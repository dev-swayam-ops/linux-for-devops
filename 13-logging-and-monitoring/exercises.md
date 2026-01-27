# Logging and Monitoring: Exercises

Complete these exercises to master log analysis and monitoring.

## Exercise 1: View Journal Entries

**Tasks:**
1. Show last 20 journal entries
2. Show entries from specific service
3. Filter by log level (errors only)
4. Show boot messages
5. Display entry details

**Hint:** Use `journalctl -n`, `journalctl -u`, `-p`, `-b`.

---

## Exercise 2: Filter and Search Logs

**Tasks:**
1. Search for specific string
2. Find SSH authentication failures
3. Look for system errors
4. Search across time range
5. Combine multiple filters

**Hint:** Use `grep`, `journalctl --since/--until`, `journalctl -p`.

---

## Exercise 3: Follow Live Logs

**Tasks:**
1. Follow journal in real-time
2. Generate events and see in real-time
3. Filter while following
4. Stop following with Ctrl+C
5. Understand log latency

**Hint:** Use `journalctl -f`, trigger events (login, service restart).

---

## Exercise 4: View Traditional Log Files

**Tasks:**
1. List /var/log directory contents
2. View syslog file
3. Check auth log for failures
4. View kernel logs
5. Compare formats with journal

**Hint:** Use `tail`, `less`, `grep`, `ls -lh /var/log/`.

---

## Exercise 5: Analyze Boot Sequence Logs

**Tasks:**
1. Show all boot messages
2. Find boot errors
3. Check service startup times
4. Identify slow services
5. Compare multiple boots

**Hint:** Use `journalctl -b`, `journalctl --list-boots`, grep for errors.

---

## Exercise 6: Monitor System Metrics

**Tasks:**
1. Show real-time CPU/memory
2. Check disk I/O stats
3. Monitor process activity
4. Track network connections
5. View system uptime

**Hint:** Use `top`, `htop`, `vmstat`, `uptime`, `ss`.

---

## Exercise 7: Check Log Disk Usage

**Tasks:**
1. Show journal disk usage
2. List log file sizes
3. Identify largest logs
4. Understand retention policy
5. Clean old logs safely

**Hint:** Use `journalctl --disk-usage`, `du -sh /var/log`, `ls -lhS`.

---

## Exercise 8: Enable Persistent Journal

**Tasks:**
1. Check if journal is persistent
2. Create journal directory
3. Restart journald
4. Verify persistence
5. View logs across boots

**Hint:** Check `/var/log/journal/`, `systemctl restart systemd-journald`.

---

## Exercise 9: Monitor Specific Service

**Tasks:**
1. View service logs
2. Follow service in real-time
3. Find service errors
4. Check service startup
5. Monitor over time

**Hint:** Use `journalctl -u service -f`, grep for patterns.

---

## Exercise 10: Create Monitoring Baseline

Create a system monitoring snapshot.

**Tasks:**
1. Document current metrics
2. Log system information
3. Check all services status
4. Monitor for 5 minutes
5. Analyze trends

**Hint:** Combine top, vmstat, journalctl, systemctl.
