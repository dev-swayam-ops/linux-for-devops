# Storage and Filesystems: Solutions

## Exercise 1: Identify Storage Devices

**Solution:**

```bash
# List all disks
sudo fdisk -l | head -30
# Output: Disk /dev/sda: 50 GiB

# Partition structure with details
lsblk -a
# Output:
# sda      8:0    0  50G  0 disk
# ├─sda1   8:1    0  30G  0 part /
# └─sda2   8:2    0  20G  0 part

# Check sizes
lsblk -b
# Sizes in bytes

# Boot partition
mount | grep " / "
# Shows root/boot filesystem

# All mounted filesystems
mount
# List all mounts

# Pretty view
df -h
# Human-readable sizes
```

**Explanation:** `lsblk` = block devices tree view. `fdisk` = partition table. `df` = mounted.

---

## Exercise 2: Understand Filesystems

**Solution:**

```bash
# Show filesystem types
df -T
# Output:
# Filesystem     Type     Size  Used Avail Use%
# /dev/sda1      ext4      30G   10G   20G  33%

# Filesystem details (ext4)
sudo tune2fs -l /dev/sda1 | head -20
# Output: Filesystem UUID, Block size, Inode count

# XFS filesystem info
sudo xfs_info /mnt/data
# Output: XFS filesystem info

# Inode info
df -i
# Output:
# Filesystem      Inodes  Iused   Ifree IUse%
# /dev/sda1      1920000 150000 1770000    8%

# Block size
stat /boot | grep "Block size"
# Output: Block size: 4096

# All details
ls -i /
# Shows inodes of files
```

**Explanation:** Inodes = file metadata. Blocks = data storage. Filesystems = organizational structure.

---

## Exercise 3: Create Partitions

**Solution:**

```bash
# View partition table
sudo fdisk -l /dev/sdb
# Output: Disk /dev/sdb, Partition table: dos/gpt

# Interactive partition creation
sudo fdisk /dev/sdb
# Commands:
# n = new partition
# p = primary/e = extended
# t = type (Linux = 83)
# w = write changes
# q = quit without saving

# Verify partition created
lsblk
# New partition shows up

# Set partition type
# In fdisk: t, select partition, choose type
# 83 = Linux, 8e = LVM, 82 = Swap

# List partition types
sudo fdisk -l -u /dev/sdb

# Using parted (alternative)
sudo parted /dev/sdb
# mklabel msdos
# mkpart primary ext4 1MiB 1GiB
# quit
```

**Explanation:** fdisk = traditional. parted = modern. Both work. fdisk is more common.

---

## Exercise 4: Format Filesystems

**Solution:**

```bash
# Format ext4
sudo mkfs.ext4 /dev/sdb1
# Output: Filesystem created successfully

# Format with label
sudo mkfs.ext4 -L "data" /dev/sdb1

# Format xfs
sudo mkfs.xfs /dev/sdb2

# Format btrfs
sudo mkfs.btrfs /dev/sdb3

# Verify formatting
sudo blkid /dev/sdb1
# Output: UUID and TYPE

# Show filesystem info
sudo tune2fs -l /dev/sdb1 | grep -E "UUID|Block size|Inode count"

# Check all filesystems
sudo blkid -o list
# List all with UUIDs
```

**Explanation:** mkfs = make filesystem. ext4 = most common. xfs = scalable. btrfs = advanced.

---

## Exercise 5: Mount and Unmount

**Solution:**

```bash
# Create mount point
sudo mkdir -p /mnt/data

# Mount filesystem
sudo mount /dev/sdb1 /mnt/data
# No output = success

# Verify mounted
mount | grep sdb1
# Output: /dev/sdb1 on /mnt/data type ext4

# Check usage
df -h /mnt/data
# Output: Size, Used, Available

# Mount with options
sudo mount -o noatime,errors=remount-ro /dev/sdb1 /mnt/data

# List mounts with details
mount -v

# Unmount filesystem
sudo umount /mnt/data

# Verify unmounted
mount | grep data
# Should be empty

# Force unmount (if in use)
sudo umount -l /mnt/data
# -l = lazy unmount
```

**Explanation:** Mount = attach filesystem. Unmount = detach. Options = performance/safety.

---

## Exercise 6: Work with /etc/fstab

**Solution:**

