# Module 07: Process Management - Hands-On Labs

8 practical labs covering process exploration, monitoring, control, and troubleshooting.

**Total Lab Time**: 180 minutes (3 hours)

---

## Lab 1: Explore Running Processes

**Difficulty**: Beginner | **Time**: 20 minutes

### Goal
Understand how to list and identify processes using various methods.

### Setup

```bash
# No special setup needed - we'll use existing system processes
# Open a terminal on your Linux VM/machine
```

### Steps

1. **See all running processes**
   ```bash
   ps aux | head -10
   ```
   Expected output shows: USER, PID, %CPU, %MEM, VSZ, RSS, STAT, START, TIME, COMMAND

2. **List only your own processes**
   ```bash
   ps
   ```
   Compare to `ps aux` - notice the difference

3. **Show process tree (hierarchy)**
   ```bash
   pstree
   pstree -p             # With PIDs
   ```
   Observe how processes are arranged in parent-child relationships

4. **Find bash process(es)**
   ```bash
   pgrep bash
   pgrep -a bash         # Show full command line
   ```

5. **Get detailed information about your shell**
   ```bash
   # Get your current shell's PID
   echo $$
   
   # Show details
   ps -o pid,ppid,user,cmd -p $$
   ```

6. **Count total processes**
   ```bash
   ps aux | wc -l
   ps aux | tail -1      # Show last (gives process count)
   ```

7. **Find all ssh-related processes**
   ```bash
   pgrep -a sshd
   ps aux | grep sshd | grep -v grep
   ```

8. **Check process states**
   ```bash
   ps aux | awk '{print $8}' | sort | uniq -c
   ```
   Count processes in each state (S, R, D, etc.)

### Expected Output

```
Sample output from ps aux (partial):
USER   PID  %CPU %MEM   VSZ  RSS STAT START   TIME COMMAND
root   1    0.0  0.2  18192 2956 Ss   10:00   0:00 /sbin/init
root   234  0.0  0.1   5232  1044 S    10:01   0:01 sshd
user   567  0.1  0.5  95000 5120 S    10:05   0:02 bash
user   890  0.0  0.1  10000  500 R    10:15   0:00 ls

PID column: Process identifier
%CPU: Percentage of CPU used
STAT: Process state (S=sleeping, R=running)
```

### Verification Checklist

- [ ] Can list all processes with `ps aux`
- [ ] Can show process tree with `pstree`
- [ ] Can find specific process with `pgrep`
- [ ] Can get your own shell's PID with `$$`
- [ ] Can count total processes on system
- [ ] Can see process states in STAT column

### Cleanup

```bash
# No cleanup needed - no processes were created
# Just close terminal if you opened one
```

---

## Lab 2: Monitor Process Resources

**Difficulty**: Beginner | **Time**: 25 minutes

### Goal
Learn to monitor CPU and memory usage of processes in real-time.

### Setup

```bash
# Start a background process that uses resources
# This will be our test process
(while true; do echo "Test"; sleep 0.1; done) &
TEST_PID=$!
echo "Test process PID: $TEST_PID"

# Note: Keep this terminal open - you'll need the PID
```

### Steps

1. **View process in ps output**
   ```bash
   ps aux | grep "echo Test"
   
   # Note the PID, %CPU, %MEM, VSZ, RSS columns
   ```

2. **Monitor with top**
   ```bash
   # Interactive monitoring
   top
   
   # In top, press:
   # - 'P' to sort by CPU
   # - 'M' to sort by memory
   # - 'q' to quit
   ```

3. **Monitor specific process with top**
   ```bash
   top -p $TEST_PID
   # Watch for a few seconds, then press q
   ```

4. **Use watch to monitor**
   ```bash
   watch -n 1 'ps aux | grep "echo Test"'
   
   # Updates every 1 second
   # Press Ctrl+C to stop
   ```

5. **Get detailed memory info**
   ```bash
   cat /proc/$TEST_PID/status | grep Vm
   
   # Shows:
   # VmPeak: Peak virtual memory
   # VmSize: Current virtual memory
   # VmRSS: Resident set size (actual RAM)
   ```

6. **Check process limits**
   ```bash
   cat /proc/$TEST_PID/limits
   
   # Shows max open files, memory, stack size, etc.
   ```

7. **Monitor multiple processes**
   ```bash
   ps aux --sort=-%cpu | head -5
   ps aux --sort=-%mem | head -5
   ```

