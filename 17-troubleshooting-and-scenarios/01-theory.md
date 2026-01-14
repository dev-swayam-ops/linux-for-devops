# Troubleshooting and Scenarios - Theory

Core concepts and methodology for systematic Linux troubleshooting.

---

## Section 1: Troubleshooting Methodology

### What is Troubleshooting?

Troubleshooting is the process of systematically identifying and solving problems. It's not guessing or random trial-and-error; it's a **scientific method** applied to system problems.

```
Report Problem
     ↓
Gather Facts
     ↓
Form Hypothesis
     ↓
Test Hypothesis
     ↓
Fix Problem
     ↓
Verify Solution
     ↓
Document Learning
```

### Core Principles

**1. Gather Information First**

Never try to fix something you don't understand. Start by collecting data:
- What's the actual symptom?
- When did it start?
- What changed recently?
- Who reported it?
- What's the business impact?

**2. Check Logs First**

Logs contain 90% of the answer. Always check:
- System logs (journalctl)
- Application logs
- Web server logs
- Authentication logs
- Kernel messages (dmesg)

**3. One Change at a Time**

If you change multiple things, you won't know what fixed it. Test systematically.

**4. Understand the Baseline**

You can't identify abnormal without knowing normal:
- What's the normal CPU usage?
- What's the expected memory usage?
- How many processes normally run?
- What's the typical load?

**5. Root Cause, Not Symptoms**

A restart might fix a service, but if it crashes again, you fixed the symptom not the cause.

Example:
- Symptom: Web server won't respond
- Surface fix: Restart the service
- Root cause: Out of disk space (logs filling up)
- Real fix: Set up log rotation

---

## Section 2: Diagnostic Tools

### Process Monitoring

**ps - List Processes**

```bash
# List all processes with details
ps aux

# Show memory hogs
ps aux --sort=-%mem | head -5

# Show CPU hogs
ps aux --sort=-%cpu | head -5

# Find process by name
ps aux | grep nginx

# Show process tree
ps auxf
```

**top - Real-time Monitor**

```bash
# Basic top
top

# Show specific process
top -p 1234

# Batch mode (non-interactive)
top -b -n 1

# Sort by memory
top -o %MEM
```

**htop - Enhanced Monitor**

```bash
# Install: sudo apt install htop
htop

# Better visualization than top
# Shows memory in real units
# Shows multi-core processes
# More interactive
```

### Network Diagnostics

**netstat - Network Statistics**

```bash
# Show listening ports
netstat -tulpn

# Show connections
netstat -an | grep ESTABLISHED

# Show statistics
netstat -s

# Find which process owns a port
netstat -tulpn | grep :8080
```

**ss - Socket Statistics (Modern)**

```bash
# Show listening sockets
ss -tulpn

# Show all connections
ss -an

# Show statistics
ss -s

# Monitor in real-time
ss -tulpn | watch -n 1
```

**Connectivity Tests**

```bash
# Ping (test if host is reachable)
ping -c 4 8.8.8.8

# Traceroute (show path to host)
traceroute google.com
traceroute -4 google.com  # IPv4 only

# Check DNS resolution
dig google.com
nslookup google.com
host google.com

# Test HTTP connectivity
curl -I http://example.com
curl -v http://example.com

# Test port connectivity
nc -zv host.example.com 80
telnet host.example.com 80
```

### Log Analysis

**journalctl - Systemd Logs**

```bash
# Show recent logs
journalctl

# Follow in real-time
journalctl -f

# Show last 50 lines
journalctl -n 50

# Show errors only
journalctl -p err

# Specific service
journalctl -u nginx.service

# Since time
journalctl --since "2024-01-15 10:00:00"

# Show boot messages
journalctl -b

# Boot before last
journalctl -b -1
```

**grep - Pattern Matching**

```bash
# Find errors in syslog
grep -i error /var/log/syslog

# Find pattern with context
grep -i error /var/log/syslog -A 5 -B 5

# Count occurrences
grep -i error /var/log/syslog | wc -l

# Find multiple patterns
grep -E "error|fail|warn" /var/log/syslog
```

**dmesg - Kernel Messages**

```bash
# Show kernel buffer
dmesg

# Show last 30 lines
dmesg | tail -30

# Follow new messages
dmesg --follow

# Show hardware errors
dmesg | grep -i hardware
```

