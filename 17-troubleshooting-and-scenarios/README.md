# Troubleshooting and Scenarios

Master practical Linux troubleshooting and real-world problem-solving.

---

## Overview

Troubleshooting is the most critical skill in system administration. Whether a service won't start, the system is slow, or the network is down, you need a systematic approach to diagnose and fix problems.

### Real-World Importance

**Every Linux Professional Needs This:**
- **System Reliability:** Quickly diagnose and fix problems before they impact users
- **Production Support:** 24/7 on-call requires fast troubleshooting skills
- **Performance Tuning:** Identify bottlenecks and optimize system performance
- **Incident Response:** Methodically handle security issues and failures
- **Time & Money:** Every minute of downtime costs; expertise saves millions
- **Career Advancement:** Troubleshooting skills are what separate junior from senior engineers

**Real Scenarios You'll Face:**
- Service stops responding (web server, database, SSH)
- System is slow (CPU, memory, disk I/O issues)
- Disk space is full (can't find the culprit)
- Network is unreachable (routing, firewall, configuration)
- Processes are crashing (memory leak, segfault, permission)
- Port is in use (which process, why, how to stop)
- Application fails to start (missing dependencies, configuration)
- Login fails (authentication, permissions, configuration)

### What This Module Covers

A **systematic approach** to Linux troubleshooting:
- Diagnostic methodology (gather facts first)
- Essential tools (top, ps, netstat, journalctl, strace)
- Common scenarios with solutions
- Log analysis techniques
- Performance monitoring
- Network troubleshooting
- Service failure recovery
- Real-world case studies

---

## Prerequisites

Before starting this module, you should understand:
- **Modules 01-02:** Linux basics, command-line, file system
- **Modules 03-07:** System concepts (processes, services, permissions)
- **Module 16:** Shell scripting (for automation)

**Recommended:**
- Access to a Linux VM (Ubuntu 20.04+ or CentOS 7+)
- Text editor (nano or vim)
- Basic understanding of services (systemd, unit files)
- Comfort with shell commands and pipes

---

## Learning Objectives

After completing this module, you will be able to:

1. **Follow a Troubleshooting Methodology**
   - Gather information systematically
   - Form hypotheses about problems
   - Test solutions methodically
   - Document findings

2. **Use Essential Diagnostic Tools**
   - Process monitoring (ps, top, htop)
   - Network diagnostics (netstat, ss, traceroute)
   - Log analysis (journalctl, grep, awk)
   - System monitoring (iostat, vmstat, sar)

3. **Diagnose Common Problems**
   - Service failures and crashes
   - Performance issues (CPU, memory, disk)
   - Network connectivity problems
   - Disk space exhaustion
   - Port conflicts

4. **Analyze Logs Effectively**
   - Find relevant log entries
   - Understand error messages
   - Correlate events across logs
   - Extract actionable information

5. **Troubleshoot Network Issues**
   - Test connectivity (ping, traceroute)
   - Check routing and DNS
   - Identify firewall issues
   - Diagnose port problems

6. **Monitor and Tune Performance**
   - Identify resource bottlenecks
   - Analyze I/O performance
   - Understand context switching
   - Find resource leaks

7. **Recover from Service Failures**
   - Restart services safely
   - Check dependencies
   - Understand startup sequences
   - Perform rollback operations

8. **Handle Real Scenarios**
   - Apply techniques to actual problems
   - Make decisions under pressure
   - Document your process
   - Learn from incidents

---

## Module Roadmap

| File | Time | Content |
|------|------|---------|
| **README.md** | 5 min | Overview, objectives, glossary, roadmap |
| **01-theory.md** | 90 min | Methodology, tools, concepts, workflow |
| **02-commands-cheatsheet.md** | 40 min | Reference of commands and patterns |
| **03-hands-on-labs.md** | 300 min | 8 complete troubleshooting labs |
| **scripts/** | 45 min | Diagnostic tools and helpers |
| **TOTAL** | ~480 min (~8 hours) | Complete troubleshooting mastery |

---

## Quick Glossary

**Core Concepts:**

- **Troubleshooting:** Systematic process of identifying and fixing problems
- **Diagnosis:** Determining what problem exists
- **Root Cause:** The underlying reason a problem occurs
- **Symptom:** What the user observes or reports
- **Strace:** Tool to trace system calls made by a process
- **Journal:** Systemd's unified logging system (journalctl)
- **Syslog:** Traditional Linux logging system
- **STDOUT/STDERR:** Standard output and error streams
- **Exit Code:** Number returned by a command (0=success, non-zero=failure)
- **Zombie Process:** Process that has ended but hasn't been reaped
- **Segmentation Fault:** Process accessed invalid memory
- **Out of Memory (OOM):** System ran out of RAM
- **Inode:** Filesystem structure holding file metadata
- **Context Switch:** CPU switching between processes
- **Load Average:** Average number of processes in run queue
- **Throughput:** Amount of data processed per unit time
- **Latency:** Time delay in a system
- **Bottleneck:** Component limiting overall performance
- **Firewall:** Network filtering (iptables, ufw, firewalld)
- **Route:** Network path to reach a destination
- **DNS:** Domain name to IP address resolution
- **TCP/IP Stack:** Network protocol implementation
- **Port:** Endpoint for network communication
- **Socket:** Connection endpoint in network
- **MTU:** Maximum Transmission Unit (packet size)

**Tools:**

- **top:** Real-time process monitor
- **ps:** List processes
- **htop:** Enhanced process viewer
- **netstat:** Network statistics
- **ss:** Socket statistics (modern netstat)
- **iostat:** I/O statistics
- **vmstat:** Virtual memory statistics
- **strace:** System call tracer
- **journalctl:** Read systemd logs
- **dmesg:** Kernel message buffer
- **lsof:** List open files
- **free:** Memory information
- **df:** Disk space usage
- **du:** Directory size analysis
- **iotop:** I/O activity monitor
- **tcpdump:** Network packet capture
- **curl/wget:** HTTP requests
- **dig/nslookup:** DNS queries

---

## Time Breakdown

**Total Module Time: ~8 hours**

| Activity | Time |
|----------|------|
| Reading theory | 90 min |
| Command cheatsheet review | 40 min |
| Hands-on labs | 300 min |
| Script study | 45 min |
| Review & practice | 45 min |
| **Total** | **~520 min** |

---

## Lab Environment Setup

### Create Lab Directory

```bash
mkdir -p ~/troubleshooting-labs
cd ~/troubleshooting-labs
```

### Install Tools (Ubuntu/Debian)

```bash
# Essential troubleshooting tools
sudo apt update
sudo apt install -y \
    htop \
    iotop \
    sysstat \
    net-tools \
    netcat-traditional \
    curl \
    wget \
    git \
    vim \
    tmux
```

### Install Tools (CentOS/RHEL)

```bash
# Essential troubleshooting tools
sudo yum install -y \
    htop \
    iotop \
    sysstat \
    net-tools \
    ncat \
    curl \
    wget \
    git \
    vim \
    tmux
```

### Verify Installation

```bash
# Check tools are available
which top ps journalctl netstat df du strace lsof

# Version check
top --version
journalctl --version
```

---

## Lab Safety

**Before Running Labs:**

- ✓ **Use a VM, not production**
- ✓ **Have a snapshot for rollback**
- ✓ **Read instructions completely first**
- ✓ **Don't kill critical processes without permission**
- ✓ **Be careful with sudo commands**
- ✓ **Keep logs of your work**

**Safe Practices:**

1. Always understand a command before running it
2. Start with `--help` or `man page`
3. Use `--dry-run` when available
4. Test on non-critical services first
5. Document your changes
6. Have a recovery plan

---

## Common Mistakes to Avoid

**Diagnostic Mistakes:**

| Mistake | Problem | Solution |
|---------|---------|----------|
| Not checking logs first | Waste time guessing | Always check error logs first |
| Assuming you know the cause | Miss root cause | Form hypothesis, test it |
| Not gathering baseline data | Can't compare | Collect normal state data first |
| Overlooking simple causes | Overthink the problem | Check obvious things first |
| Testing in production | Cause actual problems | Always test in lab first |

**Troubleshooting Mistakes:**

| Mistake | Problem | Solution |
|---------|---------|----------|
| Restart before diagnosis | Don't learn what failed | Diagnose first, then fix |
| Using wrong permissions | Can't see the issue | Use sudo when needed |
| Not reading full error | Miss important details | Read complete error message |
| Changing multiple things | Can't identify cause | Change one thing at a time |
| Not documenting findings | Repeat same investigation | Keep a troubleshooting log |

---

## Recommended Tools

### Terminal Multiplexer

```bash
# Install tmux
sudo apt install tmux

# Usage: Open multiple terminals in one SSH session
tmux new-session -s work
# Ctrl+B then C = new window
# Ctrl+B then & = close window
# Ctrl+B then " = split horizontal
```

### Text Editors

```bash
# Nano (beginner-friendly)
nano filename

# Vim (powerful, steep learning curve)
vim filename
```

### Enhanced Viewers

```bash
# Better than top
htop

# Better than netstat
ss -tulpn

# Monitor I/O
iotop
```

---

## Troubleshooting Methodology

### Step 1: Gather Information

```bash
# What's the actual symptom?
# When did it start?
# What changed recently?
# Who reported it?
# What's the impact?
```

### Step 2: Check Logs

```bash
# System logs
journalctl -xe
journalctl -u service-name
grep -i error /var/log/syslog

# Application logs
tail -f /var/log/application/error.log
```

### Step 3: Check System Status

```bash
# Process status
ps aux | grep process-name
top -p PID

# Service status
systemctl status service-name
systemctl is-active service-name
```

### Step 4: Test Connectivity

```bash
# If network-related
ping remote.host
traceroute remote.host
netstat -tulpn
curl http://service:port
```

### Step 5: Check Resources

```bash
# Disk space
df -h
du -sh *

# Memory
free -h
top

# CPU
vmstat 1 5
iostat -x 1 5
```

### Step 6: Form Hypothesis

```
IF [symptom] THEN [likely cause]
  • Service not responding → Check if running, check logs, check ports
  • System slow → Check CPU, memory, disk I/O
  • Disk full → Find large files/directories
  • Port in use → Find which process owns it
```

### Step 7: Test & Verify

```bash
# Test your hypothesis
# Make one change at a time
# Check if symptom is resolved
# Verify nothing else broke
```

### Step 8: Document & Learn

```bash
# What was the problem?
# What was the root cause?
# What did you do to fix it?
# How do we prevent this?
# What did you learn?
```

---

## Success Criteria

You'll know you've mastered this module when you can:

- ✓ Quickly identify what's wrong using logs and tools
- ✓ Use ps, top, journalctl, netstat without thinking
- ✓ Diagnose service failures in < 5 minutes
- ✓ Identify resource bottlenecks (CPU, memory, I/O)
- ✓ Solve network connectivity issues methodically
- ✓ Analyze logs and extract relevant information
- ✓ Make decisions under pressure
- ✓ Document your troubleshooting process
- ✓ Prevent similar problems in the future
- ✓ Help team members with their problems

---

## Quick Start Path

**For busy learners (4 hours minimum):**

1. Read theory sections 1-4 (methodology, tools, concepts)
2. Do labs 1-3 (service failures, resource issues)
3. Study command cheatsheet sections 1-5
4. Review troubleshooting scripts

This gives you the core 80% of troubleshooting skills.

---

## Module Files

```
17-troubleshooting-and-scenarios/
├── README.md                    ← You are here
├── 01-theory.md                 ← Core concepts
├── 02-commands-cheatsheet.md    ← Reference guide
├── 03-hands-on-labs.md          ← 8 practical labs
└── scripts/
    ├── README.md                ← Scripts documentation
    ├── system-checker.sh        ← Health check tool
    └── problem-generator.sh     ← Create test scenarios
```

---

## How to Use This Module

### For Self-Study

1. Start with **README.md** (this file) - 5 minutes
2. Read **01-theory.md** carefully - 90 minutes
3. Skim **02-commands-cheatsheet.md** - 20 minutes
4. Do labs in **03-hands-on-labs.md** one at a time - 300+ minutes
5. Study **scripts/** directory - 45 minutes
6. Practice troubleshooting your own systems

### For Instructors

1. Use theory as lecture material
2. Demonstrate tools in real-time
3. Have students pair-program on labs
4. Use problem-generator.sh for extra scenarios
5. Discuss real production issues from your environment

### For Learning Groups

1. Divide labs among team members
2. Each person presents their findings
3. Discuss different solution approaches
4. Share war stories from production
5. Create incident postmortems together

---

## Next Steps After This Module

Once you master troubleshooting:

- **Module 12:** Deep dive into security issues
- **Module 13:** Understand logging and monitoring in detail
- **Module 14:** Package management troubleshooting
- **Advanced:** Kernel debugging, performance analysis, kernel panic recovery

---

## Additional Resources

**Online Documentation:**
- Linux man pages: `man command`
- Kernel docs: https://kernel.org/doc/
- Systemd docs: https://systemd.io/
- Network tools: https://www.tcpdump.org/

**Books:**
- "Linux Performance Analysis" - Brendan Gregg
- "The Linux Command Line" - William Shotts
- "How Linux Works" - Brian Ward

**Practice Environments:**
- Linux Academy (now Linux Foundation)
- HackTheBox (security scenarios)
- OverTheWire (security wargames)

---

## Support & Help

**If you get stuck:**

1. Check the troubleshooting section in 01-theory.md
2. Review relevant command in 02-commands-cheatsheet.md
3. Look at lab solutions in 03-hands-on-labs.md
4. Run `man command` for detailed help
5. Search online: "error message linux"
6. Ask community: r/linuxadmin, linux subreddits

**Before asking for help, try:**
- [ ] Read error message carefully
- [ ] Check log files
- [ ] Google the exact error
- [ ] Try a simpler test case
- [ ] Document what you've tried

---

## Quick Reference

### Most Important Commands

```bash
# Check system health
top              # Process monitor
journalctl -xe   # Recent logs
systemctl status # Service status
df -h            # Disk space
free -h          # Memory usage
netstat -tulpn   # Network sockets

# Find problems
ps aux           # All processes
lsof -p PID      # Open files by process
strace -p PID    # System calls
tcpdump -i eth0  # Network traffic
iotop            # Disk I/O
```

### Emergency Procedures

```bash
# System running out of space - find culprits
du -sh /* | sort -rh

# Service won't start - check logs
journalctl -u service-name -n 50

# Port in use - find owner
netstat -tulpn | grep :8080

# High memory - find process
top -b -n 1 | sort -k6 -rh | head

# Find open files
lsof | grep deleted
```

---

**Version:** 1.0  
**Last Updated:** 2024-01-15  
**Difficulty:** Intermediate  
**Time to Complete:** ~8 hours  
**Prerequisites:** Modules 01-02, 16 recommended
