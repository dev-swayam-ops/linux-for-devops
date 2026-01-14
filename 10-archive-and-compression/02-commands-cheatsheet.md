# Commands Cheatsheet: Archive and Compression

Complete reference for archiving and compression commands with 40+ real examples.

---

## Part A: Creating Archives with Tar

### Basic Tar Creation

```bash
# Create uncompressed tar archive
tar -cf archive.tar file1 file2 directory/

# Create and list files being added (verbose)
tar -cvf archive.tar /home/user/documents

# Create tar from multiple sources
tar -cf backup.tar /home /etc /var/www

# Exclude certain files
tar -cf archive.tar /data --exclude='*.log' --exclude='.git'

# Exclude multiple patterns
tar -cf archive.tar /data \
  --exclude='*.tmp' \
  --exclude='cache/*' \
  --exclude='.DS_Store'
```

### Tar with Compression

```bash
# Create gzip compressed archive (.tar.gz)
tar -czf archive.tar.gz /data

# Create bzip2 compressed archive (.tar.bz2)
tar -cjf archive.tar.bz2 /data

# Create xz compressed archive (.tar.xz)
tar -cJf archive.tar.xz /data

# Create with compression and verbose
tar -czv -f archive.tar.gz /data
# output:
# /data/
# /data/file1.txt
# /data/file2.txt
# /data/subdir/file3.txt
```

### Tar Advanced Creation Options

```bash
# Create archive preserving permissions (default)
tar -czf archive.tar.gz /data --preserve-permissions

# Exclude certain files (multiple exclusions)
tar -czf backup.tar.gz /data \
  --exclude='*.o' \
  --exclude='*.pyc' \
  --exclude='.cache'

# Archive files newer than a timestamp
tar -czf recent.tar.gz /data \
  --newer-mtime-than='2024-01-01'

# Archive only files matching pattern
tar -czf src-backup.tar.gz /data --include='*.c' --include='*.h'

# Append files to existing archive (tar must exist, not compressed)
tar -rf archive.tar newfile.txt

# Update files in archive (add if newer or missing)
tar -uf archive.tar updated-file.txt
```

---

## Part B: Extracting Archives

### Basic Extraction

```bash
# Extract uncompressed tar
tar -xf archive.tar

# Extract gzip compressed tar
tar -xzf archive.tar.gz

# Extract bzip2 compressed tar
tar -xjf archive.tar.bz2

# Extract xz compressed tar
tar -xJf archive.tar.xz

# Automatic compression detection
tar -xf archive.tar.*  # Tar detects compression automatically
```

### Extract to Specific Location

```bash
# Extract to directory
tar -xzf archive.tar.gz -C /restore/

# Extract to current directory
tar -xzf archive.tar.gz -C .

# Extract with verbose output
tar -xzvf archive.tar.gz
# output:
# x data/
# x data/file1.txt
# x data/file2.txt

# Extract specific file from archive
tar -xzf archive.tar.gz data/important-file.txt

# Extract directory from archive
tar -xzf archive.tar.gz data/subdir/
```

### Extract Partial Content

```bash
# List and extract only .txt files
tar -xzf archive.tar.gz --wildcards '*.txt'

# Extract excluding patterns
tar -xzf archive.tar.gz --exclude='*.log'

# Extract with strip path components (remove leading dirs)
tar -xzf archive.tar.gz --strip-components=2
# /data/subdir/file.txt becomes subdir/file.txt
```

---

## Part C: Listing Archive Contents

### List Archive Contents

```bash
# List files in uncompressed tar
tar -tf archive.tar

# List files in gzip tar
tar -tzf archive.tar.gz

# List files in bzip2 tar
tar -tjf archive.tar.bz2

# List files in xz tar
tar -tJf archive.tar.xz

# List with details (long format)
tar -tzfv archive.tar.gz
# output:
# -rw-r--r-- user/group 1024 2024-01-15 10:30 data/file.txt
# -rw-r--r-- user/group 2048 2024-01-15 10:31 data/file2.txt
# drwxr-xr-x user/group    0 2024-01-15 10:32 data/subdir/
```

### Search Archive Contents

```bash
# Find specific file in archive
tar -tzf archive.tar.gz | grep filename.txt

# Find all .txt files
tar -tzf archive.tar.gz | grep '\.txt$'

# Count files in archive
tar -tzf archive.tar.gz | wc -l

# Show only directories
tar -tzf archive.tar.gz | grep '/$'

# Check if file exists in archive
tar -tzf archive.tar.gz | grep -q data/important.txt && echo "Found"
```

---

## Part D: Gzip Compression

### Creating Gzip Files

