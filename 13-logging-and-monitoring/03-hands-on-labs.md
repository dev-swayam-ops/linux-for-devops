# Logging and Monitoring - Hands-On Labs

## Lab Overview

This section contains 8 hands-on labs covering logging and monitoring. Each lab includes:
- **Goal**: What you'll accomplish
- **Setup**: Any prep needed
- **Steps**: Detailed instructions
- **Expected Output**: What to look for
- **Verification**: Checklist to confirm success
- **Cleanup**: Reset for next lab

**Total Time**: 2.5-3 hours for all labs

---

## Lab 1: Exploring System Logs

**Goal**: Understand where system logs are stored and what they contain

**Difficulty**: Beginner | **Time**: 15 minutes

### Setup

```bash
# No special setup needed - we'll just explore existing logs
# Ensure you can access log files (may need sudo for some)
```

### Steps

**1. Check available log files**

```bash
# List log directory
ls -lh /var/log/ | head -20
```

Expected output:
```
total 500K
drwxr-xr-x  2 root    root   4.0K Jan 15 10:30 apt
drwxr-xr-x  2 syslog  adm    4.0K Jan 15 10:30 auth
-rw-r--r--  1 syslog  adm    25K Jan 15 10:30 auth.log
-rw-r--r--  1 syslog  adm    15K Jan 15 10:30 kern.log
-rw-r--r--  1 syslog  adm    50K Jan 15 10:30 syslog
```

**2. View the main system log**

```bash
# Show last 20 lines of main log
tail -n 20 /var/log/syslog
```

Expected output:
```
Jan 15 10:25:40 hostname systemd[1]: Starting Daily apt download activities...
Jan 15 10:25:41 hostname kernel: [1234.567890] CPU: Core temperature above threshold, cpu clock throttled
Jan 15 10:26:00 hostname systemd[1]: Started Daily apt download activities.
Jan 15 10:28:15 hostname sudo[5678]: user : TTY=pts/0 ; PWD=/home/user ; USER=root ; COMMAND=/bin/systemctl restart nginx
```

**3. Check log file sizes**

```bash
# See which logs are growing
du -sh /var/log/* | sort -hr | head -10
```

Expected output:
```
50M     /var/log/syslog
30M     /var/log/kern.log
15M     /var/log/auth.log
5.2M    /var/log/apt
4.1M    /var/log/mysql
```

**4. Understand log file permissions**

```bash
# Check permissions on sensitive logs
ls -l /var/log/auth.log /var/log/kern.log /var/log/syslog
```

Expected output:
```
-rw-r----- 1 syslog adm 25000 Jan 15 10:30 /var/log/auth.log    # adm group can read
-rw-r--r-- 1 syslog adm 15000 Jan 15 10:30 /var/log/kern.log
-rw-r--r-- 1 syslog adm 50000 Jan 15 10:30 /var/log/syslog
```

**5. View kernel messages**

```bash
# Kernel-specific logs
tail -n 20 /var/log/kern.log
```

**6. Check authentication logs**

```bash
# See login attempts
tail -n 20 /var/log/auth.log
```

Expected output:
```
Jan 15 10:20:30 hostname sshd[2341]: Connection closed by 192.168.1.100 port 54321 [preauth]
Jan 15 10:21:45 hostname sudo[2500]: user : TTY=pts/0 ; PWD=/home/user ; USER=root ; COMMAND=/bin/id
Jan 15 10:22:00 hostname sudo[2500]: pam_unix(sudo:session): session opened for user root by user(uid=1000)
```

### Expected Output Summary

- `/var/log/syslog` - General system messages (largest usually)
- `/var/log/auth.log` - Authentication and sudo attempts
- `/var/log/kern.log` - Kernel messages
- `/var/log/apt/` - Package manager logs
- File sizes show which logs are most active

### Verification Checklist

- [ ] Located `/var/log/` directory
- [ ] Viewed main system log (syslog)
- [ ] Found auth.log and understood it contains login info
- [ ] Checked file permissions (why auth.log is restricted)
- [ ] Understood kernel messages in kern.log
- [ ] Can explain what each file contains

### Cleanup

```bash
# No files created, no cleanup needed
```

---

