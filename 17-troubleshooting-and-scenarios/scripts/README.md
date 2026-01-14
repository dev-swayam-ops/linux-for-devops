# Scripts for Module 17: Troubleshooting and Scenarios

Production-ready diagnostic and problem-generation scripts for system troubleshooting practice and monitoring.

## Overview

This directory contains two essential tools:

1. **system-checker.sh** - Comprehensive system health diagnostic tool
2. **problem-generator.sh** - Controlled problem scenario generator for practice

Both scripts follow Linux best practices:
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -euo pipefail`
- Help sections: `--help` for all options
- Safe defaults: No destructive operations without confirmation
- Clear output: Color-coded status messages

## Script 1: system-checker.sh

### Purpose

Quick diagnostic assessment of system health with actionable alerts and insights. Ideal for:
- First-response health checks
- Continuous monitoring mode
- Exporting results for documentation
- Establishing baselines
- Detecting anomalies

### Installation

```bash
chmod +x system-checker.sh
```

### Quick Start

```bash
# Basic health check
./system-checker.sh

# Detailed analysis with top processes
./system-checker.sh --detailed

# Continuous monitoring (updates every 5 seconds)
./system-checker.sh --monitor

# Monitor with custom interval
./system-checker.sh --monitor --interval 10

# Export results to file
./system-checker.sh --detailed --export health-report.txt
```

### Features

**Core Health Checks:**
- Load Average (per-CPU normalized with configurable thresholds)
- Memory Usage (total, percentage, available)
- Disk Space (per filesystem, with thresholds)
- Swap Usage (if configured)
- I/O Wait (vmstat iostat analysis)
- Service Status (systemd failed services)
- Zombie Processes (unreaped children)
- Top Processes (by CPU and memory)

**Thresholds (Configurable):**
- Load Average: WARN=0.75, CRIT=0.90 (per core)
- Memory: WARN=75%, CRIT=90%
- Disk: WARN=80%, CRIT=95%
- Swap: WARN=30%
- I/O Wait: WARN=20%
- Zombie Processes: WARN=5+

**Output Modes:**
- Normal: Health check with brief results
- Detailed: Extended metrics and top processes
- Monitoring: Continuous real-time updates
- Export: Results to file for records

**Status Indicators:**
- ✓ (Green) = Healthy
- ⚠ (Yellow) = Warning
- ✗ (Red) = Critical
- ℹ (Blue) = Information

### Real-World Usage Scenarios

**Scenario 1: Server is running slowly**
```bash
# Get detailed baseline
./system-checker.sh --detailed --export baseline.txt

# Monitor for 5 minutes
./system-checker.sh --monitor --interval 5

# Look for:
# - Load average > 2 on single-core system
# - Memory > 80% used
# - I/O Wait > 20%
# - Disk > 90% full
# - Swap being used heavily
```

**Scenario 2: Service stopped unexpectedly**
```bash
# Quick health check
./system-checker.sh

# Check for:
# - Failed services count
# - Recent load spikes
# - Memory exhaustion
# - Disk full conditions
```

**Scenario 3: Memory leak suspected**
```bash
# Monitor memory trend
./system-checker.sh --monitor --interval 2

# Observe if memory percentage steadily increases
# Note which services are using most memory
# Cross-reference with top processes
```

**Scenario 4: Performance baseline**
```bash
# Record normal state
./system-checker.sh --detailed --export normal-state.txt

# Later, compare with:
./system-checker.sh --detailed --export problem-state.txt

# Diff the files to see what changed
diff normal-state.txt problem-state.txt
```

### Customizing Thresholds

Edit the CONFIGURATION section at the top of the script:

```bash
# Adjust alert thresholds
readonly LOAD_THRESHOLD_WARN=0.75      # Change based on CPU count
readonly MEM_THRESHOLD_WARN=75         # Adjust for your system
readonly DISK_THRESHOLD_WARN=80        # More aggressive monitoring
readonly ZOMBIE_COUNT_WARN=5           # Typical threshold
```

### Integration with Monitoring

**Cron job for regular checks:**
```bash
# Every 15 minutes during business hours
*/15 9-17 * * 1-5 /path/to/system-checker.sh --detailed --export /var/log/health-$(date +\%s).txt
```

**Real-time monitoring with watch:**
```bash
# Monitor updates every 3 seconds
watch -n 3 '/path/to/system-checker.sh'
```

**Combine with problem-generator for testing:**
```bash
# Terminal 1: Run problem
./problem-generator.sh --scenario memory-leak --verbose

