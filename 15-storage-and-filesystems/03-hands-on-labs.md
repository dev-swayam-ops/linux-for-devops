# Storage and Filesystems - Hands-On Labs

Complete practical exercises for storage management and filesystem operations.

**Time Estimate:** 3-4 hours for all 8 labs
**Prerequisites:** Modules 01, 02, 06, 15 README
**Environment:** Test VM with extra disk space recommended

---

## Lab 1: Exploring Disk Architecture (45 minutes)

### Objective
Understand how disks are organized and learn to identify partitions, filesystems, and mount points.

### Prerequisites
- Ubuntu/Debian system
- Terminal access
- Basic sudo access

### Step 1: List All Disks and Partitions

```bash
# Simple block device listing
lsblk

# Expected output:
# NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda      8:0    0  100G  0 disk
# ├─sda1   8:1    0    1G  0 part /boot
# └─sda2   8:2    0   99G  0 part /
# sdb      8:16   0  100G  0 disk
```

**What it shows:**
- `sda`, `sdb` = Physical disks
- `sda1`, `sda2` = Partitions on sda
- Size and mount points

### Step 2: Get Detailed Filesystem Information

```bash
# Show filesystem types
lsblk -f

# Expected output:
# NAME FSTYPE FSVER LABEL UUID              FSAVAIL FSUSE%
# sda1 ext4   1.0         abc123def456       850M    15%
# sda2 ext4   1.0         def456ghi789       85G     12%
# sdb  (empty - no filesystem)
```

### Step 3: View Partition Table

```bash
# Using fdisk (MBR style)
sudo fdisk -l /dev/sda

# Expected output:
# Disk /dev/sda: 100 GiB, 107374182400 bytes
# Disk model: VBOX HARDDISK
# Units: sectors of 1 * 512 = 512 bytes
# Device     Boot   Start      End  Sectors Size Id Type
# /dev/sda1  *       2048  1050623  1048576 512M 83 Linux
# /dev/sda2     1050624 209717247 208666624  99G 83 Linux
```

**Key information:**
- `Boot` = Bootable partition (marked with *)
- `Start/End` = Sector numbers
- `Sectors` = Number of sectors in partition
- `Size` = Human-readable size
- `Type` = Partition type (83=Linux, 82=Swap, 8e=LVM)

### Step 4: Check Mount Points

```bash
# Show all mounts
mount

# Expected output:
# /dev/sda1 on /boot type ext4 (rw,noatime,errors=remount-ro)
# /dev/sda2 on / type ext4 (rw,relatime,errors=remount-ro)
# ...

# Show just filesystem mounts
mount | grep /dev/sd

# Show in tree format
findmnt
```

### Step 5: Get Device UUIDs and Labels

```bash
# Show UUID for each device
blkid

# Expected output:
# /dev/sda1: UUID="abc123def456" TYPE="ext4" PARTUUID="xyz789"
# /dev/sda2: UUID="def456ghi789" TYPE="ext4" PARTUUID="xyz790"

# Get UUID for specific device
blkid /dev/sda1
```

**Why UUIDs matter:**
- Partitions can change device names (sda → sdb)
- UUID never changes
- Used in /etc/fstab for reliable mounting

### Step 6: Understand Inode Usage

```bash
# Show inode statistics
df -i /

# Expected output:
# Filesystem     Inodes  IUsed   IFree IUse% Mounted on
# /dev/sda2    6553600  50000 6503600    1% /

# Check if any filesystem has high inode usage
df -i | awk '$5 > 80 {print}'  # Show if >80% full
```

**Inode info:**
- IUsed = number of inodes in use
- IFree = available inodes
- IUse% = percentage used
- When IUse% is high: many small files or file descriptor leaks

### Step 7: Explore /etc/fstab

```bash
# View current mount configuration
cat /etc/fstab

# Expected output:
# /dev/sda1   /boot     ext4    defaults        0 2
# /dev/sda2   /         ext4    defaults        0 1
# UUID=xyz    /home     ext4    defaults        0 2

# Understand each field
# Field 1: Device (/dev/xxx or UUID=xxx)
# Field 2: Mount point (where it attaches)
# Field 3: Filesystem type (ext4, xfs, nfs, etc.)
# Field 4: Mount options (defaults, ro, nosuid, etc.)
# Field 5: Dump flag (0=no backup, 1=backup)
# Field 6: Pass flag (fsck priority: 0=skip, 1=root, 2=other)
```