8. **Create second resource-using process**
   ```bash
   (while true; do 
     x=$(seq 1 100000 | paste -sd+ | bc)
   done) &
   
   echo "CPU-intensive process: $!"
   
   # Now run:
   top
   # Notice which process takes more CPU
   ```

### Expected Output

```
ps aux output shows:
USER  PID  %CPU %MEM  VSZ   RSS  STAT
user  123  8.5  0.1  10000 400  R

top shows similar info in interactive format with:
- Real-time updates
- Sorted by CPU or memory
- Process list with resource usage
```

### Verification Checklist

- [ ] Can view process with ps aux
- [ ] Can sort processes by CPU
- [ ] Can sort processes by memory
- [ ] Can monitor specific PID with top
- [ ] Can see VmRSS (actual memory usage)
- [ ] Can monitor with watch command
- [ ] Can identify high-CPU vs high-memory processes

### Cleanup

```bash
# Kill the test processes
kill $TEST_PID

# Check they're gone
ps aux | grep "echo Test"
```

---

## Lab 3: Job Control - Foreground and Background

**Difficulty**: Beginner | **Time**: 20 minutes

### Goal
Master bash job control - running processes in foreground and background.

### Setup

```bash
# No setup needed - all jobs will use built-in commands
```

### Steps

1. **Run process in foreground (blocks terminal)**
   ```bash
   # Sleep for 10 seconds (terminal blocked)
   sleep 10
   # Terminal prompt returns after 10 seconds
   ```

2. **Run process in background (terminal available)**
   ```bash
   # Start in background with &
   sleep 20 &
   
   # Terminal prompt returns immediately
   # Output shows: [1] 1234 (job number and PID)
   ```

3. **List background jobs**
   ```bash
   jobs
   
   # Output shows:
   # [1]   Running     sleep 20 &
   ```

4. **Start another background job**
   ```bash
   (for i in {1..5}; do echo "Job 2 running"; sleep 2; done) &
   
   # List jobs
   jobs
   ```

5. **Suspend a foreground process with Ctrl+Z**
   ```bash
   # Start foreground process
   sleep 30
   
   # While running, press: Ctrl+Z
   # Output shows: [2]+ Stopped    sleep 30
   ```

6. **Resume suspended job in background**
   ```bash
   # After Ctrl+Z, type:
   bg %2
   
   # Job 2 now runs in background
   jobs
   ```

7. **Bring background job to foreground**
   ```bash
   # List jobs first
   jobs
   
   # Bring most recent to foreground
   fg
   
   # Or specific job
   fg %1        # Job 1
   fg %2        # Job 2
   ```

8. **Create multiple concurrent jobs**
   ```bash
   # Start several background jobs
   for i in {1..3}; do sleep 30 & done
   
   # See them all
   jobs -l      # -l shows PID too
   
   # Kill specific job
   kill %1      # Kill job 1
   
   # Check result
   jobs
   ```

### Expected Output

```
$ sleep 20 &
[1] 1234

$ jobs
[1]   Running     sleep 20 &

$ sleep 30
^Z
[2]+ Stopped    sleep 30

$ bg %2
[2]+ sleep 30 &

$ jobs
[1]   Running     sleep 20 &
[2]-  Running     sleep 30 &
```

### Verification Checklist

- [ ] Can run process in background with &
- [ ] Can list jobs with `jobs`
- [ ] Can suspend foreground with Ctrl+Z
- [ ] Can resume with `bg`
- [ ] Can bring to foreground with `fg`
- [ ] Can kill jobs by number with `kill %1`
- [ ] Can have multiple concurrent jobs

### Cleanup

```bash
# Kill all remaining jobs
killall sleep

# Verify
jobs
```

---

## Lab 4: Process Signals and Termination

**Difficulty**: Intermediate | **Time**: 25 minutes

### Goal
Understand how to send signals to processes and the difference between graceful and forced termination.

### Setup

```bash
# Create a test script that handles signals
cat > /tmp/signal_test.sh << 'EOF'
#!/bin/bash

cleanup() {
  echo "Caught signal, cleaning up..."
  rm -f /tmp/test_signal_$$
  exit 0
}

trap cleanup SIGTERM

echo "Process PID: $$"
echo "Waiting for signals..."

while true; do
  echo "Still running..."
  sleep 1
done
EOF

chmod +x /tmp/signal_test.sh
```

### Steps

1. **Start test process in background**
   ```bash
   /tmp/signal_test.sh &
   TEST_PID=$!
   echo "Test process PID: $TEST_PID"
   ```

