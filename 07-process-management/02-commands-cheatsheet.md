# Module 07: Process Management - Commands Cheatsheet

Quick reference for 20+ essential process management commands with real-world examples.

---

## Part A: Listing and Viewing Processes

### ps (Process Status)

Most versatile process listing command.

```bash
# List your processes
ps

# List all processes
ps aux

# Process tree (hierarchy)
ps auxf
ps aux --forest

# Output:
# USER  PID  %CPU %MEM  VSZ   RSS  STAT START   TIME COMMAND
# root  1    0.0  0.2   18192 2956 Ss   01:23   0:00 /sbin/init
# root  234  0.0  0.1   5232  1044 S    01:24   0:01 bash

# Custom columns
ps -o pid,ppid,user,rss,cmd

# Watch process
ps aux | grep firefox

# List single process
ps -p 1234

# All processes except terminal (daemons)
ps -aux | grep -v pts
```

### pgrep (Process Grep)

Find processes by name.

```bash
# Find PID by process name
pgrep firefox         # Returns: 1234

# Find all PIDs matching pattern
pgrep -a ssh          # Shows: 234 /usr/sbin/sshd

# Count matching processes
pgrep -c nginx        # Returns: 3

# Find with full command line
pgrep -f "python.*server"

# Find processes owned by user
pgrep -u username nginx

# Get oldest process matching
pgrep -o firefox

# Get newest process matching
pgrep -n firefox
```

### pidof (Process ID Of)

Simpler alternative to pgrep for process name lookup.

```bash
# Get PID of process
pidof sshd            # Returns: 234 567 789 (all sshd processes)

# Get single PID
pidof -s sshd         # Returns: 234 (just first one)

# Equivalent to ps + grep
pidof firefox | awk '{print $1}'
```

### top (Table of Processes)

Real-time process monitoring.

```bash
# Interactive monitoring
top

# Output shows:
# ├─ System summary (load, CPU, memory)
# ├─ Per-process details
# └─ Top CPU/memory consumers

# Run in batch mode (non-interactive)
top -b -n 1           # Single snapshot

# Specify process
top -p 1234

# Sort by CPU (default)
top -o %CPU

# Sort by memory
top -o %MEM

# Run for 5 seconds, update every 1 second
top -b -n 5 -d 1

# Output top 3 processes (combined with head)
top -b -n 1 | head -20
```

### htop (Interactive Top)

Enhanced version of top (usually needs installation).

```bash
# Install if needed
sudo apt install htop

# Run htop
htop

# Advantages over top:
# - Mouse support
# - Colored output
# - Easier filtering
# - Better process tree

# Show only specific user
htop -u username

# Show tree view (default shows by CPU)
# In htop menu: press 't' for tree

# Start sorted by memory
htop -o PERCENT_MEM
```

---

## Part B: Monitoring Process Activity

### watch (Repeat Command)

Run command repeatedly, updating display.

```bash
# Monitor ps output every 2 seconds
watch -n 2 'ps aux | grep firefox'

# Monitor top 5 CPU processes
watch -n 1 'ps aux --sort=-%cpu | head -6'

# Monitor memory usage
watch -n 2 'free -h && ps aux --sort=-%mem | head -6'

# Highlight differences between updates
watch -d 'ps aux | grep httpd'
```

### Continuous Process Monitoring

```bash
# Watch directory for changes
watch 'ls -la /proc/[PID]'

# Monitor open files for process
watch 'lsof -p [PID]'

# Monitor process resource limits
watch 'cat /proc/[PID]/limits'
```

---

## Part C: Process Information Details

### Finding Process Information

```bash
# Get environment variables of running process
cat /proc/[PID]/environ | tr '\0' '\n'

# Get process memory details
cat /proc/[PID]/status | grep Vm

# Get working directory
ls -la /proc/[PID]/cwd
readlink /proc/[PID]/cwd

# Get command line (how process was started)
cat /proc/[PID]/cmdline | tr '\0' ' ' && echo

# Get process limits
cat /proc/[PID]/limits

# All open file descriptors
ls -la /proc/[PID]/fd/

# Check which files process has open
lsof -p [PID]
```

### Using ps with Multiple Columns

```bash
# Show everything important
ps -e -o pid,ppid,user,rss,vsize,cmd

# With nice value and priority
ps -e -o pid,user,pri,nice,cmd

# With state information
ps -e -o pid,state,cmd

# Memory info with percentage
ps aux --sort=-%mem | head -5

# CPU info with percentage
ps aux --sort=-%cpu | head -5

# Show process start time
ps -e -o pid,user,lstart,cmd | head -5
```

---

## Part D: Process Control

### kill (Send Signal to Process)

Terminate or signal a process.

