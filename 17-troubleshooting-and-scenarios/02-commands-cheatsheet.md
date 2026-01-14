# Troubleshooting - Commands Cheatsheet

Quick reference for all troubleshooting commands and patterns.

---

## Section 1: First Response - Quick Health Check

### 30-Second System Health

```bash
# Most critical info immediately
uptime          # Load average - is system overloaded?
free -h         # Memory - is RAM available?
df -h /         # Disk - is root full?
ps aux | wc -l  # Process count - too many running?
```

### Extended Health Check (2 minutes)

```bash
# Get full picture
uptime                           # Load average
free -h                          # Memory usage
df -h                            # All filesystems
ps aux --sort=-%cpu | head -5   # CPU hogs
ps aux --sort=-%mem | head -5   # Memory hogs
systemctl --no-pager list-units --state=failed --no-legend  # Failed services
```

### Service Quick Check

```bash
# Is service running?
systemctl status service-name

# Is port listening?
netstat -tulpn | grep :PORT_NUMBER
ss -tulpn | grep :PORT_NUMBER

# Can we connect?
curl http://localhost:PORT
nc -zv localhost PORT
```

---

## Section 2: Process Management Commands

### View Processes

**ps - Process Snapshot**

```bash
# All processes, detailed
ps aux

# Find specific process
ps aux | grep nginx

# Show only processes from user
ps -u username

# Process tree (family view)
ps auxf

# Show threads
ps auxH

# Sort by memory
ps aux --sort=-%mem | head -10

# Sort by CPU
ps aux --sort=-%cpu | head -10

# Show process with specific PID
ps -p 1234
```

**top - Real-time Monitor**

```bash
# Interactive mode
top

# Batch mode (single snapshot)
top -b -n 1

# Show specific process
top -p 1234

# Sort by memory
top -o %MEM

# Sort by CPU
top -o %CPU

# Run for N iterations
top -b -n 5

# Update interval
top -d 0.5   # 0.5 second refresh
```

**htop - Enhanced**

```bash
# Better UI than top
htop

# Show specific user
htop -u username

# Show specific process
htop -p 1234
```

### Kill/Signal Processes

```bash
# Graceful shutdown (SIGTERM = 15)
kill -15 PID
kill -TERM PID
kill PID  # Default is SIGTERM

# Force kill (SIGKILL = 9)
kill -9 PID
kill -KILL PID

# Kill all processes of user
killall -u username

# Kill by name
killall process-name

# Kill by pattern
pkill -f "pattern"

# Show available signals
kill -l

# Send specific signal
kill -SIGHUP PID
```

### Monitor Process Resources

```bash
# Memory leak detection
ps aux --sort=-%mem | head

# Track specific process memory over time
while true; do ps aux | grep process-name; sleep 1; done

# CPU hogs
ps aux --sort=-%cpu | head

# Zombie processes
ps aux | grep defunct

# Background processes
jobs -l

# Wait for process to finish
wait PID

# Limit process CPU
cpulimit -p PID -l 50  # Limit to 50%

# Limit process memory
systemctl set-property process.service MemoryLimit=512M
```

---

## Section 3: System Resource Commands

### Memory

**free - Memory Overview**

```bash
# Human-readable
free -h

# Megabytes
free -m

# Continuous monitoring
watch -n 1 free -h

# Total memory only
free -h | grep Mem | awk '{print $2}'

# Used memory only
free -h | grep Mem | awk '{print $3}'

# Available memory
free -h | grep Mem | awk '{print $7}'

# Show memory in detail
cat /proc/meminfo

# Percentage usage
free -h | awk 'NR==2 {print int($3/$2*100) "%"}'
```

**vmstat - Virtual Memory Stats**

```bash
# Single report
vmstat

# Continuous, every 1 second for 10 iterations
vmstat 1 10

# Show delay (first report is average since boot)
vmstat 1 2 | tail -1

# Key columns:
# r = runnable processes (waiting for CPU)
# b = blocked processes (waiting for I/O)
# swpd = swap memory used
# wa = wait I/O (% CPU waiting for I/O) - HIGH = I/O bottleneck
# us = user space (% CPU in user code)
# sy = system (% CPU in kernel)
# id = idle (% CPU idle)
```

### CPU

**vmstat - CPU Info**

