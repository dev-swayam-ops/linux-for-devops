# Storage and Filesystems - Theory

## 1. Disk Architecture

### Physical Disk Layout

Modern hard drives and SSDs are organized into logical structures:

```
Physical Disk (e.g., /dev/sda)
│
├─ Partition Table (MBR or GPT)
│  └─ Metadata about disk layout
│
├─ Partition 1 (/dev/sda1)
│  ├─ Boot flag (optional, for bootloader)
│  ├─ Type identifier (Linux, Windows, etc.)
│  └─ Size information
│
├─ Partition 2 (/dev/sda2)
│  └─ Contains filesystem
│
└─ Free space
   └─ Unallocated disk space
```

### MBR vs GPT

**MBR (Master Boot Record)**
- Traditional partitioning scheme
- Maximum 4 primary partitions
- Limited to 2TB disk size
- Used on older systems
- Bootstrap code in first 512 bytes

**GPT (GUID Partition Table)**
- Modern standard (UEFI)
- Unlimited partitions
- Supports drives >2TB
- Better reliability (backup copy)
- Required for UEFI boot
- Uses 8 bytes per partition entry

### Sectors and Blocks

```
Physical Disk Sector Layout:
┌─────────────────────────────────────┐
│ Sector 0: MBR/GPT Header           │ 512 bytes
├─────────────────────────────────────┤
│ Sectors 1-N: Available for data    │
├─────────────────────────────────────┤
│ Each sector = 512 bytes (traditional)
│ Or 4096 bytes (modern, 4K alignment)
└─────────────────────────────────────┘

Filesystem Block Layout:
┌─────────────────────────────────────┐
│ Block 0: Superblock (filesystem meta)
├─────────────────────────────────────┤
│ Block 1+: Inode table              │
├─────────────────────────────────────┤
│ Remaining: Data blocks             │
├─────────────────────────────────────┤
│ Each block = 1KB, 2KB, or 4KB      │
└─────────────────────────────────────┘
```

### Inode Structure

Inodes store metadata about files:

```
Inode Structure (128 bytes in ext4)
┌──────────────────────────────────────┐
│ Permissions (12 bits)                │ Owner permissions
├──────────────────────────────────────┤
│ Owner (UID - 16 bits)                │ File owner ID
├──────────────────────────────────────┤
│ Group (GID - 16 bits)                │ Group ID
├──────────────────────────────────────┤
│ Size (32-48 bits)                    │ File size in bytes
├──────────────────────────────────────┤
│ Timestamps (atime, mtime, ctime)     │ Access/modify/change times
├──────────────────────────────────────┤
│ Link count                           │ Hard links to this inode
├──────────────────────────────────────┤
│ Block pointers (12+3 indirect)       │ Data block locations
└──────────────────────────────────────┘

File = Inode + Data blocks
```

### Free Space Management

```
Bitmap-based allocation (common):
Available blocks: [X X X - - X - X]
                   1 1 1 0 0 1 0 1
                   ^ ^ ^   ^ ^ ^
                   Used blocks, - = free
```

---

## 2. Filesystem Types

### Ext4 (Fourth Extended Filesystem)

**Default on most distributions**

```
Ext4 Features:
├─ Journaling: Prevents corruption on unclean shutdown
│  └─ Journal modes: journal, ordered, writeback
├─ Extents: Allocates contiguous blocks (better fragmentation)
├─ Delayed allocation: Optimizes block placement
├─ Checksums: Verifies journal integrity
├─ Supports files up to 16TB
├─ Supports filesystems up to 1EB
├─ Backward compatible with ext3 and ext2
└─ Best for: General-purpose, default choice

Performance: Good across all scenarios
```

**When to use ext4:**
- Default choice for most systems
- Good all-around performance
- Mature and stable
- Excellent journal reliability

### XFS (eXtended File System)

**High-performance filesystem from SGI**

```
XFS Features:
├─ Delayed allocation: Groups small writes for efficiency
├─ B+tree indexing: Fast lookups and scalability
├─ Allocation groups: Parallelism for multiple writers
├─ Copy-on-write metadata: Atomicity
├─ Supports files up to 8EB
├─ Supports filesystems up to 8EB
├─ Native quota support
├─ Defragmentation tool (xfs_fsr)
└─ Best for: High-concurrency, large files, databases

Performance: Excellent for server workloads
```

**When to use XFS:**
- High-performance requirements
- Large files (databases, video)
- Multi-threaded workloads
- Default on RHEL/CentOS

