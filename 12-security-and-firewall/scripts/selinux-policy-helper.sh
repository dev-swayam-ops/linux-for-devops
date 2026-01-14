#!/bin/bash
################################################################################
# selinux-policy-helper.sh
# Helper tool for managing SELinux policies and troubleshooting denials
# Use on RHEL/CentOS systems with SELinux enabled
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

SELinux policy management and troubleshooting tool for RHEL/CentOS

COMMANDS:
    status              Show current SELinux status and mode
    mode ENFORCING|PERMISSIVE|DISABLED
                        Change SELinux mode (requires reboot for Disabled)
    contexts FILE       Show SELinux contexts for file/directory
    chcon TYPE FILE     Change SELinux type of file
    analyze             Analyze recent SELinux denials
    allow-denial FILE   Create allow policy from denial
    relabel-file FILE   Relabel single file
    relabel-home        Relabel /home directory
    relabel-all         Relabel entire filesystem (slow!)
    audit2allow         Generate policy from audit logs
    policy-info TYPE    Show information about specific policy
    troubleshoot APP    Troubleshoot common APP issues
    help                Show this help message

EXAMPLES:
    $0 status                      # Show SELinux status
    $0 mode enforcing              # Enable SELinux enforcement
    $0 contexts /var/www           # Show contexts for /var/www
    $0 chcon httpd_sys_content_t /var/www/html
    $0 analyze                     # Show recent denials
    $0 troubleshoot httpd          # Help with Apache issues

NOTES:
    - Requires root privileges
    - Only works on systems with SELinux enabled
    - Some operations require careful consideration

EOF
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script requires root privileges"
        echo "Run with: sudo $0 $@"
        exit 1
    fi
}

check_selinux() {
    if ! command -v getenforce &> /dev/null; then
        print_error "SELinux tools not found"
        echo "Install with: sudo yum install policycoreutils-python-utils"
        exit 1
    fi
}

show_status() {
    print_header "SELinux Status"
    
    if command -v sestatus &> /dev/null; then
        sestatus
    else
        echo "Current mode: $(getenforce)"
        echo "Compiled policy version: $(cat /sys/fs/selinux/policyvers 2>/dev/null || echo 'unknown')"
    fi
    
    # Show current process context
    echo ""
    echo "Current process context:"
    ps -eZ | head -1
    ps -eZ | grep $$ | tail -1
}

change_mode() {
    local new_mode="$1"
    
    # Validate input
    case "$new_mode" in
        enforcing|permissive|disabled)
            ;;
        *)
            print_error "Invalid mode: $new_mode"
            echo "Valid modes: enforcing, permissive, disabled"
            return 1
            ;;
    esac
    
    local current=$(getenforce | tr '[:upper:]' '[:lower:]')
    
    if [[ "$current" == "$new_mode" ]]; then
        print_ok "Already in $new_mode mode"
        return 0
    fi
    
    print_warning "Changing SELinux mode from $current to $new_mode"
    
    if [[ "$new_mode" == "disabled" ]]; then
        print_warning "Changing to DISABLED requires a reboot"
        echo "After disabling, you must relabel the filesystem to re-enable:"
        echo "  1. Change mode to disabled: setenforce 0"
        echo "  2. Add '.autorelabel' file: touch /.autorelabel"
        echo "  3. Reboot: reboot"
    fi
    
    read -p "Proceed with mode change? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        return
    fi
    
    setenforce "$new_mode" 2>&1 || {
        print_error "Failed to change SELinux mode"
        return 1
    }
    
    print_ok "SELinux mode changed to: $(getenforce)"
}

show_contexts() {
    local path="$1"
    
    if [[ ! -e "$path" ]]; then
        print_error "Path not found: $path"
        return 1
    fi
    
    print_header "SELinux Contexts: $path"
    
    if [[ -d "$path" ]]; then
        # Directory - show contents
        echo "Directory contents:"
        ls -ldZ "$path"
        echo ""
        echo "Sample files (first 10):"
        ls -Z "$path" | head -10
    else
        # Single file
        ls -lZ "$path"
    fi
    
    # Show processes accessing this file
    echo ""
    echo "Running processes with access:"
    ps -eZ | head -1
    ps -eZ | grep -i "$(basename "$path")" || echo "  (none matching)"
}

