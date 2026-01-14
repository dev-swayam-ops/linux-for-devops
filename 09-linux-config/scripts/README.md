# Production Scripts - Configuration Management

Two professional-grade bash scripts for automated configuration backup, validation, and management.

---

## Overview

### config-backup.sh
Automated backup and restoration of system configuration files with checksums and versioning.

**Key Features:**
- Full /etc directory backup with optional compression
- Selective exclusion of sensitive files
- Automatic checksums for integrity verification
- Backup versioning and cleanup
- Safe restoration with pre-restore backups
- Metadata tracking (timestamp, hostname, kernel)

### config-validator.sh
Configuration validation and security scanning for syntax and security issues.

**Key Features:**
- Service-specific validation (SSH, Nginx, Apache)
- JSON/YAML syntax checking
- Security hardening verification
- Common error detection
- Configuration comparison
- Automatic error detection and optional fixing

---

## Installation

```bash
# Copy scripts to standard location
sudo cp config-backup.sh /usr/local/sbin/
sudo cp config-validator.sh /usr/local/sbin/

# Make executable
sudo chmod 755 /usr/local/sbin/config-backup.sh
sudo chmod 755 /usr/local/sbin/config-validator.sh

# Verify installation
sudo config-backup.sh version
sudo config-validator.sh version
```

### Optional: Create aliases

Add to `~/.bashrc` or `~/.bash_aliases`:

```bash
alias cb='sudo config-backup.sh'
alias cv='sudo config-validator.sh'
```

Then reload: `source ~/.bashrc`

---

## config-backup.sh

### Installation

```bash
# Make executable
chmod 755 config-backup.sh

# Run with sudo (required)
sudo ./config-backup.sh [command] [options]
```

### Commands

#### Backup Configuration

```bash
# Basic backup (default: /backup/configs)
sudo config-backup.sh backup

# Backup with compression (default)
sudo config-backup.sh backup --compress

# Backup without compression
sudo config-backup.sh backup --no-compress

# Backup to custom location
sudo config-backup.sh backup --target /mnt/backups

# Backup excluding sensitive files
sudo config-backup.sh backup --exclude "ssl/private" --exclude "shadow"

# Complete example
sudo config-backup.sh backup \
  --target /backup/configs \
  --compress \
  --exclude "ssl/private" \
  --exclude "openvpn/keys"
```

#### List Backups

```bash
# List all available backups
sudo config-backup.sh list

# List backups in specific directory
sudo config-backup.sh list /mnt/backups
```

**Output:**
```
ℹ INFO: Available backups in: /backup/configs
Backup File | Size | Date | Checksum Status
etc-20240115-100000.tar.gz | 5.2M | 2024-01-15 10:00:00 | ✓ Valid
etc-20240114-235959.tar.gz | 5.2M | 2024-01-14 23:59:59 | ✓ Valid
```

#### Restore Backup

```bash
# Restore from backup with verification
sudo config-backup.sh restore /backup/configs/etc-20240115-100000.tar.gz

# Verify backup before restoring (don't restore)
sudo config-backup.sh restore /backup/configs/etc-20240115-100000.tar.gz --verify-only

# Dry-run mode (show what would happen)
sudo config-backup.sh restore /backup/configs/etc-20240115-100000.tar.gz --dry-run

# Force restore without confirmation
sudo config-backup.sh restore /backup/configs/etc-20240115-100000.tar.gz --force
```

#### Verify Backup

```bash
# Check backup integrity and contents
sudo config-backup.sh verify /backup/configs/etc-20240115-100000.tar.gz
```

**Output:**
```
File size: 5.2M
Modified: 2024-01-15 10:00:00
✓ PASS: Checksum valid - backup is intact
Backup contents preview:
etc/
etc/ssh/
etc/ssh/sshd_config
...
```

#### Cleanup Old Backups

```bash
# Keep only last 7 backups (default)
sudo config-backup.sh cleanup /backup/configs

# Keep only last 3 backups
sudo config-backup.sh cleanup /backup/configs --keep 3

# Remove all backups (careful!)
sudo config-backup.sh cleanup /backup/configs --delete-all
```

### Examples

#### Scenario: Daily Backup

```bash
#!/bin/bash
# Daily configuration backup

# Create backup
sudo config-backup.sh backup --target /backup/configs --compress

# List recent backups
sudo config-backup.sh list /backup/configs | head -5

# Keep only last 7 days
sudo config-backup.sh cleanup /backup/configs --keep 7

# Email backup status
echo "Backup completed $(date)" | mail -s "Daily Config Backup" admin@example.com
```

