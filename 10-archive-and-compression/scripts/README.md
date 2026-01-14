# Production Scripts - Archive and Compression

Two professional-grade bash scripts for automated archiving, backup management, and verification.

---

## Overview

### archive-manager.sh
Comprehensive tool for creating, extracting, verifying, and managing archives with multiple compression formats.

**Key Features:**
- Create archives with gzip, bzip2, or xz compression
- Extract to specified locations
- List and search archive contents
- Verify archive integrity with checksums
- Compare multiple archives
- Automatic compression detection

### backup-automation.sh
Automated backup solution with compression, retention policies, and verification.

**Key Features:**
- Automatic full and incremental backups
- Configurable retention policies
- Multiple backup sources support
- File exclusion patterns
- Automatic verification and checksums
- Backup reporting and statistics
- Automatic cleanup of old backups

---

## Installation

```bash
# Copy scripts to standard location
sudo cp archive-manager.sh /usr/local/sbin/
sudo cp backup-automation.sh /usr/local/sbin/

# Make executable
sudo chmod 755 /usr/local/sbin/archive-manager.sh
sudo chmod 755 /usr/local/sbin/backup-automation.sh

# Verify installation
sudo archive-manager.sh version
sudo backup-automation.sh --version
```

### Optional: Create Aliases

Add to `~/.bashrc` or `~/.bash_aliases`:

```bash
alias am='sudo archive-manager.sh'
alias ba='sudo backup-automation.sh'
```

Then reload: `source ~/.bashrc`

---

## archive-manager.sh

### Installation

```bash
# Make executable
chmod 755 archive-manager.sh

# Run with sudo (required)
sudo ./archive-manager.sh [command] [options]
```

### Commands

#### Create Archive

```bash
# Basic creation with gzip (default)
sudo archive-manager.sh create -s /home -d backup.tar.gz

# Create with bzip2 compression
sudo archive-manager.sh create -s /home -d backup.tar.bz2 -c bzip2

# Create with xz compression (best ratio)
sudo archive-manager.sh create -s /home -d backup.tar.xz -c xz

# Create with custom compression level
sudo archive-manager.sh create -s /data -d backup.tar.gz -l 9

# Create with exclusions
sudo archive-manager.sh create -s /home -d backup.tar.gz \
  --exclude='*.log' \
  --exclude='.cache' \
  --exclude='.git'

# Create with verbose output
sudo archive-manager.sh create -s /data -d backup.tar.gz --verbose
```

#### Extract Archive

```bash
# Extract to current directory
sudo archive-manager.sh extract -f backup.tar.gz

# Extract to specific location
sudo archive-manager.sh extract -f backup.tar.gz -d /restore

# Extract with verbose output
sudo archive-manager.sh extract -f backup.tar.gz -d /restore --verbose

# Dry-run (show what would be extracted)
sudo archive-manager.sh extract -f backup.tar.gz --dry-run
```

#### List Archive Contents

```bash
# List files (simple format)
sudo archive-manager.sh list -f backup.tar.gz

# List with details (long format)
sudo archive-manager.sh list -f backup.tar.gz --verbose

# Search for specific file
sudo archive-manager.sh list -f backup.tar.gz --verbose | grep filename

# Count files
sudo archive-manager.sh list -f backup.tar.gz | wc -l
```

#### Verify Archive

```bash
# Verify archive integrity
sudo archive-manager.sh verify -f backup.tar.gz

# Verify multiple archives
for archive in backups/*.tar.gz; do
  sudo archive-manager.sh verify -f "$archive"
done
```

#### Show Archive Info

```bash
# Display archive information
sudo archive-manager.sh info -f backup.tar.gz

# Output:
# Archive Information
# ====================
# File: backup.tar.gz
# Size: 2.5M
# Created: 2024-01-15 10:30:45
# Files: 245
# Directories: 32
# Checksum: abc123def456...
```

### Examples

#### Example 1: Create Multi-Format Backups