```bash
# Show CPU wait (I/O bottleneck indicator)
vmstat 1 5 | tail -4

# Context switches per second
vmstat 1 5 | awk '{print $NF}' | tail -1

# Interrupts
vmstat 1 5 | awk '{print $(NF-1)}' | tail -1
```

**top/htop - CPU Details**

```bash
# Find CPU hogs
top -o %CPU

# Show multi-core load
nproc              # CPU core count

# Load average interpretation
# Load 4.0 on 2-core = 2x overloaded
# Load 1.0 on 4-core = plenty of capacity
uptime
```

**sar - System Activity Report**

```bash
# Install: sudo apt install sysstat
sar 1 10           # CPU stats, 1 sec interval, 10 times
sar -P ALL 1 5     # Per-CPU stats
sar -u 1 5         # User/system/idle CPU time
```

### Disk & I/O

**df - Disk Utilization**

```bash
# Human-readable
df -h

# Show all filesystems
df -h

# Filesystem type
df -hT

# Inodes (file count)
df -i

# Specific filesystem
df -h /

# Show percentage used
df -h | tail -n +2 | awk '{print $5, $1}'

# Find mount point of file
df /path/to/file
```

**du - Directory Usage**

```bash
# Directory size
du -sh directory

# All subdirectories
du -sh /home/user/*

# Top 10 largest
du -sh /* | sort -rh | head -10

# Find files larger than 1GB
find / -type f -size +1G

# Find old files (older than 30 days)
find /var/log -type f -mtime +30

# Detailed breakdown
du -sh ./*
du -h . --max-depth=1
```

**iostat - I/O Statistics**

```bash
# Install: sudo apt install sysstat
iostat                # CPU and I/O stats
iostat -x 1 10        # Extended stats, 1 sec interval, 10 times
iostat -m 1 10        # In MB/s
iostat -k 1 10        # In KB/s

# Key metrics:
# %util = disk utilization (0-100%)
# r/s = reads per second
# w/s = writes per second
# rMB/s = read throughput
# wMB/s = write throughput

# Find busy disk
iostat -x 1 1 | awk '$NF > 80 {print $1, $NF}'
```

**iotop - I/O Top**

```bash
# Install: sudo apt install iotop
iotop                  # Real-time I/O monitor
iotop -b               # Batch mode
iotop -p PID           # Specific process
iotop -u username      # Specific user
```

---

## Section 4: Network Commands

### Interface & Connectivity

**ip - IP Configuration**

```bash
# Show all interfaces
ip link show
ip addr show

# Specific interface
ip addr show eth0

# Interface status
ip link show eth0

# Add IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Remove IP address
sudo ip addr del 192.168.1.100/24 dev eth0

# Bring interface up/down
sudo ip link set eth0 up
sudo ip link set eth0 down

# Show routes
ip route show

# Add route
sudo ip route add 192.168.2.0/24 via 192.168.1.1
```

**ping - Reachability**

```bash
# Basic ping
ping google.com

# Count 4 packets
ping -c 4 8.8.8.8

# IPv4 specific
ping -4 google.com

# IPv6 specific
ping -6 ipv6.google.com

# Flood ping (fast, requires root)
sudo ping -f google.com

# Timeout after N seconds
ping -w 5 host
```

**traceroute/tracert - Route Analysis**

```bash
# Trace route to host
traceroute google.com

# IPv4 only
traceroute -4 google.com

# Limit hops
traceroute -m 10 google.com

# On some systems
mtr google.com  # Continuous traceroute
```

### Port & Socket Information

**netstat - Network Statistics**

```bash
# Show listening ports with process
netstat -tulpn

# Show all connections
netstat -an

# Show only established
netstat -an | grep ESTABLISHED

# Statistics summary
netstat -s

# Find what's using a port
netstat -tulpn | grep :8080

# Monitor connections
watch -n 1 'netstat -an | grep ESTABLISHED | wc -l'

# Count connections by state
netstat -an | grep -E "^tcp" | awk '{print $NF}' | sort | uniq -c
```

**ss - Socket Statistics (Modern)**

```bash
# Show listening sockets with process
ss -tulpn

# Show all sockets
ss -an

# Show established connections
ss -nt state established

# Statistics
ss -s

# Show by state
ss -tn state listening
ss -tn state established
ss -tn state time-wait

# Show specific process
ss -p | grep sshd

# Real-time watch
watch -n 1 'ss -tulpn'
```

**lsof - List Open Files**

