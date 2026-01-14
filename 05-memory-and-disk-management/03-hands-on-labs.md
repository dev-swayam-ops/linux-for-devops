# Memory and Disk Management: Hands-On Labs

8 progressive labs covering memory analysis, disk management, and performance troubleshooting. All labs use safe, sandboxed approaches.

---

## Lab 1: Understanding System Memory with free and /proc

**Duration**: 20 minutes
**Difficulty**: Beginner
**Objective**: Understand memory terminology and how to read memory metrics

### Setup

```bash
# Create a working directory
mkdir -p ~/memory-disk-labs
cd ~/memory-disk-labs

# Copy some scripts to work with
cat > memory-pressure.sh << 'EOF'
#!/bin/bash
# Create memory pressure for testing

# Check current memory
echo "Initial state:"
free -h
echo ""

# Create a 2GB file in /tmp (doesn't actually use RAM much, just disk)
dd if=/dev/zero of=/tmp/large-file bs=1M count=2048 2>/dev/null
echo "Created 2GB file in /tmp"
free -h
echo ""

# Load 500MB into memory (creates cache)
cat /tmp/large-file > /dev/null &
echo "Loading file into cache..."
sleep 2

echo "After loading:"
free -h
echo ""

# Cleanup
rm /tmp/large-file
echo "Cleaned up"
EOF

chmod +x memory-pressure.sh
```

### Hands-On Steps

**Step 1: View current memory**
```bash
free -h
# Output example:
#              total        used        free      shared  buff/cache   available
# Mem:           15Gi        9.4Gi       2.0Gi       1.0Gi       4.2Gi       3.7Gi
# Swap:          7.9Gi          0B       7.9Gi
```

**Interpretation**:
- `total`: 15 GB of physical RAM
- `used`: 9.4 GB currently in use (but may include cache)
- `free`: 2.0 GB truly unused
- `buff/cache`: 4.2 GB can be freed if needed
- `available`: 3.7 GB actually available without swapping (most important!)

**Step 2: View memory in different units**
```bash
# Megabytes
free -m

# Kilobytes
free -k

# Bytes
free -b

# Repeated every 2 seconds
free -h -s 2
# Press Ctrl+C to stop
```

**Step 3: Examine /proc/meminfo (raw kernel data)**
```bash
cat /proc/meminfo | head -20
# MemTotal:       16403360 kB
# MemFree:         2097152 kB
# MemAvailable:    3932160 kB
# Buffers:          512000 kB
# Cached:          3932160 kB
# SwapTotal:       8388608 kB
# SwapFree:        8388608 kB
```

**Key insight**: This is what `free` reads from

**Step 4: Calculate memory percentage**
```bash
# What percentage of RAM is in use?
free -b | awk 'NR==2 {used=$3; total=$2; printf "Used: %.1f%%\n", (used/total)*100}'

# What percentage is available (not under pressure)?
free -b | awk 'NR==2 {avail=$7; total=$2; printf "Available: %.1f%%\n", (avail/total)*100}'
```

**Step 5: Understand buffers vs cache**
```bash
# Buffers: Kernel data structures and I/O buffers
grep Buffers /proc/meminfo

# Cached: Filesystem cache (pages from files)
grep Cached /proc/meminfo

# Together they make "buff/cache" in free output
```

### Verification

```bash
# Expected output: free command shows all categories
free -h | grep -q "Mem:" && echo "✓ Memory metrics visible"

# Should have some cache
free -h | awk 'NR==2 {cache=$6; if(cache>0) print "✓ Cache present:", cache}'
```

### Cleanup

```bash
# Nothing to clean - just display output
```

---

## Lab 2: Process Memory Analysis with top and ps

**Duration**: 25 minutes
**Difficulty**: Beginner
**Objective**: Identify memory hogs and understand VSZ vs RSS

### Setup

```bash
# Start a memory-consuming process in background
python3 -c "
import sys
data = []
for i in range(100):
    data.append('X' * 1024 * 1024)  # 1MB each, 100MB total
print('Process consuming ~100MB')
import time
time.sleep(600)  # Sleep for 10 minutes
" &

MEMORY_PID=$!
echo "Started memory process: $MEMORY_PID"

# Also start another to compare
sleep 500 &
SLEEP_PID=$!
echo "Started sleep process: $SLEEP_PID"
```

