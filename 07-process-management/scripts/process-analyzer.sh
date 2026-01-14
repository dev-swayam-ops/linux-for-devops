#!/bin/bash
#
# process-analyzer.sh
# Detailed process analysis and reporting tool
#
# Purpose: Gather comprehensive process information for debugging
# Usage: process-analyzer.sh [--pid PID | --name NAME] [--format text|json]
#
# Features:
# - Complete process information
# - Memory breakdown
# - File descriptor analysis
# - Process tree visualization
# - Environment variables
# - Resource limits
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

# Configuration
PID=""                    # Process ID to analyze
PROC_NAME=""              # Process name to analyze
FORMAT="text"             # Output format
DETAILED=false            # Detailed analysis

#######################################
# Print usage
#######################################
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  --pid PID          Process ID to analyze
  --name NAME        Process name to analyze
  --format FORMAT    Output format: text, json (default: text)
  --detailed         Include detailed information
  --help             Show this help
  --version          Show version

EXAMPLES:
  $SCRIPT_NAME --pid 1234
  $SCRIPT_NAME --name nginx
  $SCRIPT_NAME --pid 5678 --format json

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
# Get process info
#######################################
get_process_info() {
  local pid=$1
  
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Error: Process $pid not found" >&2
    exit 1
  fi
  
  ps -o pid,ppid,user,etime,cmd -p "$pid"
}

#######################################
# Get memory information
#######################################
get_memory_info() {
  local pid=$1
  
  if [ ! -r "/proc/$pid/status" ]; then
    echo "Memory info unavailable"
    return
  fi
  
  echo "Memory Information:"
  echo "───────────────────"
  awk '/VmPeak|VmSize|VmRSS|VmData|VmStk|VmLib/ {
    name=$1; gsub(/:$/, "", name)
    printf "  %-12s %10d kB\n", name, $2
  }' "/proc/$pid/status"
}

