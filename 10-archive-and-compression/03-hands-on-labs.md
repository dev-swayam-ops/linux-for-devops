# Hands-On Labs: Archive and Compression

8 progressive hands-on laboratories covering practical archiving and compression scenarios (280 minutes total).

---

## Lab Overview

| Lab | Title | Level | Time | Focus |
|-----|-------|-------|------|-------|
| 1 | Creating tar archives | Beginner | 30 min | Basic tar creation |
| 2 | Extracting and listing | Beginner | 30 min | Extract, list, search |
| 3 | Comparing compressions | Beginner | 35 min | Compression ratios |
| 4 | Advanced tar options | Intermediate | 40 min | Exclusions, updates |
| 5 | Incremental backups | Intermediate | 35 min | Incremental strategy |
| 6 | Multi-volume archives | Intermediate | 40 min | Large archives |
| 7 | Automated backup | Advanced | 35 min | Production scripts |
| 8 | Archive recovery | Advanced | 40 min | Recovery procedures |

---

## Lab 1: Creating Tar Archives

**Goal**: Learn to create tar archives with and without compression

**Time**: 30 minutes | **Level**: Beginner

### Setup

```bash
# Create test directory structure
mkdir -p ~/lab1-tar/project/{src,config,docs}
cd ~/lab1-tar

# Create test files
cat > project/src/main.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
EOF

cat > project/src/utils.c << 'EOF'
#include <stdio.h>
void util_print(const char *msg) {
    printf("Util: %s\n", msg);
}
EOF

cat > project/config/app.conf << 'EOF'
APP_NAME=MyApp
VERSION=1.0
DEBUG=true
EOF

cat > project/docs/README.md << 'EOF'
# MyApp Documentation
This is a sample application.
EOF

echo "Test data" > project/data.txt
```

### Steps

**Step 1**: List the project directory structure
```bash
tree project/
# Output:
# project/
# ├── config
# │   └── app.conf
# ├── data.txt
# ├── docs
# │   └── README.md
# └── src
#     ├── main.c
#     └── utils.c
```

**Step 2**: Create uncompressed tar archive
```bash
tar -cf project-backup.tar project/
ls -lh project-backup.tar
# Output: -rw-r--r-- 1 user user 10K project-backup.tar
```

**Step 3**: Verify archive contents
```bash
tar -tf project-backup.tar
# Output:
# project/
# project/src/
# project/src/main.c
# project/src/utils.c
# project/config/
# project/config/app.conf
# project/docs/
# project/docs/README.md
# project/data.txt
```

**Step 4**: Create gzip compressed archive
```bash
tar -czf project-backup.tar.gz project/
ls -lh project-backup*
# Output:
# -rw-r--r-- 1 user user 10K project-backup.tar
# -rw-r--r-- 1 user user 2K project-backup.tar.gz
```

**Step 5**: Create tar with verbose output
```bash
tar -czv -f project-backup-verbose.tar.gz project/
# Output:
# project/
# project/src/
# project/src/main.c
# project/src/utils.c
# project/config/
# project/config/app.conf
# project/docs/
# project/docs/README.md
# project/data.txt
```

**Step 6**: Create tar excluding certain files
```bash
tar -czf project-no-docs.tar.gz project/ --exclude='docs'
tar -tzf project-no-docs.tar.gz
# Output: (no docs directory)
```

**Step 7**: Compare archive sizes
```bash
ls -lh project-backup*
du -h project/
# Output example:
# 4.0K project/
# 10K project-backup.tar (uncompressed)
# 2K project-backup.tar.gz (compressed - 80% smaller!)
# 2.1K project-backup-verbose.tar.gz
# 1.8K project-no-docs.tar.gz
```

**Step 8**: Create tar appending files (update archive)
```bash
# Create new file
echo "Updated config" > project/config/new-setting.conf

# Update archive (tar must not be compressed for append)
tar -rf project-backup.tar project/config/new-setting.conf

# Verify update
tar -tf project-backup.tar | grep new-setting
```

### Expected Output

Archive files created with sizes approximately:
- Uncompressed: 10KB
- Gzip: 2KB
- No docs: 1.8KB

### Verification Checklist

- [ ] project-backup.tar created (10KB)
- [ ] project-backup.tar.gz created (2KB)
- [ ] tar -tf shows all files correctly
- [ ] Gzip version is 80% smaller
- [ ] Verbose output shows all files
- [ ] Exclusion works (no docs in output)
- [ ] Append operation successful
- [ ] tar -tzf shows new file in archive