### Hands-On Steps

**Step 1: Get process snapshot with ps**
```bash
# Show all processes with memory
ps aux | head -15

# Sort by memory usage (largest first)
ps aux --sort=-%mem | head -10
# USER  PID %CPU %MEM   VSZ   RSS TTY STAT START   TIME COMMAND
# root 1234  0.5  1.5 204800 245760 ?   S    10:00   0:05 python3

# Extract just our test processes
ps aux | grep "python\|sleep" | grep -v grep
```

**Step 2: Understand VSZ vs RSS**
```bash
# VSZ: Virtual memory size (total allocated)
# RSS: Resident Set Size (actually in RAM right now)

ps -p $MEMORY_PID -o pid=,user=,vsz=,rss=,cmd=
# 1234 root 204800 245760 python3

# The difference: VSZ-RSS = not in RAM (either swapped or not yet paged in)
ps -p $MEMORY_PID -o pid=,vsz=,rss= | awk '{print "VSZ: " $2 "KB, RSS: " $3 "KB, Difference: " ($2-$3) "KB"}'
```

**Step 3: Sort processes by memory**
```bash
# Top 5 memory consumers
ps aux --sort=-%mem | head -6 | awk 'NR>1 {printf "%6.1f%% %-6s %8.0f MB %s\n", $4, $2, $6/1024, $11}'

# Total memory by user
ps aux | awk 'NR>1 {sum[$1]+=$6} END {for (u in sum) printf "%15s: %8.0f MB\n", u, sum[u]/1024}'
```

**Step 4: Use top (interactive)**
```bash
# Launch top
top

# In top, press:
# M = sort by memory
# P = sort by CPU
# u = filter by user
# k = kill process
# q = quit

# Exit with 'q'
```

**Step 5: Get top output non-interactively**
```bash
# Single snapshot
top -b -n 1 | head -20

# Sort by memory (non-interactive)
top -b -n 1 -o %MEM | head -15

# Sort by CPU
top -b -n 1 -o %CPU | head -15

# Get just our processes
top -b -n 1 | grep "python\|sleep"
```

**Step 6: Show process memory map**
```bash
# Detailed memory layout of process
pmap $MEMORY_PID | head -20

# Summary of regions
pmap -x $MEMORY_PID

# Show total
pmap -x $MEMORY_PID | tail -1
```

### Verification

```bash
# Verify processes visible
ps aux | grep -q python && echo "✓ Python process found"

# Verify top output
top -b -n 1 | grep -q python && echo "✓ Top shows process"

# Verify pmap works
pmap $MEMORY_PID | grep -q total && echo "✓ pmap shows memory map"
```

### Cleanup

```bash
# Kill test processes
kill $MEMORY_PID $SLEEP_PID 2>/dev/null
wait $MEMORY_PID $SLEEP_PID 2>/dev/null
echo "Cleaned up test processes"
```

---

## Lab 3: Disk Space Overview with df

**Duration**: 15 minutes
**Difficulty**: Beginner
**Objective**: Understand filesystem space usage

### Setup

```bash
# No setup needed - we'll use system filesystems
```

### Hands-On Steps

**Step 1: View all filesystems**
```bash
df
# Filesystem     1K-blocks     Used Available Use% Mounted on
# /dev/sda1      104857600 52428800  52428800  50% /
# /dev/sda2      524288000 314572800 209715200  60% /home
# tmpfs            8388608        0   8388608   0% /run

# Same in human-readable format
df -h
```

**Step 2: Identify filesystem limits**
```bash
# Show space (bytes)
df -B1

# Show space (megabytes)
df -BM

# Show space (gigabytes)
df -BG
```

**Step 3: Check inode usage (file count limits)**
```bash
# Show inode usage
df -i
# Filesystem     Inodes   IUsed   IFree IUse% Mounted on
# /dev/sda1      6553600 3276800 3276800  50% /
# /dev/sda2     26214400 5242880 20971520  20% /home

# Key insight: Space and inodes are separate limits
# Can run out of inodes while space remains!
```

