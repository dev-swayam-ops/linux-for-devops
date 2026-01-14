# Memory and Disk Management: Commands Cheatsheet

Complete reference for 30+ memory and disk management commands with real examples.

---

## PART A: MEMORY ANALYSIS COMMANDS

### 1. free - Display Memory Usage

**Purpose**: Show RAM and swap usage overview

```bash
# Basic usage
free
#              total        used        free      shared  buff/cache   available
# Mem:       16403360     9876543     2097152    1048576    4429117     3906787
# Swap:       8388608            0     8388608

# Show in human-readable format (recommended)
free -h
#              total        used        free      shared  buff/cache   available
# Mem:          15Gi        9.4Gi       2.0Gi       1.0Gi       4.2Gi       3.7Gi
# Swap:         7.9Gi          0B       7.9Gi

# Show in megabytes
free -m
#              total        used        free      shared  buff/cache   available
# Mem:         16011        9653        2048        1024        4324        3815
# Swap:          8188           0        8188

# Show extended information (includes Lo and Hi memory on 32-bit systems)
free -l
#              total        used        free      shared  buff/cache   available
# Mem:       16403360     9876543     2097152    1048576    4429117     3906787

# Refresh every 2 seconds
free -h -s 2

# Display total line only
free -h | grep "Mem:"

# Convert free output to percentage
free -h | awk 'NR==2{printf "Memory: %s / %s (%.1f%%)\n", $3, $2, ($3/$2)*100}'
```

### 2. top - Process Monitor (Interactive)

**Purpose**: Real-time process and system monitoring

```bash
# Basic usage (q to quit)
top

# Non-interactive single iteration
top -b -n 1

# Show specific user's processes
top -u username

# Sort by memory (press 'M' in interactive, or use non-interactive)
top -b -n 1 -o %MEM

# Show top 10 memory consumers
top -b -n 1 -o %MEM | head -15

# Sort by CPU usage
top -b -n 1 -o %CPU

# Monitor specific process
top -b -n 1 -p 1234

# Show threads (with -H flag)
top -b -n 1 -H

# Custom interval
top -b -n 5 -d 1  # Run 5 iterations, 1 second interval

# Output current top stats to file
top -b -n 1 > top_snapshot.txt

# Interactive useful keys:
# M = sort by memory
# P = sort by CPU
# T = sort by time
# u = filter by user
# k = kill process
# Space = refresh
# q = quit
```

### 3. ps - Process Status

**Purpose**: One-time snapshot of processes

```bash
# Show all processes with memory info
ps aux
# USER  PID %CPU %MEM    VSZ   RSS TTY STAT START   TIME COMMAND
# root    1  0.0  0.0   5320   192 ?   Ss   10:00   0:01 /sbin/init

# Sort by memory usage (high to low)
ps aux --sort=-%mem | head -10

# Sort by CPU usage
ps aux --sort=-%cpu | head -10

# Show process tree with memory
ps aux --forest

# Custom format showing memory details
ps aux --sort=-%mem | awk '{print $1, $2, $6, $11}' | column -t

# Show VSZ and RSS for specific process
ps -p 1234 -o pid=,user=,vsz=,rss=,cmd=

# All processes and threads
ps -eLo pid,lwp,user,%mem,cmd

# Show zombie processes
ps aux | grep Z

# Get memory in MB for all Java processes
ps aux | grep java | awk '{printf "%s %.0f MB\n", $11, $6/1024}'

# List processes using swap
for pid in $(ps aux | grep -v grep | awk '{print $2}'); do
  if [ -f /proc/$pid/status ]; then
    swap=$(grep VmSwap /proc/$pid/status | awk '{print $2}')
    if [ "$swap" -gt 0 ]; then
      echo "PID: $pid - Swap: $swap KB"
    fi
  fi
done
```

### 4. pmap - Process Memory Map

**Purpose**: Detailed memory layout of a single process

```bash
# Show memory map of process
pmap 1234
# address     Kbytes   RSS Dirty Mode Mapping
# 0000555555554000   2544  1200    0 r-x-- /usr/bin/python
# 0000555555798000    256     0    0 r---- /usr/bin/python
# ...
# total            2844  1200    0

# Summary (recommended)
pmap -x 1234
# Address    Kbytes     RSS     Dirty  Mode Mapping
# Show each region

# Extended summary
pmap -X 1234

# Detailed summary with total
pmap -p 1234
```

