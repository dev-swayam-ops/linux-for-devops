#!/bin/bash
#
# daemon-monitor.sh
# Real-time service monitoring and status reporting
#
# Purpose: Monitor systemd services and alert on state changes
# Usage: daemon-monitor.sh [--services LIST] [--interval SECONDS] [--watch]
#
# Features:
# - Monitor specific services
# - Alert on state changes
# - Real-time or one-time mode
# - Threshold-based warnings
# - Process resource tracking
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

# Configuration defaults
SERVICES=()                    # Services to monitor
INTERVAL=60                   # Update interval (seconds)
WATCH_MODE=false             # Continuous monitoring
ALERT_THRESHOLD_MEM=500      # Memory threshold (MB)
ALERT_THRESHOLD_CPU=80       # CPU threshold (%)
CHECK_FAILED=true            # Alert on failed services
LOG_FILE="${HOME}/.daemon-monitor.log"

# Color codes
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# Tracking
declare -A LAST_STATE

#######################################
# Print usage
#######################################
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  --services LIST       Comma-separated services to monitor
                        (default: all running services)
  --interval SECONDS    Update interval (default: 60)
  --watch              Continuous monitoring mode
  --mem-threshold MB   Memory alert threshold (default: 500)
  --cpu-threshold PCT  CPU alert threshold (default: 80)
  --log FILE           Log file location
  --help              Show this help message
  --version           Show version

EXAMPLES:
  # Monitor specific services
  $SCRIPT_NAME --services nginx,mysql,postgresql

  # Continuous monitoring every 30 seconds
  $SCRIPT_NAME --watch --interval 30 --services nginx,mysql

  # One-time check with alerts
  $SCRIPT_NAME --mem-threshold 1000 --cpu-threshold 50

EXIT CODES:
  0 = All services healthy
  1 = Warning (high resource usage)
  2 = Critical (services failed)

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
# Log message
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
# Get service status
#######################################
get_service_status() {
  local service="$1"
  
  if systemctl is-active --quiet "$service" 2>/dev/null; then
    echo "running"
  else
    echo "stopped"
  fi
}

#######################################
# Get service state
#######################################
get_service_state() {
  local service="$1"
  systemctl show -p ActiveState --value "$service" 2>/dev/null || echo "unknown"
}

#######################################
# Get process ID
#######################################
get_service_pid() {
  local service="$1"
  systemctl show -p MainPID --value "$service" 2>/dev/null
}

#######################################
# Get memory usage (MB)
#######################################
get_process_memory() {
  local pid="$1"
  
  if [ -z "$pid" ] || [ "$pid" = "0" ]; then
    echo 0
    return
  fi
  
  if [ -r "/proc/$pid/status" ]; then
    awk '/VmRSS/ {print int($2/1024)}' "/proc/$pid/status"
  else
    echo 0
  fi
}

#######################################
# Get CPU usage (%)
#######################################
get_process_cpu() {
  local pid="$1"
  
  if [ -z "$pid" ] || [ "$pid" = "0" ]; then
    echo 0
    return
  fi
  
  ps -p "$pid" -o %cpu= 2>/dev/null | xargs || echo 0
}

#######################################
# Format status for display
#######################################
format_status() {
  local service="$1"
  local state="$2"
  
  case "$state" in
    active)
      echo -e "${COLOR_GREEN}●${COLOR_RESET} $service"
      ;;
    inactive)
      echo -e "${COLOR_YELLOW}○${COLOR_RESET} $service"
      ;;
    failed)
      echo -e "${COLOR_RED}✗${COLOR_RESET} $service"
      ;;
    *)
      echo -e "${COLOR_BLUE}?${COLOR_RESET} $service"
      ;;
  esac
}

