# Module 10: Archive and Compression

A comprehensive guide to archiving and compressing files in Linux—essential for backups, distribution, and storage optimization.

---

## Why This Matters in the Real World

Linux systems generate massive amounts of data daily: logs, backups, database dumps, media files. Archiving and compression are critical for:

- **Storage optimization**: Reduce disk space by 50-90% depending on content
- **Backup strategy**: Create efficient backups that can be transferred over networks
- **Distribution**: Package applications, configurations, and data for deployment
- **Data preservation**: Archive old data while freeing up space on active systems
- **Disaster recovery**: Quickly restore complete directory trees from archives
- **Compliance**: Long-term data retention with efficient compression

**Real scenario**: Your database backups grow 2GB per day. Without compression, you'd need 60GB per month. With proper compression, that drops to 3-6GB—a 90% reduction.

---

## Prerequisites

Before starting this module, you should be familiar with:

- ✅ Linux command line basics (Module 01)
- ✅ File navigation and permissions (Modules 01, 08)
- ✅ Text manipulation and pipes (Module 02)
- ✅ Basic shell scripting concepts (understanding shebang, variables, loops)

**Recommended setup**:
- Ubuntu 20.04+ or Debian 11+ (or equivalent RHEL/CentOS)
- sudo access (for some operations)
- 5GB free disk space (for labs)
- Text editor (nano, vim, or VS Code)

---

## Learning Objectives

### Beginner Level (90 minutes)
After completing beginner material, you will be able to:

- ✅ Understand compression algorithms and their tradeoffs
- ✅ Create tar archives without compression
- ✅ Extract files from tar archives
- ✅ Use gzip, bzip2, and xz compression
- ✅ Work with zip files (creation and extraction)
- ✅ Understand compression ratios and when to use each format
- ✅ Verify archive integrity

**Time**: 90 minutes | **Labs**: 1-3 | **Commands**: Part A-C

### Intermediate Level (140 minutes)
After completing intermediate material, you will be able to:

- ✅ Create and manage multi-volume archives
- ✅ Archive specific files based on patterns
- ✅ Exclude files from archives
- ✅ Compress selective directories
- ✅ Verify and repair corrupted archives
- ✅ Split and merge large archives
- ✅ Use advanced tar options (incremental backups, permissions, sparse files)
- ✅ Automate archiving workflows

**Time**: 140 minutes | **Labs**: 4-6 | **Commands**: Part D-H

### Advanced Level (40+ minutes)
After completing advanced material, you will be able to:

- ✅ Automate backup archiving with retention policies
- ✅ Create production-grade backup systems
- ✅ Implement incremental backup strategies
- ✅ Deploy archives to remote locations
- ✅ Monitor and manage archive storage
- ✅ Implement disaster recovery procedures
- ✅ Optimize compression for different scenarios

**Time**: 40+ minutes | **Labs**: 7-8 | **Scripts**: Both

---

## Module Roadmap

### 1. Theory Foundation (90 minutes)
**[01-theory.md](01-theory.md)** - Comprehensive overview of compression and archiving concepts

Learn about compression algorithms (gzip, bzip2, xz), tar archive format, compression ratios, when to use each tool, and real-world strategies.

### 2. Command Reference (40 minutes)
**[02-commands-cheatsheet.md](02-commands-cheatsheet.md)** - Quick reference for 25+ commands

Detailed command reference with 40+ real examples including:
- tar (create, extract, list, append)
- gzip, bzip2, xz, brotli
- zip, unzip
- Compression comparison
- Common patterns and workflows

### 3. Hands-On Labs (280 minutes)
**[03-hands-on-labs.md](03-hands-on-labs.md)** - 8 progressive practical exercises

- Lab 1: Creating tar archives (30 min, beginner)
- Lab 2: Extracting and listing archives (30 min, beginner)
- Lab 3: Compression comparison (35 min, beginner)
- Lab 4: Advanced tar options (40 min, intermediate)
- Lab 5: Incremental backups (35 min, intermediate)
- Lab 6: Working with multi-volume archives (40 min, intermediate)
- Lab 7: Automated backup archiving (35 min, advanced)
- Lab 8: Archive verification and recovery (40 min, advanced)

