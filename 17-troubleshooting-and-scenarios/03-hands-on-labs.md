# Troubleshooting and Scenarios - Hands-On Labs

8 complete troubleshooting laboratories with real-world scenarios.

**Total Time:** ~5 hours (labs 1-8)

---

## Lab 1: Service Failure Diagnosis (45 minutes)

### Objective
Learn to diagnose and fix service failures systematically.

### Prerequisites
- Text editor
- Terminal access
- Installed: nginx (or similar web server)

### Setup

```bash
# Create lab directory
mkdir -p ~/troubleshooting-labs/lab1
cd ~/troubleshooting-labs/lab1

# Ensure nginx is installed
sudo apt update
sudo apt install -y nginx
```

### Scenario

You arrive at work and users report the website is down. The application team says "We didn't change anything!" Let's diagnose the problem.

### Step 1: Verify the Problem

```bash
# Try to access the service
curl http://localhost:80

# Expected output:
# curl: (7) Failed to connect to localhost port 80: Connection refused
```

### Step 2: Check Service Status

```bash
# Check if service is running
systemctl status nginx

# Expected output shows service is NOT running
# You should see: "inactive (dead)"
```

### Step 3: Check Logs

```bash
# View recent logs
sudo journalctl -u nginx -n 30

# Expected output shows error like:
# "Address already in use"
# or "permission denied"
# or "configuration error"
```

### Step 4: Try to Start Service

```bash
# Attempt to start
sudo systemctl start nginx

# Check result
sudo systemctl status nginx
```

### Step 5: If Still Failing - Check Configuration

```bash
# Validate nginx configuration
sudo nginx -t

# Expected output:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# If there's an error, it will show the line number
```

### Step 6: If Configuration is OK - Check Ports

```bash
# Find what's using port 80
sudo netstat -tulpn | grep :80
# or
sudo lsof -i :80

# Expected: Either nginx process or another application
```

### Step 7: Resolve Port Conflict (if applicable)

```bash
# If another service is using port 80:
sudo systemctl status conflicting-service

# Stop the conflicting service (if not needed)
sudo systemctl stop conflicting-service

# Or reconfigure nginx to use different port
# Edit: sudo nano /etc/nginx/sites-enabled/default
# Change: listen 80; to listen 8080;
# Then: sudo systemctl start nginx
```

### Step 8: Verify Fix

```bash
# Test connectivity
curl http://localhost:80
# or
curl http://localhost:8080  # if using different port

# Expected output: HTML response with "Welcome to nginx!"

# Check service is enabled for boot
sudo systemctl is-enabled nginx

# Enable if needed
sudo systemctl enable nginx
```

### Verification Checklist

- [ ] Identified the initial problem (service not running)
- [ ] Found the root cause (port conflict, config error, etc.)
- [ ] Fixed the issue
- [ ] Verified service is running
- [ ] Confirmed web access works
- [ ] Service will start on boot

### Root Cause Analysis

```
Symptom: Website down
  ↓
Investigation: Service not running
  ↓
Root Cause: [Port conflict, config error, crashed, etc.]
  ↓
Solution: [Fix specific cause]
  ↓
Prevention: [What could prevent this?]
```

### Cleanup

```bash
# Keep nginx running for next labs
sudo systemctl status nginx  # Verify still running
```

---

## Lab 2: High Memory Usage Investigation (40 minutes)

### Objective
Find memory leaks and identify what's consuming RAM.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab2
cd ~/troubleshooting-labs/lab2
```

### Scenario

Your monitoring system alerts: "Server memory at 85%". You need to find what's consuming memory and determine if it's normal.

### Step 1: Get Memory Overview

```bash
# Check total memory and usage
free -h

# Expected output shows:
# Total memory
# Used memory
# Available memory
# Used percentage

# Example:
#               total        used       free     shared buff/cache   available
# Mem:          15Gi        4.2Gi       2.1Gi      128Mi       8.6Gi        10Gi
```

### Step 2: Identify Memory Hogs

```bash
# Find processes using most memory
ps aux --sort=-%mem | head -10

