# Logging and Monitoring Commands Cheatsheet

## Viewing Logs

### Tail (Real-Time Log Viewing)

| Command | Purpose | Example |
|---------|---------|---------|
| `tail -n NUMBER FILE` | Show last N lines | `tail -n 20 /var/log/syslog` |
| `tail -f FILE` | Follow file (real-time) | `tail -f /var/log/auth.log` |
| `tail -F FILE` | Follow even after rotation | `tail -F /var/log/syslog` |
| `tail -n +N FILE` | Start from line N | `tail -n +100 /var/log/messages` |

**Examples**:
```bash
# Watch system logs in real-time
tail -f /var/log/syslog

# Last 50 lines of auth log
tail -n 50 /var/log/auth.log

# Follow auth log and highlight 'error'
tail -f /var/log/auth.log | grep --color 'error\|$'
```

---

### Head (View Beginning of Files)

| Command | Purpose |
|---------|---------|
| `head -n NUMBER FILE` | Show first N lines |
| `head -c SIZE FILE` | Show first N bytes |

**Examples**:
```bash
# First 10 lines
head -n 10 /var/log/syslog

# First 100 bytes
head -c 100 /var/log/auth.log
```

---

### Less (Paginated Viewing)

| Command | Purpose |
|---------|---------|
| `less FILE` | Open file for scrolling |
| `less -N FILE` | Show line numbers |
| `less +F FILE` | Start at end (like tail -f) |

**Navigation in less**:
- `Space` - Next page
- `b` - Previous page
- `g` - Go to start
- `G` - Go to end
- `/pattern` - Search
- `n` - Next match
- `q` - Quit

---

## Log Filtering and Analysis

### Grep (Pattern Matching)

| Command | Purpose | Example |
|---------|---------|---------|
| `grep PATTERN FILE` | Find lines matching | `grep error /var/log/syslog` |
| `grep -i PATTERN FILE` | Case-insensitive | `grep -i error /var/log/syslog` |
| `grep -v PATTERN FILE` | Invert match (exclude) | `grep -v debug /var/log/syslog` |
| `grep -c PATTERN FILE` | Count matches | `grep -c error /var/log/syslog` |
| `grep -n PATTERN FILE` | Show line numbers | `grep -n error /var/log/syslog` |
| `grep -A N PATTERN FILE` | Show N lines after | `grep -A 2 error /var/log/syslog` |
| `grep -B N PATTERN FILE` | Show N lines before | `grep -B 2 error /var/log/syslog` |
| `grep -E PATTERN FILE` | Extended regex | `grep -E 'error\|warn' /var/log/syslog` |

**Examples**:
```bash
# Find all errors
grep error /var/log/syslog

# Find login failures (case-insensitive)
grep -i "failed\|invalid" /var/log/auth.log

# Count occurrences
grep -c "Feb 15" /var/log/syslog

# Show context around match
grep -B 3 -A 3 "critical" /var/log/syslog

# Multiple patterns
grep -E "error|warn|fail" /var/log/syslog
```

---

### Awk (Text Processing)

| Command | Purpose | Example |
|---------|---------|---------|
| `awk '{print $N}' FILE` | Extract column N | `awk '{print $4}' /var/log/syslog` |
| `awk -F: '{print $1}' FILE` | Use : as separator | `awk -F: '{print $1}' /etc/passwd` |
| `awk '/PATTERN/ {action}' FILE` | Conditional action | `awk '/error/ {print $0}' /var/log/syslog` |
| `awk '{count++} END {print count}'` | Count lines | `awk 'END {print NR}' /var/log/syslog` |

**Examples**:
```bash
# Extract timestamp, hostname, message
awk '{print $1, $2, $3, $5, $6}' /var/log/syslog

# Count occurrences by field
awk '{print $5}' /var/log/syslog | sort | uniq -c

# Show only errors with count
awk '/error/ {count++} END {print "Total errors:", count}' /var/log/syslog

# Extract specific time range
awk '$2 ~ /^10:2[0-5]/ {print}' /var/log/syslog
```

---

### Sed (Stream Editing)

| Command | Purpose | Example |
|---------|---------|---------|
| `sed -n 'N p' FILE` | Show line N | `sed -n '100p' /var/log/syslog` |
| `sed 's/OLD/NEW/' FILE` | Replace first occurrence | `sed 's/error/ERROR/' /var/log/syslog` |
| `sed 's/OLD/NEW/g' FILE` | Replace all | `sed 's/error/ERROR/g' /var/log/syslog` |
| `sed '/PATTERN/d' FILE` | Delete matching lines | `sed '/debug/d' /var/log/syslog` |
| `sed -n '/PATTERN/p' FILE` | Show matching lines | `sed -n '/error/p' /var/log/syslog` |

**Examples**:
```bash
# Show lines 100-110
sed -n '100,110p' /var/log/syslog

# Remove debug messages
sed '/DEBUG/d' /var/log/syslog

# Count specific pattern (with grep)
sed -n '/Failed password/p' /var/log/auth.log | wc -l
```

