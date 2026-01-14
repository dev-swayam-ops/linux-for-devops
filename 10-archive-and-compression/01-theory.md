# Theory: Archive and Compression Fundamentals

Understanding archiving and compression is essential for backup strategies, distribution, and storage optimization in Linux systems.

---

## 1. Understanding Archives and Compression

### What Is an Archive?

An **archive** is a single file that contains multiple other files, preserving their directory structure, permissions, and metadata. Archiving is not the same as compression—an archive groups files together, while compression reduces file size.

**Example**: A directory with 100 files and subdirectories becomes a single archive file:

```
/home/user/project/          ->  project-backup.tar
├── src/                          (single archive file)
├── docs/                         
├── config/                       
└── README                        
```

### What Is Compression?

**Compression** is an algorithm that removes redundancy from data to reduce file size. There are two types:

- **Lossless**: All original data is preserved (text, code, databases)
- **Lossy**: Non-essential data is discarded (images, audio, video)

For Linux backups and archiving, we only use **lossless compression**.

### Archive vs. Compression vs. Both

```
┌─────────────────────────────────────────────────┐
│           File Processing Options              │
├─────────────────────────────────────────────────┤
│ Archive only:   Multiple files → Single file   │
│                 No size reduction               │
│                 Tool: tar                       │
├─────────────────────────────────────────────────┤
│ Compress only:  Single file → Smaller file     │
│                 Size reduced                    │
│                 Tool: gzip, bzip2, xz          │
├─────────────────────────────────────────────────┤
│ Archive + Compress: Multiple files → Single,   │
│                     compressed file             │
│                     Both benefits               │
│                     Tool: tar + gzip (tar.gz)  │
└─────────────────────────────────────────────────┘
```

**Key insight**: On Unix/Linux, archiving and compression are separate steps that can be combined:

```bash
tar -cf output.tar input-files              # Archive only
gzip output.tar                             # Compress after
# Result: output.tar.gz

# Or in one step:
tar -czf output.tar.gz input-files          # Archive + compress together
```

---

## 2. Common Compression Algorithms

### Gzip (GNU zip)

**Algorithm**: DEFLATE (LZ77 + Huffman coding)  
**Speed**: Fast (high compression/decompression speed)  
**Compression ratio**: 40-60% of original (typical text files)  
**CPU**: Low  
**Memory**: Low  
**Typical use**: General purpose, web (HTTP compression)  

```
Compression time: Fast
Original: 100MB → Compressed: 40-60MB
Decompression: Very fast
```

**Real example**:
```bash
$ ls -lh large-file.txt
-rw-r--r-- 1 user user 500M large-file.txt

$ gzip large-file.txt

$ ls -lh large-file.txt.gz
-rw-r--r-- 1 user user 180M large-file.txt.gz

# Compression ratio: 180/500 = 36%
```

### Bzip2

**Algorithm**: Burrows-Wheeler Transform  
**Speed**: Slower than gzip  
**Compression ratio**: 50-70% (better than gzip)  
**CPU**: High  
**Memory**: High  
**Typical use**: When storage space is critical  

```
Compression time: Slower
Original: 100MB → Compressed: 30-50MB
Decompression: Slower than gzip
```

**When to use**: Archive storage (not accessed frequently), when every MB counts

### Xz (Lempel-Ziv-Markov chain)

**Algorithm**: LZMA2  
**Speed**: Very slow compression, reasonable decompression  
**Compression ratio**: 60-80% (best compression)  
**CPU**: Very high  
**Memory**: Very high  
**Typical use**: Long-term archival, maximum compression needed  

```
Compression time: Very slow (10-50x slower than gzip)
Original: 100MB → Compressed: 20-40MB
Decompression: Reasonable speed
```

**Example trade-off**:
```
Gzip:  100MB → 40MB in 5 seconds (8MB/sec compression)
Xz:    100MB → 25MB in 120 seconds (0.8MB/sec compression)

# 15MB more compressed, but takes 24x longer
# Worth it for data you compress once and keep for years
```

### Quick Compression Comparison

```
ALGORITHM    SPEED    RATIO    CPU    USE CASE
─────────────────────────────────────────────────
gzip        Very fast 40-60%   Low    General use, backups
bzip2       Slow      50-70%   High   Better compression
xz          V.slow    60-80%   V.High Maximum compression
zip         Fast      40-60%   Low    Cross-platform
brotli      Medium    50-70%   Med    Modern web, JSON
```

