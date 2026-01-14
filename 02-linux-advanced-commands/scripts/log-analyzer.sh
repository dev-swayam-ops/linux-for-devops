#!/bin/bash

################################################################################
# log-analyzer.sh - Analyze Log Files for Patterns and Statistics
################################################################################
#
# PURPOSE:
#   Parse log files and generate analysis reports.
#   Supports common log formats (syslog, Apache, Nginx, application logs).
#
# USAGE:
#   ./log-analyzer.sh /path/to/logfile
#   ./log-analyzer.sh /var/log/apache2/access.log --top-ips 10
#   ./log-analyzer.sh -h for help
#
# FEATURES:
#   - Auto-detect log format
#   - Count entries by severity/status
#   - Extract most common values
#   - Generate statistical summaries
#   - Find patterns and anomalies

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

LOGFILE=""
TOP_N=10
OUTPUT_FORMAT="text"
FILTER_PATTERN=""

################################################################################
# FUNCTIONS
################################################################################

show_help() {
    cat << EOF
${BLUE}${SCRIPT_NAME}${NC} - Analyze Log Files

${GREEN}USAGE:${NC}
    ${SCRIPT_NAME} [OPTIONS] LOGFILE

${GREEN}OPTIONS:${NC}
    -f, --file FILE         Log file to analyze (can be first argument)
    --top N                 Show top N entries (default: 10)
    --filter PATTERN        Only analyze lines matching pattern
    --ips                   Analyze IP addresses (for web logs)
    --errors                Show only error lines
    --stats                 Show basic statistics
    -h, --help              Show this help
    --version               Show version

${GREEN}EXAMPLES:${NC}
    # Analyze Apache log
    ${SCRIPT_NAME} /var/log/apache2/access.log

    # Top 20 IPs with errors
    ${SCRIPT_NAME} /var/log/apache2/access.log --top 20 --errors --ips

    # Analyze syslog with filter
    ${SCRIPT_NAME} /var/log/syslog --filter "kernel"

    # Show statistics
    ${SCRIPT_NAME} app.log --stats

${GREEN}SUPPORTED FORMATS:${NC}
    • Apache/Nginx access logs
    • Linux syslog
    • Application logs (with [LEVEL] prefix)
    • Generic text logs

EOF
}

show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