### Verification Checklist

- [ ] Can list all disks with `lsblk`
- [ ] Understand device names (sda, sdb, sda1, sda2)
- [ ] Know your filesystem types (ext4, xfs)
- [ ] Can identify mount points
- [ ] Understand fstab format
- [ ] Know what UUIDs are and why they're used

---

## Lab 2: Creating and Mounting Filesystems (50 minutes)

### Objective
Learn to partition a disk, create filesystems, and mount them manually.

### ⚠️ Warning
This lab modifies disk structure. Use test disk or VM only!

### Step 1: Identify Test Disk

```bash
# List available disks
lsblk

# If you have a second disk (sdb), use it
# If not, create virtual disk in VM:
# - VirtualBox: VM Settings → Storage → Add new SATA disk
# - KVM: virsh attach-disk

# For this lab, assume /dev/sdb (20GB)
```

### Step 2: Create Partition

```bash
# Open fdisk for /dev/sdb
sudo fdisk /dev/sdb

# At fdisk prompt, follow steps:
Welcome to fdisk. Commands:
m   = help
p   = print
n   = new partition
d   = delete partition
w   = write (SAVE!)
q   = quit

# Create partition:
> n
Partition number [1-4]: 1
First sector: (press Enter for default)
Last sector: +10G

> p  (verify it looks right)
Disk /dev/sdb: 20 GiB
Device     Boot Start      End    Sectors Size Id Type
/dev/sdb1        2048 20973567 20971520  10G 83 Linux

> w
The partition table has been altered!
Calling ioctl() to re-read partition table.

# Verify
lsblk /dev/sdb
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sdb      8:16   0  20G  0 disk
└─sdb1   8:17   0  10G  0 part
```

### Step 3: Create Filesystem

```bash
# Create ext4 filesystem on partition
sudo mkfs.ext4 /dev/sdb1

# Expected output:
# mke2fs 1.45.6 (20-Mar-2020)
# Creating filesystem with 2621440 4k blocks and 655360 inodes
# Filesystem UUID: abc123def456
# Writing superblocks and inode tables: done
# Creating journal (16384 blocks): done
# Writing superblocks and inode allocation bitmaps: done

# Verify filesystem
lsblk -f /dev/sdb1
NAME FSTYPE FSVER LABEL UUID              FSAVAIL FSUSE%
sdb1 ext4   1.0         abc123def456      9.5G    0%
```

### Step 4: Create Mount Point

```bash
# Create directory for mounting
sudo mkdir -p /mnt/data

# Verify
ls -ld /mnt/data
drwxr-xr-x 2 root root 4096 Feb 15 10:30 /mnt/data
```

### Step 5: Mount Filesystem

```bash
# Mount the filesystem
sudo mount /dev/sdb1 /mnt/data

# Verify it's mounted
mount | grep /dev/sdb1
/dev/sdb1 on /mnt/data type ext4 (rw,relatime)

# Or use lsblk
lsblk /dev/sdb1
NAME MOUNTPOINT
sdb1 /mnt/data
```

### Step 6: Test Read/Write

```bash
# Create a test file
echo "Hello, Storage World!" | sudo tee /mnt/data/test.txt
Hello, Storage World!

# Verify file exists
cat /mnt/data/test.txt
Hello, Storage World!

# Check space usage
df -h /mnt/data
Filesystem      Size  Used Avail Use%  Mounted on
/dev/sdb1        10G   33M  9.5G  1%   /mnt/data
```

### Step 7: Unmount Filesystem

```bash
# Unmount
sudo umount /mnt/data

# Verify unmounted
mount | grep /dev/sdb1
(no output = not mounted)

lsblk /dev/sdb1
NAME MOUNTPOINT
sdb1 (empty)
```

### Verification Checklist

- [ ] Created partition on test disk
- [ ] Created ext4 filesystem
- [ ] Mounted filesystem to /mnt/data
- [ ] Created test file
- [ ] Verified space usage
- [ ] Successfully unmounted

### Cleanup

