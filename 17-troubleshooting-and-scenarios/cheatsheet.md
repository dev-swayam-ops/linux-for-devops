# Troubleshooting and Scenarios: Cheatsheet

## Troubleshooting Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl status service` | Service status | `systemctl status nginx` |
| `journalctl -u service` | Service logs | `journalctl -u nginx -n 50` |
| `journalctl -xe` | Latest errors | Show recent failures |
| `dmesg` | Kernel messages | `dmesg \| tail` |
| `journalctl --since` | Logs by time | `journalctl --since "1 hour ago"` |

## Service Management

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl start service` | Start service | `systemctl start nginx` |
| `systemctl stop service` | Stop service | `systemctl stop nginx` |
| `systemctl restart service` | Restart service | `systemctl restart nginx` |
| `systemctl reload service` | Reload config | `systemctl reload nginx` |
| `systemctl enable service` | Enable on boot | `systemctl enable nginx` |
| `systemctl disable service` | Disable on boot | `systemctl disable nginx` |
| `systemctl is-active service` | Check if running | Returns active/inactive |

## Process Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `top` | Real-time process monitor | Interactive view |
| `top -p <PID>` | Monitor specific PID | `top -p 1234` |
| `top -o %CPU` | Sort by CPU | Highest CPU first |
| `top -o %MEM` | Sort by memory | Highest memory first |
| `ps aux` | List all processes | Snapshot view |
| `ps aux \| grep app` | Find process | Filter by name |
| `pgrep -a name` | Find by name | `pgrep -a nginx` |
| `pkill name` | Kill by name | Dangerous! |

## Port and Network

| Command | Purpose | Example |
|---------|---------|---------|
| `netstat -tlnp` | Listening ports | Show TCP listeners |
| `netstat -an` | All connections | All sockets |
| `ss -tlnp` | Alternative to netstat | Modern tool |
| `lsof -i :8080` | Process using port | Find PID |
| `telnet host port` | Test connectivity | `telnet localhost 80` |
| `nc -zv host port` | Netcat test | `nc -zv 192.168.1.1 80` |
| `curl -v url` | HTTP test | Verbose output |
| `ping host` | ICMP test | Connectivity check |

## Network Diagnostics

| Command | Purpose | Example |
|---------|---------|---------|
| `nslookup host` | DNS lookup | `nslookup google.com` |
| `dig host` | Detailed DNS | More info than nslookup |
| `traceroute host` | Network path | Show hops |
| `mtr host` | Continuous traceroute | Real-time path |
| `ip route show` | Routing table | Check default gateway |
| `ip addr show` | IP addresses | All interfaces |
| `ifconfig` | Network interfaces | Legacy but useful |
| `arp -a` | ARP table | IP to MAC mapping |

## Disk and File System

| Command | Purpose | Example |
|---------|---------|---------|
| `df -h` | Disk usage | Human-readable |
| `df -i` | Inode usage | Check inode availability |
| `du -sh path` | Directory size | `du -sh /home` |
| `du -sh /*` | Top-level sizes | Find large dirs |
| `find / -size +100M` | Large files | Locate > 100MB |
| `lsof +D path` | Open files in dir | `lsof +D /tmp` |
| `ls -lah` | Detailed listing | All files with sizes |
| `tree -L 2` | Directory tree | Two levels deep |

## Memory and Resource

| Command | Purpose | Example |
|---------|---------|---------|
| `free -h` | Memory status | Human-readable |
| `free -h -s 1` | Memory monitor | Update every 1s |
| `vmstat 1 5` | System stats | CPU, memory, I/O |
| `iostat -x 1` | I/O statistics | Disk I/O detailed |
| `iotop` | I/O process monitor | Like top for I/O |
| `uptime` | System uptime | Load average |
| `w` | Who is logged in | Who and what they're doing |
| `last` | Login history | Who logged in when |

## Log Analysis

| Command | Purpose | Example |
|---------|---------|---------|
| `tail -f file` | Follow log | Real-time view |
| `tail -n 50 file` | Last N lines | `tail -n 100 /var/log/syslog` |
| `head -n 50 file` | First N lines | Beginning of file |
| `grep pattern file` | Search logs | `grep ERROR /var/log/app.log` |
| `grep -i pattern file` | Case insensitive | Ignore case |
| `grep -v pattern file` | Invert match | Exclude pattern |
| `grep -c pattern file` | Count matches | How many lines |
| `wc -l file` | Line count | Total lines |

## File Permissions

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -l path` | Show permissions | Detailed listing |
| `stat path` | Detailed info | All attributes |
| `chmod 755 path` | Change mode | rwxr-xr-x |
| `chown user:group path` | Change owner | Change ownership |
| `chown -R user:group path` | Recursive | Apply recursively |
| `file path` | File type | What kind of file |

## System Information

| Command | Purpose | Example |
|---------|---------|---------|
| `uname -a` | System info | Kernel and version |
| `lsb_release -a` | OS release | Distribution info |
| `hostnamectl` | Hostname info | Machine name |
| `timedatectl` | Time and date | Time zone and NTP |
| `lscpu` | CPU info | CPU details |
| `lsmem` | Memory info | RAM details |
| `dmidecode` | Hardware info | BIOS info |

## Tracing and Debugging

| Command | Purpose | Example |
|---------|---------|---------|
| `strace -p <PID>` | System calls | Attach to running |
| `strace -e trace=file` | Trace file operations | Focus on specific |
| `strace -o trace.log` | Write to file | Save output |
| `ltrace -p <PID>` | Library calls | Library function tracing |
| `gdb ./binary` | Debugger | Full debugger |
| `objdump -d binary` | Disassemble | Binary analysis |

## Configuration Validation

| Command | Purpose | Example |
|---------|---------|---------|
| `nginx -t` | Nginx config test | Syntax check |
| `apache2ctl -t` | Apache config test | Syntax check |
| `mysql -u user -p -e "status"` | MySQL status | Database check |
| `psql -U user -c "SELECT 1"` | PostgreSQL test | Database check |
| `-n` flag | Dry run | Check without executing |

## Cron and Scheduled Tasks

| Command | Purpose | Example |
|---------|---------|---------|
| `crontab -l` | List cron jobs | User's schedule |
| `crontab -e` | Edit cron jobs | Edit schedule |
| `systemctl status cron` | Cron service | Is cron running? |
| `journalctl -u cron` | Cron logs | When did it run? |
| `grep CRON /var/log/syslog` | Cron entries | Syslog records |

## Common Scenarios Quick Reference

| Issue | First Command | Next Steps |
|-------|---------------|-----------|
| Service down | `systemctl status` | `journalctl -u service` |
| Port conflict | `lsof -i :PORT` | `kill -9 PID` or stop service |
| Disk full | `df -h` | `du -sh /*` then cleanup |
| Slow performance | `top` | Check CPU, memory, disk I/O |
| Can't connect | `ping host` | Check firewall, port open |
| Permission denied | `ls -l path` | `chmod` or `chown` |
| Memory leak | `top -p PID` | Monitor growth over time |
| Cron not running | `crontab -l` | Check logs, syntax, path |

## Troubleshooting Methodology

1. **Gather Information**
   - systemctl status
   - journalctl -xe
   - ps aux

2. **Check Logs**
   - journalctl -u service
   - tail -f /var/log/app.log
   - dmesg

3. **Verify Resources**
   - top (CPU/memory)
   - df -h (disk)
   - netstat (network)

4. **Isolate Problem**
   - Test manually
   - Check config
   - Verify dependencies

5. **Implement Fix**
   - Change one thing
   - Test thoroughly
   - Document change

6. **Verify Solution**
   - Confirm fix works
   - Monitor for recurrence
   - Update documentation
