# Memory and Disk Management: Conceptual Foundations

Understanding memory and disk management requires knowing how Linux abstracts, allocates, and manages these critical resources.

---

## Section 1: Virtual Memory Architecture

### The Abstraction Layer

Linux provides an abstraction called Virtual Memory that decouples what processes see from what physically exists:

```
Process View:       ┌─────────────────────────┐
                    │   Virtual Address Space │
                    │   (0 to 2^64 bytes)     │
                    └────────────────────────┐│
                                             ││
        Kernel Mapping ────────────────────┘ │
                                             │
Real World:     ┌──────────────┬──────────────┘
                │              │
            ┌───▼──┐      ┌────▼────┐
            │ RAM  │      │   Disk  │
            │ Fast │      │   Slow  │
            │ 16GB │      │ Swap 4GB│
            └──────┘      └─────────┘
```

**Why this matters**: A process doesn't directly access RAM. It uses virtual addresses that the kernel maps to physical memory or disk.

### Memory Pages

The kernel divides memory into fixed-size chunks called **pages** (typically 4KB):

```
Virtual Address Space:
├── Page 0 (0x0000-0x0FFF) ──→ Physical RAM frame 5
├── Page 1 (0x1000-0x1FFF) ──→ Physical RAM frame 12
├── Page 2 (0x2000-0x2FFF) ──→ Swap disk
├── Page 3 (0x3000-0x3FFF) ──→ Physical RAM frame 89
└── ...

When process accesses virtual address:
1. Kernel checks Page Table
2. If in RAM → immediate access (fast)
3. If in swap → page fault, kernel loads from disk (slow)
4. If not allocated → segmentation fault (crash)
```

### Working Set

The **working set** is the set of pages actually needed by a process at any moment:

```
Process Memory:
├── Code (always needed, small)
├── Initialized data (usually needed)
├── Heap (often needed)
├── Stack (often needed)
└── Cache (sometimes needed)

Working Set = Pages actually accessed in last time window

If Working Set fits in RAM: Process runs fast
If Working Set > RAM: Pages swap to disk, process slows dramatically
```

---

## Section 2: Memory Regions and Usage

### Process Memory Layout

Each process has virtual memory divided into regions:

```
High Address   ┌──────────────────┐
               │      Kernel      │
               │ (inaccessible)   │
               ├──────────────────┤
               │      Stack       │ Grows downward
               │   (call stack)   │ Expands as needed
               │                  │
               ├──────────────────┤
               │     (unused)     │
               │     (gap)        │
               │                  │
               ├──────────────────┤
               │      Heap        │ Grows upward
               │  (dynamic alloc) │ malloc/new allocate here
               ├──────────────────┤
               │  Initialized     │ Global variables
               │  Uninitialized   │
               ├──────────────────┤
               │      Code        │ Executable instructions
Low Address    └──────────────────┘

Process reports:
- VSZ (Virtual Size): Total allocated (code + heap + stack + libraries)
- RSS (Resident Set Size): Actually in RAM right now
```

### System Memory Types

```
System RAM Breakdown:
├── User Memory (processes)
├── Kernel Memory
├── Buffers (I/O buffers being written)
├── Cache (frequently accessed data)
└── Free

Key insight:
- Buffers/Cache = Can be freed if needed
- Free = Available immediately
- Used by Processes = Harder to free
```

### Swap: Memory on Disk

When RAM fills, kernel moves inactive pages to swap:

```
RAM Status: 15.9 GB total
├── Used by processes: 12 GB
├── Cache: 2 GB (can free)
├── Free: 1.9 GB
└── Result: ~90% full

When process needs memory:
1. Kernel looks for inactive pages
2. Moves them to swap (disk)
3. Frees physical RAM
4. Process continues

When process accesses swapped page:
1. Page fault triggered
2. Kernel loads from disk to RAM
3. May need to swap something else out
4. Process continues (but slower)
```

---

## Section 3: Memory Analysis Tools

### free Command

```bash
$ free -h

              total        used        free      shared  buff/cache   available
Mem:           15Gi       9.5Gi       2.1Gi       1.2Gi       3.4Gi       3.2Gi
Swap:          7.9Gi       0.0Gi       7.9Gi

Interpretation:
- total: Total RAM installed
- used: Used by processes (note: includes cache)
- free: Unused memory (low is normal)
- shared: Shared memory (usually small)
- buff/cache: Buffering and caching (can be freed!)
- available: Actually available without swapping

Key insight: High "used" is OK if "buff/cache" is high
            Low "available" = system under memory pressure
```