**Decision tree**:
```
Need fast compression? → gzip
Need better compression? → bzip2
Need maximum compression? → xz
Need cross-platform? → zip
Compressing for web? → brotli
```

---

## 3. The Tar Archive Format

### What Is Tar?

**TAR** = "Tape ARchive" (named after tape backups, still used today)

Tar is a **streaming archiver**—it reads from standard input and writes to standard output, preserving:

```
✓ File contents
✓ File permissions (755, 644, etc.)
✓ Ownership (user:group)
✓ Directory structure
✓ Modification times
✓ Symlinks
✗ SELinux context (preserved only with special option)
```

### Tar Archive Structure

Inside a tar archive, metadata and file content are organized as:

```
┌──────────────────────────────┐
│ Header Block (512 bytes)     │
│  - Filename                  │
│  - Size                       │
│  - Permissions               │
│  - Owner/Group               │
│  - Modification time         │
├──────────────────────────────┤
│ Data Blocks (file content)   │
│ in 512-byte chunks           │
├──────────────────────────────┤
│ Header Block (next file)     │
├──────────────────────────────┤
│ Data Blocks (next file)      │
├──────────────────────────────┤
│ End marker (zero blocks)     │
└──────────────────────────────┘
```

This simple structure is why tar works reliably even with partial corruption—you can often recover data from damaged archives.

### Tar Options Overview

```
Creation (writing archives):
  -c            Create archive
  -f FILE       Write to FILE (instead of /dev/tape)
  -v            Verbose (show files being added)
  -z            Gzip compress
  -j            Bzip2 compress
  -J            Xz compress

Extraction (reading archives):
  -x            Extract files
  -f FILE       Read from FILE
  -v            Verbose
  -C DIR        Change to DIR before extracting

Inspection (examining archives):
  -t            List contents
  -f FILE       From FILE
  -v            Verbose

Modification:
  -r            Append files to archive
  -u            Update (add if newer)
```

---

## 4. Compression Algorithms in Detail

### How Gzip Works (Simplified)

```
DEFLATE Algorithm = LZ77 (pattern matching) + Huffman (entropy coding)

1. Pattern Matching (LZ77)
   Original: "the quick brown fox jumps over the lazy dog"
   
   "the" appears at position 0
   Whenever "the" appears again, store reference:
   "the quick brown fox jumps over [ref:0,length:3] lazy dog"

2. Huffman Coding
   Count frequency of patterns/bytes:
   - Common patterns → fewer bits
   - Rare patterns → more bits
   
   Common: ' ' (space) → 001
   Rare: 'z' → 11010111

Result: Original 100 bytes → 35 bytes (65% compression)
```

**Why gzip is fast**:
- Simple pattern matching (up to 32KB lookback)
- Minimal memory overhead
- Streaming (processes input sequentially)

### How Bzip2 Works (Simplified)

```
Burrows-Wheeler Transform = Three-stage algorithm

1. Transform (reorganize data)
   Scrambles file so similar bytes cluster together
   
2. Run-length encoding
   "AAAAAABBBCC" → "6A,3B,2C" (compress runs of same character)
   
3. Huffman coding (like gzip)
   Encode compressed sequences

Result: More effective than gzip for text
Original 100 bytes → 30 bytes (70% compression)

Tradeoff: 5-10x slower than gzip
```

**Why bzip2 is better**:
- Burrows-Wheeler transform creates better patterns for compression
- Usually achieves 10-20% smaller files than gzip
- Good for highly repetitive data (logs, source code)

### How Xz Works (Simplified)

```
LZMA2 Algorithm = Very sophisticated pattern matching

1. Complex sliding-window matching
   Lookback: Up to 4GB (vs 32KB for gzip)
   Finds patterns at any distance in file
   
2. Range encoding
   More efficient than Huffman coding
   
3. Filters
   Preprocesses data to improve compressibility
   (e.g., transforms x86 machine code to be more compressible)

Result: Maximum compression
Original 100 bytes → 20 bytes (80% compression)

Tradeoff: 50-100x slower than gzip
```

**Why xz is best**:
- Can find patterns anywhere in file (not just recent history)
- Applies intelligent preprocessing
- Best compression ratio of standard tools
- Worth it when you compress once and decompress many times

---

## 5. Compression Ratio: Theory and Practice

### What Is Compression Ratio?

**Compression ratio** = Original size ÷ Compressed size

