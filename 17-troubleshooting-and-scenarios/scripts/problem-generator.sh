#!/usr/bin/env bash
# Problem Generator for Troubleshooting Lab Practice
# Purpose: Create controlled problem scenarios for hands-on learning
# Usage: ./problem-generator.sh [--scenario NAME] [--duration SECS] [--cleanup]
# Scenarios: memory-leak, disk-fill, cpu-spike, zombie-fork, service-crash

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"
readonly PROBLEM_DIR="/tmp/lab-problems"
readonly LOCK_FILE="${PROBLEM_DIR}/.lock"

# Default values
SCENARIO=""
DURATION=60
CLEANUP=false
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ============================================================================
# UTILITIES
# ============================================================================

log_msg() {
    local level="$1"
    shift
    local msg="$*"
    
    case "$level" in
        OK)     echo -e "${GREEN}✓${NC} $msg" ;;
        WARN)   echo -e "${YELLOW}⚠${NC} $msg" ;;
        CRIT)   echo -e "${RED}✗${NC} $msg" ;;
        INFO)   echo -e "${BLUE}ℹ${NC} $msg" ;;
        DEBUG)  [ "$VERBOSE" = true ] && echo -e "${PURPLE}debug${NC} $msg" || true ;;
    esac
}

setup_environment() {
    if [ ! -d "$PROBLEM_DIR" ]; then
        mkdir -p "$PROBLEM_DIR"
        log_msg OK "Created problem directory: $PROBLEM_DIR"
    fi
}

cleanup_environment() {
    if [ -d "$PROBLEM_DIR" ]; then
        rm -rf "$PROBLEM_DIR"
        log_msg OK "Cleaned up problem directory"
    fi
}

show_help() {
    cat << EOF
${BLUE}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
Create controlled problems for troubleshooting practice

${BLUE}USAGE${NC}
    $SCRIPT_NAME [OPTIONS]

${BLUE}OPTIONS${NC}
    --scenario NAME     Scenario to generate (see list below)
    --duration SECS     How long to run the problem (default: 60)
    --cleanup           Remove all problems
    --verbose           Show detailed output
    --list              List available scenarios
    --help              Show this help

${BLUE}AVAILABLE SCENARIOS${NC}
    memory-leak         Simulate memory leak (allocate unreleased memory)
    disk-fill           Fill disk space (create large temporary files)
    cpu-spike           CPU spike (spawn intensive computation)
    zombie-fork         Create zombie processes
    service-crash       Make a service crash and restart loop
    port-conflict       Run service on already-used port
    high-io             Simulate high I/O load
    network-delay       Simulate network latency

${BLUE}EXAMPLES${NC}
    # Show all scenarios
    $SCRIPT_NAME --list

    # Create memory leak for 120 seconds
    $SCRIPT_NAME --scenario memory-leak --duration 120

    # Create disk fill (runs until manual stop)
    $SCRIPT_NAME --scenario disk-fill --verbose

    # Clean up all problems
    $SCRIPT_NAME --cleanup

${BLUE}WARNINGS${NC}
    ⚠ These scripts create actual system load
    ⚠ Run in lab environment only
    ⚠ Monitor system resources while running
    ⚠ Use Ctrl+C to stop
    ⚠ Manual cleanup may be needed

EOF
}

list_scenarios() {
    cat << EOF
${BLUE}Available Scenarios:${NC}

1. memory-leak
   Allocates memory continuously without releasing
   Good for learning: Memory monitoring, memory leak detection
   Commands to try: free -h, vmstat, ps aux, top

2. disk-fill
   Creates large files to fill filesystem
   Good for learning: Disk monitoring, disk usage analysis
   Commands to try: df -h, du -sh, find, locate culprits

3. cpu-spike
   Spawns CPU-intensive processes
   Good for learning: CPU monitoring, process management
   Commands to try: top, ps aux --sort=-%cpu, kill, nice

4. zombie-fork
   Creates zombie processes (unreaped children)
   Good for learning: Process tracking, cleanup
   Commands to try: ps aux, grep defunct, ppid investigation

5. service-crash
   Makes a service crash and restart continuously
   Good for learning: Service troubleshooting, logs, systemd
   Commands to try: systemctl status, journalctl, systemctl stop

6. port-conflict
   Runs service on port already in use
   Good for learning: Port finding, service binding
   Commands to try: netstat -tulpn, ss, lsof, fuser

7. high-io
   Simulates high disk I/O load
   Good for learning: I/O monitoring and analysis
   Commands to try: iostat, iotop, vmstat, vmstat -D

8. network-delay
   Simulates network latency (requires tc command)
   Good for learning: Network troubleshooting, latency detection
   Commands to try: ping, mtr, traceroute, ss -an

EOF
}