### Cleanup

```bash
cd ~
rm -rf ~/lab1-tar
```

---

## Lab 2: Extracting and Listing Archives

**Goal**: Master extraction and searching archive contents

**Time**: 30 minutes | **Level**: Beginner

### Setup

```bash
mkdir -p ~/lab2-extract
cd ~/lab2-extract

# Use archive from Lab 1, or create a sample
cat > create-test-archive.sh << 'EOF'
#!/bin/bash
mkdir -p data/app/{bin,lib,config,docs}
echo "Binary app" > data/app/bin/myapp
echo "Shared library" > data/app/lib/libapp.so
echo "app_name=MyApp" > data/app/config/settings.conf
echo "# Documentation" > data/app/docs/README.md
tar -czf app-archive.tar.gz data/
rm -rf data
EOF

bash create-test-archive.sh
```

### Steps

**Step 1**: List archive contents
```bash
tar -tzf app-archive.tar.gz
# Output:
# data/
# data/app/
# data/app/bin/
# data/app/bin/myapp
# data/app/lib/
# data/app/lib/libapp.so
# data/app/config/
# data/app/config/settings.conf
# data/app/docs/
# data/app/docs/README.md
```

**Step 2**: List with file details
```bash
tar -tzvf app-archive.tar.gz
# Output:
# -rw-r--r-- user/group 10 2024-01-15 10:30 data/app/bin/myapp
# -rw-r--r-- user/group 15 2024-01-15 10:30 data/app/lib/libapp.so
# -rw-r--r-- user/group 20 2024-01-15 10:30 data/app/config/settings.conf
# -rw-r--r-- user/group 17 2024-01-15 10:30 data/app/docs/README.md
```

**Step 3**: Search archive for specific files
```bash
tar -tzf app-archive.tar.gz | grep '\.so'
# Output: data/app/lib/libapp.so

tar -tzf app-archive.tar.gz | grep config
# Output: data/app/config/settings.conf
```

**Step 4**: Count files in archive
```bash
tar -tzf app-archive.tar.gz | wc -l
# Output: 7 (including directories)
```

**Step 5**: Extract entire archive
```bash
mkdir extract-all
tar -xzf app-archive.tar.gz -C extract-all/
tree extract-all/
# Output:
# extract-all/
# └── data/
#     └── app/
#         ├── bin/
#         │   └── myapp
#         ├── config/
#         │   └── settings.conf
#         ├── docs/
#         │   └── README.md
#         └── lib/
#             └── libapp.so
```

**Step 6**: Extract to different location
```bash
mkdir -p /tmp/restore
tar -xzf app-archive.tar.gz -C /tmp/restore/
ls -la /tmp/restore/data/app/
```

**Step 7**: Extract specific file
```bash
mkdir extract-specific
tar -xzf app-archive.tar.gz -C extract-specific/ data/app/config/settings.conf
cat extract-specific/data/app/config/settings.conf
# Output: app_name=MyApp
```

**Step 8**: Extract excluding patterns
```bash
mkdir extract-no-docs
tar -xzf app-archive.tar.gz -C extract-no-docs/ --exclude='*/docs/*'
tree extract-no-docs/
# Output: (no docs directory)
```

### Expected Output

Multiple extraction directories created with proper file structure

### Verification Checklist

- [ ] tar -tzf lists all files correctly
- [ ] tar -tzvf shows file details
- [ ] grep searches work correctly
- [ ] File count matches (7 items)
- [ ] Full extraction creates complete structure
- [ ] Extract to different location works
- [ ] Specific file extraction works
- [ ] Exclusion filtering works

### Cleanup

```bash
cd ~
rm -rf ~/lab2-extract
```

---

## Lab 3: Comparing Compression Ratios

**Goal**: Understand compression ratios and choose appropriate algorithms

**Time**: 35 minutes | **Level**: Beginner

### Setup

```bash
mkdir -p ~/lab3-compression
cd ~/lab3-compression

# Create various test files
echo "Highly repetitive data:" > README
for i in {1..1000}; do echo "This is line number $i with repetitive content"; done >> README

# Create source code files
cat > program.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <filename>\n", argv[0]);
        return 1;
    }
    printf("Processing file: %s\n", argv[1]);
    return 0;
}
EOF

# Create binary data
dd if=/dev/urandom of=random-data.bin bs=1M count=10 2>/dev/null

# Create highly compressible (zero-filled)
dd if=/dev/zero of=zeros.bin bs=1M count=10 2>/dev/null
```