# Expected output shows top 10 processes by memory percentage
```

### Step 3: Get Detailed Stats

```bash
# Show memory statistics
vmstat 1 5

# Key columns:
# swpd = swap used (high = memory pressure)
# free = free memory
# buff = buffer memory
# cache = cache memory

# Focus on:
# - Is swpd increasing? (memory leak)
# - Is wa (wait) high? (I/O caused by swapping)
```

### Step 4: Analyze Specific Process

```bash
# Monitor a process continuously
PID=1234  # Replace with actual PID from Step 2

# Watch memory growth
while true; do ps -p $PID -o pid,vsz,rss,comm; sleep 2; done

# Expected output shows:
# PID      VSZ     RSS     COMM
# 1234     1024000 512000  nginx

# If RSS keeps growing = memory leak
# If stays steady = normal operation
```

### Step 5: Check Swap Usage

```bash
# Show swap
free -h

# Show swap details
swapon -s

# Check if swap is being used heavily
vmstat 1 5 | grep -v "procs"
```

### Step 6: Check Cache Pressure

```bash
# Memory can be freed from cache if needed
# High cache is normal and OK

# Detailed memory breakdown
cat /proc/meminfo

# Key metrics:
# MemTotal = total RAM
# MemAvailable = can be allocated
# Cached = page cache (can be freed)
# Buffers = buffer cache (can be freed)
```

### Step 7: Take Action

**If memory is high but available is good:**
```bash
# This is normal - Linux uses cache effectively
echo "System is healthy - memory is being used efficiently"
```

**If available is low:**
```bash
# Find and stop memory hog
ps aux --sort=-%mem | head -5
sudo kill -15 PID  # Graceful kill

# Or restart service if applicable
sudo systemctl restart service-name
```

### Verification Checklist

- [ ] Checked total and available memory
- [ ] Identified top memory-using processes
- [ ] Checked for memory leaks (growing RSS)
- [ ] Verified swap usage is acceptable
- [ ] Took corrective action if needed

### Cleanup

```bash
# Nothing to clean up - testing was read-only
```

---

## Lab 3: Disk Space Crisis (35 minutes)

### Objective
Find what's consuming disk space and free it up.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab3
cd ~/troubleshooting-labs/lab3

# Create test scenario (simulate large log)
sudo dd if=/dev/zero of=/tmp/test-large-file.log bs=1M count=500 2>/dev/null
```

### Scenario

Alert: "Disk usage at 92% - critical!" Applications are failing because they can't write files.

### Step 1: Verify Disk Usage

```bash
# Check all filesystems
df -h

# Expected output shows high usage on one or more filesystems
```

### Step 2: Find What's Using Space

```bash
# Check root directory
du -sh /* | sort -rh

# Expected output:
# 4.2G /home
# 3.1G /var
# 1.8G /usr
# 256M /tmp
```

### Step 3: Drill Down

```bash
# Let's say /var is the culprit (common for logs)
du -sh /var/* | sort -rh

# Expected output shows largest directories in /var
# Usually /var/log or /var/cache
```

### Step 4: Find Large Files

```bash
# Find files larger than 100MB
find / -type f -size +100M 2>/dev/null

# Find files in /var/log larger than 100MB
find /var/log -type f -size +100M 2>/dev/null
```

### Step 5: Find Old Files

```bash
# Find logs older than 30 days
find /var/log -type f -mtime +30 2>/dev/null

# Find files older than 90 days to delete
find /var/log -type f -mtime +90 2>/dev/null

# Find compressed old logs
find /var/log -name "*.gz" -mtime +30 2>/dev/null
```

### Step 6: Clean Up

```bash
# Delete old logs (backup first!)
sudo rm -f /var/log/*.1
sudo rm -f /var/log/*.gz

# Or compress large logs
sudo gzip /var/log/large-logfile.log

# Or clean old application data
sudo rm -rf /tmp/*

# Clean package cache
sudo apt clean

# Clean package lists
sudo apt autoclean
```

