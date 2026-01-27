# Troubleshooting and Scenarios: Exercises

Complete these hands-on scenarios.

## Exercise 1: Service Troubleshooting

**Scenario:** SSH service not responding

**Tasks:**
1. Check service status
2. View service logs
3. Check port listening
4. Verify configuration
5. Restart and test

**Hint:** `systemctl status`, `journalctl -u`, `netstat -tlnp`.

---

## Exercise 2: Port Conflicts

**Scenario:** Application can't bind to port 8080

**Tasks:**
1. Check what's using the port
2. Identify process/service
3. Find process ID
4. View process details
5. Resolve conflict

**Hint:** `lsof -i :8080`, `netstat -tlnp`, `ps aux`.

---

## Exercise 3: Disk Space Crisis

**Scenario:** Filesystem full, application failing

**Tasks:**
1. Find full filesystem
2. Identify large files
3. Find largest directories
4. Check for logs
5. Create space safely

**Hint:** `df -h`, `du -sh`, `find -size`.

---

## Exercise 4: Permission Issues

**Scenario:** User cannot access file/directory

**Tasks:**
1. Check current permissions
2. Identify owner/group
3. Test as different user
4. Find permission issue
5. Fix permissions correctly

**Hint:** `ls -l`, `id`, `chmod`, `chown`.

---

## Exercise 5: Application Crash

**Scenario:** Service crashes on startup

**Tasks:**
1. Check error messages
2. Verify configuration
3. Test configuration syntax
4. Check dependencies
5. Diagnose root cause

**Hint:** `journalctl -xe`, service -t`, `strace`.

---

## Exercise 6: Network Connectivity

**Scenario:** Cannot reach remote service

**Tasks:**
1. Verify destination
2. Test DNS resolution
3. Check network path
4. Verify firewall rules
5. Test connectivity

**Hint:** `ping`, `nslookup`, `traceroute`, `netstat`.

---

## Exercise 7: Memory Leak Investigation

**Scenario:** Application memory grows over time

**Tasks:**
1. Monitor process memory
2. Check memory usage trend
3. Identify process
4. Collect debug info
5. Determine cause

**Hint:** `top`, `ps aux`, `free -h`, `watch`.

---

## Exercise 8: Cron Job Issues

**Scenario:** Scheduled task not running

**Tasks:**
1. Check cron configuration
2. Verify syntax
3. Check logs
4. Test command manually
5. Verify execution

**Hint:** `crontab -l`, `journalctl -xe`, `grep CRON`.

---

## Exercise 9: Performance Degradation

**Scenario:** System running slowly

**Tasks:**
1. Check CPU usage
2. Check memory usage
3. Check disk I/O
4. Identify bottleneck
5. Optimize

**Hint:** `top`, `free`, `iostat`, `sar`.

---

## Exercise 10: Multi-Layer Troubleshooting

Complete end-to-end scenario.

**Tasks:**
1. Service not responding
2. Gather all information
3. Check all layers (OS, network, app)
4. Identify root cause
5. Implement fix

**Hint:** Use all previous exercises.
