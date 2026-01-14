# Module 04: Crontab & Scheduling - Utility Scripts

This directory contains production-ready bash scripts for automating common scheduling and backup tasks.

## Scripts Included

### 1. database-backup.sh
**Purpose**: Production-grade database backup with rotation, compression, and verification

**Features**:
- Supports MySQL/MariaDB, PostgreSQL, and MongoDB
- Automatic backup rotation (configurable retention)
- Compression and size reporting
- Email notifications on success/failure
- Detailed logging to `/var/log/backups/`
- Lock mechanism to prevent concurrent backups
- Backup integrity verification
- Disk space validation before backup

**Installation**:
```bash
sudo cp database-backup.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/database-backup.sh
```

**Usage Examples**:

```bash
# Backup all MySQL databases, keep 7 days
database-backup.sh -t mysql -u root -d '*' -r 7

# Backup PostgreSQL database
database-backup.sh -t postgresql -u postgres -d myapp_db

# Backup MongoDB with email notification
database-backup.sh -t mongodb -e admin@example.com --send-email

# Show help
database-backup.sh --help
```

**Crontab Integration**:

```bash
# MySQL daily backup at 2 AM
0 2 * * * /usr/local/bin/database-backup.sh -t mysql -u root -d '*' -r 7

# PostgreSQL nightly backup at 3 AM
0 3 * * * /usr/local/bin/database-backup.sh -t postgresql -u postgres -d myapp_db

# MongoDB twice daily (2 AM and 2 PM)
0 2,14 * * * /usr/local/bin/database-backup.sh -t mongodb

# With password from environment variable
0 2 * * * DB_PASSWORD="secret" /usr/local/bin/database-backup.sh -t mysql -u root -d '*'
```

**Configuration via Environment Variables**:
```bash
export BACKUP_DIR=/backups              # Where to store backups
export LOG_DIR=/var/log/backups         # Where to store logs
export KEEP_BACKUPS=7                   # Number of backups to keep
export ALERT_EMAIL=admin@example.com    # Alert email address
export DB_PASSWORD="password"           # Database password (for security)
```

**Expected Output**:
```
[2026-01-14 02:00:00] [INFO] ===================================
[2026-01-14 02:00:00] [INFO] Database Backup Starting
[2026-01-14 02:00:00] [INFO] Type: mysql, Host: localhost
[2026-01-14 02:00:00] [INFO] ===================================
[2026-01-14 02:00:02] [INFO] MySQL backup successful: /backups/mysql-all-20260114-020000.sql.gz (185M)
[2026-01-14 02:00:03] [INFO] Cleaning up backups older than 7 days
[2026-01-14 02:00:03] [INFO] Removing old backup: mysql-all-20260107-020000.sql.gz
[2026-01-14 02:00:03] [INFO] Backup completed successfully
```

---

### 2. cron-job-monitor.sh
**Purpose**: Monitor cron job execution and send alerts on failures

**Features**:
- Monitor system and user crontabs
- Alert on job failures and timeouts
- Track job execution status
- Identify stale/missing jobs
- Generate health reports
- Validate cron configuration
- Check cron daemon status
- Detect unreadable crontab files

**Installation**:
```bash
sudo cp cron-job-monitor.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/cron-job-monitor.sh
```

**Usage Examples**:

```bash
# Run full monitoring and generate report
sudo cron-job-monitor.sh --system-cron --user-cron

# Generate health report only
sudo cron-job-monitor.sh --report

# Monitor with custom email
sudo cron-job-monitor.sh --email ops@example.com

# Run with verbose output
sudo cron-job-monitor.sh -v

# Show help
sudo cron-job-monitor.sh --help
```

**Crontab Integration** (run as root):

```bash
# Monitor cron jobs every 10 minutes
*/10 * * * * /usr/local/bin/cron-job-monitor.sh --system-cron --email admin@example.com

# Generate daily health report at 8 AM
0 8 * * * /usr/local/bin/cron-job-monitor.sh --report >> /var/log/cron-health.log 2>&1

# Hourly check with detailed logging
0 * * * * /usr/local/bin/cron-job-monitor.sh --system-cron -v
```

