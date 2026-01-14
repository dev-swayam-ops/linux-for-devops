#!/bin/bash
################################################################################
# log-analyzer.sh
# Parse, filter, and analyze log files with statistics
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTIONS] LOGFILE

Analyze log files with filtering and statistics

OPTIONS:
    --pattern PATTERN       Search for pattern (grep)
    --level LEVEL           Filter by syslog level (err, warn, info, debug)
    --facility FACILITY     Filter by facility (auth, kern, daemon, etc.)
    --since DATE            Show logs since date (YYYY-MM-DD or "today")
    --before DATE           Show logs before date
    --time-range START END  Show between times (HH:MM:SS HH:MM:SS)
    --top-errors N          Show top N error types
    --count-by FIELD        Count occurrences by field (source, process, etc.)
    --stats                 Show statistical summary
    --extract IP            Extract IP addresses
    --extract USERS         Extract usernames
    --no-duplicates         Remove duplicate lines
    --output FILE           Save results to file
    --help                  Show this help

EXAMPLES:
    # Find all errors
    $0 --level err /var/log/syslog
    
    # Top 10 errors
    $0 --top-errors 10 /var/log/syslog
    
    # Extract IPs from failed logins
    $0 --pattern "Failed" --extract IP /var/log/auth.log
    
    # Count by process
    $0 --count-by process /var/log/syslog
    
    # Analyze between times
    $0 --time-range "10:00:00" "11:00:00" /var/log/syslog

EOF
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1" >&2
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        exit 1
    fi
    
    if [[ ! -r "$file" ]]; then
        print_error "File not readable: $file"
        exit 1
    fi
}

filter_by_level() {
    local file="$1"
    local level="$2"
    
    case "$level" in
        err|error)
            grep -i "error\|failed\|critical\|alert\|emerg" "$file" || true
            ;;
        warn|warning)
            grep -i "warning\|warn" "$file" || true
            ;;
        info)
            grep -i "info\|notice" "$file" || true
            ;;
        debug)
            grep -i "debug\|trace" "$file" || true
            ;;
        *)
            grep -i "$level" "$file" || true
            ;;
    esac
}

filter_by_facility() {
    local file="$1"
    local facility="$2"
    
    case "$facility" in
        auth)
            grep -E "sshd|sudo|auth|login|passwd" "$file" || true
            ;;
        kern|kernel)
            grep -i "kernel" "$file" || true
            ;;
        daemon)
            grep -E "systemd|daemon" "$file" || true
            ;;
        *)
            grep -i "$facility" "$file" || true
            ;;
    esac
}

filter_by_date() {
    local file="$1"
    local since="$2"
    
    if [[ "$since" == "today" ]]; then
        since=$(date +"%b %d")
    fi
    
    grep "$since" "$file" || true
}

filter_by_time_range() {
    local file="$1"
    local start="$2"
    local end="$3"
    
    # Extract time and filter
    awk -v start="$start" -v end="$end" '$3 >= start && $3 <= end' "$file" || true
}

extract_field() {
    local type="$1"
    
    case "$type" in
        ip|IP)
            grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
            ;;
        users|user)
            grep -oE 'user[^ ]*|for [^ ]*|USER=' | grep -o '[^ ]*$'
            ;;
        process)
            awk '{print $5}' | cut -d'[' -f1
            ;;
        *)
            grep -oE "^[^ ]+" 
            ;;
    esac
}

show_top_errors() {
    local file="$1"
    local count="$2"
    
    print_header "Top $count Error Types"
    
    awk -F': ' '{print $NF}' "$file" | \
        sort | uniq -c | sort -rn | head -n "$count" | \
        awk '{print $1 "\t" substr($0, index($0,$2))}'
}

count_by_field() {
    local file="$1"
    local field="$2"
    
    print_header "Count by $field"
    
    case "$field" in
        process)
            awk '{print $5}' "$file" | cut -d'[' -f1 | \
                sort | uniq -c | sort -rn | head -20
            ;;
        source|host)
            awk '{print $4}' "$file" | \
                sort | uniq -c | sort -rn | head -20
            ;;
        hour|time)
            awk '{print $2}' "$file" | cut -d: -f1-2 | \
                sort | uniq -c | sort -rn | head -24
            ;;
        *)
            awk -F: "{print \$$field}" "$file" 2>/dev/null | \
                sort | uniq -c | sort -rn | head -20 || true
            ;;
    esac
}