### Step 7: Verify Space Freed

```bash
# Check disk usage again
df -h

# Should show more free space
```

### Step 8: Prevent Recurrence

```bash
# Check if logrotate is configured
cat /etc/logrotate.conf
ls /etc/logrotate.d/

# Verify log rotation is working
sudo logrotate -f /etc/logrotate.conf

# Check results
ls -lh /var/log/*.1
```

### Verification Checklist

- [ ] Verified disk is full
- [ ] Identified culprit directory
- [ ] Found large files
- [ ] Cleaned up space
- [ ] Verified space is now available
- [ ] Set up log rotation

### Cleanup

```bash
# Remove test file
sudo rm -f /tmp/test-large-file.log
```

---

## Lab 4: Port Conflict & Network Troubleshooting (40 minutes)

### Objective
Find and resolve port conflicts, test connectivity.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab4
cd ~/troubleshooting-labs/lab4

# Make sure some services are running
sudo systemctl start ssh
sudo systemctl start nginx
```

### Scenario

You need to start a new application that should listen on port 8080, but it fails saying "Address already in use". Find what's using it.

### Step 1: Find What's Using Port 8080

```bash
# Method 1: Using netstat
sudo netstat -tulpn | grep :8080

# Method 2: Using ss
sudo ss -tulpn | grep :8080

# Method 3: Using lsof
sudo lsof -i :8080

# Expected output: Process name and PID
# tcp  0  0 0.0.0.0:8080  0.0.0.0:*  LISTEN  1234/java
```

### Step 2: Check Common Ports

```bash
# What's listening on common ports?
sudo netstat -tulpn | grep LISTEN

# Expected output:
# tcp  0  0 0.0.0.0:22    0.0.0.0:*  LISTEN  1234/sshd
# tcp  0  0 0.0.0.0:80    0.0.0.0:*  LISTEN  5678/nginx
# tcp  0  0 0.0.0.0:443   0.0.0.0:*  LISTEN  5678/nginx
```

### Step 3: Check Specific Service Ports

```bash
# What ports does ssh use?
sudo lsof -i -s TCP:LISTEN | grep ssh

# What about nginx?
sudo lsof -i -s TCP:LISTEN | grep nginx
```

### Step 4: Test Connectivity to Local Service

```bash
# Test SSH (port 22)
curl -v telnet://localhost:22

# Test HTTP (port 80)
curl http://localhost:80

# Test HTTPS (port 443)
curl -k https://localhost:443

# Or use netcat
nc -zv localhost 22  # Is port 22 open?
nc -zv localhost 80  # Is port 80 open?
```

### Step 5: Test Connectivity to Remote

```bash
# Test connectivity to remote host
ping -c 4 8.8.8.8

# Expected output:
# 4 packets transmitted, 4 received, 0% packet loss

# Traceroute (if available)
traceroute -m 15 8.8.8.8
```

### Step 6: Check Routes

```bash
# Show routing table
ip route show

# Expected output shows default route
# default via 192.168.1.1 dev eth0
```

### Step 7: Check DNS Resolution

```bash
# Resolve hostname to IP
dig google.com

# Short format
dig google.com +short

# Reverse lookup
dig -x 8.8.8.8

# Query specific nameserver
dig @8.8.8.8 google.com
```

### Step 8: Test HTTP Service

```bash
# Test if web service is responding
curl -I http://localhost:80

# Expected output:
# HTTP/1.1 200 OK
# Server: nginx/1.18.0
```

### Verification Checklist

- [ ] Identified process using port
- [ ] Checked listening ports
- [ ] Tested local connectivity
- [ ] Tested remote connectivity
- [ ] Verified DNS resolution
- [ ] Confirmed HTTP service

### Solutions

**If port is in use by unneeded service:**
```bash
# Stop the service
sudo systemctl stop conflicting-service
```

**If port is in use by needed service:**
```bash
# Change your app to use different port
# Or change the other service to use different port
```

### Cleanup

```bash
# Ensure services are still running
sudo systemctl status nginx
sudo systemctl status ssh
```

---

## Lab 5: Process Investigation & Optimization (40 minutes)

### Objective
Analyze running processes and identify problematic ones.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab5
cd ~/troubleshooting-labs/lab5
```

