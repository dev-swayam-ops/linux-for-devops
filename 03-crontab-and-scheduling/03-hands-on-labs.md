# Module 04: Crontab and Scheduling - Hands-On Labs

## Lab Overview

These 8 labs progress from basic cron usage to production-quality automation. Each lab should take 15-30 minutes to complete. You'll learn by doing, starting with simple jobs and advancing to complex scheduling scenarios with proper error handling and logging.

**Prerequisites:**
- Linux system with cron installed (`sudo apt-get install cron` or `sudo yum install cronie`)
- Sudo access
- Text editor (nano or vi)
- Ability to create files in `/tmp` and `/var/log`
- Basic shell scripting knowledge

---

## Lab 1: Your First Cron Job

### Goal
Create your first cron job that runs a simple command and verify it executes correctly.

### Setup
```bash
# Create a test directory
mkdir -p ~/cron-labs
cd ~/cron-labs

# Verify cron is running
systemctl status cron  # or crond on RHEL

# Create a simple test script
cat > test-script.sh << 'EOF'
#!/bin/bash
echo "Cron job executed at $(date)" >> ~/cron-labs/output.log
EOF

chmod +x test-script.sh
```

### Steps

1. **Open your crontab editor:**
   ```bash
   crontab -e
   ```

2. **Add this line to run every 2 minutes (for testing):**
   ```bash
   */2 * * * * ~/cron-labs/test-script.sh
   ```

3. **Save and exit** (vi: `:wq`, nano: `Ctrl+X` then `Y`)

4. **Verify the job was added:**
   ```bash
   crontab -l
   ```

5. **Wait 2-3 minutes and check the log:**
   ```bash
   cat ~/cron-labs/output.log
   ```

6. **Expected Output:**
   ```
   Cron job executed at Mon Jan 14 10:15:00 UTC 2026
   Cron job executed at Mon Jan 14 10:17:00 UTC 2026
   Cron job executed at Mon Jan 14 10:19:00 UTC 2026
   ```

### Verification Checklist
- [ ] Crontab entry saved (verified with `crontab -l`)
- [ ] Output file created and contains entries
- [ ] Multiple entries show correct 2-minute intervals
- [ ] Timestamps show reasonable times

### Common Issues

**Issue: "Permission denied" error**
```
Solution: Make script executable with: chmod +x test-script.sh
```

**Issue: Output file never created**
```
Solution: Check cron logs with: grep CRON /var/log/syslog
          Likely causes: PATH not set, wrong file path, script has errors
```

**Issue: Job runs but output isn't in log file**
```
Solution: Cron email output instead. Check: crontab without MAILTO=""
          Add to crontab: MAILTO="" to suppress emails
```

### Cleanup
```bash
# Remove the cron job
crontab -r

# Remove test files
rm -rf ~/cron-labs
```

---

## Lab 2: Managing Multiple Cron Jobs

### Goal
Create and manage multiple cron jobs with different schedules and understand system crontabs.

### Setup
```bash
# Create scripts directory
mkdir -p ~/cron-labs/scripts
cd ~/cron-labs

# Script 1: Hourly job
cat > scripts/hourly-task.sh << 'EOF'
#!/bin/bash
echo "Hourly task ran at $(date)" >> /tmp/hourly.log
EOF

# Script 2: Daily job
cat > scripts/daily-task.sh << 'EOF'
#!/bin/bash
echo "Daily task ran at $(date +%Y-%m-%d)" >> /tmp/daily.log
EOF

# Make them executable
chmod +x scripts/*.sh

# Create a crontab file
cat > mycrontab << 'EOF'
# Hourly task - run at the top of every hour
0 * * * * ~/cron-labs/scripts/hourly-task.sh

# Daily task - run at 9 AM every day
0 9 * * * ~/cron-labs/scripts/daily-task.sh

# Weekly backup - every Sunday at 2 AM
0 2 * * 0 tar -czf /tmp/backup-$(date +%s).tar.gz ~/cron-labs/

# Multiple times per day - every 6 hours starting at midnight
0 0,6,12,18 * * * echo "System status at $(date)" >> /tmp/status.log
EOF
```

### Steps

1. **Install the new crontab from file:**
   ```bash
   crontab mycrontab
   ```

