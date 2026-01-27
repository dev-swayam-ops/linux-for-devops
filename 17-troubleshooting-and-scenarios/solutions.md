# Troubleshooting and Scenarios: Solutions

## Exercise 1: Service Troubleshooting

**Solution:**

```bash
# Check service status
sudo systemctl status ssh
# Shows: active or inactive, enabled or disabled

# View service logs
sudo journalctl -u ssh -n 20
# Last 20 lines of SSH service logs

# More detailed logs
sudo journalctl -u ssh -xe
# -x = detailed, -e = tail (end of file)

# Check port listening
sudo netstat -tlnp | grep ssh
# Output: tcp 0 0 0.0.0.0:22 0.0.0.0:* LISTEN 1234/sshd

# Verify configuration
sshd -t
# Output: OK if no errors

# Restart service
sudo systemctl restart ssh
sudo systemctl status ssh
# Should show "active (running)"

# Test connectivity
ssh -v localhost
# Connect to test
```

**Output:**
```
● ssh.service - OpenSSH server
   Loaded: loaded (/lib/systemd/system/ssh.service)
   Active: active (running)
   
Process: 1234 ExecStart=/usr/sbin/sshd (code=exited)
Main PID: 5678 (sshd)
```

**Explanation:** systemctl = service manager. journalctl = logs. Port listening verification = service works.

---

## Exercise 2: Port Conflicts

**Solution:**

```bash
# Find process using port 8080
lsof -i :8080
# Output:
# COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
# java    1234 user 45u IPv4 0x1234 0t0 TCP *:8080

# Alternative method
sudo netstat -tlnp | grep 8080
# Output: LISTEN 1234/java

# Get process details
ps aux | grep 1234
# Show full process info

# Find by service name
sudo systemctl status myapp
# Shows if service is using port

# Check process command
cat /proc/1234/cmdline | tr '\0' ' '
# Show command line

# Resolve conflict (option 1: stop process)
sudo systemctl stop conflicting_service

# Resolve conflict (option 2: change port)
# Edit config and change port
# Restart service

# Verify port is free
sudo netstat -tlnp | grep 8080
# Should be empty

# Test connectivity
curl http://localhost:8080
```

**Output:**
```
# lsof -i :8080
COMMAND PID USER FD TYPE NODE NAME
java    1234 app  45u TCP *:8080 (LISTEN)

# After resolution:
# [empty output means port is free]
```

**Explanation:** lsof = list open files. netstat = network statistics. PID = process ID.

---

## Exercise 3: Disk Space Crisis

**Solution:**

```bash
# Find full filesystem
df -h
# Look for 100% or high usage

# Find culprit filesystem
df -h | grep 100%
# /dev/sda1 49G 49G 0 100% /

# Find large files
find / -type f -size +100M 2>/dev/null | head
# Files larger than 100MB

# Find large directories
du -sh /* | sort -h | tail
# Largest dirs in root

# Check common culprits
du -sh /var/log/*
du -sh /home/*
du -sh /tmp/*

# View log sizes
ls -lh /var/log/
# Syslog, auth.log might be huge

# Safe cleanup options:
# Option 1: Rotate logs
sudo logrotate -f /etc/logrotate.conf

# Option 2: Clear old logs
sudo journalctl --vacuum=time:7d
# Keep last 7 days

# Option 3: Remove temp files
sudo rm -f /tmp/*
sudo rm -f /var/tmp/*

# Verify space freed
df -h
# Check available space
```

**Output:**
```
# df -h
Filesystem     Size  Used Avail Use%
/dev/sda1       50G   49G  1.0G  98%

# After cleanup:
/dev/sda1       50G   30G   20G  60%
```

**Explanation:** du = disk usage. find = locate files. Cleanup = log rotation, temp files.

---

## Exercise 4: Permission Issues

**Solution:**

```bash
# Check current permissions
ls -l /path/to/file
# Shows: -rw-r--r-- 1 owner group

# Check ownership
stat /path/to/file
# Shows: Access: (0644/-rw-r--r--)
# Uid: (1000/user) Gid: (1000/group)

# Identify owner/group
ls -n /path/to/file
# Numeric IDs

# Test as different user
sudo -u otheruser cat /path/to/file
# Try to read as other user

# Check group membership
id username
# Groups for user

# Fix permission issues
chmod 644 /path/to/file
# Owner read/write, others read

# Fix ownership
sudo chown user:group /path/to/file
# Change owner and group

# Make executable
chmod +x /path/to/script.sh

# Recursive fix for directories
sudo chown -R user:group /path/to/dir
sudo chmod -R 755 /path/to/dir
# 755 = rwx for owner, rx for others

# Verify fix
ls -l /path/to/file
stat /path/to/file
```

