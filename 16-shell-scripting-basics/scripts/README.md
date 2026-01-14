# Shell Scripting Basics - Scripts Reference

Production-ready shell scripts demonstrating real-world automation patterns.

**Total Scripts:** 3 main utilities (~1,200+ lines)

---

## Overview

This directory contains three production-ready bash scripts that demonstrate advanced shell scripting concepts covered in the module. Each script is fully functional and designed for real-world use.

### Quick Start

```bash
# Make scripts executable
chmod +x *.sh

# Get help
./simple-backup.sh --help
./log-analyzer.sh --help
./deployment-helper.sh --help
```

---

## 1. simple-backup.sh

Automated backup utility with compression, rotation, and validation.

### Purpose

Provides reliable automated backups with:
- Automatic compression (tar.gz)
- Backup rotation with retention policies
- Archive integrity verification
- Comprehensive logging and manifests
- Dry-run mode for testing
- Error handling and recovery

### Key Features

- **Compression:** Automatic tar.gz compression
- **Rotation:** Auto-cleanup of old backups
- **Validation:** Archive integrity checks
- **Manifest:** Detailed backup metadata
- **Logging:** Timestamped logs
- **Dry-run:** Test without making changes
- **Error handling:** Trap signals, cleanup

### Usage

```bash
# Basic backup (with defaults)
./simple-backup.sh --source /home/user

# Custom retention (keep 14 days)
./simple-backup.sh --source /var/www --retention 14

# Backup without compression
./simple-backup.sh --source /config --no-compress

# Dry-run to test
./simple-backup.sh --source /data --dry-run

# Verbose output
./simple-backup.sh --source /important --verbose

# Custom destination
./simple-backup.sh --source /data --dest /mnt/backups
```

### Output

```
[INFO] ==========================================
[INFO] Backup Process Started
[INFO] ==========================================
[INFO] Source:      /home/user
[INFO] Destination: ./backups
[INFO] Retention:   7 days
[INFO] Compression: true
[INFO] Dry-run:     false

[INFO] Creating backup: backup-user-20240115-143022
[✓] Backup created: 245M
[✓] Manifest created: manifest.txt
[✓] Backup verified: Archive is valid

[INFO] Cleaning up backups older than 7 days
[✓] Removed 1 old backup(s)

[INFO] ==========================================
[INFO] Backup Status Report
[INFO] ==========================================
[INFO] Total backups: 5
[INFO] Total storage: 1.2G

[INFO] Recent backups:
[INFO]   • backup-user-20240115-143022 (245M)
[INFO]   • backup-user-20240114-140000 (248M)
[INFO]   • backup-user-20240113-141500 (251M)

[✓] Backup process completed successfully
```

### Concepts Demonstrated

**Variables:**
- Readonly configuration constants
- Argument parsing into variables
- Local function variables

**Control Flow:**
- If/else for validation
- Case statements for options
- Conditionals for file checks

**Functions:**
- parse_arguments()
- validate_environment()
- create_backup()
- cleanup_old_backups()
- show_backup_status()

**Error Handling:**
- set -euo pipefail
- Input validation
- Trap for cleanup
- Exit codes

**I/O & Logging:**
- Redirect output to files
- Colored terminal output
- Timestamped logging
- Error to stderr

### Installation

```bash
# Copy to bin directory
sudo cp simple-backup.sh /usr/local/bin/backup
sudo chmod +x /usr/local/bin/backup

# Use with cron for automated backups
0 2 * * * /usr/local/bin/backup --source /home/user --retention 30
```

### Troubleshooting

**"Source directory not found"**
- Ensure path exists: `ls -la /path/to/backup`
- Use absolute paths

**"Permission denied"**
- Check read permissions: `ls -ld /path/to/backup`
- May need sudo for system directories

**"Tar command failed"**
- Check disk space: `df -h`
- Ensure write access to destination

---

## 2. log-analyzer.sh

Advanced log file parser with pattern matching and statistics.

### Purpose

Analyzes system and application log files with:
- Pattern matching (case-insensitive)
- Severity level extraction
- Statistics and trends
- Error/warning isolation
- Repeated message detection
- Tail mode for real-time

### Key Features

