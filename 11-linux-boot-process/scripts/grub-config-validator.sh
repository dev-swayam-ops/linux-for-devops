#!/bin/bash
################################################################################
# grub-config-validator.sh
# Validates GRUB configuration and checks for common issues
# Provides warnings and suggestions for GRUB setup
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters for report
ERRORS=0
WARNINGS=0
INFO_COUNT=0

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTION]

Validate GRUB2 configuration and check for issues

OPTIONS:
    -f, --full          Full validation (default)
    -c, --config        Check config file only
    -b, --backup        Backup GRUB config before making changes
    -r, --repair        Attempt to fix common issues
    -h, --help          Show this help message

EXAMPLES:
    $0 --full           # Complete validation
    $0 --backup         # Backup current GRUB config
    $0 --config         # Check only config files

EOF
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
    ((WARNINGS++))
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
    ((INFO_COUNT++))
}

check_grub_installed() {
    echo ""
    echo "Checking if GRUB2 is installed..."
    
    if ! command -v grub-install &> /dev/null; then
        print_error "GRUB2 tools not found. Install with:"
        echo "  sudo apt install grub2          # Debian/Ubuntu"
        echo "  sudo yum install grub2          # RHEL/CentOS"
        return 1
    fi
    
    print_ok "GRUB2 tools installed"
    return 0
}

check_grub_config_exists() {
    echo ""
    echo "Checking GRUB configuration files..."
    
    if [[ ! -f /etc/default/grub ]]; then
        print_error "/etc/default/grub not found"
        return 1
    fi
    print_ok "/etc/default/grub exists"
    
    if [[ ! -f /boot/grub/grub.cfg ]]; then
        print_warning "/boot/grub/grub.cfg not found (will be generated on update-grub)"
    else
        print_ok "/boot/grub/grub.cfg exists"
    fi
    
    return 0
}

check_grub_timeout() {
    echo ""
    echo "Checking GRUB boot timeout..."
    
    local timeout=$(grep GRUB_TIMEOUT= /etc/default/grub | cut -d= -f2 | tr -d ' ' || echo "")
    
    if [[ -z "$timeout" ]]; then
        print_warning "GRUB_TIMEOUT not set in /etc/default/grub"
        return
    fi
    
    print_info "GRUB timeout: ${timeout}s"
    
    if [[ "$timeout" -eq 0 ]]; then
        print_warning "Boot menu timeout is 0 (no boot menu). Hard to edit parameters if needed"
    elif [[ "$timeout" -gt 30 ]]; then
        print_warning "Boot menu timeout is ${timeout}s (very long)"
    else
        print_ok "Boot menu timeout: ${timeout}s"
    fi
}

check_grub_default() {
    echo ""
    echo "Checking GRUB default entry..."
    
    local default=$(grep GRUB_DEFAULT= /etc/default/grub | cut -d= -f2 | tr -d ' ' || echo "0")
    
    print_info "Default boot entry: $default"
    
    if [[ ! -f /boot/grub/grub.cfg ]]; then
        print_warning "Cannot verify: /boot/grub/grub.cfg not found"
        return
    fi
    
    local entry_count=$(grep -c "^menuentry" /boot/grub/grub.cfg)
    
    if [[ "$default" != "saved" ]] && [[ "$default" =~ ^[0-9]+$ ]]; then
        if [[ "$default" -ge "$entry_count" ]]; then
            print_error "Default entry $default is out of range (only $entry_count entries exist)"
        else
            print_ok "Default entry is valid"
        fi
    fi
}

check_kernel_parameters() {
    echo ""
    echo "Checking kernel boot parameters..."
    
    if [[ ! -f /etc/default/grub ]]; then
        print_error "/etc/default/grub not found"
        return
    fi
    
    local params=$(grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub | cut -d'"' -f2)
    
    if [[ -z "$params" ]]; then
        print_warning "No default kernel parameters set"
        return
    fi
    
    print_info "Current parameters: $params"
    
    # Check for common parameters
    if echo "$params" | grep -q "quiet"; then
        print_ok "Contains 'quiet' (reduces boot messages)"
    fi
    
    if echo "$params" | grep -q "splash"; then
        print_ok "Contains 'splash' (shows boot splash)"
    fi
    
    if echo "$params" | grep -q "ro"; then
        print_ok "Contains 'ro' (mount root read-only)"
    fi
}