```
Example:
Original: 100 MB
Compressed: 40 MB
Ratio: 100 ÷ 40 = 2.5 (or 40% of original)

Also expressed as:
- "2.5:1 ratio"
- "40% compression"
- "60% size reduction"
```

### Factors Affecting Compression Ratio

**1. Data type**:
```
Highly compressible:      Poorly compressible:
- Text files: 40-80%      - JPEG images: 90-95%
- Source code: 30-70%     - MP3 audio: 98-99%
- Logs: 70-90%            - ZIP files: 95%+ (already compressed)
- XML: 80-95%             - Executables: 50-70%
- JSON: 75-90%            - Videos: 95%+
```

**2. Compression algorithm**:
```
Same file, different algorithms:

text-file.txt:
  gzip:   100MB → 40MB (40% original)
  bzip2:  100MB → 35MB (35% original)
  xz:     100MB → 25MB (25% original)
```

**3. Compression level**:
```
gzip -1 (fastest):    100MB → 45MB (fast, less compression)
gzip -6 (default):    100MB → 40MB (balanced)
gzip -9 (maximum):    100MB → 39MB (slow, marginal improvement)

# Level 9 is only 2% better but takes 10x longer—rarely worth it
```

### Real-World Compression Ratios

```
Data Type              Typical Ratio  Tool Used
─────────────────────────────────────────────
Database dumps         40-60%         gzip
Log files              70-90%         gzip
Source code            30-50%         xz
Configuration files    50-80%         bzip2
System backups         30-60%         gzip
Binary executables     50-80%         xz
JSON/XML data          70-90%         bzip2
Already-compressed     95-100%        (no benefit)
```

**Practical example**:
```bash
$ du -sh /var/log/*
2.3G total

# After compression:
tar czf logs-backup.tar.gz /var/log/*
du -sh logs-backup.tar.gz
450M

# Ratio: 450M / 2300M = 19% of original = 81% size reduction
# From 2.3GB to 450MB
```

---

## 6. Archiving Strategies

### Full Backup

**Definition**: Complete backup of all files in selected directories

```
Monday:   Backup all files → full-backup-2024-01-15.tar.gz
Tuesday:  Backup all files → full-backup-2024-01-16.tar.gz
Wednesday: Backup all files → full-backup-2024-01-17.tar.gz
```

**Advantages**:
- Simple to implement
- Easy to restore—have everything
- No dependencies between backups

**Disadvantages**:
- Large backup files
- Slow (backs up unchanged files again)
- High network/storage usage

**When to use**:
- Daily backups for small systems
- Archives that change completely
- Disaster recovery baseline

### Incremental Backup

**Definition**: Backup only files changed since last backup (any type)

```
Monday:   Full backup → all files
Tuesday:  Incremental → only files changed since Monday
Wednesday: Incremental → only files changed since Tuesday
Thursday:  Incremental → only files changed since Wednesday
```

**Storage chain**: To restore to Thursday state, you need Monday + Tuesday + Wednesday + Thursday backups

**Advantages**:
- Smallest backup files
- Fastest backups
- Minimum storage usage
- Best for active systems with frequent changes

**Disadvantages**:
- Requires keeping all intermediate backups
- Restoration is more complex (need multiple files)
- If one backup corrupts, can't restore after that point

**When to use**:
- Production systems with constant changes
- When storage is limited
- When backup time matters (frequent backups)

### Differential Backup

**Definition**: Backup all files changed since last full backup

```
Monday:   Full backup → all files
Tuesday:  Differential → files changed since Monday
Wednesday: Differential → files changed since Monday
Thursday:  Differential → files changed since Monday
Friday:   Full backup → all files
```

**Storage chain**: To restore, you only need the last full backup + the latest differential

**Advantages**:
- Fewer backups needed for restoration (full + latest differential)
- Manageable backup chain
- Good for weekly/monthly schedules

**Disadvantages**:
- Differential files can grow large over time
- Still requires keeping full + differentials

**When to use**:
- Weekly/monthly backup cycles
- Systems with gradual changes
- Good balance between full and incremental

### Strategy Comparison