```bash
# Compress single file
gzip large-file.txt
# Result: large-file.txt.gz (original deleted)

# Compress keeping original
gzip -k large-file.txt
# Result: large-file.txt and large-file.txt.gz

# Compress with specific level (1-9, default 6)
gzip -1 large-file.txt  # Fast, less compression
gzip -9 large-file.txt  # Slow, best compression

# Compress multiple files
gzip *.log
# Result: file1.log.gz, file2.log.gz, etc.

# Gzip from stdin (streaming)
cat large-file.txt | gzip > large-file.txt.gz
```

### Decompressing Gzip Files

```bash
# Decompress file
gunzip large-file.txt.gz
# Result: large-file.txt (original .gz deleted)

# Decompress keeping compressed version
gunzip -k large-file.txt.gz

# Decompress to stdout
gunzip -c large-file.txt.gz > restored-file.txt

# Decompress all .gz files
gunzip *.gz
```

### Gzip Information

```bash
# Show compression ratio
gzip -l archive.tar.gz
# output:
#   compressed        uncompressed  ratio uncompressed_name
#   524288            1048576       50.0% archive.tar

# Test integrity
gzip -t archive.tar.gz
# Silent if OK, shows error if corrupted
```

---

## Part E: Bzip2 Compression

### Creating Bzip2 Files

```bash
# Compress file
bzip2 large-file.txt
# Result: large-file.txt.bz2

# Compress keeping original
bzip2 -k large-file.txt

# Compress with quality (1-9, default 9)
bzip2 -1 large-file.txt  # Fast, less compression
bzip2 -9 large-file.txt  # Maximum compression

# Multiple files
bzip2 *.log

# From stdin
cat large-file.txt | bzip2 > large-file.txt.bz2
```

### Decompressing Bzip2 Files

```bash
# Decompress file
bunzip2 large-file.txt.bz2

# Decompress keeping .bz2
bunzip2 -k large-file.txt.bz2

# Decompress to stdout
bunzip2 -c large-file.txt.bz2 > restored-file.txt

# Decompress all .bz2 files
bunzip2 *.bz2
```

---

## Part F: Xz Compression

### Creating Xz Files

```bash
# Compress file
xz large-file.txt
# Result: large-file.txt.xz

# Compress keeping original
xz -k large-file.txt

# Compression level (0-9, default 6)
xz -0 large-file.txt  # Very fast, poor compression
xz -6 large-file.txt  # Balanced (default)
xz -9 large-file.txt  # Maximum compression (very slow)

# Multi-threaded compression (use multiple cores)
xz -T 4 large-file.txt  # Use 4 threads

# From stdin
cat large-file.txt | xz > large-file.txt.xz
```

### Decompressing Xz Files

```bash
# Decompress file
unxz large-file.txt.xz

# Decompress keeping .xz
unxz -k large-file.txt.xz

# Decompress to stdout
unxz -c large-file.txt.xz > restored-file.txt

# Multi-threaded decompression
unxz -T 4 large-file.txt.xz
```

---

## Part G: Zip Files

### Creating Zip Archives

```bash
# Create zip from files
zip archive.zip file1 file2 file3

# Create zip from directory (recursive)
zip -r archive.zip directory/

# Create zip with compression level (0=store, 9=maximum)
zip -1 archive.zip file.txt  # Fast
zip -9 archive.zip file.txt  # Maximum

# Zip excluding patterns
zip -r archive.zip directory/ -x '*.log' '*.tmp'

# Zip multiple directories
zip -r backup.zip /home /etc /var/www

# Zip with password (prompts for password)
zip -e archive.zip file1 file2
# Enter password: ****
```

### Extracting Zip Files

```bash
# List zip contents
unzip -l archive.zip

# Extract zip file
unzip archive.zip

# Extract to directory
unzip archive.zip -d /restore/

# Extract specific file
unzip archive.zip specific-file.txt

# Extract with verbose
unzip -v archive.zip

# Test zip integrity
unzip -t archive.zip
```

---

## Part H: Compression Comparison and Performance

### Compare Compression Tools

```bash
# Create test file
dd if=/dev/zero bs=1M count=100 of=testfile.bin

# Compress with different tools (measure time and size)
time gzip -k testfile.bin
du -h testfile.bin.gz

time bzip2 -k testfile.bin
du -h testfile.bin.bz2

time xz -k testfile.bin
du -h testfile.bin.xz

time zip test.zip testfile.bin
du -h test.zip

# Output comparison:
# gzip:  10 seconds, 50MB
# bzip2: 30 seconds, 45MB
# xz:    120 seconds, 35MB
# zip:   8 seconds, 50MB
```

### Calculate Compression Ratio