### 4. Production Scripts (60 minutes)
**[scripts/](scripts/)** - Ready-to-use automation tools

- **archive-manager.sh** (280L) - Create, list, extract, verify, and manage archives
- **backup-automation.sh** (300L) - Automated backup with compression, rotation, and verification
- **[scripts/README.md](scripts/README.md)** - Complete usage guide with examples

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Archive** | A collection of files grouped into a single file (no compression) |
| **Compression** | Algorithm to reduce file size by removing redundancy |
| **Lossless** | Compression that preserves all original data perfectly |
| **Lossy** | Compression that discards non-essential data (not used for text/code) |
| **Compression ratio** | Original size ÷ compressed size (higher is better) |
| **Tar** | Unix archiving tool that groups files without compression |
| **Gzip** | Fast compression algorithm using DEFLATE algorithm (~60% ratio typical) |
| **Bzip2** | Slower compression with better ratios (~70% ratio typical) |
| **Xz** | Powerful compression with best ratios (~80% ratio typical) |
| **Zip** | Archive format that includes compression (PKZIP format) |
| **Incremental backup** | Backup only files changed since last backup |
| **Full backup** | Complete backup of all files |
| **Differential backup** | Backup all changes since last full backup |
| **Extraction** | Process of removing files from an archive |
| **Verification** | Checking archive integrity and completeness |
| **Sparse files** | Files with large empty sections (efficiently compressed) |

---

## Common Workflows

### Workflow 1: Create a Simple Backup

```bash
# Create compressed archive of /home directory
tar czf backup-home-$(date +%Y%m%d).tar.gz /home

# Extract entire archive
tar xzf backup-home-20240115.tar.gz -C /restore

# List contents without extracting
tar tzf backup-home-20240115.tar.gz
```

### Workflow 2: Compress Large Directories

```bash
# Find best compression for your data
time tar cf - /data | gzip > /backup/data.tar.gz      # Fast
time tar cf - /data | bzip2 > /backup/data.tar.bz2    # Better
time tar cf - /data | xz -9 > /backup/data.tar.xz     # Best (slow)

# Compare sizes
ls -lh /backup/data.tar.*
```

### Workflow 3: Automated Daily Backups

```bash
# Create script that runs daily
#!/bin/bash
BACKUP_DIR="/backup/daily"
DATE=$(date +%Y%m%d)

# Full backup on Monday
if [[ $(date +%u) -eq 1 ]]; then
  tar czf "$BACKUP_DIR/full-$DATE.tar.gz" /home /etc
else
  # Incremental on other days
  tar czf "$BACKUP_DIR/incr-$DATE.tar.gz" \
    --newer-mtime-than="$BACKUP_DIR/recent.timestamp" /home /etc
fi

# Keep only 7 days
find "$BACKUP_DIR" -mtime +7 -delete
```

### Workflow 4: Distribute Software Package

```bash
# Create archive with specific structure
mkdir -p /tmp/myapp-1.0
cp -r src/ config/ docs/ /tmp/myapp-1.0/
tar czf myapp-1.0.tar.gz -C /tmp myapp-1.0/

# Recipients verify and extract
tar tzf myapp-1.0.tar.gz  # List contents first
tar xzf myapp-1.0.tar.gz
```

---

## Module Features

✅ **Complete coverage**: From basic tar to advanced incremental backups  
✅ **Practical focus**: Real-world scenarios and production patterns  
✅ **Security-aware**: Best practices for backup verification and integrity  
✅ **Performance-optimized**: Understand compression tradeoffs  
✅ **Production scripts**: Ready-to-deploy automation tools  
✅ **8 hands-on labs**: Progressive skill building (280 minutes)  
✅ **25+ commands**: Complete command reference with examples  
✅ **10+ diagrams**: ASCII visualizations of concepts  

---

## Success Criteria