2. **Verify all jobs are installed:**
   ```bash
   crontab -l
   ```

3. **Check the system crontab (view only):**
   ```bash
   sudo cat /etc/crontab
   sudo ls /etc/cron.d/
   ```

4. **List current cron job count:**
   ```bash
   crontab -l | grep -v "^#" | grep -v "^$" | wc -l
   ```

5. **Wait for some jobs to execute and check logs:**
   ```bash
   # Wait for at least the top of the hour
   tail /tmp/hourly.log /tmp/status.log
   ```

### Expected Output
```
==> /tmp/hourly.log <==
Hourly task ran at Mon Jan 14 10:00:01 UTC 2026

==> /tmp/status.log <==
System status at Mon Jan 14 00:00:02 UTC 2026
System status at Mon Jan 14 06:00:01 UTC 2026
```

### Verification Checklist
- [ ] Crontab shows 4 active jobs (comments don't count)
- [ ] Each job has correct syntax (minute hour day month weekday)
- [ ] Hourly job runs at the start of each hour
- [ ] System crontab files are readable
- [ ] Can distinguish between user and system crontabs

### Common Issues

**Issue: "Can't find crontab file" error when installing**
```
Solution: Use absolute paths or ensure file exists: cat ~/cron-labs/mycrontab
```

**Issue: Jobs don't run at specified times**
```
Solution: Verify system time: date
          Check cron service: systemctl status cron
          View logs: grep CRON /var/log/syslog
```

### Cleanup
```bash
crontab -r
rm -rf ~/cron-labs
rm /tmp/hourly.log /tmp/daily.log /tmp/backup-*.tar.gz /tmp/status.log
```

---

## Lab 3: Environment Variables and Paths

### Goal
Understand how cron environment differs from your shell, and how to properly set variables.

### Setup
```bash
mkdir -p ~/cron-labs
cd ~/cron-labs

# Create a script that uses environment variables
cat > test-env.sh << 'EOF'
#!/bin/bash
echo "PATH=$PATH" >> /tmp/env-test.log
echo "HOME=$HOME" >> /tmp/env-test.log
echo "USER=$USER" >> /tmp/env-test.log
echo "PWD=$PWD" >> /tmp/env-test.log
echo "Working dir: $(pwd)" >> /tmp/env-test.log
echo "---" >> /tmp/env-test.log
EOF

chmod +x test-env.sh

# First, run it directly to see normal environment
./test-env.sh
echo "=== DIRECT EXECUTION ===" 
cat /tmp/env-test.log
```

### Steps

1. **Create a crontab WITHOUT proper environment variables:**
   ```bash
   cat > crontab1 << 'EOF'
# No environment variables set - cron defaults
* * * * * ~/cron-labs/test-env.sh
EOF
   
   crontab crontab1
   ```

2. **Wait for the next minute and check output:**
   ```bash
   sleep 65
   tail -5 /tmp/env-test.log
   ```

3. **Now create a crontab WITH proper environment variables:**
   ```bash
   cat > crontab2 << 'EOF'
# Proper environment setup
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
HOME=/home/$(whoami)
MAILTO=""

* * * * * ~/cron-labs/test-env.sh
EOF
   
   crontab crontab2
   ```

4. **Wait and check the difference:**
   ```bash
   sleep 65
   tail -10 /tmp/env-test.log
   ```

5. **Compare the outputs:**
   ```bash
   cat /tmp/env-test.log
   ```

### Expected Output

First execution (without env setup):
```
PATH=                          # ← EMPTY!
HOME=                          # ← EMPTY!
USER=                          # ← Empty
PWD=/var/spool/cron/          # ← Wrong directory!
Working dir: /var/spool/cron/
---
```

Second execution (with proper env):
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin  # ✓ Correct
HOME=/home/username                                      # ✓ Correct
USER=username                                            # ✓ Set
PWD=/var/spool/cron/                                     # Still wrong (cron limitation)
Working dir: /var/spool/cron/
---
```

### Verification Checklist
- [ ] Can see difference between direct execution and cron execution
- [ ] Understand why explicit PATH is needed
- [ ] Know that PWD will always be /var/spool/cron/ in cron
- [ ] Can set environment variables in crontab

### Common Issues

**Issue: Script works fine when run directly but fails in cron**
```
Solution: Set explicit PATH in crontab with all directories where commands live
```

**Issue: Commands like "grep" don't work in cron**
```
Solution: Use absolute paths: /bin/grep or /usr/bin/grep instead of just grep
```

### Cleanup
```bash
crontab -r
rm -rf ~/cron-labs
rm /tmp/env-test.log
```

---

## Lab 4: Scheduling Real Backups

### Goal
Create a realistic backup job with logging, error handling, and proper scheduling.

### Setup
```bash
mkdir -p ~/cron-labs/{source,backups,logs}
cd ~/cron-labs

# Create test data to backup
echo "Database content" > source/db.sql
echo "Config file" > source/app.config
echo "User list" > source/users.txt

# Create professional backup script
cat > backup.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Configuration
BACKUP_DIR="/home/$(whoami)/cron-labs/backups"
SOURCE_DIR="/home/$(whoami)/cron-labs/source"
LOG_FILE="/home/$(whoami)/cron-labs/logs/backup.log"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Error handler
trap 'log "ERROR: Backup failed"; exit 1' ERR

# Main backup logic
log "Starting backup from $SOURCE_DIR"

# Check source exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Source directory not found"
    exit 1
fi

# Create backup
tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>> "$LOG_FILE"

# Verify backup
if [ ! -f "$BACKUP_FILE" ]; then
    log "ERROR: Backup file was not created"
    exit 1
fi

# Get size
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log "Backup successful: $BACKUP_FILE ($SIZE)"

# Cleanup old backups (keep only 5)
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/backup-*.tar.gz | wc -l)
if [ "$BACKUP_COUNT" -gt 5 ]; then
    REMOVE_COUNT=$((BACKUP_COUNT - 5))
    ls -t1 "$BACKUP_DIR"/backup-*.tar.gz | tail -n "$REMOVE_COUNT" | xargs rm -v >> "$LOG_FILE"
    log "Removed $REMOVE_COUNT old backups"