### Scenario

Your monitoring dashboard shows high CPU usage. Find the culprit and take action.

### Step 1: Identify High CPU Processes

```bash
# Show top CPU consumers
ps aux --sort=-%cpu | head -10

# Expected output:
# USER  PID  %CPU %MEM   VSZ   RSS COMMAND
# root  1234  45.2  2.1  1024  512 nginx
```

### Step 2: Monitor Real-time

```bash
# Interactive monitoring (press 'P' to sort by CPU)
top

# Or non-interactive snapshot
top -b -n 1 | head -15
```

### Step 3: Check Zombie Processes

```bash
# Find zombie processes
ps aux | grep " <defunct>"

# or
ps aux | grep "Z "

# Expected: Should be none or very few

# Count them
ps aux | grep -c "defunct"
```

### Step 4: Check Process Tree

```bash
# Show process relationships
ps auxf

# Find parent of high-CPU process
ps auxf | grep -E "nginx|mysql|java"

# Trace back to see parent
```

### Step 5: Analyze System Calls

```bash
# For a high-CPU process, see what it's doing
PID=1234  # Use actual PID

# Show system calls (requires root)
sudo strace -p $PID -e trace=open,read,write,lseek

# Or count syscalls
sudo strace -c -p $PID
# Press Ctrl+C after a few seconds

# Expected output shows what syscalls are taking time
```

### Step 6: Check if Process is Healthy

```bash
# Monitor specific process
PID=1234

# Memory growth (sign of leak)
watch -n 1 'ps -p '$PID' -o pid,vsz,rss,comm,etime'

# CPU usage over time
while true; do ps -p $PID -o pid,%cpu,%mem,comm; sleep 1; done

# Interrupt with Ctrl+C
```

### Step 7: Check Process Limits

```bash
# Show process limits
PID=1234
cat /proc/$PID/limits

# Expected output shows:
# Limit                     Soft Limit           Hard Limit           Units     
# Max cpu time              unlimited            unlimited            seconds   
# Max open files            1024                 4096                 files    
```

### Step 8: Take Action

**If process is healthy but CPU load is normal:**
```bash
echo "High CPU usage is normal for this workload"
```

**If process is stuck or misbehaving:**
```bash
# Stop the process
sudo kill -15 PID  # Graceful
sudo kill -9 PID   # Force if needed

# Restart service
sudo systemctl restart service-name
```

### Verification Checklist

- [ ] Identified high-CPU process
- [ ] Checked for zombie processes
- [ ] Analyzed system calls
- [ ] Monitored for issues
- [ ] Took corrective action if needed

### Cleanup

```bash
# Nothing to clean up
```

---

## Lab 6: Log Analysis Deep Dive (45 minutes)

### Objective
Find issues in logs and extract useful information.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab6
cd ~/troubleshooting-labs/lab6

# Create sample application logs for analysis
cat > sample.log << 'EOF'
2024-01-15 10:00:01 INFO Server started
2024-01-15 10:00:02 INFO Listening on port 8080
2024-01-15 10:00:05 INFO Request from 192.168.1.10
2024-01-15 10:00:06 INFO Response: 200 OK
2024-01-15 10:00:07 INFO Request from 192.168.1.11
2024-01-15 10:00:08 ERROR Connection timeout from 192.168.1.11
2024-01-15 10:00:09 WARN Retrying connection...
2024-01-15 10:00:10 ERROR Connection timeout from 192.168.1.11
2024-01-15 10:00:11 ERROR Database connection failed
2024-01-15 10:00:12 ERROR Query timeout: SELECT * FROM users WHERE id=123
2024-01-15 10:00:13 WARN Falling back to cache
2024-01-15 10:00:15 ERROR Request failed: 500 Internal Server Error
2024-01-15 10:00:16 INFO Request from 192.168.1.12
2024-01-15 10:00:17 INFO Response: 200 OK
2024-01-15 10:00:20 ERROR Out of memory error
2024-01-15 10:00:21 ERROR Service shutting down
EOF
```

### Step 1: View Logs

```bash
# View full log
cat sample.log