✅ **Can create tar archives** with and without compression  
✅ **Can extract files** from various archive formats  
✅ **Can optimize compression** for different scenarios  
✅ **Can automate backups** with retention policies  
✅ **Can verify archive integrity** and handle corruption  
✅ **Can implement incremental backups** for efficiency  
✅ **Can deploy archives** safely to production systems  

---

## Usage Path

**Recommended learning sequence**:

1. Start with [README.md](README.md) (this file) - 15 min
2. Read [01-theory.md](01-theory.md) - Understand concepts (90 min)
3. Reference [02-commands-cheatsheet.md](02-commands-cheatsheet.md) - Learn commands (40 min)
4. Complete [03-hands-on-labs.md](03-hands-on-labs.md) in order (280 min)
   - Labs 1-3: Beginner (90 min)
   - Labs 4-6: Intermediate (130 min)
   - Labs 7-8: Advanced (80 min)
5. Study [scripts/](scripts/) - Review automation tools (30 min)
6. Implement integration patterns (30-60 min)

**Total time**: 380-420 minutes (6.3-7 hours)

---

## Repository Coverage

This module covers the essential tools and techniques for Linux archiving and compression:

| Tool | Coverage | Examples |
|------|----------|----------|
| **tar** | ✅ Complete | Create, extract, list, append, update |
| **gzip** | ✅ Complete | Single file, stream compression |
| **bzip2** | ✅ Complete | Better compression ratio |
| **xz** | ✅ Complete | Best compression (slow) |
| **zip** | ✅ Complete | Cross-platform archives |
| **7z** | ✅ Mentioned | Reference for additional compression |
| **brotli** | ✅ Mentioned | Modern compression algorithm |
| **Backups** | ✅ Complete | Full, incremental, differential |
| **Verification** | ✅ Complete | Checksums, integrity checks |
| **Automation** | ✅ Complete | Production scripts included |

---

## Quick Start

### Install Necessary Tools (Ubuntu/Debian)

```bash
# Usually pre-installed, but verify:
sudo apt-get install tar gzip bzip2 xz-utils zip
```

### Verify Installation

```bash
# Check versions
tar --version
gzip --version
bzip2 --version
xz --version
zip --version
```

### Create Your First Archive

```bash
# Create test directory
mkdir -p ~/test-archive && cd ~/test-archive
echo "Hello, Archive!" > file1.txt
echo "More content" > file2.txt

# Create tar archive (no compression)
tar -cf my-archive.tar file1.txt file2.txt

# Create compressed archive
tar -czf my-archive.tar.gz file1.txt file2.txt

# Verify
tar -tzf my-archive.tar.gz

# Extract
tar -xzf my-archive.tar.gz -C ~/extract-test/
```

---

## Troubleshooting Common Issues

**Issue**: "tar: Command not found"
```bash
# Solution: Install tar
sudo apt-get install tar
```

**Issue**: "gzip: stdout: No space left on device"
```bash
# Solution: Archive to different location with more space
tar czf /other-partition/archive.tar.gz /source
```

**Issue**: "Cannot extract archive - permission denied"
```bash
# Solution: Extract to writable location or use sudo
sudo tar xzf archive.tar.gz -C /target
```

**Issue**: "Archive corrupted - unexpected end of file"
```bash
# Solution: Verify and try different extraction method
file corrupted.tar.gz
tar -tzf corrupted.tar.gz 2>&1 | head  # Show errors
```

---

## Next Steps After Module 10

- Continue to Module 11: Linux Boot Process
- Implement automated backup systems in your infrastructure
- Combine with Module 06 (Services) for automated backup services
- Use with Module 07 (Process Management) for background backup jobs
- Integrate with Module 05 (Memory/Disk) for storage optimization

---

## Module Statistics

- **Total files**: 8
- **Total lines**: 5,900+
- **Documentation**: 3,200+ lines
- **Scripts**: 600+ lines
- **Labs**: 8 (280 minutes)
- **Commands**: 25+
- **Examples**: 40+
- **Diagrams**: 10+
- **Learning time**: 380-420 minutes

---

**Module 10: Archive and Compression**  
*Professional Linux learning module for system administration*

Last updated: January 2024  
Status: Production Ready
