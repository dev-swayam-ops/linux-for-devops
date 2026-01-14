# Storage and Filesystems Commands Cheatsheet

Quick reference for 80+ essential storage and filesystem commands.

---

## Section 1: Disk and Partition Information

### List Disks and Partitions

| Command | Purpose | Example |
|---------|---------|---------|
| `lsblk` | List all block devices in tree format | `lsblk` |
| `fdisk -l` | List all disks and partitions (requires sudo) | `sudo fdisk -l` |
| `parted -l` | List all disks with GPT support (requires sudo) | `sudo parted -l` |
| `blkid` | Show block device UUID and filesystem type | `blkid` |
| `df -h` | Show mounted filesystems and space usage | `df -h` |
| `lsblk -f` | Show filesystem type for each device | `lsblk -f` |

**Examples:**
```bash
# Simple block device list
lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0  100G  0 disk
├─sda1   8:1    0    1G  0 part /boot
└─sda2   8:2    0   99G  0 part /

# Show filesystems
lsblk -f
NAME FSTYPE FSVER LABEL UUID              FSAVAIL FSUSE% MOUNTPOINT
sda1 ext4   1.0         abc123def456        900M   10%    /boot
sda2 ext4   1.0         def456ghi789       85.5G   12%    /

# Find UUID for a device
blkid /dev/sda1
/dev/sda1: UUID="abc123def456" TYPE="ext4"
```

---

## Section 2: Disk Space Analysis

### Disk Usage Commands

| Command | Purpose |
|---------|---------|
| `df` | Disk free - filesystem-level usage |
| `df -h` | Human-readable format |
| `df -i` | Show inode usage |
| `du` | Disk usage - directory and file level |
| `du -sh` | Show total size of directory |
| `du -sh *` | Show size of each item in directory |
| `du -sh /*` | Show size of each top-level directory |
| `du --max-depth=1 /home` | Show immediate subdirectories |
| `ncdu` | Interactive disk space analyzer |
| `find / -type f -size +100M` | Find files larger than 100MB |

**Examples:**
```bash
# Overall filesystem usage
df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   12G   88G  12% /
/dev/sda2       500G  250G  250G  50% /home

# Inode usage (warning when high)
df -i
Filesystem     Inodes IUsed IFree IUse% Mounted on
/dev/sda1    6553600 50000 6503600  1%  /

# Directory size (slow on large directories)
du -sh /home
485G    /home

# Top space consumers
du -sh /home/* | sort -h | tail -10
45G     /home/user1
42G     /home/user2
10G     /home/user3

# Find large files
find /home -type f -size +1G
/home/user1/huge-backup.tar.gz
/home/user2/vm-image.iso

# Interactive analysis (if installed)
ncdu /home
```

---

## Section 3: Partition Management

### Partitioning Commands

| Command | Purpose | Tool |
|---------|---------|------|
| `fdisk` | Interactive partition editor (MBR) | Text-based |
| `parted` | Partition editor supporting GPT | Text-based |
| `gdisk` | GPT partition editor | Text-based |
| `gparted` | Graphical partition editor | GUI |
| `cfdisk` | Colored fdisk | TUI |

### Fdisk (MBR Partitions)

**View partitions:**
```bash
# Show partition table
sudo fdisk -l /dev/sda
Disk /dev/sda: 100 GiB, 107374182400 bytes
Units: sectors of 1 * 512 = 512 bytes
Device     Boot   Start      End  Sectors Size Id Type
/dev/sda1  *       2048  1050623  1048576 512M 83 Linux
/dev/sda2     1050624 209717247 208666624  99G 83 Linux

# Interactive mode
sudo fdisk /dev/sda
# Commands: m=help, p=print, n=new, d=delete, w=write, q=quit
```

### Parted (GPT Partitions)

**View and edit:**
```bash
# Show partition table (supports both MBR and GPT)
sudo parted -l

# Interactive mode
sudo parted /dev/sda
> print          # Show partitions
> mkpart primary ext4 0% 50%  # Create new partition
> resizepart 1 100GB  # Resize partition 1
> quit

# Command line (one shot)
sudo parted /dev/sda mkpart primary ext4 0% 50%
```