Add to crontab:
```bash
# /etc/cron.d/daily-config-backup
0 2 * * * root /usr/local/bin/daily-config-backup.sh
```

#### Scenario: Pre-Change Backup

```bash
#!/bin/bash
# Backup before making changes

CHANGE_DESC="$1"

# Backup current state
sudo config-backup.sh backup --target /backup/pre-change --compress

echo "✓ Backup created before change: $CHANGE_DESC"
echo "To restore: sudo config-backup.sh restore /backup/pre-change/etc-*.tar.gz"

# Now proceed with changes
```

#### Scenario: Restore Specific File

```bash
#!/bin/bash
# Restore single file from backup

BACKUP_FILE="$1"
RESTORE_FILE="$2"

# Extract specific file
mkdir -p /tmp/restore-temp
tar xzf "$BACKUP_FILE" -C /tmp/restore-temp "$RESTORE_FILE"

# Show differences
echo "=== Differences ==="
diff "$RESTORE_FILE" "/tmp/restore-temp/$RESTORE_FILE" || true

# Restore if desired
read -p "Restore this file? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sudo cp "/tmp/restore-temp/$RESTORE_FILE" "$RESTORE_FILE"
  echo "Restored: $RESTORE_FILE"
fi

# Cleanup
rm -rf /tmp/restore-temp
```

#### Scenario: Remote Backup

```bash
#!/bin/bash
# Backup to remote server

REMOTE_HOST="backup.example.com"
REMOTE_PATH="/backups/servers"
LOCAL_PATH="/backup/configs"

# Create local backup
sudo config-backup.sh backup --target "$LOCAL_PATH" --compress

# Transfer to remote
rsync -avz "$LOCAL_PATH"/*.tar.gz \
  root@$REMOTE_HOST:"$REMOTE_PATH"

# Verify remote
ssh root@$REMOTE_HOST "ls -lh $REMOTE_PATH | tail -5"

echo "Remote backup complete"
```

### Output Examples

**Backup creation:**
```
ℹ INFO: Starting configuration backup
ℹ INFO: Backup source: /etc
ℹ INFO: Backup file: /backup/configs/etc-20240115-100000.tar.gz
✓ SUCCESS: Backup created: /backup/configs/etc-20240115-100000.tar.gz (5.2M)
ℹ INFO: Checksum saved: /backup/configs/etc-20240115-100000.tar.gz.sha256
ℹ INFO: Metadata saved: /backup/configs/etc-20240115-100000.tar.gz.meta
```

**Restore process:**
```
ℹ INFO: Preparing to restore from: /backup/configs/etc-20240115-100000.tar.gz
ℹ INFO: Verifying backup integrity...
✓ SUCCESS: Backup integrity verified
ℹ INFO: Creating safety backup: /backup/configs/etc-safety-20240115-100030.tar.gz
ℹ INFO: Restoring configuration...
✓ SUCCESS: Configuration restored from: /backup/configs/etc-20240115-100000.tar.gz
⚠ WARNING: You may need to restart services for changes to take effect
```

---

## config-validator.sh

### Installation

```bash
# Make executable
chmod 755 config-validator.sh

# Run with sudo (required for security checks)
sudo ./config-validator.sh [command] [options]
```

### Commands

#### Check Configuration Syntax

```bash
# Validate SSH configuration
sudo config-validator.sh check-syntax --service ssh

# Validate Nginx configuration
sudo config-validator.sh check-syntax --service nginx

# Validate Apache configuration
sudo config-validator.sh check-syntax --service apache

# Validate specific file
sudo config-validator.sh check-syntax /etc/hosts
```

#### Security Scan

```bash
# Scan /etc for security issues
sudo config-validator.sh security-scan

# Scan specific directory
sudo config-validator.sh security-scan /home

# Strict security scan (includes setuid check)
sudo config-validator.sh security-scan /etc --strict
```

**Output:**
```
ℹ INFO: Checking for world-writable configuration files
✓ PASS: No world-writable configuration files
ℹ INFO: Checking password file permissions
✓ PASS: Shadow file permissions correct
✓ PASS: Group shadow file permissions correct
ℹ INFO: Checking SSH security hardening
✓ PASS: SSH: Password authentication is disabled
✓ PASS: SSH: Root login is disabled
✓ PASS: SSH: Using secure Protocol 2
```

#### Compare Configurations

```bash
# Compare SSH configs
sudo config-validator.sh compare /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Compare full directories
sudo config-validator.sh compare /etc/nginx /backup/nginx.old
```

#### Find and Fix Errors