# View last 10 lines
tail -10 sample.log

# View with line numbers
cat -n sample.log

# Follow in real-time (if log is being written)
tail -f sample.log
```

### Step 2: Count Issues

```bash
# Count errors
grep -c "ERROR" sample.log

# Count warnings
grep -c "WARN" sample.log

# Count by level
echo "INFO: $(grep -c "INFO" sample.log)"
echo "WARN: $(grep -c "WARN" sample.log)"
echo "ERROR: $(grep -c "ERROR" sample.log)"
```

### Step 3: Find Problems

```bash
# Show only errors
grep "ERROR" sample.log

# Show only warnings and errors
grep "ERROR\|WARN" sample.log

# Show errors with context (2 lines before and after)
grep -C 2 "ERROR" sample.log
```

### Step 4: Find Related Events

```bash
# Show all events involving IP 192.168.1.11
grep "192.168.1.11" sample.log

# Show all database-related events
grep -i "database\|query" sample.log
```

### Step 5: Time Range Analysis

```bash
# Show events from specific time
grep "10:00:0[8-9]" sample.log

# Show events in range
grep "10:00:0[5-9]\|10:00:1[0-5]" sample.log
```

### Step 6: Extract Useful Data

```bash
# Extract IP addresses
grep "Request from" sample.log | grep -o "[0-9.]*$"

# Extract status codes
grep "Response:" sample.log | grep -o "[0-9][0-9][0-9]"

# Extract error types
grep "ERROR" sample.log | cut -d: -f3
```

### Step 7: Statistical Analysis

```bash
# Count errors by type
grep "ERROR" sample.log | cut -d: -f2 | cut -d' ' -f2 | sort | uniq -c

# Find most common issues
grep "ERROR" sample.log | grep -o "Connection timeout\|Query timeout\|Out of memory" | sort | uniq -c
```

### Step 8: Follow Problem Evolution

```bash
# Trace a specific problem timeline
echo "=== Timeline of Database Issue ==="
grep -n "database\|Database\|Query\|Connection" sample.log | tail -5

# Show progression
echo ""
echo "=== Before Issue ===" 
head -6 sample.log
echo ""
echo "=== Issue Starts ===" 
grep -n "ERROR" sample.log | head -3
echo ""
echo "=== Recovery ===" 
tail -3 sample.log
```

### Verification Checklist

- [ ] Viewed logs in various ways
- [ ] Counted issues by type
- [ ] Found related events
- [ ] Analyzed time ranges
- [ ] Extracted key data
- [ ] Identified problem timeline

### Real Application

**Check systemd logs:**
```bash
journalctl -u nginx -n 50
journalctl -p err
journalctl --since "1 hour ago"
```

### Cleanup

```bash
# Clean up test file
rm sample.log
```

---

## Lab 7: System Performance Baseline (50 minutes)

### Objective
Establish normal baseline and detect deviations.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab7
cd ~/troubleshooting-labs/lab7
```

### Step 1: Create Baseline Script

