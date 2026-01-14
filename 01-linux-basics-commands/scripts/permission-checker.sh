#!/bin/bash

################################################################################
# permission-checker.sh - Audit and Report File Permissions
################################################################################
#
# PURPOSE:
#   Scan a directory tree and identify unusual or potentially insecure
#   file permissions. Generate security report with color-coded warnings.
#
# USAGE:
#   ./permission-checker.sh              # Check current directory
#   ./permission-checker.sh /path/to/dir # Check specific directory
#   ./permission-checker.sh -h           # Show help
#
# EXAMPLES:
#   ./permission-checker.sh ~            # Check home directory
#   ./permission-checker.sh ~/public_html # Check web files
#   ./permission-checker.sh -r /var      # Check recursively (verbose)
#

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color

TARGET_DIR="."
RECURSIVE=0
WARNINGS_ONLY=0
SHOW_FIXES=0

# Permission thresholds (octal)
readonly WORLD_WRITABLE="002"     # Others can write
readonly WORLD_EXECUTABLE="001"   # Others can execute
readonly WORLD_READABLE="004"     # Others can read
readonly GROUP_WRITABLE="020"     # Group can write
readonly SETUID_BIT="4000"        # Set-user-ID bit
readonly SETGID_BIT="2000"        # Set-group-ID bit
readonly STICKY_BIT="1000"        # Sticky bit

################################################################################
# VARIABLES FOR TRACKING
################################################################################

declare -i TOTAL_FILES=0
declare -i TOTAL_DIRS=0
declare -i ISSUES_FOUND=0

declare -a WORLD_WRITABLE_FILES
declare -a WORLD_EXECUTABLE_FILES
declare -a WORLD_READABLE_FILES
declare -a SETUID_FILES
declare -a SETGID_FILES
declare -a STICKY_BIT_FILES

################################################################################
# FUNCTIONS
################################################################################

show_help() {
    cat << EOF
${BLUE}${SCRIPT_NAME}${NC} - Audit File Permissions

${GREEN}USAGE:${NC}
    ${SCRIPT_NAME} [OPTIONS] [DIRECTORY]

${GREEN}OPTIONS:${NC}
    -d, --dir DIRECTORY    Target directory (default: current)
    -r, --recursive        Include subdirectories
    -w, --warnings         Show only warnings, not info
    -f, --fix-suggest      Show fix suggestions
    -h, --help             Show this help
    --version              Show version

${GREEN}EXAMPLES:${NC}
    # Check current directory
    ${SCRIPT_NAME}

    # Check home directory recursively
    ${SCRIPT_NAME} -r ~

    # Check with fix suggestions
    ${SCRIPT_NAME} -f ~/scripts

    # Only show warnings
    ${SCRIPT_NAME} -w /var

${GREEN}SECURITY ISSUES DETECTED:${NC}
    • World-writable files (any user can modify)
    • World-executable files (any user can run)
    • World-readable sensitive files (any user can read)
    • SETUID binaries (run with owner privileges)
    • SETGID binaries (run with group privileges)
    • Sticky bits (subdirectory ownership)
    • Overly permissive permissions (777, 666, etc)

${GREEN}EXAMPLES OF FIXES:${NC}
    chmod 644 file.txt              # Readable by all, writable by owner
    chmod 755 script.sh             # Executable by all, writable by owner
    chmod 600 private.key           # Readable/writable by owner only
    chmod 700 secret_dir            # Owner only access

EOF
}

show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

get_octal_permissions() {
    local file="$1"
    stat -c %a "$file" 2>/dev/null || echo "000"
}

decimal_to_binary() {
    local decimal=$1
    echo "obase=2; $decimal" | bc
}

check_world_writable() {
    local perms=$1
    local last_digit=$((perms % 10))
    [ $((last_digit & 2)) -ne 0 ] && return 0 || return 1
}

check_world_readable() {
    local perms=$1
    local last_digit=$((perms % 10))
    [ $((last_digit & 4)) -ne 0 ] && return 0 || return 1
}

check_world_executable() {
    local perms=$1
    local last_digit=$((perms % 10))
    [ $((last_digit & 1)) -ne 0 ] && return 0 || return 1
}

check_setuid() {
    local perms=$1
    [ $((perms / 1000)) -eq 4 ] && return 0 || return 1
}

check_setgid() {
    local perms=$1
    [ $((perms / 1000)) -eq 2 ] && return 0 || return 1
}

check_sticky() {
    local perms=$1
    [ $((perms / 1000)) -eq 1 ] && return 0 || return 1
}

