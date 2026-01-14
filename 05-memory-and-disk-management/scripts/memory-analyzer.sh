#!/bin/bash
#
# memory-analyzer.sh
# Memory usage analysis by process
#
# Purpose: Analyze system and per-process memory usage
# Usage: memory-analyzer.sh [--top N] [--threshold MB] [--format json|table]
#
# Features:
# - Top N memory consumers
# - Total memory by user
# - Memory trend analysis
# - Multiple output formats
# - Real-time monitoring mode
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION="1.0.0"

# Configuration defaults
TOP_N=10                  # Show top N processes
THRESHOLD_MB=50          # Only show processes > this size
FORMAT="table"           # Output format: table, json, csv
MONITOR_MODE=false
INTERVAL=5               # Update interval for monitor mode
INCLUDE_SWAP=false

# Color codes
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_RESET='\033[0m'

#######################################
# Print script usage
#######################################
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  --top N               Show top N memory consumers (default: 10)
  --threshold MB        Minimum MB to display (default: 50)
  --format FORMAT       Output format: table, json, csv (default: table)
  --monitor             Run in monitor mode (continuous)
  --interval SECONDS    Update interval for monitor mode (default: 5)
  --swap                Include swap memory in analysis
  --help                Show this help message
  --version             Show version

EXAMPLES:
  # Show top 10 memory consumers
  $SCRIPT_NAME

  # Show top 20, only >= 100MB
  $SCRIPT_NAME --top 20 --threshold 100

  # Continuous monitoring
  $SCRIPT_NAME --monitor --interval 2

  # JSON output for scripting
  $SCRIPT_NAME --format json

  # CSV output for analysis
  $SCRIPT_NAME --format csv

FEATURES:
  - Total memory by user
  - Per-process breakdown (VSZ, RSS, Swap)
  - Memory trend detection
  - System-wide memory summary
  - Process filtering and sorting

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
# Convert KB to human-readable format
#######################################
to_human_readable() {
  local kb=$1
  if (( kb < 1024 )); then
    echo "${kb}K"
  elif (( kb < 1048576 )); then
    echo "$((kb / 1024))M"
  else
    echo "$((kb / 1048576))G"
  fi
}

#######################################
# Get system memory summary
#######################################
get_memory_summary() {
  echo "=== System Memory Summary: $(date '+%Y-%m-%d %H:%M:%S') ==="
  free -h | tail -3
  
  # Additional info
  local vmem_free
  vmem_free=$(free -m | awk 'NR==2 {print $7}')
  
  local swap_used
  swap_used=$(free -m | awk 'NR==3 {print $3}')
  
  echo ""
  echo "Memory Status:"
  if (( vmem_free < 500 )); then
    echo -e "${COLOR_RED}  ⚠️  LOW memory available: ${vmem_free}MB${COLOR_RESET}"
  elif (( vmem_free < 1000 )); then
    echo -e "${COLOR_YELLOW}  ⚠️  Available memory: ${vmem_free}MB${COLOR_RESET}"
  else
    echo -e "${COLOR_GREEN}  ✓ Available memory: ${vmem_free}MB${COLOR_RESET}"
  fi
  
  if (( swap_used > 0 )); then
    echo -e "${COLOR_YELLOW}  ⚠️  Swap in use: ${swap_used}MB${COLOR_RESET}"
  else
    echo -e "${COLOR_GREEN}  ✓ No swap in use${COLOR_RESET}"
  fi
}

#######################################
# Get top memory processes (table format)
#######################################
get_top_processes_table() {
  echo ""
  echo "=== Top $TOP_N Memory Consumers ==="
  printf "%-10s %-10s %-10s %-10s %-20s\n" "PID" "USER" "%MEM" "RSS(MB)" "COMMAND"
  printf "%-10s %-10s %-10s %-10s %-20s\n" "---" "----" "-----" "-------" "-------"
  
  ps aux --sort=-%mem | awk -v threshold="$THRESHOLD_MB" -v top_n="$TOP_N" '
    NR > 1 && NF >= 11 {
      rss_mb = $6 / 1024
      if (rss_mb >= threshold && count < top_n) {
        # Truncate command to 20 chars
        cmd = substr($11, 1, 20)
        printf "%-10s %-10s %-10.1f %-10.0f %-20s\n", $2, $1, $4, rss_mb, cmd
        count++
      }
    }
  ' | head -n "$TOP_N"
}

