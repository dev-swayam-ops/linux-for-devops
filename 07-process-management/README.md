# Module 07: Process Management

## Overview

Process management is fundamental to Linux system administration and development. Understanding how processes work—from creation and execution to monitoring and termination—is essential for troubleshooting system issues, optimizing performance, and writing robust scripts.

### Why This Matters

**Real-World Scenarios:**

1. **Your web service crashed** - You need to find stuck processes and restart them safely
2. **System is slow** - You need to identify resource-hungry processes and manage their priority
3. **Background job won't stop** - You need to send the right signal to terminate it
4. **Zombie processes accumulate** - You need to understand process states and cleanup
5. **Multiple tasks competing** - You need to manage CPU allocation between processes
6. **Automated task running forever** - You need to monitor and control process execution

This module teaches you to:
- Understand Linux process architecture and lifecycle
- Monitor running processes effectively
- Control process execution (start, stop, prioritize)
- Debug process-related problems
- Write process management automation

---

## Prerequisites

**Required Knowledge:**
- Module 01: Linux Basics Commands (file navigation, basic commands)
- Module 02: Linux Advanced Commands (grep, awk, pipes, redirection)
- Comfortable with shell basics (variables, conditionals)

**System Requirements:**
- Linux system with bash (Ubuntu 18.04+, RHEL 8+, Debian 10+)
- Optional: htop, tmux for enhanced labs
- 2GB RAM minimum for labs

**Skills Assumed:**
- Can navigate filesystem with cd, ls
- Understand pipes (|) and redirection (>, >>)
- Basic grep and awk usage
- Can write simple bash scripts

---

## Learning Objectives

### Beginner Level
By completing beginner labs (1-3), you will:
- [ ] Understand what a process is and how it differs from a program
- [ ] List and identify running processes using ps and top
- [ ] Understand PID, PPID, and process hierarchy
- [ ] Start processes in foreground and background
- [ ] Use job control (jobs, fg, bg, &)
- [ ] Understand basic process states (running, sleeping, stopped)

**Estimated Time**: 60 minutes

### Intermediate Level
By completing intermediate labs (4-8), you will:
- [ ] Monitor process resource usage (CPU, memory)
- [ ] Send signals to processes (SIGTERM, SIGKILL, etc.)
- [ ] Understand process priority and nice values
- [ ] Use ps with advanced filtering and formatting
- [ ] Identify and handle zombie/orphan processes
- [ ] Debug process issues using system utilities

**Estimated Time**: 120 minutes

### Advanced Level
By completing advanced sections (scripts, theory), you will:
- [ ] Implement process monitoring automation
- [ ] Parse process data programmatically
- [ ] Create process control workflows
- [ ] Understand process groups and sessions
- [ ] Optimize process execution for performance
- [ ] Integrate process management into scripts

**Estimated Time**: 40 minutes

---

## Module Roadmap

### 1. Learning Materials

**[01-theory.md](01-theory.md)** - Conceptual Foundations
- What is a process? (Program vs Process vs Thread)
- Process lifecycle and states
- PID and process hierarchy
- Process memory and resources
- Signals and signal handling
- Process groups and sessions
- Zombie and orphan processes
- Process scheduling basics
- Job control mechanism
- Real-world process examples

**[02-commands-cheatsheet.md](02-commands-cheatsheet.md)** - Command Reference
- 20+ essential commands with examples
- Process listing (ps, pgrep, pidof)
- Process monitoring (top, htop, watch)
- Process control (kill, pkill, killall)
- Job control (jobs, fg, bg)
- Priority management (nice, renice)
- Process tracing (strace, ltrace)
- Quick reference table

**[03-hands-on-labs.md](03-hands-on-labs.md)** - Practical Exercises
- 8 progressive hands-on labs
- Total lab time: 180 minutes
- Labs cover process exploration, monitoring, signals, priority, and troubleshooting

### 2. Production Tools

