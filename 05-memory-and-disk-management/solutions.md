# Memory and Disk Management: Solutions

## Exercise 1: Memory Overview

**Solution:**

```bash
# Check total RAM installed
free -h
# Output:
#               total        used        free      shared  buff/cache   available
# Mem:           15Gi       3.2Gi       8.5Gi      256Mi       3.2Gi      11Gi

# Check in megabytes
free -m
# Shows memory in MB (1GB = 1024MB)

# Check in bytes
free -b
# Shows memory in bytes

# View swap space
free -h | grep Swap
# Output: Swap: 4.0Gi 0B 4.0Gi

# Calculate percentage
# Used / Total × 100 = percentage
# 3.2Gi / 15Gi × 100 = 21.3%
```

**Explanation:** `free` shows RAM status. `-h` = human-readable. Swap = disk backup if RAM full.

---

## Exercise 2: Top Memory Consumers

**Solution:**

```bash
# Top 10 memory consumers
ps aux --sort=-%mem | head -10
# Output:
# USER    PID %CPU %MEM    VSZ   RSS COMMAND
# root      1  0.0  0.5 102436  8240 /sbin/init
# user   1234  2.3  12.5 1234567 189234 python3

# Show name, PID, and memory %
ps aux --sort=-%mem | awk '{print $2, $12, $4}' | head -10

# Check specific process
ps aux | grep "python" | grep -v grep

# Monitor changes
watch -n 1 'ps aux --sort=-%mem | head -5'
```

**Explanation:**
- `%MEM` = percentage of total RAM
- `VSZ` = virtual memory size
- `RSS` = resident memory (actual RAM used)

---

## Exercise 3: Disk Space Overview

**Solution:**

```bash
# Show all mounted filesystems
df -h
# Output:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        50G   12G   38G  24% /
# /dev/sda2       200G   85G  115G  43% /home

# Root filesystem usage
df -h / | tail -1
# Output: /dev/sda1 50G 12G 38G 24% /

# /home partition usage
df -h /home | tail -1

# Most free space
df -h | awk 'NR>1' | sort -k4 -rh | head -3

# Overall usage
df -h | tail -1
```

**Explanation:** `Use%` shows percentage used. 90%+ is critical. Need to clean up soon.

---

## Exercise 4: Find Largest Directories

**Solution:**

```bash
# Largest in /home
du -sh /home/* | sort -rh | head -5
# Output:
# 45G   /home/user1
# 12G   /home/user2
# 2.3G  /home/shared

# Largest in /var
du -sh /var/* | sort -rh | head -5

# System-wide top 5
du -sh /* | sort -rh | head -5
# Output:
# 45G   /home
# 25G   /var
# 12G   /usr

# Save to file
du -sh /* | sort -rh > disk_usage.txt
```

**Explanation:** `du -sh` = disk usage summary in human format. Then sort by size descending.

---

## Exercise 5: Locate Large Files

**Solution:**

```bash
# Files larger than 50MB
find / -size +50M -type f 2>/dev/null
# Output:
# /var/log/huge.log
# /home/user/large_file.iso

# Files larger than 500MB
find / -size +500M -type f 2>/dev/null

# In /home only
find /home -size +50M -type f 2>/dev/null

# Top 10 largest files
find / -type f 2>/dev/null -exec ls -lh {} \; | \
  sort -k5 -rh | head -10

# With modification time
find /home -size +100M -type f -printf "%s %T@ %p\n" | \
  sort -rn | head -10
```

**Explanation:** `find -size +50M` finds files bigger than 50MB. `-type f` = files only.

---

## Exercise 6: Filesystem and Mount Analysis

**Solution:**

```bash
# Show all mounts
mount | head -10
# Output:
# /dev/sda1 on / type ext4 (rw,relatime)
# /dev/sda2 on /home type ext4 (rw,relatime)

# Block device info
lsblk
# Output:
# NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda      8:0    0  250G  0 disk
# ├─sda1   8:1    0   50G  0 part /
# └─sda2   8:2    0  200G  0 part /home

# Filesystem types
df -T
# Output:
# Filesystem     Type     Size  Used Avail Use% Mounted on
# /dev/sda1      ext4      50G   12G   38G  24% /

# Root filesystem
df -T / | tail -1

# Mount options
mount | grep "/dev/sda1"
```

