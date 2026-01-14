#!/bin/bash

################################################################################
# permission-auditor.sh
# 
# Purpose: Audit filesystem permissions and identify security issues
# 
# Usage: 
#   ./permission-auditor.sh audit [<path>] [--recursive]
#   ./permission-auditor.sh audit-world-writable [<path>]
#   ./permission-auditor.sh audit-setuid [<path>]
#   ./permission-auditor.sh audit-setgid [<path>]
#   ./permission-auditor.sh fix-world-writable [<path>]
#   ./permission-auditor.sh fix-permissions [<path>] [<mode>]
#   ./permission-auditor.sh report [<path>]
#   ./permission-auditor.sh compare <file1> <file2>
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_VERSION="1.0"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="${LOG_FILE:-/var/log/permission-auditor.log}"
REPORT_FILE="${REPORT_FILE:-/tmp/permission-audit-report-$(date +%Y%m%d-%H%M%S).txt}"
DEFAULT_AUDIT_PATH="/"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Counters for reporting
WORLD_WRITABLE_COUNT=0
SETUID_COUNT=0
SETGID_COUNT=0
ISSUES_FOUND=0
FIXED_COUNT=0

################################################################################
# Utility Functions
################################################################################

# Print error message
error() {
    printf "${RED}✗ ERROR${NC}: %s\n" "$@" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE"
}

# Print success message
success() {
    printf "${GREEN}✓ SUCCESS${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*" >> "$LOG_FILE"
}

# Print info message
info() {
    printf "${BLUE}ℹ INFO${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" >> "$LOG_FILE"
}

# Print warning message
warning() {
    printf "${YELLOW}⚠ WARNING${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*" >> "$LOG_FILE"
}

# Print risk message
risk() {
    printf "${ORANGE}⚡ RISK${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] RISK: $*" >> "$LOG_FILE"
}

# Check if running as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Print usage help
print_help() {
    cat << 'EOF'
Permission Auditor - Find and fix filesystem permission issues

USAGE:
  permission-auditor audit [<path>] [--recursive]
  permission-auditor audit-world-writable [<path>]
  permission-auditor audit-setuid [<path>]
  permission-auditor audit-setgid [<path>]
  permission-auditor fix-world-writable [<path>] [--dry-run]
  permission-auditor fix-permissions <path> <mode>
  permission-auditor report [<path>]
  permission-auditor help
  permission-auditor version

COMMANDS:
  audit                   Full permission audit
  audit-world-writable    Find world-writable files
  audit-setuid            Find setuid files
  audit-setgid            Find setgid files
  fix-world-writable      Remove world-writable permissions
  fix-permissions         Change permissions on path
  report                  Generate audit report
  help                    Show this help text
  version                 Show version

OPTIONS:
  --recursive             Recurse into directories
  --dry-run              Show what would be changed without changing
  --limit <n>            Limit results to n items
  --exclude <pattern>    Exclude paths matching pattern

EXAMPLES:
  # Audit entire filesystem
  permission-auditor audit / --recursive

  # Find world-writable files in /tmp
  permission-auditor audit-world-writable /tmp

  # Fix world-writable files
  permission-auditor fix-world-writable / --recursive --dry-run

  # Generate report
  permission-auditor report /home

  # Fix specific path
  permission-auditor fix-permissions /tmp 1777
EOF
}

################################################################################
# Audit Functions
################################################################################

# Find world-writable files
audit_world_writable() {
    local path="${1:-.}"
    local recursive="${2:-false}"
    
    info "Searching for world-writable files in: $path"
    
    local find_cmd="find $path -type f -perm -002 2>/dev/null"
    [[ "$recursive" != "true" ]] && find_cmd="find $path -maxdepth 1 -type f -perm -002 2>/dev/null"
    
    local count=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            risk "World-writable file: $file"
            ls -la "$file"
            ((count++))
            ((WORLD_WRITABLE_COUNT++))
            ((ISSUES_FOUND++))
        fi
    done < <(eval "$find_cmd" || true)
    
    info "Found $count world-writable files"
}

# Find world-writable directories
audit_world_writable_dirs() {
    local path="${1:-.}"
    local recursive="${2:-false}"
    
    info "Searching for world-writable directories in: $path"
    
    local find_cmd="find $path -type d -perm -002 2>/dev/null"
    [[ "$recursive" != "true" ]] && find_cmd="find $path -maxdepth 1 -type d -perm -002 2>/dev/null"
    
    local count=0
    while IFS= read -r dir; do
        if [[ -d "$dir" ]]; then
            risk "World-writable directory: $dir"
            ls -ld "$dir"
            ((count++))
            ((ISSUES_FOUND++))
        fi
    done < <(eval "$find_cmd" || true)
    
    info "Found $count world-writable directories"
}

