# Module 07: Process Management - Theory

Comprehensive conceptual foundations for understanding and managing processes in Linux.

## Table of Contents

1. [Program vs Process vs Thread](#program-vs-process-vs-thread)
2. [Process Lifecycle](#process-lifecycle)
3. [Process Identification](#process-identification)
4. [Process Hierarchy](#process-hierarchy)
5. [Process States](#process-states)
6. [Process Memory and Resources](#process-memory-and-resources)
7. [Signals and Signal Handling](#signals-and-signal-handling)
8. [Job Control](#job-control)
9. [Zombie and Orphan Processes](#zombie-and-orphan-processes)
10. [Process Groups and Sessions](#process-groups-and-sessions)

---

## Program vs Process vs Thread

### Program
A **program** is static code on disk.

```
Binary file: /usr/bin/nginx
- Contains: Machine instructions, libraries, data
- Status: Static, not executing
- Memory: On disk
```

### Process
A **process** is a running instance of a program with its own memory space.

```
Process = Program + State + Resources

A single program can have multiple processes:
$ ps aux | grep firefox
user     1234  ... /usr/bin/firefox
user     1235  ... /usr/bin/firefox
```

Each has:
- Unique Process ID (PID)
- Own memory space
- Own file descriptors
- Current working directory
- Environment variables
- Signal handlers

### Thread
A **thread** is a lightweight execution unit within a process.

```
Single-threaded process:
┌─ Process (PID 1234) ─────┐
│ ┌─ Thread 1 (main)      │
│ │                        │
└─────────────────────────┘

Multi-threaded process:
┌─ Process (PID 1234) ─────┐
│ ┌─ Thread 1             │
│ ├─ Thread 2             │
│ └─ Thread 3             │
│ (Shared memory space)     │
└─────────────────────────┘
```

**Key Difference:**
- Processes: Separate memory spaces (isolation)
- Threads: Shared memory space (lighter weight, data race risk)

### Real Example

```bash
$ ps aux | grep bash
user     1500  0.0 0.1  5232  2456 pts/0    Ss   10:30   0:00 bash

This shows:
- Program: /bin/bash (the binary)
- Process: Running instance with PID 1500
- Threads: bash runs 1 main thread (mostly)
```

---

## Process Lifecycle

### Birth: Process Creation

```
fork()     Creates new process
    │
    ├─► Parent continues
    └─► Child process created (PPID set to parent)
           │
           exec()     Load new program into memory
               │
               └─► Process executes new program
```

### Real Example

```bash
$ bash                    # Parent shell
  └─ firefox &            # Child process created
     └─ firefox plugins   # Firefox child processes
```

When you type `bash`, the kernel:
1. Calls fork() → creates new process
2. New process calls exec("/bin/bash") → loads bash program
3. Old shell is still parent

### Running Phase

```
┌─────────────────────────────────────┐
│        Running Phase                 │
├─────────────────────────────────────┤
│ • Executing instructions            │
│ • Using CPU time (context switch)  │
│ • Reading/writing files             │
│ • Using memory                       │
│ • Waiting for I/O                   │
└─────────────────────────────────────┘
```

### Death: Process Termination

```
Normal Exit
    │
    ├─► exit()            Process calls exit with code
    │
    └─► Signal Termination
        ├─► SIGTERM        Graceful termination request
        ├─► SIGKILL        Forced termination
        └─► SIGSEGV        Segmentation fault (crash)
```

**After Process Dies:**

```
exit() called with code X
    │
    └─► Process marked as ZOMBIE
        │
        └─► Parent reads exit status (wait/waitpid)
            │
            └─► Process reaped (removed from kernel table)
```

### Exit Codes

```bash
$ command
$ echo $?              # Print exit code

Exit codes:
0 = Success
1 = General error
2 = Misuse of shell command
126 = Command found but not executable
127 = Command not found
128+N = Terminated by signal N
130 = Terminated by Ctrl+C (SIGINT)
255 = Out of range
```

---

## Process Identification

### PID (Process ID)

Unique identifier assigned by kernel to each process.

```bash
$ ps aux
PID    USER    COMMAND
1      root    /sbin/init
234    user    bash
2345   user    firefox
```

**Characteristics:**
- Unique per system (at any given time)
- Recycled when process dies
- 32-bit integer typically (1 to 2^31-1)
- PID 1 = init process (systemd on modern Linux)
- PID 0 = kernel scheduler

### PPID (Parent Process ID)

PID of the process that created this process.

```bash
$ ps aux | grep bash
PPID  PID  COMMAND
1     234  bash                    # Shell started by init
234   456  firefox                 # firefox started by bash
456   789  firefox-plugin          # Plugin started by firefox
```

**Hierarchy Tree:**
```
PID 1 (init/systemd)
├─ PID 234 (bash) ← PPID=1
│  ├─ PID 456 (firefox) ← PPID=234
│  │  └─ PID 789 (plugin) ← PPID=456
│  └─ PID 567 (htop) ← PPID=234
└─ PID 345 (sshd) ← PPID=1
```

### Getting PID/PPID Information

```bash
# Get PID of specific process
ps aux | grep nginx
pgrep nginx
pidof sshd

# Get PPID
ps -o ppid= -p 1234

# Get full process tree
ps aux
pstree

# Get process info with custom format
ps -o pid,ppid,cmd
```

---

## Process Hierarchy

### Parent-Child Relationships

```
Parent Process
  │
  ├─ fork()
  │
  └─► Child Process
      (inherits parent's resources, can diverge)
```

### Process Family Example

```
$ pstree
systemd(1)
├─sshd(450)
│ └─bash(600) ← user session
│   ├─vim(700)
│   ├─node(701)
│   └─firefox(702)
│     ├─firefox(703)
│     └─firefox(704)
├─nginx(500)
│ ├─nginx(501)
│ └─nginx(502)
└─mysqld(400)
```

### Key Relationships

**When Parent Dies:**

```
If parent (PID 600) dies:
├─ Child processes get adopted by init (PID 1)
├─ Called "orphan" process
├─ Still runs normally
└─ Gets reparented to systemd
```

**When Child Dies:**

```
If child (PID 700) dies:
├─ Returns exit code to parent
├─ Becomes ZOMBIE temporarily
├─ Parent must read status (wait/waitpid)
└─ Then fully removed from kernel
```

### Viewing Process Tree

```bash
# ASCII tree view
pstree

# Detailed tree
ps auxf                    # 'f' flag shows forest (tree)

# Following specific branch
pstree -p 600             # Show children of PID 600
```

---

## Process States

### State Diagram

```
         CREATED
            │
            ▼
        RUNNING ◄──────► SLEEPING
    (executing code)  (waiting for I/O)
            │
            ├─ Signal received
            │
            ▼
        STOPPED
    (paused, can resume)
            │
            ├─ continues/killed
            │
            ▼
        ZOMBIE
    (dead, waiting for parent)
            │
            │ (parent collects status)
            │
            ▼
        TERMINATED
    (removed from kernel)
```

### State Codes in ps Output

| Code | State | Meaning |
|------|-------|---------|
| **R** | Running | Executing code or in run queue |
| **S** | Sleeping | Waiting for event (I/O, timer, signal) |
| **D** | Disk sleep | Uninterruptible sleep (I/O wait, can't signal) |
| **Z** | Zombie | Dead process, parent hasn't collected status |
| **T** | Stopped | Suspended (Ctrl+Z or SIGSTOP) |
| **W** | Paging | Process is paging (rare on modern systems) |
| **X** | Dead | Dead (shouldn't appear) |
| **<** | High priority | Higher priority (nice value < 0) |
| **N** | Low priority | Lower priority (nice value > 0) |
| **+** | Foreground | Foreground process group |

### Real Example

```bash
$ ps aux
USER  PID %CPU %MEM STAT
root  1   0.0  0.2  Ss      ← systemd (sleeping, session leader)
root  234 0.0  0.1  S       ← sshd (sleeping)
user  456 5.2  1.5  R+      ← python (running, foreground)
user  789 0.1  0.3  S       ← bash (sleeping)
user  999 0.0  0.0  Z       ← defunct (zombie)
```

---

## Process Memory and Resources

### Virtual Memory Layout

```
┌──────────────────────────────────────┐
│         VIRTUAL MEMORY MAP            │
├──────────────────────────────────────┤
│ Kernel Space                          │
│ (protected)                           │
├──────────────────────────────────────┤
│ Stack                                 │
│ (grows downward)                      │
│ • Local variables                     │
│ • Function parameters                 │
│ • Return addresses                    │
├──────────────────────────────────────┤
│ Heap                                  │
│ (grows upward)                        │
│ • Dynamic allocation                  │
│ • malloc/new memory                   │
├──────────────────────────────────────┤
│ Data Segment                          │
│ • Uninitialized global/static (BSS)  │
│ • Initialized global/static (data)   │
├──────────────────────────────────────┤
│ Text (Code)                           │
│ • Read-only program instructions      │
│ • Shared among processes              │
└──────────────────────────────────────┘
```

### Memory Terminology

```bash
$ ps aux
USER  PID  VSZ    RSS
user  123  500000 50000

VSZ (VIRT) = Virtual Size = 500,000 KB = 500 MB
  ├─ Total addressable memory
  ├─ Includes: code, data, heap, stack, libraries
  ├─ Not all loaded in physical RAM
  └─ Can be larger than available RAM

RSS (RES) = Resident Set Size = 50,000 KB = 50 MB
  ├─ Actual physical RAM used
  ├─ Includes: loaded code, data, heap
  └─ What matters for real resource usage
```

### Checking Process Resources

```bash
# Simple memory info
ps aux | grep firefox

# Detailed memory breakdown
cat /proc/1234/status | grep Vm
# Output:
# VmPeak:     500000 kB   (peak VSZ)
# VmSize:     490000 kB   (current VSZ)
# VmRSS:       50000 kB   (current RSS)
# VmData:      100000 kB   (heap)
# VmStk:        8192 kB   (stack)

# Memory usage with multiple processes
pmap 1234                  # Detailed memory map
```

### Resource Limits

Each process can have limits:

```bash
# See limits for current process
ulimit -a

# Output:
# core file size          0
# data seg size       unlimited
# virtual memory      unlimited
# open files              1024
# max locked memory   unlimited
# stack size             8192
```

Can be set per-process:

```bash
# Limit a process to 500MB memory
ulimit -v 512000
long_running_task

# Or at process creation
systemd-run --property MemoryLimit=500M command
```

---

## Signals and Signal Handling

### What is a Signal?

A **signal** is an asynchronous notification sent to a process.

```
Signal sent by:
├─ User (Ctrl+C)
├─ Kernel (page fault, timer)
├─ Another process (kill command)
└─ Process itself (raise())

Signal received by process:
├─ Execute signal handler
├─ Default action (terminate, ignore, etc.)
└─ Or ignore if masked
```

### Common Signals

| Signal | Number | Meaning | Can Ignore? | Default |
|--------|--------|---------|-------------|---------|
| **SIGHUP** | 1 | Hangup | Yes | Terminate |
| **SIGINT** | 2 | Interrupt (Ctrl+C) | Yes | Terminate |
| **SIGQUIT** | 3 | Quit (Ctrl+\) | Yes | Terminate + Core |
| **SIGKILL** | 9 | Kill (cannot ignore!) | **No** | **Terminate** |
| **SIGTERM** | 15 | Termination (graceful) | Yes | Terminate |
| **SIGSTOP** | 19 | Stop (cannot ignore!) | **No** | **Stop** |
| **SIGCONT** | 18 | Continue | Yes | Continue |
| **SIGCHLD** | 17 | Child process change | Yes | Ignore |
| **SIGSEGV** | 11 | Segmentation fault | No | Terminate + Core |

### Signal Handling Workflow

```
Process receives signal
    │
    ├─ Signal handler registered?
    │  ├─ Yes: Execute handler
    │  └─ No: Use default
    │
    ├─ Signal masked?
    │  ├─ Yes: Queue for later
    │  └─ No: Process immediately
    │
    └─ Result:
       ├─ Terminate
       ├─ Stop/Continue
       ├─ Ignore
       └─ Custom action
```

### Sending Signals

```bash
# Send SIGTERM (graceful)
kill -TERM 1234
kill -15 1234

# Send SIGKILL (force)
kill -KILL 1234
kill -9 1234

# Send signal to all processes matching name
pkill -TERM nginx
pkill -9 firefox

# Send with delay (give time for cleanup)
kill -TERM 1234; sleep 2; kill -KILL 1234
```

### Signal Handling in Scripts

```bash
#!/bin/bash

cleanup() {
  echo "Caught SIGTERM, cleaning up..."
  # Do cleanup
  exit 0
}

# Register signal handler
trap cleanup SIGTERM

# Main loop
while true; do
  echo "Working..."
  sleep 1
done
```

---

## Job Control

### What is a Job?

A **job** is the shell's representation of a process or process group.

```
Shell Prompt
    │
    ├─ Command 1 (Job 1)
    ├─ Command 2 (Job 2)
    └─ Command 3 (Job 3)
```

### Foreground vs Background

```
┌──────────────────────────────────────┐
│ Terminal (shell prompt)               │
├──────────────────────────────────────┤
│                                       │
│ FOREGROUND Process                   │
│ ├─ Reads from terminal (stdin)       │
│ ├─ Writes to terminal (stdout/err)  │
│ ├─ Receives Ctrl+C signal           │
│ └─ Blocks terminal (can't type new)  │
│                                       │
│ Blocked: Can't execute new commands  │
│                                       │
├──────────────────────────────────────┤
│                                       │
│ BACKGROUND Processes                 │
│ ├─ Don't read from terminal          │
│ ├─ Output goes to terminal           │
│ ├─ Don't get Ctrl+C signal          │
│ └─ Terminal available for new cmds  │
│                                       │
│ Available: Can execute more commands │
│                                       │
└──────────────────────────────────────┘
```

### Job Control Commands

```bash
# Start process in foreground (normal)
$ firefox                   # Terminal blocked until firefox closes

# Start process in background
$ firefox &                 # Terminal prompt returns immediately

# Suspend foreground process
$ [running process]
^Z                          # Press Ctrl+Z

# List background jobs
$ jobs
[1]   Stopped     firefox
[2]   Running     compilation

# Resume suspended job in background
$ bg %1                     # Resume job 1 in background

# Bring background job to foreground
$ fg %1                     # Bring job 1 to foreground
```

### Multiple Jobs Example

```bash
# Start multiple background processes
$ long_task1 &              # Job 1
$ long_task2 &              # Job 2
$ long_task3                # Job 3 (foreground, terminal blocked)

# Press Ctrl+Z on Job 3
^Z                          # Suspend Job 3

# Now manage jobs
$ jobs
[1]   Running     long_task1 &
[2]   Running     long_task2 &
[3]   Stopped     long_task3

# Bring suspended job to foreground
$ fg %3
```

### Job References in Shell

```bash
%1      % nearest job
%2      %+ current job
%-      %- previous job
%str    %command_name_prefix
%?str   %?command_name_substring
```

---

## Zombie and Orphan Processes

### Zombie Processes

A **zombie** is a process that has terminated but whose parent hasn't collected its exit status.

```
Process lifecycle:
1. Process starts
2. Process does work
3. Process calls exit()
4. Kernel marks as ZOMBIE
5. Parent should call wait() to collect status
6. Process removed from kernel

Problem if Step 5 doesn't happen:
├─ Process remains in zombie state
├─ Takes up PID slot
├─ Wastes minimal resources (no memory)
└─ Should be cleaned up
```

### Why Zombies Exist (Design Reason)

```
Parent needs to know:
├─ Child exit status (success/failure)
├─ Child resource usage (CPU time, memory)
└─ Signal that killed it (if any)

So kernel keeps info until parent asks with wait()
```

### Identifying Zombies

```bash
$ ps aux | grep defunct
user  1234  0.0  0.0  0   0  pts/0  Z+  10:30   0:00 [firefox] <defunct>

# Z in STAT column = zombie
# [process_name] in brackets = zombie
# 0 0 memory = no memory use
```

### Fixing Zombie Processes

```bash
# Option 1: Restart/kill parent (parent will be reparented to init)
$ kill -TERM [PPID]

# Option 2: If parent is stuck, kill it forcefully
$ kill -KILL [PPID]

# Option 3: Restart the parent service
$ sudo systemctl restart service_name

# After parent dies, init collects zombie status (init is good parent)
```

### Orphan Processes

An **orphan** is a process whose parent has died but the process still lives.

```
1. Parent starts child
2. Parent dies (without waiting for child)
3. Child still running
4. Kernel reparents child to init (PID 1)
5. Child continues normally

Orphan is NOT a problem:
├─ Process continues normally
├─ init becomes parent (adopts it)
├─ init will eventually wait() for it
└─ No cleanup issue
```

### Difference: Zombie vs Orphan

| Type | Parent Alive? | Process Alive? | Status Collected? | Problem? |
|------|---------------|----------------|-------------------|----------|
| **Zombie** | May be stuck | Dead | No | Minor (wastes PID) |
| **Orphan** | Dead | Alive | N/A | None (reparented to init) |

### Real Example

```bash
# Script that creates zombie
$ cat create_zombie.sh
#!/bin/bash
bash -c 'sleep 1 & wait'  # Parent waits for child's child

$ ./create_zombie.sh &    # Start in background

# Check quickly (before cleanup)
$ ps aux | grep defunct
```

---

## Process Groups and Sessions

### Process Groups

A **process group** is a collection of processes that can receive the same signal.

```
PGID = Process Group ID

┌──── Process Group 1 ────┐
│ PID 100 (PGID: 100)     │
│ PID 101 (PGID: 100)     │
│ PID 102 (PGID: 100)     │
└─────────────────────────┘

Signal sent to group:
$ kill -TERM -100    # Send to PGID 100 (all 3 processes)
```

### Sessions

A **session** is a collection of process groups sharing the same controlling terminal.

```
Session Leader: Shell (bash)
│
├─ Process Group 1
│  ├─ Process 1
│  └─ Process 2
│
├─ Process Group 2
│  └─ Process 3
│
└─ Foreground Process Group: Group 1
   (can receive Ctrl+C)
```

### Terminal Control

```
Terminal (pts/0)
└─ Session Leader: bash
   ├─ Foreground Process Group
   │  └─ Current command (gets Ctrl+C)
   │
   └─ Background Process Groups
      └─ Don't get signals from terminal
```

### Viewing Groups

```bash
# See process groups
ps -o pid,ppid,pgid,sid,cmd

# Output:
# PID  PPID  PGID  SID  CMD
# 100  1     100   100  bash
# 101  100   101   100  firefox
# 102  100   101   100  firefox-plugin

# Get session ID of current shell
ps -o sid=

# Get process group ID
ps -o pgid=
```

---

## Key Takeaways

1. **Process = Running program** with isolated memory and resources
2. **PID/PPID establish hierarchy** - parent can monitor child
3. **States represent lifecycle** - running, sleeping, stopped, zombie
4. **Signals are events** - SIGTERM graceful, SIGKILL forced
5. **Job control manages** - foreground vs background execution
6. **Monitor processes** - use ps, top, htop to observe
7. **Clean up properly** - handle child processes (avoid zombies)
8. **Process groups** - for coordinated signal delivery

---

**Ready to practice?** Continue to [02-commands-cheatsheet.md](02-commands-cheatsheet.md)