- **Pattern Search:** Case-insensitive grep with highlighting
- **Error Extraction:** Find all errors automatically
- **Statistics:** Severity counts, top services
- **Trends:** Most repeated messages
- **Flexibility:** Works with any log format
- **Tail Mode:** Show newest entries first
- **Integration:** Works with standard logs

### Usage

```bash
# Analyze syslog (default)
./log-analyzer.sh

# Search for specific pattern
./log-analyzer.sh --log /var/log/syslog --pattern "ssh"

# Show errors only
./log-analyzer.sh --log /var/log/syslog --errors

# Show warnings only
./log-analyzer.sh --log /var/log/auth.log --warnings

# Get detailed statistics
./log-analyzer.sh --log /var/log/syslog --stats

# Show newest 50 lines
./log-analyzer.sh --log /var/log/syslog --tail --lines 50

# Custom log file with pattern
./log-analyzer.sh --log /var/log/nginx/error.log --pattern "500"

# Analyze Apache logs
./log-analyzer.sh --log /var/log/apache2/access.log --pattern "GET"
```

### Output

```
[*] Log Analysis Summary

File: /var/log/syslog
Size: 128 MB
Lines: 523450
Modified: 2024-01-15 14:30:22

[*] Matching entries: 1250

[*] Log Entries
==========================================
Jan 15 14:25:01 server kernel: [12345.123456] Out of memory: Kill process
Jan 15 14:25:02 server systemd[1]: service.service: Main process exited
Jan 15 14:25:03 server sudo: user : TTY=pts/0 ; PWD=/home/user ; USER=root
...

[!] Showing 20 of 1250 matching entries (truncated)

[*] Detailed Statistics
==========================================

Severity Analysis:
  Errors:    125
  Warnings:  342
  Info:      1200
  Total:     2500

Top Services/Processes:
  856 kernel
  234 systemd
  187 sshd
  145 cron
  98 sudo

Most Repeated Messages:
  234 connection closed by authenticating user root 1.2.3.4
  156 authentication failure
  142 session opened for user
```

### Concepts Demonstrated

**Variables:**
- Global configuration variables
- String manipulation (PATTERN)
- Temporary file paths

**Functions:**
- extract_pattern()
- count_pattern_occurrences()
- analyze_severity()
- get_top_services()
- find_repeated_messages()

**Text Processing:**
- grep for pattern matching
- awk for parsing fields
- sort/uniq for statistics
- sed for filtering

**Control Flow:**
- Case for action selection
- If/else for validation
- While for line processing

### Common Workflows

**Find authentication failures:**
```bash
./log-analyzer.sh --log /var/log/auth.log --pattern "failure" --stats
```

**Monitor specific service:**
```bash
./log-analyzer.sh --log /var/log/syslog --pattern "nginx" --tail
```

**Check for errors in last hour:**
```bash
# Requires recent log entries
./log-analyzer.sh --log /var/log/syslog --errors --lines 100
```

**Find repeated errors:**
```bash
./log-analyzer.sh --log /var/log/syslog --errors --stats
```

### Integration Examples

**Systemd service monitoring:**
```bash
journalctl -n 1000 > /tmp/journal.log
./log-analyzer.sh --log /tmp/journal.log --errors
```

**Docker logs analysis:**
```bash
docker logs container_name > /tmp/docker.log
./log-analyzer.sh --log /tmp/docker.log --pattern "error"
```

### Troubleshooting

**"Cannot read log file (try with sudo)"**
- Some logs require root: `sudo ./log-analyzer.sh ...`
- Or copy log first: `sudo cat /var/log/auth.log | tee temp.log`

**No matching entries found**
- Check pattern spelling
- Try without pattern: `./log-analyzer.sh --log /file`
- Use simple keywords first

**Slow performance on large files**
- Use tail mode: `--tail --lines 50`
- Increase lines count for subset

---

## 3. deployment-helper.sh

Application deployment utility with rollback support.

### Purpose

Manages application deployments with:
- Version management
- Automated rollback capability
- Health checking
- Deployment hooks
- Dry-run testing
- Status tracking

### Key Features

