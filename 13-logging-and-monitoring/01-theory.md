# Logging and Monitoring Theory

## 1. Syslog Architecture

### How Linux Logging Works

Linux uses a **syslog** architecture where messages flow through several components:

```
Application/Kernel
        |
        v
Syslog Daemon (rsyslog/systemd-journald)
        |
        +-----> /var/log/syslog (or rotated logs)
        |
        +-----> /var/log/auth.log
        |
        +-----> /var/log/kern.log
        |
        `-----> Other configured destinations
```

**Key Points**:
- **Applications and kernel** generate messages
- **Syslog daemon** (rsyslog) receives them via `/dev/log` socket
- **Rsyslog rules** determine where messages go based on facility and level
- **Files and outputs** capture the logs for analysis

### Rsyslog Components

1. **Input Modules**: Receive messages from sources
2. **Processing Rules**: Filter and process messages
3. **Output Modules**: Write to files, network, databases

Example rsyslog rule:
```
# Facility.Level  output_file
*.err /var/log/errors.log          # All errors to errors.log
kern.* /var/log/kernel.log         # All kernel messages
auth.* /var/log/auth.log           # All auth messages
*.*    @remote-host                # Send to remote syslog server
```

---

## 2. Log Levels and Facilities

### Log Levels (Severity)

Levels from most to least severe:

| Level | Value | Use Case | Example |
|-------|-------|----------|---------|
| **EMERG** | 0 | System unusable | Kernel panic |
| **ALERT** | 1 | Immediate action needed | Hardware failure |
| **CRIT** | 2 | Critical | Authentication system down |
| **ERR** | 3 | Error | Device driver error |
| **WARNING** | 4 | Warning | Configuration issue |
| **NOTICE** | 5 | Normal but significant | User login |
| **INFO** | 6 | Informational | Service started |
| **DEBUG** | 7 | Debug information | Application trace |

### Facilities (Message Categories)

| Facility | Code | Typical Messages |
|----------|------|-----------------|
| **kern** | 0 | Kernel messages |
| **user** | 1 | User-level messages |
| **mail** | 2 | Mail system |
| **daemon** | 3 | System daemons |
| **auth** | 4 | Authentication (login, sudo) |
| **syslog** | 5 | Syslog daemon itself |
| **lpr** | 6 | Printing |
| **news** | 7 | News subsystem |
| **uucp** | 8 | UUCP subsystem |
| **cron** | 9 | Cron/at jobs |
| **local0-7** | 16-23 | Local use (custom applications) |

---

## 3. Important Log Files

### System Logs

| File | Contains | Distribution |
|------|----------|-------------|
| `/var/log/syslog` | General system messages | Ubuntu/Debian |
| `/var/log/messages` | General system messages | RHEL/CentOS |
| `/var/log/auth.log` | Authentication (login, sudo) | Ubuntu/Debian |
| `/var/log/secure` | Authentication | RHEL/CentOS |
| `/var/log/kern.log` | Kernel messages | Ubuntu/Debian |
| `/var/log/dmesg` | Boot-time kernel messages | All |
| `/var/log/cron` | Cron job output | All |
| `/var/log/mail.log` | Mail server messages | Ubuntu/Debian |
| `/var/log/apache2/` | Web server logs | Apache (Ubuntu/Debian) |
| `/var/log/httpd/` | Web server logs | Apache (RHEL/CentOS) |
| `/var/log/mysql/` | MySQL database logs | MySQL |
| `/var/log/docker/` | Container runtime logs | Docker |
| `/var/log/apt/` | Package manager logs | Ubuntu/Debian |
| `/var/log/yum.log` | Package manager logs | RHEL/CentOS |

### Kernel Ring Buffer

```
dmesg output
├── Hardware initialization
├── Driver loading
├── Boot messages (errors and warnings)
└── Recent kernel messages (in RAM)

# View with: dmesg or journalctl -n (systemd-journald)
```

---

## 4. Log File Format

### Standard Syslog Format

```
Jan 15 10:23:45 hostname process[PID]: message
```

**Components**:
- `Jan 15 10:23:45` - Timestamp
- `hostname` - System hostname
- `process[PID]` - Process name and ID
- `message` - The actual log message

### Example Logs

```
Jan 15 10:23:45 webserver sudo[2341]: user : TTY=pts/0 ; PWD=/home/user ; USER=root ; COMMAND=/bin/systemctl restart nginx
Jan 15 10:24:12 webserver kernel: [1234.567890] CPU0: Package temperature/speed normal

Jan 15 10:25:00 database mysql[5678]: ERROR: Can't open file './my.cnf'
Jan 15 10:26:15 auth sshd[9102]: Failed password for invalid user admin from 192.168.1.100 port 54321 ssh2
```

### Systemd Journal Format

```
journalctl output shows structured format:
-- Logs begin at Mon 2024-01-15 08:00:00 UTC, end at Mon 2024-01-15 10:30:00 UTC --
Jan 15 10:23:45 hostname process[2341]: message text
  PRIORITY=3
  MESSAGE_ID=1234567890
  SYSLOG_FACILITY=1
  _HOSTNAME=hostname
  _PID=2341
