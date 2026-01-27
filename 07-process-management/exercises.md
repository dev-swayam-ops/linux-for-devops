# Process Management: Exercises

Complete these exercises to master process handling.

## Exercise 1: List and Identify Processes

**Tasks:**
1. List all running processes
2. Count total number of processes
3. Find process with highest CPU usage
4. Find process with highest memory usage
5. Identify init process (PID 1)

**Hint:** Use `ps aux`, `wc -l`, `--sort=-%cpu`, `--sort=-%mem`.

---

## Exercise 2: Find Specific Processes

**Tasks:**
1. Find all processes for a specific user
2. Find all Python processes
3. Get PID of SSH daemon
4. List all processes containing "systemd"
5. Show full command line of processes

**Hint:** Use `pgrep`, `pidof`, `ps aux | grep`, `ps -o`.

---

## Exercise 3: Process Tree Analysis

**Tasks:**
1. Show complete process tree
2. Identify parent and child relationships
3. Show init system as root
4. Find all children of a specific process
5. Trace ancestry of specific PID

**Hint:** Use `pstree -p`, `ps -o pid,ppid,cmd`.

---

## Exercise 4: Background and Foreground Jobs

**Tasks:**
1. Start a long-running process
2. Suspend it (Ctrl+Z)
3. Resume in background with `bg`
4. List background jobs with `jobs`
5. Bring job back to foreground

**Example:** `sleep 300` then suspend and manage.

---

## Exercise 5: Process Priority Management

**Tasks:**
1. Show process priority values
2. Start process with custom nice value
3. Change priority of running process
4. Compare nice values (0, 10, -5)
5. Observe effect on system load

**Hint:** Use `nice -n value`, `renice -n value -p PID`.

---

## Exercise 6: Send Signals to Processes

**Tasks:**
1. Start a test process
2. Send SIGTERM (graceful stop)
3. Verify process terminated
4. Start another process
5. Send SIGKILL if needed
6. Compare behavior of signals

**Hint:** Use `kill -15 PID`, `kill -9 PID`, `killall`.

---

## Exercise 7: Process Resource Monitoring

**Tasks:**
1. Show CPU usage per process
2. Show memory usage per process
3. Identify resource hogs
4. Monitor over time (3 intervals)
5. Document trends

**Hint:** Use `top -b`, `ps aux --sort`, watch command.

---

## Exercise 8: System Load Analysis

**Tasks:**
1. Check current system load
2. Understand load average (1, 5, 15 min)
3. Start multiple CPU-intensive tasks
4. Monitor load increase
5. Stop tasks and observe decrease

**Hint:** Use `uptime`, `cat /proc/loadavg`, `yes > /dev/null &`.

---

## Exercise 9: Process Limits and Constraints

**Tasks:**
1. View all process limits
2. Check max open files
3. Check max processes per user
4. Check virtual memory limit
5. Understand why limits matter

**Hint:** Use `ulimit -a`, `cat /proc/sys/kernel/`.

---

## Exercise 10: Advanced Process Debugging

Create a scenario to monitor and debug processes.

**Tasks:**
1. Start multiple related processes
2. Show parent-child relationships
3. Get file descriptor count
4. Monitor open ports
5. Generate process report

**Hint:** Use `lsof`, `ss`, `pstree -p`, `ps -o`.