fi

log "Backup process completed successfully"
EOF

chmod +x backup.sh

# Test the script directly
./backup.sh
echo "--- Direct execution log ---"
cat logs/backup.log
```

### Steps

1. **Create a crontab for regular backups:**
   ```bash
   cat > mycrontab << 'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
MAILTO=""
HOME=/home/$(whoami)

# Backup every 6 hours
0 0,6,12,18 * * * /home/$(whoami)/cron-labs/backup.sh

EOF
   
   # Replace $(whoami) with actual username first
   USERNAME=$(whoami)
   sed -i "s|\$(whoami)|$USERNAME|g" mycrontab
   
   crontab mycrontab
   ```

2. **Verify the cron job:**
   ```bash
   crontab -l
   ```

3. **Simulate multiple backups by running manually at different times:**
   ```bash
   # Run backup multiple times
   for i in {1..3}; do
       ./backup.sh
       sleep 2
   done
   ```

4. **Check the logs:**
   ```bash
   cat logs/backup.log
   ```

5. **Verify backups were created and old ones removed:**
   ```bash
   ls -lh backups/
   ```

### Expected Output

Log file should contain:
```
[2026-01-14 10:00:00] Starting backup from /home/user/cron-labs/source
[2026-01-14 10:00:01] Backup successful: /home/user/cron-labs/backups/backup-20260114-100000.tar.gz (4.0K)
[2026-01-14 10:00:01] Backup process completed successfully
[2026-01-14 10:00:03] Starting backup from /home/user/cron-labs/source
[2026-01-14 10:00:03] Backup successful: /home/user/cron-labs/backups/backup-20260114-100003.tar.gz (4.0K)
...
[2026-01-14 10:00:07] Removed 1 old backups
```

Backups directory:
```
-rw-r--r-- 1 user user 4.0K Jan 14 10:00 backup-20260114-100001.tar.gz
-rw-r--r-- 1 user user 4.0K Jan 14 10:00 backup-20260114-100003.tar.gz
-rw-r--r-- 1 user user 4.0K Jan 14 10:00 backup-20260114-100005.tar.gz
```

### Verification Checklist
- [ ] Backup script runs successfully manually
- [ ] Cron job is installed and scheduled for 6-hour intervals
- [ ] Backups are created with proper timestamps
- [ ] Old backups are automatically cleaned up
- [ ] Log file has detailed timestamps and messages
- [ ] Error handling works (trap exits on failure)

### Common Issues

**Issue: Backup fails due to permissions**
```
Solution: Ensure directories are writable: chmod 755 ~/cron-labs/{source,backups,logs}
```

**Issue: tar command not found in cron**
```
Solution: Use absolute path: /bin/tar or /usr/bin/tar in the script
```

### Cleanup
```bash
crontab -r
rm -rf ~/cron-labs
```

---

## Lab 5: Monitoring and Alerts

### Goal
Create a monitoring job that checks system health and sends alerts on failure.

### Setup
```bash
mkdir -p ~/cron-labs/scripts
cd ~/cron-labs

