# Module 15: Storage and Filesystems

## Overview

Storage and filesystem management is critical for Linux administrators and DevOps engineers. Understanding how to partition drives, manage filesystems, monitor disk usage, and optimize storage performance is essential for:

- **Server maintenance**: Ensuring systems don't run out of disk space
- **Data integrity**: Preventing filesystem corruption and data loss
- **Performance optimization**: Choosing right filesystem types and configurations
- **Scalability**: Managing storage growth across infrastructure
- **DevOps operations**: Provisioning storage for containers and VMs
- **Troubleshooting**: Diagnosing disk-related performance issues

In this module, you'll learn:
- How disks are partitioned and managed
- Filesystem types and their trade-offs
- Mounting and unmounting filesystems
- Advanced storage with LVM (Logical Volume Management)
- RAID configurations for redundancy
- Disk monitoring and quota management
- Filesystem repair and maintenance
- Storage performance tuning

---

## Prerequisites

Before starting, you should have:

- **Module 01**: Linux basics (navigation, file operations)
- **Module 02**: Linux commands (filtering, searching)
- **Module 06**: System services and daemons basics
- **Basic understanding** of disk partitions (MBR vs GPT)
- **Sudo access** for performing disk operations
- **Test VM or non-production system** (labs involve disk operations)

---

## Learning Objectives

By completing this module, you will be able to:

1. **Understand disk architecture** - Partitions, sectors, inodes, and block allocation
2. **Work with filesystem types** - Understand ext4, XFS, Btrfs, and choose appropriate type
3. **Manage partitions** - Create, modify, and delete partitions safely
4. **Mount filesystems** - Mount/unmount and configure permanent mounts via /etc/fstab
5. **Monitor disk usage** - Track space consumption and identify bottlenecks
6. **Implement LVM** - Create logical volumes for flexible storage allocation
7. **Configure RAID** - Set up RAID arrays for redundancy and performance
8. **Manage quotas** - Implement disk quotas for users and projects
9. **Repair filesystems** - Recover from filesystem errors and corruption
10. **Optimize storage** - Improve performance and reduce storage consumption
11. **Troubleshoot issues** - Diagnose and fix disk-related problems
12. **Automate monitoring** - Set up automated disk usage alerts

---

## Module Roadmap

### 1. **01-theory.md** - Foundation Concepts (90 minutes)
Learn how storage works under the hood:
- Disk architecture and partitioning schemes
- Filesystem types and comparison
- Inode structure and block allocation
- Mounting mechanisms
- LVM architecture
- RAID levels and configurations

### 2. **02-commands-cheatsheet.md** - Command Reference (30 minutes)
Quick lookup for 80+ storage commands:
- Partition management (fdisk, parted, gdisk)
- Filesystem operations (mkfs, mount, umount)
- Disk usage analysis (df, du, ncdu)
- LVM commands (lvcreate, pvdisplay, vgextend)
- RAID management (mdadm)
- Filesystem repair (fsck, e2fsck)

### 3. **03-hands-on-labs.md** - Practical Exercises (3-4 hours)
Execute 8 complete labs:
- **Lab 1**: Explore disk architecture (30 min)
- **Lab 2**: Create and mount filesystems (40 min)
- **Lab 3**: Manage /etc/fstab for persistent mounting (35 min)
- **Lab 4**: Analyze disk usage and find space hogs (40 min)
- **Lab 5**: Set up LVM for flexible storage (50 min)
- **Lab 6**: Configure RAID for redundancy (45 min)
- **Lab 7**: Implement disk quotas (40 min)
- **Lab 8**: Repair and recover filesystems (45 min)

### 4. **scripts/** - Automation Tools (reference)
Production-ready scripts for common tasks:
- **disk-monitor.sh** - Real-time disk usage monitoring with alerts
- **filesystem-analyzer.sh** - Detailed filesystem analysis and reporting
- **storage-report.sh** - Generate storage utilization reports
- **lvm-helper.sh** - LVM operations and management

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Partition** | Logical division of a physical disk into separate sections |
| **Filesystem** | Structure organizing how data is stored, organized, and retrieved |
| **Mount point** | Directory where a filesystem is attached to the directory tree |
| **Inode** | Data structure storing metadata (permissions, size, ownership) for files |
| **Block** | Smallest unit of data allocation on a filesystem (typically 4KB) |
| **Extent** | Contiguous block of data on disk (ext4 optimization) |
| **LVM** | Logical Volume Manager - abstraction layer allowing flexible storage allocation |
| **Physical Volume (PV)** | Partition or disk used as component of LVM |
| **Volume Group (VG)** | Collection of physical volumes managed as single unit |
| **Logical Volume (LV)** | Virtual partition created from volume group |
| **RAID** | Redundant Array of Independent Disks - distributes data for redundancy/speed |
| **Ext4** | Default Linux filesystem on most distributions; journaling for reliability |
| **XFS** | High-performance filesystem excellent for large files and concurrent access |
| **Btrfs** | Modern filesystem with snapshots, compression, and copy-on-write |
| **fstab** | File system table listing filesystems to mount at boot (/etc/fstab) |
| **fsck** | Filesystem check utility for detecting and repairing corruption |
| **df** | Disk free - shows disk space usage by mounted filesystem |
| **du** | Disk usage - shows space used by directories and files |
| **Quota** | Limit on disk space or files allowed per user/group |
| **Swap** | Virtual memory on disk, used when RAM is full |

---

## Time Breakdown