**Step 4: Show specific filesystem**
```bash
# Just root filesystem
df -h /

# Just /tmp
df -h /tmp

# Just /home
df -h /home
```

**Step 5: Analyze usage percentage**
```bash
# Show filesystem with highest usage
df -h | sort -k5 -rn | head -5

# Alert if any filesystem > 80%
df | awk 'NR>1 && $(NF-1) ~ /[0-9]+/ {
  used=$(NF-1)
  if(used > 80) print "⚠️  " $NF " is " used "% full"
}'

# Show all as percentage
df -h | awk 'NR>1 {printf "%-20s: %6s\n", $NF, $5}'
```

**Step 6: Calculate total usage**
```bash
# Total across all filesystems
df | tail -1

# Just total space
df | tail -1 | awk '{print "Total: " $2 " | Used: " $3 " | Available: " $4}'
```

### Verification

```bash
# Should show root filesystem
df -h | grep -q "/$" && echo "✓ Root filesystem found"

# Should show inodes
df -i | grep -q Inode && echo "✓ Inode info available"

# Should show percentages
df -h | grep -q "%" && echo "✓ Percentage shown"
```

### Cleanup

```bash
# No cleanup needed
```

---

## Lab 4: Finding Large Files and Freeing Space

**Duration**: 30 minutes
**Difficulty**: Intermediate
**Objective**: Find and safely remove large files and old logs

### Setup

```bash
# Create test log files to analyze
mkdir -p ~/disk-lab/var/log
cd ~/disk-lab

# Create large test files
for i in 1 2 3; do
  dd if=/dev/zero of=var/log/app-$i.log bs=1M count=50 2>/dev/null
  echo "Created 50MB log file: var/log/app-$i.log"
done

# Create old test files
touch -t 202201010000 var/log/old-1.log var/log/old-2.log
dd if=/dev/zero of=var/log/old-1.log bs=1M count=100 2>/dev/null
dd if=/dev/zero of=var/log/old-2.log bs=1M count=80 2>/dev/null
```

### Hands-On Steps

**Step 1: Find largest files in directory**
```bash
# Find large files (> 10MB)
find ~/disk-lab -type f -size +10M -exec ls -lh {} \; | awk '{print $5, $9}'

# Find largest N files
find ~/disk-lab -type f -exec ls -Lh {} \; | sort -k5 -hr | head -10

# Show percentage of total directory
du -sh ~/disk-lab
find ~/disk-lab -type f -exec du -h {} \; | awk '{sum+=$1; print} END {print "Total:", sum}'
```

**Step 2: Find old files (not modified recently)**
```bash
# Files not modified in last 30 days
find ~/disk-lab -type f -mtime +30 -ls
# 12345 100 -rw-r--r-- 1 user group 104857600 Jan 1 00:00 var/log/old-1.log

# Files modified between 30-60 days ago
find ~/disk-lab -type f -mtime +30 -mtime -60

# Files accessed (read) > 90 days ago
find ~/disk-lab -type f -atime +90
```

**Step 3: Show file age analysis**
```bash
# List files with modification time
find ~/disk-lab -type f -printf '%T@ %Tc %p\n' | sort -n

# Find files last modified date
for file in ~/disk-lab/var/log/*.log; do
  last_mod=$(stat -c %y "$file" | cut -d' ' -f1)
  age_days=$(( ($(date +%s) - $(date -d "$last_mod" +%s)) / 86400 ))
  size=$(du -h "$file" | cut -f1)
  echo "$size | $age_days days old | $file"
done | sort -t'|' -k2 -rn
```

**Step 4: Calculate cleanup potential**
```bash
# Show space that could be freed
total_old=$(find ~/disk-lab -type f -mtime +30 -exec du -bc {} \; | tail -1 | awk '{print $1}')
total_all=$(du -bc ~/disk-lab | tail -1 | awk '{print $1}')

if [ "$total_old" -gt 0 ]; then
  percent=$(echo "scale=1; ($total_old/$total_all)*100" | bc)
  echo "Could free: $(numfmt --to=iec $total_old 2>/dev/null || du -h <<< $total_old) ($percent%)"
fi
```