```bash
# Graceful termination (SIGTERM)
kill 1234
kill -TERM 1234
kill -15 1234

# Force kill (SIGKILL) - use as last resort
kill -KILL 1234
kill -9 1234

# Send other signals
kill -HUP 1234         # SIGHUP (reload config)
kill -USR1 1234        # SIGUSR1 (custom)
kill -USR2 1234        # SIGUSR2 (custom)

# Kill process and wait for cleanup
kill -TERM 1234; sleep 2; kill -KILL 1234

# List available signals
kill -l

# Kill multiple processes
kill 1234 5678 9012
```

### pkill (Kill by Pattern)

Kill processes by name or pattern.

```bash
# Kill all processes matching name
pkill firefox

# Kill with signal
pkill -TERM nginx
pkill -9 mysql

# Kill processes owned by user
pkill -u username nginx

# Kill processes matching full command
pkill -f "python.*server.py"

# Confirmation before killing
pkill -i firefox          # Case-insensitive

# Show what would be killed (don't kill)
pgrep -a nginx          # See what matches
```

### killall (Kill All by Name)

Kill all processes with specific name.

```bash
# Kill all firefox processes
killall firefox

# Kill with signal
killall -TERM nginx
killall -9 mysql

# Verbose (show what was killed)
killall -v apache2
```

---

## Part E: Process Priority

### nice (Set Priority)

Start process with specific priority.

```bash
# Lower priority (higher number = lower priority)
nice -n 10 long_task

# Higher priority (requires root)
sudo nice -n -10 important_task

# Highest priority
sudo nice -n -20 critical_task

# Lowest priority
nice -n 19 background_task

# Run command with default nice
nice firefox            # Runs with nice +10 by default
```

### renice (Change Priority)

Change priority of running process.

```bash
# Increase priority (requires root)
sudo renice -n -5 -p 1234    # Lower number = higher priority

# Decrease priority
renice -n 5 -p 1234

# Change all processes of user
renice -n 5 -u username

# Change all processes by name
pkill -f "python" | xargs renice -n 5

# Syntax: renice [PRIORITY] [-p PID | -u USER]
```

### Getting Process Priority

```bash
# Display NI column (nice value)
ps -o pid,user,ni,cmd

# Display PRI column (kernel priority)
ps -o pid,user,pri,cmd

# Show both
ps -e -o pid,ni,pri,cmd | head -10
```

---

## Part F: Job Control

### Managing Background/Foreground

```bash
# Run in background
command &

# List background jobs
jobs
jobs -l              # With PIDs

# Bring job to foreground
fg %1
fg %[command_name]

# Resume background job in background
bg %1

# Suspend current foreground job
# Press: Ctrl+Z

# Continue suspended process
# After Ctrl+Z, type: bg
```

### Job Control Examples

```bash
# Start process in background
$ long_task.sh &
[1] 1234

# Run another command
$ another_task

# Press Ctrl+Z to suspend
^Z
[2]+ Stopped     another_task

# Check jobs
$ jobs
[1]  Running     long_task.sh &
[2]+ Stopped     another_task

# Resume job 2 in background
$ bg %2
[2]+ another_task &

# Bring to foreground
$ fg %1
```

---

## Part G: Process Analysis

### top CPU Consumers

```bash
# Top 10 by CPU
ps aux --sort=-%cpu | head -11

# Format: user, pid, %cpu, %mem, rss, command
ps aux --sort=-%cpu -o user,pid,%cpu,%mem,rss,cmd | head -11

# Real-time top 10
watch -n 1 'ps aux --sort=-%cpu | head -11'

# Find top process
ps aux | sort -nrk 3,3 | head -1
```

### Top Memory Consumers

```bash
# Top 10 by memory
ps aux --sort=-%mem | head -11

# Format: user, pid, %mem, rss, vsize, command
ps aux --sort=-%mem -o user,pid,%mem,rss,vsize,cmd | head -11

# Real-time monitoring
watch -n 2 'ps aux --sort=-%mem | head -11'

# Memory in MB
ps aux --sort=-%mem | awk 'NR<=11 {printf "%s %s %.1f MB\n", $1, $2, $6/1024}'
```

### Finding Resource Hogs

```bash
# Process using most CPU right now
ps aux | sort -nrk 3,3 | head -2

# Process using most memory
ps aux | sort -nrk 4,4 | head -2

# Total memory by user
ps aux | awk '{arr[$1]+=$6} END {for (i in arr) printf "%s %s MB\n", i, int(arr[i]/1024)}'

# Monitor over time
while true; do
  clear
  echo "=== Top CPU ==="
  ps aux --sort=-%cpu | head -3
  echo ""
  echo "=== Top Memory ==="
  ps aux --sort=-%mem | head -3
  sleep 5
done
```

---

## Part H: Advanced Process Management

### Listing Process Tree

```bash
# Simple tree
pstree

# Tree with PIDs
pstree -p

# Tree showing specific process and children
pstree -p 1234

# Tree in BSD style
ps auxf
```

### Process System Calls

```bash
# See system calls made by process
strace -e trace=process command

# Full trace
strace command

# Trace specific syscalls
strace -e open,read,write command
```

### Process Limits