# Terminal 2: Monitor the impact
./system-checker.sh --monitor --interval 2
```

### Troubleshooting the Script

**Problem: Command not found errors**
```bash
# Ensure all required tools are installed
sudo apt install sysstat dnsutils net-tools

# Check specific tool availability
which vmstat iostat ss lsof free df
```

**Problem: Permission denied for some checks**
```bash
# Some systemd commands may need sudo
sudo ./system-checker.sh --detailed

# Or configure passwordless sudo for specific commands
```

**Problem: Colors not showing**
```bash
# Force color output in non-terminal
./system-checker.sh | cat

# Or check terminal supports ANSI colors
echo -e "${RED}Test${NC}"
```

---

## Script 2: problem-generator.sh

### Purpose

Safely create controlled problem scenarios for hands-on troubleshooting practice. Allows learners to:
- Experience real system problems in a lab environment
- Practice diagnostic commands with realistic conditions
- Develop troubleshooting workflows
- Understand system behavior under stress

### Installation

```bash
chmod +x problem-generator.sh
```

### Quick Start

```bash
# List available scenarios
./problem-generator.sh --list

# Create memory leak scenario (60 seconds default)
./problem-generator.sh --scenario memory-leak

# Create disk fill scenario with verbose output
./problem-generator.sh --scenario disk-fill --verbose

# Stop after duration or with Ctrl+C
./problem-generator.sh --scenario cpu-spike --duration 120

# Clean up all generated problems
./problem-generator.sh --cleanup
```

### Available Scenarios

#### 1. memory-leak
**What it does:** Allocates memory continuously without releasing

**Learning objectives:**
- Monitor memory usage (free -h, vmstat)
- Detect memory growth patterns
- Identify process memory consumption
- Understand memory pressure and swapping

**Commands to try:**
```bash
# Monitor memory in real-time
watch free -h

# Track specific process
watch -n 1 'ps aux | grep problem-generator'

# Observe swap usage
watch vmstat 1

# Check detailed memory info
cat /proc/meminfo | head -10
```

**Expected behavior:**
- Memory used percentage increases steadily
- Swap usage increases as physical RAM fills
- Other processes may slow down

---

#### 2. disk-fill
**What it does:** Creates large temporary files to fill filesystem

**Learning objectives:**
- Monitor disk usage (df, du)
- Locate large files and heavy directories
- Clean up disk space safely
- Prevent disk-full emergencies

**Commands to try:**
```bash
# Monitor disk usage
watch df -h

# Find largest files
find /tmp/lab-problems -type f -exec ls -lh {} \; | sort -k5 -h

