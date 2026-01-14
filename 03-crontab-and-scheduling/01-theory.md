# Module 04: Crontab and Scheduling - Theory & Concepts

## Architecture Overview

The cron system consists of three main components:

1. **crond (daemon)**: Background process that wakes up every minute to check if jobs need to run
2. **crontab files**: Text files containing job definitions located in `/var/spool/cron/crontabs/` (or `/var/spool/cron/` on some systems)
3. **at daemon (atd)**: Separate daemon for one-time scheduled tasks

### Cron Startup Flow

When your Linux system boots:

1. **Init system** (systemd or initV) reads startup scripts
2. **crond process** starts as a system service with root privileges
3. crond **loads all crontab files** into memory from `/var/spool/cron/crontabs/`
4. **Every 60 seconds**, crond wakes up and checks if any jobs should run
5. **For matching jobs**, crond forks a new process and executes the command
6. **Output captured** and sent to MAILTO address (or to syslog)

### Crontab File Locations

```
/etc/crontab                     ← System-wide crontab (edited by root)
/etc/cron.d/                     ← System cron jobs (individual files)
/etc/cron.hourly/                ← Scripts run hourly
/etc/cron.daily/                 ← Scripts run daily  
/etc/cron.weekly/                ← Scripts run weekly
/etc/cron.monthly/               ← Scripts run monthly
/var/spool/cron/crontabs/        ← User crontabs (one file per user)
/var/spool/cron/                 ← Alternative location on some systems
```

## Key Concepts

### 1. Cron Expression Syntax

Every cron job line follows this exact format:

```
minute  hour  day-of-month  month  day-of-week  command
0-59    0-23  1-31         1-12   0-6(0=Sun)
```

**Field Details:**

| Field | Range | Allowed Values | Notes |
|-------|-------|----------------|-------|
| Minute | 0-59 | 0,5,10...59 or */5 | When to run |
| Hour | 0-23 | 0,6,12,18 or 0-6 | 24-hour format (0=midnight) |
| Day of Month | 1-31 | 1,15,28 or 1-7 | Skips days that don't exist (e.g., Feb 30) |
| Month | 1-12 | 1,6,12 or JAN,JUN,DEC | Can use names or numbers |
| Day of Week | 0-6 | 0,3,5 or SUN,WED,FRI | 0=Sunday, 7 also equals Sunday |
| Command | - | Full path to command | Must be absolute path |

**Special Characters:**

- **`*`** = Every value (wildcard)
- **`,`** = List specific values: `0,6,12,18` (at these hours)
- **`-`** = Range: `1-5` (days 1 through 5)
- **`/`** = Step values: `*/15` (every 15 minutes)

### 2. Timing Examples

**Every minute:**
```
* * * * * command
```

**At midnight (00:00) every day:**
```
0 0 * * * command
```

**Every Monday at 9 AM:**
```
0 9 * * 1 command
```

**Every 15 minutes during business hours (9 AM - 5 PM):**
```
*/15 9-17 * * 1-5 command
```

**First day of the month at 2 AM:**
```
0 2 1 * * command
```

**Every 6 hours (midnight, 6 AM, noon, 6 PM):**
```
0 0,6,12,18 * * * command
```

**Every 30 minutes during weekdays:**
```
*/30 * * * 1-5 command
```

**Last day of February and December (complex - requires script logic):**
```
0 0 1 3,1 * [ $(date +%d) = 01 ] && command  # Runs first of next month
```

### 3. Special Cron Strings (Shorthand)

Some systems support special strings (non-standard, not all systems):

```bash
@reboot      # After system reboot
@yearly      # 0 0 1 1 * (once per year)
@annually    # Same as @yearly
@monthly     # 0 0 1 * * (first day of month)
@weekly      # 0 0 * * 0 (every Sunday)
@daily       # 0 0 * * * (every day at midnight)
@midnight    # Same as @daily
@hourly      # 0 * * * * (every hour)
```

Example usage:
```bash
@daily /usr/local/bin/cleanup.sh
@reboot /opt/myapp/start.sh
```

### 4. Cron Environment Variables

When cron executes a job, it has a **very limited environment**. It does NOT:
- Load `.bashrc` or `.bash_profile`
- Source `.profile` or `/etc/profile`
- Set `USER`, `HOME`, or `PATH` as you'd expect
- Have access to aliases or functions

Critical variables you must set:

```bash
# Email where output is sent (empty = don't email)
MAILTO=admin@example.com

# Must include all paths where commands live
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

# Shell to use for executing commands
SHELL=/bin/bash

# Language/locale settings
LANG=en_US.UTF-8
```

### 5. Working Directory in Cron

When cron executes a job:

- **Current working directory** is `/var/spool/cron/` (wrong!)
- **Environment variables** are minimal
- **File paths** must be absolute (not relative)

Wrong approach:
```bash
0 2 * * * backup.sh              # ❌ Won't find script
0 2 * * * /home/user/logs > app.log  # ❌ Creates /var/spool/cron/app.log
```

