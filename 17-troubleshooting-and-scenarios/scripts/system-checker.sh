#!/usr/bin/env bash
# System Health Checker
# Purpose: Quick diagnostic of system health with actionable insights
# Usage: ./system-checker.sh [--detailed] [--monitor] [--export FILE]
# Features: Health check, thresholds, monitoring mode, export results

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

# Thresholds for alerts
readonly LOAD_THRESHOLD_WARN=0.75        # Per CPU core
readonly LOAD_THRESHOLD_CRIT=0.90
readonly MEM_THRESHOLD_WARN=75           # Percentage
readonly MEM_THRESHOLD_CRIT=90
readonly DISK_THRESHOLD_WARN=80          # Percentage
readonly DISK_THRESHOLD_CRIT=95
readonly SWAP_THRESHOLD_WARN=30          # Percentage
readonly IOWAIT_THRESHOLD_WARN=20        # Percentage
readonly ZOMBIE_COUNT_WARN=5

# Options
DETAILED=false
MONITOR=false
MONITOR_INTERVAL=5
EXPORT_FILE=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ============================================================================
# LOGGING & OUTPUT
# ============================================================================

log_msg() {
    local level="$1"
    shift
    local msg="$*"
    
    case "$level" in
        OK)     echo -e "${GREEN}✓${NC} $msg" ;;
        WARN)   echo -e "${YELLOW}⚠${NC} $msg" ;;
        CRIT)   echo -e "${RED}✗${NC} $msg" ;;
        INFO)   echo -e "${BLUE}ℹ${NC} $msg" ;;
        DEBUG)  [ "$DETAILED" = true ] && echo -e "${PURPLE}debug${NC} $msg" || true ;;
    esac
}

# ============================================================================
# HELP
# ============================================================================

show_help() {
    cat << EOF
${BLUE}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
System health diagnostic tool

${BLUE}USAGE${NC}
    $SCRIPT_NAME [OPTIONS]

${BLUE}OPTIONS${NC}
    --detailed       Show detailed metrics
    --monitor        Continuous monitoring mode
    --interval SEC   Monitor update interval (default: 5)
    --export FILE    Export results to file
    --help           Show this help

${BLUE}EXAMPLES${NC}
    # Quick health check
    $SCRIPT_NAME

    # Detailed analysis
    $SCRIPT_NAME --detailed

    # Continuous monitoring
    $SCRIPT_NAME --monitor

    # Export to file
    $SCRIPT_NAME --detailed --export health.txt

${BLUE}THRESHOLDS${NC}
    Load Average:    WARN=$LOAD_THRESHOLD_WARN, CRIT=$LOAD_THRESHOLD_CRIT (per core)
    Memory:          WARN=$MEM_THRESHOLD_WARN%, CRIT=$MEM_THRESHOLD_CRIT%
    Disk:            WARN=$DISK_THRESHOLD_WARN%, CRIT=$DISK_THRESHOLD_CRIT%
    Swap:            WARN=$SWAP_THRESHOLD_WARN%
    I/O Wait:        WARN=$IOWAIT_THRESHOLD_WARN%
    Zombie Procs:    WARN=$ZOMBIE_COUNT_WARN+

EOF
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --detailed)
                DETAILED=true
                shift
                ;;
            --monitor)
                MONITOR=true
                shift
                ;;
            --interval)
                MONITOR_INTERVAL="$2"
                shift 2
                ;;
            --export)
                EXPORT_FILE="$2"
                shift 2
                ;;
            --help|-h)
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

# ============================================================================
# HEALTH CHECKS
# ============================================================================

check_load_average() {
    local cpu_count=$(nproc)
    local load=$(uptime | grep -oP '(?<=load average: )[0-9.]+' | head -1)
    local load_threshold_warn=$(echo "$LOAD_THRESHOLD_WARN * $cpu_count" | bc)
    local load_threshold_crit=$(echo "$LOAD_THRESHOLD_CRIT * $cpu_count" | bc)
    
    if (( $(echo "$load > $load_threshold_crit" | bc -l) )); then
        log_msg CRIT "Load Average: $load (CRITICAL - threshold: $load_threshold_crit)"
        return 2
    elif (( $(echo "$load > $load_threshold_warn" | bc -l) )); then
        log_msg WARN "Load Average: $load (HIGH - threshold: $load_threshold_warn)"
        return 1
    else
        log_msg OK "Load Average: $load (healthy)"
        return 0
    fi
}

check_memory() {
    local total=$(free | awk 'NR==2 {print $2}')
    local used=$(free | awk 'NR==2 {print $3}')
    local percent=$((used * 100 / total))
    
    if (( percent >= MEM_THRESHOLD_CRIT )); then
        log_msg CRIT "Memory: ${percent}% used (CRITICAL - threshold: $MEM_THRESHOLD_CRIT%)"
        return 2
    elif (( percent >= MEM_THRESHOLD_WARN )); then
        log_msg WARN "Memory: ${percent}% used (HIGH - threshold: $MEM_THRESHOLD_WARN%)"
        return 1
    else
        log_msg OK "Memory: ${percent}% used"
        return 0
    fi
}

check_disk() {
    local status=0
    
    df -h | tail -n +2 | while read -r line; do
        local filesystem=$(echo "$line" | awk '{print $1}')
        local usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        
        if (( usage >= DISK_THRESHOLD_CRIT )); then
            log_msg CRIT "Disk: $filesystem - ${usage}% used (CRITICAL)"
            return 2
        elif (( usage >= DISK_THRESHOLD_WARN )); then
            log_msg WARN "Disk: $filesystem - ${usage}% used"
            return 1
        fi
    done
}

