# Module 13: Logging and Monitoring

## Overview

Logging and monitoring are critical to managing, troubleshooting, and securing Linux systems. This module covers how to capture system events, analyze logs, monitor system health, and understand application behavior through logs and metrics.

**Why This Matters**:
- Detect and troubleshoot system issues before they become critical
- Track security incidents and suspicious activity
- Understand application performance and behavior
- Comply with audit and compliance requirements
- Maintain system health and stability
- Root cause analysis for production issues

**Real-World Context**:
Every second, Linux systems generate thousands of log messages and metrics. A DevOps engineer needs to:
- Know where to find relevant logs when troubleshooting
- Understand what messages mean and how urgent they are
- Monitor system resources to prevent outages
- Analyze logs for security incidents
- Set up alerts for critical events

This module teaches you to be systematic and efficient with logs and monitoring—essential skills for production systems.

---

## Prerequisites

Before starting this module, you should be comfortable with:
- **Module 06**: System Services and Daemons (rsyslog, systemd)
- **Module 07**: Process Management (ps, top, processes)
- **Module 12**: Security and Firewall (understanding security implications of logs)
- **Module 02**: Advanced Commands (grep, awk, sed for log parsing)

**Recommended Skills**:
- Basic Linux command line
- Understanding of system processes
- Text file viewing and manipulation
- Regular expressions (helpful but not required)

---

## Learning Objectives

After completing this module, you will be able to:

### Logging Knowledge
- [ ] Understand syslog architecture and how logs are generated
- [ ] Navigate log file locations and understand log purposes
- [ ] Interpret log levels and message formats
- [ ] Filter and search logs using grep, awk, and other tools
- [ ] Configure log rotation to prevent disk space issues
- [ ] Troubleshoot system issues using logs
- [ ] Understand centralized logging concepts

### Monitoring Skills
- [ ] Monitor system resources (CPU, memory, disk, network)
- [ ] Interpret system performance metrics
- [ ] Use monitoring tools (top, htop, iostat, netstat)
- [ ] Identify performance bottlenecks
- [ ] Monitor specific processes and services
- [ ] Set up basic alerting
- [ ] Understand systemd journal for modern logging

### Practical Application
- [ ] Parse and analyze real log files
- [ ] Create log monitoring scripts
- [ ] Configure log retention policies
- [ ] Debug application issues using logs
- [ ] Monitor long-running processes
- [ ] Capture and analyze system metrics

---

## Module Roadmap

### Core Content Files

| File | Purpose | Time |
|------|---------|------|
| [01-theory.md](01-theory.md) | Logging architecture, syslog, monitoring concepts | 45 min |
| [02-commands-cheatsheet.md](02-commands-cheatsheet.md) | 80+ commands for logs and monitoring | 20 min |
| [03-hands-on-labs.md](03-hands-on-labs.md) | 8 practical labs (troubleshooting, monitoring, analysis) | 2.5-3 hours |

### Practical Tools

| Script | Purpose |
|--------|---------|
| [log-analyzer.sh](scripts/log-analyzer.sh) | Parse, filter, and analyze log files with statistics |
| [system-monitor.sh](scripts/system-monitor.sh) | Real-time system monitoring with alerts |
| [logwatch-helper.sh](scripts/logwatch-helper.sh) | Setup and manage logwatch for automated log reviews |

### Learning Path

1. **Read theory** (45 minutes) - Understand logging and monitoring concepts
2. **Review commands** (20 minutes) - Learn command-line tools
3. **Practice labs** (2.5-3 hours total):
   - Lab 1-2: Understand logs and explore system logs
   - Lab 3-4: Monitor system resources
   - Lab 5-6: Analyze and troubleshoot using logs
   - Lab 7-8: Set up monitoring and alerting

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Syslog** | Standard Linux logging system that receives and distributes log messages |
| **Log Level** | Severity indicator (DEBUG, INFO, NOTICE, WARNING, ERR, CRIT, ALERT, EMERG) |
| **Facility** | Category of logging source (kernel, mail, auth, daemon, syslog, etc.) |
| **Rsyslog** | Modern syslog daemon that processes and routes log messages |
| **Journald** | Systemd's modern logging service with structured logging |
| **Log Rotation** | Moving old logs and creating new ones to manage disk space |
| **Metric** | Quantified measurement (CPU %, memory usage, network throughput) |
| **Threshold** | Alert trigger point (e.g., alert if CPU > 80%) |
| **Sysstat** | System statistics package with tools like iostat, mpstat, pidstat |
| **Strace** | Tool to trace system calls and signals from a process |
| **Ltrace** | Tool to trace library calls from a process |
| **Tail** | Command to display end of files, especially for real-time log viewing |
| **Dmesg** | Kernel ring buffer messages (boot and hardware messages) |

---

## Time Estimates

