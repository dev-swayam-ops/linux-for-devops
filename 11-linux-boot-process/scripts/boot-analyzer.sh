#!/bin/bash
################################################################################
# boot-analyzer.sh
# Comprehensive boot sequence analyzer
# Provides detailed insights into system boot performance and configuration
################################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPORT_FILE="/tmp/boot-analysis-$(date +%Y%m%d-%H%M%S).txt"

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTION]

Analyze Linux boot sequence and performance

OPTIONS:
    -f, --full          Full analysis (default)
    -q, --quick         Quick overview only
    -s, --services      Show slowest services
    -d, --dependencies  Show boot dependencies
    -l, --logs          Show boot logs
    -t, --timeline      Show boot timeline (systemd-analyze plot to file)
    -r, --report FILE   Save report to FILE (default: /tmp/boot-analysis-*.txt)
    -h, --help          Show this help message

EXAMPLES:
    $0 --quick                  # Quick boot summary
    $0 --services               # Find slow services
    $0 --full                   # Complete analysis
    $0 --report /tmp/boot.txt   # Save full report

EOF
}

print_header() {
    local header="$1"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${header}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    local section="$1"
    echo ""
    echo -e "${GREEN}▸ ${section}${NC}"
    echo "─────────────────────────────────────────────────────────────"
}

check_privilege() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}⚠ Warning: Some information requires root privileges${NC}"
        echo "  Run with 'sudo' for complete analysis"
    fi
}

analyze_firmware() {
    print_section "Firmware Information"
    
    if [[ -d /sys/firmware/efi ]]; then
        echo -e "${GREEN}✓${NC} Firmware: UEFI"
        
        # Check SecureBoot status if available
        if [[ -f /sys/firmware/efi/fw_platform_size ]]; then
            echo "  EFI Platform Size: $(cat /sys/firmware/efi/fw_platform_size) bits"
        fi
        
        # Check boot entries
        if command -v efibootmgr &> /dev/null; then
            local boot_count=$(efibootmgr 2>/dev/null | grep -c "^Boot" || true)
            echo "  Boot Entries: $boot_count"
        fi
    else
        echo -e "${YELLOW}✓${NC} Firmware: BIOS/Legacy"
    fi
}

analyze_bootloader() {
    print_section "Bootloader Configuration"
    
    if [[ -f /etc/default/grub ]]; then
        echo "GRUB2 Detected"
        
        local timeout=$(grep GRUB_TIMEOUT= /etc/default/grub | cut -d= -f2)
        echo "  Boot Menu Timeout: ${timeout}s"
        
        local default=$(grep GRUB_DEFAULT= /etc/default/grub | cut -d= -f2)
        echo "  Default Entry: $default"
        
        local kernel_params=$(grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub | cut -d'"' -f2)
        echo "  Default Kernel Parameters: $kernel_params"
        
        # Count boot entries
        if [[ -f /boot/grub/grub.cfg ]]; then
            local entry_count=$(grep -c "^menuentry" /boot/grub/grub.cfg)
            echo "  Available Boot Entries: $entry_count"
        fi
    else
        echo -e "${YELLOW}✓${NC} GRUB2 not found (different init system)"
    fi
}

analyze_kernel() {
    print_section "Kernel Information"
    
    echo "Kernel: $(uname -r)"
    echo "Kernel Version: $(uname -v)"
    echo "Architecture: $(uname -m)"
    echo "CPU Cores: $(nproc)"
    
    # Current boot parameters
    echo ""
    echo "Current Boot Parameters:"
    cat /proc/cmdline | tr ' ' '\n' | sed 's/^/  /'
}

analyze_boot_time() {
    print_section "Boot Performance Analysis"
    
    if ! command -v systemd-analyze &> /dev/null; then
        echo -e "${YELLOW}✗${NC} systemd-analyze not available"
        return
    fi
    
    echo "Overall Boot Time:"
    systemd-analyze | sed 's/^/  /'
    
    echo ""
    echo "Top 15 Slowest Services:"
    systemd-analyze blame 2>/dev/null | head -15 | sed 's/^/  /'
    
    echo ""
    echo "Critical Boot Path:"
    systemd-analyze critical-chain 2>/dev/null | head -10 | sed 's/^/  /'
}

analyze_targets() {
    print_section "systemd Targets"
    
    local default_target=$(systemctl get-default 2>/dev/null)
    echo "Default Target: $default_target"
    
    echo ""
    echo "Available Boot Targets:"
    systemctl list-units --type=target --all 2>/dev/null | \
        grep -E "multi-user|graphical|rescue|emergency" | \
        sed 's/^/  /'
}

analyze_services() {
    print_section "Services at Boot"
    
    local enabled_count=$(systemctl list-unit-files --type=service 2>/dev/null | grep -c "enabled" || true)
    local disabled_count=$(systemctl list-unit-files --type=service 2>/dev/null | grep -c "disabled" || true)
    
    echo "Enabled Services: $enabled_count"
    echo "Disabled Services: $disabled_count"
    
    echo ""
    echo "Top Enabled Services:"
    systemctl list-unit-files --type=service 2>/dev/null | grep enabled | head -10 | sed 's/^/  /'
    
    echo ""
    echo "Services with Failed Status:"
    systemctl list-units --type=service --state=failed 2>/dev/null | tail -n +2 | head -5 || \
        echo "  ${GREEN}✓${NC} No failed services"
}