```bash
#!/bin/bash

SOURCE="/home/user/project"
DEST_DIR="/backup"
DATE=$(date +%Y%m%d)

echo "Creating backups in different formats..."

# Gzip (fast)
sudo archive-manager.sh create -s "$SOURCE" \
  -d "$DEST_DIR/project-$DATE.tar.gz" -c gzip

# Bzip2 (better compression)
sudo archive-manager.sh create -s "$SOURCE" \
  -d "$DEST_DIR/project-$DATE.tar.bz2" -c bzip2

# Xz (best compression)
sudo archive-manager.sh create -s "$SOURCE" \
  -d "$DEST_DIR/project-$DATE.tar.xz" -c xz

# Compare sizes
echo ""
echo "Compression comparison:"
ls -lh "$DEST_DIR/project-$DATE.tar."* | awk '{print $5, $9}'
```

#### Example 2: Backup with Exclusions

```bash
#!/bin/bash

# Backup source code, excluding build artifacts and cache

sudo archive-manager.sh create \
  -s /home/dev/src \
  -d /backup/src-backup.tar.gz \
  --exclude='build/' \
  --exclude='dist/' \
  --exclude='*.o' \
  --exclude='*.pyc' \
  --exclude='.git' \
  --exclude='node_modules' \
  --verbose

# Verify the backup
sudo archive-manager.sh verify -f /backup/src-backup.tar.gz

# Show what was backed up
echo "Files backed up:"
sudo archive-manager.sh list -f /backup/src-backup.tar.gz | wc -l
```

#### Example 3: Archive Extraction Workflow

```bash
#!/bin/bash

ARCHIVE="/backup/system-backup.tar.gz"
RESTORE_DIR="/restore"

echo "=== Archive Extraction Workflow ==="

# List contents first
echo "1. Preview archive contents:"
sudo archive-manager.sh list -f "$ARCHIVE" | head -10
echo "..."

# Get archive info
echo ""
echo "2. Archive information:"
sudo archive-manager.sh info -f "$ARCHIVE"

# Extract to restore directory
echo ""
echo "3. Extracting archive..."
sudo archive-manager.sh extract -f "$ARCHIVE" -d "$RESTORE_DIR" --verbose

# Verify restoration
echo ""
echo "4. Verifying restored files:"
find "$RESTORE_DIR" -type f | wc -l
```

#### Example 4: Archive Management with Verification

```bash
#!/bin/bash

BACKUP_DIR="/backup"

echo "=== Archive Management ==="

# Create archive
echo "1. Creating archive..."
sudo archive-manager.sh create -s /home -d "$BACKUP_DIR/home-backup.tar.gz"

# List archives
echo ""
echo "2. Available archives:"
ls -lh "$BACKUP_DIR"/*.tar.gz

# Verify each archive
echo ""
echo "3. Verifying all archives..."
for archive in "$BACKUP_DIR"/*.tar.gz; do
  echo "Checking: $(basename "$archive")"
  sudo archive-manager.sh verify -f "$archive" && echo "  ✓ OK" || echo "  ✗ FAILED"
done
```

---

## backup-automation.sh

### Installation

```bash
# Make executable
chmod 755 backup-automation.sh

# Run with sudo (required)
sudo ./backup-automation.sh [options]
```

### Options and Usage

#### Basic Backup

```bash
# Backup single directory
sudo backup-automation.sh -s /home

# Backup multiple directories
sudo backup-automation.sh -s /home -s /etc -s /var/www

# Backup to custom location
sudo backup-automation.sh -s /data -b /mnt/backup

# Specify retention (keep backups for 60 days)
sudo backup-automation.sh -s /home -r 60

# Exclude files
sudo backup-automation.sh -s /home \
  --exclude='*.log' \
  --exclude='.cache' \
  --exclude='*.tmp'
```

#### Backup Strategies

```bash
# Force full backup
sudo backup-automation.sh -s /home --full

# Incremental backup (only changed files)
sudo backup-automation.sh -s /home --incremental

# Verify after backup
sudo backup-automation.sh -s /home --verify

# Dry-run (show what would be backed up)
sudo backup-automation.sh -s /home --dry-run
```

### Examples

#### Example 1: Daily Full Backup