---

## Systemd Journal

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl` | Show all journal entries | `journalctl \| tail` |
| `journalctl -n N` | Show last N entries | `journalctl -n 50` |
| `journalctl -f` | Follow in real-time | `journalctl -f` |
| `journalctl -u UNIT` | Show specific unit | `journalctl -u nginx` |
| `journalctl -p LEVEL` | Filter by priority | `journalctl -p err` |
| `journalctl --since DATE` | Show since date | `journalctl --since today` |
| `journalctl -x` | Explain messages | `journalctl -x -p err` |
| `journalctl -o json` | JSON output | `journalctl -n 10 -o json` |

**Examples**:
```bash
# Last 100 messages
journalctl -n 100

# Follow in real-time
journalctl -f

# All errors from systemd
journalctl -u systemd --priority=err

# Since yesterday
journalctl --since "1 day ago"

# Time range
journalctl --since "2024-01-15 10:00:00" --until "2024-01-15 11:00:00"

# Boot messages
journalctl -b

# Previous boot
journalctl -b -1
```

---

## Kernel Messages

| Command | Purpose |
|---------|---------|
| `dmesg` | Show kernel ring buffer |
| `dmesg -T` | Show with timestamps |
| `dmesg -L` | Show with localized timestamps |
| `dmesg -k` | Kernel messages only |
| `dmesg -C` | Clear ring buffer (requires root) |

**Examples**:
```bash
# View boot messages
dmesg

# Show with readable timestamps
dmesg -T

# Follow kernel messages (via journalctl)
journalctl -k -f

# Search kernel logs for errors
dmesg | grep -i error
```

---

## Real-Time Monitoring

### Top (Process Monitoring)

| Command | Option | Purpose |
|---------|--------|---------|
| `top` | - | Interactive monitoring |
| `top -b` | Batch mode | Non-interactive output |
| `top -n 1` | Iterations | Run once and exit |
| `top -p PID` | Monitor process | Show specific process |
| `top -u USER` | By user | Show user's processes |
| `top -d SECS` | Delay | Update interval |

**In top (interactive)**:
- `P` - Sort by CPU
- `M` - Sort by memory
- `T` - Sort by time
- `k` - Kill process
- `q` - Quit

**Examples**:
```bash
# Get one snapshot
top -b -n 1

# Monitor specific process
top -p 1234

# Show only user's processes
top -u www-data

# Batch output to file
top -b -n 1 > top_snapshot.txt
```

---

### Htop (Enhanced Top)

| Command | Purpose |
|---------|---------|
| `htop` | Interactive monitoring (better than top) |
| `htop -p PID` | Monitor specific process |
| `htop -u USER` | Show user's processes |

**Advantages over top**:
- Color-coded output
- Easier to navigate
- Better sorting options
- Can kill/suspend directly

---

### Disk I/O Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `iostat` | Disk I/O stats | `iostat -x 1 5` |
| `iostat -x` | Extended format | `iostat -x 1` |
| `iotop` | Top by I/O (interactive) | `iotop -b -n 1` |

**Examples**:
```bash
# Show every second for 10 seconds
iostat 1 10

# Extended stats
iostat -x 1 5

# Show by process
iotop -b -n 1 -o
```

---

### Network Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `netstat -tulpn` | All listening ports | `netstat -tulpn` |
| `netstat -an` | All connections | `netstat -an` |
| `ss -tulpn` | Modern replacement | `ss -tulpn` |
| `ss -an` | All connections (modern) | `ss -an` |
| `nethogs` | Network by process | `nethogs` |

**Examples**:
```bash
# Listening ports with PID
netstat -tulpn

# Established connections
netstat -tupn | grep ESTABLISHED

# By connection state
netstat -an | grep ESTABLISHED | wc -l

# Modern ss tool
ss -tulpn
```

---

## System Resource Monitoring

### Memory

| Command | Purpose |
|---------|---------|
| `free -h` | Memory usage (human readable) |
| `free -h -s N` | Update every N seconds |
| `cat /proc/meminfo` | Detailed memory info |
| `vmstat 1 10` | Memory stats every second |

**Examples**:
```bash
# Memory overview
free -h

# Detailed breakdown
cat /proc/meminfo

# Watch memory over time
vmstat 1 10  # Every second, 10 times
```

---

### Disk Space

| Command | Purpose |
|---------|---------|
| `df -h` | Disk usage by filesystem |
| `df -i` | Inode usage |
| `du -sh DIR` | Size of directory |
| `du -h --max-depth=1 DIR` | Top-level sizes |
| `lsof +D DIR` | Open files in directory |

**Examples**:
```bash
# Disk usage
df -h

