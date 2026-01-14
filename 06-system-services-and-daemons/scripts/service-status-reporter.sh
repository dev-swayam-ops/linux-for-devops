#!/bin/bash
#
# service-status-reporter.sh
# Comprehensive service status reporting tool
#
# Purpose: Generate detailed service status reports
# Usage: service-status-reporter.sh [--format table|json|csv] [--detailed]
#
# Features:
# - Multiple output formats
# - Boot analysis
# - Failed service detection
# - Resource usage summary
# - Dependency visualization
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

# Configuration
FORMAT="table"              # Output format
DETAILED=false              # Detailed analysis
SHOW_FAILED_ONLY=false     # Only show failed services
OUTPUT_FILE=""             # Output to file

#######################################
# Print usage
#######################################
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

OPTIONS:
  --format FORMAT      Output format: table, json, csv (default: table)
  --detailed          Include detailed analysis
  --failed-only       Show only failed services
  --output FILE       Write to file instead of stdout
  --help             Show this help
  --version          Show version

EXAMPLES:
  # Generate text report
  $SCRIPT_NAME

  # Detailed JSON report
  $SCRIPT_NAME --format json --detailed

  # Only failed services
  $SCRIPT_NAME --failed-only

  # Save to file
  $SCRIPT_NAME --format json --output report.json

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
# Echo to output (file or stdout)
#######################################
output() {
  if [ -n "$OUTPUT_FILE" ]; then
    echo "$@" >> "$OUTPUT_FILE"
  else
    echo "$@"
  fi
}

#######################################
# Get enabled services
#######################################
get_enabled_services() {
  systemctl list-unit-files --type=service --state=enabled --no-legend | wc -l
}

#######################################
# Get running services
#######################################
get_running_services() {
  systemctl list-units --type=service --state=running --no-legend | wc -l
}

#######################################
# Get failed services
#######################################
get_failed_services() {
  systemctl list-units --type=service --state=failed --no-legend
}

#######################################
# Get failed count
#######################################
get_failed_count() {
  get_failed_services | wc -l
}

#######################################
# Table format report
#######################################
report_table() {
  output "╔════════════════════════════════════════════════════════════════╗"
  output "║         SYSTEMD SERVICE STATUS REPORT                          ║"
  output "║         $(date '+%Y-%m-%d %H:%M:%S')                              ║"
  output "╚════════════════════════════════════════════════════════════════╝"
  output ""
  
  # Summary statistics
  local enabled_count running_count failed_count
  enabled_count=$(get_enabled_services)
  running_count=$(get_running_services)
  failed_count=$(get_failed_count)
  
  output "SUMMARY"
  output "────────────────────────────────────────────────────────────────"
  output "Enabled Services:    $enabled_count"
  output "Running Services:    $running_count"
  output "Failed Services:     $failed_count"
  output ""
  
  # Boot performance
  output "BOOT PERFORMANCE"
  output "────────────────────────────────────────────────────────────────"
  local boot_time
  boot_time=$(systemd-analyze | grep "Startup finished" | grep -oP '\d+\.\d+s' | head -1)
  output "Total Boot Time:     ${boot_time:-N/A}"
  output ""
  
  # Service details
  output "SERVICE DETAILS"
  output "────────────────────────────────────────────────────────────────"
  output "Status   Service Name                      Load      Active"
  output "──────   ────────────────────────────────  ───────   ──────────"
  
  systemctl list-units --type=service --all --no-legend | while read -r line; do
    local status service load active
    status=$(echo "$line" | awk '{print $1}' | sed 's/.service$//')
    load=$(echo "$line" | awk '{print $2}')
    active=$(echo "$line" | awk '{print $3}')
    
    if [ "$active" = "failed" ]; then
      printf "%-8s %-35s %-7s %s\n" "✗" "$status" "$load" "$active"
    elif [ "$active" = "running" ]; then
      printf "%-8s %-35s %-7s %s\n" "●" "$status" "$load" "$active"
    else
      printf "%-8s %-35s %-7s %s\n" "○" "$status" "$load" "$active"
    fi
  done | head -30
  
  output ""
  
  # Failed services detail
  if [ "$failed_count" -gt 0 ]; then
    output "FAILED SERVICES DETAIL"
    output "────────────────────────────────────────────────────────────────"
    
    while IFS= read -r line; do
      local service
      service=$(echo "$line" | awk '{print $1}' | sed 's/.service$//')
      
      output ""
      output "Service: $service"
      output "Status:"
      systemctl status "$service" 2>&1 | head -10 | sed 's/^/  /'
      
    done < <(get_failed_services)
    
    output ""
  fi
  
  # Slowest services
  if $DETAILED; then
    output "SLOWEST SERVICES (Boot)"
    output "────────────────────────────────────────────────────────────────"
    systemd-analyze blame | head -10 | while read -r line; do
      output "  $line"
    done
    output ""
  fi
}

