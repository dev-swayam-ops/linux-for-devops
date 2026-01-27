# Process Management: Solutions

## Exercise 1: List and Identify Processes

**Solution:**

```bash
# List all processes
ps aux

# Count total processes
ps aux | wc -l
# Output: 127 (example)

# Highest CPU usage
ps aux --sort=-%cpu | head -5
# Output: first line after header

# Highest memory usage
ps aux --sort=-%mem | head -5
# Output: processes sorted by memory

# Find init process
ps aux | grep " 1 " | grep -v grep
# Output: PID 1 = init/systemd
```

**Explanation:** `ps aux` shows all processes. `--sort` orders by column. CPU% and MEM% show usage.

---

## Exercise 2: Find Specific Processes

**Solution:**

```bash
# Find user's processes
ps aux | grep "^username"

# Find Python processes
pgrep -a python
# or
ps aux | grep python | grep -v grep

# Get SSH daemon PID
pgrep -f sshd
# or
pidof sshd
# Output: 1234

# Find systemd processes
ps aux | grep systemd | grep -v grep

# Show full command line
ps -o pid,cmd -p 1234
# Output:
# PID   CMD
# 1234  /usr/sbin/sshd -D
```

**Explanation:** `pgrep` finds by name. `pidof` returns just PID. `-a` shows full command.

---

## Exercise 3: Process Tree Analysis

**Solution:**

```bash
# Complete process tree
pstree -p
# Output:
# systemd(1)
# ├─systemd-journal(567)
# ├─sshd(889)
# │ └─sshd(1234)
# └─nginx(1500)
#   └─nginx(1501)

# Parent of specific PID
ps -o pid,ppid,cmd -p 1234
# Shows parent process ID

# All children of PID
pstree -p 889
# Shows all descendants

# Trace parent chain
while [ -n "$PID" ]; do
  ps -o ppid= -p $PID
  PID=$(ps -o ppid= -p $PID)
done
```

**Explanation:** `pstree -p` shows relationships. PPID = parent PID.

---

## Exercise 4: Background and Foreground Jobs

**Solution:**

```bash
# Start long process
sleep 300
# (now running in foreground)

# Press Ctrl+Z to suspend
# Output: [1]+ Stopped sleep 300

# Resume in background
bg %1
# Output: [1]+ sleep 300 &

# List jobs
jobs
# Output:
# [1]+ Running sleep 300 &

# Bring to foreground
fg %1
# Output: sleep 300

# (Press Ctrl+C to stop)
# Output: [1]+ Terminated
```

**Explanation:** `bg` = background, `fg` = foreground, `jobs` = list, `%1` = job 1.

---

## Exercise 5: Process Priority Management

**Solution:**

```bash
# Show current nice values
ps -o pid,nice,cmd

# Start with nice value 10
nice -n 10 ./script.sh &
# Gets lower priority

# Start with nice value -5 (higher priority)
nice -n -5 ./high-priority.sh &
# Requires privilege

# Change existing process
renice -n 5 -p 1234
# Output: 1234 (old priority) -> 1234 (new priority) 5

# Show effect
ps -o pid,nice,cmd | head -10
# Nice values range: -20 (highest) to 19 (lowest)
```

**Explanation:** Nice = scheduling priority. Lower nice = higher priority. `-20` to `19` range.

---

## Exercise 6: Send Signals to Processes

**Solution:**

```bash
# Start test process
sleep 1000 &
# Output: [1] 5678

# Send SIGTERM (graceful)
kill -15 5678
# or
kill 5678

# Check if terminated
ps -p 5678
# Output: (empty = terminated)

# Start another
sleep 1000 &
# Output: [1] 5679

# Send SIGKILL (force)
kill -9 5679

# Kill all matching name
killall sleep
# Kills all sleep processes

# Different signals:
# -0 = check if exists
# -1 = SIGHUP (reload)
# -15 = SIGTERM (graceful)
# -9 = SIGKILL (force)
```

**Explanation:** SIGTERM allows cleanup. SIGKILL forces. Always try SIGTERM first.

---

## Exercise 7: Process Resource Monitoring

**Solution:**

```bash
# Top 5 by CPU
ps aux --sort=-%cpu | head -6

# Top 5 by memory
ps aux --sort=-%mem | head -6

# Continuous monitoring
top -b -n 3 -d 1 | grep "^"
# 3 iterations, 1 second delay

# Specific columns
ps -o pid,%cpu,%mem,cmd --sort=-%cpu | head

# Watch for changes
watch -n 2 'ps aux --sort=-%cpu | head -10'

# Log to file
ps aux >> process_log.txt
```

**Explanation:** Sort by column shows resource hogs. `-b -n -d` options control top output.

---

## Exercise 8: System Load Analysis

**Solution:**

```bash
# Check current load
uptime
# Output: load average: 0.45, 0.52, 0.48

# More detailed load info
cat /proc/loadavg
# Output: 0.45 0.52 0.48 1/127 1234

# Start CPU-intensive task
yes > /dev/null &
# PID: 5678

# Monitor load increase
watch -n 1 uptime

# Start 4 CPU tasks (on 4-core system)
for i in {1..4}; do
  yes > /dev/null &
done

# Load will increase significantly

# Stop them
killall yes

# Load average explained:
# 1-minute load: 0.45
# 5-minute load: 0.52
# 15-minute load: 0.48
# 1/127 = 1 runnable / 127 total processes
```

**Explanation:** Load = avg tasks waiting for CPU. 1.0 on single-core = 100% busy.

---

## Exercise 9: Process Limits and Constraints

**Solution:**

```bash
# View all limits
ulimit -a
# Output:
# core file size (blocks, -c) 0
# data seg size (kbytes, -d) unlimited
# scheduling priority (-e) 0
# file size (blocks, -f) unlimited
# pending signals (-i) 31623
# max locked memory (kbytes, -l) 65536
# max memory size (kbytes, -m) unlimited
# open files (-n) 1024
# pipe size (512 bytes, -p) 8
# POSIX message queues (bytes, -q) 819200

# Check max open files
ulimit -n
# Output: 1024

# Check max processes
ulimit -u
# Output: 31623

# Set limit (temporary)
ulimit -n 2048

# View kernel limits
cat /proc/sys/kernel/pid_max
# Max process ID value
```

**Explanation:** Limits prevent resource exhaustion. `-n` = file descriptors, `-u` = processes.

---

## Exercise 10: Advanced Process Debugging

**Solution:**

```bash
# Start multiple related processes
nginx &
apache2 &
systemd-resolved &

# Show process tree
pstree -p | grep -E "nginx|apache"

# Get file descriptors for process
lsof -p 1234 | wc -l
# Shows how many files/sockets open

# Monitor open ports
ss -tlnp | grep nginx

# Complete process report
cat > process_report.txt << 'EOF'
=== Process Report ===
Date: $(date)

Running Processes:
$(ps aux | wc -l) total processes

Top by CPU:
$(ps aux --sort=-%cpu | head -3)

Top by Memory:
$(ps aux --sort=-%mem | head -3)

System Load:
$(uptime)

Process Limits:
$(ulimit -a)
EOF

cat process_report.txt

# Cleanup
killall nginx apache2 2>/dev/null || true
```

**Explanation:** Comprehensive process analysis combines multiple tools for full picture.
