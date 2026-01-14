# Module 04: Crontab and Scheduling

## Overview

Task scheduling is fundamental to DevOps operations. Whether you're backing up databases, rotating logs, running maintenance scripts, or deploying applications, you need reliable job scheduling. Cron is the Unix/Linux standard daemon that executes scheduled tasks automatically—it's been powering automated systems for over 40 years and remains essential in modern infrastructure.

Understanding cron is critical because:
- **24/7 Operations**: Automate tasks that run outside business hours
- **Infrastructure Maintenance**: Keep systems healthy with automated health checks, cleanup, and optimization
- **Reliability**: Replace manual work with consistent, repeatable automation
- **Disaster Recovery**: Schedule backups and replication to prevent data loss
- **Monitoring & Alerts**: Run periodic checks and generate reports automatically

In a typical DevOps environment, cron handles everything from database backups every 2 hours to log rotation every day to monthly compliance reports.

## Prerequisites

Before starting this module, you should:
- Be comfortable with Linux command line basics (cd, ls, cat, vi/nano)
- Understand file permissions and ownership
- Be familiar with shell scripting fundamentals
- Know how to use at least one text editor (nano or vi)
- Have basic understanding of what a daemon is
- Know how to read and write simple shell scripts

## Learning Objectives

After completing this module, you will be able to:

1. **Understand Cron Architecture**: Know how cron daemon works, how it reads crontabs, and when jobs execute
2. **Create Cron Jobs**: Write and install crontab entries with correct syntax
3. **Use Cron Timing Expressions**: Correctly specify time patterns (minute, hour, day, month, weekday)
4. **Manage Multiple Crontabs**: Handle system crontab and user crontabs effectively
5. **Debug Cron Issues**: Troubleshoot failed jobs, timing issues, and environment problems
6. **Schedule Complex Tasks**: Create multi-step automation with error handling and logging
7. **Implement Best Practices**: Follow security guidelines, avoid common pitfalls
8. **Use Alternatives**: Understand systemd timers and when to use them instead of cron
9. **Monitor Cron Execution**: Check logs, verify job completion, and set up alerts
10. **Automate DevOps Workflows**: Apply scheduling to real deployment and maintenance scenarios

## Module Roadmap

1. **01-theory.md** → Understand cron internals, timing syntax, and architecture
2. **02-commands-cheatsheet.md** → Quick reference for cron commands and syntax
3. **03-hands-on-labs.md** → Practical exercises with real-world scenarios
4. **scripts/** → Reusable automation tools

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Cron** | Daemon that executes scheduled tasks at specified times |
| **Crontab** | Text file containing cron job definitions |
| **Cron Expression** | Time specification format (minute hour day month weekday) |
| **Daemon** | Background process that runs continuously |
| **Job** | Single task/script scheduled to run at specific times |
| **Crond** | Cron daemon process name |
| **Systemd Timer** | Modern systemd alternative to cron |
| **At** | One-time task scheduler (alternative to cron) |
| **Anacron** | Cron for systems not running 24/7 |
| **Cron Environment** | Limited environment variables in cron execution |
| **Crontab Path** | Location of crontab files (/var/spool/cron/) |
| **Root Crontab** | System-wide crontab with special privileges |

## Key Concepts

### Basic Cron Syntax

Every cron job follows this format:

```
minute hour day month weekday command
0-59   0-23  1-31 1-12  0-6(0=Sun)
```

**Simple Example - Run daily backup at 2 AM:**
```bash
0 2 * * * /usr/local/bin/backup.sh
```

**Weekly Report - Every Monday at 9 AM:**
```bash
0 9 * * 1 /home/admin/generate-report.sh
```

### Environment Variables in Cron

Cron provides limited environment - you must set paths explicitly:

```bash
#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
SHELL=/bin/bash
MAILTO=admin@example.com

0 2 * * * /usr/local/bin/backup.sh
```

### Error Handling Example

```bash
#!/bin/bash
set -euo pipefail

# Redirect output to log
exec 1>>/var/log/backup.log
exec 2>&1

# Exit on error
trap 'echo "Backup failed at line $LINENO" | mail -s "Backup Error" admin@example.com' ERR

# Your backup commands here
mysqldump -u user -p database > /backup/db.sql
```

## How It Works

```
┌─────────────────────────────────────────────┐
│        Operating System Boot                 │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│     crond daemon starts (PID from init)      │
└────────────────┬────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
   Read crontabs    Load into memory
   /etc/crontab     /var/spool/cron/crontabs/*
        │                 │
        └────────┬────────┘
                 │
                 ▼
        Every minute check:
   Does a job need to run now?
                 │
        ┌────────┴────────┐
        │                 │
       YES               NO
        │                 │
        ▼                 ▼
   Fork process    Sleep 60 seconds
   Execute job
   (with limited env)
        │
        ▼
   Capture output/errors
   Send email to MAILTO
```

## Important Notes

⚠️ **Cron Security**: Jobs run with the privileges of the user who owns the crontab. Root crontabs run with full system access - be extremely careful.

⚠️ **Environment Limited**: Cron doesn't source .bashrc or .profile - you must set PATH explicitly. Many cron failures are due to missing PATH.

⚠️ **Output Handling**: Cron captures all output and emails it to MAILTO (default is the user running the job). Unwanted emails mean either set `MAILTO=""` or redirect output.

⚠️ **System Load**: Multiple simultaneous cron jobs can overload your system. Stagger large jobs and monitor load.

⚠️ **Daylight Saving Time**: Be careful with cron jobs around DST transitions - times may not be what you expect.

⚠️ **File Permissions**: Crontab file must be mode 600 and owned by the user. Incorrect permissions can prevent jobs from running.

## Common Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| **PATH not set** | Commands not found, scripts fail silently | Export full PATH in crontab or script header |
| **MAILTO misconfigured** | Emails flood inbox or job failures go unnoticed | Set `MAILTO=""` or specific address; test email delivery |
| **Crontab not saved** | Changes don't take effect | Always exit editor with :wq or Ctrl-X; verify with `crontab -l` |
| **Relative paths** | Files not found (pwd=/var/spool/cron/ not your home) | Use absolute paths in all scripts and commands |
| **Overlapping jobs** | Multiple instances running simultaneously | Add locking mechanism or adjust schedules |
| **DST transitions** | Jobs run at wrong time during clock changes | Script handles or use UTC times |
| **Log space** | Disk fills up from cron output | Redirect to /dev/null or compressed logs |
| **Syntax errors** | Job silently fails to run | Verify syntax: `0 0 0 * * echo test` (invalid - day 0) |

## Next Steps

- Move to **01-theory.md** to understand cron internals and detailed timing syntax
- Review **02-commands-cheatsheet.md** for quick command reference
- Work through **03-hands-on-labs.md** for practical exercises
- Check **scripts/** for ready-to-use automation tools
- Advanced: Learn about systemd timers and anacron for special use cases