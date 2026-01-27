# Module 2: Linux Advanced Commands

## What You'll Learn

- Master text processing and pattern matching with advanced grep and sed
- Search and find files efficiently across the filesystem
- Manage processes and system resources
- Handle input/output redirection and piping
- Work with archives and compression
- Schedule and automate tasks with cron

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Comfortable with basic file operations and navigation
- Understanding of file permissions and ownership
- Access to a Linux terminal with sudo privileges

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Regular Expressions** | Patterns for matching text: `.`, `*`, `+`, `^`, `$`, `[abc]`, `[a-z]` |
| **Process Management** | Running, stopping, and monitoring background/foreground processes |
| **Pipes and Redirection** | Connecting commands: `\|`, `>`, `>>`, `<`, `2>`, `&>` |
| **Stream Processing** | Working with text using sed, awk, and grep line by line |
| **Compression** | Reducing file size: gzip, tar, bzip2, zip |
| **Task Scheduling** | Automating tasks using cron jobs with crontab |

## Hands-on Lab: Process Management and Text Processing

### Lab Objective
Monitor system processes, manage background jobs, and process log files.

### Commands

```bash
# Display running processes
ps aux

# Filter processes by name
ps aux | grep apache

# Show process hierarchy
pstree

# Display real-time process information
top
# Press 'q' to exit

# Start a background job
sleep 100 &

# List background jobs
jobs

# Run command and send to background
find / -name "*.log" > log_files.txt 2>&1 &

# Bring job to foreground
fg %1

# Send job to background (from foreground)
# Press Ctrl+Z, then type: bg

# Kill process by PID
kill 1234

# Kill process by name
killall sleep

# Monitor process using watch
watch -n 2 'ps aux | grep python'

# Check system load and memory
uptime
free -h

# Display CPU information
nproc
lscpu

# Show file descriptors and limits
ulimit -n
```

### Expected Output

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  19376  2976 ?        Ss   10:00   0:01 /sbin/init

[1]-  Running  sleep 100 &

total        used        free      shared  buff/cache   available
Mem:           15Gi       3.2Gi      8.5Gi      256Mi       3.2Gi      11Gi
```

## Validation

- [ ] View running processes with `ps aux`
- [ ] Started a background job and listed it with `jobs`
- [ ] Killed a process using `kill` or `killall`
- [ ] Checked memory and CPU information
- [ ] Used pipes to filter process output

## Cleanup

```bash
# Kill any remaining background jobs
killall sleep 2>/dev/null || true

# Remove temporary log files
rm -f log_files.txt
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| `grep: command not found` | grep is usually included; check PATH or try full path |
| Can't find a process | Use `ps aux` to see all processes or `pgrep pattern` |
| Job still running after kill | Use `kill -9 PID` (force kill) instead of `kill PID` |
| Pattern not matching | Test regex with `grep -E` for extended regex |
| Pipe syntax error | Always use `\|` not `and`, and separate commands correctly |

## Troubleshooting

**Q: How do I find a process by name?**
A: Use `ps aux | grep processname` or `pgrep processname`.

**Q: What's the difference between kill and killall?**
A: `kill` terminates by PID; `killall` terminates by process name.

**Q: How can I see only my processes?**
A: Use `ps` (without options) or `ps aux | grep $USER`.

**Q: How do I save command output to a file and see it at the same time?**
A: Use `tee`: `command | tee output.txt`.

**Q: Can I schedule a script to run automatically?**
A: Yes, use `crontab -e` to add scheduled tasks.

## Next Steps

1. Practice searching and filtering with grep and find
2. Complete exercises on pipes and redirection
3. Learn to schedule automated tasks with cron
4. Experiment with awk for advanced text processing
5. Master log file analysis techniques
