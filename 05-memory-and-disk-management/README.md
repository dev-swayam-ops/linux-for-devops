# Module 05: Memory and Disk Management

## 🎯 Overview

Memory and disk management are foundational skills for Linux system administration. Understanding how your system uses RAM, swap, and storage is essential for troubleshooting performance issues, preventing system outages, and making informed capacity planning decisions. This module teaches you to monitor, analyze, and optimize these critical resources.

### Why This Matters

**Real-World Scenarios:**
- **Server Goes Slow**: Is it out of memory? Disk full? I/O bound? You need to know how to check.
- **Applications Crash**: Often due to OOM (Out of Memory) - how do you prevent and diagnose this?
- **Storage Fills Up**: Old logs? Cache? You need to find and clean up without breaking things.
- **Performance Issues**: Is the disk slow? CPU waiting for I/O? You need metrics to investigate.
- **Capacity Planning**: When do you need more RAM or disk? Data-driven decisions required.
- **Cost Optimization**: Right-sizing resources based on actual usage patterns.

**Career Impact:**
- 90% of production incidents involve memory or disk issues
- Essential skill for junior to senior SysAdmin/DevOps roles
- Critical for cloud cost optimization
- Foundation for advanced performance tuning

---

## 📋 Prerequisites

### Required Knowledge
- ✅ Module 01: Linux Basics Commands (file operations, permissions, basic commands)
- ✅ Module 02: Linux Advanced Commands (grep, awk, cut for parsing output)
- ✅ Comfortable with terminal and command-line tools
- ✅ Understanding of filesystems and file paths
- ✅ Basic understanding of processes

### System Requirements
- **OS**: Ubuntu 20.04+ / CentOS 8+ / Debian 10+
- **Tools**: free, top, df, du, iostat, vmstat, lsblk, fdisk, mount, dmesg
- **Environment**: Terminal access (local VM recommended for disk labs)
- **Storage**: 10 GB+ free for hands-on labs
- **Time**: 5-7 hours total (theory + hands-on practice)

### Recommended Setup
```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install sysstat cron util-linux

# For CentOS/RHEL
sudo yum install -y sysstat util-linux
```

---

## 🎓 Learning Objectives

After completing this module, you will be able to:

### Memory Management (Beginner+)
- [ ] Understand RAM, swap, and virtual memory concepts
- [ ] Use `free` command to analyze memory usage
- [ ] Use `top` and `ps` to identify memory-hungry processes
- [ ] Monitor memory in real-time
- [ ] Troubleshoot out-of-memory errors

### Disk Management (Beginner+)
- [ ] View disk partitions and layout with `lsblk`, `fdisk`
- [ ] Check disk usage with `df` and `du`
- [ ] Find large files and directories
- [ ] Identify and clean up disk space issues
- [ ] Monitor disk I/O performance

### Filesystem Operations (Intermediate)
- [ ] Create and mount filesystems
- [ ] Understand mount points and filesystem hierarchy
- [ ] Use `fstab` for persistent mount configuration
- [ ] Check filesystem health with `fsck`
- [ ] Manage filesystem quotas

### Performance Analysis (Intermediate)
- [ ] Monitor I/O activity with `iostat`
- [ ] Track system memory usage with `vmstat`
- [ ] Identify I/O bottlenecks
- [ ] Analyze performance metrics
- [ ] Generate capacity planning reports

### Real-World Scenarios
- [ ] Diagnose why a system is slow
- [ ] Free up disk space when partition fills
- [ ] Prevent out-of-memory crashes
- [ ] Monitor long-term trends
- [ ] Write automation for proactive alerts

---

## 📚 Module Roadmap

This module is organized as follows:

```
05-memory-and-disk-management/
├── README.md                    ← You are here
├── 01-theory.md                 ← Conceptual foundations (40 min)
├── 02-commands-cheatsheet.md    ← Command reference (reference)
├── 03-hands-on-labs.md          ← Practical exercises (3-5 hours)
└── scripts/
    ├── disk-monitor.sh          ← Real-time monitoring
    ├── memory-analyzer.sh        ← Memory usage analysis
    └── README.md                ← Script documentation
```

### How to Use This Module