### Steps

**Step 1**: Check original file sizes
```bash
ls -lh
du -h *
# Output:
# 50K README (highly repetitive)
# 2.5K program.c (source code)
# 10M random-data.bin (random, not compressible)
# 10M zeros.bin (zeros, highly compressible)
```

**Step 2**: Compress README with gzip
```bash
time gzip -k README
ls -lh README*
# Output:
# -rw-r--r-- 1 user user 50K README
# -rw-r--r-- 1 user user 8K README.gz
# Compression ratio: 8K/50K = 16% (84% reduction)
```

**Step 3**: Compress with bzip2
```bash
time bzip2 -k README
ls -lh README*
# Output:
# -rw-r--r-- 1 user user 50K README
# -rw-r--r-- 1 user user 8K README.gz
# -rw-r--r-- 1 user user 6K README.bz2
# Bzip2 is 25% better than gzip
```

**Step 4**: Compress with xz
```bash
time xz -k README
ls -lh README*
# Output:
# -rw-r--r-- 1 user user 50K README
# -rw-r--r-- 1 user user 8K README.gz
# -rw-r--r-- 1 user user 6K README.bz2
# -rw-r--r-- 1 user user 4K README.xz
# Xz is best: 8% of original
```

**Step 5**: Calculate compression ratios
```bash
for file in README README.gz README.bz2 README.xz; do
  size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
  echo "$file: $size bytes"
done

# Calculate ratio
original_size=51200  # approximate
for file in README.gz README.bz2 README.xz; do
  size=$(stat -c%s "$file" 2>/dev/null)
  ratio=$(echo "scale=1; $size * 100 / $original_size" | bc)
  echo "$file: $ratio%"
done
```

**Step 6**: Compare random data (not compressible)
```bash
time gzip -k random-data.bin
time bzip2 -k random-data.bin
time xz -k random-data.bin

ls -lh random-data.bin*
# Output:
# random-data.bin: 10M
# random-data.bin.gz: 10M (no reduction)
# random-data.bin.bz2: 10M (no reduction)
# random-data.bin.xz: 10M (no reduction)
# Random data doesn't compress
```

**Step 7**: Compare highly compressible data
```bash
ls -lh zeros.bin
gzip -k zeros.bin
bzip2 -k zeros.bin
xz -k zeros.bin

ls -lh zeros.bin*
# Output:
# zeros.bin: 10M
# zeros.bin.gz: 50K (99.5% reduction!)
# zeros.bin.bz2: 40K (99.6% reduction)
# zeros.bin.xz: 20K (99.8% reduction)
```

**Step 8**: Create comprehensive comparison
```bash
echo "Compression Comparison:" > results.txt
echo "File: program.c" >> results.txt

for file in program.c; do
  orig=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
  gzip -k "$file"
  gz_size=$(stat -c%s "$file.gz" 2>/dev/null)
  ratio=$(echo "scale=2; $gz_size * 100 / $orig" | bc)
  echo "Gzip: ${gz_size} bytes ($ratio% of original)" >> results.txt
done

cat results.txt
```

### Expected Output

Comparison showing:
- README: gzip 16%, bzip2 12%, xz 8%
- Random data: No significant compression (>90%)
- Zeros: Extreme compression (>99%)

### Verification Checklist

- [ ] README compressed: 16% (gzip)
- [ ] Bzip2 better than gzip: 12%
- [ ] Xz best: 8%
- [ ] Random data doesn't compress
- [ ] Zeros compress >99%
- [ ] Time measurements show xz is slower
- [ ] Compression ratios calculated correctly
- [ ] All comparison files created

### Cleanup

```bash
cd ~
rm -rf ~/lab3-compression
```

---

## Lab 4: Advanced Tar Options

**Goal**: Learn exclusions, updates, and advanced tar features

**Time**: 40 minutes | **Level**: Intermediate

### Setup

```bash
mkdir -p ~/lab4-advanced
cd ~/lab4-advanced

# Create project directory
mkdir -p project/{src,build,config,.git,docs}

# Create files
echo "main code" > project/src/main.py
echo "utils code" > project/src/utils.py
echo "README" > project/docs/README.md
echo "git config" > project/.git/config
echo "build output" > project/build/app.o
echo "settings" > project/config/app.conf

# Create some log files
echo "log entry" > project/src/app.log
echo "log entry" > project/config/error.log
```