report_issue() {
    local severity=$1
    local file=$2
    local message=$3
    local suggestion=$4
    
    ((ISSUES_FOUND++))
    
    case "$severity" in
        "CRITICAL")
            echo -e "${RED}[!]${NC} CRITICAL: $file"
            echo -e "    $message"
            if [ -n "$suggestion" ]; then
                echo -e "    ${YELLOW}Fix:${NC} $suggestion"
            fi
            ;;
        "WARNING")
            echo -e "${YELLOW}[!]${NC} WARNING: $file"
            echo -e "    $message"
            if [ -n "$suggestion" ]; then
                echo -e "    ${YELLOW}Fix:${NC} $suggestion"
            fi
            ;;
        "INFO")
            if [ "$WARNINGS_ONLY" -eq 0 ]; then
                echo -e "${BLUE}[i]${NC} INFO: $file"
                echo -e "    $message"
            fi
            ;;
    esac
}

check_file_permissions() {
    local file="$1"
    local perms=$(get_octal_permissions "$file")
    
    # Skip symbolic links
    [ -L "$file" ] && return
    
    local is_file=0
    local is_dir=0
    local is_executable=0
    
    if [ -f "$file" ]; then
        ((TOTAL_FILES++))
        is_file=1
        [ -x "$file" ] && is_executable=1
    elif [ -d "$file" ]; then
        ((TOTAL_DIRS++))
        is_dir=1
    fi
    
    # Check world-writable
    if check_world_writable "$perms"; then
        report_issue "CRITICAL" "$file" \
            "World-writable ($perms) - Any user can modify" \
            "chmod o-w $file"
    fi
    
    # Check SETUID (dangerous if combined with world-executable)
    if check_setuid "$perms"; then
        if check_world_executable "$perms"; then
            report_issue "CRITICAL" "$file" \
                "SETUID + world-executable ($perms) - High security risk" \
                "chmod o-x $file  # or chmod u-s $file"
        else
            report_issue "WARNING" "$file" \
                "SETUID bit set ($perms) - Check if necessary" \
                ""
        fi
    fi
    
    # Check SETGID
    if check_setgid "$perms"; then
        report_issue "WARNING" "$file" \
            "SETGID bit set ($perms)" \
            ""
    fi
    
    # Check world-executable for regular files (usually not needed)
    if [ "$is_file" -eq 1 ] && [ "$is_executable" -eq 1 ] && check_world_executable "$perms"; then
        report_issue "WARNING" "$file" \
            "World-executable file ($perms) - Anyone can run" \
            "chmod o-x $file"
    fi
    
    # Check for 777 permissions
    if [ "$perms" = "777" ]; then
        report_issue "CRITICAL" "$file" \
            "Full permissions ($perms) - Everyone can read/write/execute" \
            "chmod 755 $file  # for directories or executables"
    fi
    
    # Check for 666 permissions (world-readable and writable)
    if [ "$perms" = "666" ]; then
        report_issue "CRITICAL" "$file" \
            "World-readable and writable ($perms)" \
            "chmod 644 $file"
    fi
    
    # Check sensitive files that shouldn't be world-readable
    if [ "$is_file" -eq 1 ] && check_world_readable "$perms"; then
        case "$file" in
            *.key|*/.ssh/*|*password*|*.pem|*secret*|*credential*)
                report_issue "CRITICAL" "$file" \
                    "Sensitive file is world-readable ($perms)" \
                    "chmod 600 $file"
                ;;
        esac
    fi
}

scan_directory() {
    local dir="$1"
    local find_depth="-maxdepth 1"
    
    if [ "$RECURSIVE" -eq 1 ]; then
        find_depth=""  # No depth limit
    fi
    
    if [ ! -d "$dir" ]; then
        echo -e "${RED}Error: Directory not found: $dir${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Scanning: $dir${NC}"
    if [ "$RECURSIVE" -eq 1 ]; then
        echo -e "${BLUE}Mode: RECURSIVE${NC}"
    fi
    echo ""
    
    # Scan all files and directories
    while IFS= read -r -d '' item; do
        check_file_permissions "$item"
    done < <(find "$dir" $find_depth -type f -o -type d -o -type l 2>/dev/null | grep -v "^\.$" | sort -z | tr '\n' '\0')
    
    # Print summary
    echo ""
    echo -e "${BLUE}Scan Summary:${NC}"
    echo -e "  Total files: ${GREEN}$TOTAL_FILES${NC}"
    echo -e "  Total directories: ${GREEN}$TOTAL_DIRS${NC}"
    
    if [ "$ISSUES_FOUND" -gt 0 ]; then
        echo -e "  Issues found: ${RED}$ISSUES_FOUND${NC}"
        return 1
    else
        echo -e "  Issues found: ${GREEN}0${NC}"
        return 0
    fi
}

################################################################################
# MAIN SCRIPT
################################################################################

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        -r|--recursive)
            RECURSIVE=1
            shift
            ;;
        -w|--warnings)
            WARNINGS_ONLY=1
            shift
            ;;
        -f|--fix-suggest)
            SHOW_FIXES=1
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
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Run the scan
scan_directory "$TARGET_DIR"
exit $?