### 5. vmstat - Virtual Memory Statistics

**Purpose**: Memory and system performance metrics over time

```bash
# Show once
vmstat

# Refresh every 2 seconds, 5 times
vmstat 2 5

# Detailed disk I/O stats
vmstat -d

# Per-partition I/O stats
vmstat -p /dev/sda1

# Timestamps with vmstat
vmstat -t 2 5
# Shows additional column with timestamps

# Memory stats only
vmstat | tail -1 | awk '{print "Free: "$4" pages, Swap in: "$7", Swap out: "$8}'

# Watch memory pressure indicators
watch -n 1 'vmstat 1 1 | tail -1'
```

**Key columns interpretation**:
- `r`: Processes waiting for CPU
- `b`: Processes blocked on I/O
- `swpd`: Swap used
- `free`: Free memory
- `si`: Swap in (paging from disk - BAD)
- `so`: Swap out (paging to disk - BAD)
- `bi`: Blocks in (disk reads)
- `bo`: Blocks out (disk writes)

### 6. watch - Repeated Monitoring

**Purpose**: Run command repeatedly, watching output change

```bash
# Monitor memory every 2 seconds
watch -n 2 free -h

# Monitor top memory processes
watch 'top -b -n 1 -o %MEM | head -12'

# Monitor system statistics
watch -n 1 vmstat

# Monitor with title and no header updates
watch -t -n 1 'free -h'

# Highlight changes
watch -d -n 2 'ps aux | grep java'
```

---

## PART B: DISK SPACE ANALYSIS

### 7. df - Disk Free Space

**Purpose**: Show filesystem mount points and space usage

```bash
# Basic overview
df

# Human-readable format (recommended)
df -h
# Filesystem      Size Used Avail Use% Mounted on
# /dev/sda1       100G  45G   55G  45% /
# /dev/sda2       200G 150G   50G  75% /home

# Show inodes (file count limit)
df -i
# Filesystem     Inodes   IUsed   IFree IUse% Mounted on

# Show all filesystems including loopback
df -a

# Show specific filesystem
df -h /home

# Show in kilobytes/megabytes/gigabytes
df -BK    # kilobytes
df -BM    # megabytes
df -BG    # gigabytes

# One-liner: Alert if any filesystem > 80%
df -h | awk 'NR>1 && $(NF-1) ~ /[0-9]+/ {used=$(NF-1); if(used>80) print "ALERT: " $NF " is " used "%"}'

# Sort by usage percentage (high to low)
df -h | sort -k5 -rn

# Show total of all filesystems
df -h | grep -E 'total' 
# or using awk:
df | tail -1
```

### 8. du - Disk Usage

**Purpose**: See what's using disk space in directories

```bash
# Show size of current directory and subdirectories
du

# Human-readable format (recommended)
du -h

# Total only (not subdirs)
du -sh
# 45G  .

# Depth limited (useful to avoid deep trees)
du -h -d 1    # or --max-depth=1
# 12G  ./home
# 8G   ./var
# 5G   ./usr
# 45G  .

# Show all files and directories
du -ah

# Sort by size (largest first)
du -sh */ | sort -h

# Find large directories
du -h -d 2 / | sort -hr | head -10

# Watch du progress (for large directories)
du -sh /large/dir &  # runs in background, updates as you list top

# Find large files (files, not directories)
find / -type f -size +100M -exec du -h {} \;

# Compare two directories
du -sh dir1 dir2

# Show size of each file in current directory
du -h --max-depth=1 | sort -h

# Report in megabytes
du -m /var | sort -rn | head -10

# Find size of all .log files
du -ch */*.log | tail -1
```

### 9. find - File Search and Analysis

**Purpose**: Locate files by various criteria

```bash
# Find large files (>100MB)
find / -type f -size +100M -exec ls -lh {} \;

# Find recent files (modified < 1 day ago)
find /var/log -type f -mtime -1

# Find old files (not modified for 30 days)
find /var/log -type f -mtime +30

# Find files modified in last 2 hours
find /tmp -type f -mmin -120

# Find all files and show size
find /var -type f -exec du -h {} \; | sort -h | tail -10

# Count files in each directory
find . -maxdepth 1 -type d -exec sh -c 'echo "{}":; find "{}" -type f | wc -l' \;

# Find and sort by size
find . -type f -printf '%s %p\n' | sort -rn | head -10

# Find empty files
find . -type f -size 0

# Find duplicate files (using md5sum)
find . -type f -exec md5sum {} \; | sort | uniq -d -w32

# Find files not accessed for 90 days
find . -type f -atime +90

# Delete files older than 30 days (be careful!)
find /var/log -type f -name "*.log" -mtime +30 -delete

# Show file count and total size
find . -type f | wc -l
find . -type f -exec du -c {} + | tail -1
```

