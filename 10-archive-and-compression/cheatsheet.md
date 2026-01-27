# Archive and Compression: Cheatsheet

## Tar Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -cvf archive.tar files` | Create tar | `tar -cvf backup.tar *.txt` |
| `tar -tvf archive.tar` | List contents | `tar -tvf backup.tar` |
| `tar -xvf archive.tar` | Extract all | `tar -xvf backup.tar` |
| `tar -xvf archive.tar file` | Extract one | `tar -xvf backup.tar file.txt` |
| `tar -xvf archive.tar -C /path` | Extract to path | `tar -xvf backup.tar -C /tmp` |

## Compression Options

| Option | Compression | Speed | Ratio |
|--------|-------------|-------|-------|
| `-z` | gzip (.gz) | Fast | Good |
| `-j` | bzip2 (.bz2) | Medium | Better |
| `-J` | xz (.xz) | Slow | Best |
| (none) | uncompressed | Instant | None |

## Tar with Compression

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -czvf archive.tar.gz files` | Create gzip archive | `tar -czvf backup.tar.gz /home` |
| `tar -cjvf archive.tar.bz2 files` | Create bzip2 archive | `tar -cjvf backup.tar.bz2 /home` |
| `tar -cJvf archive.tar.xz files` | Create xz archive | `tar -cJvf backup.tar.xz /home` |
| `tar -xzvf archive.tar.gz` | Extract gzip | `tar -xzvf backup.tar.gz` |
| `tar -xjvf archive.tar.bz2` | Extract bzip2 | `tar -xjvf backup.tar.bz2` |
| `tar -xJvf archive.tar.xz` | Extract xz | `tar -xJvf backup.tar.xz` |

## Tar Options

| Option | Meaning |
|--------|---------|
| `-c` | Create archive |
| `-x` | Extract archive |
| `-t` | List contents |
| `-v` | Verbose (show files) |
| `-f` | File (specify filename) |
| `-C` | Change directory |
| `--exclude` | Skip pattern |
| `-z` | gzip compression |
| `-j` | bzip2 compression |
| `-J` | xz compression |

## Gzip Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `gzip file` | Compress file | `gzip largefile.txt` |
| `gunzip file.gz` | Decompress | `gunzip largefile.txt.gz` |
| `zcat file.gz` | View compressed | `zcat file.txt.gz` |
| `zless file.gz` | Page through | `zless file.txt.gz` |
| `gzip -1 file` | Fast compress | `gzip -1 file` |
| `gzip -9 file` | Best compress | `gzip -9 file` |

## Zip Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `zip archive.zip files` | Create zip | `zip backup.zip file1 file2` |
| `zip -r archive.zip dir` | Recursive zip | `zip -r backup.zip /home` |
| `zip -e archive.zip files` | Encrypt zip | `zip -e backup.zip files` |
| `unzip archive.zip` | Extract all | `unzip backup.zip` |
| `unzip -l archive.zip` | List contents | `unzip -l backup.zip` |
| `unzip -t archive.zip` | Test integrity | `unzip -t backup.zip` |
| `unzip -p archive.zip file` | View file | `unzip -p backup.zip file.txt` |

## Other Compression

| Command | Purpose | Example |
|---------|---------|---------|
| `bzip2 file` | Compress with bzip2 | `bzip2 largefile` |
| `bunzip2 file.bz2` | Decompress bzip2 | `bunzip2 file.bz2` |
| `xz file` | Compress with xz | `xz file` |
| `unxz file.xz` | Decompress xz | `unxz file.xz` |

## Verification and Testing

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -tzf archive.tar.gz` | Test tar.gz | `tar -tzf backup.tar.gz` |
| `unzip -t archive.zip` | Test zip | `unzip -t backup.zip` |
| `file archive` | Show file type | `file backup.tar.gz` |
| `md5sum archive` | Create checksum | `md5sum backup.tar.gz` |
| `md5sum -c checksum.txt` | Verify checksum | `md5sum -c backup.md5` |

## File Size Comparison

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -lh archive*` | Show sizes | `ls -lh backup.*` |
| `du -sh directory` | Directory size | `du -sh /home/user` |
| `du -sh archive.tar*` | Archive comparison | `du -sh backup.tar*` |

## Backup Examples

| Scenario | Command |
|----------|---------|
| Full backup | `tar -czvf backup_$(date +%Y%m%d).tar.gz /home` |
| Exclude logs | `tar -czvf backup.tar.gz --exclude="*.log" /home` |
| Exclude cache | `tar -czvf backup.tar.gz --exclude=".cache" /home` |
| Multiple excludes | `tar -czvf backup.tar.gz --exclude=".cache" --exclude="*.log" /home` |
| Incremental | `tar -czvf backup.tar.gz --newer-mtime-than=date_file /home` |

## Compression Algorithm Comparison

| Format | Ratio | Speed | Use Case |
|--------|-------|-------|----------|
| Uncompressed | 0% | Instant | Testing, temporary |
| gzip | 60-70% | Fast | General purpose, backups |
| bzip2 | 55-65% | Medium | Long-term storage |
| xz | 50-60% | Slow | Archival, maximum space |
| zip | 60-70% | Medium | Windows compatibility |

## Common Patterns

```bash
# Backup with timestamp
tar -czvf backup_$(date +%Y%m%d_%H%M%S).tar.gz /path

# Backup excluding patterns
tar -czvf backup.tar.gz \
  --exclude="*.log" \
  --exclude=".cache" \
  --exclude="*.tmp" \
  /source

# Create and verify
tar -czvf backup.tar.gz /source && \
  tar -tzf backup.tar.gz > /dev/null && \
  echo "Backup OK"

# Extract and verify
tar -xzvf backup.tar.gz -C /restore && \
  diff -r /source /restore/source
```