```bash
# Remove test file
sudo rm -f /mnt/data/test.txt

# Note: Filesystem remains on disk for Lab 3
```

---

## Lab 3: Configuring /etc/fstab for Persistent Mounting (45 minutes)

### Objective
Configure /etc/fstab to automatically mount filesystems at boot.

### Step 1: Get UUID of Test Filesystem

```bash
# From Lab 2, get UUID of /dev/sdb1
blkid /dev/sdb1

# Expected output:
# /dev/sdb1: UUID="abc123def456" TYPE="ext4"

# Copy the UUID (you'll need it)
```

### Step 2: Backup Current fstab

```bash
# Always backup before editing
sudo cp /etc/fstab /etc/fstab.backup

# Verify backup exists
ls -l /etc/fstab.backup
```

### Step 3: Edit fstab

```bash
# Open in editor
sudo nano /etc/fstab

# Add line for test filesystem at end:
# UUID=abc123def456  /mnt/data  ext4  defaults  0  2

# Fields:
# UUID=abc123def456  ← Device (from Step 1)
# /mnt/data          ← Mount point (from Lab 2)
# ext4               ← Filesystem type
# defaults           ← Mount options (standard)
# 0                  ← Dump (0 = skip)
# 2                  ← Pass (2 = check after root)

# Save: Ctrl+O, Enter, Ctrl+X
```

### Step 4: Test fstab Entry

```bash
# This tests syntax without rebooting
sudo mount -a

# Check if mounted (should succeed)
mount | grep /dev/sdb1
/dev/sdb1 on /mnt/data type ext4 (rw,relatime)
```

### Step 5: Verify Mount Persists Across Unmount

```bash
# Unmount
sudo umount /mnt/data

# Remount using fstab
sudo mount /mnt/data

# Verify
mount | grep /dev/sdb1
/dev/sdb1 on /mnt/data type ext4 (rw,relatime)
```

### Step 6: Check fstab with findmnt

```bash
# Show all fstab entries
findmnt /mnt/data

# Expected output:
# TARGET    SOURCE     FSTYPE OPTIONS
# /mnt/data /dev/sdb1  ext4   rw,relatime
```

### Step 7: Test Mount Options

```bash
# Add noatime option to reduce disk writes
# Edit fstab line to:
# UUID=abc123def456  /mnt/data  ext4  noatime  0  2

# Remount to apply
sudo mount -o remount /mnt/data

# Verify option applied
mount | grep /dev/sdb1
/dev/sdb1 on /mnt/data type ext4 (rw,noatime)
```

### Verification Checklist

- [ ] Edited /etc/fstab with UUID entry
- [ ] Backup of fstab created
- [ ] `mount -a` succeeds without errors
- [ ] Filesystem mounts and unmounts via fstab
- [ ] Mount options are applied correctly
- [ ] findmnt shows fstab configuration

### Cleanup

```bash
# Unmount test filesystem (optional)
sudo umount /mnt/data
```

---

## Lab 4: Analyzing Disk Usage and Finding Space Hogs (40 minutes)

### Objective
Master tools for understanding disk usage and locating large files.

### Step 1: Overall Filesystem Usage

```bash
# Check total space on all filesystems
df -h

# Expected output:
# Filesystem      Size  Used Avail Use%  Mounted on
# /dev/sda2       100G   15G   85G  15%  /
# tmpfs           7.8G     0  7.8G   0%  /dev/shm
# /dev/sdb1        10G  100M  9.5G   2%  /mnt/data

# Focus on root filesystem
df -h /
```

### Step 2: Check Inode Usage

```bash
# Show inode utilization
df -i /

# Expected output:
# Filesystem     Inodes  IUsed   IFree IUse% Mounted on
# /dev/sda2    6553600  50000 6503600    1% /

# If IUse% > 80%, investigate for many small files
# Find directories with many files:
find / -type f 2>/dev/null | wc -l
```

### Step 3: Top-Level Directory Sizes

```bash
# Show size of each top-level directory
du -sh /*

# Expected output (varies by system):
# 4.1M     /bin
# 45.2M    /boot
# 145M     /etc
# 2.3G     /home
# 23M      /lib
# 0B       /media
# 0B       /mnt
# 42M      /opt
# 0B       /proc
# 0B       /root
# 850M     /srv
# 5.2G     /usr
# 1.3G     /var
```