### Gdisk (GPT only)

**For GPT disks:**
```bash
# Show GPT partition table
sudo gdisk -l /dev/sda
GPT fdisk (gdisk) version 1.0.5

# Interactive mode
sudo gdisk /dev/sda
# Commands: p=print, n=new, d=delete, w=write, q=quit
```

---

## Section 4: Filesystem Creation

### Create Filesystems

| Command | Purpose | Example |
|---------|---------|---------|
| `mkfs.ext4` | Create ext4 filesystem | `sudo mkfs.ext4 /dev/sda1` |
| `mkfs.xfs` | Create XFS filesystem | `sudo mkfs.xfs /dev/sda1` |
| `mkfs.btrfs` | Create Btrfs filesystem | `sudo mkfs.btrfs /dev/sda1` |
| `mkfs.vfat` | Create FAT filesystem | `sudo mkfs.vfat /dev/sda1` |
| `mkfs` | Generic, auto-detects type | `sudo mkfs -t ext4 /dev/sda1` |

**Examples:**
```bash
# Create ext4 with custom block size
sudo mkfs.ext4 -b 4096 /dev/sda1

# Create XFS with specific log size
sudo mkfs.xfs -l size=32m /dev/sda1

# Create Btrfs with compression
sudo mkfs.btrfs /dev/sda1
# Enable compression after mount: mount -o compress=zstd

# Format USB drive as FAT
sudo mkfs.vfat -n USB_DRIVE /dev/sdb1

# Force format (no prompts)
sudo mkfs.ext4 -F /dev/sda1
```

---

## Section 5: Mounting and Unmounting

### Mount Operations

| Command | Purpose | Example |
|---------|---------|---------|
| `mount` | Mount filesystem | `sudo mount /dev/sda1 /mnt/data` |
| `mount -t type device path` | Mount with specific type | `sudo mount -t ext4 /dev/sda1 /mnt` |
| `mount -o options device path` | Mount with options | `sudo mount -o ro /dev/sda1 /mnt` |
| `mount -a` | Mount all filesystems in /etc/fstab | `sudo mount -a` |
| `umount` | Unmount filesystem | `sudo umount /mnt/data` |
| `umount -l` | Lazy unmount (when in use) | `sudo umount -l /mnt` |
| `mountpoint` | Check if directory is mount point | `mountpoint /mnt` |

**Examples:**
```bash
# Mount with defaults
sudo mount /dev/sda1 /mnt/data

# Mount read-only
sudo mount -o ro /dev/sda1 /mnt/data

# Mount read-only and noatime (skip access time updates)
sudo mount -o ro,noatime /dev/sda1 /mnt/data

# Mount with multiple options
sudo mount -o rw,nosuid,nodev /dev/sda1 /mnt/data

# Mount all in fstab
sudo mount -a

# Check mount points
mount | grep sda
/dev/sda1 on /boot type ext4 (rw,noatime)
/dev/sda2 on / type ext4 (rw)

# Unmount
sudo umount /mnt/data

# Unmount even if in use (risky)
sudo umount -l /mnt/data

# Check if mounted
mountpoint /mnt/data
/mnt/data is a mountpoint
```

---

## Section 6: Filesystem Repair and Checking

### Filesystem Check and Repair

| Command | Purpose | Safety |
|---------|---------|--------|
| `fsck` | Check filesystem (interactive) | Umount first! |
| `fsck -n` | Read-only check (no repair) | Safe |
| `e2fsck` | ext4 check/repair | For ext4 only |
| `xfs_repair` | XFS repair utility | For XFS only |
| `badblocks` | Check for bad sectors | Non-destructive |
| `tune2fs` | Adjust ext4 parameters | For ext4 |