### top and ps: Process Memory

```bash
$ top
PID   USER  %MEM   VSZ    RSS    COMMAND
1234  alice  12.5%  2.1G   1.8G   java
5678  bob    8.3%   1.2G   950M   chrome
9012  sys    2.1%   340M   180M   mysql

Interpretation:
- %MEM: Percentage of total RAM
- VSZ: Virtual size (including shared libraries, won't all be in RAM)
- RSS: Resident Set Size (actually in RAM)
- Diff (VSZ-RSS): Amount swapped out or mapped but not loaded

Memory hog identification: Sort by RSS (actual RAM used)
```

---

## Section 4: Disk Architecture and Hierarchy

### Block Devices

All storage appears as block devices:

```
Physical Disk (SSD/HDD)
│
/dev/sda ─────────────────────── Block device interface
│
├── /dev/sda1 (200MB) ───────── Partition 1 (Boot)
│   └── Mount at / ──────────── Accessible as directory
│
├── /dev/sda2 (100GB) ──────── Partition 2 (Root)
│   └── Mount at /data ─────── Different mountpoint
│
└── /dev/sda3 (8GB) ────────── Partition 3 (Swap)
    └── Used as memory, not mounted

Virtual Devices (from files):
/dev/loop0 ────────────────── Filesystem from file
          └── Mount at /mnt/test ─ File looks like device
```

### Filesystem Hierarchy

```
/ (Root)
├── /bin ─────── Essential commands
├── /etc ─────── Configuration files
├── /home ────── User directories
├── /var ─────── Variable data (logs, cache, spool)
│   ├── /var/log ────── Logs (can grow huge)
│   └── /var/cache ──── Application cache
├── /tmp ─────── Temporary files (often limited size)
├── /usr ─────── User programs and data
├── /dev ─────── Device files
├── /proc ────── System information (kernel, processes)
└── /sys ─────── System configuration

Storage location diagram:
One physical disk might have:
- / on partition 1
- /home on partition 2 (separate, easier to manage/expand)
- /var on partition 3 (if busy, separate I/O)
- Swap on partition 4
```

### Filesystem Space Management

```
Partition: /dev/sda1 (100 GB total)

Used Space:
├── Files: 45 GB (actual user data)
├── Metadata: 1 GB (inodes, directories)
└── Journal: 0.5 GB (filesystem journal for recovery)
= 46.5 GB used

Free Space:
├── Reserved: 5% (5 GB) - for system (root can still write when ~100%)
└── Available: ~48.5 GB to users

Key issue: If free space < 5%, system starts having problems
          - No room for logs (crashes)
          - No room for temp files (apps fail)
          - Filesystem performance degrades
```

---

## Section 5: Disk I/O Performance

### I/O Operations

Every read/write to disk involves:

```
Time for one read:
├── Seek time: 5-10 ms (disk head positioning)
├── Rotational delay: 2-4 ms (waiting for data)
└── Transfer time: depends on size

Modern SSD:
├── Seek time: ~0.1 ms (no moving parts)
├── Transfer: very fast

Typical latencies:
- RAM: 100 nanoseconds
- SSD: 100 microseconds (1,000x slower than RAM)
- HDD: 5 milliseconds (50,000x slower than RAM)
```

### I/O Performance Metrics

```
IOPS (Input/Output Operations Per Second):
- SSD: 10,000-100,000 IOPS
- HDD: 100-500 IOPS

Throughput (Data transfer rate):
- SSD: 200-600 MB/s
- HDD: 100-200 MB/s

Latency (Time per operation):
- SSD: 1 ms average
- HDD: 10-50 ms average
```

### I/O Wait (System Bottleneck)

```
CPU Activity Breakdown:
├── User: 30% (user processes)
├── System: 10% (kernel work)
├── I/O Wait: 40% ← HIGH! Waiting for disk
├── Idle: 20%

Interpretation:
- High I/O Wait % = Disk is bottleneck (not CPU)
- Solution: Get faster disk, optimize I/O pattern
```

---

## Section 6: Common Memory Problems

### Out of Memory (OOM)

```
Scenario:
1. RAM full (15 GB)
2. Swap full (8 GB)
3. Process requests more memory

What happens:
└─ OOM Killer selects a process
   └─ Kills it to free memory
   └─ Lost work, service interruption

Prevention:
1. Monitor memory (free, available, trends)
2. Set up alerts (when available < threshold)
3. Increase swap (temporary)
4. Reduce process memory usage
5. Add more RAM (permanent)
```