# Create monitoring script with email on failure
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Configuration
ALERT_THRESHOLD_DISK=80
ALERT_THRESHOLD_MEMORY=85
ALERT_THRESHOLD_CPU=75
LOG_FILE="/tmp/health-check.log"
ALERT_EMAIL="admin@example.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

ALERT_TRIGGERED=0
ALERT_MESSAGE=""

log "=== System Health Check ==="

# Check Disk Space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
log "Disk Usage: $DISK_USAGE%"
if [ "$DISK_USAGE" -gt "$ALERT_THRESHOLD_DISK" ]; then
    ALERT_TRIGGERED=1
    ALERT_MESSAGE+="DISK ALERT: $DISK_USAGE% used (threshold: $ALERT_THRESHOLD_DISK%)\n"
    log "${RED}ALERT: High disk usage${NC}"
fi

# Check Memory
MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
log "Memory Usage: $MEMORY_USAGE%"
if [ "$MEMORY_USAGE" -gt "$ALERT_THRESHOLD_MEMORY" ]; then
    ALERT_TRIGGERED=1
    ALERT_MESSAGE+="MEMORY ALERT: $MEMORY_USAGE% used (threshold: $ALERT_THRESHOLD_MEMORY%)\n"
    log "${RED}ALERT: High memory usage${NC}"
fi

# Check Load Average
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}')
CPU_COUNT=$(nproc)
LOAD_PER_CPU=$(echo "scale=2; $LOAD / $CPU_COUNT" | bc)
log "Load Average: $LOAD (per CPU: $LOAD_PER_CPU)"
if (( $(echo "$LOAD_PER_CPU > $ALERT_THRESHOLD_CPU" | bc -l) )); then
    ALERT_TRIGGERED=1
    ALERT_MESSAGE+="CPU ALERT: Load average $LOAD_PER_CPU per CPU (threshold: $ALERT_THRESHOLD_CPU)\n"
    log "${RED}ALERT: High CPU load${NC}"
fi

# Check if critical services are running
SERVICES=("cron" "sshd")
for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        log "${GREEN}Service $service: running${NC}"
    else
        ALERT_TRIGGERED=1
        ALERT_MESSAGE+="SERVICE ALERT: $service is not running\n"
        log "${RED}ALERT: Service $service is DOWN${NC}"
    fi
done

# Send alert if threshold exceeded
if [ "$ALERT_TRIGGERED" -eq 1 ]; then
    log "${RED}ALERTS DETECTED - Sending notification${NC}"
    echo -e "$ALERT_MESSAGE" | mail -s "System Health Alert - $(hostname)" "$ALERT_EMAIL" 2>/dev/null || \
    echo "Note: Email not configured, but alert would be sent to $ALERT_EMAIL"
fi

log "Health check completed"
echo "---"
```

chmod +x scripts/health-check.sh
```

### Steps

1. **Run the health check script manually:**
   ```bash
   ~/cron-labs/scripts/health-check.sh
   ```

2. **View the log:**
   ```bash
   cat /tmp/health-check.log
   ```

3. **Create a crontab for regular monitoring:**
   ```bash
   cat > mycrontab << 'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
MAILTO=""

# Run health check every 30 minutes during business hours
*/30 9-17 * * 1-5 /home/$(whoami)/cron-labs/scripts/health-check.sh

# Run hourly monitoring
0 * * * * /home/$(whoami)/cron-labs/scripts/health-check.sh

EOF
   
   # Replace $(whoami)
   USERNAME=$(whoami)
   sed -i "s|\$(whoami)|$USERNAME|g" mycrontab
   
   crontab mycrontab
   ```