# Find setuid files
audit_setuid() {
    local path="${1:-.}"
    
    info "Searching for setuid files in: $path"
    
    local count=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            warning "Setuid file: $file"
            ls -la "$file"
            ((count++))
            ((SETUID_COUNT++))
        fi
    done < <(find "$path" -type f -perm -4000 2>/dev/null || true)
    
    info "Found $count setuid files"
}

# Find setgid files
audit_setgid() {
    local path="${1:-.}"
    
    info "Searching for setgid files in: $path"
    
    local count=0
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            warning "Setgid file: $file"
            ls -la "$file"
            ((count++))
            ((SETGID_COUNT++))
        fi
    done < <(find "$path" -type f -perm -2000 2>/dev/null || true)
    
    info "Found $count setgid files"
}

# Full audit
full_audit() {
    local path="${1:-.}"
    local recursive="${2:-false}"
    
    info "Starting full permission audit"
    info "Path: $path"
    info "Recursive: $recursive"
    
    # Reset counters
    WORLD_WRITABLE_COUNT=0
    SETUID_COUNT=0
    SETGID_COUNT=0
    ISSUES_FOUND=0
    
    audit_world_writable "$path" "$recursive"
    audit_world_writable_dirs "$path" "$recursive"
    audit_setuid "$path"
    audit_setgid "$path"
    
    echo ""
    echo "=== AUDIT SUMMARY ==="
    echo "Total issues found: $ISSUES_FOUND"
    echo "World-writable files: $WORLD_WRITABLE_COUNT"
    echo "Setuid files: $SETUID_COUNT"
    echo "Setgid files: $SETGID_COUNT"
}

################################################################################
# Fix Functions
################################################################################

