#!/bin/bash

################################################################################
# config-validator.sh
#
# Purpose: Validate system configuration files for syntax and security issues
#
# Usage:
#   ./config-validator.sh check-syntax [<file>] [--service <name>]
#   ./config-validator.sh security-scan [<path>] [--strict]
#   ./config-validator.sh compare <file1> <file2>
#   ./config-validator.sh find-errors [<path>] [--fix]
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_VERSION="1.0"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="/var/log/config-validator.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
PASSES=0

################################################################################
# Utility Functions
################################################################################

# Print error message
error() {
    printf "${RED}✗ ERROR${NC}: %s\n" "$@" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE" 2>/dev/null || true
    ((ERRORS++))
}

# Print warning message
warning() {
    printf "${YELLOW}⚠ WARNING${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*" >> "$LOG_FILE" 2>/dev/null || true
    ((WARNINGS++))
}

# Print success message
success() {
    printf "${GREEN}✓ PASS${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PASS: $*" >> "$LOG_FILE" 2>/dev/null || true
    ((PASSES++))
}

# Print info message
info() {
    printf "${BLUE}ℹ INFO${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" >> "$LOG_FILE" 2>/dev/null || true
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
Config Validator - Check configuration files for errors and security issues

USAGE:
  config-validator check-syntax [<file>] [--service <name>]
  config-validator security-scan [<path>] [--strict]
  config-validator compare <file1> <file2>
  config-validator find-errors [<path>] [--fix]
  config-validator help
  config-validator version

COMMANDS:
  check-syntax       Validate configuration file syntax
  security-scan      Scan for security issues
  compare           Compare two configuration files
  find-errors       Find and optionally fix common errors
  help              Show this help text
  version           Show version

CHECK-SYNTAX OPTIONS:
  --service <name>   Validate specific service config (ssh, nginx, etc.)

SECURITY-SCAN OPTIONS:
  --strict           Enable strict security checks
  --path <path>      Scan specific directory

FIND-ERRORS OPTIONS:
  --fix              Attempt to fix found errors
  --dry-run         Show what would be fixed without fixing

EXAMPLES:
  # Check SSH configuration
  config-validator check-syntax --service ssh

  # Scan /etc for security issues
  config-validator security-scan /etc --strict

  # Compare two files
  config-validator compare /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

  # Find and fix errors
  config-validator find-errors /etc --fix
EOF
}

################################################################################
# Syntax Validation Functions
################################################################################

# Check syntax for specific services
check_syntax() {
    local file="${1:-.}"
    local service="$2"

    info "Checking configuration syntax"

    case "$service" in
        ssh)
            if [[ -f "$file" ]] || [[ "$file" == "ssh" ]]; then
                info "Validating SSH configuration"
                if sudo sshd -t -f "${file}" 2>&1; then
                    success "SSH configuration syntax valid"
                else
                    error "SSH configuration has syntax errors"
                    return 1
                fi
            fi
            ;;
        nginx)
            if command -v nginx &>/dev/null; then
                info "Validating Nginx configuration"
                if sudo nginx -t 2>&1; then
                    success "Nginx configuration syntax valid"
                else
                    error "Nginx configuration has syntax errors"
                    return 1
                fi
            else
                warning "Nginx not installed"
            fi
            ;;
        apache|apache2)
            if command -v apache2ctl &>/dev/null; then
                info "Validating Apache configuration"
                if sudo apache2ctl configtest 2>&1; then
                    success "Apache configuration syntax valid"
                else
                    error "Apache configuration has syntax errors"
                    return 1
                fi
            else
                warning "Apache not installed"
            fi
            ;;
        *)
            # Generic file checks
            if [[ -f "$file" ]]; then
                info "Performing generic checks on: $file"
                check_generic_syntax "$file"
            else
                error "File not found: $file"
                return 1
            fi
            ;;
    esac
}

