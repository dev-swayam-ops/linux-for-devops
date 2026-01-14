#!/bin/bash

################################################################################
# network-health-check.sh - Comprehensive Network Diagnostic Tool
################################################################################
#
# PURPOSE:
#   Perform comprehensive network diagnostics to quickly identify connectivity
#   issues, DNS problems, routing issues, and service availability.
#   Useful for troubleshooting network problems in production systems.
#
# USAGE:
#   ./network-health-check.sh              # Full diagnostic
#   ./network-health-check.sh -q           # Quick check (internet only)
#   ./network-health-check.sh -h HOST      # Check specific host
#   ./network-health-check.sh --full       # Detailed diagnostic
#   ./network-health-check.sh --help       # Show this help
#
# REQUIREMENTS:
#   - ping, traceroute, dig/nslookup, ss, route commands
#   - Internet connection recommended
#
# EXIT CODES:
#   0 = All checks passed
#   1 = Some checks failed
#   2 = Critical failure (no connectivity)
#
# EXAMPLES:
#   # Full health check
#   ./network-health-check.sh
#
#   # Quick check
#   ./network-health-check.sh -q
#
#   # Check specific host
#   ./network-health-check.sh -h example.com
#
#   # Detailed diagnostics
#   ./network-health-check.sh --full
#

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Counters
CHECKS_TOTAL=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Configuration
MODE="full"              # full, quick, host-check, detailed
CHECK_HOST="8.8.8.8"     # Google DNS as default
TARGET_HOST=""
VERBOSE=0

################################################################################
# UTILITY FUNCTIONS
################################################################################

# Print colored header
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1${BLUE}${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
}

# Print colored section
print_section() {
    echo -e "${CYAN}→ $1${NC}"
}

# Print check result
check_result() {
    local check_name=$1
    local result=$2
    local details=$3
    
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓${NC} $check_name: ${GREEN}PASS${NC}"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $check_name: ${RED}FAIL${NC}"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
    
    if [ -n "$details" ]; then
        echo "  └─ $details"
    fi
}

show_help() {
    cat << EOF
${BLUE}${SCRIPT_NAME} v${SCRIPT_VERSION}${NC} - Network Health Diagnostic Tool

${GREEN}USAGE:${NC}
    ${SCRIPT_NAME} [OPTIONS]

${GREEN}OPTIONS:${NC}
    -q, --quick           Quick connectivity check
    -h, --host HOST       Check specific host
    --full                Detailed diagnostics (default)
    -v, --verbose         Verbose output
    --help                Show this help
    --version             Show version

${GREEN}EXAMPLES:${NC}
    # Full health check
    ${SCRIPT_NAME}

    # Quick check (30 seconds)
    ${SCRIPT_NAME} --quick

    # Check specific host
    ${SCRIPT_NAME} --host google.com

    # Detailed output
    ${SCRIPT_NAME} --full -v

${GREEN}WHAT IT CHECKS:${NC}
    ✓ Local interfaces and IP configuration
    ✓ Internet connectivity (ping external host)
    ✓ DNS resolution (name to IP)
    ✓ Reverse DNS (IP to name)
    ✓ Routing table (default gateway)
    ✓ Listening ports (suspicious services)
    ✓ Established connections
    ✓ Network statistics
    ✓ Host connectivity (optional)

${GREEN}EXIT CODES:${NC}
    0 = All checks passed
    1 = Some checks failed (warnings)
    2 = Critical failure (no internet)

${GREEN}COMMON ISSUES DETECTED:${NC}
    • No network interface
    • Interface down
    • No IP assigned
    • No internet connectivity
    • DNS not working
    • Invalid gateway
    • Unexpected listening ports

EOF
}

show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

################################################################################
# NETWORK CHECK FUNCTIONS
################################################################################

check_interfaces() {
    print_section "Network Interfaces"
    
    local interface_count
    interface_count=$(ip link show | grep -c "^[0-9]" || echo 0)
    
    if [ "$interface_count" -lt 2 ]; then
        check_result "Network Interfaces" "FAIL" "Less than 2 interfaces found"
        return 1
    fi
    
    # Find active interface
    local active_interface
    active_interface=$(ip link show | grep "UP" | head -1 | awk '{print $2}' | sed 's/:$//')
    
    if [ -z "$active_interface" ]; then
        check_result "Network Interfaces" "FAIL" "No active interface found"
        return 1
    fi
    
    local ip_addr
    ip_addr=$(ip addr show "$active_interface" | grep "inet " | awk '{print $2}')
    
    if [ -z "$ip_addr" ]; then
        check_result "Network Interfaces" "FAIL" "Active interface has no IP"
        return 1
    fi
    
    check_result "Network Interfaces" "PASS" "Interface: $active_interface, IP: $ip_addr"
    return 0
}

