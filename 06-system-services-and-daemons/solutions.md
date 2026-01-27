# System Services and Daemons: Solutions

## Exercise 1: List and Examine Services

**Solution:**

```bash
# List all loaded services
systemctl list-units --type=service
# Output shows: loaded, active, inactive services

# Count total running services
systemctl list-units --type=service --state=running | wc -l

# Count all loaded services
systemctl list-unit-files --type=service | wc -l

# List only active services
systemctl list-units --type=service --state=active

# List failed services
systemctl list-units --type=service --state=failed
# Output:
#   UNIT                LOAD   ACTIVE SUB    DESCRIPTION
#   my-service.service  loaded failed failed My Service

# Find specific service
systemctl list-unit-files | grep ssh
# Output: ssh.service enabled
```

**Explanation:** `systemctl list-units` shows loaded units. `list-unit-files` shows all available units.

---

## Exercise 2: Service Status Investigation

**Solution:**

```bash
# Check SSH service status
systemctl status ssh
# Output:
# ● ssh.service - OpenBSD Secure Shell server
#      Loaded: loaded (/etc/systemd/system/ssh.service; enabled)
#      Active: active (running) since Tue 2026-01-27 10:00:00 UTC
#      Process: 1234 ExecStart=/usr/sbin/sshd -D
#   Main PID: 1234 (sshd)

# Check if active
systemctl is-active ssh
# Output: active

# Check if inactive
systemctl is-active invalid-service
# Output: inactive

# Get PID
systemctl status ssh | grep "Main PID"
# Output: Main PID: 1234 (sshd)

# Check start time
systemctl status ssh | grep "since"
```

**Explanation:** `status` shows complete information. `is-active` returns only active/inactive.

---

## Exercise 3: Start and Stop Services

**Solution:**

```bash
# Start Apache service (example)
sudo systemctl start apache2
# No output = success

# Verify running
systemctl status apache2
# Output: Active: active (running)

# Stop service
sudo systemctl stop apache2

# Verify stopped
systemctl status apache2
# Output: Active: inactive (dead)

# Restart service
sudo systemctl restart apache2

# Verify running again
systemctl status apache2 | grep Active
# Output: Active: active (running) since ...
```

**Explanation:** Commands require `sudo`. `restart` stops then starts. `reload` is gentler.

---

## Exercise 4: Enable and Disable Services

**Solution:**

```bash
# Check if enabled
systemctl is-enabled ssh
# Output: enabled

# Enable at boot
sudo systemctl enable ssh
# Output: Created symlink /etc/systemd/system/multi-user.target.wants/ssh.service

# Verify enabled
systemctl is-enabled ssh
# Output: enabled

# Disable at boot
sudo systemctl disable ssh
# Output: Removed /etc/systemd/system/multi-user.target.wants/ssh.service

# Verify disabled
systemctl is-enabled ssh
# Output: disabled

# List enabled services
systemctl list-unit-files --state=enabled | head -10
```

**Explanation:** Enable creates symlink in target directory. Disable removes it.

---

## Exercise 5: View and Analyze Service Logs

**Solution:**

```bash
# View recent logs
journalctl -u ssh
# Shows all ssh service logs

# Last 20 lines
journalctl -u ssh -n 20
# Output shows recent 20 entries

# Follow in real-time (5 seconds)
journalctl -u ssh -f &
# Output: scrolls as new entries appear
sleep 5 && kill %1

# Show since last boot
journalctl -u ssh -b

# Show since specific time
journalctl -u ssh --since "2026-01-27 10:00:00"

# Show entries with timestamps
journalctl -u ssh --all

# Example output:
# Jan 27 10:00:00 hostname sshd[1234]: Server listening on 0.0.0.0 port 22.
# Jan 27 10:15:32 hostname sshd[4567]: Accepted publickey for user from 192.168.1.100
```

**Explanation:** `journalctl -u servicename` shows service logs. `-f` follows like `tail -f`.

---

## Exercise 6: Service Dependencies

**Solution:**

