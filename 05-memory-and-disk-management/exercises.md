# Memory and Disk Management: Exercises

Complete these exercises to master system resource monitoring.

## Exercise 1: Memory Overview

**Tasks:**
1. Check total RAM installed
2. Check available free memory
3. View swap space usage
4. Determine memory usage percentage
5. Compare memory in different formats (KB, MB, GB)

**Hint:** Use `free -h`, `free -m`, `free -b` for different formats.

---

## Exercise 2: Top Memory Consumers

**Tasks:**
1. List top 10 processes by memory usage
2. Identify the process using most memory
3. Show process name, PID, and memory percentage
4. Repeat and note if values change
5. Explain why some processes use more memory

**Hint:** Use `ps aux --sort=-%mem | head -10`.

---

## Exercise 3: Disk Space Overview

**Tasks:**
1. Show all mounted filesystems
2. Check disk usage for root filesystem (/)
3. Check disk usage for /home partition
4. Identify filesystem with most free space
5. Determine overall disk usage percentage

**Hint:** Use `df -h` for human-readable output.

---

## Exercise 4: Find Largest Directories

**Tasks:**
1. Find largest directory in /home
2. Find largest directory in /var
3. List top 5 largest directories system-wide
4. Check if any directory exceeds certain size threshold
5. Document findings in a file

**Hint:** Use `du -sh /path` and `sort -rh`.

---

## Exercise 5: Locate Large Files

**Tasks:**
1. Find all files larger than 50MB
2. Find all files larger than 500MB
3. Limit search to /home directory
4. List 10 largest files on system
5. Check modification time of large files

**Hint:** Use `find -size +50M -type f` and `-printf`.

---

## Exercise 6: Filesystem and Mount Analysis

**Tasks:**
1. Display all mounted filesystems
2. Show block device information
3. Identify partition layout with `lsblk`
4. Check mount options for specific filesystem
5. Determine filesystem type for root partition

**Hint:** Use `mount`, `lsblk`, `df -T`, `/etc/fstab`.

---

## Exercise 7: Inode Usage Analysis

**Tasks:**
1. Check inode usage for all filesystems
2. Find filesystem with high inode percentage
3. Locate directories with many small files
4. Understand inode consumption pattern
5. Estimate how many files can fit in filesystem

**Hint:** Use `df -i` to show inode stats.

---

## Exercise 8: Memory Monitoring Over Time

**Tasks:**
1. Record memory usage at different times
2. Monitor for 5 minutes, capturing every 30 seconds
3. Create a log file with timestamps
4. Analyze memory trend (increasing/decreasing/stable)
5. Identify peak memory usage time

**Hint:** Use `free -h` in a loop with `sleep 30`.

---

## Exercise 9: Disk Activity Monitoring

**Tasks:**
1. Check disk I/O statistics
2. Monitor read/write activity
3. Identify busiest disk
4. Find processes causing high I/O
5. Calculate average I/O performance

**Hint:** Use `iostat`, `iotop`, `vmstat`.

---

## Exercise 10: Clean Up and Optimize

Create a system audit report showing resource usage.

**Tasks:**
1. Find and list old log files (>30 days)
2. Find temporary files to clean
3. Calculate total space that can be freed
4. Create cleanup script (don't execute)
5. Generate summary report with findings

**Hint:** Use `find -mtime +30`, `find /tmp`, `-exec du -h`.