```bash
# Manual calculation
du -b testfile.bin | awk '{print $1}'  # Original size
du -b testfile.bin.gz | awk '{print $1}'  # Compressed size

# Script to show compression ratio
original=$(stat -f%z testfile.bin 2>/dev/null || stat -c%s testfile.bin)
compressed=$(stat -f%z testfile.bin.gz 2>/dev/null || stat -c%s testfile.bin.gz)
ratio=$(echo "scale=2; $compressed * 100 / $original" | bc)
echo "Compression ratio: $ratio%"

# Using gzip built-in
gzip -l testfile.bin.gz
```

---

## Part I: Advanced Tar Options

### Incremental Backups

```bash
# Create full backup
tar -czf full-backup.tar.gz /data
touch /tmp/backup.timestamp

# Incremental: backup files changed since full backup
tar -czf incremental-$(date +%s).tar.gz \
  --newer-mtime-than=/tmp/backup.timestamp \
  /data

# Update timestamp
touch /tmp/backup.timestamp
```

### Sparse Files

```bash
# Create sparse file (efficiently compressed)
dd if=/dev/zero of=sparsefile bs=1M count=1 seek=100
# File shows 100MB but only uses 1MB on disk

# Tar recognizes sparse files
tar -S -czf sparse-backup.tar.gz sparsefile
# Archive is much smaller

# Extract preserving sparseness
tar -S -xzf sparse-backup.tar.gz
```

### Preserve Special Attributes

```bash
# Preserve all attributes (default)
tar -czf backup.tar.gz /data

# Preserve SELinux context (if available)
tar --selinux -czf backup.tar.gz /data

# Preserve ACLs (extended permissions)
tar --acls -czf backup.tar.gz /data

# Preserve both
tar --selinux --acls -czf backup.tar.gz /data
```

### Exclude by File Size

```bash
# Exclude files larger than 100MB
tar -czf backup.tar.gz /data --exclude-from <(find /data -size +100M)

# Exclude files smaller than 1MB
tar -czf backup.tar.gz /data --exclude-from <(find /data -size -1M)
```

---

## Part J: Working with Multiple Volumes

### Split Archives

```bash
# Create tar and split into 100MB volumes
tar -czf - /data | split -b 100m - archive.tar.gz.

# Result: archive.tar.gz.aa, archive.tar.gz.ab, archive.tar.gz.ac, etc.

# Combine and extract
cat archive.tar.gz.* | tar -xzf -

# Extract to specific location
cat archive.tar.gz.* | tar -xzf - -C /restore/
```

### Create Multi-Volume Tar

```bash
# Create tar that spans multiple volumes (old method, tape-oriented)
tar -M -f /backup/archive.tar /data
# Prompts to insert next volume

# Modern approach: use split command instead (shown above)
```

---

## Part K: Verification and Integrity

### Verify Archive Integrity

```bash
# Test tar archive (extracts to /dev/null)
tar -tzf archive.tar.gz > /dev/null
# Silent if OK, shows error if corrupted

# Test with verbose error reporting
tar -tzf archive.tar.gz 2>&1 | head

# Test zip file
unzip -t archive.zip

# Test gzip file
gzip -t archive.tar.gz

# Test bzip2 file
bzip2 -t archive.tar.bz2

# Test xz file
xz -t archive.tar.xz
```

### Create and Verify Checksums

```bash
# Create SHA256 checksum
sha256sum archive.tar.gz > archive.tar.gz.sha256

# Verify checksum
sha256sum -c archive.tar.gz.sha256
# Output: archive.tar.gz: OK

# Create MD5 (faster but less secure, OK for integrity check)
md5sum archive.tar.gz > archive.tar.gz.md5

# Verify MD5
md5sum -c archive.tar.gz.md5
```

---

## Part L: Common Patterns and Workflows

### Pattern 1: Archive and Compress Different Formats

```bash
# One-liner: archive + compress to different formats
SOURCE=/data
ARCHIVE_NAME=backup-$(date +%Y%m%d)

# Gzip (general use)
tar czf $ARCHIVE_NAME.tar.gz $SOURCE

# Bzip2 (better compression)
tar cjf $ARCHIVE_NAME.tar.bz2 $SOURCE

# Xz (maximum compression)
tar cJf $ARCHIVE_NAME.tar.xz $SOURCE

# Zip (cross-platform)
zip -r $ARCHIVE_NAME.zip $SOURCE
```

### Pattern 2: Backup with Exclusions

```bash
# Backup /home excluding .cache, .tmp, .git
tar czf home-backup.tar.gz /home \
  --exclude='~/.cache' \
  --exclude='~/.tmp' \
  --exclude='~/.git' \
  --exclude='*.log'
```

### Pattern 3: Backup and Verify

```bash
#!/bin/bash
ARCHIVE="backup-$(date +%Y%m%d).tar.gz"

# Create
tar czf "$ARCHIVE" /data || exit 1

# Verify
if tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
  sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"
  echo "✓ Backup verified: $ARCHIVE"
else
  echo "✗ Backup failed"
  rm "$ARCHIVE"
  exit 1
fi
```