- **Deploy:** Symlink-based deployment
- **Rollback:** Automatic version switching
- **Health:** Check application status
- **Validation:** Pre-deployment checks
- **Hooks:** Custom deployment scripts
- **Dry-run:** Test deployments safely
- **History:** Version tracking

### Usage

```bash
# Deploy new version
./deployment-helper.sh --action deploy --app myapp --version 1.0.0

# Dry-run deployment
./deployment-helper.sh --action deploy --app myapp --version 1.0.0 --dry-run

# Rollback to previous version
./deployment-helper.sh --action rollback --app myapp

# Check deployment status
./deployment-helper.sh --action status --app myapp

# List available versions
./deployment-helper.sh --action list --app myapp

# Check application health
./deployment-helper.sh --action health --app myapp

# Prepare deployment (validate only)
./deployment-helper.sh --action prepare --app myapp --version 1.0.0

# Staging environment deployment
./deployment-helper.sh --action deploy --app myapp --version 1.0.0 --env staging
```

### Output

```
[*] ==========================================
[*] Deployment Started
[*] ==========================================
[*] ID:           myapp-production-1705323600
[*] App:          myapp
[*] Version:      1.0.0
[*] Environment:  production
[*] Time:         2024-01-15 14:30:00

[*] Preparing deployment...
[*] Checking current version health...
[✓] Current version healthy

[✓] Deployment preparation complete

[*] Deploying version: 1.0.0
[*] Backing up current version
[*] Updating symlink
[*] Running pre-deploy hooks
[✓] Hook completed: pre-deploy
[*] Verifying deployment...
[✓] Verification passed
[*] Running post-deploy hooks
[✓] Hook completed: post-deploy
[✓] Deployment successful

[*] ==========================================
[✓] Action completed: deploy
[*] ==========================================
```

### Concepts Demonstrated

**Functions:**
- parse_arguments()
- validate_environment()
- deploy_version()
- rollback_deployment()
- verify_deployment()
- check_app_health()

**Error Handling:**
- set -euo pipefail
- Input validation
- Deployment verification
- Automatic rollback

**Advanced Features:**
- Symbolic links for version switching
- Backup creation
- Hook execution
- Health monitoring

### Deployment Structure

```
/opt/apps/
├── releases/              # All released versions
│   └── myapp/
│       ├── 1.0.0/        # Specific version
│       ├── 1.1.0/
│       └── 1.2.0/
├── backups/              # Pre-deployment backups
│   └── myapp-pre-deploy-20240115-143000/
├── logs/                 # Deployment logs
│   └── deployment.log
└── myapp/
    ├── current -> ../releases/myapp/1.2.0  # Symlink to active version
    └── hooks/            # Deployment hooks
        ├── pre-deploy.sh
        └── post-deploy.sh
```

### Deployment Hooks

Create custom hooks for automated tasks:

**pre-deploy.sh** - Run before deployment:
```bash
#!/bin/bash
# Pre-deployment tasks
set -euo pipefail

echo "Running pre-deployment tasks..."
# Stop application
systemctl stop myapp || true
# Run migrations
/opt/apps/myapp/bin/migrate.sh || true
# Backup database
mysqldump myapp > /tmp/myapp_backup.sql
```

**post-deploy.sh** - Run after deployment:
```bash
#!/bin/bash
# Post-deployment tasks
set -euo pipefail

echo "Running post-deployment tasks..."
# Start application
systemctl start myapp
# Health check
sleep 5
curl -f http://localhost:3000/health || exit 1
# Notify team
echo "Deployment successful" | mail -s "Deploy notice" team@example.com
```

### Advanced Usage

**Continuous deployment:**
```bash
# Check for new version and deploy
VERSION=$(curl -s https://api.example.com/latest)
./deployment-helper.sh --action deploy --app myapp --version $VERSION
```

**Staged rollout:**
```bash
# Deploy to staging first
./deployment-helper.sh --action deploy --app myapp --version 1.5.0 --env staging

# After verification, deploy to production
./deployment-helper.sh --action deploy --app myapp --version 1.5.0 --env production
```

**Automated rollback:**
```bash
# If health check fails, rollback
if ! ./deployment-helper.sh --action health --app myapp; then
    ./deployment-helper.sh --action rollback --app myapp
fi
```

---

## Best Practices

### Error Handling