change_context() {
    local type="$1"
    local file="$2"
    
    if [[ ! -e "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    local current=$(ls -Z "$file" | awk '{print $1}' | cut -d: -f3)
    
    print_warning "Changing SELinux type of $file"
    echo "Current type: $current"
    echo "New type: $type"
    
    read -p "Proceed? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        return
    fi
    
    chcon -t "$type" "$file" 2>&1 || {
        print_error "Failed to change context"
        return 1
    }
    
    print_ok "Context changed to: $type"
    ls -Z "$file"
}

analyze_denials() {
    print_header "Recent SELinux Denials"
    
    if ! command -v ausearch &> /dev/null; then
        print_error "auditd not installed"
        echo "Install with: sudo yum install audit"
        return 1
    fi
    
    # Get denials from last hour
    echo "Denials from the last hour:"
    ausearch -m avc -ts recent 2>/dev/null | grep "denied" | tail -5
    
    # Count unique denials
    echo ""
    echo "Top denied processes:"
    ausearch -m avc -ts recent 2>/dev/null | grep "scontext=" | cut -d' ' -f6 | sort | uniq -c | sort -rn | head -5
    
    echo ""
    echo "Denial summary:"
    ausearch -m avc -ts recent 2>/dev/null | wc -l
    echo "total denials in last hour"
}

allow_denial() {
    local audit_file="$1"
    
    if [[ ! -f "$audit_file" ]]; then
        # Try to use recent denials
        audit_file=$(mktemp)
        ausearch -m avc -ts recent 2>/dev/null > "$audit_file" || {
            print_error "No audit denials found"
            rm -f "$audit_file"
            return 1
        }
    fi
    
    print_header "Generating Allow Policy"
    
    if ! command -v audit2allow &> /dev/null; then
        print_error "audit2allow not found"
        echo "Install with: sudo yum install policycoreutils-python-utils"
        return 1
    fi
    
    echo "Generated policy:"
    audit2allow -a -f "$audit_file" 2>/dev/null | head -20
    
    read -p "Apply this policy? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        [[ -f "$audit_file" ]] && rm -f "$audit_file"
        return
    fi
    
    audit2allow -a -f "$audit_file" -M custom_policy 2>/dev/null
    semodule -i custom_policy.pp
    
    print_ok "Policy module 'custom_policy' installed and loaded"
}

relabel_file() {
    local file="$1"
    
    if [[ ! -e "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    print_warning "Relabeling: $file"
    
    echo "Current context: $(ls -Z "$file" | awk '{print $1}')"
    
    # Use restorecon to restore default context
    restorecon -v "$file" 2>&1 || {
        print_error "Relabel failed"
        return 1
    }
    
    echo "New context: $(ls -Z "$file" | awk '{print $1}')"
    print_ok "File relabeled successfully"
}

relabel_home() {
    print_warning "Relabeling /home directory"
    echo "This may take several minutes..."
    
    read -p "Proceed? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        return
    fi
    
    restorecon -r -v /home 2>&1 | tail -20
    
    print_ok "/home directory relabeled"
}

relabel_all() {
    print_warning "This will relabel the ENTIRE filesystem"
    echo "This will take a LONG time and requires a reboot"
    echo ""
    echo "Process:"
    echo "  1. Create .autorelabel file"
    echo "  2. Reboot system"
    echo "  3. Relabeling happens during boot"
    echo ""
    
    read -p "Proceed with reboot? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        return
    fi
    
    touch /.autorelabel
    print_ok "Created /.autorelabel - reboot to start relabeling"
    
    read -p "Reboot now? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        shutdown -r now
    fi
}

show_policy_info() {
    local type="$1"
    
    if ! command -v semanage &> /dev/null; then
        print_error "semanage not found"
        echo "Install with: sudo yum install policycoreutils-python-utils"
        return 1
    fi
    
    print_header "Policy Information: $type"
    
    # Try to find policy information
    semanage fcontext -l | grep -i "$type" | head -10 || echo "No file contexts found"
}

troubleshoot_app() {
    local app="$1"
    
    case "$app" in
        httpd|apache)
            print_header "Apache/HTTPD Troubleshooting"
            
            echo "Checking Apache contexts..."
            ps -eZ | grep httpd || print_warning "Apache not running"
            
            echo ""
            echo "Web root contexts:"
            ls -dZ /var/www
            ls -Z /var/www/html | head -5
            
            echo ""
            echo "If Apache cannot access files:"
            echo "  - File type should be: httpd_sys_content_t"
            echo "  - Directory should be: httpd_sys_content_ra_t"
            echo "  - Fix with: sudo chcon -R -t httpd_sys_content_t /var/www/html"
            
            echo ""
            echo "Common Apache booleans:"
            getsebool -a | grep httpd | head -10
            ;;
            
        mysql|mariadb)
            print_header "MySQL/MariaDB Troubleshooting"
            
            echo "Checking database contexts..."
            ps -eZ | grep -E "mysql|mariadb" || print_warning "Database not running"
            
            echo ""
            echo "Database directory:"
            ls -dZ /var/lib/mysql
            
            echo ""
            echo "Common database booleans:"
            getsebool -a | grep mysql | head -5
            ;;
            
        ssh|sshd)
            print_header "SSH Troubleshooting"
            
            echo "Checking SSH daemon context:"
            ps -eZ | grep sshd || print_warning "SSHD not running"
            
            echo ""
            echo "SSH config context:"
            ls -Z /etc/ssh/sshd_config
            
            echo ""
            echo "If SSH keys have wrong context:"
            echo "  - Run: restorecon -R -v ~/.ssh"
            echo "  - Check with: ls -Z ~/.ssh"
            ;;
            
        nfs)
            print_header "NFS Troubleshooting"
            
            echo "NFS service context:"
            ps -eZ | grep nfs || print_warning "NFS not running"
            
            echo ""
            echo "NFS directories:"
            ls -dZ /srv/nfs* 2>/dev/null || print_warning "No NFS mounts found"
            
            echo ""
            echo "Check NFS booleans:"
            getsebool -a | grep nfs
            ;;
            
        *)
            print_error "Unknown application: $app"
            echo "Supported: httpd, apache, mysql, mariadb, ssh, sshd, nfs"
            return 1
            ;;
    esac
}

