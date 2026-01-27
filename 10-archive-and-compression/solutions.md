# Archive and Compression: Solutions

## Exercise 1: Create Basic Archives

**Solution:**

```bash
# Create tar archive without compression
tar -cvf myarchive.tar file1.txt file2.txt directory/
# Output: a file1.txt, a file2.txt, a directory/, ...

# Show archive contents
tar -tvf myarchive.tar
# Output:
# -rw-r--r-- 0 user group    1234 Jan 20 10:30 file1.txt
# drwxr-xr-x 0 user group       0 Jan 20 10:30 directory/

# Check file sizes
ls -lh file1.txt file2.txt
# Original: 500M total

ls -lh myarchive.tar
# Archive: 500M (same - no compression)

# Create with verbose output (already shown above)
tar -cvf archive.tar *

# Understanding tar structure
file myarchive.tar
# Output: POSIX tar archive
```

**Explanation:** `tar -cvf` = create, verbose, file. No compression flag = uncompressed.

---

## Exercise 2: Gzip Compression

**Solution:**

```bash
# Create tar with gzip
tar -czvf myarchive.tar.gz directory/
# Output: a directory/, a directory/file1.txt, ...

# Compare sizes
ls -lh myarchive.tar*
# Output:
# -rw-r--r-- 500M myarchive.tar
# -rw-r--r-- 125M myarchive.tar.gz
# Compression ratio: 75% reduction

# Show compression ratio
du -sh myarchive.tar myarchive.tar.gz
# Output: 500M, 125M

# Different compression levels (1-9, default 6)
tar -czvf --compression-level=1 fast.tar.gz directory/
# Faster but larger

tar -czvf --compression-level=9 best.tar.gz directory/
# Slower but smaller

# Compare compression time
time tar -czvf archive.tar.gz directory/
# Shows elapsed time
```

**Explanation:** `-z` = gzip. Default compression level 6. Higher = smaller but slower.

---

## Exercise 3: Bzip2 Compression

**Solution:**

```bash
# Create tar with bzip2
tar -cjvf myarchive.tar.bz2 directory/
# Output: similar to gzip

# Compare sizes: gzip vs bzip2
ls -lh myarchive.tar.*
# Output:
# myarchive.tar.gz  125M (gzip)
# myarchive.tar.bz2  95M (bzip2 - better)

# Compare compression time
time tar -czvf archive.tar.gz directory/
# real 0m12.345s (gzip - faster)

time tar -cjvf archive.tar.bz2 directory/
# real 0m45.678s (bzip2 - slower)

# Maximum compression bzip2
tar -cjvf --compression-level=9 best.tar.bz2 directory/

# When to use:
# gzip: when speed matters, network backups
# bzip2: when storage space critical, archival
```

**Explanation:** bzip2 = 10-15% better ratio but 3-4x slower than gzip.

---

## Exercise 4: Extract Archives

**Solution:**

```bash
# Extract to current directory
tar -xzvf myarchive.tar.gz
# Output: x directory/, x directory/file1.txt, ...

# Extract to specific location
tar -xzvf myarchive.tar.gz -C /tmp/restore/
# Creates /tmp/restore/directory/file1.txt

# Extract single file
tar -xzvf myarchive.tar.gz path/to/file.txt
# Only extracts that one file

# Show extraction progress (already verbose above)
tar -xzvf myarchive.tar.gz | wc -l
# Shows count of extracted files

# Verify extracted files match original
diff -r original_directory/ /tmp/restore/directory/
# No output = identical
```

**Explanation:** `-x` = extract. `-C` = change to directory. Verbose shows each file.

---

## Exercise 5: List and Search Archives

**Solution:**

```bash
# List all files
tar -tzf myarchive.tar.gz
# Output:
# directory/
# directory/file1.txt
# directory/file2.txt

# Search for specific file
tar -tzf myarchive.tar.gz | grep "\.txt$"
# Output: directory/file1.txt, directory/file2.txt

# Show file sizes within archive
tar -tzvf myarchive.tar.gz | awk '{print $3, $6}' | head
# Output: 1024 file1.txt, 2048 file2.txt

# Find large files before extracting
tar -tzvf myarchive.tar.gz | sort -k3 -nr | head
# Shows largest files first

# Check archive without extracting
tar -tzf myarchive.tar.gz > /dev/null
# No output = valid archive
```

**Explanation:** `-t` = list contents. `-z` = gzip format. No extraction happens.

---

## Exercise 6: Zip Archives

**Solution:**

```bash
# Create recursive zip
zip -r myarchive.zip directory/
# Output: adding: directory/, directory/file.txt, ...

# List zip contents
unzip -l myarchive.zip
# Output:
# Archive: myarchive.zip
#   Length      Date    Time    Name
#      1024  01-20-25  10:30   directory/
#      2048  01-20-25  10:30   directory/file1.txt

# Extract zip
unzip myarchive.zip
# Output: Archive: myarchive.zip, extracting: directory/

# Create with password (encrypted)
zip -re myarchive_secure.zip directory/
# Prompts for password

# Compare sizes: zip vs tar.gz
ls -lh myarchive.zip myarchive.tar.gz
# Often similar or slightly larger

# Use cases:
# zip: Windows compatibility, email attachments
# tar.gz: Linux/Unix standard, better for backups
```