```bash
cat > baseline.sh << 'EOF'
#!/bin/bash
# System Baseline Capture

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
OUTPUT="baseline_$TIMESTAMP.txt"

{
    echo "=== SYSTEM BASELINE ==="
    echo "Captured at: $(date)"
    echo ""
    
    echo "=== LOAD AVERAGE ==="
    uptime
    echo ""
    
    echo "=== MEMORY ==="
    free -h
    echo ""
    
    echo "=== DISK ==="
    df -h
    echo ""
    
    echo "=== CPU CORES ==="
    nproc
    echo ""
    
    echo "=== PROCESSES ==="
    ps aux | wc -l
    echo ""
    
    echo "=== TOP PROCESSES BY CPU ==="
    ps aux --sort=-%cpu | head -10
    echo ""
    
    echo "=== TOP PROCESSES BY MEMORY ==="
    ps aux --sort=-%mem | head -10
    echo ""
    
    echo "=== OPEN FILES ==="
    lsof | wc -l
    echo ""
    
    echo "=== NETWORK CONNECTIONS ==="
    ss -an | wc -l
    echo ""
    
    echo "=== LISTENING PORTS ==="
    ss -tulpn | grep LISTEN
    echo ""
    
    echo "=== VIRTUAL MEMORY ==="
    vmstat 1 2 | tail -1
    
} > "$OUTPUT"

echo "Baseline saved to: $OUTPUT"
```

### Step 2: Run Baseline

```bash
bash baseline.sh

# View output
cat baseline_*.txt
```

### Step 3: Capture Extended Metrics

```bash
# CPU and I/O baseline
iostat -x 1 5 > io-baseline.txt

# Virtual memory
vmstat 1 10 > vm-baseline.txt

# Network baseline
ss -an | head -20 > net-baseline.txt

# Process list
ps auxww > ps-baseline.txt
```

### Step 4: Identify Normal Ranges

```bash
# From baseline, note:
echo "Normal Load: $(uptime | grep -o 'load average.*')"
echo "Normal Memory Available: $(free -h | grep Mem | awk '{print $7}')"
echo "Normal Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
echo "Normal Process Count: $(ps aux | wc -l)"
```

### Step 5: Create Monitoring Script

```bash
cat > monitor.sh << 'EOF'
#!/bin/bash
# Compare current to baseline

echo "=== CURRENT STATE ==="
uptime
free -h | grep Mem
df -h / | tail -1
echo "Processes: $(ps aux | wc -l)"

echo ""
echo "=== DEVIATIONS FROM BASELINE ==="

# Load average - normal is < 2 per CPU
LOAD=$(uptime | grep -oP '(?<=load average: )[0-9.]+' | head -1)
CPU_COUNT=$(nproc)
THRESHOLD=$(echo "$CPU_COUNT * 2" | bc)

if (( $(echo "$LOAD > $THRESHOLD" | bc -l) )); then
    echo "WARNING: Load is high ($LOAD, expected < $THRESHOLD)"
fi

# Memory - normal is < 80%
MEM_PERCENT=$(free | awk 'NR==2 {print int($3/$2*100)}')
if [ $MEM_PERCENT -gt 80 ]; then
    echo "WARNING: Memory usage is high ($MEM_PERCENT%)"
fi

# Disk - normal is < 80%
DISK_PERCENT=$(df / | tail -1 | awk '{print int($5)}')
if [ $DISK_PERCENT -gt 80 ]; then
    echo "WARNING: Disk usage is high ($DISK_PERCENT%)"
fi

echo "All checks completed"
EOF

chmod +x monitor.sh
bash monitor.sh
```

### Step 6: Continuous Monitoring

```bash
# Monitor in real-time
watch -n 5 'echo "=== Load ==="; uptime; echo "=== Memory ==="; free -h | grep Mem; echo "=== Disk ==="; df -h /'

# Or create custom dashboard
while true; do
    clear
    echo "=== SYSTEM MONITOR (Ctrl+C to stop) ==="
    date
    uptime
    free -h
    df -h /
    sleep 5
done
```

### Step 7: Compare Baseline

```bash
# Create new snapshot
bash baseline.sh

# Compare to old baseline
diff baseline_2024-01-15_10-00-00.txt baseline_2024-01-15_10-15-00.txt

# Or create comparison script
echo "Baseline 1: $(tail -1 baseline_2024-01-15_10-00-00.txt)"
echo "Baseline 2: $(tail -1 baseline_2024-01-15_10-15-00.txt)"
```

### Verification Checklist

