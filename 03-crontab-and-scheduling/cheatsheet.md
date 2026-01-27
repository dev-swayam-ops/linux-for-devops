# Crontab and Scheduling: Cheatsheet

## Cron Time Format

```
┌──────────── minute (0 - 59)
│ ┌────────── hour (0 - 23)
│ │ ┌──────── day of month (1 - 31)
│ │ │ ┌────── month (1 - 12)
│ │ │ │ ┌──── day of week (0 - 7) (0 and 7 are Sunday)
│ │ │ │ │
│ │ │ │ │
* * * * * command_to_run
```

## Common Cron Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `0 0 * * *` | Daily at midnight | Daily backup |
| `0 * * * *` | Every hour at :00 | Hourly check |
| `*/15 * * * *` | Every 15 minutes | Frequent refresh |
| `0 0 * * 0` | Every Sunday midnight | Weekly cleanup |
| `0 0 1 * *` | 1st of month midnight | Monthly report |
| `0 9 * * 1-5` | 9 AM weekdays | Work schedule |
| `0 2 * * *` | 2 AM every day | Night backup |
| `0 */4 * * *` | Every 4 hours | Regular interval |
| `30 3 * * *` | 3:30 AM daily | Scheduled task |
| `0 0 1 1 *` | 1 Jan midnight | Annual task |

## Special Strings

| String | Equivalent | Meaning |
|--------|-----------|---------|
| `@yearly` | `0 0 1 1 *` | Once per year |
| `@annually` | `0 0 1 1 *` | Once per year |
| `@monthly` | `0 0 1 * *` | Once per month |
| `@weekly` | `0 0 * * 0` | Once per week |
| `@daily` | `0 0 * * *` | Once per day |
| `@midnight` | `0 0 * * *` | Midnight daily |
| `@hourly` | `0 * * * *` | Every hour |
| `@reboot` | N/A | After system boot |

## Crontab Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `crontab -l` | List current jobs | `crontab -l` |
| `crontab -e` | Edit crontab | `crontab -e` |
| `crontab -r` | Remove all jobs | `crontab -r` |
| `crontab -i` | Interactive remove | `crontab -i` |
| `crontab -u user` | Manage user's crontab | `crontab -u username -l` |
| `crontab file` | Install from file | `crontab mycron.txt` |
| `crontab -l > file` | Export to file | `crontab -l > backup.txt` |

## Cron Output Redirection

| Syntax | Purpose | Example |
|--------|---------|---------|
| `> file` | Redirect stdout | `0 2 * * * script.sh > output.log` |
| `>> file` | Append stdout | `0 2 * * * script.sh >> output.log` |
| `2> file` | Redirect stderr | `0 2 * * * script.sh 2> error.log` |
| `2>> file` | Append stderr | `0 2 * * * script.sh 2>> error.log` |
| `> file 2>&1` | Combine both | `0 2 * * * script.sh > all.log 2>&1` |
| `> /dev/null` | Discard output | `0 2 * * * script.sh > /dev/null` |
| `2>&1 \| mail` | Send output via email | `0 2 * * * script.sh \| mail -s "log" user@example.com` |

## Cron Special Considerations

| Issue | Solution |
|-------|----------|
| Script not running | Use full path: `/usr/bin/python3` not `python3` |
| Variables missing | Set at top of crontab: `PATH=/usr/bin:/bin` |
| No output captured | Use redirection: `>> /tmp/output.log 2>&1` |
| Permissions denied | Make script executable: `chmod +x script.sh` |
| Timezone issues | Check with `timedatectl` or set TZ in crontab |
| Email not working | Redirect to file or check mail system |

## Monitoring and Logging

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl -u cron` | View cron logs (systemd) | `journalctl -u cron -f` |
| `journalctl -u cron -n 50` | Last 50 lines | `journalctl -u cron -n 50` |
| `grep CRON /var/log/syslog` | View in syslog | `grep CRON /var/log/syslog` |
| `sudo tail -f /var/log/cron` | Follow cron log | `sudo tail -f /var/log/cron` |

## Cron Time Symbols

| Symbol | Meaning |
|--------|---------|
| `*` | Any value (every minute/hour/day) |
| `,` | List of values: `1,3,5` (odd hours) |
| `-` | Range: `1-5` (Monday to Friday) |
| `/` | Step/interval: `*/5` (every 5 minutes) |
| `?` | No specific value (day or weekday) |

## Day of Week Reference

| Number | Day |
|--------|-----|
| 0 | Sunday |
| 1 | Monday |
| 2 | Tuesday |
| 3 | Wednesday |
| 4 | Thursday |
| 5 | Friday |
| 6 | Saturday |
| 7 | Sunday (also valid) |

## Month Reference

| Number | Month |
|--------|-------|
| 1 | January |
| 2 | February |
| 3 | March |
| 4 | April |
| 5 | May |
| 6 | June |
| 7 | July |
| 8 | August |
| 9 | September |
| 10 | October |
| 11 | November |
| 12 | December |

## Example Crontab File

```bash
# Run a backup every night at 2am
0 2 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1

# Run a report every Monday at 9am
0 9 * * 1 /home/user/report.sh

# Run cleanup every Sunday at 3am
0 3 * * 0 /home/user/cleanup.sh

# Check disk space every 6 hours
0 */6 * * * /home/user/check_disk.sh

# Sync files every 30 minutes
*/30 * * * * /home/user/sync.sh

# Monthly report on 1st of each month at midnight
0 0 1 * * /home/user/monthly_report.sh

# Run after system boot
@reboot /home/user/startup.sh
```