**[scripts/](scripts/README.md)** - Operational Scripts
- `process-monitor.sh` - Real-time process monitoring
- `process-analyzer.sh` - Detailed process analysis
- Installation guide and usage examples

### 3. Verification

**[COMPLETION-STATUS.md](COMPLETION-STATUS.md)** - Module Summary
- Content inventory and status
- Learning objectives achievement
- Quality assurance checklist
- Module statistics

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Process** | A running instance of a program with its own memory and resources |
| **PID** | Process ID - unique identifier for a process |
| **PPID** | Parent Process ID - PID of the process that created this process |
| **Foreground** | Process running in terminal, blocking command prompt |
| **Background** | Process running without blocking terminal prompt |
| **Daemon** | Background process with no controlling terminal (covered in Module 06) |
| **Zombie** | Dead process still in kernel process table (waiting for parent) |
| **Orphan** | Process whose parent has terminated |
| **Signal** | Asynchronous notification to process (SIGTERM, SIGKILL, etc.) |
| **Nice Value** | Priority level (-20 to 19, lower = higher priority) |
| **Job** | Shell's representation of a process or group |
| **Process Group** | Collection of processes that can receive same signal |
| **Session** | Collection of process groups sharing same controlling terminal |
| **Virtual Memory** | Total memory addressable by process (VIRT/VSZ) |
| **Resident Memory** | Physical RAM used by process (RSS/RES) |
| **Context Switch** | CPU switching between processes |

---

## Common Workflows

### Workflow 1: Find and Monitor a Specific Process

```bash
# Find the process
pgrep -l nginx

# Get detailed info
ps aux | grep nginx

# Monitor in real-time
top -p $(pgrep -o nginx)

# Or with watch
watch 'ps aux | grep nginx'
```

### Workflow 2: Kill a Misbehaving Process

```bash
# Find it
ps aux | grep stuck_process

# Get PID
PID=$(pgrep stuck_process)

# Try graceful termination
kill -TERM $PID
sleep 2

# Force kill if needed
kill -KILL $PID

# Verify it's gone
ps -p $PID
```

### Workflow 3: Manage Process Priority

```bash
# Start with low priority
nice -n 10 long_running_task

# Or change running process priority
renice -n 5 -p $(pgrep long_running_task)

# Check priority (NI column)
ps aux | grep long_running_task
```

### Workflow 4: Debug Resource-Heavy Process

```bash
# Find top CPU users
ps aux --sort=-%cpu | head -10

# Find top memory users
ps aux --sort=-%mem | head -10

# Detailed memory info
ps aux | grep process_name
cat /proc/PID/status | grep Vm
```

### Workflow 5: Handle Background Jobs

```bash
# Start process in background
long_task &

# List background jobs
jobs

# Bring to foreground
fg %1

# Suspend (Ctrl+Z)
# Resume in background
bg %1
```

---

## Module Features

### Hands-On Learning
- 8 complete, safe labs ranging from 15-40 minutes each
- Progressive difficulty (beginner to advanced)
- Real-world troubleshooting scenarios
- All labs use safe test processes (no production system impact)

### Practical Tools
- 2 production-ready monitoring scripts
- Real-time process tracking
- Detailed process analysis
- Process automation examples

### Comprehensive Documentation
- 10+ theory sections with ASCII diagrams
- 20+ commands with 50+ real-world examples
- Quick reference tables
- Troubleshooting guides
- Integration patterns for scripting

### Security-Conscious Design
- Safe signal handling practices
- Best practices for process cleanup
- Resource limit considerations
- No assumptions about elevated privileges

---

## Success Criteria

After completing this module, you should be able to:

1. **List processes** - Use ps, pgrep, and top to find specific processes
2. **Understand hierarchy** - Trace parent-child process relationships
3. **Control execution** - Start, stop, prioritize, and manage processes
4. **Send signals** - Use kill, pkill with appropriate signals
5. **Monitor resources** - Track CPU and memory usage over time
6. **Troubleshoot problems** - Identify zombie processes, orphans, and stuck processes
7. **Automate management** - Write scripts for process monitoring and control

