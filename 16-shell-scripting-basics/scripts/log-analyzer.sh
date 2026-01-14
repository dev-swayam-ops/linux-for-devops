#!/bin/bash
# Log Analyzer Script
# Purpose: Parse, analyze, and report on system log files
# Usage: ./log-analyzer.sh [--log FILE] [--pattern PATTERN] [--lines 20] [--stats]
# Features: Pattern matching, statistics, error extraction, performance analysis

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

# Default settings
LOG_FILE="/var/log/syslog"
PATTERN=""
LINES=20
SHOW_STATS=false
SHOW_ERRORS=false
SHOW_WARNINGS=false
SHOW_SUMMARY=true
TAIL_MODE=false

# Temporary files
TEMP_RESULTS="/tmp/log-analyzer-$$.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# LOGGING & OUTPUT
# ============================================================================

log_msg() {
    local level="$1"
    shift
    local msg="$*"
    
    case "$level" in
        ERROR)   echo -e "${RED}[ERROR]${NC} $msg" ;;
        WARN)    echo -e "${YELLOW}[!]${NC} $msg" ;;
        SUCCESS) echo -e "${GREEN}[✓]${NC} $msg" ;;
        INFO)    echo -e "${BLUE}[*]${NC} $msg" ;;
    esac
}

error() {
    log_msg ERROR "$@"
    cleanup
    exit 1
}

# ============================================================================
# HELP
# ============================================================================

show_help() {
    cat << EOF
${BLUE}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
Advanced log file analyzer

${BLUE}USAGE${NC}
    $SCRIPT_NAME [OPTIONS]

${BLUE}OPTIONS${NC}
    --log FILE           Log file to analyze (default: /var/log/syslog)
    --pattern PATTERN    Search for pattern (case-insensitive)
    --lines N            Show N recent matching lines (default: 20)
    --errors             Show error entries only
    --warnings           Show warning entries only
    --stats              Show detailed statistics
    --tail               Show newest entries (tail mode)
    --help               Show this help message

${BLUE}EXAMPLES${NC}
    # Analyze syslog
    $SCRIPT_NAME --log /var/log/syslog

    # Search for errors
    $SCRIPT_NAME --log /var/log/syslog --errors

    # Find specific pattern with stats
    $SCRIPT_NAME --log /var/log/syslog --pattern "ssh" --stats

    # Show tail of specific log
    $SCRIPT_NAME --log /var/log/auth.log --tail --lines 30

    # Custom log analysis
    $SCRIPT_NAME --log /var/log/apache2/access.log --pattern "404" --lines 50

${BLUE}SUPPORTED LOGS${NC}
    • /var/log/syslog          - General system log
    • /var/log/auth.log        - Authentication log
    • /var/log/kern.log        - Kernel messages
    • /var/log/apache2/error.log - Apache errors
    • /var/log/nginx/error.log   - Nginx errors
    • Custom log files

EOF
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --log)
                LOG_FILE="$2"
                shift 2
                ;;
            --pattern)
                PATTERN="$2"
                shift 2
                ;;
            --lines)
                LINES="$2"
                shift 2
                ;;
            --errors)
                SHOW_ERRORS=true
                PATTERN="${PATTERN:-error|failed|failure}"
                shift
                ;;
            --warnings)
                SHOW_WARNINGS=true
                PATTERN="${PATTERN:-warn|warning}"
                shift
                ;;
            --stats)
                SHOW_STATS=true
                shift
                ;;
            --tail)
                TAIL_MODE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# ============================================================================
# VALIDATION
# ============================================================================

validate_log_file() {
    if [[ ! -f "$LOG_FILE" ]]; then
        error "Log file not found: $LOG_FILE"
    fi
    
    if [[ ! -r "$LOG_FILE" ]]; then
        error "Cannot read log file (try with sudo): $LOG_FILE"
    fi
}

validate_lines_count() {
    if ! [[ "$LINES" =~ ^[0-9]+$ ]]; then
        error "Invalid line count: $LINES"
    fi
}

# ============================================================================
# LOG ANALYSIS FUNCTIONS
# ============================================================================

# Get file size and modify time
get_file_info() {
    local size=$(stat -c %s "$LOG_FILE" 2>/dev/null || stat -f %z "$LOG_FILE" 2>/dev/null || echo "0")
    local size_mb=$(( size / 1048576 ))
    local lines=$(wc -l < "$LOG_FILE")
    local modified=$(stat -c %y "$LOG_FILE" 2>/dev/null || stat -f "%Sm -f %s" "$LOG_FILE" 2>/dev/null || echo "Unknown")
    
    echo "File: $LOG_FILE"
    echo "Size: $size_mb MB ($(numfmt --to=iec-i --suffix=B $size 2>/dev/null || echo "$size bytes"))"
    echo "Lines: $lines"
    echo "Modified: $modified"
}