# ============================================================================
# SCENARIO IMPLEMENTATIONS
# ============================================================================

scenario_memory_leak() {
    log_msg WARN "Starting memory leak scenario..."
    log_msg INFO "This will allocate memory continuously"
    log_msg INFO "Try: watch free -h"
    echo ""
    
    # Memory leak simulator in pure bash
    local data=""
    local iteration=0
    
    while true; do
        # Allocate 10MB blocks
        data+=$(head -c 10485760 /dev/zero | tr '\0' 'x')
        iteration=$((iteration + 1))
        
        if (( iteration % 5 == 0 )); then
            local mem=$(free -h | awk 'NR==2 {print $3}')
            log_msg DEBUG "Iteration $iteration - Memory used: $mem"
        fi
        
        sleep 1
    done
}

scenario_disk_fill() {
    log_msg WARN "Starting disk fill scenario..."
    log_msg INFO "Creating files in $PROBLEM_DIR"
    log_msg INFO "Try: watch df -h"
    echo ""
    
    local count=0
    
    while true; do
        local file="${PROBLEM_DIR}/dummy_$(date +%s)_${count}.bin"
        dd if=/dev/zero of="$file" bs=1M count=50 2>/dev/null || break
        count=$((count + 1))
        
        local usage=$(df "$PROBLEM_DIR" | tail -1 | awk '{print $(NF-1)}')
        log_msg DEBUG "Created file $count - Disk usage: $usage"
        
        if [ "$usage" -gt 95 ]; then
            log_msg CRIT "Disk nearly full! Stopping."
            break
        fi
    done
}

scenario_cpu_spike() {
    log_msg WARN "Starting CPU spike scenario..."
    log_msg INFO "Spawning CPU-intensive processes"
    log_msg INFO "Try: top -p \$$ or ps aux --sort=-%cpu"
    echo ""
    
    local cpu_count=$(nproc)
    
    # Spawn one process per CPU core
    for ((i=1; i<=cpu_count; i++)); do
        (
            while true; do
                echo $((13 ** 13)) > /dev/null
            done
        ) &
        log_msg DEBUG "Spawned process $i"
    done
    
    log_msg INFO "CPU processes running (PIDs: $!)"
    log_msg WARN "Press Ctrl+C to stop"
    
    # Wait for interrupt
    wait
}

scenario_zombie_fork() {
    log_msg WARN "Starting zombie process scenario..."
    log_msg INFO "Creating parent process that won't wait for children"
    log_msg INFO "Try: ps aux | grep defunct"
    echo ""
    
    # Create a parent that ignores SIGCHLD
    trap "" SIGCHLD
    
    for ((i=1; i<=20; i++)); do
        (
            # Child process that exits immediately
            sleep 1
            exit 0
        ) &
        log_msg DEBUG "Spawned child process $i (PID: $!)"
    done
    
    log_msg WARN "Zombie processes created. Press Ctrl+C to exit parent."
    
    # Keep parent alive
    while true; do
        sleep 1
        local zombie_count=$(ps aux | grep -c " <defunct>" || echo 0)
        log_msg DEBUG "Current zombies: $zombie_count"
    done
}