### Memory Leaks

```
Process behavior over time:

Normal process:
Memory ─┐
        ├─────── stable (uses same amount)
        │
Time ──→

Memory leak:
Memory ─┐
        │   / growing over time
        │  /
        │ /  eventually crashes when hits limit
        │/
Time ──→

Detection: Monitor RSS of process over days/weeks
          Check if growing without reason
```

### Swap Thrashing

```
Condition: Working set > RAM, constantly paging

Performance:
├── CPU: 100% (kernel shuffling pages)
├── I/O: 100% (constantly reading/writing swap)
├── Response: 10x slower (everything waits for disk)

Example:
- RAM: 4 GB
- Swap: 4 GB
- Working set: 6 GB
= Constantly moving 2 GB between RAM and swap

Symptoms:
- "Why is my system so slow?"
- CPU at 100%, but no single process using it
- Disk constantly active
```

---

## Section 7: Common Disk Problems

### Disk Full

```
Problem: df shows 100% used

Reasons:
1. Large log files: /var/log filling up
2. Application cache: /var/cache full
3. Old packages: /var/cache/apt full
4. System packages: /usr full
5. Temp files: /tmp accumulating

Impact:
- Can't create new files
- Log rotation fails (important events lost)
- Application crashes (can't write files)
- System may not boot properly

Solution workflow:
1. df -h (see which partition full)
2. du -sh /* (see what consuming space)
3. du -sh /var/log/* (drill down)
4. find /var/log -name "*.log" -mtime +30 (old files)
5. rm or compress old files
```

### Inode Exhaustion

```
Filesystems have two limits:
1. Space (how many bytes)
2. Inodes (how many files)

Problem: Too many small files

Example:
- Partition: 100 GB total
- Space used: 10 GB (plenty free)
- df -i: 100% inodes used!

Impact:
- Can't create new files (no inodes left)
- Error: "No space left on device" (but space is free!)

Causes:
- Millions of small files
- /tmp not cleaned
- Temp files accumulating

Solution:
1. df -i (see inode usage)
2. find . -type f | wc -l (count files in directory)
3. Remove unnecessary files
```

### Filesystem Corruption

```
Causes:
- Power loss during write
- Filesystem error not recovered
- Hardware failure
- Unflushed writes

Symptoms:
- Can't read files
- Files appear corrupted
- Filesystem won't mount
- Performance degradation

Repair: fsck (filesystem check)
- Must run on unmounted filesystem
- Modern filesystems have journaling (less corruption risk)
```

---

## Section 8: ASCII Diagrams for Key Concepts

### Memory Hierarchy and Speed

```
              Access Speed
              │
              ▲
       1ns    │  ┌────────┐
              │  │ Registers (CPU)
              │  └────────┘
       3ns    │  ┌────────┐
              │  │ L1 Cache (32KB)
              │  └────────┘
      10ns    │  ┌────────┐
              │  │ L2 Cache (256KB)
              │  └────────┘
      50ns    │  ┌────────┐
              │  │ L3 Cache (8MB)
              │  └────────┘
     100ns    │  ┌────────┐
              │  │   RAM
              │  │ (16GB)
              │  └────────┘
      100µs   │  ┌────────┐
              │  │   SSD
              │  │ (512GB)
              │  └────────┘
      10ms    │  ┌────────┐
              │  │   HDD
              │  │ (2TB)
              │  └────────┘
              │
              └────────────→ Capacity
```

### Typical System Performance Under Memory Pressure

```
System Performance vs Available Memory:

Response Time
  │
  │                    ┌──────────────aining
  │                 ┌──┘ Swapping begins
  │              ┌──┘
  │          ┌───┘ Working set in RAM
  │       ┌──┘ Everything fast
  │    ┌──┘
  │ ┌──┘
  └─┘───────────────────────
    0%  25% 50% 75% 100% RAM used

- 0-60%: Fast (plenty of cache possible)
- 60-80%: Normal (cache limited)
- 80-95%: Slowing (some paging)
- 95%+: Slow (heavy paging to swap)
- 100%+: Crisis (OOM killer activating)
```

---

## Section 9: Performance Monitoring Tools

### iostat Output Interpretation