```bash
# View current user limits
ulimit -a

# Limit process resources at start
# Memory limit (virtual)
ulimit -v 512000; command

# File size limit
ulimit -f 1000000; command

# Per-process limits via systemd
systemd-run --property MemoryLimit=500M command
```

---

## Part I: Practical Patterns and Workflows

### Pattern 1: Monitor Specific Process

```bash
# Simple method
ps aux | grep nginx

# Better method (with details)
ps -o pid,ppid,user,rss,cmd -p $(pgrep -o nginx)

# Real-time monitoring
watch -n 1 'ps aux | grep nginx'

# With child processes
pstree -p $(pgrep -o nginx)
```

### Pattern 2: Kill Stuck Process Safely

```bash
# 1. Find it
ps aux | grep stuck_process
PID=$(pgrep stuck_process)

# 2. Try graceful termination
kill -TERM $PID

# 3. Wait a bit
sleep 2

# 4. Check if still running
ps -p $PID

# 5. Force kill if necessary
kill -KILL $PID

# 6. Verify gone
ps -p $PID || echo "Process terminated"
```

### Pattern 3: Find Resource-Heavy Process

```bash
# CPU heavy
ps aux --sort=-%cpu | head -3

# Memory heavy
ps aux --sort=-%mem | head -3

# Combined high use
ps aux | awk '$3+$4 > 20' | sort -nrk 3,3
```

### Pattern 4: Manage Background Jobs

```bash
# Start multiple background jobs
job1 &
job2 &
job3 &

# List them
jobs -l

# Bring specific one to foreground
fg %2

# Or manage with pid directly
kill %2              # Kill job 2
kill 1234            # Kill by PID
```

### Pattern 5: Find Child Processes

```bash
# Find all children of specific process
pstree -p 1234

# Kill parent and all children
kill -9 -1234        # Negative PID kills process group

# Get all child PIDs
ps --ppid 1234 -o pid=

# Kill all children
kill $(ps --ppid 1234 -o pid=)
```

### Pattern 6: Debug Process

```bash
# Full process info
ps -e -o pid,ppid,user,rss,vsize,pri,nice,cmd | grep process_name

# Process environment
strings /proc/1234/environ | grep -i var

# Working directory
readlink /proc/1234/cwd

# Open files
lsof -p 1234

# System calls in real time
strace -p 1234
```

---

## Part J: Quick Reference Table

| Task | Command | Example |
|------|---------|---------|
| List all processes | ps aux | ps aux \| head |
| Show process tree | pstree | pstree -p 1234 |
| Find by name | pgrep | pgrep firefox |
| Get PID | pgrep | pgrep -o nginx |
| Count processes | ps \| wc -l | ps aux \| wc -l |
| Top by CPU | sort -%cpu | ps aux --sort=-%cpu |
| Top by memory | sort -%mem | ps aux --sort=-%mem |
| Graceful kill | kill -TERM | kill -TERM 1234 |
| Force kill | kill -KILL | kill -KILL 1234 |
| Kill by name | pkill | pkill firefox |
| Suspend process | Ctrl+Z | (in terminal) |
| Background | & | command & |
| Foreground | fg | fg %1 |
| List jobs | jobs | jobs -l |
| Set priority | nice | nice -n 10 task |
| Change priority | renice | renice -n 5 -p 1234 |
| Monitor real-time | top | top -p 1234 |
| Watch command | watch | watch 'ps aux' |
| Process info | cat /proc | cat /proc/1234/status |

---

## Part K: Tips and Best Practices

### Best Practices

1. **Use SIGTERM first** - Always try kill -TERM before -KILL
   ```bash
   kill -TERM 1234; sleep 2; kill -KILL 1234
   ```

2. **Use pgrep over grep** - More reliable for process lookup
   ```bash
   pgrep nginx        # Better than: ps aux | grep nginx
   ```

3. **Watch process groups** - Don't accidentally kill important processes
   ```bash
   ps aux | grep pattern    # Check before kill!
   ```

4. **Monitor before acting** - Use top/htop to understand the situation
   ```bash
   top -p 1234        # See what it's doing before terminating
   ```

5. **Set resource limits** - Prevent runaway processes
   ```bash
   ulimit -v 512000; potentially_bad_command
   ```

### Common Mistakes

1. **Using -KILL first**
   ```bash
   # Wrong: kills without cleanup
   kill -9 1234
   
   # Right: graceful first
   kill -TERM 1234; sleep 2; kill -9 1234
   ```

2. **Killing by grep** - Can match other processes
   ```bash
   # Wrong: might kill wrong process
   kill $(ps aux | grep firefox)
   
   # Right: use pgrep
   kill $(pgrep firefox)
   ```

3. **Not checking what you'll kill**
   ```bash
   # Wrong: no verification
   pkill -f "python"
   
   # Right: verify first
   pgrep -a -f "python"    # See what matches
   pkill -f "python"       # Then kill
   ```

---

**Ready for hands-on practice?** Continue to [03-hands-on-labs.md](03-hands-on-labs.md)