## Lab 2: Understanding Log Levels and Message Formats

**Goal**: Learn how to read and interpret log messages

**Difficulty**: Beginner | **Time**: 20 minutes

### Setup

```bash
# Create a test log file for safer exploration
cp /var/log/syslog ~/test-syslog.log
```

### Steps

**1. Examine log message format**

```bash
# Look at a sample message
head -n 1 ~/test-syslog.log
```

Expected output:
```
Jan 15 10:15:00 hostname systemd[1]: Started CUPS Print Service.
```

Breakdown:
- `Jan 15 10:15:00` - Timestamp
- `hostname` - System name
- `systemd[1]` - Process name [PID]
- Message follows the colon

**2. Find different log levels**

```bash
# Search for various levels
echo "=== INFO messages ==="
grep "Started\|Started" ~/test-syslog.log | head -3

echo -e "\n=== WARNING messages ==="
grep -i "warning\|deprecated" ~/test-syslog.log | head -3

echo -e "\n=== ERROR messages ==="
grep -i "error\|failed" ~/test-syslog.log | head -3
```

**3. Identify log sources (facilities)**

```bash
# Extract process names (facilities)
echo "=== Most common sources ==="
awk '{print $5}' ~/test-syslog.log | \
  cut -d'[' -f1 | \
  sort | uniq -c | sort -rn | head -10
```

Expected output:
```
    45 systemd[1]
    23 kernel
    18 sudo
    12 sshd
     8 cron
     5 postfix/smtp
     3 apache2
```

**4. Count messages by date**

```bash
# See message frequency
echo "=== Messages per date ==="
cut -d' ' -f1,2 ~/test-syslog.log | sort | uniq -c | tail -10
```

**5. Find specific events**

```bash
# Look for system restarts
echo "=== Service starts/stops ==="
grep -E "Started|Stopped" ~/test-syslog.log | tail -5

# Look for authentication attempts
echo -e "\n=== Auth attempts ==="
grep "sshd\|sudo" ~/test-syslog.log | tail -5
```

**6. Analyze message patterns**

```bash
# Find most common messages
echo "=== Top 5 messages ==="
awk -F': ' '{print $NF}' ~/test-syslog.log | \
  sort | uniq -c | sort -rn | head -5
```

### Expected Output Summary

- Messages follow standard format: `Date Time Hostname Process[PID]: Message`
- Different processes generate logs (systemd, kernel, sshd, etc.)
- Levels range from INFO (normal) to ERROR (problems)
- Can count and analyze message frequency

### Verification Checklist

- [ ] Understand message format (Timestamp, Hostname, Process, Message)
- [ ] Can identify different log levels
- [ ] Know what facilities are (process/system that generated log)
- [ ] Can extract patterns from logs using grep/awk
- [ ] Can count occurrences of events

### Cleanup

```bash
rm ~/test-syslog.log
```

---

## Lab 3: Real-Time System Monitoring with Top

**Goal**: Learn to monitor system resources in real-time

**Difficulty**: Beginner | **Time**: 20 minutes

### Setup

```bash
# Generate some load for monitoring
# Run in background
yes > /dev/null &
BG_PID=$!
echo "Background process PID: $BG_PID"
```

### Steps

**1. Start top in batch mode**

```bash
# Get one snapshot
top -b -n 1 | head -15
```

Expected output:
```
top - 10:35:42 up 5 days,  2:15,  1 user,  load average: 1.45, 0.98, 0.72
Tasks:  142 total,   2 running, 140 sleeping,   0 stopped,   0 zombie
%Cpu(s):  45.2% us,  8.3% sy,  0.0% ni, 45.1% id,  1.2% wa,  0.0% hi,  0.2% si,  0.0% st
MiB Mem :   7956.0 total,   5432.1 free,   1200.5 used,   1323.4 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   6200.2 avail Mem

    PID USER      PR  NI    VIRT    RES  SHR S  %CPU %MEM     TIME+ COMMAND
      1 root      20   0  101.2m  11.2m   8.5m S   0.0  0.1   0:05.42 systemd
      2 root      20   0       0      0      0 S   0.0  0.0   0:00.00 kthreadd
   1234 root      20   0 1024.5m 256.8m      0 R  95.2  3.2   1:23.45 yes
```