Correct approach:
```bash
0 2 * * * /home/user/backup.sh   # ✓ Absolute path
0 2 * * * /home/user/backup.sh > /home/user/logs/backup.log 2>&1  # ✓
```

### 6. System Crontab vs User Crontab

**System Crontab** (`/etc/crontab` or `/etc/cron.d/`):
- Edited by root only
- Has extra field for username: `minute hour day month weekday username command`
- Runs with that user's privileges

Example:
```bash
# /etc/crontab
0 2 * * * postgres /usr/local/bin/backup-db.sh  # Runs as postgres user
0 * * * * root /usr/local/bin/monitor.sh        # Runs as root
```

**User Crontab** (`/var/spool/cron/crontabs/username`):
- No username field
- Runs with that user's privileges
- Edited via `crontab -e` command

Example:
```bash
# User's personal crontab (created with: crontab -e)
0 2 * * * /home/user/backup.sh
```

### 7. Output and Logging

Cron captures **STDOUT and STDERR** from every job:

```bash
0 2 * * * /backup.sh
# Output goes to: email to MAILTO
```

To **suppress output**:
```bash
0 2 * * * /backup.sh > /dev/null 2>&1
```

To **capture in log file**:
```bash
0 2 * * * /backup.sh >> /var/log/backup.log 2>&1
```

To **email only on error** (requires wrapper script):
```bash
#!/bin/bash
output=$(/backup.sh 2>&1)
status=$?
if [ $status -ne 0 ]; then
    echo "$output" | mail -s "Backup Failed" admin@example.com
fi
```

### 8. Cron Execution Context

When cron runs your job:

```
Your Script runs with:
├─ User: The user who owns the crontab
├─ Group: The user's default group
├─ Working Directory: /var/spool/cron/ (WRONG!)
├─ HOME: User's home directory (sometimes)
├─ Environment: Minimal (just PATH, SHELL, MAILTO set in crontab)
├─ Umask: 0077 (very restrictive)
├─ File Descriptors: stdin=/dev/null, stdout/stderr captured
└─ Process Limits: Inherited from system defaults
```

### 9. Common Timing Mistakes

**Mistake 1: Off-by-one with day of month/week**

```bash
# This runs on EITHER day 5 OR Friday (OR logic)
0 0 5 * 5 command

# To run only on Friday the 5th, use:
0 0 5 * * [ $(date +%A) = Friday ] && command
```

**Mistake 2: Invalid day numbers**

```bash
0 0 30 2 * command  # ❌ February doesn't have day 30 - NEVER RUNS!
0 0 1 3 * command   # ✓ First of March
```

**Mistake 3: Overlapping ranges**

```bash
*/5 9-17 * * * command  # Runs every 5 minutes, 9 AM to 5 PM
# Actually runs: 9:00, 9:05, 9:10, ... 17:00
```

**Mistake 4: Not accounting for system reboot**

```bash
@reboot /opt/app/start.sh
# But /opt/app directory might not be mounted yet!
# Add sleep: @reboot sleep 30 && /opt/app/start.sh
```

### 10. Synchronization and Locking

If a job takes longer than expected and another instance runs:

```bash
#!/bin/bash
LOCKFILE="/var/run/backup.lock"

# Try to acquire lock
if [ -e "$LOCKFILE" ]; then
    echo "Backup already running" >> /var/log/backup.log
    exit 1
fi

# Create lock
touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Your backup logic here
/usr/local/bin/backup.sh
```

### 11. Cron and Daylight Saving Time

Cron times are **local system time**. When clocks spring forward or fall back:

- Jobs **might not run** during the skipped hour (spring forward)
- Jobs **might run twice** during the repeated hour (fall back)

Solution: Use UTC times or implement custom DST handling.

### 12. Systemd Timers - Modern Alternative

Many modern systems prefer systemd timers:

**Traditional Cron:**
```bash
0 2 * * * /backup.sh
```

**Systemd Timer Equivalent:**
```
[Unit]
Description=Daily Backup
After=network.target

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

**Advantages of Systemd Timers:**
- Full systemd integration (logging, dependencies)
- Better error reporting and job status
- Can trigger services, not just run scripts
- Works well with containers
- Predictable environment

**When to use Cron still:**
- Legacy systems (RHEL 6, Ubuntu 14.04)
- Simple jobs that don't need systemd integration
- Cross-platform scripts

## Lab Prerequisites

To practice labs in this module, ensure:

1. Linux system (Ubuntu 20.04+, RHEL 8+, or similar)
2. `cron` or `cronie` package installed
3. `sudo` access or ability to run root commands
4. Text editor (nano, vi, or vim)
5. `mail` or `mailutils` package (for email testing)
6. Ability to modify `/var/log/` for log files
7. Commands: `crontab`, `systemctl`, `ps`, `grep`, `tail`