```

---

## 5. Log Rotation

### Why Log Rotation?

- **Disk space**: Logs can grow very large
- **File management**: Keeps logs organized
- **Retention**: Archives old logs separately
- **Performance**: Large files are slower to search

### Log Rotation Process

```
OLD LOGS          ROTATION          NEW LOGS
syslog          -------->          syslog
syslog.1                          (empty, ready for new)
syslog.2
syslog.3
syslog.4.gz
```

**Steps**:
1. Stop writing to current log
2. Rename current log to .1
3. Rename .1 to .2, etc.
4. Compress old logs (.gz)
5. Create new empty log file
6. Restart daemon to use new log

### Configuration (logrotate)

```bash
# /etc/logrotate.d/syslog
/var/log/syslog
{
    daily          # Rotate daily
    rotate 7       # Keep 7 versions
    compress       # Compress old logs
    delaycompress  # Don't compress until next rotation
    missingok      # Don't error if missing
    notifempty     # Don't rotate empty files
    sharedscripts  # Run scripts once per rotation
    postrotate
        /lib/systemd/systemd-update-utmp > /dev/null 2>&1 || true
    endscript
}
```

---

## 6. Systemd Journal (Journald)

### Modern Logging with Systemd

Modern systems use **systemd-journald** instead of (or alongside) rsyslog:

```
Application
    |
    v
Systemd-journald (structured logging)
    |
    +-----> Binary journal in /run/log/journal/
    |
    +-----> Forwarded to rsyslog (optional)
    |
    `-----> Available via journalctl
```

**Advantages**:
- Structured logging (key-value pairs)
- Indexed for fast searching
- Boot-aware (correlates with reboots)
- Integrates with systemd units

### Journalctl Examples

```bash
journalctl -n 50              # Last 50 messages
journalctl -f                 # Follow in real-time
journalctl -u nginx           # Messages from nginx unit
journalctl --since today      # Messages since today
journalctl -p err             # Only errors and above
journalctl -x                 # Catalog (explanations)
```

---

## 7. System Monitoring Basics

### Why Monitor?

```
No Monitoring (Reactive)
Problem occurs → Users report → Investigate → Fix
              ↑ (problems already causing impact)

With Monitoring (Proactive)
Threshold exceeded → Alert → Investigate → Fix
                                        (before impact)
```

### Key Metrics

#### CPU Monitoring
```
CPU Utilization: % of time CPU is busy
- User: Application code
- System: Kernel code
- I/O Wait: Waiting for disk
- Idle: Not in use

Ideal: Not consistently >80%
Alert threshold: >90% sustained
```

#### Memory Monitoring
```
Total Memory
├── Used (application data)
├── Buffers (disk cache)
├── Cache (frequently used data)
└── Free (available)

Ideal: Not consistently >85% used
Alert threshold: >95% or <5% free
```

#### Disk Monitoring
```
Disk Space
├── Used: Data stored
└── Available: Free space

Disk I/O
├── Read: Data from disk
├── Write: Data to disk
└── Wait: Time waiting for disk operations

Alert: <5% free space, >95% utilization
```

#### Network Monitoring
```
Network Traffic
├── Inbound: Incoming data
├── Outbound: Outgoing data
└── Errors: Transmission errors

Monitor: Bandwidth utilization, packet loss
Alert: >80% utilization, any packet loss
```

---

## 8. Monitoring Tools Overview

### Real-Time Tools

| Tool | Metric | Type |
|------|--------|------|
| **top** | CPU, Memory, Processes | Interactive |
| **htop** | Enhanced top | Interactive |
| **iotop** | Disk I/O by process | Interactive |
| **nethogs** | Network by process | Interactive |
| **watch** | Run command repeatedly | Command wrapper |

### Snapshot Tools

| Tool | Output | Use |
|------|--------|-----|
| **free** | Memory stats | Current memory |
| **df** | Disk usage | Disk space |
| **du** | Directory sizes | Find large dirs |
| **ps** | Process list | Process info |
| **netstat/ss** | Network connections | Port/connection status |
| **uptime** | System load | Overall load |

### Statistical Tools

| Tool | Output | Use |
|------|--------|-----|
| **iostat** | Disk I/O stats | Storage performance |
| **mpstat** | CPU stats per core | CPU analysis |
| **pidstat** | Process stats | Process performance |
| **sar** | System activity | Historical data |
| **vmstat** | Virtual memory | Memory analysis |

---

## 9. Understanding System Load

### Load Average

```
Load = Average number of processes ready to run

uptime output:
load average: 1.5, 2.0, 1.8
              (1min, 5min, 15min)

Interpretation (4-core system):
- 4.0: Full utilization (1 process per core)
- 8.0: 2x oversubscribed (2 processes per core)
- 0.5: Underutilized

Rule of thumb: Load < (number of CPU cores)
```

