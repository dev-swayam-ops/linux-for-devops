#!/bin/bash
#
# disk-monitor.sh
# Real-time disk space monitoring with alerts
#
# Purpose: Monitor disk usage and alert when thresholds exceeded
# Usage: disk-monitor.sh [--warning 80] [--critical 90] [--interval 60]
#
# Features:
# - Monitor all mounted filesystems
# - Color-coded output (green/yellow/red)
# - Email/syslog alerts on threshold breach
# - Non-persistent daemon mode
# - Partition exclusion support
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"

# Configuration defaults
WARNING_THRESHOLD=80      # Percentage
CRITICAL_THRESHOLD=90     # Percentage
CHECK_INTERVAL=60         # Seconds
DAEMON_MODE=false
LOG_FILE="${HOME}/.disk-monitor.log"
ALERT_EMAIL=""
EXCLUDE_FILESYSTEMS="tmpfs|devtmpfs|squashfs|vfat"

# Color codes
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_RESET='\033[0m'

# State tracking (for persistent daemon)
declare -A LAST_ALERT_TIME

#######################################
# Print script usage
#######################################
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  --warning PERCENT       Warning threshold (default: 80)
  --critical PERCENT      Critical threshold (default: 90)
  --interval SECONDS      Check interval in daemon mode (default: 60)
  --daemon                Run as daemon (continuous monitoring)
  --email ADDR            Email address for alerts
  --exclude PATTERN       Regex pattern for filesystems to exclude
  --log FILE              Log file location (default: ~/.disk-monitor.log)
  --help                  Show this help message
  --version               Show version

EXAMPLES:
  # Single check with defaults
  $SCRIPT_NAME

  # Run as daemon with custom thresholds
  $SCRIPT_NAME --daemon --warning 75 --critical 85

  # Alert via email on threshold
  $SCRIPT_NAME --daemon --email admin@example.com --critical 85

  # Exclude certain filesystems
  $SCRIPT_NAME --exclude "tmpfs|/boot"

EXIT CODES:
  0 = All filesystems OK
  1 = Warning threshold exceeded
  2 = Critical threshold exceeded
  3 = Error occurred

EOF
  exit 0
}

#######################################
# Print version
#######################################
print_version() {
  echo "$SCRIPT_NAME version $VERSION"
  exit 0
}

