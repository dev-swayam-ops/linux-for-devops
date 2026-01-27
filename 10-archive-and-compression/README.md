# Module 10: Archive and Compression

## What You'll Learn

- Understand tar, gzip, bzip2, and zip tools
- Create archives with different compression levels
- Extract files selectively from archives
- Implement backup strategies
- Understand compression algorithms
- Verify archive integrity
- Work with compressed backups

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Understanding of file systems and storage
- Basic file management skills

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Archive** | Container holding multiple files (tar) |
| **Compression** | Reduce file size (gzip, bzip2, xz) |
| **Tar** | Tape archive - groups files together |
| **gzip** | Fast compression (gz extension) |
| **bzip2** | Better compression (bz2 extension) |
| **zip** | Universal archive + compress format |
| **Extract** | Decompress and unpack files |
| **Integrity** | Verify archive not corrupted |

## Hands-on Lab: Create, Compress, and Extract Archives

### Lab Objective
Create archives with different compressions and verify integrity.

### Commands

```bash
# Create tar archive (no compression)
tar -cvf archive.tar file1.txt file2.txt directory/

# Create compressed archive (gzip - fast)
tar -czvf archive.tar.gz /path/to/files

# Create with bzip2 (better compression)
tar -cjvf archive.tar.bz2 /path/to/files

# List archive contents
tar -tzf archive.tar.gz

# Extract archive
tar -xzvf archive.tar.gz

# Extract to specific directory
tar -xzvf archive.tar.gz -C /target/directory

# Extract single file
tar -xzvf archive.tar.gz path/to/single/file

# Create zip archive
zip -r backup.zip directory/

# Extract zip
unzip backup.zip

# Compress single file with gzip
gzip largefile.txt
# Creates: largefile.txt.gz

# Decompress gzip
gunzip largefile.txt.gz

# Test archive integrity
tar -tzf archive.tar.gz > /dev/null && echo "Valid"

# Show compression info
ls -lh archive.* | awk '{print $5, $9}'

# Create backup with timestamp
tar -czvf backup_$(date +%Y%m%d).tar.gz /important/directory
```

### Expected Output

```
# tar -cvf output:
a file1.txt
a file2.txt
a directory/
a directory/file3.txt

# ls -lh output:
-rw-r--r-- 524M backup.tar
-rw-r--r-- 125M backup.tar.gz
-rw-r--r--  98M backup.tar.bz2

# tar -tzf output:
directory/
directory/file1.txt
```

## Validation

Confirm successful completion:

- [ ] Created tar archive
- [ ] Created compressed archive (gzip/bzip2)
- [ ] Listed archive contents
- [ ] Extracted archive successfully
- [ ] Verified archive integrity
- [ ] Tested with different compression levels

## Cleanup

```bash
# Remove test archives
rm -f archive.tar* backup.zip

# Clean extracted files
rm -rf extracted_directory
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Wrong tar options | Remember: c=create, x=extract, v=verbose, f=file |
| Forgetting compression flag | Add z for gzip, j for bzip2 |
| Extracting to wrong location | Use `-C /path` to specify extraction directory |
| Can't extract: no permission | Check file ownership, use sudo if needed |
| Archive corrupted | Test before relying: `tar -tzf` |

## Troubleshooting

**Q: What's the difference between gzip and bzip2?**
A: gzip = faster, bzip2 = better compression ratio. Choose based on speed vs space.

**Q: How do I extract single file from archive?**
A: `tar -xzvf archive.tar.gz path/to/file`.

**Q: How do I verify archive integrity?**
A: Use `tar -tzf archive.tar.gz > /dev/null && echo "Valid"`.

**Q: Should I use tar or zip?**
A: tar+gzip = Unix/Linux standard. zip = Windows compatible.

**Q: How do I check compression ratio?**
A: Compare original vs compressed: `ls -lh file* | awk '{print $5}'`.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Implement automated backup scripts
3. Test disaster recovery procedures
4. Learn incremental backups
5. Study backup retention policies