**Examples:**
```bash
# Dry-run check (safe)
sudo fsck -n /dev/sda1
This filesystem will not be modified.
Checking inodes and blocks...

# Automatic repair (dangerous - backup first!)
sudo fsck -y /dev/sda1
# -y answers yes to all prompts

# Check specific ext4 partition
sudo e2fsck -p /dev/sda1
# -p auto-fixes non-serious errors

# Check for bad sectors
sudo badblocks -v /dev/sda1
Testing block 1024...
Testing block 2048...
...
0 bad blocks found

# Show ext4 filesystem info
sudo tune2fs -l /dev/sda1 | head -20

# Set mount count before fsck
sudo tune2fs -c 30 /dev/sda1  # fsck after 30 mounts

# Set time between fsck
sudo tune2fs -i 180d /dev/sda1  # fsck every 180 days
```

**Safety First:**
```bash
# NEVER run fsck on mounted filesystem!
# Always unmount first:
sudo umount /dev/sda1
sudo fsck /dev/sda1

# Or check root at boot:
# Add to /etc/fstab: /dev/sda1 / ext4 defaults 0 1
# Then: sudo shutdown -F now  (force fsck at boot)
```

---

## Section 7: Logical Volume Management (LVM)

### Physical Volume (PV) Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `pvcreate` | Initialize disk for LVM | `sudo pvcreate /dev/sdb1` |
| `pvdisplay` | Show physical volumes | `sudo pvdisplay` |
| `pvs` | Short physical volume info | `sudo pvs` |
| `pvremove` | Remove physical volume | `sudo pvremove /dev/sdb1` |

### Volume Group (VG) Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `vgcreate` | Create volume group | `sudo vgcreate vg0 /dev/sdb1` |
| `vgdisplay` | Show volume groups | `sudo vgdisplay` |
| `vgs` | Short volume group info | `sudo vgs` |
| `vgextend` | Add disk to volume group | `sudo vgextend vg0 /dev/sdc1` |
| `vgreduce` | Remove disk from VG | `sudo vgreduce vg0 /dev/sdc1` |
| `vgremove` | Delete volume group | `sudo vgremove vg0` |

### Logical Volume (LV) Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `lvcreate` | Create logical volume | `sudo lvcreate -L 50G -n root vg0` |
| `lvdisplay` | Show logical volumes | `sudo lvdisplay` |
| `lvs` | Short LV info | `sudo lvs` |
| `lvextend` | Grow logical volume | `sudo lvextend -L +10G vg0/root` |
| `lvreduce` | Shrink logical volume | `sudo lvreduce -L -10G vg0/root` |
| `lvremove` | Delete logical volume | `sudo lvremove vg0/root` |
| `lvrename` | Rename logical volume | `sudo lvrename vg0 root root_new` |

**Complete LVM Workflow Example:**
```bash
# 1. Create physical volumes
sudo pvcreate /dev/sdb1
sudo pvcreate /dev/sdc1

# 2. Create volume group
sudo vgcreate vg0 /dev/sdb1 /dev/sdc1

# 3. Show VG capacity
sudo vgs
VG   #PV #LV #SN Attr   VSize  VFree
vg0    2   0   0 wz--n- 99.99g 99.99g

# 4. Create logical volumes
sudo lvcreate -L 50G -n root vg0
sudo lvcreate -L 30G -n home vg0
sudo lvcreate -L 19.99g -n backup vg0

# 5. Create filesystems
sudo mkfs.ext4 /dev/vg0/root
sudo mkfs.ext4 /dev/vg0/home
sudo mkfs.ext4 /dev/vg0/backup

# 6. Mount
sudo mount /dev/vg0/root /mnt/root
sudo mount /dev/vg0/home /mnt/home
sudo mount /dev/vg0/backup /mnt/backup

# 7. Grow logical volume
sudo lvextend -L +10G /dev/vg0/root

# 8. Grow filesystem (must do after lvextend)
sudo resize2fs /dev/vg0/root  # for ext4
# or: sudo xfs_growfs /mnt/root  # for XFS
```

---

## Section 8: fstab Management

### Edit and Verify /etc/fstab

| Command | Purpose |
|---------|---------|
| `cat /etc/fstab` | Show current fstab |
| `sudo nano /etc/fstab` | Edit fstab |
| `sudo mount -a` | Test fstab entries |
| `sudo findmnt` | Show all mounted filesystems |
| `blkid` | Get UUID for devices |