### Steps

**Step 1**: Create archive with all files
```bash
tar -czf backup-all.tar.gz project/
tar -tzf backup-all.tar.gz | wc -l
# Output: 15 files/directories
```

**Step 2**: Create archive excluding build and git
```bash
tar -czf backup-clean.tar.gz project/ \
  --exclude='build' \
  --exclude='.git'

tar -tzf backup-clean.tar.gz
# Output: (no build or .git directories)
```

**Step 3**: Create archive excluding multiple patterns
```bash
tar -czf backup-source-only.tar.gz project/ \
  --exclude='*.log' \
  --exclude='build/*' \
  --exclude='.git/*' \
  --exclude='*.pyc'

tar -tzf backup-source-only.tar.gz
# Output: Only source files and config
```

**Step 4**: Show size difference
```bash
ls -lh backup-*.tar.gz
# Output:
# backup-all.tar.gz: 2K
# backup-clean.tar.gz: 1.8K (10% smaller)
# backup-source-only.tar.gz: 1.5K (25% smaller)
```

**Step 5**: Create archive with specific file types
```bash
tar -czf backup-py-only.tar.gz project/ \
  --include='*.py' \
  --include='*.md' \
  --exclude='*'

tar -tzf backup-py-only.tar.gz
# Output: Only .py and .md files
```

**Step 6**: Update existing tar archive
```bash
# Uncompressed tar needed for append
tar -cf project-updates.tar project/src/

# Add new file
echo "new utility" > project/src/newutil.py

# Append to existing tar
tar -rf project-updates.tar project/src/newutil.py

# Verify
tar -tf project-updates.tar | grep newutil
# Output: project/src/newutil.py
```

**Step 7**: Archive files modified after specific date
```bash
# Create a reference file with old timestamp
touch -t 202301010000 reference-date

# Archive only files newer than reference
tar -czf backup-recent.tar.gz project/ \
  --newer-mtime-than=reference-date

tar -tzf backup-recent.tar.gz
```

**Step 8**: Create tar from list of files
```bash
# Create file list
cat > file-list.txt << 'EOF'
project/src/main.py
project/src/utils.py
project/config/app.conf
EOF

# Create tar from list
tar -czf backup-from-list.tar.gz -T file-list.txt

tar -tzf backup-from-list.tar.gz
# Output: Only files in the list
```

### Expected Output

Various compressed tar archives with different content based on exclusions/inclusions

### Verification Checklist

- [ ] backup-all.tar.gz includes everything (15 items)
- [ ] backup-clean.tar.gz excludes build and .git
- [ ] backup-source-only.tar.gz excludes logs and build
- [ ] Size comparison shows differences
- [ ] Pattern matching includes/excludes work
- [ ] Archive append works
- [ ] Recent modification filtering works
- [ ] File list creation works

### Cleanup

```bash
cd ~
rm -rf ~/lab4-advanced
```

---

## Lab 5: Incremental Backups

**Goal**: Implement incremental backup strategy

**Time**: 35 minutes | **Level**: Intermediate

### Setup

```bash
mkdir -p ~/lab5-incremental
cd ~/lab5-incremental

# Create data directory
mkdir -p data/important

# Initial data
echo "Original document 1" > data/important/doc1.txt
echo "Original document 2" > data/important/doc2.txt
echo "Config file" > data/config.conf

# Create timestamp for full backup
touch backup-timestamp-full
```

### Steps

**Step 1**: Create full backup
```bash
tar -czf backup-full-20240115.tar.gz data/
ls -lh backup-full-20240115.tar.gz
# Output: 2K (full backup)
```

**Step 2**: Update timestamp marker
```bash
touch backup-timestamp-full
# This marks when the full backup was created
```

**Step 3**: Simulate day 2 - make some changes
```bash
# Day 2: Modify a file
echo "Updated on Day 2" >> data/important/doc1.txt

# Add new file
echo "New document" > data/important/doc3.txt

# Don't change doc2.txt and config.conf
```

**Step 4**: Create incremental backup
```bash
tar -czf backup-incr-20240116.tar.gz \
  --newer-mtime-than=backup-timestamp-full \
  data/

ls -lh backup-incr-*.tar.gz
# Output: 1.5K (only changed files)
```