### 10. ls - List with Size Info

**Purpose**: Detailed file information

```bash
# Show size in human-readable format
ls -lh

# Sort by size (largest first)
ls -lhSr

# Show size with full time
ls -lh --full-time

# Recursive with size
ls -lhR

# Show size in specific units
ls -lhB    # in blocks
ls -lhk    # in kilobytes
ls -lhm    # in megabytes

# One-liner: Show size and percentage of total
ls -l | awk 'BEGIN{total=0} NR>1 {total+=$5} NR>1 {pct=($5/total)*100; printf "%10d (%5.1f%%) %s\n", $5, pct, $9} END{printf "%10d (100.0%%) TOTAL\n", total}'
```

---

## PART C: DISK LAYOUT AND STRUCTURE

### 11. lsblk - List Block Devices

**Purpose**: Show all block devices (disks and partitions)

```bash
# Basic listing
lsblk
# NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda      8:0    0  500G  0 disk
# ├─sda1   8:1    0  200M  0 part /boot
# ├─sda2   8:2    0  100G  0 part /
# └─sda3   8:3    0  400G  0 part /home

# Show all columns
lsblk -a

# Show permissions and owners
lsblk -m

# Tree format (default)
lsblk

# List format
lsblk -l

# Show size in human-readable
lsblk -h

# Show size in bytes
lsblk -b

# Custom columns
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Show UUID
lsblk -o NAME,SIZE,UUID

# Show disk type (SSD or HDD)
lsblk -d  # disk only

# Find partition by UUID
lsblk -o NAME,UUID | grep "a1b2c3d4"
```

### 12. fdisk - Disk Partition Editor

**Purpose**: Modify partition table (destructive - use carefully)

```bash
# View partition table (non-destructive)
fdisk -l /dev/sda
# Disk /dev/sda: 500 GiB, 536870912000 bytes
# Disk model: Samsung SSD 850
# Units: sectors of 1 * 512 = 512 bytes
# Device     Boot    Start      End  Sectors Size Id Type
# /dev/sda1  *        2048  411647   409600 200M 83 Linux
# /dev/sda2       411648 2560000 2148352 1.0G 83 Linux

# List all disks
fdisk -l

# Interactive editor (changes partition table)
fdisk /dev/sda
# (then type 'p' to print table, 'n' for new, 'd' for delete, 'w' to write)

# Quick check for partition table issues
fdisk -l | grep -i "error\|warning"

# Show MBR vs GPT
fdisk -l /dev/sda | grep -i "disklabel\|Disklabel type"

# Export partition table (backup)
fdisk -d /dev/sda > sda.dump

# Note: Modern systems use parted or gdisk for GPT disks
```

### 13. parted - GNU Partition Editor

**Purpose**: Partition management (supports both MBR and GPT)

```bash
# View partition layout
parted /dev/sda print
# Model: QEMU HARDDISK (scsi)
# Disk /dev/sda: 500GB
# Sector size (logical/physical): 512B/512B
# Partition Table: msdos
# Disk Flags:
# Number  Start   End    Size    Type     File system  Flags
# 1       1049kB 211MB  210MB  primary  ext4         boot
# 2       211MB  500GB  500GB  primary  ext4

# List all disks
parted -l

# Create partition (interactive)
parted /dev/sda
# (parted) unit GB
# (parted) mkpart primary ext4 0 50
# (parted) quit

# Print in machine-readable format
parted -m /dev/sda print

# Set partition flag
parted /dev/sda set 1 boot on

# Resize partition (carefully!)
parted /dev/sda resizepart 1 100GB

# Remove partition
parted /dev/sda rm 1
```

### 14. blkid - Block Device Identification

**Purpose**: Show filesystem UUID and type

