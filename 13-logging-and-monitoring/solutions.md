# Logging and Monitoring: Solutions

## Exercise 1: View Journal Entries

**Solution:**

```bash
# Last 20 entries
journalctl -n 20

# Specific service
journalctl -u sshd -n 10
# Output: SSH daemon log entries

# Filter by level (errors only)
journalctl -p err
# or
journalctl -p 3
# (0=emergency, 1=alert, 2=critical, 3=error)

# Boot messages
journalctl -b
# All entries since last boot

# Show entry details
journalctl -o verbose
# Shows all fields (longer output)

# With timestamps
journalctl -n 20 --output=short-precise
```

**Explanation:** `-n` = number. `-u` = unit. `-p` = priority. `-b` = this boot.

---

## Exercise 2: Filter and Search Logs

**Solution:**

```bash
# Search for string
journalctl | grep "failed"

# SSH failures specifically
journalctl -u sshd | grep "Failed"
# or
journalctl -u sshd -p err

# System errors
journalctl -p err -b
# Errors from this boot

# Time range
journalctl --since "2024-01-20 10:00:00" --until "2024-01-20 15:00:00"
# or
journalctl --since "1 hour ago"

# Combine filters
journalctl -u sshd -p err --since "today"
# SSH errors since midnight

# Count occurrences
journalctl | grep "error" | wc -l
```

**Explanation:** Journalctl filters are faster than grep. Combine for precision.

---

## Exercise 3: Follow Live Logs

**Solution:**

```bash
# Follow in real-time
journalctl -f
# Keeps showing new entries

# Filter while following
journalctl -u sshd -f
# Follow SSH daemon only

# Follow with priority filter
journalctl -p err -f
# Only show errors

# Generate event and watch
# In another terminal:
sudo systemctl restart ssh

# Back to journalctl -f terminal:
# See SSH restart messages appear live

# Stop following
# Press Ctrl+C

# Tail traditional log
tail -f /var/log/syslog
# Same concept, older style
```

**Explanation:** `-f` = follow (like `tail -f`). Shows entries as they happen.

---

## Exercise 4: View Traditional Log Files

**Solution:**

```bash
# List log directory
ls -lh /var/log/
# Output: auth.log, syslog, kernel, dmesg, etc.

# View syslog (all system messages)
tail -100 /var/log/syslog
# Last 100 lines

# Auth failures
grep "Failed password" /var/log/auth.log
# All SSH/sudo auth failures

# View dmesg (kernel messages)
dmesg | head -50

# Compare formats
# journalctl: structured, searchable
# /var/log: traditional text files

# Search across logs
grep -r "error" /var/log/*.log | head -10

# File sizes
du -sh /var/log/*
# Identify large logs
```

**Explanation:** Traditional logs in `/var/log/`. Journalctl is newer, more powerful.

---

## Exercise 5: Analyze Boot Sequence Logs

**Solution:**

```bash
# Boot messages
journalctl -b
# All messages from last boot

# Find errors during boot
journalctl -b -p err
# Boot errors only

# Service startup times
systemd-analyze blame | head -10
# Slowest services

# Boot dependencies
systemd-analyze critical-chain
# Path to graphical-target

# Compare boots
journalctl --list-boots
# Output: [-2] ... [-1] ... [0]

# Previous boot logs
journalctl -b -1 | head -20

# Find failed units
journalctl -b | grep "failed"
# Any failed services

# Boot time summary
journalctl -b | tail -5
# Usually shows "Reached target"
```

**Explanation:** `-b` = this boot. `-b -1` = previous boot. List shows all boots.

---

## Exercise 6: Monitor System Metrics

**Solution:**

```bash
# Interactive top
top
# Press 'q' to exit

# Better: htop
htop
# More user-friendly

# CPU/memory/IO stats
vmstat 1 5
# Every 1 second, 5 times

# Disk I/O
iostat -x 1 5

# Check uptime and load
uptime
# Output: 10:30:00 up 5 days, load average: 0.45, 0.52, 0.48

# Memory details
free -h

# Process by CPU
ps aux --sort=-%cpu | head -10

# Network connections
ss -tan | wc -l

# Overall system status
systemctl status
# Shows default target + resources
```

**Explanation:** `top` = overall view. `vmstat` = detailed. `uptime` = quick check.

---

## Exercise 7: Check Log Disk Usage

**Solution:**

```bash
# Journal disk usage
journalctl --disk-usage
# Output: Archived and volatile journals take up 1.2G

# Log directory sizes
du -sh /var/log/*
# Find large log files

# Largest files
ls -lhS /var/log/* | head -10

# Total /var/log size
du -sh /var/log

# Understand limits
# Journal max: usually 10% of /var (or 4GB default)

# Safe deletion
sudo journalctl --vacuum-time=30d
# Keep 30 days

sudo journalctl --vacuum-size=500M
# Keep 500MB
```

**Explanation:** Logs grow over time. Rotate to save space. `--vacuum-*` cleans safely.

---

## Exercise 8: Enable Persistent Journal

**Solution:**

```bash
# Check if persistent
ls -la /var/log/journal/
# If empty/missing = not persistent

# Create directory for persistent
sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal

# Restart journald
sudo systemctl restart systemd-journald

# Verify persistence
journalctl --list-boots
# Shows multiple boots (if rebooted)

# View across boots
journalctl -b -1 | head
# Previous boot logs

# Set permissions for group
ls -la /var/log/journal/
# Should show journald ownership
```

**Explanation:** Default = volatile (lost on reboot). Persistent = stored to disk.

---

## Exercise 9: Monitor Specific Service

**Solution:**

```bash
# View service logs
journalctl -u nginx -n 20
# Last 20 nginx entries

# Follow service in real-time
journalctl -u sshd -f

# Find errors
journalctl -u mysql -p err
# MySQL errors only

# Service startup
journalctl -u docker.service | grep "Started\|Finished"

# Over time window
journalctl -u postgresql --since "1 hour ago"

# With timestamps
journalctl -u sshd --no-pager -o short-precise

# Service restart tracking
journalctl -u sshd | grep "Stopping\|Starting\|Started"
```

**Explanation:** `-u unit` = filter by service. Combine with `-f`, `-p`, `--since` filters.

---

## Exercise 10: Create Monitoring Baseline

**Solution:**

```bash
# System monitoring snapshot
cat > system_snapshot.sh << 'EOF'
#!/bin/bash
echo "=== System Monitoring Snapshot ==="
echo "Date: $(date)"
echo ""
echo "=== Load Average ==="
uptime
echo ""
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Disk Usage ==="
df -h /
echo ""
echo "=== Top 5 CPU Processes ==="
ps aux --sort=-%cpu | head -6
echo ""
echo "=== Top 5 Memory Processes ==="
ps aux --sort=-%mem | head -6
echo ""
echo "=== Failed Services ==="
systemctl --failed
echo ""
echo "=== Recent Errors ==="
journalctl -p err -n 5 --no-pager
EOF

chmod +x system_snapshot.sh
./system_snapshot.sh

# Monitor for 5 minutes
watch -n 30 "uptime && free -h"
# Updates every 30 seconds

# Save baseline
./system_snapshot.sh > baseline_$(date +%Y%m%d).txt
```

**Explanation:** Baseline = reference point. Track changes over time. Detect anomalies.
