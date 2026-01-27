# Module 13: Logging and Monitoring

## What You'll Learn

- Understand Linux log locations and formats
- Use journalctl to query systemd logs
- Monitor system metrics in real-time
- Analyze logs for troubleshooting
- Set up basic monitoring
- Understand log rotation
- Create custom log checks

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Complete Module 6: System Services and Daemons
- Basic understanding of text filtering

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Journal** | systemd centralized logging system |
| **Log File** | Text file with timestamped events |
| **Log Rotation** | Archive and compress old logs |
| **Metrics** | System performance measurements |
| **Alert** | Notification when threshold exceeded |
| **Tail** | Follow end of file in real-time |
| **Grep** | Search logs for patterns |
| **Timestamp** | Date/time of event |

## Hands-on Lab: Query Logs and Monitor System

### Lab Objective
Review logs with journalctl and monitor real-time metrics.

### Commands

```bash
# View recent journal entries
journalctl -n 20
# Last 20 entries

# Follow journal in real-time
journalctl -f

# Show entries since last boot
journalctl -b

# Filter by service
journalctl -u sshd -n 10

# Show by priority level
journalctl -p err -b
# Errors and critical only

# Show specific time range
journalctl --since "2024-01-20 10:00:00"
journalctl --until "2024-01-20 15:00:00"

# Search for pattern
journalctl | grep "error"

# Show logs in UTC
journalctl --utc

# Check log disk usage
journalctl --disk-usage

# Persistent journal (across reboots)
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald

# View traditional logs
tail -f /var/log/syslog
# or
tail -f /var/log/messages

# Monitor system metrics
top
# or
htop
# or
vmstat 1 5
```

### Expected Output

```
# journalctl output:
Jan 20 10:30:45 ubuntu systemd[1]: Started User Manager for UID 1000.
Jan 20 10:30:46 ubuntu kernel: audit: type=1400 ...

# Disk usage:
Archived and volatile journals take up 1.2G on disk.
Max allowed: 4.0G (20% of file system)
```

## Validation

Confirm successful completion:

- [ ] Viewed recent journal entries
- [ ] Filtered logs by service
- [ ] Followed journal in real-time
- [ ] Searched logs for errors
- [ ] Checked log disk usage
- [ ] Monitored system metrics

## Cleanup

```bash
# Vacuum old journal logs (keep recent)
sudo journalctl --vacuum-time=7d
# Keep only 7 days

# Limit journal size
sudo journalctl --vacuum-size=100M
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Can't find old logs | Enable persistent journal in /var/log/journal |
| Journal too large | Use `journalctl --vacuum-time=7d` |
| Grep is slow on large logs | Use journalctl filtering instead |
| Permission denied | Use `sudo` for privileged logs |
| Timestamps confusing | Use `journalctl -a` for all fields |

## Troubleshooting

**Q: How do I follow live logs?**
A: Use `journalctl -f` to follow systemd journal, or `tail -f /path/to/log`.

**Q: How do I find errors from yesterday?**
A: `journalctl --since "yesterday" -p err`.

**Q: Logs taking too much disk space?**
A: Rotate with logrotate, or vacuum journal: `journalctl --vacuum-time=7d`.

**Q: How do I monitor CPU/memory?**
A: Use `top`, `htop`, `vmstat`, or `systemd-analyze plot`.

**Q: Where are application logs?**
A: Check `/var/log/`, service-specific dirs, or use `journalctl -u service`.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Master journalctl filtering options
3. Set up log monitoring for services
4. Learn logrotate configuration
5. Implement custom logging