```bash
# Show all block devices with UUID
blkid
# /dev/sda1: UUID="a1b2c3d4-e5f6-7890-1234-567890abcdef" TYPE="ext4"
# /dev/sda2: UUID="f1e2d3c4-b5a6-7890-1234-567890abcdef" TYPE="ext4"

# Show specific device
blkid /dev/sda1

# Output format (key=value)
blkid -o full

# Show UUID only
blkid -s UUID -o value

# Show TYPE only
blkid -s TYPE -o value

# Export as shell variables
blkid -o export /dev/sda1
# DEVNAME=/dev/sda1
# UUID=a1b2c3d4-e5f6-7890-1234-567890abcdef
# TYPE=ext4

# Find device by UUID
blkid -U "a1b2c3d4-e5f6-7890-1234-567890abcdef"
# /dev/sda1
```

---

## PART D: FILESYSTEM OPERATIONS

### 15. mount - Mount Filesystems

**Purpose**: Attach filesystems to directory tree

```bash
# Show mounted filesystems
mount

# Show mounted filesystems with sizes
mount | column -t

# Mount device at location
mount /dev/sda1 /mnt/data

# Mount read-only
mount -o ro /dev/sda1 /mnt/data

# Mount with specific options
mount -o defaults,noatime /dev/sda1 /mnt/data

# Mount by UUID (preferred, more reliable)
mount UUID="a1b2c3d4-e5f6-7890-1234-567890abcdef" /mnt/data

# Mount temporary filesystem in RAM
mount -t tmpfs -o size=1G tmpfs /mnt/ram

# Mount ISO image
mount -o loop /path/to/image.iso /mnt/iso

# Show mount options for specific mount
mount | grep "/mnt/data"

# Remount with different options
mount -o remount,noatime /mnt/data

# Show all mount options
cat /proc/mounts

# Show available filesystems
cat /etc/filesystems
```

### 16. umount - Unmount Filesystems

**Purpose**: Detach filesystems safely

```bash
# Basic unmount
umount /mnt/data

# Unmount by device name
umount /dev/sda1

# Lazy unmount (allow in-use, unmount when no longer in use)
umount -l /mnt/data

# Force unmount (dangerous, can cause data loss)
umount -f /mnt/data

# Check what's using filesystem before unmounting
lsof /mnt/data

# Kill processes using mount point
fuser -k /mnt/data

# Then unmount
umount /mnt/data

# Umount all
umount -a

# Show busy files
fuser -v /mnt/data
```

### 17. fsck - Filesystem Check and Repair

**Purpose**: Verify and repair filesystems (must be unmounted)

```bash
# Check filesystem (read-only)
fsck -n /dev/sda1

# Check and repair automatically
fsck /dev/sda1

# Check without waiting for input
fsck -y /dev/sda1

# Check with progress
fsck -C /dev/sda1

# Check all filesystems in /etc/fstab
fsck -A

# Check specific filesystem type
fsck.ext4 /dev/sda1

# Verbose output
fsck -v /dev/sda1

# NOTE: Should NOT be run on mounted filesystem!
# If / (root) needs checking, must do at boot or:
# 1. Boot to single-user mode
# 2. Boot from recovery media
# 3. Mount read-only, then fsck -y
```

### 18. mkfs - Make Filesystem

**Purpose**: Create new filesystem on block device

```bash
# Create ext4 filesystem
mkfs.ext4 /dev/sda1

# Specify label
mkfs.ext4 -L mydisk /dev/sda1

# Fast creation (doesn't wipe all blocks)
mkfs.ext4 -F /dev/sda1

# Specify block size
mkfs.ext4 -b 4096 /dev/sda1

# Create ext3
mkfs.ext3 /dev/sda1

# Create FAT
mkfs.fat /dev/sda1

# Create XFS
mkfs.xfs /dev/sda1

# Show filesystem types supported
ls /sbin/mkfs*

# WARNING: This erases data! Be sure of device path
# Always double-check: fdisk -l before mkfs
```

### 19. tune2fs - Adjust ext2/ext3/ext4 Parameters

**Purpose**: Tune filesystem options after creation

```bash
# Show filesystem info
tune2fs -l /dev/sda1
# Filesystem UUID: a1b2c3d4-e5f6-7890-1234-567890abcdef
# Last write time: Thu Jan 01 00:00:00 1970

# Change label
tune2fs -L newlabel /dev/sda1

# Disable periodic checks
tune2fs -c -1 /dev/sda1

# Set maximum mount count before check
tune2fs -c 30 /dev/sda1

# Add journal (convert ext2 to ext3)
tune2fs -j /dev/sda1

# Change reserved block percentage
tune2fs -m 1 /dev/sda1  # Reserve 1% for root (default 5%)

# Show UUID
tune2fs -l /dev/sda1 | grep UUID
```

