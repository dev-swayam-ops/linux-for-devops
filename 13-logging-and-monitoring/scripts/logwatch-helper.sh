#!/bin/bash
################################################################################
# logwatch-helper.sh
# Setup and manage logwatch for automated log reviews
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Setup and manage logwatch for automated log monitoring and reporting

COMMANDS:
    install         Install logwatch (requires sudo)
    config          Show current configuration
    test            Run test report
    report-daily    Generate daily report
    report-weekly   Generate weekly report
    setup-cron      Setup automated daily reports (requires sudo)
    disable-cron    Disable automated reports (requires sudo)
    status          Show installation and cron status
    help            Show this help

OPTIONS:
    --output FILE       Save report to file
    --format FORMAT     Report format (text, html, json)
    --detail LEVEL      Detail level (Low, Med, High)
    --service SERVICE   Monitor specific service
    --range RANGE       Time range (Today, Yesterday, All)

EXAMPLES:
    # Check if installed
    $0 status
    
    # Generate test report
    $0 test
    
    # Generate detailed daily report
    $0 report-daily --detail High
    
    # Setup automatic daily emails
    sudo $0 setup-cron --output /var/log/logwatch-report.txt

EOF
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1" >&2
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This operation requires root privileges"
        echo "Run with: sudo $0 $@"
        exit 1
    fi
}

is_installed() {
    command -v logwatch &> /dev/null
}

install_logwatch() {
    check_root
    
    print_header "Installing Logwatch"
    
    if is_installed; then
        print_ok "Logwatch is already installed"
        return 0
    fi
    
    # Detect distro and install
    if [[ -f /etc/debian_version ]]; then
        print_ok "Installing on Debian/Ubuntu..."
        apt-get update
        apt-get install -y logwatch
    elif [[ -f /etc/redhat-release ]]; then
        print_ok "Installing on RHEL/CentOS..."
        yum install -y logwatch
    else
        print_error "Cannot detect distribution"
        return 1
    fi
    
    if is_installed; then
        print_ok "Logwatch installed successfully"
    else
        print_error "Installation failed"
        return 1
    fi
}

show_config() {
    print_header "Logwatch Configuration"
    
    local config_file="/etc/logwatch/conf/logwatch.conf"
    
    if [[ -f "$config_file" ]]; then
        echo "=== Main Configuration ==="
        grep -v "^#" "$config_file" | grep -v "^$" | head -20
    else
        print_warn "Configuration file not found: $config_file"
        echo "This is normal if using defaults"
    fi
    
    echo ""
    echo "=== Services Monitored ==="
    ls -1 /etc/logwatch/scripts/services/ 2>/dev/null | head -10 || echo "No services found"
}

run_test_report() {
    if ! is_installed; then
        print_error "Logwatch not installed"
        echo "Run: $0 install"
        return 1
    fi
    
    print_header "Running Test Report (Last 24 Hours)"
    
    logwatch --range Today --detail High 2>/dev/null || {
        print_warn "Test report generation failed"
        print_ok "Trying basic logwatch..."
        logwatch --range Today --format text 2>/dev/null || {
            print_error "Logwatch cannot generate report"
            return 1
        }
    }
}

generate_report() {
    local range="$1"
    local detail="${2:-Med}"
    local output_file="${3:-}"
    
    if ! is_installed; then
        print_error "Logwatch not installed"
        return 1
    fi
    
    print_header "Generating $range Report"
    
    local cmd="logwatch --range $range --detail $detail --format text"
    
    if [[ -n "$output_file" ]]; then
        $cmd > "$output_file"
        print_ok "Report saved to: $output_file"
    else
        $cmd
    fi
}

setup_cron_job() {
    check_root
    
    local output_file="${1:-/var/log/logwatch-daily-report.txt}"
    
    print_header "Setting up Daily Logwatch Cron Job"
    
    # Create cron job
    cat > /etc/cron.daily/logwatch-report << 'CRON_SCRIPT'
#!/bin/bash
/usr/sbin/logwatch --range Today --detail High --format text > /var/log/logwatch-daily-report.txt 2>&1
CRON_SCRIPT
    
    chmod 755 /etc/cron.daily/logwatch-report
    
    print_ok "Cron job created: /etc/cron.daily/logwatch-report"
    print_ok "Report will be saved to: $output_file"
    
    echo ""
    echo "To view report:"
    echo "  tail /var/log/logwatch-daily-report.txt"
}

disable_cron_job() {
    check_root
    
    if [[ -f /etc/cron.daily/logwatch-report ]]; then
        rm /etc/cron.daily/logwatch-report
        print_ok "Cron job removed"
    else
        print_warn "No cron job found to remove"
    fi
}

show_status() {
    print_header "Logwatch Status"
    
    if is_installed; then
        print_ok "Logwatch is installed"
        
        # Check version
        local version=$(logwatch --version 2>/dev/null | head -1)
        echo "Version: $version"
    else
        print_warn "Logwatch is not installed"
        echo "Install with: sudo $0 install"
    fi
    
    echo ""
    echo "Cron Job Status:"
    if [[ -f /etc/cron.daily/logwatch-report ]]; then
        print_ok "Daily report cron job is enabled"
    else
        print_warn "No daily report cron job configured"
        echo "Setup with: sudo $0 setup-cron"
    fi
    
    echo ""
    echo "Recent reports:"
    ls -lt /var/log/logwatch* 2>/dev/null | head -3 || echo "  (none found)"
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
    
    case "$command" in
        install)
            install_logwatch
            ;;
        config)
            show_config
            ;;
        test)
            run_test_report
            ;;
        report-daily)
            local output=""
            local detail="Med"
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --output)
                        output="$2"
                        shift 2
                        ;;
                    --detail)
                        detail="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            generate_report "Today" "$detail" "$output"
            ;;
        report-weekly)
            local output=""
            local detail="Med"
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --output)
                        output="$2"
                        shift 2
                        ;;
                    --detail)
                        detail="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            generate_report "This Week" "$detail" "$output"
            ;;
        setup-cron)
            local output="/var/log/logwatch-daily-report.txt"
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --output)
                        output="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            
            setup_cron_job "$output"
            ;;
        disable-cron)
            disable_cron_job
            ;;
        status)
            show_status
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