**Step 5: Safely delete old files (with confirmation)**
```bash
# Preview what would be deleted (DRY RUN)
find ~/disk-lab -type f -mtime +30 -print

# Delete with confirmation (safer)
find ~/disk-lab -type f -mtime +30 -exec rm -i {} \;

# Or use older tools to double-check
find ~/disk-lab -type f -mtime +30 -ls  # List first
# Then: find ~/disk-lab -type f -mtime +30 -delete

# Verify cleanup
du -sh ~/disk-lab
```

**Step 6: Compress remaining files**
```bash
# Show which files are candidates for compression
find ~/disk-lab -type f -name "*.log" -exec ls -lh {} \;

# Compress old logs (demonstration)
for file in ~/disk-lab/var/log/app-*.log; do
  gzip -v "$file"
  # Creates .gz version, removes original
done

# Verify compression
ls -lh ~/disk-lab/var/log/
```

### Verification

```bash
# Verify old files identified
find ~/disk-lab -type f -mtime +30 -printf '%f\n' | grep -q old && echo "✓ Old files found"

# Verify files deleted
[ ! -f ~/disk-lab/var/log/old-1.log ] && echo "✓ Old files cleaned"

# Verify remaining files
ls ~/disk-lab/var/log/*.gz 2>/dev/null && echo "✓ Remaining files compressed"
```

### Cleanup

```bash
# Remove test directory
rm -rf ~/disk-lab
echo "Cleaned up test directory"
```

---

## Lab 5: Understanding Block Devices and Partitions

**Duration**: 20 minutes
**Difficulty**: Intermediate
**Objective**: See filesystem structure without modifying anything

### Setup

```bash
# No setup needed - view existing structure
```

### Hands-On Steps

**Step 1: List block devices**
```bash
# Simple tree view
lsblk

# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda           8:0    0  500G  0 disk
# ├─sda1        8:1    0  200M  0 part /boot
# ├─sda2        8:2    0  100G  0 part /
# └─sda3        8:3    0  400G  0 part /home

# More detailed
lsblk -a

# With all columns
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
```

**Step 2: Show partition table**
```bash
# Non-destructive view of partition table
fdisk -l /dev/sda 2>/dev/null | head -20
# Disk /dev/sda: 500 GiB, ...
# Device     Boot    Start      End  Sectors Size Id Type
# /dev/sda1  *        2048  411647   409600 200M 83 Linux
# /dev/sda2       411648 2560000  2148352 1.0G 83 Linux

# View all disks
sudo fdisk -l 2>/dev/null | grep "^Disk /dev"
```

**Step 3: Get filesystem information**
```bash
# Show UUID and type
blkid 2>/dev/null

# /dev/sda1: UUID="a1b2c3d4-e5f6-7890-1234-567890abcdef" TYPE="ext4"
# /dev/sda2: UUID="f1e2d3c4-b5a6-7890-1234-567890abcdef" TYPE="ext4"

# Show just UUIDs
blkid -s UUID -o value 2>/dev/null

# Show just types
blkid -s TYPE -o value 2>/dev/null
```

**Step 4: View mount points and hierarchy**
```bash
# Show mounted filesystems as tree
findmnt

# Show with device names
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS

# Show unused mount points
findmnt | grep -v "/"
```

**Step 5: Check filesystem labels**
```bash
# Get labels for filesystems
blkid -s LABEL -o value 2>/dev/null | grep -v "^$"

# List with device and label
blkid -o full 2>/dev/null | grep LABEL
```

**Step 6: Examine /etc/fstab (startup configuration)**
```bash
# View what filesystems mount at boot
cat /etc/fstab
# UUID=a1b2c3d4  /          ext4  defaults,errors=remount-ro   0  1
# UUID=b5c6d7e8  /home      ext4  defaults,noatime              0  2
# /dev/sda3      none       swap  sw                            0  0

# Understand columns:
# 1. Device/UUID to mount
# 2. Mount point
# 3. Filesystem type
# 4. Mount options
# 5. Backup flag (0=no, 1=yes for dump)
# 6. Check order (0=no, 1=root, 2=others for fsck)
```