### Btrfs (B-tree filesystem)

**Next-generation filesystem**

```
Btrfs Features:
├─ Copy-on-write: Efficient snapshots
├─ Subvolumes: Virtual filesystems within filesystem
├─ Snapshots: Point-in-time copies
├─ Compression: Transparent compression (zstd, lz4)
├─ RAID support: Software RAID built-in
├─ Self-healing: Detects and repairs corruption
├─ Supports files up to 16EB
├─ Supports filesystems up to 16EB
└─ Best for: Advanced features, snapshots, dynamic allocation

Performance: Good, improving with new kernels
```

**When to use Btrfs:**
- Need snapshots for backups
- Want compression
- Advanced features needed
- Container and VM storage

### Comparison

| Feature | Ext4 | XFS | Btrfs |
|---------|------|-----|-------|
| Default | ✓ | ✗ | ✗ |
| Performance | Good | Excellent | Good |
| Scalability | 1EB max | 8EB max | 16EB max |
| Snapshots | ✗ | ✗ | ✓ |
| Compression | ✗ | ✗ | ✓ |
| Deduplication | ✗ | ✗ | ✓ |
| Raid support | ✗ | ✗ | ✓ |
| Stability | Mature | Mature | Modern |
| Use case | General | Enterprise | Advanced |

---

## 3. Mounting and Filesystem Hierarchy

### Mount Points

Mounting attaches a filesystem to the directory tree:

```
Before mount:
/mnt/data → empty directory

After mount of /dev/sdb1:
/mnt/data → contents of /dev/sdb1
└─ file1.txt
└─ dir/
   └─ file2.txt

Device /dev/sdb1 is now accessed via /mnt/data
```

### Standard Mount Points

```
/ (root)              - Base of filesystem tree
├─ /home              - User home directories
├─ /root              - Root user home
├─ /tmp               - Temporary files (volatile)
├─ /var               - Variable data (logs, mail, cache)
│  ├─ /var/log        - System logs
│  ├─ /var/spool      - Print jobs, mail
│  └─ /var/cache      - Package cache
├─ /opt               - Optional software
├─ /usr               - User programs, libraries
│  ├─ /usr/bin        - User binaries
│  ├─ /usr/local      - Local additions
│  └─ /usr/share      - Documentation, icons
├─ /etc               - System configuration
├─ /boot              - Kernel and bootloader
├─ /dev               - Device files
├─ /proc              - Process information
├─ /sys               - System information
└─ /srv               - Service data

Each can be on separate filesystem!
```

### /etc/fstab (Filesystem Table)

Configuration for persistent mounts:

```
Format: device mount_point filesystem options dump pass

Example:
/dev/sda1    /boot              ext4    defaults        0    2
/dev/mapper/vg0-lv_root    /              ext4    defaults        0    1
/dev/mapper/vg0-lv_home    /home          ext4    defaults        0    2
UUID=ABC123  /media/usb        vfat    defaults,user    0    0
192.168.1.10:/export /mnt/nfs nfs     defaults        0    0

Fields:
1. Device: /dev/xxx, UUID=xxx, or LABEL=xxx
2. Mount point: Where to mount
3. Filesystem type: ext4, xfs, nfs, vfat, etc.
4. Options: defaults, ro, noexec, nosuid, etc.
5. Dump: 0=no backup, 1=include in dump
6. Pass: 0=no fsck, 1=fsck first (root), 2=fsck later
```

### Mount Options

```
Common options:
- defaults: rw, suid, dev, exec, auto, nouser, async
- ro: read-only
- rw: read-write
- noexec: no execute
- nosuid: no setuid
- nodev: no devices
- nouser: only root can mount
- async: asynchronous I/O
- sync: synchronous (slower but safer)
- noatime: don't update access time
- relatime: update atime only if older than mtime
- nofail: don't fail boot if mount fails

Example with options:
/dev/sdb1 /data ext4 rw,noatime,nouser 0 2
```

---

## 4. Logical Volume Management (LVM)

### LVM Hierarchy

LVM provides abstraction layer for storage:

