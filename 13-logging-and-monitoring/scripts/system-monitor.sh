#!/bin/bash
################################################################################
# system-monitor.sh
# Real-time system monitoring with alerts
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85
LOAD_THRESHOLD=4
INTERVAL=5
ITERATIONS=0

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Real-time system monitoring with alerts

OPTIONS:
    --cpu PERCENT       CPU alert threshold (default: 80)
    --memory PERCENT    Memory alert threshold (default: 80)
    --disk PERCENT      Disk alert threshold (default: 85)
    --load LOAD         Load average threshold (default: 4)
    --interval SECS     Update interval (default: 5 seconds)
    --count N           Number of iterations (default: infinite)
    --process NAME      Monitor specific process
    --log FILE          Log alerts to file
    --once              Single snapshot and exit
    --help              Show this help

EXAMPLES:
    # Real-time monitoring with defaults
    $0
    
    # Tighter thresholds
    $0 --cpu 70 --memory 75
    
    # Monitor specific process
    $0 --process nginx --interval 10
    
    # Single snapshot
    $0 --once
    
    # Log to file
    $0 --log /tmp/monitoring.log --count 60

EOF
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_alert() {
    echo -e "${RED}✗ ALERT:${NC} $1"
}

log_alert() {
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

check_cpu() {
    # Get CPU usage (simplified - last idle percentage)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | \
        awk '{print int(100 - $8)}' 2>/dev/null || echo 0)
    
    if [[ $cpu_usage -gt $CPU_THRESHOLD ]]; then
        print_alert "CPU usage: ${cpu_usage}% (threshold: $CPU_THRESHOLD%)"
        log_alert "CPU usage: ${cpu_usage}% (threshold: $CPU_THRESHOLD%)"
    else
        print_ok "CPU: ${cpu_usage}% (threshold: $CPU_THRESHOLD%)"
    fi
}

check_memory() {
    # Get memory usage
    local mem_usage=$(free | grep Mem | awk '{print int($3/$2*100)}')
    
    if [[ $mem_usage -gt $MEM_THRESHOLD ]]; then
        print_alert "Memory usage: ${mem_usage}% (threshold: $MEM_THRESHOLD%)"
        log_alert "Memory usage: ${mem_usage}% (threshold: $MEM_THRESHOLD%)"
    else
        print_ok "Memory: ${mem_usage}% (threshold: $MEM_THRESHOLD%)"
    fi
}

check_disk() {
    # Check all filesystems
    df -h | tail -n +2 | while read line; do
        usage=$(echo $line | awk '{print $5}' | cut -d'%' -f1)
        mount=$(echo $line | awk '{print $6}')
        fs=$(echo $line | awk '{print $1}')
        
        if [[ -z "$usage" ]]; then
            continue
        fi
        
        if [[ $usage -gt $DISK_THRESHOLD ]]; then
            print_alert "Disk $mount is ${usage}% full"
            log_alert "Disk $mount is ${usage}% full"
        else
            if [[ $usage -gt 70 ]]; then
                print_warn "Disk $mount: ${usage}%"
            else
                print_ok "Disk $mount: ${usage}%"
            fi
        fi
    done
}

check_load() {
    # Get load average
    local load=$(uptime | grep -oE 'load average[^,]*' | cut -d' ' -f3)
    
    # Convert to integer for comparison
    local load_int=${load%.*}
    
    if [[ $load_int -gt $LOAD_THRESHOLD ]]; then
        print_alert "Load average: $load (threshold: $LOAD_THRESHOLD)"
        log_alert "Load average: $load (threshold: $LOAD_THRESHOLD)"
    else
        print_ok "Load: $load (threshold: $LOAD_THRESHOLD)"
    fi
}

check_processes() {
    # Count running processes
    local proc_count=$(ps aux | wc -l)
    
    echo "Running processes: $((proc_count - 1))"
}

check_specific_process() {
    local proc_name="$1"
    
    local count=$(pgrep -c "$proc_name" 2>/dev/null || echo 0)
    local status="unknown"
    
    if [[ $count -gt 0 ]]; then
        status="running ($count instances)"
        print_ok "$proc_name: $status"
    else
        status="not running"
        print_alert "$proc_name: $status"
        log_alert "Process $proc_name is not running"
    fi
}