check_grub_boot_partition() {
    echo ""
    echo "Checking GRUB and boot partition..."
    
    local boot_partition=""
    local boot_device=""
    
    # Find /boot partition
    if mount | grep -q "/boot "; then
        boot_partition=$(mount | grep "/boot " | awk '{print $1}')
        print_ok "Boot partition found: $boot_partition"
    else
        print_warning "/boot is not on separate partition (using root filesystem)"
        boot_partition=$(mount | grep "^/ " | awk '{print $1}' || echo "")
    fi
    
    # Check /boot filesystem
    if [[ -n "$boot_partition" ]]; then
        local boot_fs=$(df /boot | tail -1 | awk '{print $6}')
        print_ok "Boot filesystem: $boot_fs"
        
        local boot_usage=$(df /boot | tail -1 | awk '{print $5}')
        print_info "Boot usage: $boot_usage"
        
        if [[ "${boot_usage%\%}" -gt 90 ]]; then
            print_error "Boot partition is ${boot_usage} full - may cause issues during kernel updates"
        elif [[ "${boot_usage%\%}" -gt 80 ]]; then
            print_warning "Boot partition is ${boot_usage} full"
        fi
    fi
    
    # Check if GRUB is installed on boot device
    if command -v grub-probe &> /dev/null; then
        if grub-probe -t device /boot &> /dev/null; then
            boot_device=$(grub-probe -t device /boot)
            print_ok "GRUB boot device: $boot_device"
        fi
    fi
}

check_menu_entries() {
    echo ""
    echo "Checking GRUB menu entries..."
    
    if [[ ! -f /boot/grub/grub.cfg ]]; then
        print_warning "Cannot check: /boot/grub/grub.cfg not found"
        return
    fi
    
    local entry_count=$(grep -c "^menuentry" /boot/grub/grub.cfg)
    print_info "Number of boot entries: $entry_count"
    
    if [[ $entry_count -eq 0 ]]; then
        print_error "No boot entries found in /boot/grub/grub.cfg"
        return
    fi
    
    echo "Boot entries:"
    grep "^menuentry" /boot/grub/grub.cfg | sed "s/menuentry '\(.*\)'.*/  - \1/" | head -10
    
    # Check for missing kernel files
    local missing_kernels=0
    while IFS= read -r line; do
        if echo "$line" | grep -q "linux\|linuxefi"; then
            local kernel=$(echo "$line" | grep -oP '(?<=vmlinuz-)\S+|(?<=vmlinuz\S+)' || echo "")
            if [[ -n "$kernel" ]]; then
                local kernel_file="/boot/vmlinuz-${kernel}"
                if [[ ! -f "$kernel_file" ]]; then
                    ((missing_kernels++))
                fi
            fi
        fi
    done < /boot/grub/grub.cfg
    
    if [[ $missing_kernels -gt 0 ]]; then
        print_error "Found $missing_kernels entries with missing kernel files"
        echo "  Run: sudo update-grub"
    fi
}

check_firmware_type() {
    echo ""
    echo "Checking firmware type..."
    
    if [[ -d /sys/firmware/efi ]]; then
        print_ok "UEFI firmware detected"
        
        if [[ -d /boot/efi ]]; then
            print_ok "EFI System Partition mounted at /boot/efi"
        else
            print_warning "EFI System Partition not mounted"
        fi
    else
        print_info "BIOS/Legacy firmware detected"
    fi
}

check_grub_password() {
    echo ""
    echo "Checking GRUB password configuration..."
    
    if grep -q "^[^#]*password" /etc/default/grub; then
        print_ok "GRUB password protection is enabled"
    else
        print_info "GRUB password protection is not enabled"
        echo "  To add password: sudo grub-mkpasswd-pbkdf2"
        echo "  Then edit /etc/default/grub and add password_pbkdf2 line"
    fi
}