**Step 5**: Verify incremental only has changes
```bash
tar -tzf backup-incr-20240116.tar.gz
# Output: Only doc1.txt and doc3.txt
# No doc2.txt or config.conf
```

**Step 6**: Update timestamp
```bash
touch backup-timestamp-day2
```

**Step 7**: Simulate day 3 - more changes
```bash
# Day 3: Change config
echo "Updated config on Day 3" > data/config.conf

# Create new file
echo "Report file" > data/report.txt
```

**Step 8**: Create day 3 incremental
```bash
tar -czf backup-incr-20240117.tar.gz \
  --newer-mtime-than=backup-timestamp-day2 \
  data/

tar -tzf backup-incr-20240117.tar.gz
# Output: Only config.conf and report.txt
```

**Step 9**: Show backup chain
```bash
ls -lh backup-*.tar.gz
# Output:
# backup-full-20240115.tar.gz: 2K
# backup-incr-20240116.tar.gz: 1.5K
# backup-incr-20240117.tar.gz: 1K
# Total: 4.5K (vs 2.5K for 3 full backups!)
```

**Step 10**: Restore from backup chain
```bash
mkdir -p restore

# Extract full backup first
tar -xzf backup-full-20240115.tar.gz -C restore/

# Apply day 2 changes
tar -xzf backup-incr-20240116.tar.gz -C restore/

# Apply day 3 changes
tar -xzf backup-incr-20240117.tar.gz -C restore/

# Verify final state
cat restore/data/important/doc1.txt
# Output: Includes Day 2 update
cat restore/data/config.conf
# Output: Updated on Day 3
```

### Expected Output

Backup chain showing:
- Full: 2K
- Incr Day 2: 1.5K
- Incr Day 3: 1K
- Total: 4.5K (40% of 3 full backups)

### Verification Checklist

- [ ] Full backup created successfully
- [ ] Incremental backups contain only changes
- [ ] Incremental files are smaller
- [ ] Backup chain combines correctly
- [ ] Restoration produces current state
- [ ] Only changed files in incremental
- [ ] Timestamp management works

### Cleanup

```bash
cd ~
rm -rf ~/lab5-incremental
```

---

## Lab 6: Multi-Volume Archives

**Goal**: Split large archives into volumes

**Time**: 40 minutes | **Level**: Intermediate

### Setup

```bash
mkdir -p ~/lab6-multivolume
cd ~/lab6-multivolume

# Create data larger than available space
mkdir -p data/large

# Create 50MB of test data
for i in {1..5}; do
  dd if=/dev/zero bs=1M count=10 of=data/large/file-$i.bin 2>/dev/null
done

du -h data/
# Output: 50M
```

### Steps

**Step 1**: Create single large archive
```bash
tar -czf archive-full.tar.gz data/
ls -lh archive-full.tar.gz
# Output: ~15M (compressed from 50M)
```

**Step 2**: Split archive into volumes using split command
```bash
# Create archive and split into 5MB volumes
tar -czf - data/ | split -b 5m - archive-volume-

ls -lh archive-volume-*
# Output:
# archive-volume-aa: 5M
# archive-volume-ab: 5M
# archive-volume-ac: 5M
# archive-volume-ad: 2M (remainder)
```

**Step 3**: Verify volumes
```bash
ls -la archive-volume-* | awk '{print $9, $5}'
# Output:
# archive-volume-aa 5242880
# archive-volume-ab 5242880
# archive-volume-ac 5242880
# archive-volume-ad 2097152
```

**Step 4**: Combine volumes and extract
```bash
mkdir restore-multivolume
cat archive-volume-* | tar -xzf - -C restore-multivolume/

ls -la restore-multivolume/data/large/
# Output: All 5 files restored
```

**Step 5**: Calculate space savings
```bash
echo "Single archive:"
ls -lh archive-full.tar.gz | awk '{print $5}'

echo "Volume set:"
du -h archive-volume-* | tail -1

echo "Savings over 3 full backups:"
du -h data/ | awk '{print "Original: " $1}'
```

**Step 6**: Simulate losing a volume
```bash
# Remove middle volume
rm archive-volume-ac

# Try to restore (should fail)
cat archive-volume-* | tar -xzf - -C /tmp/test 2>&1 | head -5
# Output: Error messages
```