2. **Verify process is running**
   ```bash
   ps aux | grep signal_test
   ```

3. **Send SIGTERM (graceful termination)**
   ```bash
   kill -TERM $TEST_PID
   
   # You should see: "Caught signal, cleaning up..."
   # Process exits gracefully
   ```

4. **Start another test process**
   ```bash
   /tmp/signal_test.sh &
   TEST_PID=$!
   ```

5. **Send SIGKILL (force termination)**
   ```bash
   kill -KILL $TEST_PID
   
   # Process terminates immediately without cleanup message
   ```

6. **Compare different termination signals**
   ```bash
   # Test SIGHUP (hangup)
   /tmp/signal_test.sh &
   PID1=$!
   kill -HUP $PID1
   
   # Test SIGINT (Ctrl+C)
   /tmp/signal_test.sh &
   PID2=$!
   kill -INT $PID2
   ```

7. **List all available signals**
   ```bash
   kill -l
   
   # Shows numeric and alphabetic names:
   # 1) SIGHUP   2) SIGINT   3) SIGQUIT ... 9) SIGKILL 15) SIGTERM
   ```

8. **Test signal timing**
   ```bash
   # Start process
   /tmp/signal_test.sh &
   PID=$!
   
   # Send SIGTERM, then after delay, SIGKILL
   kill -TERM $PID
   sleep 2
   ps -p $PID && kill -KILL $PID   # Only kill if still running
   
   ps -p $PID || echo "Process terminated"
   ```

### Expected Output

```
$ /tmp/signal_test.sh &
[1] 1234

$ kill -TERM 1234
Caught signal, cleaning up...
[1]  Terminated    /tmp/signal_test.sh

$ /tmp/signal_test.sh &
[1] 5678

$ kill -KILL 5678
[1]+ Killed        /tmp/signal_test.sh
```

### Verification Checklist

- [ ] Can send SIGTERM with `kill -TERM`
- [ ] Can send SIGKILL with `kill -KILL`
- [ ] Can send SIGINT with `kill -INT`
- [ ] Can list signals with `kill -l`
- [ ] Understand SIGTERM allows cleanup (trap handler runs)
- [ ] Understand SIGKILL cannot be caught (immediate termination)
- [ ] Can distinguish signal behaviors

### Cleanup

```bash
# Kill any remaining test processes
pkill -f signal_test

# Remove test script
rm /tmp/signal_test.sh

# Check
ps aux | grep signal_test
```

---

## Lab 5: Process Priority with nice and renice

**Difficulty**: Intermediate | **Time**: 20 minutes

### Goal
Control process CPU priority using nice values.

### Setup

```bash
# Create CPU-intensive test processes
cat > /tmp/cpu_test.sh << 'EOF'
#!/bin/bash
echo "CPU test PID: $$"
while true; do
  x=$(seq 1 100000 | paste -sd+ | bc) > /dev/null
done
EOF

chmod +x /tmp/cpu_test.sh
```

### Steps

1. **Start process with default priority**
   ```bash
   /tmp/cpu_test.sh &
   PID1=$!
   
   sleep 1
   ps -o pid,ni,cmd | grep cpu_test | head -2
   # Should show NI (nice value) of 0
   ```

2. **Start process with lower priority (higher nice value)**
   ```bash
   nice -n 10 /tmp/cpu_test.sh &
   PID2=$!
   
   sleep 1
   ps -o pid,ni,cmd | grep cpu_test | head -3
   # Shows: PID1 with NI=0, PID2 with NI=10
   ```

3. **Check CPU usage with top**
   ```bash
   top -p $PID1,$PID2
   
   # Notice PID1 (nice 0) gets more CPU than PID2 (nice 10)
   # Press q to exit
   ```

4. **Change priority of running process**
   ```bash
   # Increase priority (lower nice value)
   sudo renice -n 5 -p $PID1
   
   ps -o pid,ni,cmd | grep cpu_test
   # PID1 now shows NI=5
   ```

5. **Decrease priority further**
   ```bash
   sudo renice -n -10 -p $PID1   # Requires root for negative values
   
   ps -o pid,ni,cmd | grep cpu_test
   ```

6. **Monitor priority impact**
   ```bash
   # Watch CPU usage with priorities
   watch -n 1 'ps -o pid,ni,%cpu,cmd | grep cpu_test'
   
   # Let it run for 10 seconds, then Ctrl+C
   ```