#######################################
# Get top memory processes (JSON format)
#######################################
get_top_processes_json() {
  echo "{"
  echo '  "timestamp": "'$(date -Iseconds)'",'
  echo '  "processes": ['
  
  local first=true
  ps aux --sort=-%mem | awk -v threshold="$THRESHOLD_MB" -v top_n="$TOP_N" '
    NR > 1 && NF >= 11 {
      rss_mb = $6 / 1024
      rss_kb = $6
      vsz_mb = $5 / 1024
      if (rss_mb >= threshold && count < top_n) {
        printf "    {\n"
        printf "      \"pid\": %s,\n", $2
        printf "      \"user\": \"%s\",\n", $1
        printf "      \"percent_mem\": %.1f,\n", $4
        printf "      \"rss_mb\": %.1f,\n", rss_mb
        printf "      \"vsz_mb\": %.1f,\n", vsz_mb
        printf "      \"command\": \"%s\"\n", substr($11, 1, 100)
        if (count < top_n - 1) printf "    },\n"
        else printf "    }\n"
        count++
      }
    }
  ' | head -n "$((TOP_N * 8))"
  
  echo "  ]"
  echo "}"
}

#######################################
# Get top memory processes (CSV format)
#######################################
get_top_processes_csv() {
  echo "PID,USER,%MEM,RSS_MB,VSZ_MB,COMMAND"
  
  ps aux --sort=-%mem | awk -v threshold="$THRESHOLD_MB" -v top_n="$TOP_N" '
    NR > 1 && NF >= 11 {
      rss_mb = $6 / 1024
      vsz_mb = $5 / 1024
      if (rss_mb >= threshold && count < top_n) {
        printf "%s,%s,%.1f,%.1f,%.1f,\"%s\"\n", $2, $1, $4, rss_mb, vsz_mb, substr($11, 1, 100)
        count++
      }
    }
  '
}

#######################################
# Get memory by user
#######################################
get_memory_by_user() {
  echo ""
  echo "=== Memory Usage by User ==="
  printf "%-15s %-10s\n" "USER" "TOTAL(MB)"
  printf "%-15s %-10s\n" "----" "---------"
  
  ps aux | awk 'NR > 1 {
    user = $1
    rss_mb = $6 / 1024
    total[user] += rss_mb
  }
  END {
    for (user in total) {
      printf "%-15s %-10.1f\n", user, total[user]
    }
  }' | sort -k2 -rn
}

#######################################
# Get process memory details (detailed view)
#######################################
get_process_details() {
  echo ""
  echo "=== Detailed Process Analysis ==="
  
  ps aux --sort=-%mem | awk -v threshold="$THRESHOLD_MB" '
    NR > 1 && NF >= 11 {
      rss_mb = $6 / 1024
      if (rss_mb >= threshold) {
        if (count < 5) {
          printf "Process: %s (PID: %s)\n", $11, $2
          printf "  User: %s\n", $1
          printf "  %%CPU: %.1f, %%MEM: %.1f\n", $3, $4
          printf "  VSZ: %dMB, RSS: %.0fMB\n", $5/1024, rss_mb
          printf "\n"
          count++
        }
      }
    }
  '
}

#######################################
# Monitor mode (continuous updates)
#######################################
run_monitor() {
  trap 'echo ""; exit 0' SIGINT SIGTERM
  
  while true; do
    clear
    get_memory_summary
    get_top_processes_table
    get_memory_by_user
    
    echo ""
    echo "Next update in ${INTERVAL}s (Ctrl+C to exit)"
    sleep "$INTERVAL"
  done
}

#######################################
# Parse command-line arguments
#######################################
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --top)
        TOP_N="$2"
        shift 2
        ;;
      --threshold)
        THRESHOLD_MB="$2"
        shift 2
        ;;
      --format)
        FORMAT="$2"
        shift 2
        ;;
      --monitor)
        MONITOR_MODE=true
        shift
        ;;
      --interval)
        INTERVAL="$2"
        shift 2
        ;;
      --swap)
        INCLUDE_SWAP=true
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
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
  done
}

#######################################
# Validate configuration
#######################################
validate_config() {
  if ! [[ "$TOP_N" =~ ^[0-9]+$ ]] || (( TOP_N < 1 )); then
    echo "Error: Invalid top N value: $TOP_N" >&2
    exit 1
  fi
  
  if ! [[ "$THRESHOLD_MB" =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid threshold: $THRESHOLD_MB" >&2
    exit 1
  fi
  
  case "$FORMAT" in
    table|json|csv)
      ;;
    *)
      echo "Error: Invalid format: $FORMAT (must be table, json, or csv)" >&2
      exit 1
      ;;
  esac
}

#######################################
# Main function
#######################################
main() {
  if $MONITOR_MODE; then
    run_monitor
  else
    get_memory_summary
    
    case "$FORMAT" in
      json)
        get_top_processes_json
        ;;
      csv)
        get_top_processes_csv
        ;;
      *)
        get_top_processes_table
        get_memory_by_user
        ;;
    esac
    
    get_process_details
  fi
}

# Parse arguments
parse_arguments "$@"
validate_config

# Run main
main