### Verification

```bash
# Should show block devices
lsblk | grep -q sda && echo "✓ Block devices visible"

# Should show UUID
blkid 2>/dev/null | grep -q UUID && echo "✓ Filesystem UUID visible"

# Should show mounts
findmnt | grep -q "/" && echo "✓ Mount points visible"

# Should show fstab
[ -f /etc/fstab ] && echo "✓ fstab accessible"
```

### Cleanup

```bash
# No cleanup needed - nothing was modified
```

---

## Lab 6: Disk I/O Monitoring and Analysis

**Duration**: 35 minutes
**Difficulty**: Intermediate
**Objective**: Understand and identify disk I/O bottlenecks

### Setup

```bash
# Create a background I/O workload
mkdir -p ~/io-lab
cd ~/io-lab

# Create a script that generates I/O
cat > generate-io.sh << 'EOF'
#!/bin/bash

# Generate read I/O
for i in {1..5}; do
  dd if=/dev/zero of=test-file-$i.img bs=1M count=100 2>/dev/null &
  sleep 0.5
done

# Generate read I/O
for i in {1..3}; do
  cat test-file-$i.img > /dev/null &
done

wait
EOF

chmod +x generate-io.sh

echo "Setup complete - I/O generation script ready"
```

### Hands-On Steps

**Step 1: Baseline I/O statistics**
```bash
# Get current I/O statistics
iostat
# Linux 5.10.0-13-generic (hostname) 01/10/2024
#
# avg-cpu:  %user   %nice %system %iowait  %steal   %idle
#           10.5     0.0    3.2     5.2     0.0    81.1
#
# Device      tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
# sda        45.23     1234.56       678.90    1234567    678900

# Watch trend over time
iostat 1 5  # 1-second interval, 5 iterations
```

**Step 2: Detailed I/O statistics**
```bash
# Extended I/O information
iostat -x 1 3
# Device   r/s  w/s  rMB/s  wMB/s  r_await  w_await %util
# sda     100   50   12.3    5.4    3.2ms    4.1ms   85.2

# Interpretation:
# - r/s: reads per second
# - w/s: writes per second
# - %util: percentage of time device was busy (>70% = bottleneck)
# - r_await: average read latency in milliseconds
# - w_await: average write latency in milliseconds
```

**Step 3: Generate I/O and monitor**
```bash
# Terminal 1: Generate I/O
cd ~/io-lab
./generate-io.sh

# Terminal 2: Monitor while workload runs
iostat -x 1 10

# Look for:
# - High %util (70-100%)
# - High latency (r_await, w_await)
# - High throughput (MB/s)
```

**Step 4: Per-process I/O analysis**
```bash
# Check which processes doing I/O
iotop -b -n 1

# Or in non-interactive mode (if available)
iotop -b -n 1 -o  # Show only processes doing I/O

# Watch for changes
watch -n 1 'iotop -b -n 1 | head -20'
```

**Step 5: Virtual memory and I/O correlation**
```bash
# Monitor memory pressure and I/O together
vmstat 1 5
# procs -----------memory---------- ---swap-- -----io-----
# r  b   swpd   free   buff  cache   si   so    bi    bo
# 2  1   1024  2048   512  8192    0    0    10    20

# Key indicators:
# - si/so: Swap in/out (paging to disk) - BAD
# - bi/bo: Disk blocks in/out
# - If high si/so while high %util = memory pressure causing I/O
```

**Step 6: Analyze I/O pattern**
```bash
# Take baseline
iostat -x > baseline.txt

# Let workload run for 30 seconds
sleep 30

# Take after snapshot
iostat -x > after.txt

# Compare
diff baseline.txt after.txt

# Expected changes: higher r/s, w/s, MB/s, and %util
```

**Step 7: Calculate system bottleneck**
```bash
# Collect metrics
iostat -x 1 1 > io_snapshot.txt

# Extract utilization
awk '/sda/ {print "Disk utilization: " $NF "%"}' io_snapshot.txt

# Monitor CPU during I/O
top -b -n 1 | head -3

# If CPU low but disk %util high = I/O bottleneck
# If CPU high but disk %util low = CPU bottleneck
```