scenario_service_crash() {
    log_msg WARN "Starting service crash scenario..."
    log_msg INFO "Creating crash-loop service"
    log_msg INFO "Try: systemctl status; journalctl -f"
    echo ""
    
    # This creates a test script that crashes
    local test_script="/tmp/crasher.sh"
    cat > "$test_script" << 'BASH'
#!/bin/bash
sleep 2
exit 1
BASH
    chmod +x "$test_script"
    
    # Create systemd service
    local service_file="/etc/systemd/system/crasher.service"
    if [ ! -f "$service_file" ]; then
        cat > "$service_file" << BASH
[Unit]
Description=Test Crashing Service
After=network.target

[Service]
Type=simple
ExecStart=$test_script
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
BASH
        log_msg WARN "Created service file: $service_file (requires root)"
    fi
    
    log_msg WARN "To enable: sudo systemctl enable --now crasher.service"
    log_msg WARN "To monitor: journalctl -f -u crasher.service"
}

scenario_port_conflict() {
    log_msg WARN "Starting port conflict scenario..."
    log_msg INFO "Binding to port 8000"
    echo ""
    
    # Simple server on port 8000
    (
        while true; do
            echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK" | \
                nc -l -p 8000 -q 1 2>/dev/null || break
        done
    ) &
    
    log_msg OK "Server listening on port 8000 (PID: $!)"
    log_msg INFO "Try: netstat -tulpn | grep 8000"
    log_msg INFO "Try: lsof -i :8000"
    log_msg WARN "Press Ctrl+C to stop"
    
    wait
}

scenario_high_io() {
    log_msg WARN "Starting high I/O scenario..."
    log_msg INFO "Performing intensive disk operations"
    log_msg INFO "Try: iostat -x 1 or iotop"
    echo ""
    
    while true; do
        # Create and read large files
        local file="${PROBLEM_DIR}/io_test_$$.bin"
        dd if=/dev/urandom of="$file" bs=4K count=1000 2>/dev/null
        dd if="$file" of=/dev/null bs=4K 2>/dev/null
        rm -f "$file"
        
        log_msg DEBUG "I/O cycle complete"
    done
}

scenario_network_delay() {
    log_msg WARN "Starting network delay scenario..."
    log_msg INFO "Requires: tc (traffic control) command"
    echo ""
    
    # Check if tc is available
    if ! command -v tc &> /dev/null; then
        log_msg CRIT "tc command not found. Install: sudo apt install iproute2"
        return 1
    fi
    
    log_msg WARN "This requires sudo. Attempting to set 500ms latency on lo interface..."
    
    if sudo tc qdisc add dev lo root netem delay 500ms 2>/dev/null; then
        log_msg OK "Added 500ms delay to loopback"
        log_msg INFO "Try: ping -c 5 127.0.0.1"
        log_msg WARN "To cleanup: sudo tc qdisc del dev lo root"
        
        sleep 30
        
        sudo tc qdisc del dev lo root 2>/dev/null || true
        log_msg OK "Cleaned up delay rules"
    else
        log_msg CRIT "Failed to add delay. May need sudo without password."
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --scenario)
                SCENARIO="$2"
                shift 2
                ;;
            --duration)
                DURATION="$2"
                shift 2
                ;;
            --cleanup)
                CLEANUP=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --list)
                list_scenarios
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    if [ "$CLEANUP" = true ]; then
        cleanup_environment
        exit 0
    fi
    
    if [ -z "$SCENARIO" ]; then
        log_msg CRIT "No scenario specified"
        show_help
        exit 1
    fi
    
    setup_environment
    
    echo ""
    log_msg INFO "Scenario: $SCENARIO"
    log_msg INFO "Duration: ${DURATION}s (if applicable)"
    echo ""
    
    case "$SCENARIO" in
        memory-leak)
            scenario_memory_leak
            ;;
        disk-fill)
            scenario_disk_fill
            ;;
        cpu-spike)
            scenario_cpu_spike
            ;;
        zombie-fork)
            scenario_zombie_fork
            ;;
        service-crash)
            scenario_service_crash
            ;;
        port-conflict)
            scenario_port_conflict
            ;;
        high-io)
            scenario_high_io
            ;;
        network-delay)
            scenario_network_delay
            ;;
        *)
            log_msg CRIT "Unknown scenario: $SCENARIO"
            list_scenarios
            exit 1
            ;;
    esac
}

main "$@"
