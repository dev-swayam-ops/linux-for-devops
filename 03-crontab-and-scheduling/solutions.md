# Crontab and Scheduling: Solutions

## Exercise 1: Basic Crontab Usage

**Solution:**

```bash
# View current crontab
crontab -l
# Output: no crontab for user (if empty) or list of jobs

# Edit crontab
crontab -e
# Add this line:
# Crontab for training purposes

# Save and exit (in nano: Ctrl+O, Enter, Ctrl+X)

# Verify entry
crontab -l
# Output:
# Crontab for training purposes
```

**Explanation:** Comments in crontab start with `#`. `crontab -l` lists current jobs, `crontab -e` opens editor.

---

## Exercise 2: Schedule a Daily Task

**Solution:**

```bash
# Create script
cat > daily_task.sh << 'EOF'
#!/bin/bash
echo "Daily task executed at $(date)"
EOF

# Make executable
chmod +x daily_task.sh

# Get full path
pwd  # Note the path, e.g., /home/user

# Add to crontab
crontab -e
# Add line:
# 0 15 * * * /home/user/daily_task.sh >> /home/user/daily_output.log 2>&1

# Verify
crontab -l
# Output:
# 0 15 * * * /home/user/daily_task.sh >> /home/user/daily_output.log 2>&1

# Test manually
./daily_task.sh

# Check output
cat daily_output.log
# Output:
# Daily task executed at Tue Jan 27 10:30:45 UTC 2026
```

**Explanation:** 
- `0 15 * * *` = 3:00 PM daily
- `>>` appends to log
- `2>&1` redirects errors to same log

---

## Exercise 3: Schedule Multiple Time Intervals

**Solution:**

```bash
# Edit crontab
crontab -e

# Add these entries:
# Every hour at minute 0
0 * * * * /usr/local/bin/hourly_task.sh

# Every 6 hours
0 */6 * * * /usr/local/bin/six_hourly.sh

# Every Monday at 9:00 AM
0 9 * * 1 /usr/local/bin/monday_task.sh

# Every 1st of month at midnight
0 0 1 * * /usr/local/bin/monthly_task.sh

# Verify
crontab -l
# Output shows all 4 entries
```

**Explanation:**
- `0 * * * *` = every hour at :00
- `0 */6` = every 6 hours
- `0 9 * * 1` = 9 AM Mondays (1=Monday)
- `0 0 1 * *` = midnight, 1st day of month

---

## Exercise 4: Handle Cron Output and Logging

**Solution:**

```bash
# Create script
cat > backup_task.sh << 'EOF'
#!/bin/bash
echo "Backup started"
sleep 2
echo "Backup completed"
EOF

chmod +x backup_task.sh

# Add to crontab with output redirection
crontab -e
# Add:
# 0 14 * * * /home/user/backup_task.sh >> /tmp/backup_success.log 2>> /tmp/backup_error.log

# Test manually
./backup_task.sh >> /tmp/backup_success.log 2>> /tmp/backup_error.log

# Check logs
cat /tmp/backup_success.log
# Output:
# Backup started
# Backup completed

cat /tmp/backup_error.log
# Output: (empty if no errors)
```

**Explanation:**
- `>>` appends stdout to success log
- `2>>` appends stderr to error log
- If no errors, error log remains empty

---

## Exercise 5: Create a Backup Schedule

**Solution:**

```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/tmp/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Copy files (example: from test directory)
if cp -r /tmp/test_files "$BACKUP_PATH/"; then
    echo "Backup successful at $(date)" >> /var/log/backup.log
    exit 0
else
    echo "Backup FAILED at $(date)" >> /var/log/backup_error.log
    exit 1
fi
EOF

chmod +x backup.sh

# Add to crontab
crontab -e
# Add:
# 0 2 * * * /home/user/backup.sh >> /var/log/backup.log 2>> /var/log/backup_error.log

# Verify
crontab -l
```

**Explanation:** Script runs daily at 2:00 AM with error logging. Uses timestamp for unique directory names.

---

## Exercise 6: Monitor Cron Job Execution

**Solution:**

```bash
# Add test cron job
crontab -e
# Add:
# * * * * * echo "Test cron job" >> /tmp/cron_test.log

# Wait 5 minutes and check execution
sleep 300

# Check logs - systemd systems
journalctl -u cron | tail -10

# Check logs - syslog systems
grep CRON /var/log/syslog | tail -10
# Output:
# Jan 27 10:00:01 hostname CRON[1234]: (user) CMD (echo "Test cron job" >> /tmp/cron_test.log)
# Jan 27 10:01:01 hostname CRON[1235]: (user) CMD (echo "Test cron job" >> /tmp/cron_test.log)

# Count executions
grep CRON /var/log/syslog | wc -l
# Output: (shows how many cron runs occurred)

# Remove test job
crontab -r
```