check_network() {
    # Network connections
    local tcp_conn=$(ss -tn 2>/dev/null | grep ESTAB | wc -l || echo 0)
    local listen=$(ss -tln 2>/dev/null | grep LISTEN | wc -l || echo 0)
    
    echo "Network: $tcp_conn established, $listen listening"
}

check_services() {
    # Check critical services
    local services=("ssh" "systemd-journald")
    
    for service in "${services[@]}"; do
        if pgrep -x "$service" > /dev/null 2>&1 || systemctl is-active "$service" &>/dev/null; then
            print_ok "$service is running"
        else
            print_warn "$service may not be running"
        fi
    done
}

snapshot_top_processes() {
    echo ""
    echo "=== Top 5 CPU consumers ==="
    top -bn1 | tail -n +8 | head -5 | awk '{printf "%-15s %5s%% CPU\n", $12, $9}'
    
    echo ""
    echo "=== Top 5 Memory consumers ==="
    top -bn1 | tail -n +8 | head -5 | awk '{printf "%-15s %5s%% MEM\n", $12, $10}'
}

show_summary() {
    echo ""
    echo "=== System Summary ==="
    
    # Uptime
    uptime
    
    # Memory
    free -h | grep Mem | awk '{printf "Memory: %s used of %s (%.0f%%)\n", $3, $2, $3/$2*100}'
    
    # Disk
    df -h / | tail -1 | awk '{printf "Root disk: %s used of %s (%.0f%%)\n", $3, $2, $3/$2*100}'
    
    # Last few errors
    if command -v journalctl &>/dev/null; then
        local errors=$(journalctl -p err --since "1 hour ago" 2>/dev/null | wc -l || echo 0)
        echo "Errors (last hour): $errors"
    fi
}

################################################################################
# Main Script
################################################################################

main() {
    local PROCESS=""
    local LOG_FILE=""
    local ONCE=0
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --cpu)
                CPU_THRESHOLD="$2"
                shift 2
                ;;
            --memory)
                MEM_THRESHOLD="$2"
                shift 2
                ;;
            --disk)
                DISK_THRESHOLD="$2"
                shift 2
                ;;
            --load)
                LOAD_THRESHOLD="$2"
                shift 2
                ;;
            --interval)
                INTERVAL="$2"
                shift 2
                ;;
            --count)
                ITERATIONS="$2"
                shift 2
                ;;
            --process)
                PROCESS="$2"
                shift 2
                ;;
            --log)
                LOG_FILE="$2"
                shift 2
                ;;
            --once)
                ONCE=1
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Clear screen if interactive
    if [[ -t 1 ]]; then
        clear
    fi
    
    echo "System Monitor"
    echo "Thresholds: CPU=$CPU_THRESHOLD%, Memory=$MEM_THRESHOLD%, Disk=$DISK_THRESHOLD%, Load=$LOAD_THRESHOLD"
    echo ""
    
    local count=0
    
    while true; do
        # Show timestamp
        echo "[$(date +'%Y-%m-%d %H:%M:%S')]"
        
        # Run checks
        check_cpu
        echo ""
        
        check_memory
        echo ""
        
        check_disk
        echo ""
        
        check_load
        echo ""
        
        if [[ -n "$PROCESS" ]]; then
            check_specific_process "$PROCESS"
            echo ""
        fi
        
        check_network
        echo ""
        
        # Full report on first iteration
        if [[ $count -eq 0 ]]; then
            snapshot_top_processes
            show_summary
        fi
        
        # Exit conditions
        if [[ $ONCE -eq 1 ]]; then
            break
        fi
        
        ((count++))
        
        if [[ $ITERATIONS -gt 0 ]] && [[ $count -ge $ITERATIONS ]]; then
            break
        fi
        
        # Sleep before next iteration
        sleep "$INTERVAL"
        
        # Clear screen for next iteration
        if [[ -t 1 ]]; then
            clear
        else
            echo "---"
        fi
    done
    
    if [[ -n "$LOG_FILE" ]]; then
        print_ok "Monitoring log saved to: $LOG_FILE"
    fi
}

main "$@"
