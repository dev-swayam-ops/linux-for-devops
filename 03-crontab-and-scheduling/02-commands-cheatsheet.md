# Module 04: Crontab and Scheduling - Commands Cheatsheet

## Quick Reference: Essential Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `crontab -e` | Edit your personal crontab | `crontab -e` |
| `crontab -l` | List your current cron jobs | `crontab -l` |
| `crontab -r` | Remove your entire crontab | `crontab -r` |
| `sudo crontab -e -u user` | Edit another user's crontab | `sudo crontab -e -u postgres` |
| `sudo crontab -l -u user` | List another user's cron jobs | `sudo crontab -l -u www-data` |
| `crontab -i -r` | Prompt before removing crontab | `crontab -i -r` |
| `cat /var/log/syslog` | View cron execution logs (Ubuntu) | `grep CRON /var/log/syslog` |
| `tail -f /var/log/cron` | View cron logs live (RHEL/CentOS) | `tail -f /var/log/cron` |
| `systemctl restart cron` | Restart cron service (Ubuntu) | `sudo systemctl restart cron` |
| `systemctl restart crond` | Restart cron service (RHEL) | `sudo systemctl restart crond` |
| `systemctl status cron` | Check cron service status | `sudo systemctl status cron` |

## Common Cron Expression Patterns

### Time-Based Patterns

| Pattern | Meaning | Run Time |
|---------|---------|----------|
| `* * * * *` | Every minute | Every minute, all day |
| `0 * * * *` | Every hour | XX:00 (hourly) |
| `0 0 * * *` | Daily at midnight | 00:00 |
| `0 12 * * *` | Daily at noon | 12:00 |
| `0 0 * * 0` | Weekly (every Sunday) | Sunday 00:00 |
| `0 0 1 * *` | Monthly (first day) | 1st of month 00:00 |
| `0 0 1 1 *` | Yearly (Jan 1) | January 1st 00:00 |
| `*/5 * * * *` | Every 5 minutes | 00:00, 00:05, 00:10... |
| `0 */4 * * *` | Every 4 hours | 00:00, 04:00, 08:00, 12:00, 16:00, 20:00 |
| `0 9-17 * * 1-5` | Every hour, 9 AM-5 PM, weekdays | Each hour during business hours |
| `30 2 * * *` | Daily at 2:30 AM | 02:30 |
| `45 23 * * *` | Daily at 11:45 PM | 23:45 |
| `0 */2 * * *` | Every 2 hours | 00:00, 02:00, 04:00... |
| `0 0 1,15 * *` | Twice monthly | 1st and 15th at 00:00 |

### Business Day Patterns

| Pattern | Meaning |
|---------|---------|
| `0 9 * * 1-5` | Weekdays at 9 AM |
| `0 17 * * 1-5` | Weekdays at 5 PM |
| `0 9 * * 0,6` | Weekends at 9 AM |
| `*/15 8-18 * * 1-5` | Every 15 min, 8 AM-6 PM, weekdays |
| `0 12 * * 1-5` | Lunch time check (noon, weekdays) |

### Infrastructure Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| `0 2 * * *` | Nightly backup | Database dump |
| `0 3 1 * *` | Monthly maintenance | Log rotation, cleanup |
| `@daily` | Once daily | System updates |
| `@reboot` | After system restart | Start services |
| `*/5 * * * *` | Frequent monitoring | Health checks |

## Dangerous Commands ⚠️

**These can damage your system. Use with extreme caution:**

| Command | Danger | Safe Alternative |
|---------|--------|------------------|
| `0 0 * * * rm -rf /` | Deletes entire system | DON'T USE |
| `0 0 * * * :(){:\|:&};:` | Fork bomb (DoS) | DON'T USE |
| `*/1 * * * * dd if=/dev/urandom of=/dev/sda` | Overwrites disk | DON'T USE |
| `0 0 * * * kill -9 -1` | Kills all processes | Use systemctl instead |
| `0 0 * * * chown -R root / $(logname)` | Changes all ownership | Use specific paths only |
| `crontab -r` | Deletes all your jobs silently | Use `crontab -i -r` instead |

**Golden Rule**: Always use full paths, test scripts manually first, and have backups.

## Useful Command Combinations

### Backup with Timestamp

```bash
0 2 * * * tar -czf /backup/app-$(date +\%Y\%m\%d-\%H\%M\%S).tar.gz /app
```

### Run Only If Previous Completed

```bash
0 2 * * * [ ! -f /var/run/backup.lock ] && /usr/local/bin/backup.sh
```

### Log to File with Rotation

```bash
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1
```