# Large directories
du -sh /home/*

# Find what's taking space
du -h --max-depth=1 /var | sort -hr
```

---

### CPU and Load

| Command | Purpose |
|---------|---------|
| `uptime` | Load average |
| `mpstat -P ALL` | Per-core CPU stats |
| `pidstat -p PID` | Process stats |
| `lscpu` | CPU information |

**Examples**:
```bash
# System load
uptime

# CPU stats
mpstat -P ALL 1 5

# Per-process CPU
pidstat -p 1234 1 10
```

---

## Log Rotation

| Command | Purpose |
|---------|---------|
| `logrotate FILE` | Manually rotate log |
| `logrotate -d FILE` | Dry run |
| `logrotate -f FILE` | Force rotation |

**Examples**:
```bash
# Test rotation config
logrotate -d /etc/logrotate.d/syslog

# Force rotation
logrotate -f /etc/logrotate.d/syslog
```

---

## Searching Logs by Date

### Using Grep with Timestamps

| Pattern | Command | Purpose |
|---------|---------|---------|
| Today's date | `grep "$(date +%b %d)" /var/log/syslog` | Today's logs |
| Specific hour | `grep "10:0[0-9]" /var/log/syslog` | Between 10:00-10:09 |
| Time range | `sed -n '/10:00/,/11:00/p' /var/log/syslog` | 10:00 to 11:00 |

**Examples**:
```bash
# Logs from today
grep "$(date +%b %d)" /var/log/syslog

# Specific date
grep "Jan 15" /var/log/syslog

# Time window
sed -n '/10:20/,/10:30/p' /var/log/syslog
```

---

## Common Log Analysis Patterns

### Count Occurrences

```bash
# Count total
grep "error" /var/log/syslog | wc -l

# Count by field
awk '{print $5}' /var/log/syslog | sort | uniq -c | sort -rn

# Count by pattern
grep -o 'Failed [^:]*' /var/log/auth.log | sort | uniq -c
```

### Find Top Issues

```bash
# Most common error
grep error /var/log/syslog | cut -d' ' -f5- | sort | uniq -c | sort -rn | head

# Most active hosts
awk '{print $4}' /var/log/syslog | sort | uniq -c | sort -rn | head

# Most common time
awk '{print $2":"$3}' /var/log/syslog | cut -d: -f1-2 | sort | uniq -c | sort -rn
```

### Find Specific Events

```bash
# Failed logins with IPs
grep "Failed password" /var/log/auth.log | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | sort | uniq -c

# Service restarts
grep "systemd.*Stopped\|Started" /var/log/syslog

# Disk issues
grep "I/O\|disk\|space" /var/log/syslog | grep -i error
```

---

## Process Tracing

| Command | Purpose |
|---------|---------|
| `strace COMMAND` | Trace system calls |
| `strace -p PID` | Trace existing process |
| `strace -e SYSCALL COMMAND` | Trace specific syscall |
| `ltrace COMMAND` | Trace library calls |

**Examples**:
```bash
# Trace a command
strace ls /tmp

# Trace process
strace -p 1234

# Only file operations
strace -e openat,read,write COMMAND

# Library calls
ltrace ./myapp
```

---

## Quick Reference

### Emergency Troubleshooting

```bash
# System is slow - check what's happening
top -b -n 1
free -h
df -h
iostat -x 1 5

# Service won't start
journalctl -u servicename -n 100
journalctl -u servicename -p err

# Check for errors
dmesg | tail -50
tail -f /var/log/syslog

# Network issues
ss -tulpn
netstat -an | grep ESTABLISHED

# Disk full investigation
du -sh /home /var /opt
df -h
```

### Performance Analysis

```bash
# CPU bound
top -b -n 1 | head -20
mpstat -P ALL 1 5

# Memory pressure
free -h
vmstat 1 10

# I/O bottleneck
iostat -x 1 5
iotop -b -n 1 -o
```

### Security Checks

```bash
# Failed logins
grep "Failed\|Invalid" /var/log/auth.log | tail -20

# Sudo usage
grep "sudo" /var/log/auth.log | tail -10

# SSH attempts
grep sshd /var/log/auth.log | grep -i "invalid\|failed"

# Port scanning
grep "Connection from\|Invalid" /var/log/auth.log
```

---

## Command Chaining Examples

### Count errors by hour

```bash
grep "error" /var/log/syslog | \
  awk '{print $2}' | \
  sort | uniq -c | \
  sort -rn
```

### Find most CPU-intensive processes

```bash
ps aux | \
  head -1 && \
  ps aux | \
  sort -k3 -rn | \
  head -5
```

### Extract unique usernames from auth log

```bash
grep "sshd\|sudo" /var/log/auth.log | \
  grep -oP 'user=\K[^ ]*|for \K[^ ]*' | \
  sort | uniq -c | sort -rn
```

### Find memory leaks (growing memory)

```bash
ps aux | \
  awk '$2==PID {print $6}' | \
  while true; do echo $(date): $(cat); sleep 60; done
```

---

This cheatsheet covers the most important commands. For more details, use `man COMMAND` or `COMMAND --help`.