```
Physical Disks
├─ /dev/sda     (Physical disk 1)
├─ /dev/sdb     (Physical disk 2)
└─ /dev/sdc     (Physical disk 3)
    │
    ↓
Physical Volumes (PV)
├─ /dev/sda1    (PV1)
├─ /dev/sdb1    (PV2)
└─ /dev/sdc1    (PV3)
    │
    ↓
Volume Groups (VG)
├─ vg0           ← Created from PV1, PV2, PV3
    │            (Total: 1TB + 2TB + 3TB = 6TB pool)
    │
    ↓
Logical Volumes (LV)
├─ lv_root       (50GB)
├─ lv_home       (100GB)
├─ lv_data       (200GB)
└─ lv_backup     (500GB)
    │
    ↓
Filesystems
├─ ext4 on lv_root
├─ ext4 on lv_home
├─ xfs on lv_data
└─ xfs on lv_backup

Benefits:
- Grow/shrink volumes without unmounting
- Stripe data across disks for performance
- Snapshot capabilities
- Move data between physical disks
```

### LVM Workflow

```
Create LVM:
1. pvcreate /dev/sdb1      → Initialize physical volume
2. vgcreate vg0 /dev/sdb1  → Create volume group
3. lvcreate -L 50G -n root vg0  → Create logical volume
4. mkfs.ext4 /dev/vg0/root → Create filesystem
5. mount /dev/vg0/root /   → Mount filesystem

Expand LVM:
1. pvcreate /dev/sdc1                    → Add disk
2. vgextend vg0 /dev/sdc1                → Extend VG
3. lvextend -L +50G /dev/vg0/root        → Extend LV
4. resize2fs /dev/vg0/root (ext4)        → Resize filesystem
   or xfs_growfs /mnt/root (XFS)
```

---

## 5. RAID (Redundant Array of Independent Disks)

### RAID Levels

**RAID 0 - Striping**
```
Data striped across 2+ disks
Disk 1: [Block 1] [Block 3] [Block 5]
Disk 2: [Block 2] [Block 4] [Block 6]

Pros: High speed, full capacity
Cons: No redundancy (one failure = total loss)
Use: Temporary caches, non-critical data
```

**RAID 1 - Mirroring**
```
Data mirrored on 2+ disks
Disk 1: [Block 1] [Block 2] [Block 3]
Disk 2: [Block 1] [Block 2] [Block 3]

Pros: Full redundancy, fast reads
Cons: 50% capacity loss, slower writes
Use: System drives, databases
```

**RAID 5 - Striping with Parity**
```
3 disks store 2 blocks + parity
Disk 1: [Block A]  [Block C]  [Parity B+C]
Disk 2: [Block B]  [Parity A] [Block D]
Disk 3: [Parity A+B] [Block D] [Block E]

Pros: Good speed, redundancy, efficient space
Cons: Complex rebuild, slow rebuild, slower writes
Use: General-purpose storage
```

**RAID 6 - Dual Parity**
```
Like RAID 5 but with 2 parity blocks
Survives 2 disk failures

Pros: High reliability, fast reads
Cons: Complex, slower writes
Use: Large drive arrays, critical data
```

**RAID 10 - Mirrored Striping**
```
Combination of RAID 1 + RAID 0
Disk 1 ↔ Disk 2 (mirror pair 1)
Disk 3 ↔ Disk 4 (mirror pair 2)
Data striped across pairs

Pros: High performance and reliability
Cons: 50% capacity, more complex
Use: High-performance databases
```

---

## 6. Disk Quotas

### Quota System

Limits per-user or per-group disk usage:

```
User Quotas:
├─ Soft limit: Warning threshold (grace period)
├─ Hard limit: Cannot exceed (enforced)
└─ Grace period: Time to reduce usage

Example:
- user1: 100GB soft, 120GB hard, 7-day grace
  When exceeds 100GB: warning
  If still exceeds after 7 days: blocks at 120GB

Commands:
edquota -u username     → Edit user quota
edquota -g groupname    → Edit group quota
quota username          → Check quota usage
quotaon /dev/sda1       → Enable quotas
repquota /dev/sda1      → Report all quotas
```

---

## 7. Filesystem Checking and Repair

### Journaling

Journaling prevents corruption from unclean shutdowns:

```
Write sequence:
1. Journal: "About to write block 100"
2. Disk: Write block 100
3. Journal: "Confirmed write of block 100"

If crash after step 1 or 2:
- Journal exists but not confirmed
- Replay: Just redo the operation (idempotent)

If no crash:
- Journal: Erase confirmation

Result: Filesystem always consistent
```

### fsck (Filesystem Check)