---

## How to Use This Module

### Recommended Study Path

1. **Read Module Overview** (this file)
   - 5 minutes to get context

2. **Study Theory** ([01-theory.md](01-theory.md))
   - 60 minutes to understand concepts
   - Focus on process lifecycle and states
   - Understand signals and job control

3. **Reference Commands** ([02-commands-cheatsheet.md](02-commands-cheatsheet.md))
   - Use as reference while doing labs
   - Try examples in your terminal
   - Build command fluency

4. **Complete Labs** ([03-hands-on-labs.md](03-hands-on-labs.md))
   - Work through in order (1-8)
   - 180 minutes total
   - Each lab builds on previous knowledge

5. **Explore Scripts** ([scripts/](scripts/README.md))
   - Review production scripts
   - Try examples
   - Integrate into your workflows

### Lab Environment Setup

```bash
# Recommended: Use a VM to avoid affecting your main system
# All labs are safe and contained, but VM is best practice

# On your Linux VM, clone or navigate to this module:
cd linux-for-devops/07-process-management

# Make scripts executable:
chmod +x scripts/*.sh

# Start with lab 1:
# Follow instructions in 03-hands-on-labs.md
```

---

## What's Covered vs. What's Not

### Covered in This Module
- Process fundamentals and lifecycle
- Process monitoring and control
- Job control in bash
- Process signals
- Priority and resource management
- Common troubleshooting scenarios
- Practical process automation

### Related to Other Modules
- **Module 06**: System services and daemons (background processes)
- **Module 05**: Memory and disk management (process resources)
- **Module 13**: Logging and monitoring (process event tracking)
- **Module 16**: Shell scripting basics (process scripting fundamentals)

### Out of Scope
- Advanced kernel scheduling (for kernel development)
- Real-time process scheduling (SCHED_RR, SCHED_FIFO)
- Memory management internals
- Container process isolation

---

## Troubleshooting This Module

### "Command not found" errors

Some commands might not be installed:
```bash
# Install htop if needed
sudo apt install htop

# Install tmux for lab 8
sudo apt install tmux
```

### "Permission denied" on /proc files

This is normal. Use `sudo` when needed:
```bash
sudo ps aux
sudo kill -9 PID
```

### Labs not running as expected

Verify systemd is installed:
```bash
systemctl --version
ps aux | head -5
```

---

## Next Steps After This Module

### Immediate
- Practice with your own processes
- Monitor your system with provided scripts
- Use kill/nice in real scenarios

### Then Study
- **Module 13**: Advanced logging and monitoring
- **Module 06**: System services and background processes
- **Module 16**: Shell scripting for process automation

### Advanced Topics
- Container process management (Docker, Kubernetes)
- Advanced system performance tuning
- Custom kernel module development

---

## Module Statistics

| Metric | Value |
|--------|-------|
| Theory Sections | 10+ |
| Documented Commands | 20+ |
| Real Examples | 50+ |
| Hands-On Labs | 8 |
| Lab Time | 180 minutes |
| Production Scripts | 2 |
| ASCII Diagrams | 8+ |

---

## Quick Start (TL;DR)

```bash
# Verify you can run labs
ps aux | head -3

# Start first lab
cat 03-hands-on-labs.md | head -100

# Make scripts executable
chmod +x scripts/*.sh

# Run a script
./scripts/process-monitor.sh --help
```

---

## Questions or Issues?

Refer to:
1. **Troubleshooting section** above
2. **Theory section** for concept questions
3. **Commands cheatsheet** for command syntax
4. **Lab setup sections** for lab-specific issues

---

**Ready to start?** Begin with [01-theory.md](01-theory.md) or jump to [03-hands-on-labs.md](03-hands-on-labs.md) if you prefer learning by doing!

---

**Module Version**: 1.0.0  
**Status**: Complete  
**Last Updated**: January 2024
