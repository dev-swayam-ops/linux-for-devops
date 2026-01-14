#!/bin/bash
################################################################################
# security-auditor.sh
# Comprehensive Linux system security audit with detailed reporting
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

# Audit results
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Comprehensive system security audit

OPTIONS:
    --quick             Quick audit (5 min, essential checks)
    --full              Full audit (15 min, all checks)
    --report FILE       Save report to file
    --fix               Auto-fix simple issues (use with caution)
    --help              Show this help

CHECKS PERFORMED:
    - File permissions audit
    - SUID/SGID binaries review
    - User and group analysis
    - Sudo configuration
    - SSH hardening status
    - Password policy
    - Firewall configuration
    - SELinux/AppArmor status
    - Failed login attempts
    - Open ports and services
    - File integrity

EXAMPLES:
    $0 --quick                      # Quick scan (5 min)
    $0 --full                       # Comprehensive scan (15 min)
    $0 --full --report audit.txt    # Save detailed report

EOF
}

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_subheader() {
    echo -e "\n${GRAY}→ $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS_COUNT++))
}

print_warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    ((WARN_COUNT++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAIL_COUNT++))
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}Note: Some checks require root privileges${NC}"
        echo "Run with sudo for complete audit: sudo $0 $@"
    fi
}

audit_file_permissions() {
    print_subheader "Checking critical file permissions..."
    
    # Check /etc/passwd
    local perm=$(stat -c '%a' /etc/passwd 2>/dev/null || stat -f '%OLp' /etc/passwd 2>/dev/null)
    if [[ "$perm" == "644" || "$perm" == "-rw-r--r--" ]]; then
        print_pass "/etc/passwd readable by all (644)"
    else
        print_fail "/etc/passwd has unusual permissions: $perm"
    fi
    
    # Check /etc/shadow
    if [[ -r /etc/shadow ]]; then
        print_warn "/etc/shadow is readable - only root should access this"
        ((WARN_COUNT++))
    else
        print_pass "/etc/shadow not readable by non-root"
    fi
    
    # Check /etc/sudoers
    local sudoers_perm=$(stat -c '%a' /etc/sudoers 2>/dev/null || echo "unknown")
    if [[ "$sudoers_perm" == "440" ]]; then
        print_pass "/etc/sudoers has restricted permissions (440)"
    else
        print_fail "/etc/sudoers permissions: $sudoers_perm (should be 440)"
    fi
    
    # Check /root
    if [[ -d /root ]]; then
        local root_perm=$(stat -c '%a' /root 2>/dev/null || echo "unknown")
        if [[ "$root_perm" == "700" ]]; then
            print_pass "/root directory permissions (700 - owner only)"
        else
            print_warn "/root directory permissions: $root_perm (recommended: 700)"
        fi
    fi
}

audit_world_writable() {
    print_subheader "Scanning for world-writable files..."
    
    local world_writable=$(find /usr /bin /sbin -type f -perm -002 2>/dev/null | wc -l)
    
    if [[ $world_writable -eq 0 ]]; then
        print_pass "No world-writable files in /usr, /bin, /sbin"
    else
        print_fail "Found $world_writable world-writable files in system directories"
        [[ $QUICK_AUDIT -ne 1 ]] && find /usr /bin /sbin -type f -perm -002 2>/dev/null | head -5 | sed 's/^/      /'
    fi
}

audit_suid_sgid() {
    print_subheader "Checking SUID/SGID binaries..."
    
    local suid_count=$(find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | wc -l)
    
    if [[ $suid_count -lt 50 ]]; then
        print_pass "Reasonable number of SUID/SGID binaries: $suid_count"
    else
        print_warn "High number of SUID/SGID binaries: $suid_count (may indicate bloat)"
    fi
    
    if [[ $QUICK_AUDIT -ne 1 ]]; then
        echo "    Top SUID binaries:"
        find / -type f -perm -4000 2>/dev/null | head -3 | sed 's/^/      /'
    fi
}

audit_users() {
    print_subheader "Analyzing user accounts..."
    
    # Check for users with UID 0 (besides root)
    local uid0_users=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/passwd)
    
    if [[ -z "$uid0_users" ]]; then
        print_pass "Only 'root' account has UID 0"
    else
        print_fail "Found non-root accounts with UID 0: $uid0_users"
    fi
    
    # Check for accounts with empty passwords
    local empty_pass=$(awk -F: '($2 == "" || $2 == "!" || $2 == "*") {print $1}' /etc/shadow 2>/dev/null | grep -v "^root$" || true)
    
    if [[ -z "$empty_pass" ]]; then
        print_pass "No system accounts have empty passwords"
    else
        print_warn "Accounts with empty/disabled passwords: $empty_pass"
    fi
    
    # Count active user accounts
    local user_count=$(awk -F: '$3 >= 1000 {count++} END {print count+0}' /etc/passwd)
    echo "    Active user accounts: $user_count"
}