4. **Check the crontab:**
   ```bash
   crontab -l
   ```

### Expected Output

Health check output:
```
[2026-01-14 10:00:00] === System Health Check ===
[2026-01-14 10:00:00] Disk Usage: 35%
[2026-01-14 10:00:00] Memory Usage: 45%
[2026-01-14 10:00:00] Load Average: 0.85
[2026-01-14 10:00:01] Service cron: running
[2026-01-14 10:00:01] Service sshd: running
[2026-01-14 10:00:01] Health check completed
---
```

### Verification Checklist
- [ ] Health check script runs without errors
- [ ] All system metrics are reported
- [ ] Log file is created with timestamps
- [ ] Cron jobs schedule monitoring at correct intervals
- [ ] Can modify alert thresholds

### Common Issues

**Issue: mail command not found**
```
Solution: Install mailutils: sudo apt-get install mailutils
          Or suppress mail: MAILTO="" in crontab
```

**Issue: bc command not found**
```
Solution: Install bc: sudo apt-get install bc
          Or use awk instead of bc for calculations
```

### Cleanup
```bash
crontab -r
rm -rf ~/cron-labs
rm /tmp/health-check.log
```

---

## Lab 6: Advanced Scheduling with Conditional Logic

### Goal
Create jobs that execute only under certain conditions (advanced patterns).

### Setup
```bash
mkdir -p ~/cron-labs/scripts
cd ~/cron-labs

# Script that runs only if another job completed
cat > scripts/dependent-job.sh << 'EOF'
#!/bin/bash
LOCKFILE="/tmp/job.lock"
MAX_AGE=3600  # 1 hour in seconds

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /tmp/job-execution.log
}

# Check if another job is running
if [ -f "$LOCKFILE" ]; then
    LOCK_AGE=$(($(date +%s) - $(stat -c %Y "$LOCKFILE")))
    if [ "$LOCK_AGE" -lt "$MAX_AGE" ]; then
        log "Previous job still running (lock age: $LOCK_AGE seconds)"
        exit 0
    else
        log "Lock file stale, removing and proceeding"
        rm "$LOCKFILE"
    fi
fi

# Create lock
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

log "Starting dependent job"
sleep 5  # Simulate work
log "Dependent job completed"
EOF

chmod +x scripts/dependent-job.sh

# Script that runs only on specific conditions
cat > scripts/conditional-job.sh << 'EOF'
#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /tmp/conditional.log
}

# Only run if disk has less than 90% usage
DISK_USAGE=$(df /home | awk 'NR==2 {print $5}' | cut -d'%' -f1)
if [ "$DISK_USAGE" -gt 90 ]; then
    log "Disk usage $DISK_USAGE% exceeds threshold - skipping"
    exit 0
fi

# Only run on weekdays
if [ "$(date +%w)" -eq 0 ] || [ "$(date +%w)" -eq 6 ]; then
    log "Weekends excluded - skipping"
    exit 0
fi

log "All conditions met - executing job"
log "Disk usage: $DISK_USAGE%, Day of week: $(date +%w)"
EOF

chmod +x scripts/conditional-job.sh
```

### Steps

1. **Install a crontab with conditional logic:**
   ```bash
   cat > mycrontab << 'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
MAILTO=""

# Run every minute - will skip if previous still running
* * * * * /home/$(whoami)/cron-labs/scripts/dependent-job.sh

# Run weekday business hours - will skip on weekends or high disk
*/5 9-17 * * * /home/$(whoami)/cron-labs/scripts/conditional-job.sh

EOF
   
   USERNAME=$(whoami)
   sed -i "s|\$(whoami)|$USERNAME|g" mycrontab
   
   crontab mycrontab
   ```

2. **Trigger multiple executions by running manually:**
   ```bash
   # Run first job three times
   for i in {1..3}; do
       ~/cron-labs/scripts/dependent-job.sh
   done
   ```

3. **Check logs to see conditional behavior:**
   ```bash
   cat /tmp/job-execution.log
   cat /tmp/conditional.log
   ```