# Generic syntax checks
check_generic_syntax() {
    local file="$1"

    # Check if file exists
    [[ ! -f "$file" ]] && error "File not found: $file" && return 1

    # Check file permissions (should not be world-writable)
    local perms=$(stat -c %a "$file")
    if [[ "${perms: -1}" -ge 2 ]]; then
        warning "File is world-writable: $file (permissions: $perms)"
    fi

    # Check for common issues
    if [[ "$file" == *.json ]]; then
        info "Validating JSON format"
        if python3 -m json.tool "$file" > /dev/null 2>&1; then
            success "JSON syntax valid"
        else
            error "JSON syntax invalid"
            return 1
        fi
    fi

    if [[ "$file" == *.yaml ]] || [[ "$file" == *.yml ]]; then
        info "Validating YAML format"
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            success "YAML syntax valid"
        else
            error "YAML syntax invalid"
            return 1
        fi
    fi

    # Check for common mistakes
    if grep -q $'\t' "$file"; then
        warning "File contains tabs (may cause parsing issues)"
    fi

    if grep -q "^[[:space:]]*$" "$file"; then
        info "File contains blank lines"
    fi

    success "Generic syntax checks passed"
}

################################################################################
# Security Scanning Functions
################################################################################

# Scan for security issues
security_scan() {
    local path="${1:-/etc}"
    local strict=false

    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --strict)
                strict=true
                ;;
            *)
                ;;
        esac
        shift || true
    done

    info "Scanning for security issues in: $path"

    # Check 1: World-writable config files
    info "Checking for world-writable configuration files"
    local world_writable
    world_writable=$(find "$path" -type f -perm -002 2>/dev/null | wc -l)
    if [[ $world_writable -gt 0 ]]; then
        error "Found $world_writable world-writable config files"
        find "$path" -type f -perm -002 2>/dev/null | while read -r file; do
            echo "  - $file"
        done
    else
        success "No world-writable configuration files"
    fi

    # Check 2: Readable shadow/password files
    info "Checking password file permissions"
    if [[ -r /etc/shadow ]]; then
        error "Shadow file is readable by non-root (security issue)"
    else
        success "Shadow file permissions correct"
    fi

    if [[ -r /etc/gshadow ]]; then
        error "Group shadow file is readable by non-root (security issue)"
    else
        success "Group shadow file permissions correct"
    fi

    # Check 3: Empty or commented-only config files
    info "Checking for empty configuration files"
    find "$path" -type f -name "*.conf" 2>/dev/null | while read -r file; do
        if ! grep -v "^#" "$file" | grep -v "^$" | grep -q .; then
            warning "Empty or comment-only config: $file"
        fi
    done

    # Check 4: SSH hardening recommendations
    if [[ -f "$path/ssh/sshd_config" ]]; then
        info "Checking SSH security hardening"
        
        # Check password authentication
        if grep -q "^PasswordAuthentication yes" "$path/ssh/sshd_config"; then
            warning "SSH: Password authentication is enabled (consider disabling)"
        else
            success "SSH: Password authentication is disabled"
        fi
        
        # Check root login
        if grep -q "^PermitRootLogin yes" "$path/ssh/sshd_config"; then
            warning "SSH: Root login is permitted (consider disabling)"
        else
            success "SSH: Root login is disabled"
        fi
        
        # Check protocol version
        if grep -q "^Protocol 1" "$path/ssh/sshd_config"; then
            error "SSH: Using insecure Protocol 1 (use Protocol 2)"
        else
            success "SSH: Using secure Protocol 2"
        fi
    fi

    # Check 5: Setuid/Setgid files (if strict)
    if [[ "$strict" == "true" ]]; then
        info "Checking for setuid/setgid files"
        local setuid_count
        setuid_count=$(find "$path" -type f -perm -4000 2>/dev/null | wc -l)
        if [[ $setuid_count -gt 0 ]]; then
            warning "Found $setuid_count setuid files"
        else
            success "No setuid files found"
        fi
    fi

    # Summary
    echo ""
    echo "=== SECURITY SCAN SUMMARY ==="
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    echo "Passes: $PASSES"
}