################################################################################
# Main Script
################################################################################

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 0
    fi
    
    local command="$1"
    shift
    
    check_root
    check_selinux
    
    case "$command" in
        status)
            show_status
            ;;
        mode)
            [[ $# -lt 1 ]] && { print_error "Missing mode"; usage; exit 1; }
            change_mode "$1"
            ;;
        contexts)
            [[ $# -lt 1 ]] && { print_error "Missing path"; usage; exit 1; }
            show_contexts "$1"
            ;;
        chcon)
            [[ $# -lt 2 ]] && { print_error "Missing type or file"; usage; exit 1; }
            change_context "$1" "$2"
            ;;
        analyze)
            analyze_denials
            ;;
        allow-denial)
            allow_denial "${1:-}"
            ;;
        relabel-file)
            [[ $# -lt 1 ]] && { print_error "Missing file"; usage; exit 1; }
            relabel_file "$1"
            ;;
        relabel-home)
            relabel_home
            ;;
        relabel-all)
            relabel_all
            ;;
        audit2allow)
            allow_denial
            ;;
        policy-info)
            [[ $# -lt 1 ]] && { print_error "Missing type"; usage; exit 1; }
            show_policy_info "$1"
            ;;
        troubleshoot)
            [[ $# -lt 1 ]] && { print_error "Missing app"; usage; exit 1; }
            troubleshoot_app "$1"
            ;;
        help)
            usage
            ;;
        *)
            print_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