```bash
# List all open files
lsof

# By process ID
lsof -p 1234

# By username
lsof -u username

# By command name
lsof -c nginx

# Network connections
lsof -i

# Specific port
lsof -i :8080
lsof -i :8080 -s TCP:LISTEN

# Specific host
lsof -i @192.168.1.1

# Show deleted files (disk space leak)
lsof | grep deleted

# Count open files by process
lsof | awk '{print $1}' | sort | uniq -c | sort -rn
```

### DNS & Naming

**dig - DNS Query**

```bash
# Simple query
dig google.com

# Show all records
dig google.com ANY

# Query specific type
dig google.com A
dig google.com MX
dig google.com NS

# Short answer only
dig google.com +short

# Trace from root
dig google.com +trace

# Reverse lookup
dig -x 8.8.8.8

# Query specific nameserver
dig @8.8.8.8 google.com

# Recursive query
dig +recurse google.com
```

**nslookup - Name Server Lookup**

```bash
# Simple lookup
nslookup google.com

# Query specific nameserver
nslookup google.com 8.8.8.8

# Reverse lookup
nslookup 8.8.8.8

# Interactive mode
nslookup
> google.com
> exit
```

### HTTP/Web Testing

**curl - HTTP Client**

```bash
# Simple request
curl http://example.com

# Show headers
curl -I http://example.com

# Verbose (show headers)
curl -v http://example.com

# Follow redirects
curl -L http://example.com

# POST request
curl -X POST http://example.com

# With data
curl -d "data=value" http://example.com

# Custom header
curl -H "Authorization: Bearer token" http://example.com

# Timeout
curl --max-time 10 http://example.com

# Save to file
curl http://example.com > file.html

# Show response code
curl -o /dev/null -s -w "%{http_code}\n" http://example.com

# Test connectivity
curl -s http://localhost:8080 && echo "UP" || echo "DOWN"
```

**wget - File Download**

```bash
# Download file
wget http://example.com/file.tar.gz

# Continue incomplete download
wget -c http://example.com/file.tar.gz

# Save as different name
wget -O newname.tar.gz http://example.com/file.tar.gz

# Recursive download
wget -r http://example.com

# Quiet mode
wget -q http://example.com/file.tar.gz
```

---

## Section 5: Log Viewing

### journalctl - Systemd Logs

```bash
# Show recent logs
journalctl

# Follow in real-time
journalctl -f

# Last N lines
journalctl -n 50

# Since timestamp
journalctl --since "2024-01-15 10:00:00"
journalctl --since "1 hour ago"
journalctl --since "10 minutes ago"

# Until timestamp
journalctl --until "2024-01-15 11:00:00"

# Specific service
journalctl -u nginx.service
journalctl -u ssh

# Service last boot
journalctl -u ssh -b

# Show boot messages
journalctl -b              # This boot
journalctl -b -1           # Previous boot

# List boots
journalctl --list-boots

# Priority levels
journalctl -p err          # Errors only
journalctl -p warning      # Warnings and above
journalctl -p info         # Info and above

# Multiple priorities
journalctl -p err,warning

# By executable
journalctl /usr/sbin/nginx

# By PID
journalctl _PID=1234

# Output formats
journalctl -o json         # JSON
journalctl -o short-full   # More detailed
journalctl -o cat          # Message only

# Combine filters
journalctl -u ssh --since "1 hour ago" -p err
```

### dmesg - Kernel Messages

```bash
# Show all kernel messages
dmesg

# Last 30 lines
dmesg | tail -30

# Follow new messages
dmesg --follow

# By level
dmesg --level=err
dmesg --level=warn,err

# Clear buffer (requires root)
sudo dmesg -c

# With timestamps
dmesg -T

# Human-readable kernel time
dmesg | tail -20

# Find specific pattern
dmesg | grep -i hardware
dmesg | grep -i error
dmesg | grep -i oom
```

### Traditional Log Files

```bash
# System log
tail -f /var/log/syslog
tail -f /var/log/messages  # CentOS/RHEL

# Authentication
tail -f /var/log/auth.log

# Kernel
tail -f /var/log/kern.log

# Application specific
tail -f /var/log/nginx/error.log
tail -f /var/log/mysql/error.log

# Web server access
tail -f /var/log/apache2/access.log

# Security
tail -f /var/log/security.log
```

---

## Section 6: Process Tracing

### strace - System Call Tracing