```bash
#!/bin/bash

# Daily full backup with 30-day retention

sudo backup-automation.sh \
  -s /home \
  -s /etc \
  -s /var/www \
  -b /backup \
  --full \
  --retention 30 \
  --verify

# This creates:
# /backup/full-backup-20240115-100000.tar.gz
# /backup/full-backup-20240115-100000.tar.gz.sha256
# /backup/backup-report-20240115.txt
```

#### Example 2: Mixed Backup Strategy

```bash
#!/bin/bash

# Full backup on Monday, incremental other days

BACKUP_DIR="/backup"
DAY=$(date +%u)  # 1=Monday, 7=Sunday

if [[ $DAY -eq 1 ]]; then
  # Full backup on Monday
  sudo backup-automation.sh \
    -s /home \
    -b "$BACKUP_DIR" \
    --full \
    --retention 30
else
  # Incremental on other days
  sudo backup-automation.sh \
    -s /home \
    -b "$BACKUP_DIR" \
    --incremental
fi
```

#### Example 3: Multi-Source Backup with Exclusions

```bash
#!/bin/bash

# Backup multiple sources excluding unwanted files

sudo backup-automation.sh \
  -s /home \
  -s /etc \
  -s /opt/app \
  -b /backup \
  --exclude='*.log' \
  --exclude='*.tmp' \
  --exclude='.cache' \
  --exclude='node_modules' \
  --exclude='.git' \
  --retention 60 \
  --verify
```

#### Example 4: Scheduled Backup via Cron

Create `/etc/cron.d/daily-backup`:

```cron
# Daily backup at 2 AM
0 2 * * * root /usr/local/sbin/backup-automation.sh \
  -s /home \
  -s /etc \
  -b /backup \
  --retention 30 \
  --verify >> /var/log/backup-automation.log 2>&1

# Weekly full backup on Sunday at 3 AM
0 3 * * 0 root /usr/local/sbin/backup-automation.sh \
  -s /home \
  -s /etc \
  -s /var/www \
  -b /backup \
  --full \
  --retention 90 \
  --verify >> /var/log/backup-automation.log 2>&1

# Cleanup old backups every day at 23:00
0 23 * * * root /usr/local/sbin/backup-automation.sh \
  -b /backup \
  --dry-run >> /var/log/backup-automation.log 2>&1
```

#### Example 5: Backup with Error Notification

```bash
#!/bin/bash

# Backup with error handling and email notification

BACKUP_SCRIPT="/usr/local/sbin/backup-automation.sh"
EMAIL="admin@example.com"
LOG_FILE="/var/log/backup-errors.log"

echo "Starting backup at $(date)" >> "$LOG_FILE"

if sudo "$BACKUP_SCRIPT" -s /home -b /backup --verify; then
  echo "✓ Backup completed successfully" >> "$LOG_FILE"
else
  echo "✗ Backup FAILED at $(date)" >> "$LOG_FILE"
  echo "Backup failed - check logs" | mail -s "Backup Error" "$EMAIL"
  exit 1
fi
```

---

## Troubleshooting

### Issue: "Permission denied"

```bash
# Solution: Run with sudo
sudo archive-manager.sh [command]
sudo backup-automation.sh [options]
```

### Issue: "Archive verification failed"

```bash
# The archive may be corrupted
# Try extracting to see what can be recovered
sudo archive-manager.sh extract -f corrupted.tar.gz -d /tmp/recovery

# Check what was extracted
ls -la /tmp/recovery
```

### Issue: "Out of disk space during creation"

```bash
# Create archive on different partition
sudo archive-manager.sh create -s /data -d /other-partition/backup.tar.gz

# Or use compression with better ratio
sudo archive-manager.sh create -s /data -d backup.tar.xz -c xz
```

### Issue: "Backup takes too long"

```bash
# Use faster compression
sudo backup-automation.sh -s /home \
  -c gzip \
  --exclude='*.iso' \
  --exclude='*.zip' \
  --exclude='node_modules'

# Or use incremental backup instead of full
sudo backup-automation.sh -s /home --incremental
```