#######################################
# Check single service
#######################################
check_service() {
  local service="$1"
  local state
  state=$(get_service_state "$service")
  
  local pid
  pid=$(get_service_pid "$service")
  
  local status_line
  status_line="$(format_status "$service" "$state")"
  
  # Check for state change
  local state_changed=false
  if [ -v "LAST_STATE[$service]" ]; then
    if [ "${LAST_STATE[$service]}" != "$state" ]; then
      state_changed=true
    fi
  fi
  
  LAST_STATE[$service]="$state"
  
  # Resource information
  local mem=0
  local cpu=0
  if [ -n "$pid" ] && [ "$pid" != "0" ]; then
    mem=$(get_process_memory "$pid")
    cpu=$(get_process_cpu "$pid")
  fi
  
  # Alert conditions
  local alert=""
  if [ "$state" = "failed" ] && $CHECK_FAILED; then
    alert="${COLOR_RED}[FAILED]${COLOR_RESET}"
  elif [ "$mem" -gt "$ALERT_THRESHOLD_MEM" ]; then
    alert="${COLOR_YELLOW}[HIGH MEMORY: ${mem}MB]${COLOR_RESET}"
  elif (( $(echo "$cpu > $ALERT_THRESHOLD_CPU" | bc -l 2>/dev/null || echo 0) )); then
    alert="${COLOR_YELLOW}[HIGH CPU: ${cpu}%]${COLOR_RESET}"
  fi
  
  # Output
  if [ -z "$alert" ]; then
    printf "%-40s PID: %-6s MEM: %4dMB CPU: %5.1f%%\n" \
      "$status_line" "$pid" "$mem" "$cpu"
  else
    printf "%-40s PID: %-6s MEM: %4dMB CPU: %5.1f%% %b\n" \
      "$status_line" "$pid" "$mem" "$cpu" "$alert"
  fi
  
  # Log state changes
  if $state_changed; then
    log_message "INFO" "$service changed state from ${LAST_STATE[$service]} to $state"
  fi
}

#######################################
# Get service list to monitor
#######################################
get_services_to_monitor() {
  if [ ${#SERVICES[@]} -eq 0 ]; then
    # Monitor all running services
    systemctl list-units --type=service --state=running --no-legend | awk '{print $1}' | sed 's/\.service$//'
  else
    printf '%s\n' "${SERVICES[@]}"
  fi
}

#######################################
# Monitor all services
#######################################
monitor_services() {
  local services
  services=$(get_services_to_monitor)
  
  echo "=== Service Monitor: $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo "Services: $(echo "$services" | wc -l) | Memory Threshold: ${ALERT_THRESHOLD_MEM}MB | CPU Threshold: ${ALERT_THRESHOLD_CPU}%"
  echo ""
  echo "Status                                        PID    MEM       CPU      Alerts"
  echo "─────────────────────────────────────────────────────────────────────────────────"
  
  while IFS= read -r service; do
    if [ -n "$service" ]; then
      check_service "$service"
    fi
  done <<< "$services"
  
  echo ""
}

#######################################
# Run in watch mode
#######################################
run_watch_mode() {
  trap 'echo ""; exit 0' SIGINT SIGTERM
  
  log_message "INFO" "Watch mode started (interval: ${INTERVAL}s)"
  
  while true; do
    clear
    monitor_services
    
    echo "Next update in ${INTERVAL}s (Ctrl+C to exit)"
    sleep "$INTERVAL"
  done
}

#######################################
# Parse arguments
#######################################
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --services)
        IFS=',' read -ra SERVICES <<< "$2"
        shift 2
        ;;
      --interval)
        INTERVAL="$2"
        shift 2
        ;;
      --watch)
        WATCH_MODE=true
        shift
        ;;
      --mem-threshold)
        ALERT_THRESHOLD_MEM="$2"
        shift 2
        ;;
      --cpu-threshold)
        ALERT_THRESHOLD_CPU="$2"
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
        exit 1
        ;;
    esac
  done
}

#######################################
# Validate configuration
#######################################
validate_config() {
  if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || (( INTERVAL < 1 )); then
    echo "Error: Invalid interval: $INTERVAL" >&2
    exit 1
  fi
  
  if ! [[ "$ALERT_THRESHOLD_MEM" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid memory threshold: $ALERT_THRESHOLD_MEM" >&2
    exit 1
  fi
  
  if ! [[ "$ALERT_THRESHOLD_CPU" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid CPU threshold: $ALERT_THRESHOLD_CPU" >&2
    exit 1
  fi
}

#######################################
# Main function
#######################################
main() {
  # Ensure log directory exists
  local log_dir
  log_dir=$(dirname "$LOG_FILE")
  mkdir -p "$log_dir" 2>/dev/null || true
  
  log_message "INFO" "Daemon monitor started"
  
  if $WATCH_MODE; then
    run_watch_mode
  else
    monitor_services
  fi
}

# Parse arguments
parse_arguments "$@"
validate_config

# Run main
main