1. **Start with Theory** (40 minutes)
   - Read [01-theory.md](01-theory.md) to understand concepts
   - Review ASCII diagrams and memory/disk models
   - Understand why each tool exists

2. **Reference While Practicing** (as needed)
   - Keep [02-commands-cheatsheet.md](02-commands-cheatsheet.md) handy
   - Look up command syntax and examples
   - Copy-paste examples to learn

3. **Do the Hands-On Labs** (3-5 hours)
   - Follow [03-hands-on-labs.md](03-hands-on-labs.md) in order
   - Start with monitoring basics, advance to disk management
   - Use provided setup scripts and sample data
   - Verify expected output after each step

4. **Explore the Scripts** (30 minutes)
   - Review [scripts/README.md](scripts/README.md)
   - Run disk-monitor.sh and memory-analyzer.sh
   - Understand how to combine commands into automation

5. **Apply to Your Systems** (ongoing)
   - Use these tools on your own VMs
   - Monitor actual systems (dev, staging, production)
   - Create custom monitoring for your environment

---

## 📖 Quick Glossary

### Memory Terms

| Term | Definition |
|------|-----------|
| **RAM** | Physical memory (fast, volatile) - where programs run |
| **Swap** | Disk used as backup memory (slow, persistent) - used when RAM full |
| **Virtual Memory** | Abstraction of physical RAM + swap - allows overcommitting |
| **RSS** | Resident Set Size - actual RAM used by a process |
| **VSZ** | Virtual Memory Size - total addressable memory for a process |
| **Buffer** | Memory temporarily holding data between devices |
| **Cache** | Memory storing frequently accessed data for fast access |
| **OOM** | Out of Memory - system runs out of RAM+swap |
| **Paging** | Moving data between RAM and swap (slow, causes delays) |
| **Demand Paging** | Kernel moves pages to disk only when needed |
| **Working Set** | Active memory currently needed by processes |
| **Dirty Pages** | Memory data changed but not written to disk yet |

### Disk Terms

| Term | Definition |
|------|-----------|
| **Partition** | Logical division of physical disk |
| **Filesystem** | Organizational structure for storing files (ext4, btrfs, xfs) |
| **Block Device** | Hardware storage interface (usually /dev/sda, /dev/nvme0n1) |
| **Mount Point** | Directory where filesystem is accessible |
| **Inode** | Data structure storing file metadata |
| **Free Space** | Available storage space on filesystem |
| **Used Space** | Storage actually used by files |
| **I/O** | Input/Output operations (reads/writes to disk) |
| **IOPS** | Input/Output Operations Per Second - measure of disk speed |
| **Throughput** | Data transfer rate (MB/s or GB/s) |
| **Latency** | Time to complete one I/O operation |
| **fstab** | File system table - configuration for permanent mounts |
| **LVM** | Logical Volume Manager - abstraction layer for storage |
| **Quota** | Storage limit per user or group |
| **Fsck** | Filesystem check - repair utility |

---

## 🔄 Common Workflows

### Workflow 1: Diagnose Slow System
```bash
# Step 1: Check memory
free -h
top -bn1 | head -20

# Step 2: Check disk
df -h
du -sh /*

# Step 3: Check I/O
iostat -x 1 5
vmstat 1 5

# Interpretation: Which resource is bottleneck?
```

### Workflow 2: Free Up Disk Space
```bash
# Find what's using space
du -sh /* | sort -hr

# Find old files
find /var/log -name "*.log" -mtime +30

# Clean up safely
sudo rm -rf /path/to/old/files
# Or compress: gzip *.log
```

### Workflow 3: Prevent Out of Memory
```bash
# Monitor current usage
free -h

# Identify memory hogs
top -b -o %MEM | head -10

# Set up alerts
# Script: check if free memory < threshold, alert if true
```

### Workflow 4: Capacity Planning
```bash
# Historical data (assuming collectd or similar)
# 1. Track usage over time
# 2. Calculate growth rate
# 3. Project when capacity exceeded
# 4. Plan upgrade before problem occurs
```

### Workflow 5: Analyze Filesystem Issues
```bash
# Check filesystem health
sudo fsck -n /dev/sda1

# Check mount options
mount | grep /dev/sda

# Check limits
df -i  # Inode usage
```