### Resource Monitoring

**free - Memory Usage**

```bash
# Show memory in human-readable format
free -h

# Show memory in MB
free -m

# Continuous monitoring
watch -n 1 free -h

# Show memory breakdown
cat /proc/meminfo
```

**df - Disk Space**

```bash
# Show disk usage
df -h

# Show inodes
df -i

# Show specific filesystem
df -h /

# Find filesystem
df /path/to/file
```

**du - Directory Size**

```bash
# Show directory size
du -sh /home/user

# Show all subdirectories
du -sh /home/user/*

# Top 10 largest
du -sh /* | sort -rh | head -10

# Find large files
find / -type f -size +100M
```

**iostat - I/O Statistics**

```bash
# Show I/O stats
iostat -x 1 5

# Key metrics:
# util% = utilization percentage
# r/s = read requests per second
# w/s = write requests per second
# rMB/s = read throughput
# wMB/s = write throughput
```

**vmstat - Virtual Memory**

```bash
# Show virtual memory stats
vmstat 1 10

# Key metrics:
# r = runnable processes
# b = blocked processes
# wa = I/O wait
# us = user CPU
# sy = system CPU
# id = idle CPU
```

### Process Tracing

**strace - System Call Trace**

```bash
# Trace system calls
strace command

# Show only write syscalls
strace -e write command

# Trace open files
strace -e open command

# Trace by PID
strace -p 1234

# Show time spent in syscalls
strace -c command
```

**lsof - List Open Files**

```bash
# List all open files
lsof

# Show by process
lsof -p 1234

# Show by user
lsof -u username

# Show network connections
lsof -i

# Show specific port
lsof -i :8080

# Find deleted files still open (disk space leak)
lsof | grep deleted
```

---

## Section 3: Common Problem Scenarios

### Scenario 1: Service Won't Start

**Symptoms:**
- Service fails to start
- `systemctl start service` returns error
- Error message in systemctl output

**Diagnosis Steps:**

```bash
# 1. Check service status
systemctl status nginx

# 2. Check service logs
journalctl -u nginx -n 50

# 3. Try to run service manually
/usr/sbin/nginx

# 4. Check configuration
nginx -t  # for nginx

# 5. Check dependencies
systemctl show -p Requires nginx

# 6. Check if port is in use
netstat -tulpn | grep :80
```

**Common Causes:**
- Port already in use
- Configuration error
- Missing dependencies
- Insufficient permissions
- File permissions wrong

---

### Scenario 2: System Running Slow

**Symptoms:**
- High load average
- SSH slowdown
- Web pages slow
- Commands take a long time

**Diagnosis Steps:**

```bash
# 1. Check load average
uptime
cat /proc/loadavg

# 2. Check what's using CPU
top -b -n 1 | head -20

# 3. Check disk I/O
iostat -x 1 5

# 4. Check memory pressure
free -h
vmstat 1 5

# 5. Check for context switching
vmstat 1 5 | grep cs

# 6. Check for disk bottleneck
iotop
```

**Likely Causes:**
- High CPU usage (find process with: top)
- Memory pressure (find with: free, top)
- I/O bottleneck (find with: iostat, iotop)
- Context switching (check vmstat)

---

### Scenario 3: Disk Full

**Symptoms:**
- "No space left on device" error
- Cannot write files
- Applications fail

**Diagnosis Steps:**

```bash
# 1. Verify disk is full
df -h

# 2. Find what's using space
du -sh /home/* /var/* /opt/*

# 3. Find large files
find / -type f -size +1G

# 4. Find old logs
find /var/log -name "*.log" -mtime +30

# 5. Check inode usage (if df shows full but du doesn't)
df -i
```

**Common Causes:**
- Large log files
- Core dumps
- Package caches
- Old backups
- Temporary files

---

### Scenario 4: High Memory Usage

**Symptoms:**
- OOM killer activates
- System gets slow
- Swapping occurs
- `free` shows little available memory

**Diagnosis Steps:**

```bash
# 1. Check total memory and usage
free -h

# 2. Find memory hogs
ps aux --sort=-%mem | head -10

# 3. Check swap usage
free -h

# 4. Check cache/buffer pressure
vmstat 1 5

# 5. Check if OOM killer was invoked
dmesg | grep "Out of memory"
```