| Component | Time | Difficulty |
|-----------|------|-----------|
| Reading 01-theory.md | 45 minutes | Beginner |
| Review 02-commands-cheatsheet.md | 20 minutes | Beginner |
| Lab 1: Explore syslog | 15 minutes | Beginner |
| Lab 2: Understand log levels | 20 minutes | Beginner |
| Lab 3: Monitor CPU and memory | 20 minutes | Beginner |
| Lab 4: Disk and network monitoring | 25 minutes | Beginner |
| Lab 5: Parse and filter logs | 30 minutes | Intermediate |
| Lab 6: Troubleshoot using logs | 30 minutes | Intermediate |
| Lab 7: Setup log rotation | 20 minutes | Intermediate |
| Lab 8: Configure system alerts | 25 minutes | Intermediate |
| **Total** | **3-3.5 hours** | - |

---

## How to Use This Module

### For Self-Study
1. Start with README.md (this file) for context
2. Read 01-theory.md to understand concepts
3. Use 02-commands-cheatsheet.md as reference
4. Work through 03-hands-on-labs.md in order
5. Try the scripts and modify them for your needs

### For Classroom
1. Use theory as lecture material
2. Demonstrate commands live from cheatsheet
3. Have students work through labs (individually or in pairs)
4. Show script examples and discuss modifications
5. Assign one lab per week for deeper learning

### For Reference
- Bookmark commands cheatsheet for quick lookup
- Use log-analyzer.sh for production log analysis
- Refer to labs when troubleshooting real issues
- Review scripts for log monitoring patterns

---

## Important Notes & Safety

### Lab Safety
- ✓ All labs are **non-destructive** (read-only by default)
- ✓ Safe to run on production systems in *monitoring* mode
- ✓ Log rotation labs use test files (not system logs)
- ✓ Recommended: Use VM for writing/testing modifications

### Best Practices
- Always **backup before rotating** production logs
- Use **grep carefully** on large files (can be slow)
- **Understand log rotation** before configuring (don't lose important logs)
- **Monitor appropriately** (too much data = noise, too little = blind)
- **Document your setup** for troubleshooting later

### Common Mistakes
- Not understanding log levels (noise vs important messages)
- Monitoring wrong metric for the problem (CPU vs I/O)
- Deleting logs without archiving first
- Setting alerts too tight (false positives)
- Collecting metrics without analysis strategy

---

## Module Success Criteria

You've completed this module successfully when you can:

- [ ] Locate and understand system log files
- [ ] Use grep/awk to extract relevant information from logs
- [ ] Interpret log messages and understand their severity
- [ ] Monitor CPU, memory, disk, and network usage
- [ ] Identify performance bottlenecks
- [ ] Troubleshoot issues using log analysis
- [ ] Configure log rotation on test systems
- [ ] Create simple monitoring and alerting scripts
- [ ] Understand real-time vs periodic monitoring
- [ ] Know the difference between syslog and journald

---

## Prerequisites to Other Modules

This module prepares you for:
- **Module 14**: Package Management (understand logs from package operations)
- **Module 15**: Storage and Filesystems (disk I/O monitoring)
- **Module 16**: Shell Scripting Basics (create monitoring scripts)
- **Module 17**: Troubleshooting and Scenarios (use logs for debugging)

---

## Recommended Tools & Environment

### For Labs
- **OS**: Ubuntu 20.04+ or CentOS 8+ (VM recommended)
- **Tools**:
  - `rsyslog` (usually pre-installed)
  - `systemd-journald` (modern logging)
  - `grep`, `awk`, `sed` (text processing)
  - `top`, `htop`, `iostat` (monitoring)
  - `tail`, `less` (log viewing)

### Installation
```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install sysstat htop

# On RHEL/CentOS
sudo yum install sysstat
sudo yum install htop  # or use top (built-in)
```

---

## Quick Start

To get started immediately:

```bash
# View system logs
tail -f /var/log/syslog              # Ubuntu/Debian
tail -f /var/log/messages             # RHEL/CentOS

# Check system resources
top                                   # Interactive monitoring
free -h                               # Memory usage
df -h                                 # Disk usage
iostat -x 1 5                         # I/O statistics

# View systemd journal
journalctl -n 50                      # Last 50 messages
journalctl -f                         # Real-time follow
```

---

## File Organization

```
13-logging-and-monitoring/
├── README.md                    # This file (overview & roadmap)
├── 01-theory.md                 # Logging and monitoring theory
├── 02-commands-cheatsheet.md    # Command reference (80+ commands)
├── 03-hands-on-labs.md          # 8 practical labs
└── scripts/
    ├── README.md                # Scripts documentation
    ├── log-analyzer.sh          # Log parsing and analysis
    ├── system-monitor.sh        # System monitoring with alerts
    └── logwatch-helper.sh       # Logwatch setup and management
```

---

## Next Steps

1. **Start with 01-theory.md** to understand the concepts
2. **Review 02-commands-cheatsheet.md** for tools you'll use
3. **Work through 03-hands-on-labs.md** hands-on
4. **Explore scripts/** for automation examples
5. **Practice on your own systems** for real experience

Good luck, and happy learning! 📊🔍