# Check directory sizes
du -sh /tmp/lab-problems/*

# Monitor usage trend
df /tmp | tail -1
```

**Expected behavior:**
- Disk usage percentage increases
- Free space decreases until critical
- Script stops at 95% full to prevent system issues

---

#### 3. cpu-spike
**What it does:** Spawns CPU-intensive processes (one per core)

**Learning objectives:**
- Monitor CPU usage and load average
- Process management and termination
- Understanding CPU affinity
- Load balancing concepts

**Commands to try:**
```bash
# View top CPU consumers
top -b -n 1 | head -15

# Sort by CPU usage
ps aux --sort=-%cpu | head

# Monitor load average
uptime
watch -n 1 uptime

# Kill all problem-generator processes
killall -9 problem-generator.sh
```

**Expected behavior:**
- Load average increases (1 per core)
- Multiple processes show high %CPU
- System becomes unresponsive if load exceeds cores
- Keyboard/mouse may lag

---

#### 4. zombie-fork
**What it does:** Creates parent process with unreaped child processes

**Learning objectives:**
- Understand process lifecycle and states
- Identify zombie processes
- Find parent processes
- Cleanup and recovery

**Commands to try:**
```bash
# List zombie processes
ps aux | grep -i defunct

# Find parent process
ps -o ppid= -p <zombie_pid>

# List children of parent
ps --ppid <parent_pid>

# View process tree
pstree -p | grep problem-generator

# Clean up zombies
kill -9 <parent_pid>
```

**Expected behavior:**
- Zombies appear with "<defunct>" in ps output
- Cannot be killed (they're already "dead")
- Only solution is to kill parent process
- Illustrates importance of signal handling

---

#### 5. service-crash
**What it does:** Creates systemd service that crashes and restarts

**Learning objectives:**
- Systemd service management
- Log analysis for failure reasons
- Service restart policies
- Debugging service failures

**Commands to try:**
```bash
# Check service status
sudo systemctl status crasher.service

# View service logs
journalctl -u crasher.service -f

# See restart count
systemctl show crasher.service -p NRestarts

# Stop the restart loop
sudo systemctl stop crasher.service

# Disable auto-restart
sudo systemctl disable crasher.service
```

**Expected behavior:**
- Service starts, crashes, restarts automatically
- Each crash logged with exit code 1
- Restart delay increases slightly (2 seconds in example)
- Systemd tracks restart count

---

#### 6. port-conflict
**What it does:** Binds a service to port 8000

**Learning objectives:**
- Find which process owns a port
- Port conflict resolution
- Network socket analysis
- Service binding issues

**Commands to try:**
```bash
# Find process using port
sudo netstat -tulpn | grep 8000

# Using ss (modern replacement)
ss -tulpn | grep 8000

# Find by filename
lsof -i :8000

# Identify by process
fuser 8000/tcp

# Try to connect
curl http://localhost:8000

# Port alternatives
netstat -tulpn | grep LISTEN
```

**Expected behavior:**
- Port shows as LISTEN state
- Process (problem-generator) listed as owner
- Attempts to start another service on 8000 fail
- Port becomes available when process stops

---

#### 7. high-io
**What it does:** Performs intensive disk read/write operations

**Learning objectives:**
- Monitor I/O activity
- Identify I/O bottlenecks
- Disk performance analysis
- Cache and buffer behavior

**Commands to try:**
```bash
# Real-time I/O monitoring
iotop -o

# I/O statistics
iostat -x 1

# Virtual memory stats including I/O
vmstat 1 10

# Monitor open files
lsof -p <pid> | grep REG

# Check disk performance
fio --name=sequential-read --filename=/tmp/test --rw=read --size=1G
```

**Expected behavior:**
- High read/write rates (MB/s)
- Elevated I/O wait time
- Disk utilization near 100%
- System may feel slow
- Top processes show high I/O

---

#### 8. network-delay
**What it does:** Simulates latency on loopback interface (requires tc)

**Learning objectives:**
- Network latency simulation
- Traffic control concepts
- Network troubleshooting with delays
- RTT and timeout detection

**Commands to try:**
```bash
# Measure latency
ping -c 5 127.0.0.1

# Show latency statistics
mtr localhost

# Test with curl
time curl http://localhost:8000

# Monitor network stats
netstat -s

# View traffic control rules
tc qdisc show dev lo
```

**Expected behavior:**
- Ping times increase (~500ms delay)
- Timeouts occur for services expecting fast response
- Applications may fail or hang
- Reveals dependency on low latency

---

### Usage Patterns

**Practice Pattern 1: Sequential Problem Solving**
```bash
# Terminal 1: Generate problem
./problem-generator.sh --scenario memory-leak --verbose

# Terminal 2: Diagnose using system-checker
./system-checker.sh --monitor

# Terminal 3: Use manual commands
watch free -h
ps aux --sort=-%mem | head
```

**Practice Pattern 2: Timed Challenges**
```bash
# Problem runs for 60 seconds (default)
./problem-generator.sh --scenario disk-fill

# Your challenge: Identify and clean up the files
# Commands to use:
# - du -sh /tmp/lab-problems/*
# - find /tmp/lab-problems -type f
# - rm /tmp/lab-problems/*
```

**Practice Pattern 3: Multi-Problem Scenario**
```bash
# Create multiple problems in sequence
./problem-generator.sh --scenario cpu-spike --duration 30 &
sleep 10
./problem-generator.sh --scenario memory-leak --duration 30 &
sleep 10
./problem-generator.sh --scenario disk-fill --duration 30 &

# Now troubleshoot all three simultaneously
./system-checker.sh --monitor --interval 2
```

**Practice Pattern 4: Monitoring Before/After**
```bash
# Baseline
./system-checker.sh --detailed --export before.txt

# Create problem
./problem-generator.sh --scenario high-io --verbose &

# Monitor impact
./system-checker.sh --monitor --interval 3

# Compare
diff before.txt after.txt
```

### Safety Considerations

**Running in Docker/VM:**
```bash
# Best practice: Run in isolated environment
# Prevents accidental data loss or system damage
docker run -it ubuntu:22.04 bash
# Inside container:
apt update && apt install -y sysstat net-tools
./problem-generator.sh --scenario disk-fill
```

**Resource Limits:**
```bash
# Prevent runaway resource consumption
ulimit -v 1000000  # Limit virtual memory to ~1GB
./problem-generator.sh --scenario memory-leak

ulimit -u 100      # Limit processes to 100
./problem-generator.sh --scenario zombie-fork
```

**Cleanup Guarantees:**
```bash
# Always cleanup when done
./problem-generator.sh --cleanup

# Or manual cleanup
rm -rf /tmp/lab-problems
sudo tc qdisc del dev lo root 2>/dev/null
killall -9 problem-generator.sh
sudo systemctl stop crasher.service 2>/dev/null
```

### Troubleshooting

**Problem: "nc: command not found" (port-conflict scenario)**
```bash
# Install netcat
sudo apt install netcat-openbsd
```

**Problem: "tc: No such file" (network-delay scenario)**
```bash
# Install traffic control utility
sudo apt install iproute2
```

**Problem: Memory leak scenario uses too much RAM**
```bash
# Set memory limit before running
ulimit -v 536870912  # 512MB limit
./problem-generator.sh --scenario memory-leak
```

**Problem: Can't kill processes**
```bash
# Use sudo for some scenarios
sudo ./problem-generator.sh --scenario zombie-fork

# Or force kill
sudo killall -9 problem-generator.sh
```

---

## Combined Workflow Example

Here's a realistic troubleshooting training scenario:

```bash
# Step 1: Establish baseline
./system-checker.sh --detailed --export baseline.txt
echo "=== BASELINE CAPTURED ==="

# Step 2: Create mysterious problem
./problem-generator.sh --scenario cpu-spike &
PROBLEM_PID=$!
echo "Problem generated with PID: $PROBLEM_PID"

# Step 3: User notices system slow
sleep 5
echo "=== SYSTEM SLOW DETECTED ==="

# Step 4: Run full diagnostic
./system-checker.sh --detailed --export problem-state.txt

# Step 5: Compare and analyze
diff baseline.txt problem-state.txt

# Step 6: Manual investigation
top -b -n 1 | head -20
ps aux --sort=-%cpu | head -10

# Step 7: Fix
killall problem-generator.sh

# Step 8: Verify recovery
sleep 5
./system-checker.sh
```

---

## Performance Characteristics

**system-checker.sh:**
- Runtime: 3-5 seconds for full check
- Memory usage: ~5-10 MB
- CPU impact: Minimal (< 1%)
- Safe to run frequently (every minute)

**problem-generator.sh:**
- Memory-leak: Allocates ~10MB every second
- Disk-fill: Creates 50MB files every iteration
- CPU-spike: Uses 100% CPU per core
- I/O: Generates 100+ MB/s I/O

---

## Integration with Monitoring Systems

**Prometheus-style export:**
```bash
# Extend system-checker to export Prometheus metrics
./system-checker.sh --export-prometheus metrics.txt
```

**Graphite/InfluxDB:**
```bash
# Schedule regular checks and send to monitoring
*/1 * * * * /path/to/system-checker.sh --detailed | /path/to/send-to-influx.sh
```

**Alerting:**
```bash
# Run check and alert if critical
./system-checker.sh 2>&1 | grep CRITICAL && \
  echo "Alert: Critical issue detected" | mail -s "System Alert" admin@example.com
```

---

## References

See the main module README and hands-on labs for:
- Detailed troubleshooting methodology
- Command reference and examples
- Real-world case studies
- Integration patterns

Related files:
- `../README.md` - Module overview
- `../01-theory.md` - Troubleshooting theory
- `../02-commands-cheatsheet.md` - Command reference
- `../03-hands-on-labs.md` - Hands-on exercises

---

**Last Updated:** 2024
**Version:** 1.0
**License:** Educational Use

