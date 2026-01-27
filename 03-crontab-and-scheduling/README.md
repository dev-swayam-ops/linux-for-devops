# Module 3: Crontab and Scheduling

## What You'll Learn

- Schedule tasks to run automatically at specific times
- Create and manage cron jobs using crontab
- Understand cron syntax and scheduling intervals
- Monitor scheduled tasks and view logs
- Handle common scheduling scenarios
- Use systemd timers as alternatives to cron

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Understanding of file permissions and command line
- Access to a Linux system with cron daemon
- Basic text editor proficiency (nano or vim)

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Cron Daemon** | Background service that executes scheduled tasks |
| **Crontab** | Table file containing scheduled jobs for each user |
| **Cron Job** | Individual task scheduled to run at specific times |
| **Cron Syntax** | Format: minute hour day month weekday command |
| **Special Strings** | @hourly, @daily, @weekly, @monthly, @yearly |
| **Cron Environment** | Limited PATH and no user shell; use full paths |

## Hands-on Lab: Create and Manage Scheduled Tasks

### Lab Objective
Create backup jobs, monitor their execution, and understand cron behavior.

### Commands

```bash
# View current crontab
crontab -l

# Edit crontab (opens in default editor)
crontab -e

# Add a simple cron job (using bash, not interactive editor)
echo "0 2 * * * /home/user/backup.sh" | crontab -

# View all scheduled jobs
crontab -l

# Check cron logs
grep CRON /var/log/syslog
# or on systemd systems:
journalctl -u cron

# List cron jobs for all users (requires sudo)
sudo for user in $(cut -f1 -d: /etc/passwd); do 
  echo "=== $user ===" 
  sudo crontab -u $user -l 2>/dev/null
done

# Remove all cron jobs
crontab -r

# Install crontab from file
crontab /path/to/crontab_file

# Test cron job immediately
*/1 * * * * /path/to/script.sh

# Redirect cron output to file
0 2 * * * /backup.sh >> /var/log/backup.log 2>&1

# Send output to email
0 2 * * * /backup.sh | mail -s "Backup Report" user@example.com
```

### Cron Syntax Explanation

```
Minute (0-59)
│   Hour (0-23)
│   │   Day of Month (1-31)
│   │   │   Month (1-12)
│   │   │   │   Day of Week (0-7, 0=Sunday)
│   │   │   │   │   Command
│   │   │   │   │   │
0   2   *   *   *   /home/user/backup.sh

# Common examples:
0 2 * * *      # Every day at 2:00 AM
0 */4 * * *    # Every 4 hours
0 0 * * 0      # Every Sunday at midnight
0 0 1 * *      # First day of each month at midnight
30 9 * * 1-5   # 9:30 AM, Monday to Friday
```

### Expected Output

```
# crontab -l output:
0 2 * * * /home/user/backup.sh

# journalctl output:
Jan 27 02:00:00 hostname CRON[1234]: (user) CMD (/home/user/backup.sh)

# grep CRON /var/log/syslog output:
Jan 27 02:00:00 hostname CRON[1234]: (user) CMDOUT (Backup complete)
```

## Validation

Confirm successful completion:

- [ ] Created a crontab entry using `crontab -e`
- [ ] Viewed cron jobs with `crontab -l`
- [ ] Checked cron logs in system logs
- [ ] Understood cron time format (minute, hour, day, month, weekday)
- [ ] Tested cron output redirection

## Cleanup

```bash
# Remove test cron job
crontab -r

# Or remove specific line by editing
crontab -e  # Then delete the line manually

# Clear cron logs (if needed)
sudo truncate -s 0 /var/log/cron
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Cron job not running | Ensure cron daemon is active: `sudo systemctl status cron` |
| Scripts not executing | Use absolute paths: `/usr/bin/python3` not `python3` |
| No output from job | Redirect to file: `>> /var/log/my.log 2>&1` |
| Wrong time format | Remember: minute (0-59), hour (0-23), day (1-31) |
| Permissions denied | Make script executable: `chmod +x script.sh` |
| Email not working | Configure mail system or redirect to file |

## Troubleshooting

**Q: How do I know if cron ran my job?**
A: Check logs: `journalctl -u cron` or `grep CRON /var/log/syslog`

**Q: Can I run a cron job every minute?**
A: Yes: `* * * * * command` (all asterisks means every minute)

**Q: How do I edit a cron job?**
A: Use `crontab -e` and modify the line, then save

**Q: Can multiple users have cron jobs?**
A: Yes. Each user has their own crontab. Root can edit others' with `crontab -u username -e`

**Q: What if my script needs environment variables?**
A: Set them in crontab file: add `VARIABLE=value` before the job

## Next Steps

1. Complete all exercises in `exercises.md`
2. Create backup scripts and schedule them
3. Monitor cron job execution with logs
4. Explore systemd timers as alternatives to cron
5. Implement error handling and notifications in scheduled scripts