```bash
# Show dependencies
systemctl show-dependencies ssh
# Output:
# ssh.service
# ├─ system-getty.slice
# ├─ network-online.target
# └─ system.slice

# Show what depends on SSH
systemctl show-dependencies ssh --reverse

# View unit file with dependencies
systemctl cat ssh
# Shows [Unit] section with Wants/Requires

# Check if service is required elsewhere
grep -r "Requires=ssh" /etc/systemd/system/ 2>/dev/null

# Critical services example:
# - systemd-udevd.service (hardware detection)
# - system-getty.slice (login prompts)
# - network-online.target (network up)
```

**Explanation:** `Requires` = must start. `Wants` = nice to have. `Before/After` = order.

---

## Exercise 7: Examine Unit File

**Solution:**

```bash
# View complete unit file
systemctl cat ssh
# Output:
# [Unit]
# Description=OpenBSD Secure Shell server
# After=network-online.target
# Wants=network-online.target
#
# [Service]
# Type=notify
# EnvironmentFile=-/etc/default/ssh
# ExecStartPre=/usr/sbin/sshd -t
# ExecStart=/usr/sbin/sshd -D
# ExecReload=/bin/kill -HUP $MAINPID
# Restart=on-failure
# RestartSec=5s
#
# [Install]
# WantedBy=multi-user.target
# Alias=sshd.service

# Find unit file location
systemctl show -p FragmentPath ssh
# Output: FragmentPath=/etc/systemd/system/ssh.service

# View raw file
cat /etc/systemd/system/ssh.service

# Check permissions
ls -la /etc/systemd/system/ssh.service
```

**Explanation:**
- `[Unit]` = metadata and dependencies
- `[Service]` = execution details
- `[Install]` = installation/enablement info

---

## Exercise 8: System Targets and Runlevels

**Solution:**

```bash
# Get current target
systemctl get-default
# Output: multi-user.target

# List all targets
systemctl list-units --type=target

# List target files
systemctl list-unit-files --type=target

# Show services in specific target
systemctl list-dependencies multi-user.target

# Switch to graphical target
sudo systemctl set-default graphical.target
# (requires reboot to take effect)

# Check which target wants SSH
grep -l "WantedBy=.*ssh" /etc/systemd/system/* /usr/lib/systemd/system/*

# Common targets:
# - poweroff.target (shutdown)
# - rescue.target (single user, minimal)
# - multi-user.target (CLI, full)
# - graphical.target (GUI, full)
# - reboot.target (restart)
```

**Explanation:** Targets group services. `multi-user` = CLI only. `graphical` = with GUI.

---

## Exercise 9: Service Reload vs Restart

**Solution:**

```bash
# Check if service supports reload
systemctl show ssh -p ExecReload
# Output: ExecReload=/bin/kill -HUP $MAINPID

# Reload service (applies config without restart)
sudo systemctl reload ssh
# Fast, no downtime

# Restart service (full stop/start)
sudo systemctl restart ssh
# Brief downtime

# Verify both work
systemctl status ssh

# Example difference:
# Reload: Reads new config, keeps connections
# Restart: Closes connections, reads new config, rebuilds state

# Some services don't support reload:
systemctl show apache2 -p ExecReload
# If empty, reload not supported
```

**Explanation:** `reload` = graceful config update. `restart` = full cycle. Prefer reload when possible.

---

## Exercise 10: Troubleshooting Failed Services

**Solution:**

```bash
# Check for failed services
systemctl list-units --type=service --state=failed
# Output shows failed services

# Select failed service and view status
systemctl status my-service
# Output:
# my-service.service - My Custom Service
#      Loaded: loaded
#      Active: failed (Result: exit-code) since ...
#      Process: 1234 ExecStart=/path/to/script.sh (code=exited, status=1)

# View detailed logs
journalctl -u my-service -n 50
# Output shows errors and why it failed

# Common failure reasons:
# - ExecStart command doesn't exist
# - Permission denied on executable
# - Configuration file missing
# - Port already in use
# - Dependency not met

# Fix example:
# Edit unit file
sudo nano /etc/systemd/system/my-service.service
# Reload systemd
sudo systemctl daemon-reload
# Try starting again
sudo systemctl start my-service
# Check status
systemctl status my-service
```

**Explanation:** Always check `journalctl` for failure reason. Fix, reload, and retry.