7. **Test with multiple processes**
   ```bash
   # Start several with different priorities
   for i in {1..3}; do
     nice -n $((i*5)) /tmp/cpu_test.sh &
   done
   
   sleep 1
   
   # Check all
   ps -o pid,ni,%cpu | grep cpu_test
   ```

8. **Check nice value limits**
   ```bash
   # User can lower priority (increase NI):
   nice -n 19 /tmp/cpu_test.sh &    # Works
   
   # User cannot raise priority (decrease NI below 0):
   nice -n -5 /tmp/cpu_test.sh &    # Fails - "Permission denied"
   
   # Need sudo:
   sudo nice -n -10 /tmp/cpu_test.sh &    # Works
   ```

### Expected Output

```
$ ps -o pid,ni,cmd | grep cpu_test
  PID  NI COMMAND
 1234   0 /tmp/cpu_test.sh
 5678  10 /tmp/cpu_test.sh

$ sudo renice -n 5 -p 1234
1234 (process ID): old priority 0, new priority 5

$ ps -o pid,ni,cmd | grep cpu_test
  PID  NI COMMAND
 1234   5 /tmp/cpu_test.sh
 5678  10 /tmp/cpu_test.sh
```

### Verification Checklist

- [ ] Can start process with `nice -n` flag
- [ ] Can see nice value (NI) in ps output
- [ ] Can change priority with `renice`
- [ ] Can observe CPU allocation reflects priority
- [ ] Understand lower nice = higher priority = more CPU
- [ ] Understand requires sudo for negative nice values
- [ ] Can compare CPU usage for different priorities

### Cleanup

```bash
# Kill all test processes
pkill -f cpu_test

# Remove test script
rm /tmp/cpu_test.sh

# Verify all gone
ps aux | grep cpu_test
```

---

## Lab 6: Finding and Handling Zombie Processes

**Difficulty**: Intermediate | **Time**: 25 minutes

### Goal
Understand zombie processes and learn to identify and clean them up.

### Setup

```bash
# Create script that creates zombie process
cat > /tmp/create_zombie.sh << 'EOF'
#!/bin/bash

# Function to create zombie
create_zombie() {
  bash -c 'sleep 2 & wait'
}

# Start zombie-creating process in background
while true; do
  create_zombie &
  sleep 1
done
EOF

chmod +x /tmp/create_zombie.sh
```

### Steps

1. **Start zombie creation process**
   ```bash
   /tmp/create_zombie.sh &
   PARENT_PID=$!
   echo "Parent PID: $PARENT_PID"
   ```

2. **Look for zombie processes**
   ```bash
   ps aux | grep -E "\[.*\]|defunct"
   
   # Look for entries with STAT column showing 'Z'
   ```

3. **Get detailed zombie information**
   ```bash
   ps aux | awk '$8 ~ /Z/ {print $0}'
   
   # Shows all zombies
   ```

4. **Get zombie PID and PPID**
   ```bash
   ps -o pid,ppid,stat,cmd -e | grep -E "Z.*defunct"
   
   # Note the PPID - should be the parent we started
   ```

5. **Count zombie processes**
   ```bash
   ps aux | awk '$8 ~ /Z/ {print}' | wc -l
   ```

6. **Try to kill zombie directly**
   ```bash
   # Get zombie PID
   ZOMBIE_PID=$(ps aux | awk '$8 ~ /Z/ {print $2; exit}')
   
   echo "Zombie PID: $ZOMBIE_PID"
   
   # Try to kill it
   kill -TERM $ZOMBIE_PID
   
   # Check if still there
   ps -p $ZOMBIE_PID
   # Note: Zombie can't be killed!
   ```

7. **Kill the parent process**
   ```bash
   # Zombies are adopted by init when parent dies
   kill $PARENT_PID
   
   # Wait a moment
   sleep 1
   
   # Check for zombies
   ps aux | grep defunct
   # Zombies should be gone (adopted and cleaned by init)
   ```

8. **Create controlled zombie for study**
   ```bash
   # Create process that exits but parent doesn't wait
   cat > /tmp/parent.sh << 'SCRIPT'
   #!/bin/bash
   
   bash -c 'exit 0' &
   
   # Parent doesn't wait for child
   sleep 10
   SCRIPT
   
   chmod +x /tmp/parent.sh
   
   /tmp/parent.sh &
   
   # Quickly check process tree
   sleep 0.5
   ps -o pid,ppid,stat,cmd | grep parent -A2
   ```

### Expected Output

```
Zombie process in ps output:
USER  PID  PPID  STAT  COMMAND
user  123  456   Z     [bash] <defunct>

After killing parent:
$ kill 456
Zombies reaper by init and cleaned up
```

