# System Services and Daemons: Exercises

Complete these exercises to master systemd service management.

## Exercise 1: List and Examine Services

**Tasks:**
1. List all loaded services
2. Count total services running
3. List only active (running) services
4. List only failed services
5. Find a specific service (e.g., ssh, apache2, mysql)

**Hint:** Use `systemctl list-units --type=service`, `systemctl list-units --type=service --state=failed`.

---

## Exercise 2: Service Status Investigation

**Tasks:**
1. Check status of SSH service
2. Check status of another system service
3. Determine if service is active/inactive
4. Find when service was last started
5. Check service process ID (PID)

**Hint:** Use `systemctl status servicename`, `systemctl is-active servicename`.

---

## Exercise 3: Start and Stop Services

**Tasks:**
1. Start a service using systemctl
2. Verify it's running
3. Stop the service
4. Verify it's stopped
5. Restart it again

**Note:** Use a safe service (not SSH if remote). Example: apache2, mysql, or create dummy service.

**Hint:** Use `systemctl start/stop/restart`, then `systemctl status`.

---

## Exercise 4: Enable and Disable Services

**Tasks:**
1. Check if a service is enabled at boot
2. Enable a service for automatic startup
3. Verify it's enabled
4. Disable the service
5. Confirm it's disabled
6. Document the enable/disable status

**Hint:** Use `systemctl is-enabled`, `systemctl enable`, `systemctl disable`.

---

## Exercise 5: View and Analyze Service Logs

**Tasks:**
1. View logs for a specific service
2. Show last 20 lines of logs
3. Follow logs in real-time (5 seconds)
4. Filter logs for ERROR level
5. Find when service last started/stopped

**Hint:** Use `journalctl -u servicename`, `journalctl -u servicename -n 20`, `journalctl -u servicename -f`.

---

## Exercise 6: Service Dependencies

**Tasks:**
1. Show dependencies for SSH service
2. List services that must start before another
3. Identify critical services the system needs
4. Understand "wants" vs "requires" relationships
5. Draw or document dependency chain

**Hint:** Use `systemctl show-dependencies servicename`, `systemctl cat servicename`.

---

## Exercise 7: Examine Unit File

**Tasks:**
1. View SSH service unit file
2. Understand each section: [Unit], [Service], [Install]
3. Identify ExecStart command
4. Find restart policy
5. Check permissions and ownership

**Hint:** Use `systemctl cat servicename` or `cat /etc/systemd/system/servicename.service`.

---

## Exercise 8: System Targets and Runlevels

**Tasks:**
1. Check current target (runlevel)
2. List all available targets
3. Understand multi-user.target vs graphical.target
4. View services needed for current target
5. Check which target includes SSH

**Hint:** Use `systemctl get-default`, `systemctl list-units --type=target`.

---

## Exercise 9: Service Reload vs Restart

**Tasks:**
1. Start a service that supports reload
2. Modify its configuration file
3. Reload the service (without interruption)
4. Verify changes are applied
5. Compare reload vs restart behavior

**Hint:** Not all services support reload. Use `systemctl reload servicename`.

---

## Exercise 10: Troubleshooting Failed Services

Create a failed service and diagnose the issue.

**Tasks:**
1. Check if any services are in failed state
2. Select a failed service
3. View its status and logs
4. Identify the failure reason
5. Document findings in report
6. Attempt to fix (if possible)

**Hint:** `systemctl list-units --state=failed`, `journalctl -u servicename`.
