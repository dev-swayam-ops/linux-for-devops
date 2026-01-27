# Archive and Compression: Exercises

Complete these exercises to master archiving and compression.

## Exercise 1: Create Basic Archives

**Tasks:**
1. Create tar archive without compression
2. Show archive contents
3. Check file sizes (original vs archive)
4. Create tar with verbose output
5. Understand tar file structure

**Hint:** Use `tar -cvf`, `tar -tvf`, `ls -lh`.

---

## Exercise 2: Gzip Compression

**Tasks:**
1. Create tar with gzip compression
2. Compare size: tar vs tar.gz
3. Show compression ratio
4. Create with different compression levels
5. Understand gzip limitations

**Hint:** Use `tar -czvf`, `-z`, `ls -lh`, `du -sh`.

---

## Exercise 3: Bzip2 Compression

**Tasks:**
1. Create tar with bzip2
2. Compare: gzip vs bzip2 sizes
3. Compare: compression time
4. Create with max compression (bzip2 -9)
5. When to use bzip2

**Hint:** Use `tar -cjvf`, `time tar`, `stat`.

---

## Exercise 4: Extract Archives

**Tasks:**
1. Extract tar.gz to current directory
2. Extract to specific location (-C)
3. Extract single file from archive
4. Show extraction progress
5. Verify extracted files

**Hint:** Use `tar -xzvf`, `-C`, `-x`, `diff`.

---

## Exercise 5: List and Search Archives

**Tasks:**
1. List all files in archive
2. Search for specific file in archive
3. Show file sizes within archive
4. Find large files before extracting
5. Check archive without extracting

**Hint:** Use `tar -tzf`, `tar -tzf | grep`.

---

## Exercise 6: Zip Archives

**Tasks:**
1. Create zip archive (recursive)
2. List zip contents
3. Extract zip files
4. Create zip with password
5. Compare zip vs tar.gz

**Hint:** Use `zip -r`, `unzip -l`, `unzip -p`.

---

## Exercise 7: Verify Archive Integrity

**Tasks:**
1. Test tar.gz integrity
2. Test zip integrity
3. Create script to verify
4. Detect corrupted archives
5. Understand checksum verification

**Hint:** Use `tar -tzf > /dev/null`, `unzip -t`, `md5sum`.

---

## Exercise 8: Backup Complete Directories

**Tasks:**
1. Create timestamped backup
2. Include exclude patterns
3. Create full backup script
4. Verify backup completeness
5. Test restore procedure

**Hint:** Use `date +%Y%m%d`, `--exclude`, tar with variables.

---

## Exercise 9: Work with Compressed Files

**Tasks:**
1. Compress single file with gzip
2. Decompress with gunzip
3. View compressed file contents without extracting
4. Compress with xz (better ratio)
5. Compare all compression methods

**Hint:** Use `gzip`, `gunzip`, `zcat`, `xz`.

---

## Exercise 10: Create Automated Backup Strategy

Create realistic backup workflow.

**Tasks:**
1. Design backup schedule
2. Create backup script
3. Implement retention policy
4. Test recovery procedure
5. Document backup strategy

**Hint:** Combine tar, cron, timestamps, logging.