show_stats() {
    local file="$1"
    
    print_header "Log Statistics"
    
    local total=$(wc -l < "$file")
    local errors=$(grep -c -i "error\|failed\|critical" "$file" || echo 0)
    local warnings=$(grep -c -i "warning\|warn" "$file" || echo 0)
    local infos=$(grep -c -i "info\|notice" "$file" || echo 0)
    
    echo "Total lines: $total"
    echo "Errors: $errors ($(( errors * 100 / (total + 1) ))%)"
    echo "Warnings: $warnings ($(( warnings * 100 / (total + 1) ))%)"
    echo "Info/Notice: $infos ($(( infos * 100 / (total + 1) ))%)"
    
    echo ""
    echo "Most active process:"
    awk '{print $5}' "$file" | cut -d'[' -f1 | \
        sort | uniq -c | sort -rn | head -1
    
    echo ""
    echo "Most common hour:"
    awk '{print $2}' "$file" | cut -d: -f1 | \
        sort | uniq -c | sort -rn | head -1
}

################################################################################
# Main Script
################################################################################

main() {
    local logfile=""
    local pattern=""
    local level=""
    local facility=""
    local since=""
    local before=""
    local time_range_start=""
    local time_range_end=""
    local top_errors=""
    local count_by=""
    local stats=0
    local extract_type=""
    local no_dups=0
    local output_file=""
    local filtered_content=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --pattern)
                pattern="$2"
                shift 2
                ;;
            --level)
                level="$2"
                shift 2
                ;;
            --facility)
                facility="$2"
                shift 2
                ;;
            --since)
                since="$2"
                shift 2
                ;;
            --before)
                before="$2"
                shift 2
                ;;
            --time-range)
                time_range_start="$2"
                time_range_end="$3"
                shift 3
                ;;
            --top-errors)
                top_errors="$2"
                shift 2
                ;;
            --count-by)
                count_by="$2"
                shift 2
                ;;
            --stats)
                stats=1
                shift
                ;;
            --extract)
                extract_type="$2"
                shift 2
                ;;
            --no-duplicates)
                no_dups=1
                shift
                ;;
            --output)
                output_file="$2"
                shift 2
                ;;
            --help)
                usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                logfile="$1"
                shift
                ;;
        esac
    done
    
    # Validate logfile
    if [[ -z "$logfile" ]]; then
        print_error "No logfile specified"
        usage
        exit 1
    fi
    
    check_file "$logfile"
    
    # Start with full file
    filtered_content=$(<"$logfile")
    
    # Apply filters
    if [[ -n "$pattern" ]]; then
        filtered_content=$(echo "$filtered_content" | grep "$pattern" || echo "")
    fi
    
    if [[ -n "$level" ]]; then
        filtered_content=$(echo "$filtered_content" | grep -i "$level" || echo "")
    fi
    
    if [[ -n "$facility" ]]; then
        filtered_content=$(echo "$filtered_content" | grep -i "$facility" || echo "")
    fi
    
    if [[ -n "$since" ]]; then
        if [[ "$since" == "today" ]]; then
            since=$(date +"%b %d")
        fi
        filtered_content=$(echo "$filtered_content" | grep "$since" || echo "")
    fi
    
    if [[ -n "$time_range_start" ]] && [[ -n "$time_range_end" ]]; then
        filtered_content=$(echo "$filtered_content" | \
            awk -v start="$time_range_start" -v end="$time_range_end" \
            '$3 >= start && $3 <= end' || echo "")
    fi
    
    if [[ $no_dups -eq 1 ]]; then
        filtered_content=$(echo "$filtered_content" | sort -u || echo "")
    fi
    
    # Show filtered results
    if [[ -z "$filtered_content" ]]; then
        print_ok "No matching entries found"
    else
        print_header "Filtered Results ($( echo "$filtered_content" | wc -l) lines)"
        echo "$filtered_content"
    fi
    
    # Additional analysis
    if [[ -n "$extract_type" ]]; then
        print_header "Extracted: $extract_type"
        echo "$filtered_content" | extract_field "$extract_type" | sort | uniq -c | sort -rn
    fi
    
    if [[ -n "$top_errors" ]]; then
        show_top_errors "$logfile" "$top_errors"
    fi
    
    if [[ -n "$count_by" ]]; then
        count_by_field "$logfile" "$count_by"
    fi
    
    if [[ $stats -eq 1 ]]; then
        show_stats "$logfile"
    fi
    
    # Save to file if requested
    if [[ -n "$output_file" ]]; then
        echo "$filtered_content" > "$output_file"
        print_ok "Results saved to: $output_file"
    fi
}

main "$@"