**Common Causes:**
- Memory leak in application
- Too many processes
- Cache growing unbounded
- Database buffer pool too large

---

### Scenario 5: Port in Use

**Symptoms:**
- Cannot start service (address already in use)
- Port conflict error
- Cannot bind to port

**Diagnosis Steps:**

```bash
# 1. Find what's using the port
netstat -tulpn | grep :8080
ss -tulpn | grep :8080

# 2. Get more details about the process
ps aux | grep [PID]

# 3. Check if it's supposed to be running
systemctl status service-name

# 4. Find zombie processes (might still hold port)
ps aux | grep defunct
```

**Solutions:**
- Stop the existing service
- Use a different port
- Check for zombie processes
- Restart the system if needed

---

### Scenario 6: Network Unreachable

**Symptoms:**
- Cannot connect to remote host
- Network timeouts
- DNS not resolving
- Can't reach default gateway

**Diagnosis Steps:**

```bash
# 1. Check interface status
ip link show
ip addr show

# 2. Test local connectivity
ping 127.0.0.1
ping gateway_IP

# 3. Test remote connectivity
ping -c 4 8.8.8.8

# 4. Check DNS resolution
dig google.com
nslookup google.com

# 5. Check routing table
ip route show
route -n

# 6. Test application layer
curl -v http://remote.host
telnet remote.host 80
```

**Common Causes:**
- Interface down
- IP misconfiguration
- Gateway unreachable
- DNS failure
- Firewall blocking
- Routing issue

---

### Scenario 7: Process Crashes

**Symptoms:**
- Process exits unexpectedly
- Segmentation fault
- Service keeps restarting
- Core dump

**Diagnosis Steps:**

```bash
# 1. Check recent errors
journalctl -e -n 50

# 2. Look for core dumps
dmesg | tail -20

# 3. Check system limits
ulimit -a

# 4. Trace the process to see where it fails
strace process-name

# 5. Check available memory
free -h

# 6. Check if it's OOM killer
dmesg | grep "Out of memory"
```

**Common Causes:**
- Segmentation fault (memory corruption)
- Out of memory
- Uncaught exception
- Stack overflow
- Signal received (SIGTERM, SIGKILL)

---

### Scenario 8: Login Failures

**Symptoms:**
- Cannot SSH to host
- sudo fails
- Password authentication fails
- Permission denied

**Diagnosis Steps:**

```bash
# 1. Check SSH service is running
systemctl status ssh

# 2. Check SSH logs
journalctl -u ssh -n 50

# 3. Verify SSH configuration
sshd -t  # Test config syntax

# 4. Check SSH listening
netstat -tulpn | grep :22

# 5. Check user exists
getent passwd username

# 6. Check user permissions
groups username

# 7. Test SSH connection with verbose output
ssh -vvv user@host
```

**Common Causes:**
- SSH service not running
- SSH config syntax error
- User doesn't exist
- Wrong permissions (700 on .ssh)
- Key authentication issue
- SELinux/AppArmor blocking

---

## Section 4: Log Analysis Techniques

### Where Are the Logs?

**System Logs (Systemd):**
```bash
journalctl              # All logs
journalctl -u service   # Service logs
journalctl -b           # This boot only
```

**Application Logs:**
```bash
/var/log/syslog         # General system
/var/log/auth.log       # Authentication
/var/log/kern.log       # Kernel
/var/log/nginx/         # Web server
/var/log/mysql/         # Database
/var/log/apache2/       # Apache
```

### Log Format Understanding

Most Linux logs follow this pattern:
```
Timestamp  Hostname Service[PID]: Message
```

Example:
```
Jan 15 10:30:45 webserver nginx[1234]: Connection refused (111)
                                      ↑            ↑              ↑
                                   Service      Error         Details
```

### Extracting Key Information

**Find errors:**
```bash
grep -i "error\|fail\|refused\|denied" /var/log/syslog
```

**Find by time range:**
```bash
grep "10:30:" /var/log/syslog
```

**Find related entries:**
```bash
# Find entries with PID
grep "\[1234\]" /var/log/syslog
```

**Count problems:**
```bash
grep -i "error" /var/log/syslog | wc -l
```

---

## Section 5: Performance Monitoring Workflow

### Quick Health Check

