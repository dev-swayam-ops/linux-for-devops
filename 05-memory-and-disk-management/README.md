# Module 5: Memory and Disk Management

## What You'll Learn

- Monitor and analyze memory usage on Linux systems
- Check disk space and file system utilization
- Understand filesystem types and mounting
- Manage disk partitions and volumes
- Identify memory-intensive processes
- Optimize storage and clean up unused data

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Understanding of system administration basics
- Familiar with process concepts from Module 2
- Basic command-line proficiency

## Key Concepts

| Concept | Description |
|---------|-------------|
| **RAM** | Physical memory for running processes |
| **Swap** | Disk space used when RAM is full |
| **Filesystem** | Storage structure (ext4, xfs, btrfs) |
| **Partition** | Logical division of disk |
| **Mount Point** | Directory where filesystem is attached |
| **Inode** | Data structure storing file metadata |
| **Block** | Smallest disk storage unit (usually 4KB) |
| **Fragmentation** | File scattered across disk sectors |

## Hands-on Lab: Monitor Memory and Disk Usage

### Lab Objective
Check system memory, disk space, and identify large files.

### Commands

```bash
# Check total and available memory
free -h
# Shows RAM and swap in human-readable format

# Detailed memory information
free -m
# Memory in megabytes

# Memory usage by process
ps aux --sort=-%mem | head -10
# Shows top 10 memory-consuming processes

# Real-time memory monitoring
top -b -n 1 | head -20
# Batch mode, 1 iteration

# List filesystems and mount points
df -h
# Disk space in human-readable format

# Detailed filesystem info
df -i
# Show inode usage

# Directory size
du -sh /home
# Total size of /home directory

# Find largest directories
du -sh /* | sort -rh | head -10
# Top 10 largest directories in root

# Find large files (>100MB)
find / -size +100M -type f 2>/dev/null

# Check mount points
mount | grep -E "^/"

# View partition table
lsblk
# Lists block devices and partitions

# Detailed partition info
fdisk -l
# (requires sudo)

# Check disk I/O activity
iostat -x 1 5
# Extended stats, 1 second interval, 5 times
```

### Expected Output

```
# free -h output:
              total        used        free      shared  buff/cache   available
Mem:           15Gi       3.2Gi       8.5Gi      256Mi       3.2Gi      11Gi
Swap:          4.0Gi          0B       4.0Gi

# df -h output:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   12G   38G  24% /
/dev/sda2       200G   85G  115G  43% /home
tmpfs           1.5G     0  1.5G   0% /dev/shm

# du -sh /* output:
4.0K  /bin
12G   /home
2.3G  /var
6.5G  /usr
```

## Validation

Confirm successful completion:

- [ ] Used `free -h` to check memory status
- [ ] Used `df -h` to check disk space
- [ ] Found memory-consuming processes with `ps aux --sort=-%mem`
- [ ] Identified large directories with `du -sh`
- [ ] Located files larger than 100MB
- [ ] Viewed filesystem mount points

## Cleanup

```bash
# No cleanup needed for monitoring commands
# All commands are read-only

# If you created test files, remove them:
rm -rf /tmp/test_files
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Free space shows 0% | You have a full disk - emergency cleanup needed |
| OOM (Out of Memory) errors | Check `free -h` and kill non-essential processes |
| `iostat: command not found` | Install: `sudo apt install sysstat` |
| Forgot human-readable flag | Use `-h` with `df` and `du` commands |
| Can't see mount info | Use `mount` without grep, or check `/proc/mounts` |
| Permission denied on large search | Use `sudo` or redirect errors: `2>/dev/null` |

## Troubleshooting

**Q: Why is my disk 100% full?**
A: Use `du -sh /*` to find largest directories, then investigate and clean.

**Q: How do I check which process uses most memory?**
A: Use `ps aux --sort=-%mem | head -5` to see top 5 memory hogs.

**Q: What's using my swap space?**
A: Check `free -h` and `top`. Swap usage means RAM is full.

**Q: How do I safely delete large files?**
A: Use `du -sh directory/` first, then `rm -rf path` only after verifying.

**Q: Can I see disk activity in real-time?**
A: Use `iostat`, `iotop`, or `vmstat` for real-time disk/memory stats.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Monitor your system's memory and disk regularly
3. Implement cleanup scripts for old files
4. Learn about filesystem maintenance (fsck, e2fsck)
5. Explore LVM for advanced disk management