### CPU Utilization States

```
%user    - Time running application code
%sys     - Time in kernel mode
%iowait  - Time waiting for disk I/O
%idle    - Time not doing anything

Total: 100%

Problem diagnosis:
- High %user: CPU-bound application
- High %sys: Kernel issue or many interrupts
- High %iowait: Disk bottleneck
- Low %idle: System is busy (good if productive)
```

---

## 10. Troubleshooting Methodology

### Use Logs to Troubleshoot

**Step 1: Understand the Problem**
```bash
# Check recent errors
tail -n 100 /var/log/syslog | grep -i error
tail -n 100 /var/log/auth.log | grep failed

# Check systemd journal
journalctl -n 50 --priority=err
```

**Step 2: Look for Patterns**
```bash
# Search for specific service/error
grep "nginx\|error" /var/log/syslog | tail -20

# Check timestamps for correlation
grep "error" /var/log/syslog | awk '{print $1, $2, $3}'
```

**Step 3: Monitor During Issue**
```bash
# Real-time log watching
tail -f /var/log/syslog

# Watch processes
watch -n 1 'ps aux | grep application'

# Monitor system resources
iostat -x 1 10  # Show 10 intervals
```

**Step 4: Check Specific Components**
```bash
# Service status
systemctl status servicename

# Detailed logs
journalctl -u servicename -n 100

# Application-specific logs
tail /var/log/applicationname/error.log
```

### Common Issues and Log Clues

| Problem | Log Evidence |
|---------|-------------|
| Disk full | "No space left on device" in /var/log/messages |
| Memory exhausted | "Out of memory" in dmesg |
| Permission denied | "Permission denied" in /var/log/auth.log |
| Service won't start | "Failed to start" in journalctl |
| Network unreachable | "Network unreachable" in syslog |
| SSH brute force | Multiple "Failed password" in auth.log |
| Filesystem corruption | "I/O error" in dmesg and syslog |

---

## 11. Best Practices

### Logging Best Practices

1. **Understand log levels**: Don't ignore WARNINGs and ERRs
2. **Rotate regularly**: Prevent disk exhaustion
3. **Archive important logs**: Keep historical data for investigation
4. **Don't store sensitive data**: Passwords, tokens in logs
5. **Use proper formats**: Consistent, parseable logs
6. **Set appropriate retention**: Balance space vs history
7. **Monitor log growth**: Alert if logs grow unexpectedly

### Monitoring Best Practices

1. **Monitor meaningful metrics**: Focus on what matters
2. **Set thresholds appropriately**: Avoid alert fatigue
3. **Correlate metrics**: CPU spike + I/O spike = disk bottleneck
4. **Historical comparison**: Trends matter more than snapshots
5. **Understand baseline**: Know what's "normal" for your system
6. **Automate responses**: Alert + manual action = problems
7. **Document setup**: Why you're monitoring what

### Troubleshooting Best Practices

1. **Check logs first**: Before making changes
2. **Understand timestamps**: Correlate events across logs
3. **Look for patterns**: Single error vs repeated issue
4. **Test in stages**: Isolate the problem
5. **Keep change history**: Document what you tried
6. **Use baseline**: Compare to known-good state
7. **Communicate findings**: Share knowledge with team

---

## 12. Advanced Concepts

### Centralized Logging

```
Multiple Hosts
    |
    +---> Server A: Send to syslog server
    |
    +---> Server B: (rsyslog rule: *.* @logserver)
    |
    v
Central Log Server (collects all logs)
    |
    v
Analysis and Alerting
```

**Benefits**:
- Single place to search all logs
- Correlation across systems
- Compliance/audit trail
- Log preservation if host fails

**Tools**: rsyslog with remote forwarding, ELK stack, Splunk, Graylog

### Metrics Collection

```
System Metrics → Collector → Storage → Visualization
(CPU %, Mem)  (telegraf)    (InfluxDB) (Grafana)
              (Prometheus)  (Prometheus)
```

**Common stacks**:
- Prometheus + Grafana (open source, popular)
- InfluxDB + Telegraf + Grafana
- DataDog, New Relic (commercial)

---

## Summary

**Key Takeaways**:

1. **Syslog system** routes logs based on facility and level
2. **Log levels** indicate severity; understand what each means
3. **Multiple sources** create logs: kernel, system, applications
4. **Log rotation** prevents disk exhaustion
5. **Systemd journal** provides modern structured logging
6. **Monitoring** means tracking metrics over time
7. **Key metrics**: CPU, memory, disk, network
8. **Tools exist** for every monitoring need (top, iostat, journalctl)
9. **Logs are for troubleshooting**: Use them systematically
10. **Proactive monitoring** beats reactive firefighting

The next sections (commands and labs) will teach you the practical skills to apply this knowledge.