```bash
#!/bin/bash
# One-liner health check

echo "=== SYSTEM HEALTH ===" && \
echo "Load: $(uptime | grep -o 'load average.*')" && \
echo "Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')" && \
echo "Disk: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')" && \
echo "Processes: $(ps aux | wc -l)" && \
echo "Services: $(systemctl --no-pager list-units --type=service --state=failed --no-legend | wc -l) failed"
```

### Establishing Baseline

Before troubleshooting performance, know the normal:

```bash
# Capture baseline data
echo "Baseline capture..." > baseline.txt
date >> baseline.txt
uptime >> baseline.txt
free -h >> baseline.txt
vmstat 1 5 >> baseline.txt
iostat -x 1 5 >> baseline.txt
ps aux >> baseline.txt

# Compare later if needed
diff baseline.txt current.txt
```

### Performance Troubleshooting Flowchart

```
High Load
    ↓
Check CPU usage → ps, top, sar
    ↓
Check Memory → free, vmstat, top
    ↓
Check I/O → iostat, iotop, vmstat
    ↓
Identify bottleneck → CPU, Memory, I/O, Network
    ↓
Find culprit process → top, ps, lsof
    ↓
Analyze why → logs, strace, profiling
    ↓
Fix and verify
```

---

## Section 6: Real-World Case Studies

### Case Study 1: Web Server Slow

**Symptom:** Users report website slow
**Timeline:**
1. Check load average: 8.2, 7.1, 6.5 (very high)
2. Check top: nginx processes at 80% CPU
3. Check logs: Application making slow database queries
4. Root cause: O(n²) query in new code
5. Solution: Optimize query, add index
6. Prevention: Code review for performance

### Case Study 2: Disk Space Emergency

**Symptom:** Application fails with "No space left on device"
**Timeline:**
1. df -h: 99% full
2. du -sh /* : /var is the culprit (95%)
3. du -sh /var/* : /var/log is huge
4. find /var/log -size +1G : Several GB of logs
5. Root cause: Log rotation not configured properly
6. Solution: Delete old logs, configure logrotate
7. Prevention: Monitor disk usage, set up alerts

### Case Study 3: Service Crashing Loop

**Symptom:** Service keeps restarting
**Timeline:**
1. systemctl status: Shows it's in restarts
2. journalctl -u service: See repeated failures
3. Check logs: "FATAL: Out of memory"
4. free -h: Almost no free memory
5. ps aux --sort=-%mem: Find memory hog
6. Root cause: Memory leak in another application
7. Solution: Restart leaking application, add swap
8. Prevention: Memory monitoring and alerts

---

## Section 7: Tools Comparison

**Process Monitoring:**
| Tool | Best For | Pros | Cons |
|------|----------|------|------|
| ps | Scripting | Lightweight, portable | Not real-time |
| top | Quick look | Real-time, many metrics | Verbose output |
| htop | Visual | Color, better UI | Requires installation |
| iotop | I/O issues | Specific to disk I/O | Slower than top |

**Network Tools:**
| Tool | Best For | Pros | Cons |
|------|----------|------|------|
| netstat | Port binding | Shows process/port | Deprecated |
| ss | Modern systems | Faster, more details | Different output |
| tcpdump | Packet analysis | Detailed capture | Requires root |
| curl | Web testing | Simple, reliable | Requires server |

**Log Analysis:**
| Tool | Best For | Pros | Cons |
|------|----------|------|------|
| journalctl | System logs | Structured, searchable | Systemd only |
| grep | Text search | Universal, powerful | Basic |
| awk/sed | Log parsing | Very fast, flexible | Syntax learning curve |
| jq | JSON logs | Powerful JSON parsing | Requires JSON logs |

---

## Key Takeaways

1. **Follow the Methodology** - Gather info, form hypothesis, test
2. **Check Logs First** - They have 90% of the answer
3. **One Change at a Time** - Test systematically
4. **Tools Over Memory** - You don't need to memorize commands
5. **Document Learning** - Record what you find for future reference
6. **Establish Baseline** - Know what's normal before fixing abnormal
7. **Think Root Cause** - Fix the problem, not the symptom
8. **Automate Detection** - Use monitoring to catch issues early

---

**Next:** [02-commands-cheatsheet.md](02-commands-cheatsheet.md) - Complete command reference