**Analysis:**
- `/home` = 2.3G (user files)
- `/usr` = 5.2G (programs, libraries)
- `/var` = 1.3G (logs, caches)

### Step 4: Investigate Largest Directory

```bash
# Go deeper into largest (e.g., /home)
du -sh /home/*

# Expected output:
# 1.2G     /home/user1
# 800M     /home/user2
# 300M     /home/user3

# Further investigate top user
du -sh /home/user1/*

# Shows subdirectories
# 500M     /home/user1/Downloads
# 450M     /home/user1/Documents
# 200M     /home/user1/Videos
```

### Step 5: Find Large Individual Files

```bash
# Find files larger than 100MB
find / -type f -size +100M 2>/dev/null

# Expected output:
# /home/user1/Downloads/large-file.iso
# /usr/share/archive.tar.gz
# /var/log/old-logfile

# Show them sorted by size
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | sort -k5 -h | tail -10
```

### Step 6: Use ncdu for Interactive Analysis (if available)

```bash
# Install if not present
sudo apt install ncdu

# Run interactive analyzer
sudo ncdu /home

# In ncdu:
# - Navigate with arrow keys
# - Press 'd' to delete
# - Press 'q' to quit
# - Shows percentage breakdown
```

### Step 7: Find Cache and Temporary Files

```bash
# System caches
du -sh /var/cache/*

# Package manager cache (Ubuntu)
du -sh /var/cache/apt/archives

# Clear old package cache
sudo apt clean

# Temporary files
du -sh /tmp/*

# Old log files
du -sh /var/log/*
ls -lh /var/log/*.1  # Compressed old logs
```

### Step 8: Monitor Real-Time Disk Usage

```bash
# Watch space changes
watch -n 1 'df -h / | tail -1'

# Output updates every second:
# Filesystem      Size  Used Avail Use%  Mounted on
# /dev/sda2       100G   15G   85G  15%  /

# Exit with Ctrl+C
```

### Verification Checklist

- [ ] Can list all filesystems with `df -h`
- [ ] Understand inode usage with `df -i`
- [ ] Can identify large directories
- [ ] Can find files larger than threshold
- [ ] Know where caches and logs are
- [ ] Can estimate disk usage before deletion

---

## Lab 5: Setting Up LVM for Flexible Storage (50 minutes)

### Objective
Create and manage Logical Volumes for flexible storage allocation.

### ⚠️ Warning
Lab involves disk operations. Use test environment!

### Step 1: Check for Free Disk Space

```bash
# Identify available disk
lsblk

# For this lab, assume /dev/sdb (at least 20GB)
# If using existing disk, ensure unused space

# Check if LVM is installed
which lvm
/usr/sbin/lvm

# If not: sudo apt install lvm2
```

### Step 2: Initialize Physical Volume

```bash
# Create physical volume from disk/partition
sudo pvcreate /dev/sdb

# If using partition:
# sudo pvcreate /dev/sdb1

# Verify
sudo pvdisplay
--- Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size              20.00 GiB
  Allocatable          yes
  PE Size               4.00 MiB
  Total PE              5120
  Allocated PE          0
  Free PE               5120
```

### Step 3: Create Volume Group

```bash
# Create volume group from physical volume
sudo vgcreate vg0 /dev/sdb

# Expected output:
# Volume group "vg0" successfully created

# Verify
sudo vgdisplay

# Short format
sudo vgs
VG   #PV #LV #SN Attr   VSize   VFree
vg0    1   0   0 wz--n- 20.00g 20.00g
```

**Understanding:**
- VSize = 20.00g (total from PV)
- VFree = 20.00g (available to allocate)

### Step 4: Create Logical Volumes

```bash
# Create first logical volume (10GB)
sudo lvcreate -L 10G -n lv_root vg0

# Create second logical volume (5GB)
sudo lvcreate -L 5G -n lv_data vg0

# Create third with remaining space
sudo lvcreate -l 100%FREE -n lv_backup vg0

# Verify
sudo lvdisplay

# Short format
sudo lvs
LV        VG   Attr       LSize  Pool Origin
lv_root   vg0  -wi-a----- 10.00g
lv_data   vg0  -wi-a----- 5.00g
lv_backup vg0  -wi-a----- 5.00g
```

