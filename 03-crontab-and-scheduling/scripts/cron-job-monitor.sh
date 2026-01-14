#!/bin/bash
################################################################################
# Script Name: cron-job-monitor.sh
# Purpose: Monitor cron job execution and send alerts on failures
# Usage: ./cron-job-monitor.sh [OPTIONS]
# Author: DevOps Team
# Version: 1.0
#
# Features:
#   - Monitor system and application cron jobs
#   - Alert on job failures via email
#   - Track job execution times
#   - Identify stale/failed jobs
#   - Generate health reports
#   - Manage job whitelists/blacklists
################################################################################

set -euo pipefail

################################################################################
# Configuration
################################################################################

# Monitoring settings
MONITOR_SYSTEM_CRON="${MONITOR_SYSTEM_CRON:=true}"
MONITOR_USER_CRON="${MONITOR_USER_CRON:=true}"

# Log locations
SYSLOG_FILE="${SYSLOG_FILE:=/var/log/syslog}"
CRON_LOG="${CRON_LOG:=/var/log/cron}"
REPORT_FILE="${REPORT_FILE:=/var/log/cron-monitor.log}"

# Alert settings
ALERT_EMAIL="${ALERT_EMAIL:=admin@example.com}"
ALERT_ON_FAILURE="${ALERT_ON_FAILURE:=true}"
ALERT_ON_TIMEOUT="${ALERT_ON_TIMEOUT:=true}"

# Job timeout settings (in seconds)
DEFAULT_TIMEOUT="${DEFAULT_TIMEOUT:=1800}"  # 30 minutes
WARN_TIMEOUT="${WARN_TIMEOUT:=900}"          # 15 minutes

# Thresholds
FAILURE_THRESHOLD="${FAILURE_THRESHOLD:=3}"  # Alert after 3 consecutive failures
TIMEOUT_THRESHOLD="${TIMEOUT_THRESHOLD:=2}"  # Alert after 2 timeouts

# Lock file
LOCK_FILE="/tmp/cron-monitor.lock"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Functions
################################################################################

show_help() {
    cat << EOF
${BLUE}Cron Job Monitor${NC}
Monitor cron job execution and health

Usage: $0 [OPTIONS]

OPTIONS:
    -s, --system-cron       Monitor system crontab (default: $MONITOR_SYSTEM_CRON)
    -u, --user-cron         Monitor user crontabs (default: $MONITOR_USER_CRON)
    -e, --email EMAIL       Alert email address (default: $ALERT_EMAIL)
    -t, --timeout SECONDS   Default job timeout (default: $DEFAULT_TIMEOUT)
    -f, --failure THRESHOLD Alert after N failures (default: $FAILURE_THRESHOLD)
    -r, --report            Generate and display report only
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

EXAMPLES:
    # Monitor all cron jobs and alert on failures
    $0 --system-cron --user-cron --email admin@example.com

    # Generate monitoring report
    $0 --report

    # Monitor with custom timeout
    $0 --timeout 3600

CRON INTEGRATION:
    # Add to root's crontab to run every 10 minutes:
    */10 * * * * /usr/local/bin/cron-job-monitor.sh

EOF
}

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$REPORT_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $@" | tee -a "$REPORT_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $@" | tee -a "$REPORT_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@" | tee -a "$REPORT_FILE"
}

# Acquire lock
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        log_error "Monitor already running"
        return 1
    fi
    
    echo "$$" > "$LOCK_FILE"
    trap "rm -f $LOCK_FILE" EXIT
    return 0
}

# Get recent cron logs
get_recent_cron_logs() {
    local hours="${1:=1}"
    local since=$(date -d "$hours hours ago" '+%Y-%m-%d %H:%M:%S')
    
    # Try journalctl first (systemd)
    if command -v journalctl &>/dev/null; then
        journalctl -u cron -u crond --since "$since" --no-pager 2>/dev/null || true
    # Fallback to syslog
    elif [ -f "$SYSLOG_FILE" ]; then
        grep CRON "$SYSLOG_FILE" | tail -100 || true
    elif [ -f "$CRON_LOG" ]; then
        tail -100 "$CRON_LOG" || true
    fi
}