# Extract entries with pattern
extract_pattern() {
    if [[ -z "$PATTERN" ]]; then
        if [[ "$TAIL_MODE" == true ]]; then
            tail -n "$LINES" "$LOG_FILE"
        else
            head -n "$LINES" "$LOG_FILE"
        fi
    else
        if [[ "$TAIL_MODE" == true ]]; then
            grep -i "$PATTERN" "$LOG_FILE" | tail -n "$LINES" || true
        else
            grep -i "$PATTERN" "$LOG_FILE" | head -n "$LINES" || true
        fi
    fi
}

# Count occurrences
count_pattern_occurrences() {
    if [[ -z "$PATTERN" ]]; then
        wc -l < "$LOG_FILE"
    else
        grep -ic "$PATTERN" "$LOG_FILE" || echo "0"
    fi
}

# Extract timestamps (if available)
extract_timestamps() {
    # Try to extract time entries - different formats
    grep -oE "[0-9]{2}:[0-9]{2}:[0-9]{2}" "$LOG_FILE" | head -100 || true
}

# Get top services/processes mentioned
get_top_services() {
    grep -oP '(?<=\[|:|\s)[a-zA-Z0-9_-]+(?::|]|\s)' "$LOG_FILE" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -10 || true
}

# Analyze severity levels (if available)
analyze_severity() {
    local total=$(wc -l < "$LOG_FILE")
    local errors=$(grep -ic "error\|failed\|failure" "$LOG_FILE" || echo "0")
    local warnings=$(grep -ic "warn\|warning" "$LOG_FILE" || echo "0")
    local info=$(grep -ic "info\|information" "$LOG_FILE" || echo "0")
    
    echo ""
    echo "Severity Analysis:"
    echo "  Errors:    $errors"
    echo "  Warnings:  $warnings"
    echo "  Info:      $info"
    echo "  Total:     $total"
}

# Find repeated patterns
find_repeated_messages() {
    echo ""
    echo "Most Repeated Messages:"
    echo "======================"
    
    # Extract message part (after timestamp usually)
    awk '{
        # Skip first few fields (timestamp, hostname, etc)
        $1=$2=$3=""; 
        msg=$0;
        count[msg]++
    }
    END {
        for (msg in count) {
            if (count[msg] > 1) {
                print count[msg], msg
            }
        }
    }' "$LOG_FILE" | sort -rn | head -10 || true
}

# ============================================================================
# REPORTING
# ============================================================================

show_summary() {
    log_msg INFO "Log Analysis Summary"
    echo ""
    get_file_info
    echo ""
    
    local count=$(count_pattern_occurrences)
    if [[ -n "$PATTERN" ]]; then
        log_msg INFO "Matching entries: $count"
    fi
}

show_entries() {
    echo ""
    log_msg INFO "Log Entries"
    echo "=========================================="
    
    local entries=$(extract_pattern)
    
    if [[ -z "$entries" ]]; then
        log_msg WARN "No matching entries found"
        return
    fi
    
    echo "$entries" | head -n "$LINES"
    
    local shown_count=$(echo "$entries" | wc -l)
    if [[ $shown_count -ge $LINES ]]; then
        echo ""
        log_msg WARN "Showing $LINES of $shown_count matching entries (truncated)"
    fi
}

show_statistics() {
    if [[ "$SHOW_STATS" != true ]]; then
        return
    fi
    
    echo ""
    log_msg INFO "Detailed Statistics"
    echo "=========================================="
    
    analyze_severity
    
    echo ""
    echo "Top Services/Processes:"
    echo "======================"
    get_top_services || log_msg WARN "Could not extract services"
    
    find_repeated_messages
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    if [[ -f "$TEMP_RESULTS" ]]; then
        rm -f "$TEMP_RESULTS"
    fi
}

trap cleanup EXIT

# ============================================================================
# MAIN
# ============================================================================

main() {
    parse_arguments "$@"
    validate_log_file
    validate_lines_count
    
    echo ""
    show_summary
    show_entries
    show_statistics
    
    echo ""
    log_msg SUCCESS "Analysis complete"
}

main "$@"