#######################################
# JSON format report
#######################################
report_json() {
  local enabled_count running_count failed_count
  enabled_count=$(get_enabled_services)
  running_count=$(get_running_services)
  failed_count=$(get_failed_count)
  
  output "{"
  output '  "timestamp": "'$(date -Iseconds)'",'
  output '  "summary": {'
  output "    \"enabled_services\": $enabled_count,"
  output "    \"running_services\": $running_count,"
  output "    \"failed_services\": $failed_count"
  output "  },"
  output '  "services": ['
  
  local first=true
  systemctl list-units --type=service --all --no-legend | while read -r line; do
    local service load active
    service=$(echo "$line" | awk '{print $1}')
    load=$(echo "$line" | awk '{print $2}')
    active=$(echo "$line" | awk '{print $3}')
    
    if [ "$first" = "true" ]; then
      first=false
    else
      output ","
    fi
    
    output "    {"
    output "      \"name\": \"$service\","
    output "      \"load\": \"$load\","
    output "      \"active\": \"$active\""
    output "    }" | tr -d '\n'
    
  done
  
  output ""
  output "  ]"
  output "}"
}

#######################################
# CSV format report
#######################################
report_csv() {
  output "Service,Load,Active,PID,Memory(MB),CPU(%)"
  
  systemctl list-units --type=service --all --no-legend | while read -r line; do
    local service load active pid mem cpu
    service=$(echo "$line" | awk '{print $1}')
    load=$(echo "$line" | awk '{print $2}')
    active=$(echo "$line" | awk '{print $3}')
    pid=$(systemctl show -p MainPID --value "$service" 2>/dev/null)
    
    if [ -n "$pid" ] && [ "$pid" != "0" ] && [ -r "/proc/$pid/status" ]; then
      mem=$(awk '/VmRSS/ {print int($2/1024)}' "/proc/$pid/status")
      cpu=$(ps -p "$pid" -o %cpu= 2>/dev/null | xargs || echo 0)
    else
      pid=""
      mem=0
      cpu=0
    fi
    
    output "\"$service\",\"$load\",\"$active\",\"$pid\",\"$mem\",\"$cpu\""
  done
}

#######################################
# Parse arguments
#######################################
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format)
        FORMAT="$2"
        shift 2
        ;;
      --detailed)
        DETAILED=true
        shift
        ;;
      --failed-only)
        SHOW_FAILED_ONLY=true
        shift
        ;;
      --output)
        OUTPUT_FILE="$2"
        # Clear file if exists
        > "$OUTPUT_FILE"
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
# Validate format
#######################################
validate_format() {
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
  case "$FORMAT" in
    table)
      report_table
      ;;
    json)
      report_json
      ;;
    csv)
      report_csv
      ;;
  esac
  
  if [ -n "$OUTPUT_FILE" ]; then
    echo "Report written to: $OUTPUT_FILE"
  fi
}

# Parse arguments
parse_arguments "$@"
validate_format

# Run main
main