All scripts use:
- `set -euo pipefail` for safety
- Input validation before operations
- Trap for cleanup
- Meaningful error messages
- Exit codes for automation

### Logging

- Timestamped log entries
- Structured log format
- Color-coded output
- File and console logging
- Different log levels

### Security

- Validate all inputs
- Check file permissions
- Use readonly for constants
- Secure temporary files
- No hardcoded credentials

### Testing

- Always use `--dry-run` first
- Test with non-production data
- Review backup before deletion
- Verify deployment before committing
- Check permissions before operations

### Maintenance

- Keep scripts modular
- Use functions for reusability
- Document complex logic
- Follow naming conventions
- Version control scripts

---

## Integration Examples

### Cron Scheduling

```bash
# Daily backup at 2 AM
0 2 * * * /usr/local/bin/simple-backup.sh --source /home/user

# Hourly log analysis
0 * * * * /usr/local/bin/log-analyzer.sh --log /var/log/syslog --errors

# Weekly deployment health check
0 3 * * 0 /usr/local/bin/deployment-helper.sh --action health --app myapp
```

### Systemd Services

**Create /etc/systemd/system/backup.service:**
```ini
[Unit]
Description=Daily Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/simple-backup.sh --source /home/user
User=backup

[Install]
WantedBy=multi-user.target
```

### Monitoring & Alerting

```bash
# Alert if recent errors in syslog
./log-analyzer.sh --log /var/log/syslog --errors --lines 10 | \
    mail -s "System errors detected" admin@example.com
```

---

## Performance Notes

**simple-backup.sh:**
- Speed depends on file size and I/O performance
- Compression reduces storage at CPU cost
- Verification adds ~10% overhead
- Typical: 100MB/min on modern systems

**log-analyzer.sh:**
- Pattern matching is fast (linear scan)
- Statistics on large files may take seconds
- Use `--tail` for large active logs
- Typical: <1s for most operations

**deployment-helper.sh:**
- Deployment speed depends on content size
- Symlink switching is near-instant
- Hook execution depends on script complexity
- Typical: <30s for complete deployment

---

## Troubleshooting Guide

### General Issues

**Permission denied:**
```bash
# Make scripts executable
chmod +x *.sh

# Or run with sudo (if needed)
sudo ./script.sh [options]
```

**Command not found:**
```bash
# Use full path
/path/to/script.sh

# Or add to PATH
export PATH="$PATH:$(pwd)"
```

**Syntax errors:**
```bash
# Check syntax
bash -n script.sh

# Enable debug output
bash -x script.sh [options]
```

---

## Advanced Customization

### Modify Default Paths

Edit the configuration section:

```bash
# In simple-backup.sh
BACKUP_DEST="/mnt/backups"

# In log-analyzer.sh
LOG_FILE="/var/log/custom.log"

# In deployment-helper.sh
DEPLOY_APPS_DIR="/srv/apps"
```

### Add Custom Logging

Modify log functions to send to external systems:

```bash
# Send to syslog
log() {
    logger -t "my-script" "$@"
}

# Send to external server
log() {
    echo "$@" | nc -q 1 logserver.example.com 514
}
```

### Integration with Other Tools

**Ansible:**
```yaml
- name: Run backup
  shell: /usr/local/bin/simple-backup.sh --source /data

- name: Deploy application
  shell: /usr/local/bin/deployment-helper.sh --action deploy --app myapp
```

**Jenkins/CI-CD:**
```groovy
sh '/usr/local/bin/log-analyzer.sh --log build.log --errors'
sh '/usr/local/bin/deployment-helper.sh --action health --app app'
```

---

## Additional Resources

- Bash Manual: https://www.gnu.org/software/bash/manual/
- Advanced Bash Scripting: https://www.tldp.org/LDP/abs/html/
- ShellCheck for validation: https://www.shellcheck.net/
- Linux command man pages: `man [command]`

---

## Support & Contribution

For issues or improvements:
1. Check troubleshooting section
2. Review script comments
3. Test with `--dry-run` first
4. Check file permissions and paths
5. Enable verbose mode for details

---

**Version:** 1.0
**Last Updated:** 2024-01-15
**License:** Open source - free to use and modify