check_localhost() {
    print_section "Localhost Connectivity"
    
    if ping -c 1 127.0.0.1 &>/dev/null; then
        check_result "Localhost (127.0.0.1)" "PASS" ""
        return 0
    else
        check_result "Localhost (127.0.0.1)" "FAIL" "Cannot ping loopback"
        return 1
    fi
}

check_gateway() {
    print_section "Gateway & Routing"
    
    local gateway
    gateway=$(ip route | grep default | awk '{print $3}' | head -1)
    
    if [ -z "$gateway" ]; then
        check_result "Default Gateway" "FAIL" "No default gateway found"
        return 1
    fi
    
    if ping -c 1 "$gateway" &>/dev/null; then
        check_result "Default Gateway" "PASS" "Gateway: $gateway"
        return 0
    else
        check_result "Default Gateway" "FAIL" "Cannot ping gateway: $gateway"
        return 1
    fi
}

check_internet() {
    print_section "Internet Connectivity"
    
    # Try multiple hosts
    local result=1
    local test_host
    
    for test_host in "$CHECK_HOST" 1.1.1.1 8.8.4.4; do
        if ping -c 1 -W 2 "$test_host" &>/dev/null; then
            check_result "Internet Connectivity" "PASS" "Reached $test_host"
            result=0
            break
        fi
    done
    
    if [ $result -ne 0 ]; then
        check_result "Internet Connectivity" "FAIL" "Cannot reach any test host"
    fi
    
    return $result
}

check_dns() {
    print_section "DNS Resolution"
    
    # Try to resolve google.com
    if dig +short google.com @8.8.8.8 &>/dev/null; then
        local ip
        ip=$(dig +short google.com @8.8.8.8 | head -1)
        check_result "DNS Resolution" "PASS" "google.com resolves to $ip"
        return 0
    else
        check_result "DNS Resolution" "FAIL" "Cannot resolve google.com"
        return 1
    fi
}

check_reverse_dns() {
    print_section "Reverse DNS"
    
    # Reverse lookup for 8.8.8.8
    if dig +short -x 8.8.8.8 &>/dev/null; then
        local hostname
        hostname=$(dig +short -x 8.8.8.8 | head -1)
        check_result "Reverse DNS" "PASS" "8.8.8.8 → $hostname"
        return 0
    else
        check_result "Reverse DNS" "FAIL" "Reverse DNS lookup failed"
        return 1
    fi
}

check_listening_ports() {
    print_section "Listening Ports"
    
    local unusual_ports=0
    local suspicious=""
    
    # Check for unusual listening ports
    while IFS= read -r line; do
        local port
        port=$(echo "$line" | awk '{print $4}' | rev | cut -d: -f1 | rev)
        
        # Flag ports that are unusual
        if [ "$port" -gt 1024 ] && [ "$port" -lt 5000 ] && [ "$port" != "3306" ] && \
           [ "$port" != "5432" ] && [ "$port" != "5000" ] && [ "$port" != "8080" ]; then
            unusual_ports=$((unusual_ports + 1))
            suspicious="$suspicious $port"
        fi
    done < <(ss -tlnp 2>/dev/null | tail -n +2)
    
    if [ $unusual_ports -eq 0 ]; then
        check_result "Listening Ports" "PASS" "Normal ports listening"
        return 0
    else
        check_result "Listening Ports" "WARN" "Unusual ports detected:$suspicious"
        return 0
    fi
}

check_established_connections() {
    print_section "Established Connections"
    
    local conn_count
    conn_count=$(ss -anp 2>/dev/null | grep ESTAB | wc -l)
    
    if [ "$conn_count" -lt 10 ]; then
        check_result "Established Connections" "PASS" "$conn_count connections (normal)"
    else
        check_result "Established Connections" "WARN" "$conn_count connections (high)"
    fi
    
    return 0
}