### 20. findmnt - Find Mounts

**Purpose**: Display mount point hierarchy

```bash
# Show mount tree
findmnt

# List format
findmnt -l

# Show specific mount point
findmnt /

# Find by filesystem type
findmnt -t ext4

# Find by device
findmnt /dev/sda1

# Show kernel mount options
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS

# Show unused filesystems
findmnt -o TARGET,SOURCE,AVAIL -h
```

---

## PART E: I/O PERFORMANCE MONITORING

### 21. iostat - I/O Statistics

**Purpose**: Monitor disk I/O performance

```bash
# Single report
iostat

# Repeated reports (every 1 second, 5 times)
iostat 1 5

# Extended statistics
iostat -x 1 5
# Device r/s w/s rMB/s wMB/s rrqm/s wrqm/s %rrqm %wrqm r_await w_await
# sda 100 50 12.3 5.4 5 2 5% 4% 3.2ms 4.1ms

# Per-partition I/O
iostat -p /dev/sda

# CPU and I/O (default)
iostat

# I/O only (no CPU)
iostat -d

# Device utilization (busiest first)
iostat -x 1 3 | awk 'NR>3 && NF' | sort -k14 -rn

# Watch disk %util trend
watch -n 1 'iostat -x 1 2 | grep -E "^(sda|nvme)" | awk "{print \$1, \$(NF)}"'
```

**Key metrics**:
- `r/s`: Reads per second
- `w/s`: Writes per second
- `rMB/s`: Read throughput
- `wMB/s`: Write throughput
- `%util`: Disk utilization (>70% = bottleneck)
- `r_await`: Average read latency
- `w_await`: Average write latency

### 22. iotop - I/O Per-Process Monitor

**Purpose**: Which processes are doing I/O

```bash
# Top I/O processes (interactive, press q to quit)
iotop

# Non-interactive
iotop -b -n 1

# Monitor specific process
iotop -p 1234

# Show only processes doing I/O
iotop -o

# Batch mode with iterations
iotop -b -n 3 -d 1

# Sort by I/O read
iotop -b -n 1 -o | sort -k4 -rn

# Monitor with one-second updates for 10 seconds
watch -n 1 -e 'iotop -b -n 1 -o -d 1' | head -20
```

### 23. dstat - Versatile System Resource Monitoring

**Purpose**: Combined CPU, memory, disk, network statistics

```bash
# Show CPU, memory, disk, net
dstat

# Specific interval and count
dstat 1 5

# CPU and memory only
dstat -c -m

# Disk I/O and network
dstat -d -n

# Full details
dstat --full

# Output to CSV
dstat --output stats.csv

# Show top I/O processes
dstat --top-io

# Show top memory processes
dstat --top-mem

# High-precision (milliseconds)
dstat -t --disk -T
```

---

## PART F: ADVANCED ANALYSIS

### 24. awk - Text Processing for Log Analysis

**Purpose**: Extract and process data from command output

```bash
# Get total memory from free
free -h | awk 'NR==2 {print "Used: " $3 " / " $2}'

# Calculate memory percentage
free -h | awk 'NR==2 {used=$3; gsub(/G/,"", used); total=$2; gsub(/G/, "", total); printf "Memory: %.1f%%\n", (used/total)*100}'

# Extract disk usage percentage
df -h / | awk 'NR==2 {print $5}'

# Show processes and memory (sorted)
ps aux | awk 'NR>1 {printf "%10.0f MB  %s\n", $6/1024, $11}' | sort -rn | head -5

# Sum total memory by user
ps aux | awk '{sum[$1]+=$6} END {for (user in sum) printf "%s: %.0f MB\n", user, sum[user]/1024}'

# Extract mount usage info
df -h | awk 'NR>1 && $(NF-1) ~ /[0-9]+/ {printf "%-15s %6s / %-6s (%-3s)\n", $NF, $3, $2, $(NF-1)}'
```

### 25. sort - Sort Data

**Purpose**: Organize output by criteria

