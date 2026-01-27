# Storage and Filesystems: Cheatsheet

## Disk and Partition Tools

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo fdisk -l` | List partitions | `sudo fdisk -l \| head` |
| `lsblk` | Block devices tree | `lsblk -a` |
| `lsblk -b` | Sizes in bytes | `lsblk -b` |
| `sudo parted -l` | Partition layout | `sudo parted -l` |
| `sudo gdisk /dev/sda` | GPT partitions | `sudo gdisk /dev/sda` |

## Create and Format

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo fdisk /dev/sdb` | Create partitions | Interactive tool |
| `sudo mkfs.ext4 /dev/sdb1` | Format ext4 | `sudo mkfs.ext4 -L data /dev/sdb1` |
| `sudo mkfs.xfs /dev/sdb1` | Format XFS | `sudo mkfs.xfs /dev/sdb1` |
| `sudo mkfs.btrfs /dev/sdb1` | Format Btrfs | `sudo mkfs.btrfs /dev/sdb1` |
| `sudo mkswap /dev/sdb2` | Create swap | `sudo mkswap /dev/sdb2` |

## Filesystem Information

| Command | Purpose | Example |
|---------|---------|---------|
| `df -h` | Disk usage | `df -h` |
| `df -T` | With filesystem type | `df -T` |
| `df -i` | Inode usage | `df -i` |
| `du -sh path` | Directory size | `du -sh /home` |
| `du -h --max-depth=2` | Tree view | `du -h --max-depth=2 /` |
| `sudo tune2fs -l device` | Ext4 info | `sudo tune2fs -l /dev/sdb1` |
| `sudo xfs_info mount` | XFS info | `sudo xfs_info /mnt` |

## Mount Operations

| Command | Purpose | Example |
|---------|---------|---------|
| `mount` | Show mounts | `mount` |
| `mount \| grep sdb` | Find specific | Filter by device |
| `sudo mount device path` | Mount | `sudo mount /dev/sdb1 /mnt/data` |
| `sudo mount -o options device path` | With options | `sudo mount -o noatime /dev/sdb1 /mnt` |
| `sudo umount path` | Unmount | `sudo umount /mnt/data` |
| `sudo umount -l path` | Lazy unmount | Force unmount if busy |
| `sudo mount -a` | Mount from fstab | Test fstab entries |

## Mount Options

| Option | Purpose | Example |
|--------|---------|---------|
| `defaults` | Standard options | `defaults` |
| `ro` | Read-only | `ro` |
| `rw` | Read-write | `rw` |
| `noatime` | Skip atime updates | Performance boost |
| `relatime` | Relative atime | Balanced |
| `noexec` | No execute | Security |
| `nosuid` | No setuid | Security |
| `nodev` | No devices | Security |
| `errors=remount-ro` | Remount read-only on error | Safety |

## /etc/fstab

| Field | Purpose | Example |
|-------|---------|---------|
| Device | Partition identifier | `/dev/sdb1` or `UUID=...` |
| Mount | Directory | `/mnt/data` |
| Filesystem | Type | `ext4`, `xfs`, `btrfs` |
| Options | Mount flags | `defaults,noatime` |
| Dump | Backup (0/1) | `0` |
| Pass | Check order (0/1/2) | `2` |

## UUIDs and Labels

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo blkid` | Show all UUIDs | `sudo blkid` |
| `sudo blkid -s UUID -o value /dev/sdb1` | Get UUID | Extract for fstab |
| `sudo e2label /dev/sdb1` | Show ext4 label | `sudo e2label /dev/sdb1` |
| `sudo e2label /dev/sdb1 "data"` | Set ext4 label | Set label |
| `sudo xfs_admin -L label /dev/sdb1` | Set XFS label | `sudo xfs_admin -L data` |

## Filesystem Check and Repair

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo fsck -n device` | Check only | `sudo fsck -n /dev/sdb1` |
| `sudo fsck -y device` | Check and repair | `sudo fsck -y /dev/sdb1` |
| `sudo e2fsck -f device` | Force ext4 check | `sudo e2fsck -f /dev/sdb1` |
| `sudo fsck.xfs device` | XFS check | `sudo fsck.xfs /dev/sdb1` |
| `dmesg \| grep -i error` | Check logs | Find filesystem errors |

## Disk Health (SMART)

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo smartctl -a device` | Show SMART status | `sudo smartctl -a /dev/sda` |
| `sudo smartctl -t short device` | Run short test | Quick health check |
| `sudo smartctl -t long device` | Run long test | Full disk scan |
| `sudo smartctl -H device` | Health summary | `sudo smartctl -H /dev/sda` |

## Quotas

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo mount -o usrquota /dev/sdb1 /mnt` | Enable quota | Add to mount |
| `sudo quotacheck -c /mnt` | Initialize quota | Create db |
| `sudo quotaon /mnt` | Turn on quotas | Enable |
| `sudo edquota -u user` | Set user quota | Edit limits |
| `sudo quota -u user` | Show user quota | View limits |
| `sudo repquota /mnt` | Generate report | All users |

## Swap Management

| Command | Purpose | Example |
|---------|---------|---------|
| `free -h` | Show swap usage | `free -h` |
| `sudo mkswap /dev/sdb2` | Create swap | `sudo mkswap /dev/sdb2` |
| `sudo swapon /dev/sdb2` | Activate swap | `sudo swapon /dev/sdb2` |
| `sudo swapoff /dev/sdb2` | Deactivate swap | `sudo swapoff /dev/sdb2` |
| `swapon -s` | List swap | Show all swaps |

## Filesystem Sizes

| Filesystem | Max File | Max Volume | Notes |
|------------|----------|------------|-------|
| ext4 | 16TB | 1EB | Standard Linux |
| XFS | 8EB | 8EB | Large files |
| Btrfs | 16EB | 16EB | Modern features |
| NTFS | 16EB | 8PB | Windows compatible |

## Common Tasks

| Task | Command |
|------|---------|
| Find large files | `find / -type f -size +100M` |
| Disk usage by dir | `du -sh /* \| sort -h` |
| Monitor growth | `watch -n 1 'df -h'` |
| Check I/O | `iostat -x 1 5` |
| Filesystem type | `df -T` |
| Mount options | `mount \| grep device` |
| Inodes available | `df -i` |
| Add to fstab | Use UUID for safety |