### Step 5: Create Filesystems on Logical Volumes

```bash
# Create ext4 on each LV
sudo mkfs.ext4 /dev/vg0/lv_root
sudo mkfs.ext4 /dev/vg0/lv_data
sudo mkfs.ext4 /dev/vg0/lv_backup

# Verify
lsblk -f /dev/vg0/lv_root
NAME              FSTYPE FSVER LABEL UUID
lv_root           ext4   1.0         abc123
```

### Step 6: Mount Logical Volumes

```bash
# Create mount points
sudo mkdir -p /mnt/root /mnt/data /mnt/backup

# Mount filesystems
sudo mount /dev/vg0/lv_root /mnt/root
sudo mount /dev/vg0/lv_data /mnt/data
sudo mount /dev/vg0/lv_backup /mnt/backup

# Verify
mount | grep /mnt/
/dev/mapper/vg0-lv_root on /mnt/root type ext4 (rw,relatime)
/dev/mapper/vg0-lv_data on /mnt/data type ext4 (rw,relatime)
/dev/mapper/vg0-lv_backup on /mnt/backup type ext4 (rw,relatime)

# Check space
df -h /mnt/
Filesystem                Size  Used Avail Use%  Mounted on
/dev/mapper/vg0-lv_root  9.8G   33M  9.3G  1%   /mnt/root
/dev/mapper/vg0-lv_data  4.9G   20M  4.6G  1%   /mnt/data
/dev/mapper/vg0-lv_backup 4.9G   20M  4.6G  1%   /mnt/backup
```

### Step 7: Grow Logical Volume

```bash
# Check current size
sudo lvs vg0/lv_root
LV      VG   Attr LSize
lv_root vg0  -wi-a----- 10.00g

# Extend logical volume by 5GB
sudo lvextend -L +5G /dev/vg0/lv_root

# Extend to specific size
# sudo lvextend -L 20G /dev/vg0/lv_root

# Extend filesystem to use new space (ext4)
sudo resize2fs /dev/vg0/lv_root

# Or for XFS:
# sudo xfs_growfs /mnt/root

# Verify new size
df -h /mnt/root
Filesystem                Size  Used Avail Use%  Mounted on
/dev/mapper/vg0-lv_root  14.8G  33M  14.3G  1%   /mnt/root
```

### Step 8: Shrink Logical Volume (Advanced)

```bash
# Shrink MUST be done carefully (data loss risk!)
# 1. Unmount filesystem
sudo umount /mnt/data

# 2. Check and repair filesystem
sudo e2fsck -f /dev/vg0/lv_data

# 3. Shrink filesystem to 3GB
sudo resize2fs /dev/vg0/lv_data 3G

# 4. Shrink logical volume
sudo lvreduce -L 3G /dev/vg0/lv_data

# 5. Remount
sudo mount /dev/vg0/lv_data /mnt/data

# Verify
df -h /mnt/data
Filesystem                Size  Used Avail Use%  Mounted on
/dev/mapper/vg0-lv_data  2.9G   20M  2.7G  1%   /mnt/data
```

### Verification Checklist

- [ ] Physical volume created with `pvcreate`
- [ ] Volume group created with `vgcreate`
- [ ] Logical volumes created with `lvcreate`
- [ ] Filesystems created on LVs
- [ ] Mounted successfully
- [ ] Extended LV and filesystem
- [ ] Can show LVM status with `lvdisplay`

### Cleanup

```bash
# Unmount all
sudo umount /mnt/root /mnt/data /mnt/backup

# Note: LVM setup remains for reference
# To remove: lvremove, vgremove, pvremove
```

---

## Lab 6: Understanding RAID Configuration (45 minutes)

### Objective
Learn RAID concepts and create software RAID array.

### Step 1: Check RAID Support

```bash
# Check if mdadm is installed
which mdadm
/sbin/mdadm

# If not: sudo apt install mdadm

# Check current RAID arrays
cat /proc/mdstat
Personalities : [raid1]
md0 : active raid1 sdc1[1] sdb1[0]
      1048512 blocks super 1.2 [2/2] [UU]
      bitmap: 0/1 pages [0KB], 65536KB chunk
```