### Expected Output

Job execution log:
```
[2026-01-14 10:00:00] Starting dependent job
[2026-01-14 10:00:05] Dependent job completed
[2026-01-14 10:00:05] Starting dependent job
[2026-01-14 10:00:10] Dependent job completed
[2026-01-14 10:00:10] Starting dependent job
[2026-01-14 10:00:15] Dependent job completed
```

Conditional log:
```
[2026-01-14 10:05:00] All conditions met - executing job
[2026-01-14 10:05:00] Disk usage: 35%, Day of week: 2
```

### Verification Checklist
- [ ] Lock mechanism prevents overlapping execution
- [ ] Jobs skip execution based on conditions
- [ ] Log files show decision logic
- [ ] Cron jobs schedule correctly

### Cleanup
```bash
crontab -r
rm -rf ~/cron-labs
rm /tmp/job-execution.log /tmp/conditional.log /tmp/job.lock
```

---

## Lab 7: System Crontab and Root Jobs

### Goal
Understand system-wide crontab and how root cron jobs differ from user jobs.

### Setup
```bash
# View system crontab
sudo cat /etc/crontab

# Check cron.d directory
sudo ls -la /etc/cron.d/
```

### Steps

1. **Create a system-wide cron job in /etc/cron.d/:**
   ```bash
   sudo cat > /etc/cron.d/system-monitoring << 'EOF'
# System monitoring cron jobs
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
MAILTO=root

# Monitor every 10 minutes (note: includes username field)
*/10 * * * * root /usr/local/bin/system-check.sh

# Daily cleanup at 3 AM
0 3 * * * root /usr/local/bin/cleanup.sh

EOF
   ```

2. **Create the monitoring scripts:**
   ```bash
   sudo cat > /usr/local/bin/system-check.sh << 'EOF'
#!/bin/bash
echo "System check at $(date)" >> /var/log/system-check.log
df -h >> /var/log/system-check.log
free -h >> /var/log/system-check.log
echo "---" >> /var/log/system-check.log
EOF
   
   sudo chmod +x /usr/local/bin/system-check.sh
   ```

3. **Verify system crontab:**
   ```bash
   sudo crontab -l
   sudo cat /etc/cron.d/system-monitoring
   ```

4. **Check logs:**
   ```bash
   sudo tail -20 /var/log/system-check.log
   ```

### Expected Output

System check log:
```
System check at Mon Jan 14 10:00:00 UTC 2026
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       50G   10G   40G  20% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
              total        used        free      shared  buff/cache   available
Mem:           7.8Gi       2.0Gi       3.0Gi      100Mi       2.7Gi       5.3Gi
---
```

### Verification Checklist
- [ ] System crontab file created in /etc/cron.d/
- [ ] File includes username field for each job
- [ ] Root jobs have correct permissions
- [ ] Jobs execute with root privileges
- [ ] MAILTO is set for system notifications

### Common Issues

**Issue: Permission denied when creating /etc/cron.d/ files**
```
Solution: Use sudo: sudo cat > /etc/cron.d/filename
```

**Issue: Scripts in /usr/local/bin not found**
```
Solution: Ensure full path and file is executable: sudo chmod +x /usr/local/bin/script.sh
```

### Cleanup
```bash
sudo rm /etc/cron.d/system-monitoring
sudo rm /usr/local/bin/system-check.sh /usr/local/bin/cleanup.sh
sudo rm /var/log/system-check.log
```

---

## Lab 8: Troubleshooting Real Problems

### Goal
Diagnose and fix common cron problems using logs and debugging techniques.