**Step 7**: Create volume with different names
```bash
# Split with sequential numbers
tar -czf - data/ | split -b 5m -d - archive-vol-

ls archive-vol-*
# Output:
# archive-vol-00
# archive-vol-01
# archive-vol-02
# archive-vol-03
```

**Step 8**: Document volume information
```bash
cat > volume-manifest.txt << 'EOF'
Archive: data-backup-20240115
Total volumes: 4
Compression: gzip
Date: 2024-01-15

Volume 1: archive-volume-aa (5MB)
Volume 2: archive-volume-ab (5MB)
Volume 3: archive-volume-ac (5MB)
Volume 4: archive-volume-ad (2MB)

To restore:
cat archive-volume-* | tar -xzf -
EOF

cat volume-manifest.txt
```

### Expected Output

4 volume files (aa, ab, ac, ad) totaling 17MB (compressed)

### Verification Checklist

- [ ] Full archive created (15MB)
- [ ] Split into volumes (5MB each)
- [ ] 4 volumes created (aa, ab, ac, ad)
- [ ] Last volume is remainder (2MB)
- [ ] Volumes combine correctly
- [ ] Extraction from volumes works
- [ ] Files are restored completely
- [ ] Manifest document created

### Cleanup

```bash
cd ~
rm -rf ~/lab6-multivolume
```

---

## Lab 7: Automated Backup

**Goal**: Create production backup script

**Time**: 35 minutes | **Level**: Advanced

### Setup

```bash
mkdir -p ~/lab7-automated
cd ~/lab7-automated

# Create data to backup
mkdir -p data/{important,configs,logs}
echo "Important file" > data/important/file.txt
echo "Config setting" > data/configs/app.conf
echo "Log entry" > data/logs/app.log

# Create backup directory
mkdir -p backups
```

### Steps

**Step 1**: Create simple daily backup script
```bash
cat > simple-backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d)
ARCHIVE="$BACKUP_DIR/backup-$DATE.tar.gz"

# Create backup
tar -czf "$ARCHIVE" data/

# Report status
echo "Backup created: $ARCHIVE"
ls -lh "$ARCHIVE"
EOF

chmod +x simple-backup.sh
```

**Step 2**: Run backup script
```bash
./simple-backup.sh
# Output:
# Backup created: backups/backup-20240115.tar.gz
# -rw-r--r-- 1 user user 500 backups/backup-20240115.tar.gz
```

**Step 3**: Create backup with verification
```bash
cat > backup-with-verify.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d)
ARCHIVE="$BACKUP_DIR/backup-$DATE.tar.gz"

# Create backup
tar -czf "$ARCHIVE" data/ || { echo "Backup failed"; exit 1; }

# Verify
if tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
  echo "✓ Backup verified: $ARCHIVE"
  
  # Create checksum
  cd "$BACKUP_DIR"
  sha256sum "backup-$DATE.tar.gz" > "backup-$DATE.tar.gz.sha256"
  cd ..
else
  echo "✗ Backup corrupted"
  rm "$ARCHIVE"
  exit 1
fi
EOF

chmod +x backup-with-verify.sh
./backup-with-verify.sh
```

**Step 4**: Create incremental backup script
```bash
cat > backup-incremental.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="backups"
TIMESTAMP_FILE="$BACKUP_DIR/.last-backup"
DATE=$(date +%Y%m%d)

# Determine if full or incremental
if [ ! -f "$TIMESTAMP_FILE" ]; then
  TYPE="full"
  ARCHIVE="$BACKUP_DIR/full-$DATE.tar.gz"
  tar -czf "$ARCHIVE" data/
else
  TYPE="incr"
  ARCHIVE="$BACKUP_DIR/incr-$DATE.tar.gz"
  tar -czf "$ARCHIVE" \
    --newer-mtime-than="$TIMESTAMP_FILE" \
    data/
fi

# Update timestamp
touch "$TIMESTAMP_FILE"

echo "✓ $TYPE backup created: $ARCHIVE"
ls -lh "$ARCHIVE"
EOF

chmod +x backup-incremental.sh
./backup-incremental.sh
```

**Step 5**: Create backup with cleanup
```bash
cat > backup-with-cleanup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d)
ARCHIVE="$BACKUP_DIR/backup-$DATE.tar.gz"
KEEP_DAYS=7

# Create backup
tar -czf "$ARCHIVE" data/ || exit 1

# Verify
tar -tzf "$ARCHIVE" > /dev/null || { rm "$ARCHIVE"; exit 1; }

# Remove old backups (older than 7 days)
find "$BACKUP_DIR" -name "backup-*.tar.gz" -mtime +$KEEP_DAYS -delete

echo "✓ Backup: $ARCHIVE"
echo "Retention: Keep last $KEEP_DAYS days"
EOF

chmod +x backup-with-cleanup.sh
./backup-with-cleanup.sh
```