################################################################################
# Comparison Functions
################################################################################

# Compare two configuration files
compare_configs() {
    local file1="$1"
    local file2="$2"

    [[ ! -f "$file1" ]] && error "File not found: $file1" && return 1
    [[ ! -f "$file2" ]] && error "File not found: $file2" && return 1

    info "Comparing configurations"
    echo "File 1: $file1"
    echo "File 2: $file2"
    echo ""

    # Show differences
    if diff -q "$file1" "$file2" > /dev/null; then
        success "Files are identical"
    else
        warning "Files differ - showing differences:"
        echo ""
        diff -u "$file1" "$file2" || true
        echo ""
        
        # Count differences
        local diff_count
        diff_count=$(diff "$file1" "$file2" | wc -l)
        echo "Total lines that differ: $diff_count"
    fi
}

################################################################################
# Error Finding Functions
################################################################################

# Find and optionally fix common errors
find_errors() {
    local path="${1:-/etc}"
    local fix=false
    local dry_run=false

    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix)
                require_root
                fix=true
                ;;
            --dry-run)
                dry_run=true
                ;;
            *)
                ;;
        esac
        shift || true
    done

    info "Scanning for common configuration errors in: $path"

    # Error 1: Typos in common directives
    info "Checking for common directive typos"
    find "$path" -type f \( -name "*.conf" -o -name "*_config" \) 2>/dev/null | while read -r file; do
        # Check for common SSH typos
        if grep -q "ListnAddress" "$file" 2>/dev/null; then
            error "Found typo 'ListnAddress' in: $file (should be 'ListenAddress')"
            
            if [[ "$fix" == "true" ]] && [[ "$dry_run" != "true" ]]; then
                info "Fixing typo in: $file"
                sudo sed -i.bak 's/ListnAddress/ListenAddress/g' "$file"
                success "Fixed: $file"
            fi
        fi
        
        # Check for HostKye typo
        if grep -q "HostKye" "$file" 2>/dev/null; then
            error "Found typo 'HostKye' in: $file (should be 'HostKey')"
            
            if [[ "$fix" == "true" ]] && [[ "$dry_run" != "true" ]]; then
                info "Fixing typo in: $file"
                sudo sed -i.bak 's/HostKye/HostKey/g' "$file"
                success "Fixed: $file"
            fi
        fi
    done

    # Error 2: World-writable files
    info "Checking for world-writable config files"
    find "$path" -type f -perm -002 2>/dev/null | while read -r file; do
        error "World-writable config file: $file"
        
        if [[ "$fix" == "true" ]] && [[ "$dry_run" != "true" ]]; then
            sudo chmod o-w "$file"
            success "Fixed permissions: $file"
        fi
    done

    # Error 3: Missing critical directives
    if [[ -f "$path/ssh/sshd_config" ]]; then
        if ! grep -q "^Port" "$path/ssh/sshd_config"; then
            warning "SSH: No Port directive found (using default 22)"
        fi
    fi

    # Summary
    echo ""
    echo "=== ERROR SCAN SUMMARY ==="
    echo "Errors found: $ERRORS"
    echo "Warnings: $WARNINGS"
    if [[ "$fix" == "true" ]]; then
        echo "Note: Some errors may require manual fixes"
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    local command="${1:-help}"

    case "$command" in
        check-syntax)
            shift || true
            # Parse for service name
            if [[ "$1" == "--service" ]]; then
                shift
                check_syntax "$2" "$1"
            else
                check_syntax "$@"
            fi
            ;;
        security-scan)
            shift || true
            security_scan "$@"
            ;;
        compare)
            shift || true
            [[ $# -lt 2 ]] && error "Two files required for comparison"
            compare_configs "$1" "$2"
            ;;
        find-errors)
            shift || true
            find_errors "$@"
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