# Fix world-writable permissions
fix_world_writable() {
    local path="${1:-.}"
    local dry_run="${2:-false}"
    local recursive="${3:-false}"
    
    info "Fixing world-writable permissions in: $path"
    [[ "$dry_run" == "true" ]] && info "DRY RUN - No changes will be made"
    
    local fixed=0
    local find_cmd="find $path -type f -perm -002 2>/dev/null"
    [[ "$recursive" != "true" ]] && find_cmd="find $path -maxdepth 1 -type f -perm -002 2>/dev/null"
    
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            # Remove world-writable bit
            if [[ "$dry_run" == "true" ]]; then
                info "Would fix: $file"
                ls -la "$file"
            else
                if chmod o-w "$file"; then
                    success "Fixed: $file"
                    ((fixed++))
                    ((FIXED_COUNT++))
                else
                    error "Failed to fix: $file"
                fi
            fi
        fi
    done < <(eval "$find_cmd" || true)
    
    # Also fix directories
    find_cmd="find $path -type d -perm -002 2>/dev/null"
    [[ "$recursive" != "true" ]] && find_cmd="find $path -maxdepth 1 -type d -perm -002 2>/dev/null"
    
    while IFS= read -r dir; do
        if [[ -d "$dir" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                info "Would fix: $dir"
                ls -ld "$dir"
            else
                if chmod o-w "$dir"; then
                    success "Fixed: $dir"
                    ((fixed++))
                    ((FIXED_COUNT++))
                else
                    error "Failed to fix: $dir"
                fi
            fi
        fi
    done < <(eval "$find_cmd" || true)
    
    info "Fixed $fixed items"
}

# Fix permissions on specific path
fix_permissions() {
    local path="$1"
    local mode="$2"
    local dry_run="${3:-false}"
    local recursive="${4:-false}"
    
    if [[ ! -e "$path" ]]; then
        error "Path does not exist: $path"
        return 1
    fi
    
    if [[ ! "$mode" =~ ^[0-7]{3,4}$ ]]; then
        error "Invalid permission mode: $mode"
        return 1
    fi
    
    info "Changing permissions on: $path"
    info "New mode: $mode"
    [[ "$dry_run" == "true" ]] && info "DRY RUN - No changes will be made"
    
    local chmod_cmd="chmod"
    [[ "$recursive" == "true" ]] && chmod_cmd="$chmod_cmd -R"
    
    if [[ "$dry_run" == "true" ]]; then
        info "Would execute: $chmod_cmd $mode $path"
        ls -la "$path"
    else
        if $chmod_cmd "$mode" "$path"; then
            success "Permissions changed: $path -> $mode"
            ls -la "$path"
            return 0
        else
            error "Failed to change permissions"
            return 1
        fi
    fi
}

################################################################################
# Report Functions
################################################################################

# Generate audit report
generate_report() {
    local path="${1:-.}"
    
    info "Generating audit report..."
    info "Report will be saved to: $REPORT_FILE"
    
    {
        echo "=================================="
        echo "Permission Audit Report"
        echo "=================================="
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Path: $path"
        echo "Hostname: $(hostname)"
        echo "User: $(whoami)"
        echo ""
        
        echo "=== WORLD-WRITABLE FILES ==="
        find "$path" -type f -perm -002 2>/dev/null | while read -r file; do
            ls -la "$file"
        done
        
        echo ""
        echo "=== WORLD-WRITABLE DIRECTORIES ==="
        find "$path" -type d -perm -002 2>/dev/null | while read -r dir; do
            ls -ld "$dir"
        done
        
        echo ""
        echo "=== SETUID FILES ==="
        find "$path" -type f -perm -4000 2>/dev/null | while read -r file; do
            ls -la "$file"
        done
        
        echo ""
        echo "=== SETGID FILES ==="
        find "$path" -type f -perm -2000 2>/dev/null | while read -r file; do
            ls -la "$file"
        done
        
        echo ""
        echo "=== SUSPICIOUS PERMISSIONS ==="
        find "$path" -type f -perm 777 2>/dev/null | while read -r file; do
            echo "777 (fully open): $file"
            ls -la "$file"
        done
        
    } | tee "$REPORT_FILE"
    
    success "Report saved to: $REPORT_FILE"
}

# Compare permissions between two files/directories
compare_permissions() {
    local file1="$1"
    local file2="$2"
    
    if [[ ! -e "$file1" ]]; then
        error "First path does not exist: $file1"
        return 1
    fi
    
    if [[ ! -e "$file2" ]]; then
        error "Second path does not exist: $file2"
        return 1
    fi
    
    info "Comparing permissions:"
    echo ""
    echo "File 1: $file1"
    ls -la "$file1"
    echo ""
    echo "File 2: $file2"
    ls -la "$file2"
    echo ""
    
    local perm1
    local perm2
    perm1=$(stat -c "%a" "$file1")
    perm2=$(stat -c "%a" "$file2")
    
    if [[ "$perm1" == "$perm2" ]]; then
        success "Permissions are identical: $perm1"
    else
        warning "Permissions differ!"
        echo "File 1: $perm1"
        echo "File 2: $perm2"
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    require_root

    local command="${1:-help}"

    case "$command" in
        audit)
            shift
            local audit_path="${1:-.}"
            local recursive="false"
            
            while [[ $# -gt 1 ]]; do
                shift
                case "$1" in
                    --recursive)
                        recursive="true"
                        ;;
                    *)
                        error "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            full_audit "$audit_path" "$recursive"
            ;;
        audit-world-writable)
            shift
            local path="${1:-.}"
            audit_world_writable "$path" "true"
            audit_world_writable_dirs "$path" "true"
            ;;
        audit-setuid)
            shift
            local path="${1:-.}"
            audit_setuid "$path"
            ;;
        audit-setgid)
            shift
            local path="${1:-.}"
            audit_setgid "$path"
            ;;
        fix-world-writable)
            shift
            local path="${1:-.}"
            local dry_run="false"
            local recursive="true"
            
            while [[ $# -gt 1 ]]; do
                shift
                case "$1" in
                    --dry-run)
                        dry_run="true"
                        ;;
                    --recursive)
                        recursive="true"
                        ;;
                    *)
                        error "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            fix_world_writable "$path" "$dry_run" "$recursive"
            ;;
        fix-permissions)
            shift
            if [[ $# -lt 2 ]]; then
                error "Path and mode required"
                exit 1
            fi
            
            local path="$1"
            local mode="$2"
            local dry_run="false"
            local recursive="false"
            
            shift 2
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --dry-run)
                        dry_run="true"
                        shift
                        ;;
                    --recursive)
                        recursive="true"
                        shift
                        ;;
                    *)
                        error "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            fix_permissions "$path" "$mode" "$dry_run" "$recursive"
            ;;
        report)
            shift
            local path="${1:-.}"
            generate_report "$path"
            ;;
        compare)
            shift
            if [[ $# -lt 2 ]]; then
                error "Two file paths required"
                exit 1
            fi
            compare_permissions "$1" "$2"
            ;;
        version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            ;;
        help|--help|-h)
            print_help
            ;;
        *)
            error "Unknown command: $command"
            print_help
            exit 1
            ;;
    esac
}

main "$@"