### Step 2: Identify Disks for RAID

```bash
# Identify at least 2 available disks/partitions
lsblk

# For this lab, assume /dev/sdb1 and /dev/sdc1
# Each at least 5GB

# If on VM, create new virtual disks:
# - Add multiple disks in VM settings
# - Partition them
```

### Step 3: Create RAID 1 (Mirror)

```bash
# Stop any existing arrays (if applicable)
# sudo mdadm --stop /dev/md0

# Create RAID 1 array
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1

# When prompted:
# Continue creating array? y

# Expected output:
# mdadm: Defaulting to version 1.2 metadata and 64 sectors chunk
# mdadm: array /dev/md0 started.

# Check status
cat /proc/mdstat
md0 : active raid1 sdc1[1] sdb1[0]
      5242880 blocks super 1.2 [2/2] [UU]
      bitmap: 0/3 pages [0KB], 65536KB chunk
```

**Understanding:**
- `[2/2]` = All 2 disks present and functioning
- `[UU]` = Both disks "Up"
- Status is "active"

### Step 4: Create Filesystem on RAID

```bash
# Create ext4 on RAID
sudo mkfs.ext4 /dev/md0

# Expected output:
# Creating filesystem with 1310720 4k blocks and 327680 inodes
# Filesystem UUID: abc123def456

# Verify
lsblk /dev/md0
NAME FSTYPE FSVER LABEL UUID
md0  ext4   1.0         abc123def456
```

### Step 5: Mount RAID Array

```bash
# Create mount point
sudo mkdir -p /mnt/raid

# Mount
sudo mount /dev/md0 /mnt/raid

# Verify
mount | grep md0
/dev/md0 on /mnt/raid type ext4 (rw,relatime)

# Check space
df -h /mnt/raid
Filesystem      Size  Used Avail Use%  Mounted on
/dev/md0        5.0G   33M  4.7G  1%   /mnt/raid
```

### Step 6: Test RAID Reliability

```bash
# Create test file
echo "RAID Test Data" | sudo tee /mnt/raid/testfile
RAID Test Data

# Simulate disk failure (mark sdb1 as faulty)
sudo mdadm /dev/md0 --manage --set-faulty /dev/sdb1

# Check status
cat /proc/mdstat
md0 : active raid1 sdc1[1] sdb1[0](F)
      5242880 blocks super 1.2 [2/1] [_U]

# Status changed:
# [2/1] = Need 2, have 1 (one failed)
# [_U] = One down (_), one up (U)

# Verify data still accessible
cat /mnt/raid/testfile
RAID Test Data

# System is still functioning on remaining disk!
```

### Step 7: Replace Failed Disk

```bash
# Remove failed disk from array
sudo mdadm /dev/md0 --manage --remove /dev/sdb1

# Status
cat /proc/mdstat
md0 : active raid1 sdc1[1]
      5242880 blocks super 1.2 [2/1] [_U]
      recovery: 0/5242880 (0%)

# Add replacement disk (assume /dev/sdd1)
sudo mdadm /dev/md0 --manage --add /dev/sdd1

# Status shows rebuilding
cat /proc/mdstat
md0 : active raid1 sdc1[1] sdd1[2]
      5242880 blocks super 1.2 [2/2] [_U]
      recovery: 15%

# Wait for rebuild to complete
# (Takes time proportional to size)
```

### Verification Checklist

- [ ] Created RAID 1 array
- [ ] Created filesystem on RAID
- [ ] Mounted successfully
- [ ] Tested data persistence
- [ ] Simulated disk failure
- [ ] Verified data still accessible
- [ ] Can view RAID status with `mdadm --detail`

### Cleanup

```bash
# Unmount
sudo umount /mnt/raid

# Stop RAID array (optional)
# sudo mdadm --stop /dev/md0
```

---

## Lab 7: Implementing Disk Quotas (40 minutes)

### Objective
Set up and manage disk quotas to limit user storage.

### Step 1: Check Quota Support

```bash
# Check if quotas installed
which edquota

# If not: sudo apt install quota quotatool

# Check if filesystem supports quotas
tune2fs -l /dev/sda2 | grep -i quota
```