```bash
# Sort processes by memory (descending)
ps aux --sort=-%mem

# Sort by CPU usage
ps aux --sort=-%cpu

# Sort by virtual memory
ps aux --sort=-vsz

# Sort by command name
ps aux --sort=cmd

# Reverse sort (ascending)
ps aux --sort=+%mem

# Multiple sort criteria
ps aux --sort=-%cpu,-%mem

# Sort numeric data
du -sh */ | sort -h

# Sort in place
sort -i filename
```

---

## PART G: COMMON PATTERNS AND ONE-LINERS

### Memory Analysis Patterns

```bash
# Top 5 memory consumers
ps aux --sort=-%mem | head -6 | awk '{printf "%6.1f%% %-6s %s\n", $4, $2, $11}'

# Total memory by user
ps aux | awk 'NR>1 {sum[$1]+=$6} END {for (user in sum) printf "%30s: %8.0f MB\n", user, sum[user]/1024}'

# Find memory hogs (> 100MB)
ps aux | awk '$6 > 100000 {printf "%8s %6.0f MB %s\n", $2, $6/1024, $11}'

# Monitor memory growth
watch -n 5 'free -h; echo "---"; ps aux --sort=-%mem | head -8'

# Alert if memory < 500MB
while true; do
  available=$(free -m | awk 'NR==2 {print $7}')
  if [ $available -lt 500 ]; then
    echo "ALERT: Available memory: ${available}MB"
  fi
  sleep 60
done
```

### Disk Analysis Patterns

```bash
# Largest directories
du -sh */ | sort -hr | head -10

# Find and show large files
find / -type f -size +100M -exec ls -lh {} \; | awk '{print $5, $9}' | sort -hr

# Disk usage by partition
df -h | grep -E '^/dev' | awk '{printf "%-20s %6s / %6s (%4s)\n", $1, $3, $2, $5}'

# Alert if partition > 85%
df -h | grep -E '^/dev' | awk '$5 ~ /^[0-9]+%$/ && substr($5,1,2) > 85 {print "ALERT: " $NF " is " $5 " full"}'

# Monitor disk I/O
watch -n 2 'iostat -x 1 2 | grep -E "^(Device|sda|nvme)"'

# Find old files to delete
find /var/log -name "*.log" -mtime +30 | xargs rm -v
```

---

## PART H: FILESYSTEM AND MOUNT PATTERNS

### Working with /etc/fstab

```bash
# View fstab
cat /etc/fstab
# UUID=a1b2c3d4  /          ext4  defaults           0  1
# UUID=e5f6g7h8  /home      ext4  defaults,noatime   0  2
# /dev/sda3      swap       swap  defaults           0  0

# Add new mount to fstab (edit with nano or vi)
echo "UUID=new-uuid  /mnt/data  ext4  defaults,noatime  0  2" >> /etc/fstab

# Test fstab for errors
mount -a --fake-all

# Check if all mounts work
mount -a

# Find filesystem by label
blkid -t LABEL="mylabel"

# Find filesystem by UUID
blkid -U "uuid-value"
```

### Mount Point Management

```bash
# Create mount point
mkdir -p /mnt/data

# Mount and verify
mount /dev/sda1 /mnt/data && df -h /mnt/data

# Mount and check permissions
mount /dev/sda1 /mnt/data && ls -ld /mnt/data

# Umount and verify
umount /mnt/data && ls -la /mnt/data (should be empty)

# Check what's preventing umount
lsof /mnt/data

# Kill processes and umount
fuser -k /mnt/data && umount /mnt/data
```

---

## PART I: TROUBLESHOOTING REFERENCE TABLE

| Symptom | Commands to Run | Likely Cause |
|---------|-----------------|--------------|
| System slow | vmstat, iostat, top | CPU, Memory pressure, or I/O |
| Memory full | free -h, ps aux --sort=-%mem | Process leak or too many apps |
| Disk full | df -h, du -sh /, find -size +100M | Old logs, cache, or data bloat |
| Inode full | df -i, find . \| wc -l | Too many small files |
| High I/O wait | iostat -x, iotop | Disk bottleneck |
| High swap use | vmstat, free -h, watch swapon -s | Memory pressure |
| Slow disk | iostat -x, iotop, fio | Contention or failing hardware |
| Filesystem errors | fsck -n, dmesg | Corruption or hardware issue |
| OOM killss | dmesg, /var/log/syslog | Memory leak or insufficient RAM |

---

*Memory and Disk Management: Commands Cheatsheet*
*Reference these commands for quick diagnosis and optimization*
