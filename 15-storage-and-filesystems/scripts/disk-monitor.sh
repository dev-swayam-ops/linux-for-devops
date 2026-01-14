#!/bin/bash

################################################################################
# Disk Monitor Script
# Monitor disk usage and send alerts when thresholds are exceeded
# 
# Usage: ./disk-monitor.sh [--threshold 80] [--interval 60]
# Examples:
#   ./disk-monitor.sh                    # Default 80% threshold
#   ./disk-monitor.sh --threshold 70     # Alert at 70%
#   ./disk-monitor.sh --interval 300     # Check every 5 minutes
################################################################################

set -euo pipefail

# Configuration
THRESHOLD=${THRESHOLD:-80}           # Alert if disk usage exceeds this %
CHECK_INTERVAL=${CHECK_INTERVAL:-300} # Check interval in seconds (5 min default)
LOG_FILE="/var/log/disk-monitor.log"
LOCK_FILE="/var/run/disk-monitor.pid"
ALERT_COOLDOWN=3600                 # Cooldown between alerts (1 hour)
ALERT_LAST_FILE="/tmp/disk-monitor-alert-time.txt"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

################################################################################
# Functions
################################################################################

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [[ "$level" == "ERROR" || "$level" == "WARNING" ]]; then
        echo -e "${YELLOW}[$timestamp] [$level]${NC} $message" >&2
    else
        echo "[$timestamp] [$level] $message"
    fi
}

# Send alert (email or log)
send_alert() {
    local subject="$1"
    local message="$2"
    
    # Check cooldown
    if [[ -f "$ALERT_LAST_FILE" ]]; then
        local last_alert=$(cat "$ALERT_LAST_FILE")
        local current_time=$(date +%s)
        if (( current_time - last_alert < ALERT_COOLDOWN )); then
            return 0 # Skip alert if within cooldown
        fi
    fi
    
    # Log the alert
    log_message "ALERT" "$subject: $message"
    
    # Update last alert time
    date +%s > "$ALERT_LAST_FILE"
    
    # Send email if mail command exists
    if command -v mail &> /dev/null && [[ -n "${ADMIN_EMAIL:-}" ]]; then
        echo "$message" | mail -s "DISK ALERT: $subject" "$ADMIN_EMAIL"
    fi
}

# Check disk usage
check_disk_usage() {
    local filesystems=$(df -h | awk 'NR>1 {print $1":"$2":"$3":"$4":"$5}')
    local alert_triggered=0
    
    echo -e "\n=== Disk Usage Report ==="
    echo "Threshold: ${THRESHOLD}% | Checked: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "─────────────────────────────────────────────────────────────────"
    
    while IFS=: read -r device size used avail usage; do
        usage_percent=$(echo "$usage" | sed 's/%//')
        
        # Format for display
        printf "%-20s %8s used of %-8s (%3s%%)" "$device" "$used" "$size" "$usage_percent"
        
        # Check threshold
        if (( usage_percent >= THRESHOLD )); then
            echo -e " ${RED}⚠ CRITICAL${NC}"
            alert_triggered=1
            send_alert "High Disk Usage" "$device: $usage_percent% of $size used"
        else
            # Show progress bar
            local bar_length=20
            local filled=$(( (usage_percent * bar_length) / 100 ))
            local empty=$(( bar_length - filled ))
            printf " ["
            printf "%-${filled}s" "=" | tr ' ' '='
            printf "%-${empty}s" " "
            echo "]"
        fi
    done <<< "$filesystems"
    
    echo "─────────────────────────────────────────────────────────────────"
    
    return $alert_triggered
}

# Check inode usage
check_inode_usage() {
    echo -e "\n=== Inode Usage Report ==="
    
    local inode_high=0
    df -i | awk 'NR>1 {print $1":"$6}' | while IFS=: read -r device usage; do
        usage_percent=$(echo "$usage" | sed 's/%//')
        
        printf "%-20s %3s%% inodes used" "$device" "$usage_percent"
        
        if (( usage_percent >= THRESHOLD )); then
            echo -e " ${RED}⚠ CRITICAL${NC}"
            inode_high=1
        else
            echo ""
        fi
    done
    
    if (( inode_high == 1 )); then
        log_message "WARNING" "High inode usage detected"
    fi
}

# Get largest directories
get_largest_dirs() {
    echo -e "\n=== Largest Directories ==="
    for mount_point in $(mount | grep -E '^/dev' | awk '{print $3}'); do
        if [[ -r "$mount_point" ]]; then
            echo "Top directories in $mount_point:"
            du -hs "$mount_point"/* 2>/dev/null | sort -rh | head -5 | \
                awk '{printf "  %-40s %8s\n", $2, $1}'
        fi
    done
}

# Cleanup function
cleanup() {
    log_message "INFO" "Disk monitor stopped"
    rm -f "$LOCK_FILE"
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --threshold)
                THRESHOLD="$2"
                shift 2
                ;;
            --interval)
                CHECK_INTERVAL="$2"
                shift 2
                ;;
            --log)
                LOG_FILE="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Disk Monitor - Monitor disk and inode usage with alerts

Usage: $(basename "$0") [OPTIONS]

Options:
  --threshold PCT   Alert if usage exceeds PCT% (default: 80)
  --interval SEC    Check interval in seconds (default: 300)
  --log FILE        Log file path (default: /var/log/disk-monitor.log)
  --help            Show this help message

Examples:
  $(basename "$0")                      # Default settings
  $(basename "$0") --threshold 70       # Alert at 70%
  $(basename "$0") --interval 60        # Check every 60 seconds
  $(basename "$0") --threshold 85 --interval 600  # Both options

Configuration via environment:
  export THRESHOLD=75
  export ADMIN_EMAIL="admin@example.com"
  $(basename "$0")

Log file: /var/log/disk-monitor.log
Alert cooldown: 1 hour between alerts per filesystem
EOF
}

################################################################################
# Main
################################################################################

main() {
    parse_args "$@"
    
    # Validate threshold
    if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 1 || THRESHOLD > 100 )); then
        echo "Error: Threshold must be 1-100" >&2
        exit 1
    fi
    
    # Create log directory if needed
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Check if already running
    if [[ -f "$LOCK_FILE" ]]; then
        old_pid=$(cat "$LOCK_FILE")
        if kill -0 "$old_pid" 2>/dev/null; then
            echo "Disk monitor already running (PID: $old_pid)"
            exit 1
        fi
    fi
    
    # Write PID
    echo "$$" > "$LOCK_FILE"
    
    # Setup signal handlers
    trap cleanup SIGTERM SIGINT
    
    log_message "INFO" "Disk monitor started (PID: $$, Threshold: ${THRESHOLD}%, Interval: ${CHECK_INTERVAL}s)"
    
    # Main loop
    while true; do
        {
            check_disk_usage
            check_inode_usage
            get_largest_dirs
        } | tee -a "$LOG_FILE"
        
        sleep "$CHECK_INTERVAL"
    done
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