**Example /etc/fstab Entry:**
```bash
# Add to /etc/fstab:
/dev/sda1           /boot    ext4    defaults        0    2
/dev/sda2           /        ext4    defaults        0    1
/dev/mapper/vg0-lv_home   /home    ext4    defaults        0    2
UUID=abc-123-def   /data    xfs     defaults        0    2
LABEL=USB_DRIVE    /media/usb  vfat  defaults,user   0    0
192.168.1.10:/export   /nfs   nfs     defaults        0    0

# Test before rebooting
sudo mount -a

# Verify
mount | grep /home
/dev/mapper/vg0-lv_home on /home type ext4 (rw,relatime)
```

---

## Section 9: RAID Management (mdadm)

### Create and Manage RAID

| Command | Purpose |
|---------|---------|
| `mdadm --create` | Create RAID array |
| `mdadm --detail` | Show RAID details |
| `mdadm --stop` | Stop RAID array |
| `mdadm --assemble` | Assemble RAID array |
| `mdadm --add` | Add disk to array |
| `cat /proc/mdstat` | Show RAID status |
| `mdadm --manage --set-faulty` | Mark disk as failed |
| `mdadm --manage --remove` | Remove disk from array |

**RAID 1 Example (Mirror):**
```bash
# Create RAID 1 (mirror)
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
mdadm: Defaulting to version 1.2 metadata and 64 sectors chunk
Continue creating array? y
mdadm: array /dev/md0 started.

# Check status
sudo mdadm --detail /dev/md0
cat /proc/mdstat
md0 : active raid1 sdc1[1] sdb1[0]
      1048512 blocks super 1.2 [2/2] [UU]

# Create filesystem on RAID
sudo mkfs.ext4 /dev/md0

# Mount
sudo mount /dev/md0 /mnt/raid

# Simulate disk failure
sudo mdadm /dev/md0 --manage --set-faulty /dev/sdb1

# Replace failed disk
sudo mdadm /dev/md0 --manage --remove /dev/sdb1
sudo mdadm /dev/md0 --manage --add /dev/sdd1
# Watch rebuild: watch cat /proc/mdstat
```

---

## Section 10: Disk Quotas

### User and Group Quotas

| Command | Purpose |
|---------|---------|
| `quotaon` | Enable quotas |
| `quotaoff` | Disable quotas |
| `edquota -u user` | Edit user quota |
| `edquota -g group` | Edit group quota |
| `quota user` | Show user quota |
| `quotastat` | Show quota status |
| `repquota -u /dev/sda1` | Report all user quotas |
| `repquota -g /dev/sda1` | Report all group quotas |

**Quota Setup:**
```bash
# 1. Install tools
sudo apt install quota quotatool

# 2. Enable quotas in /etc/fstab
# Add usrquota,grpquota to mount options
# Example: /dev/sda1 / ext4 usrquota,grpquota 0 1

# 3. Remount filesystem
sudo mount -o remount /

# 4. Initialize quota database
sudo quotacheck -cugm /

# 5. Turn on quotas
sudo quotaon -u -g /

# 6. Set quota for user
sudo edquota -u username
# Edit soft and hard limits (in vi editor)

# 7. Check user quota
quota -u username
Disk quotas for user 'user' (uid 1000):
     Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
      /dev/sda1  204800* 204800  250000   6days       5       -       -

# 8. View all quotas
sudo repquota -u /
```

---

## Section 11: Storage Information and Monitoring

### Disk and Storage Info

| Command | Purpose |
|---------|---------|
| `hdparm -i /dev/sda` | Show disk info |
| `smartctl -a /dev/sda` | Show SMART status (requires smartmontools) |
| `iotop` | Show I/O by process |
| `iostat` | Show I/O statistics |
| `sar -d` | Show disk I/O history |
| `lsof` | Show open files and sockets |