| Section | Time | Activities |
|---------|------|-----------|
| README & Overview | 15 min | Read module structure and objectives |
| 01-theory.md | 90 min | Study concepts, diagrams, and architecture |
| 02-commands-cheatsheet.md | 30 min | Review command reference (reference during labs) |
| 03-hands-on-labs.md | 180 min | Execute all 8 hands-on labs (3 hours) |
| Scripts exploration | 30 min | Review and test provided automation scripts |
| **Total** | **345 min** | **~5.75 hours** |

---

## How to Use This Module

### For Self-Study
1. Read README.md to understand module scope (this file)
2. Study 01-theory.md to build conceptual foundation
3. Keep 02-commands-cheatsheet.md open while working
4. Execute 03-hands-on-labs.md labs step-by-step
5. Review scripts/ for automation patterns

### For Classroom Instruction
1. Present 01-theory.md concepts and diagrams
2. Demonstrate commands from 02-commands-cheatsheet.md
3. Have students execute labs in controlled environment
4. Show practical scripting examples from scripts/

### For Reference
- Use 02-commands-cheatsheet.md as quick lookup
- Return to specific labs for step-by-step examples
- Review scripts/ for production patterns

---

## Lab Safety and Setup

### ⚠️ Important: Lab Environment

**These labs involve disk operations. Use appropriately:**

1. **Test VM Recommended**: Use virtual machine with free disk space
   - VirtualBox, KVM, or cloud instance
   - At least 50GB virtual disk
   - Ubuntu 20.04+ or CentOS 8+ recommended

2. **Non-Production Systems**: Never run on production without testing first
   - Data loss is possible with disk operations
   - Always backup important data

3. **Safe Defaults**: All labs include safety checks
   - Operate on test partitions/volumes
   - Non-destructive where possible
   - Cleanup procedures included

### Recommended Tools

```bash
# System
- Linux VM (VirtualBox, KVM, Hyper-V, or cloud)
- SSH client for remote access
- Terminal (bash 4.0+)

# Analysis
- ncdu (disk space visualization)
- iotop (I/O monitoring)
- hdparm (disk performance)

# Optional
- gparted (graphical partition tool)
- yad (dialog boxes in scripts)
```

### Preparing Your Environment

```bash
# Create test disk (in VM or on secondary disk)
# For virtual disks: use hypervisor tools
# For physical: ensure you have test partition

# Recommended test disk size: 10-20GB
# Ensure you have free space for LVM labs
```

---

## Prerequisites Check

Before starting, verify you have:

```bash
# Check Linux distribution
lsb_release -d

# Check available disks
lsblk

# Check available disk space
df -h

# Check for LVM support
which lvm

# Verify sudo access
sudo -l | grep -q NOPASSWD && echo "Passwordless sudo" || echo "Requires password"
```

---

## Success Criteria

You've mastered this module when you can:

- [ ] Identify and work with different filesystem types appropriately
- [ ] Create, modify, and delete partitions safely
- [ ] Mount/unmount filesystems and configure persistent mounts
- [ ] Analyze disk usage and identify space bottlenecks
- [ ] Set up and manage LVM for flexible storage allocation
- [ ] Configure RAID arrays for redundancy or performance
- [ ] Implement and manage disk quotas
- [ ] Detect and repair filesystem corruption
- [ ] Troubleshoot disk-related performance issues
- [ ] Automate disk monitoring and alert on problems

---

## Quick Start

Want to jump in? Here's the minimal path:

1. **5 minutes**: Skim this README
2. **30 minutes**: Read 01-theory.md (Sections 1-3)
3. **30 minutes**: Run Lab 1 from 03-hands-on-labs.md
4. **30 minutes**: Run Lab 4 (disk usage analysis)
5. **Continue**: Pick labs based on your needs

---

## Next Steps After This Module

Once you master storage and filesystems, you can:

- **Container storage**: Docker volume management and optimization
- **Database storage**: Performance tuning for database workloads
- **Backup strategies**: Snapshot-based backups with LVM
- **Cloud storage**: Object storage (S3) and block storage integration
- **High availability**: Clustered storage with distributed filesystems (Ceph, GlusterFS)

---

## Module Navigation

- 📚 **[Full Theory (01-theory.md)](01-theory.md)** - Comprehensive concept explanations
- 📋 **[Commands Reference (02-commands-cheatsheet.md)](02-commands-cheatsheet.md)** - 80+ commands with examples
- 🧪 **[Hands-On Labs (03-hands-on-labs.md)](03-hands-on-labs.md)** - 8 complete labs with full walkthroughs
- 🛠️ **[Scripts (scripts/)](scripts/)** - Production-ready automation tools

---

## Common Questions

**Q: Can I run these labs on a laptop?**
A: Yes! Use a virtual machine (VirtualBox, VMware) with at least 50GB virtual disk.

**Q: Is RAID necessary to learn?**
A: Not for basic knowledge, but Lab 6 covers it. You can skip if RAID not relevant to your role.

**Q: Can I use these scripts in production?**
A: Yes! They include error handling and logging. Review and customize for your environment.

**Q: How long does this module take?**
A: 5-6 hours if you do all labs. You can skip labs based on your specific needs.

**Q: What if I mess up a partition?**
A: Use a test VM! Data on test filesystems can be recreated. Always backup before lab.

---

## Feedback and Contribution

This module is continuously improved. If you:
- Find errors or unclear explanations
- Have suggestions for new labs
- Want to share production tips
- Find the content useful

Feel free to contribute!

---

**Ready to start? Begin with [01-theory.md](01-theory.md) to build your foundation!**