### Email on Failure Only

```bash
0 2 * * * /usr/local/bin/backup.sh || echo "Backup failed" | mail -s "Alert" admin@example.com
```

### Run with Custom Environment

```bash
0 2 * * * export APP_ENV=production && /opt/app/deploy.sh
```

### Chain Multiple Commands

```bash
0 2 * * * (cd /app && ./setup.sh && ./backup.sh && ./cleanup.sh) >> /var/log/app.log 2>&1
```

### Conditional Execution (Only on Weekends)

```bash
0 10 * * 0,6 /usr/local/bin/weekend-maintenance.sh
```

### Prevent Overlapping Execution

```bash
*/15 * * * * flock -n /tmp/job.lock /usr/local/bin/job.sh || echo "Job already running"
```

## Quick Lookup by Use Case

### Database Tasks

```bash
# MySQL daily backup at 3 AM
0 3 * * * mysqldump -u root -ppassword --all-databases > /backup/mysql-$(date +%Y%m%d).sql

# PostgreSQL daily backup at 4 AM  
0 4 * * * pg_dump -U postgres mydb > /backup/postgres-$(date +%Y%m%d).sql

# MongoDB backup
0 2 * * * mongodump --out /backup/mongodb-$(date +%Y%m%d)
```

### Log Management

```bash
# Rotate logs daily
0 0 * * * logrotate /etc/logrotate.conf

# Clean old logs weekly
0 2 * * 0 find /var/log -type f -name "*.log" -mtime +30 -delete

# Archive logs monthly
0 0 1 * * tar -czf /archive/logs-$(date +%Y-%m).tar.gz /var/log/*.log
```

### Monitoring & Alerts

```bash
# Check disk space hourly
0 * * * * df -h | mail -s "Disk Report" admin@example.com

# Monitor process availability
*/5 * * * * pgrep -x mysqld || systemctl restart mysql

# System health check
*/15 * * * * /usr/local/bin/health-check.sh >> /var/log/health.log 2>&1
```

### Application Updates

```bash
# Update package lists daily
0 4 * * * apt-get update > /dev/null 2>&1

# Apply security updates
0 5 * * * apt-get upgrade -y >> /var/log/apt-upgrade.log 2>&1

# Deploy application
0 2 * * * cd /opt/app && git pull origin main && ./deploy.sh
```

### Cleanup Tasks

```bash
# Remove old temp files
0 3 * * * find /tmp -type f -mtime +7 -delete

# Clear package cache
0 2 * * 0 apt-get clean && apt-get autoclean

# Remove old backups
0 1 * * * find /backup -type f -mtime +30 -delete
```

### System Maintenance

```bash
# Update system time daily
0 0 * * * ntpdate ntp.ubuntu.com

# Check filesystem integrity weekly
0 4 * * 0 fsck -n /dev/sda1

# Sync filesystem caches
0 * * * * sync
```

## Environment Setup in Crontab

```bash
# Start with environment declarations
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
MAILTO=admin@example.com
LANG=en_US.UTF-8

# Then your actual cron jobs
0 2 * * * /usr/local/bin/backup.sh
```

## Troubleshooting Command Reference

### Check if Cron is Running

```bash
# Ubuntu/Debian
sudo systemctl status cron

# RHEL/CentOS
sudo systemctl status crond

# Verify process is running
ps aux | grep crond
```

### View Cron Logs

```bash
# Ubuntu/Debian
grep CRON /var/log/syslog | tail -20
sudo journalctl -u cron -n 50

# RHEL/CentOS
tail -50 /var/log/cron

# Watch logs in real-time
sudo journalctl -u cron -f
```

### Test a Cron Expression

```bash
# Install cron expression parser
npm install -g cron-parser
cron-parser "0 2 * * *"

# Or use online tools:
# https://crontab.guru/
```

### Verify Crontab Syntax

```bash
# Check if your crontab would load
crontab -l
# If no error, it's valid

# Before saving, manually test the command
/usr/local/bin/backup.sh

# Check exit status
echo $?  # 0 = success, non-zero = failure
```

### Debug Cron Execution

```bash
# Run job with all environment variables captured
env -i HOME=/root /bin/sh -c 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin; /usr/local/bin/backup.sh'

# Or add to crontab with debugging
0 2 * * * bash -x /usr/local/bin/backup.sh >> /var/log/backup-debug.log 2>&1
```

### Monitor a Job

```bash
# Watch a job run every minute
watch -n 60 'ps aux | grep backup.sh'

# Check if lock file exists
ls -la /var/run/*.lock

# View last execution time
stat /var/log/backup.log
```