**Examples:**
```bash
# Disk information
sudo hdparm -i /dev/sda | grep Model
Model=VBOX HARDDISK

# Check SMART status (requires smartctl)
sudo smartctl -a /dev/sda | grep "Health Status"
SMART Health Status: OK

# Monitor I/O by process (interactive)
sudo iotop

# Show disk I/O statistics
iostat -x 1 5
Device     r/s     w/s     rMB/s   wMB/s
sda       12.3   34.5      0.5      1.2

# Show processes with open files
sudo lsof | grep /dev/sda | head

# Find what's using disk
sudo iotop -b -n 1 | head -20
```

---

## Section 12: Filesystem-Specific Tools

### Ext4 Tools

```bash
# Show ext4 filesystem info
sudo tune2fs -l /dev/sda1

# Enable features
sudo tune2fs -O extent /dev/sda1

# Set journal size
sudo tune2fs -J size=128 /dev/sda1

# Resize ext4 filesystem
sudo resize2fs /dev/sda1 100G  # Shrink to 100G
sudo resize2fs /dev/sda1       # Grow to fill device
```

### XFS Tools

```bash
# Show XFS filesystem info
sudo xfs_info /dev/sda1

# Grow XFS filesystem (must be mounted)
sudo xfs_growfs /mnt/data

# Check XFS (offline)
sudo xfs_repair /dev/sda1

# Defragment XFS
sudo xfs_fsr /dev/sda1
```

### Btrfs Tools

```bash
# Show Btrfs filesystem info
sudo btrfs filesystem show

# Check Btrfs
sudo btrfs check /dev/sda1

# Defragment
sudo btrfs filesystem defragment /mnt/data

# Create snapshot
sudo btrfs subvolume snapshot /mnt/data /mnt/data-backup

# List snapshots
sudo btrfs subvolume list /mnt/data
```

---

## Section 13: Partition Type and Label Reference

### Common Partition Types (fdisk hex codes)

| Code | Type | Use |
|------|------|-----|
| 83 | Linux | Standard Linux partition |
| 82 | Linux swap | Swap memory |
| 8e | LVM | Logical Volume Manager |
| fd | RAID auto | Software RAID |
| 7 | HPFS/NTFS | Windows NTFS |
| b | W95 FAT32 | Windows FAT32 |

### Filesystem Types for Mount

| Type | Name | Use |
|------|------|-----|
| ext4 | Fourth Extended | Linux default |
| xfs | XFS | High performance |
| btrfs | B-tree FS | Modern features |
| vfat | FAT32 | USB drives, Windows |
| ntfs | NTFS | Windows disks |
| exfat | ExFAT | Large USB drives |
| nfs | NFS | Network shares |
| iso9660 | ISO | CD/DVD images |

---

## Section 14: Quick Command Examples

**Common Tasks:**

```bash
# Get disk usage overview
df -h /

# Find large files
find / -type f -size +1G 2>/dev/null

# Check inodes
df -i /

# Mount ISO
sudo mount -o loop image.iso /mnt/iso

# Partition disk with fdisk
sudo fdisk /dev/sdb
# Command: n (new), p (primary), 1 (number), default start, +10G (size), w (write)

# Format USB drive
sudo mkfs.vfat /dev/sdb1

# Mount USB
sudo mount /dev/sdb1 /mnt/usb

# Eject USB safely
sudo umount /mnt/usb

# Check filesystem type
lsblk -f

# Show mount options
mount | grep /dev/sda1

# Change mount options (remount)
sudo mount -o remount,noatime /

# Check LVM setup
sudo pvs && sudo vgs && sudo lvs

# Monitor disk performance
iostat -x 1

# Find files by size
find . -type f -size -1M  # Less than 1MB
find . -type f -size +100M  # More than 100MB
```

---

## Summary

Essential commands by frequency:

**Daily Use:**
- `df -h` - Check space
- `du -sh` - Directory size
- `mount` - Check mounts
- `lsblk` - List disks

**Maintenance:**
- `fsck` - Check filesystem
- `mount -a` - Mount from fstab
- `smartctl` - Check disk health

**Advanced:**
- `lvcreate` - Create LVM volumes
- `mdadm` - RAID management
- `edquota` - Set quotas

Keep this reference handy while working with storage and filesystems!
