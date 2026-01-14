#!/bin/bash
#
# process-monitor.sh
# Real-time process monitoring with resource tracking
#
# Purpose: Monitor specific processes and alert on resource thresholds
# Usage: process-monitor.sh [--processes NAMES] [--interval SEC] [--watch]
#
# Features:
# - Monitor CPU and memory usage
# - Alert on threshold violations
# - Track process state changes
# - Support multiple output formats
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

# Configuration
PROCESSES=""              # Processes to monitor
INTERVAL=5                # Update interval in seconds
WATCH_MODE=false          # Continuous monitoring
MEM_THRESHOLD=500         # Memory alert in MB
CPU_THRESHOLD=80          # CPU alert in percent
OUTPUT_LOG="$HOME/.process-monitor.log"

#######################################
# Print usage
#######################################
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  --processes LIST    Comma-separated process names to monitor
                      (default: all)
  --interval SEC      Update interval (default: 5)
  --watch            Enable continuous watch mode
  --mem-threshold MB  Memory alert threshold (default: 500)
  --cpu-threshold PCT CPU alert threshold (default: 80)
  --output FILE      Log file location (default: ~/.process-monitor.log)
  --help             Show this help
  --version          Show version

EXAMPLES:
  $SCRIPT_NAME --processes nginx,mysql
  $SCRIPT_NAME --watch --interval 2
  $SCRIPT_NAME --mem-threshold 1000 --cpu-threshold 50

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
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$OUTPUT_LOG"
}

#######################################
# Print colored output
#######################################
print_status() {
  local status=$1
  local message=$2
  
  case "$status" in
    ok)     echo -e "\033[32m✓\033[0m $message" ;;
    warn)   echo -e "\033[33m⚠\033[0m $message" ;;
    error)  echo -e "\033[31m✗\033[0m $message" ;;
    *)      echo "$message" ;;
  esac
}

#######################################
# Get process memory (MB)
#######################################
get_process_memory() {
  local pid=$1
  
  if [ ! -r "/proc/$pid/status" ]; then
    echo 0
    return
  fi
  
  awk '/VmRSS/ {print int($2/1024)}' "/proc/$pid/status"
}

#######################################
# Get process CPU usage
#######################################
get_process_cpu() {
  local pid=$1
  
  ps -p "$pid" -o %cpu= 2>/dev/null | xargs || echo 0
}

#######################################
# Check if process is running
#######################################
process_running() {
  local pid=$1
  kill -0 "$pid" 2>/dev/null
}

#######################################
# Get process state
#######################################
get_process_state() {
  local pid=$1
  ps -p "$pid" -o stat= 2>/dev/null | xargs || echo "?"
}

#######################################
# Monitor single process
#######################################
monitor_process() {
  local name=$1
  local pid
  local state mem cpu prev_state
  
  # Find process
  pid=$(pgrep -o "$name" 2>/dev/null) || pid=""
  
  if [ -z "$pid" ]; then
    print_status error "$name: NOT RUNNING"
    log "ALERT: $name not running"
    return
  fi
  
  # Get metrics
  state=$(get_process_state "$pid")
  mem=$(get_process_memory "$pid")
  cpu=$(get_process_cpu "$pid")
  
  # Check thresholds
  if [ "${mem%.*}" -gt "$MEM_THRESHOLD" ]; then
    print_status warn "$name (PID $pid): Memory ${mem}MB > ${MEM_THRESHOLD}MB"
    log "ALERT: $name memory high: ${mem}MB"
  elif [ "${cpu%.*}" -gt "$CPU_THRESHOLD" ]; then
    print_status warn "$name (PID $pid): CPU ${cpu}% > ${CPU_THRESHOLD}%"
    log "ALERT: $name CPU high: ${cpu}%"
  else
    print_status ok "$name (PID $pid): CPU ${cpu}% Memory ${mem}MB"
  fi
}

#######################################
# Monitor all processes
#######################################
monitor_all() {
  local prev_pids=""
  
  ps aux --sort=-%cpu | tail -n +2 | while read -r line; do
    local pid user cpu mem cmd
    
    pid=$(echo "$line" | awk '{print $2}')
    user=$(echo "$line" | awk '{print $1}')
    cpu=$(echo "$line" | awk '{print $3}')
    mem=$(echo "$line" | awk '{print $6/1024}')
    cmd=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
    
    if [ "${cpu%.*}" -gt "$CPU_THRESHOLD" ] || [ "${mem%.*}" -gt "$MEM_THRESHOLD" ]; then
      printf "%-8s %-10s %6.1f%% %7.0fMB  %s\n" "$user" "$pid" "$cpu" "$mem" "$cmd"
    fi
  done | head -10
}

#######################################
# Main monitoring loop
#######################################
monitor_loop() {
  while true; do
    clear
    echo "╔════════════════════════════════════════════╗"
    echo "║    PROCESS MONITOR - $(date '+%Y-%m-%d %H:%M:%S')    ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    
    if [ -n "$PROCESSES" ]; then
      # Monitor specific processes
      echo "Monitoring Processes:"
      echo "────────────────────────────────────────────"
      for proc in $(echo "$PROCESSES" | tr ',' ' '); do
        monitor_process "$proc"
      done
    else
      # Monitor all heavy processes
      echo "Top Resource Consumers:"
      echo "────────────────────────────────────────────"
      monitor_all
    fi
    
    echo ""
    echo "Thresholds: Memory > ${MEM_THRESHOLD}MB, CPU > ${CPU_THRESHOLD}%"
    echo "Update interval: ${INTERVAL}s"
    echo ""
    
    if ! $WATCH_MODE; then
      break
    fi
    
    sleep "$INTERVAL"
  done
}

#######################################
# Parse arguments
#######################################
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --processes)
        PROCESSES="$2"
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
        MEM_THRESHOLD="$2"
        shift 2
        ;;
      --cpu-threshold)
        CPU_THRESHOLD="$2"
        shift 2
        ;;
      --output)
        OUTPUT_LOG="$2"
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
# Main
#######################################
main() {
  # Parse arguments
  parse_arguments "$@"
  
  # Ensure log directory exists
  mkdir -p "$(dirname "$OUTPUT_LOG")"
  
  # Start monitoring
  monitor_loop
}

# Run main
main "$@"