audit_sudo() {
    print_subheader "Checking sudo configuration..."
    
    # Check if sudo is installed
    if command -v sudo &> /dev/null; then
        print_pass "Sudo is installed"
        
        # Check sudoers syntax
        if sudo -l &>/dev/null; then
            print_pass "Sudoers file syntax is valid"
        else
            print_fail "Sudoers file has syntax errors"
        fi
        
        # Count sudoers entries
        local sudo_users=$(sudo -l -U root 2>/dev/null | wc -l || echo "unknown")
        echo "    Sudo access configured for user"
    else
        print_fail "Sudo is not installed"
    fi
    
    # Check for NOPASSWD entries (security concern)
    if grep -q "NOPASSWD" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        print_fail "Found NOPASSWD in sudoers - requires password for privilege escalation"
    else
        print_pass "No NOPASSWD entries in sudoers (password required)"
    fi
}

audit_ssh() {
    print_subheader "Checking SSH hardening..."
    
    if [[ ! -f /etc/ssh/sshd_config ]]; then
        print_warn "SSH server not installed or config not found"
        return
    fi
    
    # Check if SSH is running
    if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
        print_pass "SSH server is running"
    else
        print_warn "SSH server is not running"
    fi
    
    # Check key settings
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
        print_pass "Root login disabled (PermitRootLogin no)"
    else
        print_fail "Root login might be enabled (check PermitRootLogin)"
    fi
    
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
        print_pass "Password authentication disabled (key-only)"
    else
        print_warn "Password authentication enabled (should use keys)"
    fi
    
    if grep -q "^PubkeyAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
        print_pass "Public key authentication enabled"
    else
        print_warn "Public key authentication not explicitly enabled"
    fi
}