#######################################
# Log message with timestamp
#######################################
log_message() {
  local level="$1"
  shift
  local message="$@"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

#######################################
# Send email alert
#######################################
send_alert() {
  local subject="$1"
  local message="$2"
  
  if [ -z "$ALERT_EMAIL" ]; then
    return 0
  fi
  
  if ! command -v mail &>/dev/null && ! command -v sendmail &>/dev/null; then
    log_message "WARN" "Email command not found, skipping alert"
    return 1
  fi
  
  {
    echo "Disk monitoring alert from $(hostname)"
    echo "Time: $(date)"
    echo ""
    echo "$message"
  } | mail -s "$subject" "$ALERT_EMAIL" 2>/dev/null || \
    log_message "ERROR" "Failed to send email alert to $ALERT_EMAIL"
}

#######################################
# Get filesystem list with usage
#######################################
get_disk_usage() {
  df -h | grep -v "^Filesystem" | grep -v "^$"
}

#######################################
# Get numeric usage percentage
#######################################
get_usage_percent() {
  local percent="$1"
  echo "${percent%\%}"
}

#######################################
# Color code usage level
#######################################
colorize_status() {
  local percent="$1"
  local status="$2"
  
  percent=$(get_usage_percent "$percent")
  
  if (( percent >= CRITICAL_THRESHOLD )); then
    echo -e "${COLOR_RED}${status}${COLOR_RESET}"
    return 2
  elif (( percent >= WARNING_THRESHOLD )); then
    echo -e "${COLOR_YELLOW}${status}${COLOR_RESET}"
    return 1
  else
    echo -e "${COLOR_GREEN}${status}${COLOR_RESET}"
    return 0
  fi
}

#######################################
# Check single filesystem
#######################################
check_filesystem() {
  local filesystem="$1"
  local mount_point="$2"
  local usage_line="$3"
  
  # Extract usage percentage
  local usage_percent
  usage_percent=$(echo "$usage_line" | awk '{print $NF}')
  
  local percent
  percent=$(get_usage_percent "$usage_percent")
  
  # Extract used and total
  local used_size total_size
  used_size=$(echo "$usage_line" | awk '{print $3}')
  total_size=$(echo "$usage_line" | awk '{print $2}')
  
  # Format output
  local status
  status="[${mount_point}] ${used_size} / ${total_size} (${usage_percent})"
  
  # Check thresholds and determine return code
  local rc=0
  if (( percent >= CRITICAL_THRESHOLD )); then
    rc=2
    printf "%-50s %s\n" "CRITICAL:" "$(colorize_status "$usage_percent" "$status" 2>/dev/null || echo "$status")"
    
    log_message "CRIT" "Filesystem $mount_point is $usage_percent full"
    send_alert "CRITICAL: Disk Full Alert on $(hostname)" \
      "Filesystem: $mount_point\nUsage: $usage_percent\nDetails: $status"
    
  elif (( percent >= WARNING_THRESHOLD )); then
    rc=1
    printf "%-50s %s\n" "WARNING:" "$(colorize_status "$usage_percent" "$status" 2>/dev/null || echo "$status")"
    
    log_message "WARN" "Filesystem $mount_point is $usage_percent full"
    send_alert "WARNING: High Disk Usage on $(hostname)" \
      "Filesystem: $mount_point\nUsage: $usage_percent\nDetails: $status"
    
  else
    printf "%-50s %s\n" "OK:" "$(colorize_status "$usage_percent" "$status" 2>/dev/null || echo "$status")"
    log_message "INFO" "Filesystem $mount_point OK at $usage_percent"
  fi
  
  return $rc
}

#######################################
# Check all filesystems
#######################################
check_all_filesystems() {
  local max_rc=0
  
  echo "=== Disk Usage Report: $(date '+%Y-%m-%d %H:%M:%S') ==="
  
  get_disk_usage | while read -r line; do
    local filesystem mount_point usage_line
    
    filesystem=$(echo "$line" | awk '{print $1}')
    mount_point=$(echo "$line" | awk '{print $NF}')
    usage_line="$line"
    
    # Skip excluded filesystems
    if echo "$filesystem" | grep -qE "$EXCLUDE_FILESYSTEMS"; then
      continue
    fi
    
    local rc
    check_filesystem "$filesystem" "$mount_point" "$usage_line"
    rc=$?
    
    if (( rc > max_rc )); then
      max_rc=$rc
    fi
  done
  
  return $max_rc
}

#######################################
# Run in daemon mode
#######################################
run_daemon() {
  log_message "INFO" "Disk monitor daemon started (interval: ${CHECK_INTERVAL}s, warning: ${WARNING_THRESHOLD}%, critical: ${CRITICAL_THRESHOLD}%)"
  
  # Trap signals for graceful shutdown
  trap 'log_message "INFO" "Disk monitor daemon stopped"; exit 0' SIGTERM SIGINT
  
  while true; do
    check_all_filesystems || true
    sleep "$CHECK_INTERVAL"
  done
}

#######################################
# Parse command-line arguments
#######################################
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --warning)
        WARNING_THRESHOLD="$2"
        shift 2
        ;;
      --critical)
        CRITICAL_THRESHOLD="$2"
        shift 2
        ;;
      --interval)
        CHECK_INTERVAL="$2"
        shift 2
        ;;
      --daemon)
        DAEMON_MODE=true
        shift
        ;;
      --email)
        ALERT_EMAIL="$2"
        shift 2
        ;;
      --exclude)
        EXCLUDE_FILESYSTEMS="$2"
        shift 2
        ;;
      --log)
        LOG_FILE="$2"
        shift 2
        ;;
      --help|-h)
        usage
        ;;
      --version|-v)
        print_version
        ;;
      *)
        echo "Error: Unknown option: $1" >&2
        echo "Use --help for usage information"
        exit 3
        ;;
    esac
  done
}

#######################################
# Validate thresholds
#######################################
validate_config() {
  if ! [[ "$WARNING_THRESHOLD" =~ ^[0-9]+$ ]] || (( WARNING_THRESHOLD > 100 )); then
    echo "Error: Invalid warning threshold: $WARNING_THRESHOLD" >&2
    exit 3
  fi
  
  if ! [[ "$CRITICAL_THRESHOLD" =~ ^[0-9]+$ ]] || (( CRITICAL_THRESHOLD > 100 )); then
    echo "Error: Invalid critical threshold: $CRITICAL_THRESHOLD" >&2
    exit 3
  fi
  
  if (( WARNING_THRESHOLD >= CRITICAL_THRESHOLD )); then
    echo "Error: Warning threshold must be less than critical threshold" >&2
    exit 3
  fi
  
  if ! [[ "$CHECK_INTERVAL" =~ ^[0-9]+$ ]] || (( CHECK_INTERVAL < 1 )); then
    echo "Error: Invalid check interval: $CHECK_INTERVAL" >&2
    exit 3
  fi
}

#######################################
# Main function
#######################################
main() {
  # Ensure log directory exists
  local log_dir
  log_dir=$(dirname "$LOG_FILE")
  mkdir -p "$log_dir" || true
  
  log_message "INFO" "Script started with warning=$WARNING_THRESHOLD%, critical=$CRITICAL_THRESHOLD%"
  
  if $DAEMON_MODE; then
    run_daemon
  else
    check_all_filesystems
  fi
}

# Parse arguments
parse_arguments "$@"
validate_config

# Run main
main