check_host_connectivity() {
    print_section "Host Connectivity Check: $TARGET_HOST"
    
    # Try to ping
    if ping -c 1 -W 2 "$TARGET_HOST" &>/dev/null; then
        check_result "Ping to $TARGET_HOST" "PASS" ""
    else
        check_result "Ping to $TARGET_HOST" "FAIL" "No response"
        return 1
    fi
    
    # Try to resolve (if hostname)
    if ! echo "$TARGET_HOST" | grep -qE '^[0-9.]+$'; then
        if dig +short "$TARGET_HOST" &>/dev/null; then
            check_result "DNS for $TARGET_HOST" "PASS" ""
        else
            check_result "DNS for $TARGET_HOST" "FAIL" "Cannot resolve"
            return 1
        fi
    fi
    
    # Try traceroute (non-blocking)
    print_section "  Trace Route to $TARGET_HOST (up to 5 hops)"
    timeout 5 traceroute -m 5 "$TARGET_HOST" 2>/dev/null | head -6 || echo "    (traceroute not available)"
    
    return 0
}

################################################################################
# REPORTING FUNCTIONS
################################################################################

print_summary() {
    echo ""
    print_header "Summary"
    
    echo -e "Total Checks: ${CYAN}$CHECKS_TOTAL${NC}"
    echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
    echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"
    echo ""
    
    if [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All checks passed! Network is healthy.${NC}"
        return 0
    elif [ $CHECKS_FAILED -lt 3 ]; then
        echo -e "${YELLOW}⚠ Some checks failed. Review details above.${NC}"
        return 1
    else
        echo -e "${RED}✗ Multiple failures detected. Critical issues present.${NC}"
        return 2
    fi
}

print_recommendations() {
    print_header "Recommendations"
    
    if [ "$CHECKS_FAILED" -gt 0 ]; then
        echo "To troubleshoot network issues:"
        echo "  1. Check interface status: ip link show"
        echo "  2. View IP configuration: ip addr show"
        echo "  3. Test gateway: ping GATEWAY"
        echo "  4. Check DNS: nslookup google.com"
        echo "  5. Trace path: traceroute 8.8.8.8"
        echo "  6. View routing: ip route show"
        echo "  7. Check firewall: sudo ufw status"
        echo ""
    fi
}

print_detailed_info() {
    print_header "Detailed Network Information"
    
    print_section "Network Interfaces"
    ip addr show | grep -E "^[0-9]|inet "
    
    echo ""
    print_section "Routing Table"
    ip route show | head -5
    
    echo ""
    print_section "Listening Ports"
    ss -tlnp 2>/dev/null | tail -n +2 | head -5
    
    echo ""
    print_section "DNS Configuration"
    cat /run/systemd/resolve/resolv.conf 2>/dev/null | grep nameserver || echo "Not available"
    
    echo ""
}

################################################################################
# MAIN SCRIPT
################################################################################

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quick)
            MODE="quick"
            shift
            ;;
        -h|--host)
            MODE="host-check"
            TARGET_HOST="$2"
            shift 2
            ;;
        --full)
            MODE="full"
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        --version)
            show_version
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'"
            echo "Try: ${SCRIPT_NAME} --help"
            exit 1
            ;;
    esac
done

print_header "Network Health Check (${SCRIPT_NAME})"

case "$MODE" in
    quick)
        # Quick checks only
        check_interfaces
        check_localhost
        check_gateway
        check_internet
        print_summary
        exit $?
        ;;
    
    host-check)
        # Check specific host
        if [ -z "$TARGET_HOST" ]; then
            echo "Error: Host required for host-check mode"
            exit 1
        fi
        check_interfaces
        check_localhost
        check_gateway
        check_internet
        check_host_connectivity
        print_summary
        print_recommendations
        exit $?
        ;;
    
    full)
        # Full checks
        check_interfaces
        check_localhost
        check_gateway
        check_internet
        check_dns
        check_reverse_dns
        check_listening_ports
        check_established_connections
        
        print_summary
        EXIT_CODE=$?
        
        if [ $VERBOSE -eq 1 ] || [ $EXIT_CODE -ne 0 ]; then
            print_detailed_info
            print_recommendations
        fi
        
        exit $EXIT_CODE
        ;;
esac

exit 0