```bash
# View fstab
cat /etc/fstab
# Output:
# /dev/sdb1 /mnt/data ext4 defaults 0 2
# UUID=... /home ext4 defaults 0 2

# Add new entry
echo "/dev/sdb1 /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Using UUID (better)
UUID=$(sudo blkid -s UUID -o value /dev/sdb1)
echo "UUID=$UUID /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Test fstab validity
sudo mount -a
# Mounts all, shows errors if any

# Verify mounts
df -h | grep mnt

# fstab fields:
# Device | Mount | Filesystem | Options | Dump | Pass
# /dev/sdb1 | /mnt/data | ext4 | defaults | 0 | 2

# Remove entry
sudo nano /etc/fstab
# Delete line manually
```

**Explanation:** fstab = filesystem table. Loaded at boot. UUID = safer than device name.

---

## Exercise 7: Disk Space Analysis

**Solution:**

```bash
# Show disk usage
df -h
# Output: Filesystem, Size, Used, Available

# Inode usage
df -i
# Output: Inode count, Used, Available, Percent

# Directory size
du -sh /home
# Total size of /home

# Top 10 directories
du -sh /home/* | sort -h | tail -10

# Find large files
find / -type f -size +100M 2>/dev/null | head

# Show usage with tree
du -h --max-depth=2 /home

# Space by filesystem
df -h

# Monitor growth
watch -n 1 'df -h /'
# Updates every 1 second

# Disk I/O monitoring
iostat -x 1 5
# I/O statistics
```

**Explanation:** df = filesystem usage. du = directory usage. Find = locate large files.

---

## Exercise 8: Filesystem Permissions and Quotas

**Solution:**

```bash
# Check mount options
mount | grep sdb1
# Output: rw, nosuid, nodev, noexec, relatime, etc.

# Show quota support
mount -o remount,usrquota,grpquota /mnt/data

# Initialize quota database
sudo quotacheck -cugm /mnt/data

# Enable quotas
sudo quotaon /mnt/data

# Check quota status
sudo quotactl -c /mnt/data

# Set user quota
sudo edquota -u username
# Edit: soft limit = 1000M, hard limit = 1500M

# View quotas
sudo quota -u username

# Generate report
sudo repquota /mnt/data

# Soft vs hard limits:
# Soft = grace period allowed
# Hard = absolute limit
```

**Explanation:** Quotas = usage limits. Soft = warning. Hard = enforced.

---

## Exercise 9: Check Filesystem Health

**Solution:**

```bash
# Check filesystem (read-only)
sudo fsck -n /dev/sdb1
# -n = no change

# Repair filesystem (use only unmounted)
sudo fsck -y /dev/sdb1
# -y = auto yes to all

# Ext4 specific check
sudo e2fsck -f /dev/sdb1
# -f = force check

# SMART status (if supported)
sudo smartctl -a /dev/sda
# Show disk health

# Monitor SMART
sudo smartctl -t short /dev/sda
# Run short test

# Bad blocks detection
sudo badblocks -v /dev/sda1

# Read-only mount to protect
sudo mount -o ro /dev/sdb1 /mnt/test

# Filesystem errors in dmesg
dmesg | grep -i error

# Check extended attributes
sudo tune2fs -l /dev/sdb1 | grep -i reserved
```

**Explanation:** fsck = filesystem check. SMART = disk health prediction. Regular checks = prevent loss.

---

## Exercise 10: Plan Storage Strategy

**Solution:**

```bash
# Document current layout
cat > storage_plan.txt << 'EOF'
=== Current Storage Layout ===

Disks:
$(lsblk)

Mounted Filesystems:
$(df -h)

Inode Usage:
$(df -i)

=== Storage Plan ===

1. Primary: /dev/sda (50GB)
   - /     : 30GB ext4
   - /home: 20GB ext4

2. Secondary: /dev/sdb (100GB)
   - /mnt/data: 100GB ext4

3. Quotas:
   - Users: 10GB soft, 15GB hard
   - Groups: 50GB soft, 75GB hard

4. Backup Strategy:
   - Daily incremental
   - Weekly full backup
   - Monthly offline copy

=== Maintenance Schedule ===
- Weekly: fsck -n check
- Monthly: SMART tests
- Quarterly: Capacity review
EOF

cat storage_plan.txt

# Verify current state
echo "Filesystems:"
df -hT

echo "Inodes:"
df -i

echo "Largest dirs:"
du -sh /* | sort -h | tail -5
```

**Explanation:** Planning = prevent outages. Document = understand usage. Monitor = detect trends.