### Verification Checklist

- [ ] Can identify zombie processes (STAT = Z)
- [ ] Can find zombie PID and PPID
- [ ] Understand cannot kill zombie directly
- [ ] Know that killing parent cleans zombies
- [ ] Understand init (PID 1) adopts orphans
- [ ] Can count zombies on system
- [ ] Know difference between zombie and orphan

### Cleanup

```bash
# Kill parent process
pkill -f create_zombie

# Wait for cleanup
sleep 1

# Remove scripts
rm /tmp/create_zombie.sh /tmp/parent.sh 2>/dev/null

# Verify no more zombies
ps aux | grep defunct
```

---

## Lab 7: Process Information and Debugging

**Difficulty**: Intermediate | **Time**: 20 minutes

### Goal
Learn to gather detailed information about running processes for debugging.

### Setup

```bash
# Start a process we'll investigate
cat > /tmp/debug_process.sh << 'EOF'
#!/bin/bash

echo "Debug process starting..."
echo "PID: $$"

# Create some files (file descriptors)
exec 3< /etc/passwd
exec 4> /tmp/output.log

# Create some environment
DEBUG_VAR="test_value"
export DEBUG_VAR

# Sleep to keep running
sleep 60
EOF

chmod +x /tmp/debug_process.sh

# Start it
/tmp/debug_process.sh &
DEBUG_PID=$!
sleep 1
echo "Debug process PID: $DEBUG_PID"
```

### Steps

1. **Get basic process information**
   ```bash
   ps -o pid,ppid,user,rss,vsize,cmd -p $DEBUG_PID
   ```

2. **Check process working directory**
   ```bash
   ls -la /proc/$DEBUG_PID/cwd
   
   # Shows where process is running from
   ```

3. **Get absolute path of working directory**
   ```bash
   readlink /proc/$DEBUG_PID/cwd
   
   # Shows: /home/user or /path/to/directory
   ```

4. **View process command line**
   ```bash
   cat /proc/$DEBUG_PID/cmdline | tr '\0' ' ' && echo
   
   # Shows exactly how process was started
   ```

5. **Check process memory breakdown**
   ```bash
   cat /proc/$DEBUG_PID/status | grep Vm
   
   # Shows:
   # VmPeak: Peak memory
   # VmSize: Virtual size
   # VmRSS: Physical memory
   # VmData: Heap
   # VmStk: Stack
   ```

6. **View open file descriptors**
   ```bash
   ls -la /proc/$DEBUG_PID/fd/
   
   # Shows all open files, sockets, pipes
   ```

7. **Get environment variables**
   ```bash
   cat /proc/$DEBUG_PID/environ | tr '\0' '\n' | grep DEBUG
   
   # Shows DEBUG_VAR=test_value
   ```

8. **Check process limits**
   ```bash
   cat /proc/$DEBUG_PID/limits
   
   # Shows max file size, max processes, etc.
   ```

9. **List all file descriptors with details**
   ```bash
   for fd in /proc/$DEBUG_PID/fd/*; do
     echo -n "$(basename $fd): "
     readlink $fd
   done
   ```

10. **Use lsof to see open files** (may need sudo)
    ```bash
    lsof -p $DEBUG_PID
    
    # Shows all files, sockets, pipes opened by process
    ```

11. **Get full process map**
    ```bash
    pmap $DEBUG_PID
    
    # Shows memory map (virtual regions)
    ```

### Expected Output

```
$ cat /proc/$DEBUG_PID/status
Name:   debug_process.sh
Pid:    1234
PPid:   456
VmPeak:    50000 kB
VmSize:    48000 kB
VmRSS:      2000 kB
VmData:     1000 kB
VmStk:       136 kB

$ ls -la /proc/$DEBUG_PID/fd/
0 -> /dev/pts/0 (stdin)
1 -> /dev/pts/0 (stdout)
2 -> /dev/pts/0 (stderr)
3 -> /etc/passwd (opened file)
4 -> /tmp/output.log (output file)
```

### Verification Checklist

- [ ] Can view process info with ps
- [ ] Can check working directory
- [ ] Can read command line from /proc
- [ ] Can view memory breakdown
- [ ] Can list open file descriptors
- [ ] Can see environment variables
- [ ] Can check process limits
- [ ] Can use pmap or lsof for detailed info

### Cleanup