```bash
# Find common errors
sudo config-validator.sh find-errors /etc

# Find errors in specific directory
sudo config-validator.sh find-errors /etc/ssh

# Dry-run: show what would be fixed
sudo config-validator.sh find-errors /etc --dry-run

# Fix errors automatically
sudo config-validator.sh find-errors /etc --fix
```

### Examples

#### Scenario: Pre-Deployment Validation

```bash
#!/bin/bash
# Validate all configs before deployment

echo "=== Configuration Validation Report ==="
echo "Generated: $(date)"
echo ""

echo "=== SSH Configuration ==="
sudo config-validator.sh check-syntax --service ssh

echo ""
echo "=== Security Scan ==="
sudo config-validator.sh security-scan /etc --strict

echo ""
echo "=== Comparison with Backup ==="
sudo config-validator.sh compare /etc/ssh/sshd_config /backup/ssh/sshd_config.backup

echo ""
echo "=== Error Check ==="
sudo config-validator.sh find-errors /etc

echo ""
echo "Validation complete"
```

#### Scenario: Regular Security Audit

```bash
#!/bin/bash
# Weekly security audit

echo "Security Configuration Audit - $(date)" > /tmp/audit-report.txt

# Scan for issues
sudo config-validator.sh security-scan /etc --strict >> /tmp/audit-report.txt 2>&1

# Check SSH hardening
sudo config-validator.sh check-syntax --service ssh >> /tmp/audit-report.txt 2>&1

# Find errors
sudo config-validator.sh find-errors /etc >> /tmp/audit-report.txt 2>&1

# Email report
mail -s "Weekly Security Audit Report" admin@example.com < /tmp/audit-report.txt

echo "Audit complete - report emailed"
```

#### Scenario: Configuration Change Verification

```bash
#!/bin/bash
# Verify config changes before and after

CONFIG_FILE="$1"

echo "Before changes:"
sudo config-validator.sh check-syntax "$CONFIG_FILE"

# Make some changes...
echo "
Make your configuration changes now.
Press Enter when ready to verify changes...
"
read

echo ""
echo "After changes:"
sudo config-validator.sh check-syntax "$CONFIG_FILE"

# Compare with backup
if [[ -f "$CONFIG_FILE.bak" ]]; then
  echo ""
  echo "Comparing with backup:"
  sudo config-validator.sh compare "$CONFIG_FILE" "$CONFIG_FILE.bak"
fi
```

#### Scenario: Automated Error Fixing

```bash
#!/bin/bash
# Find and fix common configuration errors

# First, show what would be fixed
echo "=== DRY RUN: Changes that would be made ==="
sudo config-validator.sh find-errors /etc --dry-run

# Confirm
read -p "Apply fixes? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Create backup before fixing
  sudo config-backup.sh backup --target /backup/pre-fix

  # Apply fixes
  sudo config-validator.sh find-errors /etc --fix

  echo "Fixes applied (backup at /backup/pre-fix)"
fi
```

### Output Examples

**SSH validation:**
```
ℹ INFO: Validating SSH configuration
✓ PASS: SSH configuration syntax valid
```

**Security scan:**
```
ℹ INFO: Checking for world-writable configuration files
✓ PASS: No world-writable configuration files
ℹ INFO: Checking SSH security hardening
⚠ WARNING: SSH: Password authentication is enabled (consider disabling)
✓ PASS: SSH: Root login is disabled

=== SECURITY SCAN SUMMARY ===
Errors: 0
Warnings: 1
Passes: 7
```

**Configuration comparison:**
```
ℹ INFO: Comparing configurations
File 1: /etc/ssh/sshd_config
File 2: /etc/ssh/sshd_config.bak
⚠ WARNING: Files differ - showing differences:

5c5
< PasswordAuthentication no
---
> PasswordAuthentication yes

Total lines that differ: 2
```

---

## Integration Patterns

### Pattern 1: Pre-Change Safety

```bash
#!/bin/bash
# Safe configuration change workflow

CHANGED_FILE="$1"
CHANGE_REASON="$2"

# Step 1: Backup current state
sudo config-backup.sh backup --compress
PRE_CHANGE_BACKUP=$(ls -t /backup/configs/etc-*.tar.gz | head -1)

# Step 2: Validate before changing
echo "Validating before changes..."
sudo config-validator.sh check-syntax "$CHANGED_FILE"

# Step 3: Allow user to make changes
echo "Make changes to: $CHANGED_FILE"
echo "Reason: $CHANGE_REASON"
echo "Press Enter when done..."
read

# Step 4: Validate after changes
echo ""
echo "Validating after changes..."
if sudo config-validator.sh check-syntax "$CHANGED_FILE"; then
  echo "✓ Changes validated successfully"
  echo "To revert: sudo config-backup.sh restore $PRE_CHANGE_BACKUP"
else
  echo "✗ Configuration has errors - reverting"
  sudo config-backup.sh restore "$PRE_CHANGE_BACKUP" --force
fi
```