analyze_filesystems() {
    print_section "Filesystem Configuration"
    
    # Check /boot mount
    if mount | grep -q "/boot"; then
        echo "Boot Partition Status:"
        mount | grep "/boot" | awk '{print "  Mounted at:", $3; print "  Type:", $5}' | sed 's/^/  /'
        
        local boot_usage=$(df -h /boot | tail -1 | awk '{print $5}')
        echo "  Usage: $boot_usage"
    fi
    
    # Check root filesystem
    echo ""
    echo "Root Filesystem Status:"
    df -h / | tail -1 | awk '{print "  Mount Point: /"; print "  Usage:", $5; print "  Available:", $4}' | sed 's/^/  /'
    
    # Check fstab
    echo ""
    echo "Entry Count in /etc/fstab: $(grep -cv '^#\|^$' /etc/fstab)"
}

analyze_boot_logs() {
    print_section "Recent Boot Log Excerpt"
    
    if command -v journalctl &> /dev/null; then
        echo "Last 5 boot messages from current boot:"
        journalctl -b -n 5 --no-pager 2>/dev/null | tail -6 | sed 's/^/  /'
        
        echo ""
        echo "Error/Warning Messages from Boot:"
        journalctl -b -p err..alert --no-pager 2>/dev/null | head -5 || \
            echo "  ${GREEN}✓${NC} No errors/warnings found"
    else
        echo "journalctl not available"
    fi
}

generate_timeline() {
    print_section "Generating Boot Timeline"
    
    if ! command -v systemd-analyze &> /dev/null; then
        echo -e "${YELLOW}✗${NC} systemd-analyze not available"
        return
    fi
    
    local timeline_file="/tmp/boot-timeline-$(date +%Y%m%d-%H%M%S).svg"
    
    if systemd-analyze plot > "$timeline_file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Timeline generated: $timeline_file"
        echo "  Size: $(du -h "$timeline_file" | cut -f1)"
        echo "  Open with: firefox $timeline_file"
    else
        echo -e "${RED}✗${NC} Failed to generate timeline"
    fi
}

generate_optimization_suggestions() {
    print_section "Optimization Suggestions"
    
    echo "To improve boot time, consider:"
    echo ""
    
    # Check for old kernels
    local old_kernel_count=$(ls -1 /boot/vmlinuz-* 2>/dev/null | wc -l)
    if [[ $old_kernel_count -gt 2 ]]; then
        echo "  1. Remove old kernels:"
        echo "     sudo apt autoremove      # Debian/Ubuntu"
        echo "     sudo yum autoremove      # RHEL/CentOS"
    fi
    
    # Check for disabled services
    echo "  2. Disable unnecessary services:"
    echo "     systemd-analyze blame | head -10"
    echo "     sudo systemctl disable SERVICE_NAME"
    
    # Check for socket activation
    echo "  3. Check if services can use socket activation"
    echo "     systemctl list-unit-files --type=socket"
    
    # Check for parallel startup
    echo "  4. Services with 'Type=simple' or 'Type=dbus' start faster"
    echo "     grep Type= /etc/systemd/system/*.service"
}

full_analysis() {
    clear
    print_header "Linux Boot Process Analysis"
    
    check_privilege
    echo ""
    
    analyze_firmware
    analyze_bootloader
    analyze_kernel
    analyze_boot_time
    analyze_targets
    analyze_services
    analyze_filesystems
    analyze_boot_logs
    generate_timeline
    generate_optimization_suggestions
    
    echo ""
    print_header "Analysis Complete"
    echo "Generated at: $(date)"
}

quick_analysis() {
    print_header "Linux Boot - Quick Summary"
    
    analyze_kernel
    analyze_boot_time
    analyze_targets
    
    print_header "Done"
}

################################################################################
# Main Script
################################################################################

main() {
    local mode="full"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--full)
                mode="full"
                shift
                ;;
            -q|--quick)
                mode="quick"
                shift
                ;;
            -s|--services)
                mode="services"
                shift
                ;;
            -d|--dependencies)
                mode="dependencies"
                shift
                ;;
            -l|--logs)
                mode="logs"
                shift
                ;;
            -t|--timeline)
                mode="timeline"
                shift
                ;;
            -r|--report)
                REPORT_FILE="$2"
                shift 2
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
            full_analysis
            ;;
        quick)
            quick_analysis
            ;;
        services)
            print_header "Top Slowest Services"
            analyze_boot_time
            ;;
        dependencies)
            print_header "Boot Dependencies"
            analyze_services
            ;;
        logs)
            print_header "Boot Logs"
            analyze_boot_logs
            ;;
        timeline)
            print_header "Boot Timeline"
            generate_timeline
            ;;
    esac
}

# Run main function
main "$@"