- [ ] Created baseline capture script
- [ ] Captured initial baseline
- [ ] Identified normal ranges
- [ ] Created monitoring script
- [ ] Set up continuous monitoring
- [ ] Can detect deviations

### Real-World Application

```bash
# Set up cron to capture daily baseline
0 2 * * * /home/user/troubleshooting-labs/lab7/baseline.sh

# And weekly comparison
0 3 * * 0 diff /home/user/baselines/baseline_last.txt $(ls -t /home/user/baselines/baseline_*.txt | head -1)
```

### Cleanup

```bash
# Keep baselines for reference
ls -la baseline*.txt
```

---

## Lab 8: Troubleshooting Workflow - Integration Lab (60 minutes)

### Objective
Apply all techniques to solve a complex, realistic problem.

### Setup

```bash
mkdir -p ~/troubleshooting-labs/lab8
cd ~/troubleshooting-labs/lab8
```

### Complex Scenario

You've been paged during the night: "Production web server is responding slowly to requests. Occasional 503 errors. The application team says 'We didn't change anything!'"

Your job: Find and fix the problem in 1 hour.

### Step 1: Initial Assessment (5 min)

```bash
# Quick health check
echo "=== INITIAL ASSESSMENT ===" > investigation.log
date >> investigation.log
echo "" >> investigation.log

echo "Load:" >> investigation.log
uptime >> investigation.log

echo "Memory:" >> investigation.log
free -h >> investigation.log

echo "Disk:" >> investigation.log
df -h / >> investigation.log

echo "Services:" >> investigation.log
systemctl --no-pager list-units --type=service --state=running >> investigation.log

cat investigation.log
```

### Step 2: Check Service Availability (5 min)

```bash
# Test web service
echo "" >> investigation.log
echo "=== SERVICE TEST ===" >> investigation.log

curl -I http://localhost:80 >> investigation.log 2>&1
curl -I http://localhost:3000 >> investigation.log 2>&1  # If app server

echo "HTTP response status captured"
```

### Step 3: Check Logs for Errors (10 min)

```bash
# System logs
echo "" >> investigation.log
echo "=== SYSTEM LOGS ===" >> investigation.log
journalctl -p err -n 30 >> investigation.log 2>&1

# Web server logs
echo "" >> investigation.log
echo "=== WEB SERVER ERRORS ===" >> investigation.log
sudo tail -50 /var/log/nginx/error.log >> investigation.log 2>&1

# Application logs (if exists)
echo "" >> investigation.log
echo "=== APPLICATION LOGS ===" >> investigation.log
if [ -f /var/log/app/error.log ]; then
    tail -50 /var/log/app/error.log >> investigation.log 2>&1
fi

grep -i "error\|fail\|timeout\|refused" investigation.log
```

### Step 4: Identify Resource Bottleneck (10 min)

```bash
# Check CPU
echo "" >> investigation.log
echo "=== CPU ANALYSIS ===" >> investigation.log
ps aux --sort=-%cpu | head -10 >> investigation.log
top -b -n 1 | head -20 >> investigation.log 2>&1

# Check memory
echo "" >> investigation.log
echo "=== MEMORY ANALYSIS ===" >> investigation.log
ps aux --sort=-%mem | head -10 >> investigation.log
vmstat 1 5 >> investigation.log

# Check I/O
echo "" >> investigation.log
echo "=== I/O ANALYSIS ===" >> investigation.log
iostat -x 1 3 >> investigation.log 2>&1
```

### Step 5: Check Connectivity (5 min)

```bash
# Network status
echo "" >> investigation.log
echo "=== NETWORK STATUS ===" >> investigation.log

# Check if ports are listening
netstat -tulpn | grep LISTEN >> investigation.log 2>&1

# Check for connection issues
netstat -an | grep TIME_WAIT | wc -l >> investigation.log
echo "TIME_WAIT connections: $(netstat -an 2>/dev/null | grep TIME_WAIT | wc -l)"

# Check for connection limits
ulimit -n >> investigation.log
```

### Step 6: Root Cause Analysis (15 min)