```
Phases:
1. Inode scan: Check inodes for validity
2. Inode allocation: Verify allocation bitmaps
3. Inode links: Check link counts
4. Directory structure: Verify parent pointers
5. Cylinder groups: Check filesystem groups

When needed:
- Unclean shutdown (power failure)
- Boot with read-only root
- Explicit fsck command
- Device errors detected

Safety:
- Never run on mounted filesystem!
- Run on read-only or after unmount
- Always backup first
```

---

## 8. Disk Performance

### Key Metrics

```
Throughput: MB/s of data transfer
├─ Sequential: 100-300 MB/s (HDDs), 500+ MB/s (SSDs)
└─ Random: 1-20 MB/s (HDDs), 100+ MB/s (SSDs)

IOPS: Input/Output operations per second
├─ Sequential: 100-200 IOPS (HDDs)
└─ Random: 500-5000 IOPS (SSDs)

Latency: Time per operation
├─ HDDs: 5-20ms average seek
└─ SSDs: 0.1-1ms

Write patterns:
├─ Sequential: Fast (optimized by disk)
└─ Random: Slow (lots of seeking)
```

### Optimization Strategies

1. **Filesystem choice**
   - XFS for large databases (better concurrency)
   - Ext4 for general purpose
   - Btrfs for snapshots

2. **Mount options**
   - noatime: Skip access time updates
   - relatime: Update atime less frequently
   - Use sync only when necessary

3. **I/O scheduler**
   - noop: For SSDs (no optimization needed)
   - deadline: Best general-purpose
   - cfq: Fair scheduling for mixed workloads

4. **Disk cache settings**
   - Write cache: Faster but risky (enable with battery backup)
   - Read-ahead: Pre-load data
   - Block size: Larger blocks for sequential, smaller for random

---

## 9. Common Filesystem Issues

### Inode Exhaustion

```
Problem: "No space left on device" but df shows free space

Cause: All inodes used up
├─ Millions of small files
├─ Temporary files accumulating
└─ Log files not rotated

Solution:
1. Find the culprit: find / -type f | wc -l
2. Remove small/old files: find /tmp -atime +7 -delete
3. Increase inode count: Requires reformatting
```

### Fragmentation

```
Problem: Performance degradation over time

Modern Ext4 & XFS: Less of a problem (delayed allocation)
Btrfs: Built-in defragmentation

Btrfs defrag:
btrfs filesystem defragment /mnt/data

XFS defrag:
xfs_fsr /mnt/data (online, slower)
```

### Corruption

```
Cause: Power failure, hardware failure, kernel bug

Recovery:
1. Unmount filesystem
2. Run fsck: fsck.ext4 -p /dev/sda1
3. Restore from backup

Prevention:
- Use journaling filesystem
- Use UPS for power stability
- Monitor SMART errors
```

---

## 10. Storage Terminology

### Storage Capacity

```
Traditional (1000-based):
1 KB = 1,000 bytes
1 MB = 1,000 KB = 1,000,000 bytes
1 GB = 1,000 MB = 1,000,000,000 bytes
1 TB = 1,000 GB = 1,000,000,000,000 bytes

Binary (1024-based):
1 KiB = 1,024 bytes
1 MiB = 1,024 KiB = 1,048,576 bytes
1 GiB = 1,024 MiB = 1,073,741,824 bytes
1 TiB = 1,024 GiB = 1,099,511,627,776 bytes

Modern OSes use 1000-based
Storage capacity uses 1000-based
RAM uses 1024-based
```

### Access Patterns

```
Sequential: File read from start to end
├─ CAN benefit from caching/readahead
├─ FAST on all storage
└─ Example: Video streaming

Random: Scattered block access
├─ Cannot optimize easily
├─ SLOW on HDDs (seeking)
├─ Acceptable on SSDs
└─ Example: Database queries
```

---

## Summary

Key takeaways:

1. **Partitions** organize physical disks
2. **Filesystems** organize data on partitions (choose ext4 by default)
3. **Mounting** attaches filesystems to directory tree
4. **LVM** provides abstraction for flexible allocation
5. **RAID** provides redundancy or performance
6. **Journaling** prevents corruption
7. **Monitoring** catches problems early
8. **Performance** depends on workload and configuration

Understanding these concepts allows you to:
- Design scalable storage infrastructure
- Troubleshoot disk-related issues
- Optimize performance for your workload
- Recover from failures safely
- Make informed hardware choices

Continue to [02-commands-cheatsheet.md](02-commands-cheatsheet.md) for practical command reference.