**Step 6**: Create cron-style script
```bash
cat > backup-cron.sh << 'EOF'
#!/bin/bash
# Run as cron job: 0 2 * * * /path/to/backup-cron.sh

BACKUP_DIR="/backups"
LOG_FILE="$BACKUP_DIR/backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

{
  echo "=== Backup started $DATE ==="
  
  tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d).tar.gz" /home /etc || \
    { echo "ERROR: Backup failed"; exit 1; }
  
  # Cleanup old backups
  find "$BACKUP_DIR" -name "backup-*.tar.gz" -mtime +30 -delete
  
  echo "✓ Backup completed"
  echo "Available backups:"
  ls -lh "$BACKUP_DIR"/backup-*.tar.gz | tail -3
} | tee -a "$LOG_FILE"
EOF

chmod +x backup-cron.sh
```

**Step 7**: List all backups
```bash
ls -lh backups/
# Output: Shows all backup files created
```

**Step 8**: Create backup report
```bash
cat > backup-report.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="backups"

echo "=== Backup Report ==="
echo "Generated: $(date)"
echo ""
echo "Available backups:"
ls -lh "$BACKUP_DIR"/backup-*.tar.gz | awk '{print $5, $9}' | column -t

echo ""
echo "Total backup storage:"
du -h "$BACKUP_DIR"

echo ""
echo "Recent backup verification:"
for archive in $(ls -t "$BACKUP_DIR"/backup-*.tar.gz | head -1); do
  if tar -tzf "$archive" > /dev/null 2>&1; then
    echo "✓ $archive: OK"
  else
    echo "✗ $archive: CORRUPTED"
  fi
done
EOF

chmod +x backup-report.sh
./backup-report.sh
```

### Expected Output

Multiple backup scripts created, demonstrating various techniques

### Verification Checklist

- [ ] Simple backup script works
- [ ] Backup with verification works
- [ ] Incremental script works
- [ ] Cleanup removes old backups
- [ ] Cron-ready script created
- [ ] Report script shows status
- [ ] Checksum created and verified
- [ ] Timestamp management working

### Cleanup

```bash
cd ~
rm -rf ~/lab7-automated
```

---

## Lab 8: Archive Recovery and Troubleshooting

**Goal**: Handle corrupted archives and recovery procedures

**Time**: 40 minutes | **Level**: Advanced

### Setup

```bash
mkdir -p ~/lab8-recovery
cd ~/lab8-recovery

# Create test data
mkdir -p data/{important,config}
echo "Important data" > data/important/critical.txt
echo "Config content" > data/config/app.conf

# Create archives for testing
tar -czf good-archive.tar.gz data/
tar -czf backup1.tar.gz data/
tar -czf backup2.tar.gz data/
```

### Steps

**Step 1**: Verify healthy archive
```bash
echo "Testing good archive..."
tar -tzf good-archive.tar.gz > /dev/null
echo "Archive status: OK"

tar -tzf good-archive.tar.gz
# Output: All files listed successfully
```

**Step 2**: Create intentionally corrupted archive
```bash
# Copy archive and corrupt it
cp good-archive.tar.gz corrupted-archive.tar.gz

# Corrupt some bytes
dd if=/dev/zero of=corrupted-archive.tar.gz bs=1 count=100 seek=5000 conv=notrunc 2>/dev/null

echo "Corrupted archive created"
```

**Step 3**: Test corrupted archive
```bash
echo "Testing corrupted archive..."
tar -tzf corrupted-archive.tar.gz 2>&1 | head -10
# Output: Error messages about corruption
```

**Step 4**: Attempt recovery from corrupted archive
```bash
# Try to extract what we can
mkdir -p recover-attempt
tar -xzf corrupted-archive.tar.gz -C recover-attempt/ 2>&1 | head -5
# Output: Error messages, but may extract partial data

ls -la recover-attempt/
# Output: May show partial restoration
```

