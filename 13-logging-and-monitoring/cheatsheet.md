# Logging and Monitoring: Cheatsheet

## Journal Viewing

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl` | Show all journal | `journalctl` |
| `journalctl -n 20` | Last 20 entries | `journalctl -n 20` |
| `journalctl -f` | Follow live | `journalctl -f` |
| `journalctl -b` | This boot | `journalctl -b` |
| `journalctl -b -1` | Previous boot | `journalctl -b -1` |
| `journalctl --list-boots` | All boots | `journalctl --list-boots` |

## Filter by Unit/Service

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl -u service` | By service | `journalctl -u sshd` |
| `journalctl -u service -f` | Follow service | `journalctl -u sshd -f` |
| `journalctl -u service -n 20` | Last 20 | `journalctl -u nginx -n 20` |

## Filter by Priority

| Command | Purpose | Level |
|---------|---------|-------|
| `journalctl -p emerg` | Emergency | 0 |
| `journalctl -p alert` | Alert | 1 |
| `journalctl -p crit` | Critical | 2 |
| `journalctl -p err` | Error | 3 |
| `journalctl -p warn` | Warning | 4 |
| `journalctl -p notice` | Notice | 5 |
| `journalctl -p info` | Info | 6 |
| `journalctl -p debug` | Debug | 7 |

## Time Filters

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl --since "2024-01-20"` | Since date | `journalctl --since "2024-01-20 10:00:00"` |
| `journalctl --until "2024-01-20"` | Until date | `journalctl --until "2024-01-20 15:00:00"` |
| `journalctl --since "1 hour ago"` | Last hour | `journalctl --since "1 hour ago"` |
| `journalctl --since "today"` | Since midnight | `journalctl --since "today"` |
| `journalctl --since "yesterday"` | Yesterday | `journalctl --since "yesterday"` |

## Output Formats

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl -o short` | Compact | `journalctl -o short` |
| `journalctl -o short-precise` | Precise timestamps | `journalctl -o short-precise` |
| `journalctl -o json` | JSON format | `journalctl -o json` |
| `journalctl -o cat` | Minimal | `journalctl -o cat` |
| `journalctl -a` | All fields | `journalctl -a` |

## Journal Management

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl --disk-usage` | Disk usage | `journalctl --disk-usage` |
| `journalctl --vacuum-time=7d` | Keep 7 days | `sudo journalctl --vacuum-time=7d` |
| `journalctl --vacuum-size=100M` | Keep 100MB | `sudo journalctl --vacuum-size=100M` |
| `journalctl --flush-to-var` | Flush to /var | `sudo journalctl --flush-to-var` |

## Traditional Log Files

| File | Purpose |
|------|---------|
| `/var/log/syslog` | System messages (Debian) |
| `/var/log/messages` | System messages (RedHat) |
| `/var/log/auth.log` | Authentication |
| `/var/log/kernel.log` | Kernel messages |
| `/var/log/dmesg` | Boot messages |
| `/var/log/secure` | Security (RedHat) |

## Monitoring Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `top` | Interactive metrics | `top` |
| `htop` | Enhanced top | `htop` |
| `vmstat 1 5` | Virtual memory | `vmstat 1 5` |
| `iostat -x 1 5` | I/O stats | `iostat -x 1 5` |
| `free -h` | Memory usage | `free -h` |
| `uptime` | System uptime | `uptime` |
| `ps aux` | All processes | `ps aux` |
| `ps aux --sort=-%cpu` | By CPU | `ps aux --sort=-%cpu` |

## System Status

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl status` | System status | `systemctl status` |
| `systemctl --failed` | Failed units | `systemctl --failed` |
| `systemd-analyze` | Boot time | `systemd-analyze` |
| `systemd-analyze blame` | Slowest units | `systemd-analyze blame` |
| `uptime` | Uptime/load | `uptime` |
| `df -h` | Disk usage | `df -h` |
| `du -sh /path` | Directory size | `du -sh /var/log` |

## Log Search

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl \| grep "error"` | Search | `journalctl \| grep "error"` |
| `grep "Failed" /var/log/auth.log` | File search | `grep "Failed" /var/log/auth.log` |
| `grep -r "error" /var/log/` | Recursive | `grep -r "error" /var/log/` |
| `tail -f /var/log/file` | Follow log | `tail -f /var/log/syslog` |
| `less /var/log/file` | Page through | `less /var/log/syslog` |

## Network Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `ss -tan` | TCP connections | `ss -tan` |
| `ss -tan \| wc -l` | Count connections | `ss -tan \| wc -l` |
| `netstat -tlnp` | Listening ports | `sudo netstat -tlnp` |
| `lsof -i` | Network files | `sudo lsof -i` |
| `iftop` | Bandwidth usage | `sudo iftop` |