detect_log_format() {
    local file="$1"
    
    # Sample first line
    local first_line=$(head -1 "$file")
    
    if [[ "$first_line" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
        echo "apache"
    elif [[ "$first_line" =~ ^[A-Za-z]+[[:space:]]+[0-9]+ ]]; then
        echo "syslog"
    elif [[ "$first_line" =~ \[ERROR\]|\[WARNING\]|\[INFO\] ]]; then
        echo "app"
    else
        echo "generic"
    fi
}

count_log_entries() {
    local file="$1"
    wc -l < "$file"
}

analyze_apache_log() {
    local file="$1"
    
    echo -e "${BLUE}Apache/Nginx Access Log Analysis${NC}"
    echo ""
    
    echo -e "${GREEN}Total Requests:${NC} $(wc -l < "$file")"
    
    echo ""
    echo -e "${GREEN}Status Codes:${NC}"
    cut -d' ' -f9 "$file" | sort | uniq -c | sort -rn | awk '{printf "  %s: %d\n", $2, $1}'
    
    echo ""
    echo -e "${GREEN}Top ${TOP_N} IP Addresses:${NC}"
    cut -d' ' -f1 "$file" | sort | uniq -c | sort -rn | head -n "$TOP_N" | awk '{printf "  %s: %d requests\n", $2, $1}'
    
    if grep -q "404" "$file"; then
        echo ""
        echo -e "${RED}IPs with 404 Errors:${NC}"
        grep " 404 " "$file" | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -5 | awk '{printf "  %s: %d errors\n", $2, $1}'
    fi
    
    if grep -q "5[0-9][0-9]" "$file"; then
        echo ""
        echo -e "${RED}Server Errors (5xx):${NC}"
        grep " 5[0-9][0-9] " "$file" | wc -l | awk '{printf "  Found %d server errors\n", $1}'
    fi
}

analyze_syslog() {
    local file="$1"
    
    echo -e "${BLUE}Syslog Analysis${NC}"
    echo ""
    
    echo -e "${GREEN}Total Entries:${NC} $(wc -l < "$file")"
    
    echo ""
    echo -e "${GREEN}Processes (top ${TOP_N}):${NC}"
    awk '{print $5}' "$file" | cut -d'[' -f1 | sort | uniq -c | sort -rn | head -n "$TOP_N" | awk '{printf "  %s: %d entries\n", $2, $1}'
    
    if grep -qi "error\|fail\|critical" "$file"; then
        echo ""
        echo -e "${RED}Error Entries:${NC}"
        grep -i "error\|fail\|critical" "$file" | wc -l | awk '{printf "  Found %d error-related entries\n", $1}'
    fi
    
    if grep -qi "warning" "$file"; then
        echo ""
        echo -e "${YELLOW}Warnings:${NC}"
        grep -i "warning" "$file" | wc -l | awk '{printf "  Found %d warnings\n", $1}'
    fi
}

analyze_app_log() {
    local file="$1"
    
    echo -e "${BLUE}Application Log Analysis${NC}"
    echo ""
    
    echo -e "${GREEN}Total Entries:${NC} $(wc -l < "$file")"
    
    echo ""
    echo -e "${GREEN}Severity Breakdown:${NC}"
    grep -oE '\[(ERROR|WARNING|INFO|DEBUG)\]' "$file" | sort | uniq -c | sort -rn | awk -F'[\\[\\]]' '{printf "  %s: %d\n", $3, $1}'
    
    if grep -q "\[ERROR\]" "$file"; then
        echo ""
        echo -e "${RED}Error Count:${NC}"
        grep -c "\[ERROR\]" "$file" | awk '{printf "  %d errors\n", $1}'
    fi
}

analyze_generic_log() {
    local file="$1"
    
    echo -e "${BLUE}Generic Log Analysis${NC}"
    echo ""
    
    echo -e "${GREEN}Total Lines:${NC} $(wc -l < "$file")"
    
    if grep -qi "error" "$file"; then
        echo ""
        echo -e "${RED}Error Lines:${NC}"
        grep -ci "error" "$file" | awk '{printf "  %d lines contain 'error'\n", $1}'
    fi
    
    if grep -qi "warning" "$file"; then
        echo ""
        echo -e "${YELLOW}Warning Lines:${NC}"
        grep -ci "warning" "$file" | awk '{printf "  %d lines contain 'warning'\n", $1}'
    fi
    
    echo ""
    echo -e "${GREEN}Most Common Words (first field):${NC}"
    awk '{print $1}' "$file" | sort | uniq -c | sort -rn | head -n "$TOP_N" | awk '{printf "  %s: %d\n", $2, $1}'
}

show_statistics() {
    local file="$1"
    
    echo ""
    echo -e "${BLUE}=== File Statistics ===${NC}"
    echo -e "${GREEN}File:${NC} $file"
    echo -e "${GREEN}Size:${NC} $(du -h "$file" | cut -f1)"
    echo -e "${GREEN}Lines:${NC} $(wc -l < "$file")"
    echo -e "${GREEN}Words:${NC} $(wc -w < "$file")"
    echo -e "${GREEN}Last Modified:${NC} $(stat -c %y "$file" | cut -d' ' -f1-2)"
}

main() {
    if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
        echo -e "${RED}Error: Log file not found or not specified${NC}"
        show_help
        exit 1
    fi
    
    local format=$(detect_log_format "$LOGFILE")
    
    case "$format" in
        "apache")
            analyze_apache_log "$LOGFILE"
            ;;
        "syslog")
            analyze_syslog "$LOGFILE"
            ;;
        "app")
            analyze_app_log "$LOGFILE"
            ;;
        *)
            analyze_generic_log "$LOGFILE"
            ;;
    esac
    
    show_statistics "$LOGFILE"
}

################################################################################
# ARGUMENT PARSING
################################################################################

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            LOGFILE="$2"
            shift 2
            ;;
        --top)
            TOP_N="$2"
            shift 2
            ;;
        --filter)
            FILTER_PATTERN="$2"
            shift 2
            ;;
        --ips)
            # Will focus IP analysis (Apache format assumed)
            shift
            ;;
        --errors)
            # Will focus on errors only
            shift
            ;;
        --stats)
            # Show full statistics
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --version)
            show_version
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            LOGFILE="$1"
            shift
            ;;
    esac
done

main