**Explanation:** `zip -r` = recursive. `-e` = encrypt. `unzip` = extract.

---

## Exercise 7: Verify Archive Integrity

**Solution:**

```bash
# Test tar.gz integrity
tar -tzf myarchive.tar.gz > /dev/null && echo "Valid" || echo "Corrupted"
# Output: Valid

# Test zip integrity
unzip -t myarchive.zip
# Output: testing: directory/file1.txt OK

# Create verification script
#!/bin/bash
ARCHIVE=$1
if file "$ARCHIVE" | grep -q "gzip"; then
  tar -tzf "$ARCHIVE" > /dev/null && echo "$ARCHIVE: OK"
elif file "$ARCHIVE" | grep -q "Zip"; then
  unzip -t "$ARCHIVE" > /dev/null && echo "$ARCHIVE: OK"
fi

# Run script
./verify_archive.sh myarchive.tar.gz

# Checksum verification
md5sum myarchive.tar.gz > checksum.txt
md5sum -c checksum.txt
# Output: myarchive.tar.gz: OK
```

**Explanation:** Redirection to `/dev/null` suppresses output. Exit code 0 = valid.

---

## Exercise 8: Backup Complete Directories

**Solution:**

```bash
# Create timestamped backup
tar -czvf backup_$(date +%Y%m%d_%H%M%S).tar.gz /home/user/documents/

# Exclude patterns
tar -czvf backup.tar.gz \
  --exclude="*.log" \
  --exclude=".cache" \
  /home/user/

# Full backup script
#!/bin/bash
BACKUP_DIR="/backups"
SOURCE="/home/user"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE="$BACKUP_DIR/backup_$DATE.tar.gz"

mkdir -p $BACKUP_DIR
tar -czvf $ARCHIVE \
  --exclude=".cache" \
  --exclude="*.tmp" \
  "$SOURCE" && echo "Backup succeeded" || echo "Backup failed"

# Verify completeness
tar -tzf backup_20250120_120000.tar.gz | wc -l
# Shows file count

# Test restore
mkdir -p /tmp/test_restore
tar -xzvf backup_20250120_120000.tar.gz -C /tmp/test_restore/
diff -r /home/user /tmp/test_restore/home/user
```

**Explanation:** `$(date)` = timestamp. `--exclude` = skip patterns. Verify before relying.

---

## Exercise 9: Work with Compressed Files

**Solution:**

```bash
# Compress single file
gzip largefile.txt
# Creates: largefile.txt.gz, removes original

# Decompress
gunzip largefile.txt.gz
# Creates: largefile.txt, removes .gz

# View without extracting
zcat largefile.txt.gz | head
# Shows first 10 lines

# Or use zless
zless largefile.txt.gz

# Compress with xz (better ratio)
tar -cf - directory/ | xz > archive.tar.xz
# Better compression but slower

# Compare all methods
ls -lh archive.tar*
# Output:
# archive.tar      500M (no compression)
# archive.tar.gz   125M (gzip)
# archive.tar.bz2   95M (bzip2)
# archive.tar.xz    85M (xz - best)

# Trade-offs:
# Speed: gzip > bzip2 > xz
# Ratio: xz > bzip2 > gzip
```

**Explanation:** `zcat` = cat compressed. `xz` = best compression but slowest.

---

## Exercise 10: Create Automated Backup Strategy

**Solution:**

```bash
# Design: Daily backups, keep 7 days
# Location: /backups
# Schedule: 2:00 AM daily

# Backup script
#!/bin/bash
BACKUP_DIR="/backups"
SOURCE="/home/user /etc /var/www"
KEEP_DAYS=7
DATE=$(date +%Y%m%d)

# Create backup
tar -czvf $BACKUP_DIR/backup_$DATE.tar.gz $SOURCE 2>> $BACKUP_DIR/backup.log

# Retention policy: delete files older than 7 days
find $BACKUP_DIR -name "backup_*.tar.gz" -mtime +$KEEP_DAYS -delete

# Log result
echo "$(date): Backup completed, size: $(du -sh $BACKUP_DIR | cut -f1)" >> $BACKUP_DIR/backup.log

# Add to crontab
# 0 2 * * * /scripts/backup.sh

# Test recovery
mkdir -p /tmp/test_restore
tar -xzvf $BACKUP_DIR/backup_$DATE.tar.gz -C /tmp/test_restore/

# Verify: compare file counts
find /home/user -type f | wc -l
# Original count

find /tmp/test_restore/home/user -type f | wc -l
# Restored count (should match)
```

**Explanation:** Retention = automatic cleanup. Test recovery regularly. Log for monitoring.
