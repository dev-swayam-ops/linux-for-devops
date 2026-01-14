#!/bin/bash

################################################################################
# port-monitor.sh - Real-time Port and Connection Monitoring Tool
################################################################################
#
# PURPOSE:
#   Monitor network ports in real-time, showing listening services and active
#   connections. Helps identify port conflicts, unexpected services, and
#   network connection patterns.
#
# USAGE:
#   ./port-monitor.sh              # Show listening ports once
#   ./port-monitor.sh -w 5         # Watch listening ports, update every 5 seconds
#   ./port-monitor.sh -l           # List listening ports with details
#   ./port-monitor.sh -c           # Show active connections
#   ./port-monitor.sh -p 8080      # Monitor specific port
#   ./port-monitor.sh -h           # Show this help
#
# REQUIREMENTS:
#   - ss command (socket statistics, modern Linux)
#   - root/sudo access recommended
#
# EXAMPLES:
#   # Monitor port 22 (SSH) every 2 seconds
#   sudo ./port-monitor.sh -w 2 -p 22
#
#   # Show all listening ports with service names
#   sudo ./port-monitor.sh -l
#
#   # Find what's using port 8080
#   ./port-monitor.sh -p 8080
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
readonly NC='\033[0m' # No Color

# Default values
MODE="list"           # list, watch, connections, specific-port
PORT=""               # If monitoring specific port
WATCH_INTERVAL=""     # If watch mode
PROTOCOL="tcp"        # tcp or udp

################################################################################
# FUNCTIONS
################################################################################

show_help() {
    cat << EOF
${BLUE}${SCRIPT_NAME} v${SCRIPT_VERSION}${NC} - Monitor Network Ports and Connections

${GREEN}USAGE:${NC}
    ${SCRIPT_NAME} [OPTIONS]

${GREEN}OPTIONS:${NC}
    -l, --listen          Show all listening ports (default)
    -c, --connections     Show established connections
    -w, --watch SECONDS   Watch mode, update every N seconds
    -p, --port PORT       Monitor specific port
    -u, --udp             Show UDP ports (instead of TCP)
    -h, --help            Show this help message
    -v, --version         Show version

${GREEN}EXAMPLES:${NC}
    # Show all listening TCP ports
    ${SCRIPT_NAME} --listen

    # Watch listening ports every 2 seconds
    ${SCRIPT_NAME} --watch 2

    # Show established connections
    ${SCRIPT_NAME} --connections

    # Monitor specific port (TCP 8080)
    ${SCRIPT_NAME} --port 8080

    # Monitor UDP port 53 (DNS)
    ${SCRIPT_NAME} --port 53 --udp

    # Watch all connections every 3 seconds (with sudo)
    sudo ${SCRIPT_NAME} --connections --watch 3

${GREEN}COMMON PORTS:${NC}
    22    SSH
    80    HTTP
    443   HTTPS
    53    DNS
    3306  MySQL
    5432  PostgreSQL
    6379  Redis
    8080  Alternate HTTP

${GREEN}TROUBLESHOOTING:${NC}
    Port appears busy?           Try: lsof -i :PORT
    Need process info?           Run with: sudo
    Want more details?           Use: ss -anp | grep PORT

${GREEN}SECURITY NOTE:${NC}
    • Always review unexpected listening services
    • Use: ss -tlnp to see processes
    • Check: sudo lsof -i -P -n to identify processes

EOF
}

show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

# Main function: Show listening ports
show_listening_ports() {
    echo -e "${BLUE}=== Listening ${PROTOCOL^^} Ports ===${NC}"
    echo ""
    
    if [ "${PROTOCOL}" = "tcp" ]; then
        # TCP ports
        ss -tlnp 2>/dev/null | tail -n +2 | while read -r line; do
            if [ -z "$line" ]; then continue; fi
            
            # Extract port number
            local port=$(echo "$line" | awk '{print $4}' | rev | cut -d: -f1 | rev)
            local state=$(echo "$line" | awk '{print $1}')
            local process=$(echo "$line" | grep -oP '(?<=\().*(?=\))' || echo "unknown")
            
            # Color code by port range
            local color=$NC
            if [ "${port}" -lt 1024 ]; then
                color=$RED  # System ports in red
            elif [ "${port}" -lt 5000 ]; then
                color=$YELLOW  # Common app ports in yellow
            else
                color=$GREEN  # High ports in green
            fi
            
            printf "${color}%-10s${NC} Port: %-6s Process: %s\n" "$state" "$port" "$process"
        done
    else
        # UDP ports
        ss -ulnp 2>/dev/null | tail -n +2 | while read -r line; do
            if [ -z "$line" ]; then continue; fi
            
            local port=$(echo "$line" | awk '{print $4}' | rev | cut -d: -f1 | rev)
            local process=$(echo "$line" | grep -oP '(?<=\().*(?=\))' || echo "unknown")
            
            printf "UDP Port: %-6s Process: %s\n" "$port" "$process"
        done
    fi
    echo ""
}

# Show active connections
show_connections() {
    echo -e "${BLUE}=== Active Connections ===${NC}"
    echo ""
    
    ss -anp 2>/dev/null | grep -E "ESTAB|CLOSE_WAIT|FIN_WAIT" || echo "No active connections"
    echo ""
}

# Monitor specific port
monitor_port() {
    local port=$1
    echo -e "${BLUE}=== Monitoring Port $port ===${NC}"
    echo ""
    
    # Check TCP
    local result=$(ss -tlnp 2>/dev/null | grep ":${port}" || echo "")
    
    if [ -z "$result" ]; then
        result=$(ss -ulnp 2>/dev/null | grep ":${port}" || echo "")
        if [ -z "$result" ]; then
            echo -e "${YELLOW}Port $port: Not listening${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}Port $port: LISTENING${NC}"
    echo "$result"
    echo ""
    
    # Also show any connections to/from this port
    echo -e "${BLUE}Active connections on port $port:${NC}"
    ss -anp 2>/dev/null | grep ":${port}" | grep -v LISTEN || echo "No active connections"
    echo ""
}

# Watch mode - continuously monitor
watch_mode() {
    local interval=$1
    
    while true; do
        clear
        echo -e "${BLUE}Port Monitor (${SCRIPT_NAME}) - Refresh every ${interval}s${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo -e "${BLUE}Last update: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
        echo ""
        
        if [ "$MODE" = "list" ]; then
            show_listening_ports
        elif [ "$MODE" = "connections" ]; then
            show_connections
        elif [ "$MODE" = "specific-port" ]; then
            monitor_port "$PORT"
        fi
        
        sleep "$interval"
    done
}

################################################################################
# MAIN SCRIPT
################################################################################

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--listen)
            MODE="list"
            shift
            ;;
        -c|--connections)
            MODE="connections"
            shift
            ;;
        -w|--watch)
            WATCH_INTERVAL="$2"
            shift 2
            ;;
        -p|--port)
            MODE="specific-port"
            PORT="$2"
            shift 2
            ;;
        -u|--udp)
            PROTOCOL="udp"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
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

# Execute based on mode
if [ -n "$WATCH_INTERVAL" ]; then
    # Watch mode
    watch_mode "$WATCH_INTERVAL"
else
    # Single run
    case "$MODE" in
        list)
            show_listening_ports
            ;;
        connections)
            show_connections
            ;;
        specific-port)
            if [ -z "$PORT" ]; then
                echo "Error: Port number required for --port option"
                exit 1
            fi
            monitor_port "$PORT"
            ;;
        *)
            echo "Error: Unknown mode"
            exit 1
            ;;
    esac
fi

exit 0