check_swap() {
    local total=$(free | grep Swap | awk '{print $2}')
    
    if [ "$total" -eq 0 ]; then
        log_msg INFO "Swap: Not configured"
        return 0
    fi
    
    local used=$(free | grep Swap | awk '{print $3}')
    local percent=$((used * 100 / total))
    
    if (( percent >= SWAP_THRESHOLD_WARN )); then
        log_msg WARN "Swap: ${percent}% used (SWAP USAGE DETECTED)"
        return 1
    else
        log_msg OK "Swap: ${percent}% used"
        return 0
    fi
}

check_io_wait() {
    local wa=$(vmstat 1 2 | tail -1 | awk '{print $(NF-4)}')
    
    if (( $(echo "$wa > $IOWAIT_THRESHOLD_WARN" | bc -l) )); then
        log_msg WARN "I/O Wait: ${wa}% (HIGH - threshold: $IOWAIT_THRESHOLD_WARN%)"
        return 1
    else
        log_msg OK "I/O Wait: ${wa}%"
        return 0
    fi
}

check_services() {
    local failed=$(systemctl --no-pager list-units --type=service --state=failed --no-legend 2>/dev/null | wc -l)
    
    if [ "$failed" -gt 0 ]; then
        log_msg WARN "Services: $failed service(s) failed"
        
        if [ "$DETAILED" = true ]; then
            systemctl --no-pager list-units --type=service --state=failed --no-legend | \
                while read -r service rest; do
                    log_msg DEBUG "  - $service"
                done
        fi
        return 1
    else
        log_msg OK "Services: All running"
        return 0
    fi
}

check_zombie_processes() {
    local zombies=$(ps aux | grep -c " <defunct>")
    
    if (( zombies > ZOMBIE_COUNT_WARN )); then
        log_msg WARN "Zombie Processes: $zombies (WARN - threshold: $ZOMBIE_COUNT_WARN)"
        return 1
    elif (( zombies > 0 )); then
        log_msg INFO "Zombie Processes: $zombies (OK but present)"
        return 0
    else
        log_msg OK "Zombie Processes: None"
        return 0
    fi
}

check_open_files() {
    local open=$(lsof 2>/dev/null | wc -l || echo "0")
    log_msg DEBUG "Open Files: $open"
}

check_network() {
    local connections=$(ss -an 2>/dev/null | wc -l || echo "0")
    log_msg DEBUG "Network Connections: $connections"
}

check_top_processes() {
    if [ "$DETAILED" = true ]; then
        echo ""
        log_msg INFO "Top Processes by CPU:"
        ps aux --sort=-%cpu | head -4 | tail -3 | while read -r line; do
            cpu=$(echo "$line" | awk '{print $3}')
            cmd=$(echo "$line" | awk '{print $11}')
            log_msg DEBUG "  ${cpu}% - $cmd"
        done
        
        echo ""
        log_msg INFO "Top Processes by Memory:"
        ps aux --sort=-%mem | head -4 | tail -3 | while read -r line; do
            mem=$(echo "$line" | awk '{print $4}')
            cmd=$(echo "$line" | awk '{print $11}')
            log_msg DEBUG "  ${mem}% - $cmd"
        done
    fi
}

# ============================================================================
# REPORTING
# ============================================================================

run_checks() {
    local overall_status=0
    
    echo ""
    log_msg INFO "System Health Check"
    echo "==========================================="
    
    check_load_average || overall_status=$?
    check_memory || overall_status=$?
    check_disk || overall_status=$?
    check_swap || overall_status=$?
    check_io_wait || overall_status=$?
    check_services || overall_status=$?
    check_zombie_processes || overall_status=$?
    check_open_files
    check_network
    check_top_processes
    
    echo ""
    
    # Summary
    case $overall_status in
        0)
            log_msg OK "Overall Status: HEALTHY"
            ;;
        1)
            log_msg WARN "Overall Status: WARNINGS PRESENT"
            ;;
        2)
            log_msg CRIT "Overall Status: CRITICAL ISSUES"
            ;;
    esac
    
    echo "==========================================="
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
}

# ============================================================================
# MONITORING MODE
# ============================================================================

monitor_system() {
    while true; do
        clear
        echo "${BLUE}=== System Health Monitor (Ctrl+C to stop) ===${NC}"
        echo "Interval: ${MONITOR_INTERVAL}s | Last update: $(date '+%H:%M:%S')"
        echo ""
        
        run_checks
        
        sleep "$MONITOR_INTERVAL"
    done
}

# ============================================================================
# EXPORT
# ============================================================================

export_results() {
    if [ -z "$EXPORT_FILE" ]; then
        return
    fi
    
    {
        echo "System Health Report"
        echo "Generated: $(date)"
        echo ""
        run_checks
        echo ""
        echo "System Information:"
        echo "Hostname: $(hostname)"
        echo "Uptime: $(uptime)"
        echo "OS: $(lsb_release -ds 2>/dev/null || echo 'Unknown')"
        echo "Kernel: $(uname -r)"
    } >> "$EXPORT_FILE"
    
    log_msg OK "Results exported to: $EXPORT_FILE"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    parse_arguments "$@"
    
    if [ "$MONITOR" = true ]; then
        monitor_system
    else
        run_checks
        export_results
    fi
}

main "$@"