**2. Interpret the header**

```bash
# Let's break down what we see:
echo "=== Understanding Top Header ==="
echo "Load average: 1.45 (1min), 0.98 (5min), 0.72 (15min)"
echo "CPU breakdown: 45.2% user, 8.3% system, 45.1% idle"
echo "Memory: 5432.1 MB free, 1200.5 MB used of 7956 MB total"
```

**3. Monitor specific process**

```bash
# Watch the background process we started
top -b -n 1 -p $BG_PID
```

Expected output:
```
%Cpu(s):  99.8% us,  0.0% sy,  0.0% ni,  0.0% id,  0.2% wa
...
   1234 root      20   0   10.0m   0.7m      0 R  99.8  0.0   0:15.23 yes
```

**4. Check memory usage**

```bash
# Show just memory info
free -h
```

Expected output:
```
              total        used        free      shared  buff/cache   available
Mem:          7.8Gi       1.2Gi       5.4Gi      100Mi       1.3Gi       6.2Gi
Swap:         2.0Gi          0B       2.0Gi
```

**5. Get top consumers**

```bash
# Top 5 memory consumers
echo "=== Top memory consumers ==="
top -b -n 1 | tail -10 | head -5

# Top 5 CPU consumers
echo -e "\n=== Top CPU consumers ==="
top -b -n 1 | sort -k9 -rn | head -5
```

**6. Check load average**

```bash
# Simple load check
uptime
```

Expected output:
```
 10:35:42 up 5 days,  2:15,  1 user,  load average: 1.45, 0.98, 0.72
```

### Expected Output Summary