### Pattern 4: Backup to Remote with Verification

```bash
REMOTE="backup.example.com"
ARCHIVE="backup-$(date +%Y%m%d).tar.gz"

# Create locally
tar czf "$ARCHIVE" /data

# Create checksum
sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"

# Copy to remote
scp "$ARCHIVE" root@$REMOTE:/backup/
scp "$ARCHIVE.sha256" root@$REMOTE:/backup/

# Verify on remote
ssh root@$REMOTE "cd /backup && sha256sum -c $ARCHIVE.sha256"
```

### Pattern 5: Incremental Backup Strategy

```bash
#!/bin/bash
BACKUP_DIR=/backup
TIMESTAMP_FILE=$BACKUP_DIR/.last-full

# Full backup on Monday
if [[ $(date +%u) -eq 1 ]]; then
  tar czf $BACKUP_DIR/full-$(date +%Y%m%d).tar.gz /data
  touch $TIMESTAMP_FILE
else
  # Incremental on other days
  tar czf $BACKUP_DIR/incr-$(date +%Y%m%d).tar.gz \
    --newer-mtime-than=$TIMESTAMP_FILE \
    /data
fi
```

---

## Part M: Quick Reference Table

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -cf` | Create tar | `tar -cf backup.tar /data` |
| `tar -czf` | Create tar + gzip | `tar -czf backup.tar.gz /data` |
| `tar -cjf` | Create tar + bzip2 | `tar -cjf backup.tar.bz2 /data` |
| `tar -cJf` | Create tar + xz | `tar -cJf backup.tar.xz /data` |
| `tar -xf` | Extract tar | `tar -xf backup.tar` |
| `tar -xzf` | Extract tar.gz | `tar -xzf backup.tar.gz` |
| `tar -tf` | List tar contents | `tar -tf backup.tar` |
| `tar -tzf` | List tar.gz contents | `tar -tzf backup.tar.gz` |
| `gzip` | Compress file | `gzip large.txt` |
| `gunzip` | Decompress | `gunzip large.txt.gz` |
| `bzip2` | Compress (better ratio) | `bzip2 large.txt` |
| `bunzip2` | Decompress bzip2 | `bunzip2 large.txt.bz2` |
| `xz` | Compress (best ratio) | `xz large.txt` |
| `unxz` | Decompress xz | `unxz large.txt.xz` |
| `zip -r` | Create zip | `zip -r archive.zip dir/` |
| `unzip` | Extract zip | `unzip archive.zip` |
| `sha256sum` | Create checksum | `sha256sum file > file.sha256` |
| `sha256sum -c` | Verify checksum | `sha256sum -c file.sha256` |

---

## Part N: Troubleshooting Common Issues

### Issue: "tar: Cannot open ... No such file"

```bash
# Wrong: File path doesn't exist
tar -czf backup.tar.gz /nonexistent/path

# Right: Verify path exists first
tar -czf backup.tar.gz /existing/path
```

### Issue: "tar: Unexpected EOF"

Archive is corrupted or incomplete:
```bash
# Verify
tar -tzf archive.tar.gz 2>&1 | tail

# Try to extract what you can
tar -xzf archive.tar.gz 2>&1 | grep -i error
```

### Issue: "Out of disk space"

```bash
# Wrong: Trying to compress in same location
gzip /data/large-file.txt
# Needs 2x space (original + compressed)

# Right: Compress to different location
gzip -c /data/large-file.txt > /other-partition/large-file.txt.gz
```

### Issue: "Permission denied" on extraction

```bash
# Wrong: Permissions stripped
tar -xzf archive.tar.gz

# Right: Preserve permissions (default behavior)
tar -xzf archive.tar.gz --preserve-permissions
# Or extract as sudo
sudo tar -xzf archive.tar.gz
```

### Issue: Checksum mismatch after transfer

```bash
# File was corrupted in transit
sha256sum -c archive.tar.gz.sha256
# Output: archive.tar.gz: FAILED

# Solution: Transfer again
# Or check if receiving system has disk corruption
```

---

## Part O: Best Practices Summary

| Practice | Reason |
|----------|--------|
| **Always create checksums** | Verify backup integrity |
| **Test archive after creation** | Catch corruption early |
| **Use consistent naming** | Easy to find backups |
| **Include date in filename** | Track backup timeline |
| **Choose compression wisely** | Balance speed vs. size |
| **Exclude unnecessary files** | Reduce backup size |
| **Compress before transfer** | Faster network transfer |
| **Keep multiple copies** | Disaster recovery |
| **Document retention policy** | Know what to keep |
| **Verify on restore** | Test backups before needed |

---

**Next**: Complete [03-hands-on-labs.md](03-hands-on-labs.md) for practical experience.