**Configuration via Environment Variables**:
```bash
export MONITOR_SYSTEM_CRON=true         # Monitor system crontab
export MONITOR_USER_CRON=true           # Monitor user crontabs
export ALERT_EMAIL=admin@example.com    # Alert email
export DEFAULT_TIMEOUT=1800             # Job timeout (seconds)
export FAILURE_THRESHOLD=3              # Alert after N failures
```

**Expected Output**:

```
[INFO] ==========================================
[INFO] Cron Monitor Started
[INFO] ==========================================
[INFO] Validating cron configuration...
[INFO] Cron daemon is RUNNING
[INFO] Starting cron job monitoring...
[INFO] Scanning system crontab...
[INFO] Scanning user crontabs...
[INFO] Found 12 configured cron jobs
[INFO] ==========================================
[INFO] Cron Monitor Completed
[INFO] ==========================================
```

---

## Common Patterns & Recipes

### Daily Database Backups
```bash
# Add to root's crontab:
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

# MySQL backup daily at 2 AM
0 2 * * * /usr/local/bin/database-backup.sh -t mysql -u root -d '*'

# PostgreSQL backup daily at 3 AM
0 3 * * * /usr/local/bin/database-backup.sh -t postgresql -u postgres -d mydb

# MongoDB backup daily at 4 AM
0 4 * * * /usr/local/bin/database-backup.sh -t mongodb --send-email
```

### Monitor Multiple Applications
```bash
# Add to root's crontab:
# Monitor every 15 minutes during business hours
*/15 9-17 * * 1-5 /usr/local/bin/cron-job-monitor.sh --report

# Full system health check at 6 AM daily
0 6 * * * /usr/local/bin/cron-job-monitor.sh --system-cron --user-cron --email ops@company.com
```

### Production Best Practices
```bash
# Set proper permissions
sudo chmod 755 /usr/local/bin/database-backup.sh
sudo chmod 755 /usr/local/bin/cron-job-monitor.sh

# Create backup directories
sudo mkdir -p /backups
sudo mkdir -p /var/log/backups
sudo chmod 755 /backups /var/log/backups

# Verify scripts work manually first
sudo /usr/local/bin/database-backup.sh --help
sudo /usr/local/bin/cron-job-monitor.sh --help

# Test with actual data
DB_PASSWORD="test123" /usr/local/bin/database-backup.sh -t mysql -u root -d '*' -r 7

# Check logs
tail -f /var/log/backups/backup-mysql.log
```

## Troubleshooting

### Script Not Running in Cron
1. Check PATH: Add to top of crontab: `PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin`
2. Check permissions: Ensure script is executable: `chmod +x /usr/local/bin/script.sh`
3. Check logs: Review `/var/log/syslog` or `/var/log/cron`

### Backup Failures
1. Test manually: Run script directly to see actual errors
2. Check database credentials: Verify username/password with direct connection
3. Verify disk space: Ensure backup directory has sufficient space
4. Check file permissions: Backup directory must be writable

### Monitor Not Detecting Jobs
1. Verify cron service is running: `systemctl status cron`
2. Check log file location: May be in `/var/log/syslog` or `/var/log/cron`
3. Run with verbose flag: `script.sh -v` to see what it's checking
4. Ensure journalctl access: Monitor script needs to read cron logs

## Integration with Other Modules

- **Module 03 (Hands-on Labs)**: Use these scripts in your own cron jobs
- **Module 07 (Process Management)**: Monitor backup processes
- **Module 13 (Logging & Monitoring)**: Parse logs from these scripts
- **Module 18 (Troubleshooting)**: Use monitor script to diagnose cron issues

## Security Considerations

- **Database Passwords**: Never hardcode in crontab; use environment variables or credential files
- **Log Files**: Ensure `/var/log/backups/` is not world-readable if containing sensitive info
- **Backup Permissions**: Set backups to mode 600: `chmod 600 /backups/backup-*.sql.gz`
- **Email Notifications**: Use encrypted transport for alerts containing paths/commands
- **Audit Trail**: Monitor script creates logs - regularly review for security issues

## Support & Advanced Usage

For complete documentation, see the main module files:
- **Theory & Concepts**: 01-theory.md
- **Command Reference**: 02-commands-cheatsheet.md
- **Practical Labs**: 03-hands-on-labs.md

For questions or improvements, refer to the main README.md.