**Explanation:** `lsblk` shows partition layout. `df -T` shows filesystem types (ext4, xfs, etc.).

---

## Exercise 7: Inode Usage Analysis

**Solution:**

```bash
# Check inode usage
df -i
# Output:
# Filesystem    Inodes IUsed IFree IUse% Mounted on
# /dev/sda1   3276800 450000 2826800  14% /
# /dev/sda2   13107200 5400000 7707200 41% /home

# Identify high inode usage
df -i | awk 'NR>1' | awk '$5>80 {print $0}'
# Finds filesystems over 80% inode usage

# Find directories with many files
find /home -maxdepth 2 -type d -exec sh -c \
  'echo "$(find "$1" -type f | wc -l) $1"' _ {} \; | \
  sort -rn | head -10

# Count files in directory
find /var -type f | wc -l
# Output: 15234 (files in /var)
```

**Explanation:** Inodes store file metadata. Each file = 1 inode. More files = more inode usage.

---

## Exercise 8: Memory Monitoring Over Time

**Solution:**

```bash
# Create monitoring script
cat > monitor_memory.sh << 'EOF'
#!/bin/bash
echo "Timestamp,Total,Used,Free" > memory.csv
for i in {1..10}; do
    free -m | awk 'NR==2 {
        print strftime("%Y-%m-%d %H:%M:%S") "," $2 "," $3 "," $4
    }' >> memory.csv
    sleep 30
done
EOF

chmod +x monitor_memory.sh
./monitor_memory.sh

# View results
cat memory.csv

# Analyze trend
tail -5 memory.csv
# Compare first and last entries to see trend
```

**Explanation:** Creates CSV log with timestamps. Can analyze memory trend over 5 minutes.

---

## Exercise 9: Disk Activity Monitoring

**Solution:**

```bash
# Install if needed
sudo apt install sysstat

# Check I/O statistics
iostat -x 1 5
# Output shows: 
# rrqm/s, wrqm/s, r/s, w/s, rMB/s, wMB/s, avgqu-sz, await, util%

# Monitor with iotop
sudo iotop -n 5 -b
# Shows processes causing I/O

# Virtual memory statistics
vmstat 1 5
# Shows: procs, memory, swap, io, system, cpu

# Disk usage example:
# util% = 45% means disk busy 45% of time
# await = latency in milliseconds
```

**Explanation:** `iostat` shows disk performance. `util%` >80% = disk bottleneck.

---

## Exercise 10: Clean Up and Optimize

**Solution:**

```bash
# Find old log files (>30 days)
find /var/log -type f -mtime +30
# Output: list of files older than 30 days

# Calculate space to free
find /var/log -type f -mtime +30 -exec du -sh {} \; | \
  awk '{sum+=$1} END {print sum}'

# Find temp files
find /tmp -type f -atime +7
# Not accessed for 7 days

# Calculate cleanup potential
du -sh /tmp
du -sh /var/log

# Create cleanup script (don't execute)
cat > cleanup.sh << 'EOF'
#!/bin/bash
# Cleanup script - review before running

echo "Old log files:"
find /var/log -type f -mtime +30

echo "Temp files:"
find /tmp -type f -atime +7

# Generate report
{
  echo "=== System Cleanup Report ==="
  echo "Date: $(date)"
  echo ""
  echo "Log files >30 days old:"
  find /var/log -type f -mtime +30 | wc -l
  echo "Space: $(find /var/log -type f -mtime +30 -exec du -sh {} \; | \
    awk '{sum+=$1} END {print sum}')"
} > cleanup_report.txt
EOF

chmod +x cleanup.sh
cat cleanup_report.txt
```

**Explanation:** Safe cleanup approach: analyze first, log findings, then act. Never delete without verification.