#######################################
# Get file descriptor info
#######################################
get_fd_info() {
  local pid=$1
  
  if [ ! -d "/proc/$pid/fd" ]; then
    echo "FD info unavailable"
    return
  fi
  
  echo ""
  echo "Open Files (File Descriptors):"
  echo "────────────────────────────────────────"
  
  local count=0
  for fd in /proc/$pid/fd/*; do
    local fd_num=$(basename "$fd")
    local target=$(readlink "$fd" 2>/dev/null || echo "?")
    printf "  FD %3s: %s\n" "$fd_num" "$target"
    count=$((count + 1))
  done
  
  echo "  Total open: $count"
}

#######################################
# Get limits
#######################################
get_limits_info() {
  local pid=$1
  
  if [ ! -r "/proc/$pid/limits" ]; then
    echo "Limits unavailable"
    return
  fi
  
  echo ""
  echo "Process Limits:"
  echo "────────────────────────────────────────"
  cat "/proc/$pid/limits" | tail -n +2 | while read -r line; do
    echo "  $line"
  done
}

#######################################
# Get environment
#######################################
get_environment() {
  local pid=$1
  
  if [ ! -r "/proc/$pid/environ" ]; then
    echo "Environment unavailable"
    return
  fi
  
  echo ""
  echo "Environment Variables:"
  echo "────────────────────────────────────────"
  cat "/proc/$pid/environ" | tr '\0' '\n' | sort | while read -r line; do
    printf "  %s\n" "$line"
  done
}

#######################################
# Get command line
#######################################
get_cmdline() {
  local pid=$1
  
  if [ ! -r "/proc/$pid/cmdline" ]; then
    echo "Command line unavailable"
    return
  fi
  
  echo ""
  echo "Command Line:"
  echo "────────────────────────────────────────"
  cat "/proc/$pid/cmdline" | tr '\0' ' ' && echo ""
}

#######################################
# Get process tree
#######################################
get_process_tree() {
  local pid=$1
  
  echo ""
  echo "Process Tree:"
  echo "────────────────────────────────────────"
  pstree -p "$pid" || echo "pstree unavailable"
}

#######################################
# Text format output
#######################################
output_text() {
  local pid=$1
  
  echo "╔════════════════════════════════════════════════════════════════╗"
  echo "║           PROCESS ANALYSIS REPORT                             ║"
  echo "║           PID: $pid"
  echo "║           Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "╚════════════════════════════════════════════════════════════════╝"
  echo ""
  
  echo "Basic Information:"
  echo "────────────────────────────────────────"
  get_process_info "$pid"
  echo ""
  
  echo "Working Directory:"
  echo "────────────────────────────────────────"
  readlink "/proc/$pid/cwd" 2>/dev/null || echo "CWD unavailable"
  echo ""
  
  get_memory_info "$pid"
  get_fd_info "$pid"
  get_limits_info "$pid"
  
  if $DETAILED; then
    get_cmdline "$pid"
    get_environment "$pid"
    get_process_tree "$pid"
  fi
}

#######################################
# JSON format output
#######################################
output_json() {
  local pid=$1
  
  echo "{"
  echo '  "timestamp": "'$(date -Iseconds)'",'
  echo '  "process": {'
  
  # Basic info
  echo '    "pid": '$pid','
  
  local ppid user cmd
  ppid=$(ps -o ppid= -p "$pid" | xargs)
  user=$(ps -o user= -p "$pid" | xargs)
  cmd=$(cat "/proc/$pid/cmdline" | tr '\0' ' ')
  
  echo '    "ppid": '$ppid','
  echo '    "user": "'$user'",'
  echo '    "command": "'$cmd'",'
  echo '    "cwd": "'$(readlink "/proc/$pid/cwd" 2>/dev/null || echo "")'\",'
  
  # Memory info
  echo '    "memory": {'
  awk '/VmPeak|VmSize|VmRSS|VmData|VmStk/ {
    name=$1; gsub(/:$/, "", name)
    lower=tolower(name)
    printf "      \"%s\": %d", lower, $2; 
    if (NR < NF-1) printf ","
    printf "\n"
  }' "/proc/$pid/status" | head -5
  echo '    },'
  
  # Open files count
  local fd_count=$(ls "/proc/$pid/fd" 2>/dev/null | wc -l)
  echo '    "open_files": '$fd_count''
  
  echo '  }'
  echo "}"
}

#######################################
# Parse arguments
#######################################
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pid)
        PID="$2"
        shift 2
        ;;
      --name)
        PROC_NAME="$2"
        shift 2
        ;;
      --format)
        FORMAT="$2"
        shift 2
        ;;
      --detailed)
        DETAILED=true
        shift
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
# Validate format
#######################################
validate_format() {
  case "$FORMAT" in
    text|json)
      ;;
    *)
      echo "Error: Invalid format: $FORMAT (must be text or json)" >&2
      exit 1
      ;;
  esac
}

#######################################
# Get PID from name
#######################################
get_pid_from_name() {
  local name=$1
  local result
  
  result=$(pgrep -o "$name" 2>/dev/null) || result=""
  
  if [ -z "$result" ]; then
    echo "Error: Process '$name' not found" >&2
    exit 1
  fi
  
  echo "$result"
}

#######################################
# Main
#######################################
main() {
  parse_arguments "$@"
  validate_format
  
  # Determine PID
  if [ -z "$PID" ] && [ -z "$PROC_NAME" ]; then
    echo "Error: Must specify --pid or --name" >&2
    exit 1
  fi
  
  if [ -n "$PROC_NAME" ]; then
    PID=$(get_pid_from_name "$PROC_NAME")
  fi
  
  # Output based on format
  case "$FORMAT" in
    text)
      output_text "$PID"
      ;;
    json)
      output_json "$PID"
      ;;
  esac
}

# Run main
main "$@"
