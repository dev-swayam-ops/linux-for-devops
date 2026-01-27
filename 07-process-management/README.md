# Module 7: Process Management

## What You'll Learn

- Understand Linux process lifecycle and states
- Monitor running processes in detail
- Manage process priority and CPU usage
- Send signals to processes (SIGTERM, SIGKILL)
- Manage foreground and background processes
- Monitor system load and performance
- Use advanced process debugging tools

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Basic understanding of shell and commands
- Familiar with top from Module 5
- Understanding of signals and process control

## Key Concepts

| Concept | Description |
|---------|-------------|
| **PID** | Process ID - unique identifier for each process |
| **PPID** | Parent Process ID - process that started this one |
| **Process State** | Running, sleeping, stopped, zombie, etc. |
| **Signal** | Message sent to process (SIGTERM, SIGKILL, SIGHUP) |
| **Priority/Nice** | CPU scheduling priority (-20 to 19) |
| **Background Job** | Process running without terminal control |
| **Foreground Job** | Process controlling terminal input/output |
| **Zombie** | Process completed but parent hasn't reaped it |

## Hands-on Lab: Monitor and Control Processes

### Lab Objective
View process details, manage priorities, and send signals.

### Commands

```bash
# List all processes
ps aux

# Show process tree
pstree -p

# Show detailed process info
ps -ef

# Filter by name
ps aux | grep python

# Show resource usage
ps aux --sort=-%cpu | head -5

# Get process state details
ps -o pid,status,command

# Check PID of specific process
pgrep nginx
# or
pidof apache2

# Show process with full command line
ps -ef | grep servicename

# Get parent of process
ps -o pid,ppid,cmd | grep processname

# Monitor real-time with top
top -p PID

# Send SIGTERM (graceful stop)
kill 1234

# Send SIGKILL (force kill)
kill -9 1234

# Kill by name
killall -TERM nginx

# Get process priority
ps -o pid,nice,cmd

# Change priority (lower = higher priority)
nice -n 10 ./script.sh

# Change existing process priority
renice -n 5 -p 1234

# Show process limits
ulimit -a

# Monitor load average
uptime
# or
cat /proc/loadavg

# Watch command continuously
watch -n 1 'ps aux --sort=-%cpu | head -10'
```

### Expected Output

```
# ps aux output:
USER    PID %CPU %MEM    VSZ   RSS TTY STAT START   TIME COMMAND
root      1  0.0  0.1  19376  2976 ?   Ss   10:00   0:01 /sbin/init
user   1234  2.3  0.5 1234567 8192 ?   S    10:30   0:15 /usr/bin/python3

# pstree output:
systemd─┬─systemd-journald
        ├─sshd─┬─sshd───bash───ps
        └─nginx─┬─nginx
                └─nginx

# uptime output:
10:45:00 up 5 days, 3:23, 2 users, load average: 0.45, 0.52, 0.48
```

## Validation

Confirm successful completion:

- [ ] Listed all processes with `ps aux`
- [ ] Found specific process using `pgrep` or `pidof`
- [ ] Changed process priority with `nice` or `renice`
- [ ] Sent signals to processes (SIGTERM, SIGKILL)
- [ ] Monitored process tree with `pstree`
- [ ] Checked system load with `uptime`

## Cleanup

```bash
# Kill any test processes
killall test-script 2>/dev/null || true

# Check all processes terminated
ps aux | wc -l
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Killing wrong process | Always verify PID with `ps aux` first |
| SIGKILL doesn't work | SIGKILL always works; process can't ignore it |
| Process still running after kill | Try `kill -9` (SIGKILL) |
| Permission denied | Need privilege for others' processes |
| Can't find process | Use `pgrep -a processname` for full command |

## Troubleshooting

**Q: How do I see all processes and their parents?**
A: Use `pstree -p` to show process tree with PIDs.

**Q: Why is a process using 100% CPU?**
A: Use `top` or `ps aux --sort=-%cpu` to find it, then investigate.

**Q: How do I send a signal to a process?**
A: Use `kill -signal PID`. SIGTERM (15) = graceful, SIGKILL (9) = force.

**Q: What's the difference between SIGTERM and SIGKILL?**
A: SIGTERM allows cleanup. SIGKILL forces immediate termination.

**Q: How do I run a process with lower priority?**
A: Use `nice -n 10 command` (higher nice value = lower priority).

## Next Steps

1. Complete all exercises in `exercises.md`
2. Practice process management daily
3. Learn about process groups and sessions
4. Explore strace for debugging processes
5. Master systemd process management integration