- Top shows real-time process information
- Header shows load average (should relate to # of cores)
- Can identify resource-hungry processes
- Memory breakdown shows available vs cached
- Load of 1.0 = fully utilized (on single core)

### Verification Checklist

- [ ] Understand load average (what each number means)
- [ ] Know what %CPU and %MEM represent
- [ ] Can identify which process is using the most CPU
- [ ] Understand memory categories (used, free, cache)
- [ ] Know what high CPU or memory usage indicates

### Cleanup

```bash
# Kill the background process
kill $BG_PID 2>/dev/null
wait $BG_PID 2>/dev/null
```

---

## Lab 4: Disk and Network Monitoring

**Goal**: Monitor disk I/O and network activity

**Difficulty**: Beginner | **Time**: 25 minutes

### Setup

```bash
# No special setup, we'll use existing tools
# Ensure sysstat is installed
which iostat || echo "Install: sudo apt install sysstat"
```

### Steps

**1. Check disk space**

```bash
# Disk usage overview
df -h
```

Expected output:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   12G  7.2G  62% /
/dev/sda2       100G   45G   50G  47% /home
tmpfs           7.8G     0  7.8G   0% /dev/shm
```

**2. Find largest directories**

```bash
# What's taking up space?
echo "=== Largest directories in /home ==="
du -sh /home/* 2>/dev/null | sort -hr | head -5
```

**3. Monitor disk I/O**

```bash
# Disk I/O statistics
echo "=== Disk I/O Stats (5 seconds, updates each second) ==="
iostat -x 1 5
```

Expected output:
```
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           10.25    0.00   5.15    2.10    0.00   82.50

Device            r/s     w/s     rMB/s     wMB/s   rrqm/s   wrqm/s  %rrqm  %wrqm %r_await %w_await %util
sda              45.20   23.10     2.30     1.10    0.50     3.20    1.1   12.2    15.4     22.5   8.95
```

**4. Check network connections**

```bash
# Listening ports
echo "=== Listening ports ==="
ss -tulpn 2>/dev/null | head -10
```

Expected output:
```
Netid  State    Recv-Q Send-Q Local Address:Port Peer Address:Port Process
tcp    LISTEN      0      128   0.0.0.0:22        0.0.0.0:*      users:(("sshd",pid=1234,fd=3))
tcp    LISTEN      0      128   0.0.0.0:80        0.0.0.0:*      users:(("nginx",pid=5678,fd=6))
tcp    LISTEN      0      128   0.0.0.0:443       0.0.0.0:*      users:(("nginx",pid=5679,fd=7))
```

**5. Check open file descriptors**

```bash
# How many files are open?
echo "=== Open file descriptors ==="
lsof 2>/dev/null | wc -l

# By process
echo -e "\n=== Top file handlers ==="
lsof 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
```

**6. Monitor processes by I/O (if iotop available)**

```bash
# Disk I/O by process (one snapshot)
if command -v iotop &> /dev/null; then
    echo "=== I/O by process ==="
    iotop -b -n 1 -o 2>/dev/null | head -15
else
    echo "iotop not installed (install with: sudo apt install iotop)"
fi
```

### Expected Output Summary

- Disk usage shows filesystem capacity
- I/O stats show read/write performance
- Network shows which services are listening
- Open files show resource usage
- Can identify I/O bottlenecks

### Verification Checklist

- [ ] Know how to check available disk space (df)
- [ ] Can identify large directories (du)
- [ ] Understand I/O statistics (r/s, w/s, %util)
- [ ] Know how to list listening ports (ss/netstat)
- [ ] Can monitor open file descriptors (lsof)

### Cleanup

```bash
# No cleanup needed
```

---

## Lab 5: Filtering and Searching Logs

**Goal**: Extract specific information from logs using grep and awk

**Difficulty**: Intermediate | **Time**: 30 minutes

### Setup

```bash
# Create test data with realistic patterns
cat > ~/sample-logs.txt << 'EOF'
Jan 15 10:00:15 webserver sshd[2341]: Failed password for invalid user admin from 192.168.1.100 port 54321 ssh2
Jan 15 10:01:30 webserver kernel: [1234.567890] Out of memory: Kill process 5678 (java) score 450
Jan 15 10:02:45 webserver sudo[3456]: user1 : TTY=pts/0 ; PWD=/home/user1 ; USER=root ; COMMAND=/bin/systemctl restart nginx
Jan 15 10:03:20 webserver systemd[1]: Started CUPS Print Service.
Jan 15 10:04:10 webserver sshd[2342]: Failed password for invalid user root from 192.168.1.101 port 54322 ssh2
Jan 15 10:05:55 webserver apache2[4567]: [notice] Apache/2.4.41 (Ubuntu) configured
Jan 15 10:06:30 webserver kernel: [1456.123456] CPU0: Package temperature above threshold, cpu clock throttled
Jan 15 10:07:15 webserver sshd[2343]: Accepted publickey for user1 from 192.168.1.50 port 54323 ssh2
Jan 15 10:08:00 webserver sudo[3457]: user2 : TTY=unknown ; PWD=? ; USER=root ; COMMAND=/usr/bin/mysql
Jan 15 10:09:30 webserver systemd[1]: Failed to start Docker service. [FAILED]
EOF

echo "Created sample-logs.txt with 10 test entries"
```

### Steps

**1. Find all error messages**

```bash
echo "=== ERROR messages ==="
grep -i "error\|failed\|failed\|exception" ~/sample-logs.txt
```

Expected output:
```
Jan 15 10:00:15 webserver sshd[2341]: Failed password for invalid user admin from 192.168.1.100 port 54321 ssh2
Jan 15 10:01:30 webserver kernel: [1234.567890] Out of memory: Kill process 5678 (java) score 450
Jan 15 10:04:10 webserver sshd[2342]: Failed password for invalid user root from 192.168.1.101 port 54322 ssh2
Jan 15 10:09:30 webserver systemd[1]: Failed to start Docker service. [FAILED]
```

**2. Extract IPs from failed logins**

```bash
echo "=== Failed login IPs ==="
grep "Failed password" ~/sample-logs.txt | \
  grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
  sort | uniq -c
```

Expected output:
```
      1 192.168.1.100
      1 192.168.1.101
```

**3. Count messages by process**

```bash
echo "=== Messages by process ==="
awk '{print $5}' ~/sample-logs.txt | \
  cut -d'[' -f1 | \
  sort | uniq -c | sort -rn
```

Expected output:
```
      3 sshd
      2 systemd[1]
      2 kernel
      1 sudo[3456]
      1 apache2[4567]
      1 sudo[3457]
```

**4. Find sudo commands executed**

```bash
echo "=== Sudo commands ==="
grep "sudo" ~/sample-logs.txt | \
  grep -oP 'COMMAND=\K[^ ]+'
```

Expected output:
```
/bin/systemctl
/usr/bin/mysql
```

**5. Extract timestamps for specific events**

```bash
echo "=== SSH authentication attempts (all) ==="
grep "sshd" ~/sample-logs.txt | \
  awk '{print $1, $2, $3, $5, $NF}'
```

**6. Advanced: Find all sudoed commands by user**

```bash
echo "=== Sudo by user ==="
grep "sudo" ~/sample-logs.txt | \
  awk -F': ' '{print $1, $2}' | \
  while read line process; do
    user=$(echo $process | grep -oP 'user[^ ]* :' | cut -d' ' -f1)
    command=$(echo $process | grep -oP 'COMMAND=\K[^ ]+')
    echo "$user ran: $command"
  done
```

### Expected Output Summary

- Can filter messages by severity
- Can extract structured data (IPs, commands, users)
- Can count and sort results
- Can combine multiple tools effectively
- Can identify patterns in logs

### Verification Checklist

- [ ] Can use grep to find errors
- [ ] Know how to use grep -o for extraction
- [ ] Can pipe grep to awk for sorting
- [ ] Can extract patterns using grep -oE
- [ ] Can count occurrences with uniq -c

### Cleanup

```bash
rm ~/sample-logs.txt
```

---

## Lab 6: Troubleshooting Using Logs

**Goal**: Use logs systematically to diagnose and solve problems

**Difficulty**: Intermediate | **Time**: 30 minutes

### Setup

```bash
# Check if there are actual recent errors we can investigate
echo "=== Recent system errors ==="
journalctl -p err --since "1 hour ago" | head -20
```

### Steps

**1. Investigate system startup issues**

```bash
# Check if system booted cleanly
echo "=== Boot status ==="
journalctl -b | tail -20
```

**2. Check service status**

```bash
# Pick a service and check its logs
echo "=== Checking specific service ==="
systemctl status systemd-journald
```

**3. Find failed units**

```bash
# Which services failed?
echo "=== Failed units ==="
systemctl list-units --state=failed
```

**4. Get detailed error information**

```bash
# Explain errors (if available)
echo "=== Detailed error explanations ==="
journalctl -x -p err --since "1 hour ago" | head -30
```

**5. Timeline analysis**

```bash
# Correlate events by timestamp
echo "=== Events around 10:00 ==="
grep "10:0[0-5]" /var/log/syslog 2>/dev/null | tail -10
```

**6. Identify repeat issues**

```bash
# Same error happening multiple times?
echo "=== Most frequent errors ==="
journalctl -p err --since "1 day ago" | \
  awk -F': ' '{print $NF}' | \
  sort | uniq -c | sort -rn | head -5
```

### Expected Output Summary

- Can identify when systems had issues
- Can correlate timestamps across services
- Can determine if issues are recurring
- Can get context and explanations
- Can extract root causes from logs

### Verification Checklist

- [ ] Can check service status and logs
- [ ] Know how to find failed units
- [ ] Can correlate events by time
- [ ] Can identify repeating problems
- [ ] Understand journal explanations (-x flag)

### Cleanup

```bash
# No cleanup needed
```

---

## Lab 7: Setting Up Log Rotation

**Goal**: Configure log rotation to manage disk space

**Difficulty**: Intermediate | **Time**: 20 minutes

### Setup

```bash
# Create a test application log
mkdir -p ~/test-app-logs
cat > ~/test-app-logs/app.log << 'EOF'
2024-01-15 10:00:00 INFO: Application started
2024-01-15 10:00:15 DEBUG: Configuration loaded
2024-01-15 10:00:30 INFO: Database connected
EOF

echo "Created test application log"
```

### Steps

**1. Examine current log rotation config**

```bash
# Check what rotation rules exist
echo "=== Existing logrotate configs ==="
ls -la /etc/logrotate.d/ | head -10
```

**2. View a rotation config**

```bash
# See how syslog is rotated
echo "=== Syslog rotation config ==="
cat /etc/logrotate.d/syslog 2>/dev/null || echo "File not accessible (try with sudo)"
```

**3. Create custom rotation config**

```bash
# Create test application rotation config
cat > ~/test-logrotate.conf << 'EOF'
/home/$(whoami)/test-app-logs/app.log {
    daily                  # Rotate daily
    rotate 5               # Keep 5 rotated versions
    compress               # Compress with gzip
    delaycompress          # Don't compress until next rotation
    missingok              # Don't error if missing
    notifempty             # Don't rotate if empty
    create 0644 root root  # Permissions for new log
}
EOF

echo "Created test logrotate configuration"
cat ~/test-logrotate.conf
```

**4. Test rotation config (dry run)**

```bash
# Verify config is valid (won't actually rotate)
logrotate -d ~/test-logrotate.conf
```

Expected output:
```
reading config file /home/user/test-logrotate.conf
Handling 1 logs

rotating pattern: /home/user/test-app-logs/app.log
 daily (5 rotations)
empty log files are not rotated, old logs are removed
considering log file /home/user/test-app-logs/app.log
  log does not need rotating
```

**5. Manually test rotation (with real file)**

```bash
# Add more content to make rotation worthwhile
for i in {1..100}; do
    echo "2024-01-15 10:$((i % 60)):00 INFO: Log entry $i" >> ~/test-app-logs/app.log
done

# Show current file
echo "=== Before rotation ==="
ls -lh ~/test-app-logs/

# Test actual rotation
echo -e "\n=== Rotating ==="
logrotate -f ~/test-logrotate.conf

# Show after rotation
echo -e "\n=== After rotation ==="
ls -lh ~/test-app-logs/
```

Expected output:
```
After rotation
total 16K
-rw-r--r-- 1 root root  234 Jan 15 10:35 app.log      # New, small file
-rw-r--r-- 1 root root  890 Jan 15 10:34 app.log.1.gz # Old, compressed
```

**6. Understand rotation parameters**

```bash
echo "=== Rotation parameters explained ==="
cat << 'EOF'
daily        - Rotate every day (weekly, monthly, yearly options exist)
rotate 5     - Keep 5 old logs, delete oldest
compress     - Compress rotated logs with gzip
delaycompress - Don't compress until next rotation (keeps latest readable)
missingok    - Don't error if log doesn't exist
notifempty   - Don't rotate empty logs (saves space)
create       - Create new log with specified permissions
postrotate   - Commands to run after rotation (restart daemons, etc)
EOF
```

### Expected Output Summary

- Logrotate manages log files automatically
- Prevents disk space exhaustion from logs
- Compresses old logs to save space
- Can be configured per application
- Important for long-running systems

### Verification Checklist

- [ ] Know where logrotate configs are (/etc/logrotate.d/)
- [ ] Understand rotation parameters
- [ ] Can create custom rotation config
- [ ] Know how to test configs (logrotate -d)
- [ ] Understand file compression in rotation

### Cleanup

```bash
rm -rf ~/test-app-logs ~/test-logrotate.conf
```

---

## Lab 8: Creating Monitoring Alerts

**Goal**: Set up basic monitoring to alert on critical conditions

**Difficulty**: Intermediate | **Time**: 25 minutes

### Setup

```bash
# Create a simple monitoring script that we'll make alert-aware
mkdir -p ~/monitoring
```

### Steps

**1. Monitor disk space and alert**

```bash
# Create alert script
cat > ~/monitoring/check-disk.sh << 'SCRIPT'
#!/bin/bash

THRESHOLD=80  # Alert if >80% used

# Check all filesystems
df -h | tail -n +2 | while read line; do
    usage=$(echo $line | awk '{print $5}' | cut -d'%' -f1)
    mount=$(echo $line | awk '{print $6}')
    
    if [ "$usage" -gt "$THRESHOLD" ]; then
        echo "ALERT: $mount is ${usage}% full"
    fi
done
SCRIPT

chmod +x ~/monitoring/check-disk.sh
```

**2. Test disk alert**

```bash
# Run the script
echo "=== Running disk check ==="
~/monitoring/check-disk.sh
```

Expected output (if any filesystem is >80%):
```
ALERT: /home is 85% full
```

**3. Monitor memory and alert**

```bash
# Create memory alert script
cat > ~/monitoring/check-memory.sh << 'SCRIPT'
#!/bin/bash

THRESHOLD=80  # Alert if >80% used

USED=$(free | grep Mem | awk '{print int($3/$2*100)}')

if [ "$USED" -gt "$THRESHOLD" ]; then
    echo "ALERT: Memory usage is ${USED}%"
else
    echo "OK: Memory usage is ${USED}%"
fi
SCRIPT

chmod +x ~/monitoring/check-memory.sh
```

**4. Test memory alert**

```bash
~/monitoring/check-memory.sh
```

**5. Monitor process and alert**

```bash
# Create process monitoring script
cat > ~/monitoring/check-process.sh << 'SCRIPT'
#!/bin/bash

PROCESS=$1
THRESHOLD=${2:-5}  # Alert if >5 instances

if [ -z "$PROCESS" ]; then
    echo "Usage: $0 <process_name> [max_instances]"
    exit 1
fi

COUNT=$(pgrep -c "$PROCESS" || echo 0)

if [ "$COUNT" -gt "$THRESHOLD" ]; then
    echo "ALERT: Found $COUNT instances of $PROCESS (threshold: $THRESHOLD)"
else
    echo "OK: Found $COUNT instances of $PROCESS"
fi
SCRIPT

chmod +x ~/monitoring/check-process.sh
```

**6. Test process alert**

```bash
# Check for shell processes
~/monitoring/check-process.sh "bash" 50
```

**7. Schedule checks with cron**

```bash
# Show how to automate these (don't actually add to cron)
echo "=== Cron schedule example (don't run) ==="
cat << 'CRON'
# Run every 5 minutes
*/5 * * * * /home/user/monitoring/check-disk.sh >> /tmp/disk-check.log 2>&1
*/5 * * * * /home/user/monitoring/check-memory.sh >> /tmp/mem-check.log 2>&1

# Run hourly
0 * * * * /home/user/monitoring/check-process.sh "sshd" 10 >> /tmp/proc-check.log 2>&1
CRON
```

**8. View monitoring logs**

```bash
# Show what alerts look like
echo "=== Sample alert log ==="
cat > /tmp/sample-alerts.log << 'LOG'
2024-01-15 10:00:05 ALERT: /home is 82% full
2024-01-15 10:05:10 OK: Memory usage is 65%
2024-01-15 10:10:15 ALERT: Found 12 instances of nginx (threshold: 10)
2024-01-15 10:15:20 OK: Memory usage is 68%
2024-01-15 10:20:25 ALERT: /var is 88% full
LOG

cat /tmp/sample-alerts.log
```

### Expected Output Summary

- Can create monitoring scripts for resources
- Can check thresholds and alert
- Scripts can be automated with cron
- Alerts can be logged for analysis
- Proactive monitoring prevents emergencies

### Verification Checklist

- [ ] Created disk space monitoring script
- [ ] Created memory monitoring script
- [ ] Created process count monitoring script
- [ ] Understand how to set thresholds
- [ ] Know how to schedule with cron
- [ ] Understand logging output for debugging

### Cleanup

```bash
rm -rf ~/monitoring /tmp/sample-alerts.log
```

---

## Lab Summary

| Lab | Topic | Key Skills |
|-----|-------|-----------|
| 1 | Exploring logs | Finding logs, understanding structure |
| 2 | Log formats | Reading messages, extracting data |
| 3 | Real-time monitoring | Using top, understanding metrics |
| 4 | Disk/network monitoring | Using iostat, ss, checking resources |
| 5 | Log filtering | Using grep, awk for log analysis |
| 6 | Troubleshooting | Using logs systematically |
| 7 | Log rotation | Managing disk space with logrotate |
| 8 | Creating alerts | Simple monitoring scripts |

**Total Time**: 2.5-3 hours

All labs are **non-destructive** and **safe** to run on production systems (monitoring only).

---

## After the Labs

Now that you understand logging and monitoring:

1. **Apply to real systems**: Check your own system's logs
2. **Create monitoring**: Set up monitoring for services you run
3. **Understand patterns**: Study logs when issues occur
4. **Automate**: Create monitoring scripts for your infrastructure
5. **Practice regularly**: Get comfortable with these tools

Good luck! 🚀