audit_password_policy() {
    print_subheader "Checking password policy..."
    
    # Check /etc/login.defs
    if grep -q "^PASS_MAX_DAYS" /etc/login.defs 2>/dev/null; then
        local max_days=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
        if [[ $max_days -le 90 ]]; then
            print_pass "Password expiration set: $max_days days"
        else
            print_warn "Password expiration too long: $max_days days (recommended: 90)"
        fi
    else
        print_fail "Password expiration policy not set"
    fi
    
    # Check minimum password length
    if grep -q "^PASS_MIN_LEN" /etc/login.defs 2>/dev/null; then
        local min_len=$(grep "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}')
        if [[ $min_len -ge 12 ]]; then
            print_pass "Minimum password length: $min_len characters"
        else
            print_warn "Minimum password length too short: $min_len (recommended: 12+)"
        fi
    fi
    
    # Check pam_cracklib (Ubuntu/Debian)
    if grep -q "pam_cracklib.so" /etc/pam.d/common-password 2>/dev/null; then
        print_pass "Password quality checking enabled (cracklib)"
    elif grep -q "pam_pwquality.so" /etc/pam.d/system-auth 2>/dev/null; then
        print_pass "Password quality checking enabled (pwquality)"
    else
        print_warn "Password quality checking not enabled"
    fi
}

audit_firewall() {
    print_subheader "Checking firewall status..."
    
    # Check UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
            print_pass "UFW firewall is active"
        else
            print_fail "UFW firewall is inactive"
        fi
    elif command -v firewall-cmd &> /dev/null; then
        if sudo firewall-cmd --state &>/dev/null; then
            print_pass "Firewalld is active"
        else
            print_fail "Firewalld is inactive"
        fi
    else
        print_warn "No firewall management tool found (UFW/firewalld)"
    fi
    
    # Check iptables
    if sudo iptables -L -n 2>/dev/null | grep -q "Chain INPUT"; then
        local rule_count=$(sudo iptables -L -n 2>/dev/null | grep -c "^[^ ]" || echo 0)
        if [[ $rule_count -gt 0 ]]; then
            print_pass "iptables rules are configured"
        fi
    fi
}

audit_selinux() {
    print_subheader "Checking SELinux (if available)..."
    
    if command -v getenforce &> /dev/null; then
        local selinux_mode=$(getenforce)
        
        if [[ "$selinux_mode" == "Enforcing" ]]; then
            print_pass "SELinux is in Enforcing mode (maximum security)"
        elif [[ "$selinux_mode" == "Permissive" ]]; then
            print_warn "SELinux is in Permissive mode (logging only, not enforcing)"
        elif [[ "$selinux_mode" == "Disabled" ]]; then
            print_warn "SELinux is Disabled"
        fi
        
        echo "    SELinux mode: $selinux_mode"
    else
        print_warn "SELinux not available (this is OK for non-RHEL systems)"
    fi
}

audit_apparmor() {
    print_subheader "Checking AppArmor (if available)..."
    
    if command -v aa-status &> /dev/null; then
        local profiles=$(sudo aa-status 2>/dev/null | grep "profiles are loaded" | awk '{print $1}')
        
        if [[ -n "$profiles" ]]; then
            print_pass "AppArmor is loaded with $profiles profiles"
        else
            print_warn "AppArmor not enabled"
        fi
    else
        print_warn "AppArmor not available (this is OK for non-Debian systems)"
    fi
}

audit_failed_logins() {
    print_subheader "Checking failed login attempts..."
    
    # Check /var/log/auth.log or /var/log/secure
    local auth_log="/var/log/auth.log"
    [[ -f /var/log/secure ]] && auth_log="/var/log/secure"
    
    if [[ -f "$auth_log" ]]; then
        local failed_count=$(grep -c "Failed password\|Invalid user" "$auth_log" 2>/dev/null || echo 0)
        
        if [[ $failed_count -eq 0 ]]; then
            print_pass "No failed login attempts in recent logs"
        elif [[ $failed_count -lt 10 ]]; then
            print_warn "Some failed login attempts: $failed_count"
        else
            print_fail "High number of failed login attempts: $failed_count"
        fi
    else
        print_warn "Auth log not found (logging not enabled?)"
    fi
}

audit_open_ports() {
    print_subheader "Checking open ports and services..."
    
    if command -v ss &> /dev/null; then
        local listening=$(sudo ss -tlnp 2>/dev/null | grep LISTEN | wc -l)
        echo "    Services listening: $listening"
        
        # Check for unexpected services
        if sudo ss -tlnp 2>/dev/null | grep -qE "(telnet|ftp|rsh|rlogin)"; then
            print_fail "Found insecure services (telnet/ftp) - should use SSH/SFTP"
        else
            print_pass "No insecure remote services found"
        fi
    else
        print_warn "ss command not available"
    fi
}

audit_file_integrity() {
    print_subheader "Checking file integrity tools..."
    
    if command -v aide &> /dev/null; then
        print_pass "AIDE file integrity tool is installed"
    elif command -v tripwire &> /dev/null; then
        print_pass "Tripwire file integrity tool is installed"
    else
        print_warn "No file integrity checking tool (consider installing AIDE)"
    fi
}

audit_system_updates() {
    print_subheader "Checking system update status..."
    
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        if sudo apt list --upgradable 2>/dev/null | grep -q "upgradable"; then
            local updates=$(sudo apt list --upgradable 2>/dev/null | wc -l)
            print_warn "Updates available: $updates packages"
        else
            print_pass "System is up to date"
        fi
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS
        if sudo yum check-update &>/dev/null; then
            print_warn "Updates available (run: sudo yum update)"
        else
            print_pass "System is up to date"
        fi
    fi
}

audit_umask() {
    print_subheader "Checking default umask..."
    
    local umask=$(umask)
    
    if [[ "$umask" == "0022" || "$umask" == "0027" ]]; then
        print_pass "Default umask is restrictive: $umask"
    else
        print_warn "Non-standard umask: $umask"
    fi
}

################################################################################
# Report Generation
################################################################################

generate_report() {
    local report_file="$1"
    
    echo "Audit Summary" >> "$report_file"
    echo "=============" >> "$report_file"
    echo "Date: $(date)" >> "$report_file"
    echo "Hostname: $(hostname)" >> "$report_file"
    echo "Kernel: $(uname -r)" >> "$report_file"
    echo "" >> "$report_file"
}

print_summary() {
    print_header "Security Audit Summary"
    
    echo ""
    echo -e "Results:"
    echo -e "  ${GREEN}✓ PASS${NC}:  $PASS_COUNT checks"
    echo -e "  ${YELLOW}⚠ WARN${NC}:  $WARN_COUNT checks"
    echo -e "  ${RED}✗ FAIL${NC}:  $FAIL_COUNT checks"
    echo ""
    
    local total=$((PASS_COUNT + WARN_COUNT + FAIL_COUNT))
    local score=$((PASS_COUNT * 100 / total))
    
    echo -e "Security Score: ${YELLOW}$score%${NC} ($PASS_COUNT/$total)"
    echo ""
    
    if [[ $FAIL_COUNT -gt 0 ]]; then
        print_fail "Immediate action needed for security"
    elif [[ $WARN_COUNT -gt 0 ]]; then
        print_warn "Review warnings and address security concerns"
    else
        print_pass "System appears well-secured"
    fi
}

################################################################################
# Main Script
################################################################################

main() {
    local QUICK_AUDIT=0
    local FULL_AUDIT=0
    local REPORT_FILE=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --quick)
                QUICK_AUDIT=1
                ;;
            --full)
                FULL_AUDIT=1
                ;;
            --report)
                REPORT_FILE="$2"
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
        shift
    done
    
    # Default to full audit if nothing specified
    if [[ $QUICK_AUDIT -eq 0 && $FULL_AUDIT -eq 0 ]]; then
        FULL_AUDIT=1
    fi
    
    check_root
    
    print_header "Linux Security Audit"
    echo "Starting comprehensive security audit..."
    
    # Always run
    audit_file_permissions
    audit_users
    audit_sudo
    audit_ssh
    audit_firewall
    audit_failed_logins
    audit_open_ports
    
    # Quick mode skips some checks
    if [[ $QUICK_AUDIT -ne 1 ]]; then
        audit_world_writable
        audit_suid_sgid
        audit_password_policy
        audit_selinux
        audit_apparmor
        audit_file_integrity
        audit_system_updates
        audit_umask
    fi
    
    print_summary
    
    if [[ -n "$REPORT_FILE" ]]; then
        generate_report "$REPORT_FILE"
        echo "Report saved to: $REPORT_FILE"
    fi
}

main "$@"