```
Full backup 500MB daily:
  Week storage: 500M × 7 = 3.5GB

Incremental backup (Mon full, then daily):
  Mon: 500MB (full)
  Tue: 50MB (changed since Mon)
  Wed: 40MB (changed since Tue)
  Thu: 60MB (changed since Wed)
  Fri: 30MB (changed since Thu)
  Sat: 45MB (changed since Fri)
  Sun: 35MB (changed since Sat)
  
  Week storage: 790MB total (77% savings!)
  Restore Friday: Need Mon + Tue + Wed + Thu + Fri (5 files)

Differential backup (Mon full, rest differential from Mon):
  Mon: 500MB (full)
  Tue: 50MB (changed since Mon)
  Wed: 90MB (changed since Mon)
  Thu: 140MB (changed since Mon)
  Fri: 200MB (changed since Mon)
  Sat: 250MB (changed since Mon)
  Sun: 300MB (changed since Mon)
  
  Week storage: 1.53GB total
  Restore Friday: Need Mon + Fri (2 files) ✓ Easier!
```

---

## 7. Archive Verification and Integrity

### Why Verify Archives?

Backups are useless if they're corrupted. Verification catches problems before disaster.

**Common corruption scenarios**:
```
✗ Transmission error: File transferred over network, corrupted in transit
✗ Storage decay: Disk slowly failing, data degrading
✗ Silent corruption: Bit errors that go undetected
✗ Truncation: Transfer stopped mid-way, archive incomplete
✗ Media failure: CD/tape degrading, some blocks unreadable
```

### Verification Methods

**1. List contents (quick check)**:
```bash
tar -tzf archive.tar.gz
# If any errors appear → archive is corrupted
```

**2. Extract with test mode**:
```bash
tar -tzf archive.tar.gz > /dev/null
# Extracts to /dev/null (discards), tests all blocks
```

**3. Checksums**:
```bash
# Create checksum when archiving
tar czf archive.tar.gz /data
sha256sum archive.tar.gz > archive.tar.gz.sha256

# Later, verify
sha256sum -c archive.tar.gz.sha256
# Output: archive.tar.gz: OK
```

**4. Duplicate verification**:
```bash
# Verify by extracting to temporary location and comparing
mkdir /tmp/verify
tar xzf archive.tar.gz -C /tmp/verify
diff -r /tmp/verify/data /original/data
```

### Best Practice: Verify After Creation

```bash
#!/bin/bash
# Safe backup procedure

ARCHIVE="backup-$(date +%Y%m%d).tar.gz"

# Step 1: Create archive
echo "Creating archive..."
tar czf "$ARCHIVE" /data

# Step 2: Verify it worked
echo "Verifying archive..."
if tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
  echo "✓ Archive verified successfully"
  
  # Step 3: Store checksum
  sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"
else
  echo "✗ Archive corrupted!"
  rm "$ARCHIVE"
  exit 1
fi
```

---

## 8. Common Pitfalls and Solutions

### Pitfall 1: Forgetting Compression Option

```bash
# Wrong: Created uncompressed tar (1GB)
tar -cf large-backup.tar /data
ls -lh large-backup.tar
# -rw-r--r-- 1 user user 1.0G large-backup.tar

# Right: Create compressed tar (100-300MB)
tar -czf large-backup.tar.gz /data
ls -lh large-backup.tar.gz
# -rw-r--r-- 1 user user 250M large-backup.tar.gz

# Remember: Add -z for gzip, -j for bzip2, -J for xz
```

### Pitfall 2: Extracting to Wrong Location

```bash
# Wrong: Extracts to current directory, polluting it
cd /tmp
tar xzf /backup/archive.tar.gz
# /tmp now has many new files

# Right: Extract to specific directory
cd /tmp
mkdir extracted
tar xzf /backup/archive.tar.gz -C extracted/

# Or with absolute paths:
tar xzf /backup/archive.tar.gz -C /restore/location/
```

### Pitfall 3: Archive Gets Corrupted During Transfer

```bash
# Wrong: No verification after transfer
scp archive.tar.gz remote-server:/backup/
# Hope it got there intact

# Right: Verify with checksums
sha256sum archive.tar.gz > archive.tar.gz.sha256
scp archive.tar.gz remote-server:/backup/
scp archive.tar.gz.sha256 remote-server:/backup/

# On remote server:
cd /backup
sha256sum -c archive.tar.gz.sha256
```

### Pitfall 4: Choosing Wrong Compression Level

```bash
# Slow compression taking 30 minutes
tar --use-compress-program='xz -9' -cf archive.tar.xz /huge-data
# Only 2% better compression than -6

# Better: Use default compression level (good speed/compression balance)
tar -czf archive.tar.gz /data  # Much faster, 95% as good
```

### Pitfall 5: Losing Old Backups