### Setup
```bash
mkdir -p ~/cron-labs/scripts
cd ~/cron-labs

# Create problem scripts to debug

# Problem 1: Script with broken PATH
cat > scripts/broken-path.sh << 'EOF'
#!/bin/bash
echo "Starting backup"
mysqldump -u root mydb > /tmp/backup.sql
echo "Backup complete"
EOF

# Problem 2: Script with wrong permissions
cat > scripts/no-permission.sh << 'EOF'
#!/bin/bash
echo "This script will fail" >> /var/log/special.log
EOF

# Problem 3: Script with non-existent directory
cat > scripts/bad-directory.sh << 'EOF'
#!/bin/bash
cd /nonexistent
echo "Hello" > file.txt
EOF

chmod +x scripts/broken-path.sh
# Note: no-permission.sh is intentionally not executable

# Create crontab with problems
cat > mycrontab << 'EOF'
SHELL=/bin/bash
MAILTO=""

# Missing PATH - mysqldump won't be found
* * * * * /home/$(whoami)/cron-labs/scripts/broken-path.sh

# Will fail due to permissions
* * * * * /home/$(whoami)/cron-labs/scripts/no-permission.sh

# Will fail - directory doesn't exist
* * * * * /home/$(whoami)/cron-labs/scripts/bad-directory.sh
EOF

USERNAME=$(whoami)
sed -i "s|\$(whoami)|$USERNAME|g" mycrontab
```

### Steps

1. **Install the broken crontab:**
   ```bash
   crontab mycrontab
   crontab -l
   ```

2. **Check cron logs to find the problems:**
   ```bash
   # On Ubuntu/Debian
   sudo journalctl -u cron -n 20
   
   # Or check syslog
   grep CRON /var/log/syslog | tail -20
   ```

3. **Try running scripts manually to understand failures:**
   ```bash
   # This will show the actual error
   ~/cron-labs/scripts/broken-path.sh
   
   # This will show permission error
   ~/cron-labs/scripts/no-permission.sh
   
   # This will show directory error
   ~/cron-labs/scripts/bad-directory.sh
   ```

4. **Fix the scripts:**
   ```bash
   # Fix Problem 1: Add PATH
   cat > scripts/broken-path.sh << 'EOF'
#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
echo "Starting backup"
/usr/bin/mysqldump -u root mydb > /tmp/backup.sql 2>/dev/null || echo "mysqldump not available"
echo "Backup complete"
EOF
   
   # Fix Problem 2: Make executable
   chmod +x scripts/no-permission.sh
   
   # Fix Problem 3: Create directory first
   cat > scripts/bad-directory.sh << 'EOF'
#!/bin/bash
WORKDIR="/home/$(whoami)/cron-labs/work"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo "Hello" > file.txt
echo "File created in $WORKDIR"
EOF
   chmod +x scripts/bad-directory.sh
   ```

5. **Create fixed crontab:**
   ```bash
   cat > mycrontab-fixed << 'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
MAILTO=""

# Fixed: Explicit PATH set, absolute command path, error handling
*/15 * * * * /home/$(whoami)/cron-labs/scripts/broken-path.sh >> /home/$(whoami)/cron-labs/logs/backup.log 2>&1

# Fixed: Now executable
*/15 * * * * /home/$(whoami)/cron-labs/scripts/no-permission.sh >> /home/$(whoami)/cron-labs/logs/perm.log 2>&1

# Fixed: Creates directory before use
*/15 * * * * /home/$(whoami)/cron-labs/scripts/bad-directory.sh >> /home/$(whoami)/cron-labs/logs/dir.log 2>&1
EOF
   
   USERNAME=$(whoami)
   sed -i "s|\$(whoami)|$USERNAME|g" mycrontab-fixed
   
   crontab mycrontab-fixed
   ```

6. **Monitor the fixed jobs:**
   ```bash
   mkdir -p logs
   
   # Wait a bit and check logs
   sleep 65
   tail -f logs/*.log
   ```

### Expected Results

After fixes, logs should show:
```
Starting backup
Backup complete
  [or: mysqldump not available]
File created in /home/username/cron-labs/work
```

### Verification Checklist
- [ ] Can identify problems in cron logs
- [ ] Know how to manually test scripts
- [ ] Understand role of PATH in cron failures
- [ ] Can fix permission issues
- [ ] Understand working directory limitations
- [ ] Can create proper logging for debugging

### Cleanup
```bash
crontab -r
rm -rf ~/cron-labs
```

---

## Summary

You've completed 8 comprehensive labs covering:
1. Basic cron job creation
2. Managing multiple jobs
3. Environment variables and PATH issues
4. Production backup scripts
5. System monitoring and alerts
6. Advanced conditional scheduling
7. System-wide cron jobs
8. Troubleshooting real problems

**Next: Review the scripts in the scripts/ folder for ready-to-use templates!**