### Step 2: Enable Quotas on Filesystem

```bash
# Edit /etc/fstab to enable quotas
# Find the line for /home (or any filesystem)
# Add usrquota,grpquota to mount options

# Example original:
# /dev/sda2 /home ext4 defaults 0 2

# Example modified:
# /dev/sda2 /home ext4 defaults,usrquota,grpquota 0 2

# Edit:
sudo nano /etc/fstab

# Remount filesystem
sudo mount -o remount /home

# Verify options
mount | grep /home
/dev/sda2 on /home type ext4 (rw,usrquota,grpquota)
```

### Step 3: Initialize Quota Database

```bash
# Create quota files
sudo quotacheck -cugm /home

# Expected output:
# Creating user quota file /home/aquota.user...
# Creating group quota file /home/aquota.group...
# Quotafile quarantine files created.

# Verify files created
ls -la /home/aquota*
-rw------- 1 root root  16384 Feb 15 11:00 /home/aquota.group
-rw------- 1 root root  16384 Feb 15 11:00 /home/aquota.user
```

### Step 4: Enable Quotas

```bash
# Turn on quotas
sudo quotaon -u -g /home

# Check status
sudo quotaon -p /home
group quotas are on for /home
user quotas are on for /home
```

### Step 5: Set User Quota

```bash
# Edit quota for user 'testuser'
sudo edquota -u testuser

# Text editor opens (vi):
# Disk quotas for user testuser (uid 1001):
#   Filesystem                   blocks       soft       hard     inodes     soft     hard
#   /home                         100        500000     600000         10    50000    60000

# Fields:
# blocks = current usage (read-only)
# soft = warning threshold (in KB)
# hard = maximum limit (in KB)
# inodes = current file count
# inodes soft = warning file count
# inodes hard = maximum file count

# Example: Set 5GB soft, 6GB hard limit
# Change to:
# /home                         100       5242880    6291456         10    50000    60000

# Save and exit
```

### Step 6: View User Quota

```bash
# Check quota for user
quota -u testuser

# Expected output:
# Disk quotas for user testuser (uid 1001):
#      Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
#      /home        1024   5242880  6291456         2      50000  60000

# or with human-readable format
quota -u testuser | awk '{if(NR>1) printf "%s %dKB/%dKB\n", $1, $2, $3}'
```

### Step 7: Test Quota Enforcement

```bash
# Create test user
sudo useradd -m testuser

# Set quota on testuser
sudo edquota -u testuser
# Set soft=100KB, hard=200KB (small for testing)

# Switch to test user
su - testuser

# Try to create large file
dd if=/dev/zero of=largefile bs=1M count=150

# Expected:
# Error: Disk quota exceeded
# File size will not exceed soft limit

# Check usage
quota
```

### Step 8: View All Quotas

```bash
# Report all user quotas on /home
sudo repquota -u /home

# Expected output:
# Block grace time: 7days; Inode grace time: 7days
#   User            used  soft  hard grace  used  soft  hard grace
# testuser         -- 51200 102400 204800        2    50    100
# user1          -- 1024000 unlimited unlimited 4321    -      -
# user2            50000  1048576 1258291 6days  100 10000 15000

# Report all group quotas
sudo repquota -g /home
```

### Verification Checklist

- [ ] Quotas enabled in /etc/fstab
- [ ] Quota database initialized
- [ ] Quotas activated with quotaon
- [ ] User quota set with edquota
- [ ] Can view quota with quota command
- [ ] Can view all quotas with repquota

---

## Lab 8: Repairing and Recovering Filesystems (45 minutes)

### Objective
Detect and repair filesystem corruption safely.

### ⚠️ IMPORTANT
Never run fsck on mounted filesystem! This lab uses test filesystem.

### Step 1: Create Test Filesystem

```bash
# From Lab 2, use existing /dev/sdb1 with filesystem
# Or create new test partition and filesystem

# Ensure unmounted
sudo umount /mnt/data 2>/dev/null

# Verify
mount | grep /dev/sdb1
(no output = not mounted)
```

### Step 2: Perform Read-Only Check