```bash
# Wrong: Keep rotating backups with same name
tar czf daily-backup.tar.gz /data   # Monday
tar czf daily-backup.tar.gz /data   # Tuesday (overwrites Monday)
tar czf daily-backup.tar.gz /data   # Wednesday (overwrites Tuesday)

# Right: Include date in filename
tar czf daily-backup-$(date +%Y%m%d).tar.gz /data
ls -1 daily-backup-*.tar.gz
# daily-backup-20240115.tar.gz
# daily-backup-20240116.tar.gz
# daily-backup-20240117.tar.gz
```

---

## 9. Performance Considerations

### Compression vs. Decompression Speed

```
Operation          Gzip        Bzip2       Xz
──────────────────────────────────────────────
Compress 1GB       8 seconds   60 seconds  200 seconds
Decompress 1GB     3 seconds   20 seconds  50 seconds

Ratio: Decompression is 2-4x faster than compression
Implication: Slow compression is OK, decompression should be fast
```

**Practical decision**:
```
Compress daily backups:
  10 minutes of compression time is acceptable
  → Can use xz for maximum compression
  → Stored for years, decompressed rarely

Compress for daily use:
  Compression time matters
  → Use gzip (fast)
  → Accept slightly larger files
```

### Parallel Compression

Some compression tools support parallel processing:

```bash
# Pigz: Parallel gzip
pigz -p 4 large-file.txt  # Use 4 CPU cores
# 4x faster on quad-core system

# Pbzip2: Parallel bzip2
pbzip2 -p 4 -cf large-file.txt > large-file.txt.bz2

# Xz: Multi-threaded
xz -T 4 large-file.txt  # Use 4 threads
```

### Memory Usage

```
Tool      Memory Usage    Notes
─────────────────────────────────────
gzip      ~1-4 MB         Very low
bzip2     ~9-30 MB        Depends on block size
xz        ~100-800 MB     Very high with max settings
zip       Varies          Depends on compression
```

**Implication**: On small systems with limited RAM, use gzip instead of xz

---

## 10. Real-World Backup Strategy

### Three-Tier Backup Strategy

```
┌──────────────────────────────────────────────────────┐
│         Complete Backup Strategy                     │
├──────────────────────────────────────────────────────┤
│                                                      │
│ Tier 1: Local Backups (Daily)                       │
│  Location: /backup/daily                            │
│  Type: Incremental                                   │
│  Retention: 7 days                                   │
│  Speed: Very fast (on same system)                  │
│  Recovery time: Minutes                             │
│  Use: Day-to-day file recovery                      │
│                                                      │
│ Tier 2: Weekly Full Backup (Remote)                │
│  Location: Backup server (different building)      │
│  Type: Full backup                                  │
│  Retention: 4 weeks                                 │
│  Speed: Slower (network transfer)                  │
│  Recovery time: Hours                               │
│  Use: Disaster recovery, 1-month history           │
│                                                      │
│ Tier 3: Monthly Archive (Off-site)                 │
│  Location: Off-site location or cloud              │
│  Type: Full backup                                 │
│  Retention: 12 months                               │
│  Speed: Very slow (long-distance transfer)         │
│  Recovery time: Days                                │
│  Use: Long-term archival, compliance                |
│                                                      │
└──────────────────────────────────────────────────────┘
```

**Implementation**:
```bash
# Local daily incremental (runs at 2 AM)
tar czf /backup/daily/full-$(date +%Y%m%d).tar.gz \
  --newer-mtime-than=/backup/daily/.timestamp /data
touch /backup/daily/.timestamp

# Weekly full backup to remote (runs Sunday 3 AM)
tar czf /tmp/weekly-backup.tar.gz /data
rsync -v /tmp/weekly-backup.tar.gz backup-server:/backups/

# Monthly archive to off-site (runs 1st of month)
tar czf /tmp/monthly-archive.tar.gz /data
aws s3 cp /tmp/monthly-archive.tar.gz s3://compliance-backups/
```

---

## Summary

Key takeaways from compression and archiving theory:

1. **Archive** = group files; **Compress** = reduce size
2. Choose compression based on your needs:
   - Fast: gzip (general purpose)
   - Better: bzip2 (when space matters)
   - Best: xz (for long-term storage)
3. Use tar for preserving permissions and structure
4. Always verify backups before relying on them
5. Implement multi-tier backup strategy
6. Automate to ensure consistency

---

**Next**: Read [02-commands-cheatsheet.md](02-commands-cheatsheet.md) for practical command examples.