check_recovery_mode() {
    echo ""
    echo "Checking recovery mode..."
    
    if grep -q "GRUB_DISABLE_RECOVERY=true" /etc/default/grub; then
        print_warning "Recovery mode is disabled in GRUB"
    else
        print_ok "Recovery mode is available"
    fi
}

check_grub_modules() {
    echo ""
    echo "Checking essential GRUB modules..."
    
    local modules_dir="/boot/grub/x86_64-pc"
    
    if [[ ! -d "$modules_dir" ]]; then
        modules_dir="/boot/grub2/x86_64-efi"
    fi
    
    if [[ -d "$modules_dir" ]]; then
        print_ok "GRUB modules directory exists: $modules_dir"
        
        # Check for critical modules
        local critical_modules=("normal.mod" "linux.mod" "ext2.mod")
        
        for module in "${critical_modules[@]}"; do
            if [[ -f "$modules_dir/$module" ]]; then
                print_ok "Found $module"
            else
                print_warning "Missing $module"
            fi
        done
    else
        print_warning "Cannot find GRUB modules directory"
    fi
}

backup_grub_config() {
    echo ""
    echo "Backing up GRUB configuration..."
    
    local backup_dir="/root/.grub-backup-$(date +%Y%m%d-%H%M%S)"
    
    if ! mkdir -p "$backup_dir" 2>/dev/null; then
        print_error "Cannot create backup directory (need root)"
        return 1
    fi
    
    cp /etc/default/grub "$backup_dir/" 2>/dev/null
    cp -r /boot/grub "$backup_dir/" 2>/dev/null || true
    
    print_ok "GRUB config backed up to: $backup_dir"
    echo "  To restore: sudo cp -r $backup_dir/* /"
}

repair_grub() {
    echo ""
    echo "Attempting to repair GRUB configuration..."
    
    # Regenerate GRUB config
    if command -v update-grub &> /dev/null; then
        if sudo update-grub &> /dev/null; then
            print_ok "GRUB configuration regenerated"
        else
            print_error "Failed to regenerate GRUB configuration"
            return 1
        fi
    fi
    
    # Reinstall GRUB bootloader
    local boot_device=$(df /boot | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')
    
    echo "Boot device: $boot_device"
    
    if command -v grub-install &> /dev/null; then
        if sudo grub-install "$boot_device" &> /dev/null; then
            print_ok "GRUB bootloader reinstalled on $boot_device"
        else
            print_error "Failed to reinstall GRUB bootloader"
            return 1
        fi
    fi
}

print_summary() {
    echo ""
    print_header "Validation Summary"
    
    echo -e "${RED}Errors: $ERRORS${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo -e "${BLUE}Informational: $INFO_COUNT${NC}"
    
    if [[ $ERRORS -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}✓ GRUB configuration looks good!${NC}"
    else
        echo ""
        echo -e "${RED}✗ Please fix the errors above${NC}"
        return 1
    fi
}

full_validation() {
    print_header "GRUB Configuration Validator"
    
    check_grub_installed || return 1
    check_grub_config_exists || return 1
    check_firmware_type
    check_grub_timeout
    check_grub_default
    check_kernel_parameters
    check_grub_boot_partition
    check_menu_entries
    check_grub_password
    check_recovery_mode
    check_grub_modules
    
    print_summary
}

config_only_validation() {
    print_header "GRUB Configuration File Check"
    
    check_grub_config_exists || return 1
    check_grub_timeout
    check_grub_default
    check_kernel_parameters
    check_menu_entries
    
    print_summary
}

################################################################################
# Main Script
################################################################################

main() {
    local mode="full"
    
    # Check if running as root for some operations
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}⚠ Some operations require root. Some checks will be skipped.${NC}"
        echo "  Run with: sudo $0"
        echo ""
    fi
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--full)
                mode="full"
                shift
                ;;
            -c|--config)
                mode="config"
                shift
                ;;
            -b|--backup)
                mode="backup"
                shift
                ;;
            -r|--repair)
                mode="repair"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Execute selected mode
    case "$mode" in
        full)
            full_validation
            ;;
        config)
            config_only_validation
            ;;
        backup)
            backup_grub_config
            ;;
        repair)
            backup_grub_config
            repair_grub
            ;;
    esac
}

# Run main function
main "$@"