### Issue: "Checksum mismatch after transfer"

```bash
# File was corrupted during transfer
# Create local checksum and verify after transfer
sha256sum archive.tar.gz > archive.sha256
scp archive.tar.gz user@remote:/backup/
scp archive.sha256 user@remote:/backup/

# Verify on remote
ssh user@remote "cd /backup && sha256sum -c archive.sha256"
```

---

## Best Practices

1. **Always verify backups** after creation:
   ```bash
   sudo archive-manager.sh verify -f backup.tar.gz
   ```

2. **Test restoration** periodically:
   ```bash
   sudo archive-manager.sh extract -f backup.tar.gz -d /tmp/test
   ```

3. **Use checksums** for transmission safety:
   ```bash
   # Checksum created automatically by both scripts
   ```

4. **Exclude unnecessary files** to reduce backup size:
   ```bash
   --exclude='*.log' --exclude='.cache'
   ```

5. **Implement retention policy**:
   ```bash
   --retention 30  # Keep 30 days of backups
   ```

6. **Schedule automated backups**:
   ```bash
   # Via cron job for consistency
   0 2 * * * /usr/local/sbin/backup-automation.sh ...
   ```

7. **Monitor backup logs**:
   ```bash
   tail -f /var/log/backup-automation.log
   ```

8. **Keep backups in multiple locations**:
   - Local backups (fast recovery)
   - Remote backups (disaster recovery)
   - Off-site backups (compliance, long-term)

---

## Integration Patterns

### Pattern 1: Daily Backup with Weekly Full

```bash
#!/bin/bash
# Run daily: backup_daily.sh

DAY=$(date +%u)

if [[ $DAY -eq 1 ]]; then
  # Monday: Full backup
  sudo backup-automation.sh -s /home -b /backup --full
else
  # Other days: Incremental
  sudo backup-automation.sh -s /home -b /backup --incremental
fi
```

### Pattern 2: Multi-Tier Backup

```bash
#!/bin/bash
# Local + Remote + Off-site backups

LOCAL_BACKUP="/backup"
REMOTE_SERVER="backup.example.com"
S3_BUCKET="s3://compliance-backups"

# Local backup
sudo backup-automation.sh -s /home -b "$LOCAL_BACKUP" --verify

# Copy to remote
rsync -avz "$LOCAL_BACKUP"/*.tar.gz root@$REMOTE_SERVER:/backup/

# Archive to S3 (monthly)
if [[ $(date +%d) -eq 1 ]]; then
  aws s3 sync "$LOCAL_BACKUP" "$S3_BUCKET"
fi
```

### Pattern 3: Pre-Change Backup

```bash
#!/bin/bash
# Backup before making system changes

CHANGE_DESC="$1"

echo "Creating safety backup before: $CHANGE_DESC"
sudo archive-manager.sh create -s /etc -d "/backup/pre-change-$CHANGE_DESC.tar.gz"

echo "To revert: sudo archive-manager.sh extract -f /backup/pre-change-$CHANGE_DESC.tar.gz"
read -p "Proceed with changes? (y/n) " -n 1
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi
```

---

## Maintenance

### View Logs

```bash
# View script logs
sudo tail -f /var/log/backup-automation.log

# View recent errors
sudo grep ERROR /var/log/backup-automation.log
```

### List Backups

```bash
# Show all backups
sudo archive-manager.sh list -b /backup

# Show recent
ls -lht /backup/*.tar.gz | head -5

# Show storage
du -sh /backup
```

### Remove Old Backups

```bash
# Manual deletion of backups older than 30 days
find /backup -name "*.tar.gz" -mtime +30 -delete
```

---

## Statistics

- **Scripts**: 2
- **Lines of code**: 700+ (total)
- **Commands**: 8+
- **Compression formats**: 3+ (gzip, bzip2, xz)
- **Features**: Verify, rotate, report, automate
- **Production-ready**: Yes
- **Error handling**: Comprehensive

---

**Documentation Version**: 1.0  
**Last Updated**: January 2024  
**License**: MIT

For issues or improvements, contact: devops@example.com
