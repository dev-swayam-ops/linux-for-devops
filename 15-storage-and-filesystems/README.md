# Module 15: Storage and Filesystems

## What You'll Learn

- Understand storage hierarchy and partitions
- Work with filesystems (ext4, xfs, btrfs)
- Manage disk space and quotas
- Use LVM for flexible storage
- Mount and unmount filesystems
- Check disk health and performance
- Understand inode and block allocation

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Complete Module 5: Memory and Disk Management
- Comfortable with command-line navigation
- Understanding of file permissions

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Partition** | Division of physical disk |
| **Filesystem** | Organizational structure (ext4, xfs) |
| **Mount** | Attach filesystem to directory tree |
| **Inode** | Data structure storing file metadata |
| **Block** | Smallest disk storage unit |
| **LVM** | Logical Volume Manager for flexibility |
| **Quota** | Limit disk usage per user/group |
| **UUID** | Unique identifier for filesystem |

## Hands-on Lab: Create and Mount Filesystems

### Lab Objective
Create partition, format with filesystem, and mount it.

### Commands

```bash
# List disks
sudo fdisk -l | head -20

# List partitions
lsblk

# Show mounted filesystems
df -h

# Disk usage details
df -i

# Check inode usage
df -hi

# Create partition (interactive)
sudo fdisk /dev/sdb
# n = new, t = type, w = write

# Format partition (ext4)
sudo mkfs.ext4 /dev/sdb1

# Format with xfs
sudo mkfs.xfs /dev/sdb1

# Create mount point
sudo mkdir -p /mnt/data

# Mount filesystem
sudo mount /dev/sdb1 /mnt/data

# Verify mount
mount | grep sdb1

# Check space after mount
df -h /mnt/data

# Persistent mount (/etc/fstab)
echo "/dev/sdb1 /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Test fstab
sudo mount -a

# Unmount filesystem
sudo umount /mnt/data

# Show filesystem info
sudo tune2fs -l /dev/sdb1
```

### Expected Output

```
# lsblk output:
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   50G  0 disk
├─sda1   8:1    0   30G  0 part /
└─sda2   8:2    0   20G  0 part /home

# df -h output:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        30G   10G   20G  33% /
/dev/sdb1        50G  100M   50G   1% /mnt/data
```

## Validation

Confirm successful completion:

- [ ] Listed disks with fdisk/lsblk
- [ ] Created and formatted partition
- [ ] Mounted filesystem
- [ ] Verified with df
- [ ] Added to /etc/fstab
- [ ] Tested persistent mount

## Cleanup

```bash
# Unmount filesystem
sudo umount /mnt/data

# Remove from fstab
sudo nano /etc/fstab
# Delete the line

# Verify unmounted
df -h | grep data
# Should be gone
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Mounted on wrong point | Unmount first: `sudo umount` |
| Partition in use | Boot from live USB to modify |
| Wrong filesystem type | Check with `df -T` |
| Inode exhaustion | Monitor with `df -i` |
| fstab errors prevent boot | Fix with `sudo mount -a` test |

## Troubleshooting

**Q: How do I find which filesystem a file is on?**
A: Use `df /path/to/file` to see mount point and filesystem.

**Q: How do I extend a partition?**
A: Use LVM or tools like parted/gparted. Requires backups first.

**Q: Filesystem corrupted - how to fix?**
A: Unmount, run `sudo fsck -n /dev/partition` to check, then repair with `-y`.

**Q: How do I set disk quotas?**
A: Install quotas, enable in mount options, set with `edquota`.

**Q: Can't mount - permission denied?**
A: Use `sudo mount`. Permissions must allow mounting.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Practice LVM setup and management
3. Learn filesystem optimization
4. Set up disk quotas
5. Implement backup strategies