```bash
# Kill debug process
kill $DEBUG_PID

# Remove files
rm /tmp/debug_process.sh /tmp/output.log 2>/dev/null

# Verify
ps -p $DEBUG_PID
```

---

## Lab 8: Real-Time Process Monitoring with watch

**Difficulty**: Intermediate | **Time**: 25 minutes

### Goal
Use watch command to create continuous monitoring dashboards.

### Setup

```bash
# Create processes to monitor
cat > /tmp/varying_load.sh << 'EOF'
#!/bin/bash
while true; do
  # Vary CPU usage
  for i in {1..3}; do
    x=$(seq 1 $((50000 * $RANDOM / 32768)) | paste -sd+ | bc) > /dev/null &
  done
  
  sleep 3
  killall bc 2>/dev/null
  sleep 2
done
EOF

chmod +x /tmp/varying_load.sh

# Start it
/tmp/varying_load.sh &
LOAD_PID=$!
sleep 1
```

### Steps

1. **Monitor top CPU consumers every 2 seconds**
   ```bash
   watch -n 2 'ps aux --sort=-%cpu | head -10'
   
   # Watch for 15 seconds, then Ctrl+C
   ```

2. **Monitor memory usage**
   ```bash
   watch -n 2 'ps aux --sort=-%mem | head -10'
   ```

3. **Highlight changes between updates**
   ```bash
   watch -d 'ps aux | grep varying_load'
   
   # Differences highlighted
   # Ctrl+C to stop
   ```

4. **Create custom monitoring dashboard**
   ```bash
   watch -n 1 'clear; 
   echo "=== CPU Top 3 ===";
   ps aux --sort=-%cpu | head -4;
   echo "";
   echo "=== MEMORY Top 3 ===";
   ps aux --sort=-%mem | head -4;
   echo "";
   echo "=== PROCESS COUNT ===";
   ps aux | wc -l'
   
   # Watch for 10 seconds, Ctrl+C
   ```

5. **Monitor specific process**
   ```bash
   watch -n 1 'ps -o pid,ppid,%cpu,%mem,cmd -p '$LOAD_PID
   
   # See real-time changes
   # Ctrl+C when done
   ```

6. **Monitor with system resources**
   ```bash
   watch -n 2 'echo "=== LOAD ===";
   uptime;
   echo "";
   echo "=== MEMORY ===";
   free -h;
   echo "";
   echo "=== TOP PROCESS ===";
   ps aux --sort=-%cpu | head -2'
   ```

7. **Monitor process tree changes**
   ```bash
   watch 'pstree -p' | head -30
   
   # Watch for 10 seconds
   # Ctrl+C to stop
   ```

8. **Create file to watch process across terminals**
   ```bash
   # In terminal 1
   watch -n 1 'ps aux | grep varying_load' > /tmp/monitor.log 2>&1 &
   
   # In terminal 2, tail the log
   tail -f /tmp/monitor.log
   
   # See continuous monitoring
   ```

### Expected Output

```
watch output updates every 2 seconds:

Every 2.0s: ps aux --sort=-%cpu | head -10

USER  PID  %CPU %MEM  VSZ   RSS STAT START TIME COMMAND
root  1    0.0  0.2   18192 2956 Ss   10:00 0:00 /sbin/init
user  123  45.2 1.5   95000 15000 R  10:15 0:15 /tmp/varying_load.sh
user  124  32.1 0.8   50000 8000  R  10:15 0:08 bc
...
```

### Verification Checklist

- [ ] Can use watch with ps output
- [ ] Can set update interval with -n
- [ ] Can highlight changes with -d
- [ ] Can create custom dashboard
- [ ] Can monitor specific PID
- [ ] Can combine multiple commands
- [ ] Can see real-time process changes

### Cleanup

```bash
# Stop monitoring processes
pkill -f varying_load

# Stop any remaining watch processes
pkill watch

# Remove temporary files
rm /tmp/varying_load.sh /tmp/monitor.log 2>/dev/null

# Verify
ps aux | grep -E "varying_load|watch"
```

---

## Summary

After completing these 8 labs, you should be comfortable with:

✓ Listing and exploring processes  
✓ Monitoring CPU and memory usage  
✓ Managing background jobs  
✓ Sending signals to processes  
✓ Understanding process priority  
✓ Identifying zombie processes  
✓ Gathering detailed process information  
✓ Creating real-time monitoring dashboards  

**Total Time**: 180 minutes of hands-on learning

---

**Next**: Explore the production scripts in [scripts/README.md](scripts/README.md) for real-world automation patterns.