### Verification

```bash
# Should have I/O data
[ -f ~/io-lab/baseline.txt ] && echo "✓ Baseline captured"

# Should see iostat output
iostat 1 1 | grep -q sda && echo "✓ I/O stats available"

# Should have test files
ls ~/io-lab/test-file-*.img 2>/dev/null && echo "✓ Test files created"
```

### Cleanup

```bash
# Stop any running I/O workloads
pkill -f generate-io

# Remove test files
rm -rf ~/io-lab
echo "Cleaned up I/O test files"
```

---

## Lab 7: Memory Pressure and Swap Analysis

**Duration**: 30 minutes
**Difficulty**: Intermediate
**Objective**: Observe system behavior under memory pressure

### Setup

```bash
# Create a controlled memory pressure scenario
mkdir -p ~/memory-lab
cd ~/memory-lab

# Create a program that uses memory incrementally
cat > memory-consumer.py << 'EOF'
#!/usr/bin/env python3
import sys
import time

size_mb = int(sys.argv[1]) if len(sys.argv) > 1 else 100

data = []
for i in range(size_mb):
    data.append('X' * (1024 * 1024))  # 1MB chunks
    if i % 10 == 0:
        print(f"Allocated {i}MB...", flush=True)

print(f"Allocated {size_mb}MB total, sleeping for 10 minutes...")
time.sleep(600)
EOF

chmod +x memory-consumer.py

echo "Memory pressure test setup complete"
```

### Hands-On Steps

**Step 1: Baseline memory state**
```bash
# Record initial state
free -h
vmstat 1 1

# Record swap status
swapon -s || free -h | grep -i swap
```

**Step 2: Monitor available memory threshold**
```bash
# Check when system starts using swap
available_mb=$(free -m | awk 'NR==2 {print $7}')
echo "Available memory: ${available_mb}MB"

# Create pressure slightly above swap threshold
threshold=$((available_mb + 500))
echo "Will create ${threshold}MB test process"
```

**Step 3: Create gradual memory pressure**
```bash
# Terminal 1: Start memory consumer (smaller amount first)
./memory-consumer.py 200 &
MEMORY_PID=$!

# Terminal 2: Monitor in real-time
watch -n 1 'free -h; echo "---"; vmstat 1 1 | tail -1'

# Watch for:
# - available decreasing
# - si/so increasing (swap activity)
# - High memory pressure

# Let it run for 30 seconds, observe swap in values
sleep 30

# Stop the process
kill $MEMORY_PID 2>/dev/null
```

**Step 4: Analyze swap usage**
```bash
# Show swap usage
free -h | grep -i swap

# Show swap per process (requires elevated privileges)
for pid in $(ps aux | grep python | grep -v grep | awk '{print $2}'); do
  swap=$(grep VmSwap /proc/$pid/status 2>/dev/null | awk '{print $2}')
  if [ "$swap" -gt 0 ]; then
    echo "PID $pid using swap: ${swap}KB"
  fi
done
```

**Step 5: Monitor paging activity**
```bash
# Watch vmstat output during memory allocation
vmstat 1 10
# Watch si (swap in) and so (swap out) columns
# When available memory drops, these should increase

# Measure paging impact
echo "Initial state:"
vmstat | tail -1

echo "Creating 500MB process..."
./memory-consumer.py 500 > /dev/null &
MEMORY_PID=$!
sleep 5

echo "Under memory pressure:"
vmstat | tail -1

# Compare si/so values (should increase)

kill $MEMORY_PID 2>/dev/null
```

