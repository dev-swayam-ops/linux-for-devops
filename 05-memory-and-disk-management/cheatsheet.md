# Memory and Disk Management: Cheatsheet

## Memory Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `free -h` | Memory usage human-readable | `free -h` |
| `free -m` | Memory in MB | `free -m` |
| `free -b` | Memory in bytes | `free -b` |
| `free -s 5` | Update every 5 seconds | `free -s 5` |
| `cat /proc/meminfo` | Detailed memory info | `cat /proc/meminfo` |

## Process Memory Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `ps aux --sort=-%mem` | Sort by memory usage | `ps aux --sort=-%mem \| head` |
| `ps -o pid,comm,%mem` | PID, name, memory % | `ps -o pid,comm,%mem --sort=-%mem` |
| `top -b -n 1` | Batch mode snapshot | `top -b -n 1 \| head -20` |
| `watch -n 1 'top'` | Watch top output | `watch -n 1 'ps aux --sort=-%mem'` |

## Disk Space Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `df -h` | Disk usage human-readable | `df -h` |
| `df -m` | Disk usage in MB | `df -m` |
| `df -i` | Inode usage | `df -i` |
| `df -T` | Show filesystem type | `df -T` |
| `du -sh /path` | Directory size summary | `du -sh /home` |
| `du -sh /*` | Size of root subdirs | `du -sh /*` |

## Finding Large Files and Directories

| Command | Purpose | Example |
|---------|---------|---------|
| `find / -size +100M -type f` | Files >100MB | `find / -size +100M -type f 2>/dev/null` |
| `find / -size +1G -type f` | Files >1GB | `find / -size +1G 2>/dev/null` |
| `du -sh / \| sort -rh` | Largest dirs | `du -sh /* \| sort -rh \| head -10` |
| `find -type f -exec ls -lh` | Largest files | `find / -type f -exec ls -lh \; 2>/dev/null` |

## Filesystem Information

| Command | Purpose | Example |
|---------|---------|---------|
| `lsblk` | List block devices | `lsblk` |
| `lsblk -f` | Filesystems | `lsblk -f` |
| `mount` | Show mounts | `mount \| grep "^/"` |
| `mount \| grep /home` | Specific mount | `mount \| grep /home` |
| `cat /etc/fstab` | Mount configuration | `cat /etc/fstab` |
| `fdisk -l` | Partition table (sudo) | `sudo fdisk -l` |

## Disk I/O and Performance

| Command | Purpose | Example |
|---------|---------|---------|
| `iostat -x 1 5` | Disk I/O stats | `iostat -x 1 5` |
| `iostat -d 1 3` | Disk summary | `iostat -d 1 3` |
| `vmstat 1 5` | Virtual memory stats | `vmstat 1 5` |
| `iotop -b -n 5` | Process I/O usage | `sudo iotop -b -n 5` |
| `iotop -o` | Only busy processes | `sudo iotop -o` |

## File and Directory Statistics

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -lh` | File sizes | `ls -lh /var/log` |
| `ls -lhS` | Sort by size | `ls -lhS /var/log` |
| `find /path -type f -mtime +30` | Files older than 30 days | `find /tmp -type f -atime +7` |
| `find /path -type f -size +50M` | Files larger than 50M | `find / -size +500M 2>/dev/null` |

## Disk Usage Analysis

| Command | Purpose | Example |
|---------|---------|---------|
| `ncdu /path` | Interactive disk usage | `ncdu /home` |
| `du -ah /path \| sort -rh` | Sorted by size | `du -ah /var \| sort -rh \| head` |
| `du -h --max-depth=1 /path` | Single level | `du -h --max-depth=1 /home` |

## Memory Limits and Ulimit

| Command | Purpose | Example |
|---------|---------|---------|
| `ulimit -a` | Show all limits | `ulimit -a` |
| `ulimit -m` | Max memory | `ulimit -m` |
| `ulimit -v` | Virtual memory | `ulimit -v` |
| `ulimit -n` | Max file descriptors | `ulimit -n` |

## Swap Management

| Command | Purpose | Example |
|---------|---------|---------|
| `free -h \| grep Swap` | Swap usage | `free -h` |
| `swapon -s` | Swap summary | `swapon -s` |
| `swapon --show` | Swap info | `swapon --show` |

## Disk Cleanup Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `find /tmp -type f -atime +7 -delete` | Delete old temp files | `find /tmp -type f -atime +7` |
| `rm -rf /var/log/*.log.*` | Remove old logs | `ls -la /var/log/*.log.*` |
| `du -sh /var/cache` | Cache size | `du -sh /var/cache` |
| `apt-get autoremove` | Remove old packages | `sudo apt-get autoremove` |

## Monitoring Dashboard

| Command | Purpose |
|---------|---------|
| `free -h && df -h && ps aux --sort=-%mem \| head -3` | Quick overview |
| `watch -n 2 'free -h; echo "---"; df -h; echo "---"; top -n 1 -b \| head'` | Continuous monitor |

## Memory Size Reference

| Unit | Bytes |
|------|-------|
| 1 KB | 1,024 |
| 1 MB | 1,048,576 |
| 1 GB | 1,073,741,824 |
| 1 TB | 1,099,511,627,776 |

## Common Filesystem Types

| Type | Use Case |
|------|----------|
| ext4 | Standard Linux filesystem |
| xfs | High performance, large files |
| btrfs | Modern, snapshots, compression |
| tmpfs | RAM-based, temporary |
| nfs | Network filesystem |