**Output:**
```
# Before:
-rw-r--r-- 1 root root 1234 Jan 27 10:00 config.txt

# After:
-rw-r--r-- 1 user user 1234 Jan 27 10:00 config.txt

# Test:
$ cat /path/to/file
# Should work now
```

**Explanation:** chmod = change mode. chown = change owner. Permissions block access.

---

## Exercise 5: Application Crash

**Solution:**

```bash
# Check error messages
sudo journalctl -xe
# Latest errors with details

# Check service logs
sudo systemctl status myapp
# Status and recent output

# Test configuration syntax
myapp --check-config
# Application-specific test

# Verify dependencies
ldd /usr/bin/myapp
# Show required libraries

# Check library paths
ldconfig -p | grep libname
# Find library location

# Trace system calls
strace -f -e open,read,write /usr/bin/myapp
# See what app is doing

# Run app manually to see error
/usr/bin/myapp
# Direct output instead of systemd

# Check configuration file
cat /etc/myapp/config.conf
# Look for syntax errors

# Try starting with debug
strace -o /tmp/trace.log myapp start
# Write trace to file

# Analyze trace
grep -E "open|Error|denied" /tmp/trace.log
```

**Output:**
```
# journalctl
myapp[1234]: Error: Failed to load config from /etc/myapp/config.conf
myapp[1234]: Parsing error at line 42
myapp[1234]: Exit status: 1

# strace
open("/etc/myapp/config.conf", O_RDONLY) = 3
read(3, "...", 1024) = 1024
# Shows exact system calls
```

**Explanation:** journalctl = system logs. strace = system call tracing. Config files = app startup.

---

## Exercise 6: Network Connectivity

**Solution:**

```bash
# Check destination is reachable
ping -c 4 remote.server.com
# ICMP packets to test reachability

# Test DNS resolution
nslookup remote.server.com
# Shows: Server: 8.8.8.8
# Output: Address: 1.2.3.4

# Alternative DNS test
dig remote.server.com
# More detailed DNS info

# Trace network path
traceroute remote.server.com
# Shows hops to destination

# Check default route
ip route show
# Output: default via 192.168.1.1

# Test TCP connectivity
telnet remote.server.com 80
# Can also use nc (netcat)

# Check firewall rules
sudo iptables -L -n
# List all rules

# Check UFW status
sudo ufw status
# UFW firewall rules

# Verify port is open
sudo netstat -tlnp | grep :80
# Should show service listening

# Test from application
curl -v http://remote.server.com
# Verbose output shows connection

# Check network interface
ip addr show
# IP address and status

# Monitor network traffic
sudo tcpdump -i any -c 10
# Capture 10 packets
```

**Output:**
```
# ping
PING remote.server.com (1.2.3.4) 56(84) bytes of data.
64 bytes from 1.2.3.4: icmp_seq=1 ttl=64 time=5.23 ms

# nslookup
Server: 8.8.8.8
Address: 8.8.8.8#53
Name: remote.server.com
Address: 1.2.3.4

# curl -v
> GET / HTTP/1.1
< HTTP/1.1 200 OK
```

**Explanation:** ping = ICMP test. DNS = name resolution. Traceroute = network path. Firewall = access control.

---

## Exercise 7: Memory Leak Investigation

**Solution:**

```bash
# Monitor process memory
top -p <PID>
# Shows memory usage in real-time

# Check current memory
ps aux | grep myapp
# RSS = resident set size (actual memory)
# VSZ = virtual size

# Track memory over time
watch -n 1 'ps aux | grep myapp'
# Update every 1 second

# Get detailed memory info
cat /proc/<PID>/status | grep Vm
# Output:
# VmPeak: 2048000 kB (peak memory)
# VmRSS:  1024000 kB (current memory)

# Analyze memory map
cat /proc/<PID>/maps
# Memory regions

# Check for file descriptors (leak indicator)
ls -la /proc/<PID>/fd | wc -l
# Count open files

# Monitor system memory
free -h -s 1
# Update every 1 second

# Check swap usage
swapon -s
# Swap utilization

# Collect heap dump (if supported)
jmap -heap <PID>
# Java apps

# Generate report over time
for i in {1..10}; do
    echo "Sample $i: $(date)"
    ps aux | grep myapp
    sleep 10
done > memory_report.txt
```

**Output:**
```
# top -p 1234
PID  USER  PR  NI  VIRT  RES  SHR %CPU %MEM
1234 user  20  0   2.0G 1.5G 200M 5.2 18.5

# After 1 hour:
PID  USER  PR  NI  VIRT  RES  SHR %CPU %MEM
1234 user  20  0   2.5G 2.0G 200M 5.2 25.0  <- Growing!
```