**Explanation:** Every minute job runs 60 times per hour, so 5 minutes = ~5 executions.

---

## Exercise 7: Cron Job with Environment Variables

**Solution:**

```bash
# Create script using environment variable
cat > env_script.sh << 'EOF'
#!/bin/bash
echo "MYVAR is: $MYVAR"
/usr/bin/env
EOF

chmod +x env_script.sh

# Add to crontab with variables
crontab -e
# Add:
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
# MYVAR=myvalue
# 0 1 * * * /home/user/env_script.sh >> /tmp/env.log

# Test manually first
export MYVAR=myvalue
./env_script.sh

# Check cron execution in log
grep MYVAR /tmp/env.log
```

**Explanation:** 
- Cron has limited default PATH
- Set PATH and variables at top of crontab
- Applies to all jobs below it

---

## Exercise 8: Conditional Scheduling

**Solution:**

```bash
# Create conditional script
cat > conditional_task.sh << 'EOF'
#!/bin/bash

TESTFILE="/tmp/testfile.txt"
LOGFILE="/tmp/conditional.log"

if [ -f "$TESTFILE" ]; then
    echo "$(date): File exists - processing" >> "$LOGFILE"
else
    echo "$(date): File not found - skipping" >> "$LOGFILE"
fi
EOF

chmod +x conditional_task.sh

# Add to crontab
crontab -e
# Add:
# */10 * * * * /home/user/conditional_task.sh

# Test by creating file
touch /tmp/testfile.txt

# Wait 10 minutes and check log
cat /tmp/conditional.log
# Output:
# Tue Jan 27 10:10:00 UTC 2026: File exists - processing

# Remove file
rm /tmp/testfile.txt

# Wait and check again
cat /tmp/conditional.log
# Output:
# Tue Jan 27 10:20:00 UTC 2026: File not found - skipping
```

**Explanation:** Script checks condition every 10 minutes and logs different outputs.

---

## Exercise 9: System Resource Monitoring

**Solution:**

```bash
# Create monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash

LOGFILE="/tmp/monitor.log"

{
    echo "=== $(date) ==="
    echo "Disk Usage:"
    df -h / | tail -1
    echo ""
    echo "Memory Usage:"
    free -h | grep Mem:
    echo ""
} >> "$LOGFILE"
EOF

chmod +x monitor.sh

# Add to crontab
crontab -e
# Add:
# 0 * * * * /home/user/monitor.sh

# Check log after multiple runs
cat /tmp/monitor.log
# Output:
# === Tue Jan 27 10:00:00 UTC 2026 ===
# Disk Usage:
# /dev/sda1  20G  5.2G  14G  28%  /
# 
# Memory Usage:
# Mem:      15Gi    3.2Gi    8.5Gi   256Mi    3.2Gi    11Gi
```

**Explanation:** Uses `df` and `free` to monitor system resources hourly.

---

## Exercise 10: Manage Multiple Cron Jobs

**Solution:**

```bash
# Create three scripts
cat > cleanup.sh << 'EOF'
#!/bin/bash
find /tmp -name "*.old" -delete
echo "Cleanup done: $(date)" >> /var/log/cleanup.log
EOF

cat > report.sh << 'EOF'
#!/bin/bash
echo "Report: $(date)" >> /var/log/report.log
echo "Disk: $(df -h / | tail -1)" >> /var/log/report.log
EOF

cat > notify.sh << 'EOF'
#!/bin/bash
echo "Notification: $(date)" >> /var/log/notify.log
EOF

chmod +x cleanup.sh report.sh notify.sh

# Add to crontab
crontab -e
# Add:
# 0 3 * * * /home/user/cleanup.sh
# 0 6 * * * /home/user/report.sh
# 30 * * * * /home/user/notify.sh

# Export to file
crontab -l > my_crontab.txt

# Remove all
crontab -r

# Verify removed
crontab -l
# Output: no crontab for user

# Restore from file
crontab my_crontab.txt

# Verify restored
crontab -l
# Output shows all 3 jobs restored
```

**Explanation:** Demonstrates full crontab lifecycle: create, export, remove, restore.