**Step 5**: Create partially downloaded archive simulation
```bash
# Get size of complete archive
SIZE=$(stat -c%s good-archive.tar.gz 2>/dev/null || stat -f%z good-archive.tar.gz)

# Create truncated copy (simulate incomplete download)
HALF_SIZE=$((SIZE / 2))
dd if=good-archive.tar.gz of=partial-archive.tar.gz bs=1 count=$HALF_SIZE 2>/dev/null

echo "Partial archive created (${HALF_SIZE} bytes)"
```

**Step 6**: Test partial archive
```bash
tar -tzf partial-archive.tar.gz 2>&1 | tail -5
# Output: Shows how far it got before truncation
```

**Step 7**: Use checksums for verification strategy
```bash
# Create good archive with checksum
sha256sum good-archive.tar.gz > archive.sha256

echo "Checksum file created:"
cat archive.sha256

# Later, verify
sha256sum -c archive.sha256
# Output: archive.tar.gz: OK

# Verify corrupted archive fails
sha256sum -c archive.sha256 < corrupted-archive.tar.gz 2>&1 || \
  echo "Checksum mismatch detected"
```

**Step 8**: Implement recovery strategy
```bash
cat > recovery-plan.sh << 'EOF'
#!/bin/bash

# Recovery procedure for corrupted backup

ARCHIVE="$1"

if [ ! -f "$ARCHIVE" ]; then
  echo "Archive not found: $ARCHIVE"
  exit 1
fi

echo "=== Archive Recovery Procedure ==="
echo "Archive: $ARCHIVE"
echo ""

# Step 1: Test archive
echo "Step 1: Testing archive integrity..."
if tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
  echo "✓ Archive is intact"
  exit 0
else
  echo "✗ Archive appears corrupted"
fi

echo ""
echo "Step 2: Attempting partial recovery..."
mkdir -p recovery-temp
tar -xzf "$ARCHIVE" -C recovery-temp/ 2>&1 | head -5

echo ""
echo "Step 3: Files recovered:"
find recovery-temp -type f | head -10

echo ""
echo "Recovered files in: recovery-temp/"
EOF

chmod +x recovery-plan.sh
./recovery-plan.sh corrupted-archive.tar.gz
```

**Step 9**: Create backup rotation strategy
```bash
cat > backup-rotation.sh << 'EOF'
#!/bin/bash

# Implement 3-backup rotation for safety

BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

DATE=$(date +%Y%m%d)
NEW_BACKUP="$BACKUP_DIR/backup-$DATE.tar.gz"

# Create new backup
tar -czf "$NEW_BACKUP" data/ || exit 1

# Verify
tar -tzf "$NEW_BACKUP" > /dev/null || { rm "$NEW_BACKUP"; exit 1; }

# Keep last 3 successful backups
ls -1t "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null | tail -n +4 | xargs rm -f

echo "Backups in rotation:"
ls -lh "$BACKUP_DIR"/backup-*.tar.gz | awk '{print $9, $5}'
EOF

chmod +x backup-rotation.sh
```

**Step 10**: Test disaster recovery scenario
```bash
echo "Simulating disaster recovery..."

# Assume main data is lost
rm -rf data/

# List available backups
echo "Available backups for recovery:"
ls -lh *.tar.gz

# Restore from backup
mkdir -p restore-after-disaster
tar -xzf good-archive.tar.gz -C restore-after-disaster/

echo "Data restored to restore-after-disaster/"
ls -la restore-after-disaster/
```

### Expected Output

Recovery procedures demonstrated with corrupted, partial, and complete archives

### Verification Checklist

- [ ] Healthy archive verifies successfully
- [ ] Corrupted archive detected
- [ ] Partial data recoverable from corrupted archive
- [ ] Truncated archive handling works
- [ ] Checksum verification works
- [ ] Recovery procedure documented
- [ ] 3-backup rotation implemented
- [ ] Disaster recovery tested successfully

### Cleanup

```bash
cd ~
rm -rf ~/lab8-recovery
```

---

## Summary

After completing all 8 labs, you should be able to:

✅ **Create archives** in tar, zip, and compressed formats  
✅ **Extract and restore** from various archive types  
✅ **Compare compression** algorithms and choose appropriately  
✅ **Use advanced tar options** for selective archiving  
✅ **Implement incremental backups** for efficient storage  
✅ **Handle multi-volume archives** for large data  
✅ **Automate backup procedures** with scripts  
✅ **Recover from corruption** and plan disaster recovery  

---

**Next**: Review [scripts/](scripts/) for production automation tools.