**Explanation:** RSS = actual memory. VmPeak = peak used. Growth = leak indicator.

---

## Exercise 8: Cron Job Issues

**Solution:**

```bash
# View cron configuration
crontab -l
# User's cron jobs

# View system cron
cat /etc/crontab

# View logs
journalctl -S "1 hour ago" | grep CRON
# Show cron entries from last hour

# Check cron syntax
# Format: minute hour day month weekday command
# Example: 0 2 * * * /usr/local/bin/backup.sh

# Check if cron is running
systemctl status cron
# Should be active

# Verify command exists
which /usr/local/bin/backup.sh
# Command path correct?

# Test command manually
/usr/local/bin/backup.sh
# Run directly to check

# Check script permissions
ls -la /usr/local/bin/backup.sh
# Must be executable (+x)

# Check for errors in script
bash -n /usr/local/bin/backup.sh
# Syntax check

# Redirect output to log
# Add to crontab:
# 0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1

# Monitor execution
tail -f /var/log/backup.log
# Watch for output

# Use full paths in cron
# BAD: 0 2 * * * tar -czf backup.tar.gz /data
# GOOD: 0 2 * * * /bin/tar -czf backup.tar.gz /data
```

**Output:**
```
# crontab -l
0 2 * * * /usr/local/bin/backup.sh

# journalctl
cron[1234]: (user) CMD (/usr/local/bin/backup.sh)

# /var/log/backup.log
Backup started at 2025-01-27 02:00:00
Backup completed successfully
```

**Explanation:** Cron syntax = (minute hour day month weekday). Full paths = crucial. Logs = verify execution.

---

## Exercise 9: Performance Degradation

**Solution:**

```bash
# Check CPU usage
top
# CPU % per process
# Load average shows system load

# Check memory
free -h
# Used/Available memory

# Check disk I/O
iostat -x 1 5
# Disk I/O statistics

# Alternative I/O view
iotop
# Top I/O processes

# Check swap
free -h | grep Swap
# Swap usage

# System load average
uptime
# Output: load average: 2.5, 2.0, 1.8

# Process that uses CPU
top -o %CPU
# Sort by CPU usage

# Process that uses memory
top -o %MEM
# Sort by memory

# Detailed metrics
sar -u 1 10
# CPU stats every 1 second for 10 samples

# Disk space check
df -h
# Check for full disks

# Network interface stats
ethtool -S eth0
# Network errors/dropped

# System info to compare baseline
uname -a
# Kernel version
```

**Output:**
```
# top
PID  USER  %CPU  %MEM  COMMAND
1234 user  95.5  5.2   myapp
5678 user  3.2   12.0  firefox

# uptime
load average: 3.5, 2.8, 2.1  <- High load

# iostat
Device r/s w/s rMB/s wMB/s <- I/O intensive
sda    450 200 12.3  8.5
```

**Explanation:** Load average > CPU count = bottleneck. iostat = disk I/O. top = process monitoring.

---

## Exercise 10: Multi-Layer Troubleshooting

**Solution:**

```bash
# Layer 1: Service Level
systemctl status webserver
journalctl -u webserver -xe

# Layer 2: System Resources
top
free -h
df -h

# Layer 3: Network Level
netstat -tlnp | grep 8080
netstat -an | grep ESTABLISHED

# Layer 4: Application Level
/usr/bin/webserver --check-config
strace -o /tmp/trace.log /usr/bin/webserver

# Layer 5: Connectivity
curl -v http://localhost:8080
telnet localhost 8080

# Comprehensive check script:
#!/bin/bash
echo "=== System Status ==="
systemctl status webserver

echo "=== Recent Logs ==="
journalctl -u webserver -n 10

echo "=== Resource Usage ==="
ps aux | grep webserver

echo "=== Port Status ==="
netstat -tlnp | grep 8080

echo "=== Config Validation ==="
/usr/bin/webserver --check-config

echo "=== Connectivity ==="
curl -v http://localhost:8080
```

**Output:**
```
=== System Status ===
● webserver.service - Web Server
   Active: active (running)

=== Recent Logs ===
Jan 27 14:30:00 host webserver[1234]: Started successfully

=== Resource Usage ===
user 1234 0.2 0.5 52000 5000 ... /usr/bin/webserver

=== Port Status ===
tcp 0 0 0.0.0.0:8080 0.0.0.0:* LISTEN 1234/webserver

=== Config Validation ===
Configuration OK

=== Connectivity ===
> GET / HTTP/1.1
< HTTP/1.1 200 OK
```

**Explanation:** Systematic approach = layer by layer. Logs + resources = RCA. Verification = confirmation.