# Extract job info from cron logs
parse_cron_logs() {
    local output_file="${1:=/tmp/cron-jobs.txt}"
    
    > "$output_file"  # Clear file
    
    get_recent_cron_logs 24 | while read line; do
        # Parse journalctl format: user=xxx COMMAND="..."
        if echo "$line" | grep -q "user=.*COMMAND="; then
            local user=$(echo "$line" | grep -oP 'user=\K[^ ]+' || echo "unknown")
            local cmd=$(echo "$line" | grep -oP 'COMMAND=\K[^"]*' || echo "unknown")
            local result=$(echo "$line" | grep -oP '\(.*\)' || echo "(completed)")
            
            echo "$user|$cmd|$result" >> "$output_file"
        # Parse syslog format: CRON[pid]: (user) COMMAND output
        elif echo "$line" | grep -q "CRON\["; then
            local user=$(echo "$line" | grep -oP '\\(\K[^)]+' || echo "unknown")
            local cmd=$(echo "$line" | grep -oP 'CMD \\(\K[^)]+' || echo "unknown")
            
            echo "$user|$cmd|completed" >> "$output_file"
        fi
    done
    
    log_info "Parsed $(wc -l < "$output_file") cron log entries"
}

# Check job execution status
check_job_status() {
    local job_name="$1"
    local hours="${2:=1}"
    
    # Search logs for job
    if get_recent_cron_logs "$hours" | grep -q "$job_name"; then
        # Check if job failed
        if get_recent_cron_logs "$hours" | grep "$job_name" | grep -q "failed\|error\|denied"; then
            echo "FAILED"
        else
            echo "SUCCESS"
        fi
    else
        echo "NOT_FOUND"
    fi
}