---

## ⏱️ Time Breakdown

| Phase | Duration | Content |
|-------|----------|---------|
| **Theory** | 40 min | Conceptual foundations, diagrams, models |
| **Commands Intro** | 20 min | Overview of each monitoring tool |
| **Lab 1-3** | 60 min | Basic monitoring and exploration |
| **Lab 4-6** | 90 min | Disk analysis and troubleshooting |
| **Lab 7-8** | 90 min | Advanced analysis and automation |
| **Scripts Exploration** | 30 min | Understanding production tools |
| **Practice & Review** | 60 min | Revisit labs, customize for your systems |
| **TOTAL** | **5-7 hours** | Complete mastery |

---

## 🔒 Safety and Best Practices

### Important Rules

🚫 **DO NOT:**
- Delete files without checking what they are first
- Resize partitions without backups
- Run fsck on mounted filesystems
- Fill disk to 100% (leaves no room for system operations)
- Ignore OOM killer events (they're warnings)

✅ **DO:**
- Always backup before modifying partitions
- Use `df` and `du` before cleaning anything
- Check what's consuming space before deleting
- Monitor trends over time for planning
- Set up alerts before crisis happens
- Use `--dry-run` or preview when available
- Create snapshots/LVM snapshots for safety

### Lab Safety

All labs use sandboxed directories and test partitions:
```bash
# Safe sandbox for disk analysis
mkdir -p ~/memory-disk-labs
cd ~/memory-disk-labs

# Loopback files for safe testing (not real partitions)
```

---

## 🎯 Key Concepts at a Glance

### Memory Model

```
┌─────────────────────────────┐
│        Virtual Memory       │
│  (Addressable by processes) │
├──────────────┬──────────────┤
│   Physical   │    Disk      │
│     RAM      │    Swap      │
│   (Fast)     │   (Slow)     │
└──────────────┴──────────────┘

When RAM full → Pages move to swap (slower)
When swap full → OOM Killer terminates processes
```

### Disk Organization

```
Physical Disk (/dev/sda)
├── Partition 1 (/dev/sda1)
│   └── Filesystem (ext4)
│       └── Mount at /
├── Partition 2 (/dev/sda2)
│   └── Filesystem (ext4)
│       └── Mount at /home
└── Partition 3 (/dev/sda3)
    └── Swap
```

### Key Monitoring Tools

| Tool | Purpose | Best For |
|------|---------|----------|
| **free** | Memory overview | Quick memory check |
| **top** | Real-time resource usage | Finding process hogs |
| **df** | Disk space per filesystem | Checking capacity |
| **du** | Disk usage by directory | Finding space hogs |
| **iostat** | I/O performance | Disk bottleneck analysis |
| **vmstat** | System-wide statistics | Overall performance |
| **lsblk** | Block device layout | Understanding storage |
| **mount** | Active mount points | See filesystem layout |

---

## 📊 Command Quick Reference

| Command | What It Does | Example |
|---------|-------------|---------|
| `free -h` | Memory usage | Check RAM and swap |
| `top` | Live processes & resources | Find memory hogs |
| `df -h` | Disk space per filesystem | Check partition capacity |
| `du -sh /*` | Disk usage by directory | Find large directories |
| `iostat -x` | I/O performance stats | Check disk activity |
| `vmstat 1 5` | System statistics | View memory/I/O trends |
| `lsblk` | Block device tree | See partition layout |
| `mount` | Active filesystems | Check mount points |
| `findmnt` | Tree of mount points | Visual filesystem layout |
| `ps aux --sort=-%mem` | Processes by memory | Top memory consumers |
| `find . -size +100M` | Files larger than 100MB | Locate large files |
| `df -i` | Inode usage | Check filesystem limits |

---

## 🚀 Getting Started

### Step 1: Verify Tools Are Installed
```bash
# Check all tools are available
which free top df du iostat vmstat lsblk
# All should return paths
```

### Step 2: Create Lab Environment
```bash
# Safe sandbox for all labs
mkdir -p ~/memory-disk-labs
cd ~/memory-disk-labs

# Verify location
pwd
# Should show: /home/username/memory-disk-labs
```

### Step 3: Check Your Current System
```bash
# Quick system overview
echo "=== Memory ==="
free -h

echo ""
echo "=== Disk ==="
df -h

echo ""
echo "=== Top Processes by Memory ==="
ps aux --sort=-%mem | head -10
```

### Step 4: Read Theory
```bash
# Start with concepts
cat ../01-theory.md | less
```

### Step 5: Start with Lab 1
```bash
# Begin first lab
cat ../03-hands-on-labs.md | grep -A 50 "Lab 1:"
```

---

## ✅ Success Criteria

You'll know you've mastered this module when you can:

- [ ] Interpret output of `free`, `top`, `df` commands
- [ ] Identify which processes use most memory
- [ ] Find what's consuming disk space
- [ ] Diagnose why a system is running slow
- [ ] Prevent out-of-memory conditions
- [ ] Clean up disk space safely
- [ ] Set up monitoring alerts
- [ ] Create capacity planning reports
- [ ] Explain memory vs. swap tradeoffs
- [ ] Optimize I/O performance

---

## 🔄 Progression Path

### After This Module
- ✅ Ready for: Module 06 (System Services & Daemons)
- ✅ Ready for: Module 13 (Logging & Monitoring)
- ✅ Ready for: Module 08 (User & Permission Management)
- ✅ Foundation for: DevOps automation and performance tuning

### Building on Previous Modules
- Extends: Module 01 (file operations, commands)
- Extends: Module 02 (text processing for parsing outputs)
- Extends: Module 04 (system information)
- Complements: All system administration modules

---

## 📞 Getting Help

### Within This Module
1. Check the Glossary (above) for term definitions
2. Review Command Quick Reference for syntax
3. Look up specific command in 02-commands-cheatsheet.md
4. Find similar example in 03-hands-on-labs.md

### External Resources
- **Man pages**: `man free`, `man top`, `man df`, `man du`, `man iostat`
- **Linux documentation**: kernel.org/doc
- **Stack Overflow**: [linux-kernel], [memory], [disk-space] tags
- **Community**: LinuxQuestions.org

### Troubleshooting
- **Command not found**: Install with `apt-get install sysstat`
- **Permission denied**: Use `sudo` or run as root
- **Output looks different**: Different Linux versions vary slightly
- **Numbers don't match**: May be calculating differently; focus on patterns

---

## 🎯 Next Steps

**Ready to start?**

1. ✅ Verify prerequisites (5 min)
2. ✅ Create lab environment (5 min)
3. ✅ Read [01-theory.md](01-theory.md) (40 min)
4. ✅ Start with Lab 1 in [03-hands-on-labs.md](03-hands-on-labs.md) (30 min)
5. ✅ Continue through all labs (3-5 hours)
6. ✅ Explore scripts (30 min)

**Estimated Total Time**: 5-7 hours

**Recommendation**: Dedicate 2 hours per session over 3-4 days for best retention.

---

## 📊 Module Statistics

- **Commands Covered**: 30+
- **Hands-On Labs**: 8
- **Production Scripts**: 2
- **Learning Time**: 5-7 hours
- **Prerequisites**: Module 01, 02
- **Difficulty**: Beginner to Intermediate
- **Real-World Relevance**: ⭐⭐⭐⭐⭐ (Essential)

---

## 📝 Files in This Module

| File | Purpose | Time |
|------|---------|------|
| README.md | This overview | 15 min |
| 01-theory.md | Conceptual foundations | 40 min |
| 02-commands-cheatsheet.md | Command reference | Reference |
| 03-hands-on-labs.md | Practical exercises | 3-5 hours |
| scripts/disk-monitor.sh | Monitoring tool | 15 min |
| scripts/memory-analyzer.sh | Analysis tool | 15 min |
| scripts/README.md | Script documentation | 10 min |

---

## 🎓 Module 05: Memory and Disk Management

**Welcome to one of the most critical skills in system administration.**

You can't manage what you can't measure. This module gives you the tools and knowledge to understand, monitor, and optimize memory and disk resources on Linux systems. Whether you're troubleshooting a crisis or planning for growth, these skills are essential.

**Let's get started.** → Read [01-theory.md](01-theory.md) next.

---

*Module 05: Memory and Disk Management*
*Part of the Linux for DevOps Learning Repository*