```bash
# Trace all system calls
strace command

# Write to file
strace -o trace.txt command

# Show only syscalls
strace -e trace=syscall command

# Specific syscalls
strace -e open,read,write command
strace -e socket,connect command

# Show syscall timings
strace -c command

# Attach to running process
sudo strace -p PID

# Show file operations
strace -e trace=file command

# Show network operations
strace -e trace=network command

# Show memory operations
strace -e trace=mmap,munmap command

# Show time spent in each call
strace -T command

# Verbose output
strace -vv command

# Follow forked processes
strace -f command

# Show process communication
strace -e trace=write -e write=all command
```

### ltrace - Library Call Tracing

```bash
# Install: sudo apt install ltrace
ltrace command

# Specific library
ltrace -l /usr/lib/libc.so.6 command

# Count calls
ltrace -c command

# Show arguments
ltrace -s 100 command
```

---

## Section 7: Performance Analysis

### All-in-One Commands

```bash
# Single command health check
echo "=== HEALTH ===" && uptime && echo "---" && free -h && echo "---" && df -h / && echo "---" && ps aux | wc -l

# Find top memory users
ps aux --sort=-%mem | head -10

# Find top CPU users
ps aux --sort=-%cpu | head -10

# Show process resource usage
ps aux | awk '{print $2, $3, $4, $11}' | column -t

# Find zombie processes
ps aux | grep -w Z | grep -v grep

# Count processes by user
ps aux | awk '{print $1}' | sort | uniq -c

# List largest directories
du -sh /* | sort -rh

# Find large files
find / -type f -size +100M 2>/dev/null

# Monitor load in real-time
watch -n 1 uptime

# Show system metrics dashboard
dstat 1 10
```

### Baseline Capture

```bash
# Create baseline snapshot
cat > baseline.sh << 'EOF'
#!/bin/bash
echo "=== BASELINE CAPTURE ===" > baseline.txt
date >> baseline.txt
uptime >> baseline.txt
free -h >> baseline.txt
vmstat 1 5 >> baseline.txt
iostat -x 1 5 >> baseline.txt
ps aux >> baseline.txt
netstat -an >> baseline.txt
df -h >> baseline.txt
EOF

chmod +x baseline.sh
./baseline.sh
```

---

## Section 8: Troubleshooting Workflows

### Service Troubleshooting

```bash
# 1. Check status
systemctl status nginx

# 2. Check logs
journalctl -u nginx -n 50

# 3. Check configuration
nginx -t

# 4. Try manual start
sudo /usr/sbin/nginx

# 5. Check dependencies
systemctl show -p Requires nginx

# 6. Check ports
netstat -tulpn | grep :80
```

### Slow System Troubleshooting

```bash
# 1. Check load
uptime

# 2. Check top processes
top -b -n 1 | head -15

# 3. Check memory pressure
vmstat 1 5

# 4. Check I/O
iostat -x 1 5

# 5. Check disk bottleneck
iotop -b -n 1
```

### Network Troubleshooting

```bash
# 1. Check interfaces
ip link show

# 2. Check IP config
ip addr show

# 3. Ping gateway
ping -c 4 DEFAULT_GATEWAY

# 4. Check DNS
dig google.com

# 5. Check routes
ip route show

# 6. Check listening ports
ss -tulpn

# 7. Test connectivity
curl http://remote.host
```

### Disk Space Troubleshooting

```bash
# 1. Check usage
df -h

# 2. Find large dirs
du -sh /* | sort -rh

# 3. Find large files
find / -type f -size +100M

# 4. Find old logs
find /var/log -type f -mtime +30

# 5. Check inodes
df -i

# 6. Delete/compress
rm oldfile
gzip logfile
```

---

## Quick Reference by Task

### Check if Service is Running

```bash
systemctl is-active service-name
systemctl is-enabled service-name
ps aux | grep service-name
netstat -tulpn | grep :PORT
```

### Find Process Using Port

```bash
netstat -tulpn | grep :PORT
lsof -i :PORT
fuser PORT/tcp
```

### Monitor Real-Time

```bash
top
htop
watch -n 1 'free -h'
journalctl -f
tail -f logfile
```

### Get Detailed Stats

```bash
vmstat 1 5
iostat -x 1 5
sar -u 1 5
ps aux --sort=-%cpu
```

### Check Connectivity

```bash
ping host
traceroute host
curl http://host:port
nc -zv host port
dig hostname
```

---

**See:** [03-hands-on-labs.md](03-hands-on-labs.md) - Practice labs using these commands