```bash
$ iostat -x 1 2

Device           %util    r/s    w/s    rMB/s   wMB/s
sda              85.2     120    300    15.2    8.3
nvme0n1          12.4     500    100    120.3   40.2

Interpretation:
- %util: Disk busy percentage (>70% = bottleneck)
- r/s: Reads per second
- w/s: Writes per second
- rMB/s: Read throughput
- wMB/s: Write throughput

High values indicate:
- High %util = Disk saturated
- High r/s or rMB/s = Read intensive workload
- High w/s or wMB/s = Write intensive workload
```

### vmstat Output Interpretation

```bash
$ vmstat 1 3

procs -----------memory---------- ---swap-- -----io-----
 r  b   swpd   free   buff  cache   si   so    bi    bo
 2  0   1024  2048   512  8192    0    0    10    20
 1  0   1024  2048   512  8192    2    1    15    25
 3  1   2048  1024   512  4096    5    3    50    40

Interpretation:
- r: Processes in run queue
- b: Processes in blocked I/O
- swpd: Swap used
- free: Free memory
- buff: Buffer memory
- cache: Cache memory
- si: Swap in (pages read from swap, BAD)
- so: Swap out (pages written to swap, BAD)
- bi: Blocks in (disk reads)
- bo: Blocks out (disk writes)

Indicators of problems:
- High si/so = Memory pressure (paging)
- High bi/bo = I/O intensive
- High b = Blocked on I/O
```

---

## Section 10: Mental Models for Troubleshooting

### Model 1: System as a Hierarchy

```
Application (using resources)
    ↓
Kernel (managing allocation)
    ├─→ Process scheduler (CPU)
    ├─→ Memory manager (RAM/swap)
    └─→ I/O scheduler (disk)

When problem occurs:
1. Is it application? (using too much?)
2. Is it kernel? (managing poorly?)
3. Is it hardware? (insufficient capacity?)
```

### Model 2: Performance Triangle

```
        Quality
           /\
          /  \
         /    \
        /      \
       /        \
Speed─────────Capacity
      \        /
       \      /
        \    /
         \  /
          \/
        Cost

Can't maximize all three:
- Fast & High Capacity = Expensive (more RAM/SSD)
- Fast & Cheap = Low Capacity (limited)
- High Capacity & Cheap = Slow (HDD)

Optimization involves choosing tradeoff
```

### Model 3: Bottleneck Analysis

```
System has 4 potential bottlenecks:

1. CPU: Can't process data fast enough
   - Solution: Faster CPU, parallel processing
   - Indicator: High CPU%, low I/O%

2. Memory: Not enough RAM
   - Solution: Add RAM, reduce process usage
   - Indicator: High swap, available < 20%

3. Disk I/O: Disk too slow or overloaded
   - Solution: Faster disk, SSD, optimize I/O
   - Indicator: High %util, high si/so

4. Network: Network connection bottleneck
   - Solution: Faster NIC, optimize protocol
   - Indicator: Network saturated (not covered here)

Find bottleneck first, then optimize it
(No point optimizing what's not constraining)
```

---

## Section 11: Optimization Strategies

### For Memory Issues

```
Problem: High memory usage, low available

Options (in order of impact):

1. Add more RAM (best if sustainable growth)
   - Cost: $$$
   - Impact: Solves problem completely

2. Reduce process memory footprint
   - Tune application settings
   - Use lighter alternatives
   - Cost: Development time

3. Increase swap (temporary, not permanent solution)
   - Cost: Disk space
   - Impact: Temporary relief only
   - Warning: Can cause thrashing

4. Reduce cache/buffer pressure
   - Tune kernel parameters
   - Cost: Possible performance impact
```

### For Disk Issues

```
Problem: Disk full, slow I/O, or both

For disk full:
1. Find large files: du -sh /, find -size +100M
2. Delete/compress old logs
3. Move data to another partition
4. Add more storage

For slow I/O:
1. Check %util: iostat -x
2. If %util high: Get faster disk or reduce load
3. If %util low but slow: Optimization opportunity
   - Reduce number of operations
   - Batch operations
   - Use caching
```

---

## Summary

**Key Takeaways:**

1. **Virtual memory** abstracts RAM and disk as one memory space
2. **Memory pressure** causes paging, dramatically slowing system
3. **Working set** determines if system runs fast or slow
4. **Disk space** has two limits: bytes and inodes
5. **I/O performance** degrades under heavy concurrent load
6. **Monitoring** is prerequisite to optimization
7. **Bottleneck analysis** finds what actually constrains performance
8. **Prevention** is better than crisis response

---

*Memory and Disk Management: Conceptual Foundations*
*Understanding the "why" enables diagnosing and fixing the "what"*
