#!/bin/bash
################################################################################
# kernel-param-optimizer.sh
# Analyze and suggest kernel parameter optimizations
# Provides recommendations for boot time and performance improvements
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
SUGGESTIONS=0

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [OPTION]

Analyze and optimize Linux kernel boot parameters

OPTIONS:
    -a, --analyze       Analyze current parameters (default)
    -s, --suggest       Get optimization suggestions
    -p, --performance   Performance-focused suggestions
    -b, --boot          Boot-time focused suggestions
    -h, --help          Show this help message

EXAMPLES:
    $0 --analyze        # Analyze current kernel parameters
    $0 --suggest        # Get all suggestions
    $0 --performance    # Performance optimizations

EOF
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}▸ $1${NC}"
    echo "──────────────────────────────────────────────────"
}

print_current() {
    echo -e "${GREEN}Current:${NC} $1"
}

print_suggestion() {
    echo -e "${YELLOW}→ Suggestion:${NC} $1"
    ((SUGGESTIONS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

get_current_param() {
    local param="$1"
    grep "$param=" /proc/cmdline | sed "s/.*$param=\([^ ]*\).*/\1/" || echo "not set"
}

check_has_param() {
    local param="$1"
    grep -q "$param" /proc/cmdline
}

analyze_current_params() {
    print_header "Current Kernel Boot Parameters"
    
    print_info "Parameters used in current boot:"
    echo ""
    cat /proc/cmdline | tr ' ' '\n' | grep -v '^$' | sort | sed 's/^/  /'
    
    echo ""
    print_info "Source: /proc/cmdline"
}

suggest_boot_optimization() {
    print_section "Boot Time Optimizations"
    
    # Check quiet and splash
    if ! check_has_param "quiet"; then
        print_current "quiet parameter: NOT SET"
        print_suggestion "Add 'quiet' to reduce boot messages (faster perceived boot)"
        echo "  This hides non-critical kernel messages"
    else
        print_ok "quiet parameter is set (reduces boot messages)"
    fi
    
    if ! check_has_param "splash"; then
        print_current "splash parameter: NOT SET"
        print_suggestion "Add 'splash' for Plymouth boot splash screen"
    else
        print_ok "splash parameter is set (shows boot splash)"
    fi
    
    # Check for loglevel
    if check_has_param "loglevel"; then
        local level=$(get_current_param "loglevel")
        print_current "loglevel: $level"
        
        if [[ "$level" -gt 3 ]]; then
            print_suggestion "Set loglevel=3 to reduce kernel messages (KERN_ERR and below)"
        fi
    else
        print_current "loglevel: NOT SET (default is 7, very verbose)"
        print_suggestion "Add 'loglevel=3' to reduce kernel message verbosity"
        echo "  Levels: 0=EMERG, 1=ALERT, 2=CRIT, 3=ERR, 4=WARN, 5=NOTICE, 6=INFO, 7=DEBUG"
    fi
    
    # Check for ro parameter
    if check_has_param "ro"; then
        print_ok "ro parameter is set (mount root read-only initially)"
    else
        print_current "ro parameter: NOT SET"
        print_suggestion "Add 'ro' to mount root read-only initially (safer boot)"
    fi
    
    # Check for no_console_suspend
    if check_has_param "no_console_suspend"; then
        print_ok "no_console_suspend is set"
    else
        print_suggestion "Add 'no_console_suspend' to keep console alive during suspend (debugging)"
    fi
}

suggest_performance_optimization() {
    print_section "Performance Optimizations"
    
    # CPU scaling
    if check_has_param "cpufreq"; then
        local gov=$(get_current_param "cpufreq")
        print_current "CPU frequency scaling governor: $gov"
    else
        print_current "cpufreq: NOT SET"
        print_suggestion "Consider adding 'cpufreq.default_governor=performance' for server workloads"
        echo "  Options: performance, powersave, ondemand, conservative, schedutil"
    fi
    
    # I/O scheduler
    if check_has_param "elevator"; then
        local sched=$(get_current_param "elevator")
        print_current "I/O scheduler: $sched"
    else
        print_current "elevator: NOT SET (uses kernel default)"
        print_suggestion "For high-performance storage, consider elevator=noop or elevator=none"
        echo "  Options: noop, deadline, cfq, none (for NVMe)"
    fi
    
    # Hugepages
    if check_has_param "hugepages"; then
        local pages=$(get_current_param "hugepages")
        print_current "Huge pages: $pages"
    else
        print_current "hugepages: NOT SET"
        print_suggestion "For memory-intensive apps: add 'hugepages=256' (allocate 2GB with 8MB pages)"
        echo "  Reduces TLB misses and improves memory performance"
    fi
    
    # Transparent hugepages
    if check_has_param "transparent_hugepage"; then
        local thp=$(get_current_param "transparent_hugepage")
        print_current "Transparent hugepages: $thp"
    else
        print_current "transparent_hugepage: NOT SET (uses kernel default: madvise)"
        print_suggestion "For databases/caches: consider 'transparent_hugepage=always'"
        echo "  Tradeoff: better memory efficiency vs. CPU overhead for THP allocation"
    fi
    
    # NUMA
    if check_has_param "numa"; then
        local numa=$(get_current_param "numa")
        print_current "NUMA: $numa"
    else
        local has_numa=$(find /proc/numa -type d 2>/dev/null | wc -l)
        if [[ $has_numa -gt 1 ]]; then
            print_current "NUMA: NOT EXPLICITLY SET (system has NUMA hardware)"
            print_suggestion "Consider 'numa=off' if experiencing NUMA issues, or tune interleave policy"
        fi
    fi
}

suggest_hardware_specific() {
    print_section "Hardware-Specific Optimizations"
    
    # GPU/nomodeset
    if check_has_param "nomodeset"; then
        print_ok "nomodeset is set (using BIOS video mode)"
        print_info "This is sometimes needed for broken GPUs or old hardware"
    else
        print_current "nomodeset: NOT SET (kernel video mode setting enabled)"
        print_suggestion "If GPU issues at boot, try 'nomodeset' (uses BIOS-set video mode)"
    fi
    
    # IOMMU
    if check_has_param "iommu"; then
        local iommu=$(get_current_param "iommu")
        print_current "IOMMU: $iommu"
    else
        print_current "IOMMU: NOT SET"
        print_suggestion "For passthrough VMs: consider 'iommu=pt' (passthrough mode)"
        echo "  Or 'intel_iommu=on' for Intel / 'amd_iommu=on' for AMD"
    fi
    
    # ACPI
    if check_has_param "acpi"; then
        local acpi=$(get_current_param "acpi")
        print_current "ACPI: $acpi"
    else
        print_current "ACPI: NOT EXPLICITLY SET (enabled by default)"
        print_suggestion "If power/thermal issues: try 'acpi=off' (disables all ACPI)"
        echo "  Or specific: 'acpi_osi=Linux' for OS compatibility mode"
    fi
    
    # PCI settings
    if check_has_param "pci"; then
        local pci=$(get_current_param "pci")
        print_current "PCI options: $pci"
    else
        print_current "PCI: NOT SET"
        print_suggestion "For problematic hardware: try 'pci=nomsi' (disable message signaled interrupts)"
    fi
}

suggest_debugging() {
    print_section "Debugging & Troubleshooting Options"
    
    # Kernel debugging
    if check_has_param "debug"; then
        print_ok "debug parameter is set"
    else
        print_current "debug: NOT SET"
        print_suggestion "For troubleshooting: add 'debug' to enable kernel debugging"
        echo "  Shows all boot messages at KERN_DEBUG level"
    fi
    
    # Panic behavior
    if check_has_param "panic"; then
        local panic=$(get_current_param "panic")
        print_current "Panic timeout: ${panic}s"
    else
        print_current "panic: NOT SET (kernel hangs on panic)"
        print_suggestion "Add 'panic=10' to auto-reboot 10s after kernel panic"
        echo "  Useful for servers: panic=-1 reboots immediately"
    fi
    
    # Verbose output
    if check_has_param "verbose"; then
        print_ok "verbose parameter is set (maximum messages)"
    else
        print_current "verbose: NOT SET"
        print_suggestion "For boot troubleshooting: temporarily add 'verbose' to see all messages"
    fi
    
    # Dynamic debug
    if check_has_param "dyndbg"; then
        local dyndbg=$(get_current_param "dyndbg")
        print_current "Dynamic debug: $dyndbg"
    else
        print_current "dyndbg: NOT SET"
        print_suggestion "For module debugging: 'dyndbg=\"file drivers/your/driver.c +p\"'"
    fi
}

suggest_security() {
    print_section "Security-Related Options"
    
    # Selinux
    if check_has_param "selinux"; then
        local selinux=$(get_current_param "selinux")
        print_current "SELinux: $selinux"
    else
        print_current "SELinux: NOT SET (may be managed by init system)"
        print_suggestion "For strong mandatory access control: 'selinux=1' with enforcing=1"
    fi
    
    # AppArmor
    if check_has_param "apparmor"; then
        local apparmor=$(get_current_param "apparmor")
        print_current "AppArmor: $apparmor"
    else
        print_current "AppArmor: NOT SET"
        print_suggestion "For Ubuntu security: 'apparmor=1' to enable AppArmor at boot"
    fi
    
    # Module signing
    if check_has_param "module.sig_enforce"; then
        local sig=$(get_current_param "module.sig_enforce")
        print_current "Module signature enforcement: $sig"
    else
        print_current "module.sig_enforce: NOT SET"
        print_suggestion "For security: 'module.sig_enforce=1' requires signed kernel modules"
    fi
    
    # Randomization
    if check_has_param "slub_debug"; then
        local slub=$(get_current_param "slub_debug")
        print_current "SLUB debugging: $slub"
    else
        print_current "slub_debug: NOT SET"
        print_suggestion "For security testing: 'slub_debug=P' (poisoning on free)"
    fi
}

analyze_grub_defaults() {
    print_header "GRUB Default Configuration Analysis"
    
    if [[ ! -f /etc/default/grub ]]; then
        print_info "GRUB not found or system uses different bootloader"
        return
    fi
    
    echo "Current /etc/default/grub settings:"
    echo ""
    
    grep "^GRUB_CMDLINE" /etc/default/grub | sed 's/^/  /'
    
    echo ""
    print_info "To modify kernel parameters:"
    echo "  1. Edit /etc/default/grub"
    echo "  2. Find GRUB_CMDLINE_LINUX_DEFAULT line"
    echo "  3. Add/remove parameters"
    echo "  4. Run: sudo update-grub"
    echo "  5. Reboot to apply"
}

generate_config_template() {
    print_header "Optimized GRUB Configuration Template"
    
    echo ""
    echo "# For balanced boot time and performance:"
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash ro loglevel=3"'
    echo ""
    
    echo "# For maximum boot performance:"
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet ro loglevel=3 elevator=noop"'
    echo ""
    
    echo "# For maximum compatibility (verbose output):"
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="verbose ro"'
    echo ""
    
    echo "# For server workload (performance + stability):"
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet ro loglevel=3 panic=10 elevator=deadline"'
    echo ""
    
    echo "# For database/cache (memory optimizations):"
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet ro hugepages=256 transparent_hugepage=always"'
    echo ""
}

print_summary() {
    echo ""
    print_header "Optimization Summary"
    
    echo -e "Total suggestions: ${YELLOW}$SUGGESTIONS${NC}"
    echo ""
    echo "To apply changes:"
    echo "  1. Edit /etc/default/grub"
    echo "  2. Modify GRUB_CMDLINE_LINUX_DEFAULT line"
    echo "  3. Run: sudo update-grub"
    echo "  4. Reboot: sudo reboot"
    echo ""
    echo "To test before applying:"
    echo "  • Boot into GRUB menu (hold Shift)"
    echo "  • Press 'e' to edit"
    echo "  • Add parameters to linux/linuxefi line"
    echo "  • Press Ctrl+X to boot with new parameters"
}

################################################################################
# Main Script
################################################################################

main() {
    local mode="analyze"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--analyze)
                mode="analyze"
                shift
                ;;
            -s|--suggest)
                mode="suggest"
                shift
                ;;
            -p|--performance)
                mode="performance"
                shift
                ;;
            -b|--boot)
                mode="boot"
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
        analyze)
            analyze_current_params
            analyze_grub_defaults
            ;;
        suggest)
            analyze_current_params
            suggest_boot_optimization
            suggest_performance_optimization
            suggest_hardware_specific
            suggest_debugging
            suggest_security
            generate_config_template
            print_summary
            ;;
        performance)
            suggest_performance_optimization
            suggest_hardware_specific
            generate_config_template
            ;;
        boot)
            suggest_boot_optimization
            generate_config_template
            print_summary
            ;;
    esac
}

# Run main function
main "$@"