**Step 6: Calculate pressure metrics**
```bash
# Create a monitoring script
cat > monitor-pressure.sh << 'EOF'
#!/bin/bash

echo "Memory Pressure Monitor"
echo "======================"

while true; do
  echo "Time: $(date +%H:%M:%S)"
  free -h | awk 'NR==2 {printf "Memory: Used %s / Total %s (%.1f%% available)\n", $3, $2, ($7/$2)*100}'
  vmstat 1 1 | awk 'NR==3 {printf "Paging: SI=%s SO=%s (pages/sec)\n", $7, $8; if($7>0||$8>0) print "⚠️  System paging!"}'
  
  echo ""
  sleep 5
done
EOF

chmod +x monitor-pressure.sh

# Run while creating memory pressure
# Terminal 1:
./monitor-pressure.sh &

# Terminal 2:
./memory-consumer.py 300

# Let it run for 30 seconds
sleep 30

# Kill monitoring
pkill -f monitor-pressure
```

**Step 7: System response to OOM**
```bash
# Check OOM settings
cat /proc/sys/vm/overcommit_memory
# 0 = heuristic (default)
# 1 = always allow
# 2 = never allow overcommit

# Current OOM killer behavior
[ -f /proc/sys/vm/panic_on_oom ] && cat /proc/sys/vm/panic_on_oom

# Review OOM events in logs
dmesg | grep -i "out of memory\|killed process" | tail -5
```

### Verification

```bash
# Check swap is installed
swapon -s 2>/dev/null | grep -q partition && echo "✓ Swap configured"

# Memory consumer script works
python3 ~/memory-lab/memory-consumer.py 10 &
PID=$!
sleep 2
ps -p $PID > /dev/null && echo "✓ Memory consumer runs" && kill $PID 2>/dev/null
```

### Cleanup

```bash
# Kill any remaining processes
pkill -f memory-consumer
pkill -f monitor-pressure

# Remove test directory
rm -rf ~/memory-lab
echo "Cleaned up memory lab"
```

---

## Lab 8: Filesystem Operations and Mount Management

**Duration**: 40 minutes
**Difficulty**: Intermediate to Advanced
**Objective**: Create and manage filesystems safely using loopback devices

### Setup

```bash
# Create working directory
mkdir -p ~/filesystem-lab
cd ~/filesystem-lab

# Create empty file to use as loop device (safe, no real disk modification)
dd if=/dev/zero of=loopback.img bs=1M count=500 2>/dev/null
echo "Created 500MB loopback image file"

# Alternative: compressed sparse file (faster)
fallocate -l 500M loopback.img 2>/dev/null || \
  dd if=/dev/zero of=loopback.img bs=1M count=500 2>/dev/null

ls -lh loopback.img
```

### Hands-On Steps

**Step 1: Setup loopback device**
```bash
# Find available loop device
LOOP_DEV=$(losetup -f)
echo "Using loop device: $LOOP_DEV"

# Attach file to loop device
sudo losetup $LOOP_DEV ~/filesystem-lab/loopback.img

# Verify it's attached
losetup -a

# Alternative: use losetup -P for partition table support
```

**Step 2: Create filesystem on loop device**
```bash
# Create ext4 filesystem (this is safe - on our image file)
sudo mkfs.ext4 $LOOP_DEV
# mke2fs 1.46.2 (28-Feb-2021)
# Discarding device blocks: done
# Creating filesystem with 128000 4k blocks and 32000 inodes
# ...

# Add a label
sudo e2label $LOOP_DEV "test-fs"

# Verify filesystem
sudo blkid $LOOP_DEV
```

**Step 3: Mount the filesystem**
```bash
# Create mount point
mkdir -p ~/filesystem-lab/mount-point

# Mount the filesystem
sudo mount $LOOP_DEV ~/filesystem-lab/mount-point

# Verify mount
df -h ~/filesystem-lab/mount-point

# Show mount details
mount | grep filesystem-lab

# Check filesystem info
sudo tune2fs -l $LOOP_DEV | head -20
```

**Step 4: Add files and test**
```bash
# Add files to filesystem
cd ~/filesystem-lab/mount-point

# Create some test files
for i in {1..10}; do
  dd if=/dev/urandom of=file-$i.bin bs=1M count=10 2>/dev/null
done

# Check space usage
df -h .

# Show filesystem contents
ls -lh
du -sh *
```