```bash
# Based on findings, determine cause
echo "" >> investigation.log
echo "=== ROOT CAUSE ANALYSIS ===" >> investigation.log

# Possible causes and checks:
# 1. High CPU - what process?
if [ $(top -b -n 1 | head -2 | tail -1 | awk '{print $3}') -gt 80 ]; then
    echo "HIGH CPU DETECTED" >> investigation.log
    ps aux --sort=-%cpu | head -5 >> investigation.log
fi

# 2. Memory pressure - is swap being used?
SWAP=$(free | grep Swap | awk '{print $3}')
if [ $SWAP -gt 0 ]; then
    echo "SWAP USAGE DETECTED: $SWAP KB" >> investigation.log
fi

# 3. Disk bottleneck - check I/O wait
IO_WAIT=$(vmstat 1 2 | tail -1 | awk '{print $NF}')
echo "I/O Wait: $IO_WAIT" >> investigation.log

# 4. Service failure - what services are down?
echo "Failed services:" >> investigation.log
systemctl --no-pager list-units --type=service --state=failed --no-legend >> investigation.log
```

### Step 7: Implement Fix (15 min)

```bash
# Depending on root cause:

# If high CPU process:
# echo "Stopping process: $PID"
# sudo kill -15 PID

# If disk full:
# echo "Cleaning logs"
# sudo rm -f /var/log/*.old
# sudo apt clean

# If service failed:
# echo "Restarting service"
# sudo systemctl restart service-name

# If memory pressure:
# echo "Restarting application"
# sudo systemctl restart app-service

echo "Fix implemented at: $(date)" >> investigation.log
```

### Step 8: Verify Solution (5 min)

```bash
echo "" >> investigation.log
echo "=== POST-FIX VERIFICATION ===" >> investigation.log
date >> investigation.log

# Test service is responding
for i in {1..5}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/)
    echo "Request $i: HTTP $response" >> investigation.log
    sleep 1
done

# Check metrics are normal
uptime >> investigation.log
free -h >> investigation.log
df -h / >> investigation.log

echo "Service is $(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/ 2>/dev/null)"
```

### Step 9: Document Findings

```bash
# Show complete investigation
echo ""
echo "=== COMPLETE INVESTIGATION REPORT ==="
cat investigation.log

# Summary
echo ""
echo "=== SUMMARY ==="
echo "Problem: Web service responding slowly"
echo "Root Cause: [From investigation]"
echo "Solution: [What was fixed]"
echo "Prevention: [How to prevent recurrence]"
```

### Verification Checklist

- [ ] Identified the problem
- [ ] Found root cause
- [ ] Implemented fix
- [ ] Verified service is working
- [ ] Documented findings
- [ ] Identified prevention measures

### Prevention & Alerts

```bash
# Set up monitoring to catch early
echo "0 * * * * /usr/local/bin/check-health.sh" | crontab -

# Or use nagios/prometheus for continuous monitoring
# Set up alerts for:
# - CPU > 80%
# - Memory > 85%
# - Disk > 90%
# - Service down
# - High I/O wait
```

### Cleanup

```bash
# Keep investigation log for postmortem
cat investigation.log

# Archive findings
gzip investigation.log
mv investigation.log.gz ~/troubleshooting-labs/case_$(date +%Y%m%d).log.gz
```

---

## Summary

**8 Labs Completed:**

1. ✓ Service failure diagnosis
2. ✓ Memory usage investigation
3. ✓ Disk space crisis
4. ✓ Port conflicts & networking
5. ✓ Process analysis
6. ✓ Log analysis
7. ✓ Performance baseline
8. ✓ Integration troubleshooting

**Skills Mastered:**

- Systematic troubleshooting methodology
- Using diagnostic tools (ps, top, netstat, journalctl)
- Reading and interpreting logs
- Identifying bottlenecks
- Network diagnosis
- Performance analysis
- Incident documentation

---

**Next:** [scripts/](scripts/) - Diagnostic automation tools