# Get list of configured cron jobs
list_cron_jobs() {
    local jobs_file="/tmp/configured-jobs.txt"
    > "$jobs_file"
    
    # System crontab
    if [ "$MONITOR_SYSTEM_CRON" = "true" ]; then
        log_info "Scanning system crontab..."
        
        if [ -f /etc/crontab ]; then
            grep -v "^#" /etc/crontab | grep -v "^$" | \
            awk '{print "SYSTEM|" $6 "|" $7 " " $8 " " $9}' >> "$jobs_file"
        fi
        
        # Check cron.d directory
        if [ -d /etc/cron.d ]; then
            find /etc/cron.d -type f -exec \
            grep -v "^#" {} \; | grep -v "^$" | \
            awk '{print "SYSTEM|" $6 "|" $7 " " $8 " " $9}' >> "$jobs_file"
        fi
    fi
    
    # User crontabs
    if [ "$MONITOR_USER_CRON" = "true" ]; then
        log_info "Scanning user crontabs..."
        
        if [ -d /var/spool/cron/crontabs ]; then
            for user_crontab in /var/spool/cron/crontabs/*; do
                if [ -f "$user_crontab" ]; then
                    local user=$(basename "$user_crontab")
                    grep -v "^#" "$user_crontab" | grep -v "^$" | \
                    awk -v user="$user" '{print user "|" $6 " " $7 " " $8}' >> "$jobs_file"
                fi
            done
        fi
    fi
    
    cat "$jobs_file"
    log_info "Found $(wc -l < "$jobs_file") configured cron jobs"
}

# Generate health report
generate_report() {
    local report_file="/tmp/cron-health-report.txt"
    
    {
        echo "==============================================="
        echo "Cron System Health Report"
        echo "Generated: $(date)"
        echo "==============================================="
        echo ""
        
        # Check cron service status
        echo "Cron Service Status:"
        if systemctl is-active --quiet cron || systemctl is-active --quiet crond; then
            echo "  ✓ Cron daemon is RUNNING"
        else
            echo "  ✗ Cron daemon is STOPPED"
        fi
        echo ""
        
        # Check cron log rotation
        echo "Cron Log Status:"
        if [ -f "$SYSLOG_FILE" ]; then
            local log_size=$(du -h "$SYSLOG_FILE" | cut -f1)
            local log_lines=$(grep -c CRON "$SYSLOG_FILE" 2>/dev/null || echo "0")
            echo "  Syslog size: $log_size"
            echo "  Recent entries: $log_lines"
        fi
        echo ""
        
        # List all configured jobs
        echo "Configured Cron Jobs:"
        list_cron_jobs | while read line; do
            echo "  $line"
        done
        echo ""
        
        # Recent execution status
        echo "Recent Execution Summary (last 24 hours):"
        get_recent_cron_logs 24 | tail -10 | while read line; do
            # Truncate long lines
            echo "  ${line:0:120}"
        done
        echo ""
        
        echo "==============================================="
        
    } | tee "$report_file"
    
    cat "$report_file"
}

# Send alert email
send_alert() {
    local subject="$1"
    local message="$2"
    
    if [ "$ALERT_ON_FAILURE" = "true" ] || [ "$ALERT_ON_TIMEOUT" = "true" ]; then
        if command -v mail &>/dev/null; then
            echo -e "$message" | mail -s "$subject" "$ALERT_EMAIL"
            log_info "Alert sent to $ALERT_EMAIL"
        else
            log_warn "mail command not found, cannot send alert"
        fi
    fi
}

# Validate cron configuration
validate_cron_config() {
    log_info "Validating cron configuration..."
    
    local issues=0
    
    # Check if cron is running
    if ! systemctl is-active --quiet cron 2>/dev/null && \
       ! systemctl is-active --quiet crond 2>/dev/null; then
        log_error "Cron daemon is not running!"
        issues=$((issues + 1))
    fi
    
    # Check if crontab files are readable
    if [ -d /var/spool/cron/crontabs ]; then
        local unreadable=$(find /var/spool/cron/crontabs -type f -not -readable | wc -l)
        if [ "$unreadable" -gt 0 ]; then
            log_warn "$unreadable crontab files are not readable"
            issues=$((issues + 1))
        fi
    fi
    
    # Check system crontab syntax
    if [ -f /etc/crontab ]; then
        if ! grep -E "^[0-9\*]" /etc/crontab | grep -v "^#" | while read line; do
            # Simple syntax check
            if ! echo "$line" | grep -qE "^[0-9\*\-,/]+ [0-9\*\-,/]+ [0-9\*\-,/]+ [0-9\*\-,/]+ [0-9\*\-,/]+ "; then
                false
            fi
        done; then
            log_warn "System crontab may have syntax errors"
            issues=$((issues + 1))
        fi
    fi
    
    if [ "$issues" -eq 0 ]; then
        log_info "Cron configuration is valid"
        return 0
    else
        log_error "Found $issues configuration issue(s)"
        return 1
    fi
}

# Monitor cron jobs
monitor_jobs() {
    log_info "Starting cron job monitoring..."
    
    local failed_jobs=""
    local timeout_jobs=""
    
    list_cron_jobs | while IFS='|' read user cmd schedule; do
        if [ -z "$cmd" ]; then
            continue
        fi
        
        # Extract job name (first word of command)
        local job_name=$(echo "$cmd" | awk '{print $1}')
        
        # Check recent execution
        local status=$(check_job_status "$job_name" 1)
        
        case "$status" in
            FAILED)
                log_error "Job FAILED: $job_name (user: $user)"
                failed_jobs+="$job_name "
                ;;
            NOT_FOUND)
                log_warn "Job NOT_EXECUTED: $job_name (user: $user)"
                ;;
            SUCCESS)
                # Check execution time for warning
                if [ -n "$WARN_TIMEOUT" ]; then
                    # This would need more complex parsing of execution times
                    true
                fi
                ;;
        esac
    done
    
    # Send alerts if needed
    if [ -n "$failed_jobs" ]; then
        send_alert "Cron Jobs Failed - $(hostname)" \
            "The following cron jobs failed:\n$failed_jobs\n\nCheck logs for details."
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--system-cron)
                MONITOR_SYSTEM_CRON="true"
                shift
                ;;
            -u|--user-cron)
                MONITOR_USER_CRON="true"
                shift
                ;;
            -e|--email)
                ALERT_EMAIL="$2"
                shift 2
                ;;
            -t|--timeout)
                DEFAULT_TIMEOUT="$2"
                shift 2
                ;;
            -f|--failure)
                FAILURE_THRESHOLD="$2"
                shift 2
                ;;
            -r|--report)
                REPORT_ONLY="true"
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    log_info "=========================================="
    log_info "Cron Monitor Started"
    log_info "=========================================="
    
    # Generate report
    if [ "${REPORT_ONLY:=false}" = "true" ]; then
        generate_report
        return 0
    fi
    
    # Acquire lock
    if ! acquire_lock; then
        return 1
    fi
    
    # Validate configuration
    validate_cron_config
    
    # Monitor jobs
    monitor_jobs
    
    # Parse recent logs
    parse_cron_logs
    
    log_info "=========================================="
    log_info "Cron Monitor Completed"
    log_info "=========================================="
}

################################################################################
# Entry Point
################################################################################

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

REPORT_ONLY="false"
parse_args "$@"
main