### Pattern 2: Automated Monitoring

```bash
#!/bin/bash
# Monitor configuration for changes

WATCH_FILES=(
  "/etc/ssh/sshd_config"
  "/etc/hosts"
  "/etc/network/interfaces"
)

for file in "${WATCH_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    # Validate
    if ! sudo config-validator.sh check-syntax "$file" 2>/dev/null; then
      echo "ERROR: Invalid config in $file"
      mail -s "Config Error: $file" admin@example.com
    fi
  fi
done
```

### Pattern 3: Multi-Server Deployment

```bash
#!/bin/bash
# Deploy configs to multiple servers

SERVERS=("web1" "web2" "web3")
CONFIG_FILE="$1"

# Validate locally first
echo "Validating configuration..."
sudo config-validator.sh check-syntax "$CONFIG_FILE" || exit 1

# Deploy to each server
for server in "${SERVERS[@]}"; do
  echo "Deploying to $server..."
  
  # Copy with SCP
  scp "$CONFIG_FILE" root@$server:/tmp/
  
  # Validate on remote
  ssh root@$server "sudo config-validator.sh check-syntax /tmp/$(basename $CONFIG_FILE)" || continue
  
  # Backup on remote
  ssh root@$server "sudo config-backup.sh backup"
  
  # Deploy
  ssh root@$server "sudo cp /tmp/$(basename $CONFIG_FILE) $(dirname $CONFIG_FILE)/"
  
  echo "✓ $server updated"
done
```

---

## Troubleshooting

### Issue: "Permission denied" when accessing /etc

```bash
# Solution: Run with sudo
sudo config-backup.sh backup
sudo config-validator.sh security-scan
```

### Issue: Backup directory doesn't exist

```bash
# Solution: Create it first
sudo mkdir -p /backup/configs
sudo chmod 700 /backup/configs

# Or use --target option
sudo config-backup.sh backup --target /mnt/backups
```

### Issue: Cannot restore - "file permission denied"

```bash
# Solution: Restore with sudo from root shell
sudo -i
config-backup.sh restore /path/to/backup.tar.gz
```

### Issue: Validation fails but I need to change config anyway

```bash
# Solution: Make changes gradually, validate after each change
# Or use --dry-run to understand what's wrong
sudo config-validator.sh find-errors /etc --dry-run

# Fix issues one by one
sudo config-validator.sh find-errors /etc --fix
```

---

## Best Practices

1. **Always backup before changes**: Use `config-backup.sh backup`
2. **Always validate first**: Use `config-validator.sh check-syntax`
3. **Test on non-production**: Validate on development system first
4. **Keep backups**: Don't delete old backups immediately
5. **Document changes**: Add comments explaining why changes were made
6. **Automate validation**: Include in deployment scripts
7. **Regular audits**: Run security scans weekly
8. **Version control**: Keep important configs in git
9. **Monitor logs**: Check validation logs regularly
10. **Have rollback plan**: Know how to restore quickly

---

## Advanced Usage

### Scheduled Backups

```bash
# /etc/cron.d/config-backup
# Backup daily at 2 AM, keep 7 days of backups
0 2 * * * root /usr/local/sbin/config-backup.sh backup --compress && \
           /usr/local/sbin/config-backup.sh cleanup /backup/configs --keep 7
```

### Configuration Monitoring

```bash
# Monitor for unauthorized changes
*/15 * * * * root /usr/local/sbin/config-validator.sh security-scan /etc --strict | \
              grep -i error && mail -s "Config Alert" admin@example.com
```

### Automated Recovery

```bash
# Detect broken configs and restore from backup
if ! sudo config-validator.sh check-syntax /etc/ssh/sshd_config; then
  # Restore from most recent backup
  LATEST_BACKUP=$(ls -t /backup/configs/etc-*.tar.gz | head -1)
  sudo config-backup.sh restore "$LATEST_BACKUP" --force
  sudo systemctl restart ssh
  mail -s "SSH config restored" admin@example.com
fi
```

---

## Statistics

- **Commands**: 20+
- **Service support**: SSH, Nginx, Apache, JSON, YAML
- **Security checks**: 10+ different checks
- **Lines of code**: 650+ lines total
- **Production-ready**: Yes
- **Error handling**: Comprehensive

---

**Documentation Version**: 1.0  
**Last Updated**: January 2024  
**Maintainers**: DevOps Team  
**License**: MIT

For issues or improvements, contact: devops@example.com