```bash
# Safe check without modifications
sudo fsck -n /dev/sdb1

# Expected output:
# fsck from util-linux 2.35.2
# e2fsck 1.45.6 (20-Mar-2020)
# Block device busy.
# Will not try to clean this time.

# The device is busy because filesystem is mounted
# For lab, create new filesystem or ensure properly unmounted
```

### Step 3: Check Filesystem After Unmount

```bash
# Ensure unmounted
sudo umount /mnt/data

# Safe read-only check
sudo fsck.ext4 -n /dev/sdb1

# Expected (if filesystem is clean):
# e2fsck 1.45.6 (20-Mar-2020)
# /dev/sdb1: clean, 12/655360 inodes, 73821/2621440 blocks
# No errors!

# If errors found, next step repairs them
```

### Step 4: Repair Filesystem

```bash
# Auto-repair with fsck
sudo fsck.ext4 -p /dev/sdb1

# Options:
# -p = preen (auto-fix safe issues)
# -y = assume yes to all prompts
# -f = force check even if clean

# Expected output:
# e2fsck 1.45.6 (20-Mar-2020)
# /dev/sdb1: clean, 12/655360 inodes, 73821/2621440 blocks

# If repairs made:
# Pass 1: Checking inodes, blocks, and sizes
# Pass 2: Checking directory structure
# Pass 3: Checking directory connectivity
# Pass 4: Checking reference counts
# Pass 5: Checking group summary information
# /dev/sdb1: ***** FILE SYSTEM WAS MODIFIED ***** (if changed)
```

### Step 5: Check for Bad Sectors

```bash
# Test disk for bad sectors (non-destructive)
sudo badblocks -v /dev/sdb1 | head -50

# Expected output:
# Checking blocks 0 to 10485759
# Testing with pattern 0xaa: done
# Reading and comparing: 0%
# (continues checking)

# If no output or completes successfully:
# No bad blocks found
```

### Step 6: Show Filesystem Information

```bash
# Display ext4 filesystem info
sudo tune2fs -l /dev/sdb1

# Important fields:
# - Filesystem UUID: abc123def456
# - Filesystem state: clean
# - Last mounted on: /mnt/data
# - Filesystem created: Mon Feb 15 10:00:00 2021
# - Last mount time: Mon Feb 15 11:30:00 2021
# - Mount count: 5
# - Maximum mount count before fsck: 30
# - Last checked: Mon Feb 15 11:30:00 2021
# - Check interval: 15552000 (180 days)
```

### Step 7: Change Fsck Parameters

```bash
# Set fsck to run after 30 mounts (default)
sudo tune2fs -c 30 /dev/sdb1

# Set fsck to run every 180 days (default)
sudo tune2fs -i 180d /dev/sdb1

# Disable automatic fsck
sudo tune2fs -c 0 /dev/sdb1

# Verify changes
sudo tune2fs -l /dev/sdb1 | grep -E "Mount count|Check interval"
```

### Step 8: Remount and Verify

```bash
# Remount filesystem
sudo mount /dev/sdb1 /mnt/data

# Verify it works
mount | grep /dev/sdb1
/dev/sdb1 on /mnt/data type ext4 (rw,relatime)

# Write test file
echo "Filesystem is healthy!" | sudo tee /mnt/data/health_check
Filesystem is healthy!

# Read back
cat /mnt/data/health_check
Filesystem is healthy!
```

### Verification Checklist

- [ ] Can run fsck in read-only mode
- [ ] Can perform automatic repair
- [ ] Can check for bad sectors
- [ ] Understand filesystem parameters
- [ ] Can modify fsck schedule
- [ ] Filesystem mounts and works after repair

---

## Summary

These 8 labs covered:

1. **Disk Architecture** - Understanding how Linux sees disks
2. **Filesystem Creation** - Creating filesystems from scratch
3. **Persistent Mounting** - Configuring /etc/fstab
4. **Space Analysis** - Finding what uses disk space
5. **LVM** - Flexible logical volume management
6. **RAID** - Redundancy with software RAID
7. **Quotas** - Limiting user storage
8. **Repair** - Detecting and fixing issues

**You now can:**
- Partition disks safely
- Create and mount filesystems
- Monitor disk usage
- Implement LVM for flexibility
- Set up RAID for redundancy
- Manage user quotas
- Recover from filesystem issues

Continue learning with [scripts/](scripts/) for automation patterns!