**Step 5: Test filesystem limits**
```bash
# Show filesystem statistics
sudo tune2fs -l $LOOP_DEV | grep -E "Block|Inode"

# Show inode usage
df -i ~/filesystem-lab/mount-point

# Create many small files (test inode limit)
mkdir -p ~/filesystem-lab/mount-point/many-files
cd ~/filesystem-lab/mount-point/many-files

for i in {1..1000}; do
  touch file-$i
done 2>/dev/null

# Check inode usage now
df -i ~/filesystem-lab/mount-point
```

**Step 6: Perform filesystem check**
```bash
# IMPORTANT: Must unmount before fsck

# Unmount the filesystem
sudo umount ~/filesystem-lab/mount-point

# Run filesystem check (read-only)
sudo fsck.ext4 -n $LOOP_DEV
# -n means non-destructive, just report issues

# Would look like:
# e2fsck 1.46.2 (28-Feb-2021)
# /dev/loop0: clean, 1234/32000 inodes, 45678/128000 blocks

# If errors, can repair with -y flag (automatic yes)
# sudo fsck.ext4 -y $LOOP_DEV
```

**Step 7: Remount and cleanup**
```bash
# Remount for use
sudo mount $LOOP_DEV ~/filesystem-lab/mount-point

# Verify it mounted cleanly
mount | grep filesystem-lab

# Show current status
df -h ~/filesystem-lab/mount-point

# When done, unmount
sudo umount ~/filesystem-lab/mount-point

# Detach loop device
sudo losetup -d $LOOP_DEV

# Verify detached
losetup -a  # Should not show our loop device
```

**Step 8: Experiment with different filesystems (optional)**
```bash
# Create another loop device for testing XFS
dd if=/dev/zero of=xfs-test.img bs=1M count=200 2>/dev/null

# Attach to loop
LOOP_DEV2=$(losetup -f)
sudo losetup $LOOP_DEV2 ~/filesystem-lab/xfs-test.img

# Create XFS filesystem (if installed)
sudo mkfs.xfs $LOOP_DEV2 2>/dev/null && echo "XFS created" || echo "XFS not available"

# Or create ext3 (older format)
sudo mkfs.ext3 $LOOP_DEV2 2>/dev/null && echo "ext3 created"

# Compare filesystem info
sudo blkid ~/filesystem-lab/xfs-test.img
```

### Verification

```bash
# Verify loop device operations
losetup -l 2>/dev/null | grep -q loopback && echo "✓ Loop device attached"

# Verify filesystem
sudo tune2fs -l $LOOP_DEV 2>/dev/null | grep -q UUID && echo "✓ Filesystem created"

# Verify mount point exists
[ -d ~/filesystem-lab/mount-point ] && echo "✓ Mount point exists"
```

### Cleanup

```bash
# Unmount if still mounted
sudo umount ~/filesystem-lab/mount-point 2>/dev/null

# Detach all loop devices
LOOP_DEVICES=$(losetup -l 2>/dev/null | grep loopback | awk '{print $1}')
for dev in $LOOP_DEVICES; do
  sudo losetup -d $dev 2>/dev/null
done

# Remove all test files
rm -rf ~/filesystem-lab

echo "Cleaned up filesystem lab"
```

---

## Lab Summary and Progression

| Lab | Concept | Duration | Difficulty | Key Takeaway |
|-----|---------|----------|------------|--------------|
| 1 | Memory metrics | 20 min | Beginner | How to read free output |
| 2 | Process memory | 25 min | Beginner | VSZ vs RSS, top sorting |
| 3 | Disk space | 15 min | Beginner | Filesystem limits (bytes & inodes) |
| 4 | Finding large files | 30 min | Intermediate | Safe cleanup procedures |
| 5 | Disk structure | 20 min | Intermediate | Block devices and partitions |
| 6 | I/O monitoring | 35 min | Intermediate | Identifying I/O bottlenecks |
| 7 | Memory pressure | 30 min | Intermediate | Swap and paging behavior |
| 8 | Filesystem ops | 40 min | Intermediate+ | Safe filesystem management |

**Total Time**: ~215 minutes (3.5+ hours)

---

*Memory and Disk Management: Hands-On Labs*
*Complete all labs to master practical memory and disk management*
