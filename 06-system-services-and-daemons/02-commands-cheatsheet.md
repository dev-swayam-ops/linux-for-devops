# System Services and Daemons: Commands Cheatsheet

Reference for systemd commands and service management patterns.

---

## PART A: SYSTEMCTL - Service Control

### 1. Service Status Commands

**Purpose**: Check current service state

```bash
# Show service status with recent log excerpt
systemctl status nginx
# ● nginx.service - A High Performance Web Server and Reverse Proxy Server
#    Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
#    Active: active (running) since Mon 2024-01-15 10:30:00 UTC; 5 days ago
#    Process: 1234 ExecStart=/usr/sbin/nginx -g daemon on; master_process on;
#   Main PID: 1235 (nginx)
#      Tasks: 5
#     Memory: 12.5M
#      CPU: 2m 30s

# Quick status (running/failed/etc)
systemctl is-active nginx
# active

# Check if enabled at boot
systemctl is-enabled nginx
# enabled

# Check if failed
systemctl is-failed nginx
# inactive (returns error code if failed)

# List all services with status
systemctl list-units --type=service

# List all service files
systemctl list-unit-files --type=service

# Show enabled services only
systemctl list-unit-files --type=service --state=enabled

# Show failed services
systemctl list-units --type=service --failed

# Get very quick status
systemctl --no-pager status nginx | head -10

# Check multiple services at once
systemctl status nginx mysql postgresql

# See what services depend on this one
systemctl list-dependencies --reverse nginx
```

### 2. Starting and Stopping Services

**Purpose**: Control service runtime state

```bash
# Start a service
sudo systemctl start nginx

# Stop a service
sudo systemctl stop nginx

# Restart (stop then start)
sudo systemctl restart nginx

# Reload configuration without restart
sudo systemctl reload nginx
# Service keeps running, reloads config file

# Reload or restart if reload not available
sudo systemctl reload-or-restart nginx

# Restart with signal (e.g., SIGHUP)
sudo systemctl kill -s HUP nginx

# Isolate service (stop all others and run this)
sudo systemctl isolate multi-user.target

# Stop all services
sudo systemctl stop '*.service'
```

### 3. Enabling and Disabling Services

**Purpose**: Control startup behavior

```bash
# Enable service to start at boot
sudo systemctl enable nginx

# Disable from autostarting
sudo systemctl disable nginx

# Enable and start immediately
sudo systemctl enable --now nginx

# Disable and stop immediately
sudo systemctl disable --now nginx

# Check enabled status
systemctl is-enabled nginx
# enabled

# Reenable after modifying service file
sudo systemctl reenable nginx

# List what's going to start at boot
systemctl list-units --all --state=loaded --type=service

# Check specifically enabled services
systemctl list-unit-files --type=service | grep enabled
```

---

## PART B: CONFIGURATION AND FILES

### 4. View Service Configuration

**Purpose**: Examine service unit files

```bash
# Show complete service file
systemctl cat nginx
# [Unit]
# Description=A High Performance Web Server and Reverse Proxy Server
# After=network-online.target remote-fs.target nss-lookup.target
# Wants=network-online.target

# [Service]
# Type=forking
# PIDFile=/run/nginx.pid
# ExecStartPre=/usr/sbin/nginx -t
# ExecStart=/usr/sbin/nginx -g daemon on; master_process on;
# ExecReload=/bin/kill -s HUP $MAINPID

# [Install]
# WantedBy=multi-user.target

# Show just the [Unit] section
systemctl cat nginx | grep -A 20 "^\[Unit\]"

# Show the file path
systemctl cat --full nginx | head -1

# Edit service file (creates drop-in)
sudo systemctl edit nginx
# Opens editor, changes go to /etc/systemd/system/nginx.service.d/override.conf

# Edit full service file
sudo systemctl edit --full nginx
# Creates full copy in /etc/systemd/system/nginx.service

# Reset customizations
sudo systemctl revert nginx

# List drop-in directories
ls /etc/systemd/system/nginx.service.d/ 2>/dev/null
```

### 5. Daemon Reload and Reapply

**Purpose**: Apply configuration changes

```bash
# Reload systemd unit configuration
sudo systemctl daemon-reload
# Must run after modifying service files

# Reload AND restart all changed services
sudo systemctl daemon-reexec

# Reload all daemon configuration in target
sudo systemctl restart multi-user.target

# Reload specific service config
sudo systemctl daemon-reload
sudo systemctl restart myapp

# Create service file and enable
sudo nano /etc/systemd/system/myapp.service
# ... edit file ...
sudo systemctl daemon-reload
sudo systemctl enable --now myapp
```

---

## PART C: JOURNALCTL - Logging

### 6. View Service Logs

**Purpose**: Query systemd journal logs

```bash
# Last 50 lines of service logs
sudo journalctl -u nginx -n 50

# Follow logs in real-time (like tail -f)
sudo journalctl -u nginx -f

# All nginx logs with full details
sudo journalctl -u nginx

# Last hour of logs
sudo journalctl -u nginx --since "1 hour ago"

# Logs since last boot
sudo journalctl -u nginx --since today

# Logs between times
sudo journalctl -u nginx --since "2024-01-15 10:00:00" --until "2024-01-15 11:00:00"

# Logs from last N lines
sudo journalctl -u nginx --lines 100

# Specific priority (error and above)
sudo journalctl -u nginx -p err

# Multiple priorities
sudo journalctl -u nginx -p debug..err

# Show all syslog messages
sudo journalctl SYSLOG_IDENTIFIER=nginx

# Search for keyword
sudo journalctl -u nginx -G "connection refused"

# Show entire journal
sudo journalctl

# Reverse order (newest first)
sudo journalctl -u nginx -r

# No pagination (all output)
sudo journalctl -u nginx --no-pager

# Show boot messages
sudo journalctl -b
```

### 7. Advanced Logging

**Purpose**: Complex log queries

```bash
# Per-service logs with verbose output
sudo journalctl -u nginx -o verbose

# JSON output for parsing
sudo journalctl -u nginx -o json | jq '.'

# Show where logs are stored
sudo journalctl --disk-usage

# Rotate logs
sudo journalctl --vacuum-size=100M

# Keep last 7 days only
sudo journalctl --vacuum-time=7d

# Show log sources
sudo journalctl --all --catalog

# Combine multiple service logs
sudo journalctl -u nginx -u mysql -u postgres

# Correlate by PID
sudo journalctl _PID=1234

# Show kernel messages (dmesg)
sudo journalctl -k

# Follow multiple services in real-time
sudo journalctl -u nginx -u mysql -f

# Show sessions
sudo journalctl | grep SESSION

# Export to text file
sudo journalctl -u nginx --no-pager > nginx-logs.txt
```

---

## PART D: DEPENDENCY AND ORDERING

### 8. View Dependencies

**Purpose**: Understand service relationships

```bash
# Show services this one requires
systemctl list-dependencies nginx

# Reverse - show what requires this service
systemctl list-dependencies --reverse nginx

# Tree view of dependencies
systemctl list-dependencies --tree nginx

# Show all dependencies recursively
systemctl list-dependencies --all nginx

# Show only direct dependencies
systemctl list-dependencies --no-indent nginx

# Check target dependencies
systemctl list-dependencies multi-user.target

# Show what needs this to boot
systemctl list-dependencies --reverse systemd-resolved

# Pretty print
systemctl list-dependencies nginx --no-pager
```

### 9. Service Ordering

**Purpose**: Check startup order

```bash
# Check what runs before service
grep "^After=" /lib/systemd/system/nginx.service

# Check what runs after
grep "^Before=" /lib/systemd/system/nginx.service

# Manual ordering test
systemctl cat nginx | grep -E "^(After|Before|Requires|Wants)="

# Show boot sequence for target
systemctl list-dependencies --all multi-user.target

# Test if dependency exists
systemctl show -p Requires nginx
systemctl show -p Wants nginx
```

---

## PART E: ANALYSIS AND DEBUGGING

### 10. Systemd Analyze

**Purpose**: Performance and configuration analysis

```bash
# Analyze boot time
systemd-analyze

# Show slowest services during boot
systemd-analyze blame

# Show critical path (services that delayed boot)
systemd-analyze critical-chain

# Visualize boot sequence
systemd-analyze plot > boot.svg

# Verify service file syntax
systemd-analyze verify /etc/systemd/system/myapp.service

# Verify all services
systemd-analyze verify /etc/systemd/system/*.service

# Show unit dependencies
systemd-analyze dump | grep nginx

# Check for circular dependencies
systemd-analyze verify /etc/systemd/system/*.service
```

### 11. Process and Resource Info

**Purpose**: Monitor service processes

```bash
# Show main PID
systemctl show -p MainPID nginx

# Show all processes in service
systemctl show -p ExecMainPID nginx

# Show resource usage by service
systemctl --all --full -o table

# Get memory usage
ps aux | grep nginx | grep -v grep | awk '{print $6}'

# Get CPU usage
ps aux | grep nginx | grep -v grep | awk '{print $3}'

# Monitor service processes
watch 'ps aux | grep nginx'

# Show cgroup for service
cat /proc/1234/cgroup

# Show resource limits
cat /proc/1234/limits
```

### 12. Debugging Failed Services

**Purpose**: Troubleshoot service startup failures

```bash
# Show detailed error
sudo systemctl status myapp -l

# Show recent logs with full details
sudo journalctl -u myapp -n 100 --no-pager

# Check if ExecStart command works
sudo -u appuser /path/to/command

# Dry-run the service start
sudo systemctl start --dry-run myapp

# Enable debug logging
sudo SYSTEMD_LOG_LEVEL=debug systemctl start myapp

# Check environment variables
systemctl show-environment

# Show service environment file
sudo systemctl cat myapp | grep EnvironmentFile

# Manually run PreExec commands
sudo bash -c 'source /etc/sysconfig/myapp; echo $VAR'

# Check dependencies are running
systemctl list-dependencies myapp | grep ✓
```

---

## PART F: COMMON PATTERNS AND WORKFLOWS

### Pattern 1: Quick Service Check

```bash
# One-liner status check
systemctl is-active nginx && echo "Running" || echo "Not running"

# Check multiple services
for service in nginx mysql postgresql; do
  systemctl is-active $service && echo "$service: ✓" || echo "$service: ✗"
done

# Check all and report
systemctl list-units --type=service --all --no-pager | grep -E "active|failed"
```

### Pattern 2: Service Restart with Verification

```bash
# Restart and wait for it to be active
sudo systemctl restart nginx
sleep 2
systemctl is-active nginx && echo "Restart successful" || echo "Restart failed"

# Or with journalctl verification
sudo systemctl restart nginx
sleep 1
sudo journalctl -u nginx -n 5 --no-pager
```

### Pattern 3: Enable Multiple Services

```bash
# Enable several at once
sudo systemctl enable nginx mysql postgresql

# Enable and start several
for service in nginx mysql postgresql; do
  sudo systemctl enable --now $service
done

# Verify all enabled
systemctl list-unit-files | grep -E "nginx|mysql|postgresql"
```

### Pattern 4: Monitor Service Health

```bash
# Continuous monitoring
watch -n 5 'systemctl status nginx'

# Or with multiple services
watch -n 5 'systemctl list-units --type=service --all --no-pager'

# Alert on failure
while true; do
  systemctl is-active nginx || echo "ALERT: nginx failed!"
  sleep 60
done
```

### Pattern 5: Collect Service Diagnostics

```bash
# Comprehensive diagnostics
{
  echo "=== Service Status ==="
  systemctl status myapp
  echo ""
  echo "=== Recent Logs ==="
  sudo journalctl -u myapp -n 20 --no-pager
  echo ""
  echo "=== Processes ==="
  ps aux | grep myapp
  echo ""
  echo "=== Dependencies ==="
  systemctl list-dependencies myapp
} > diagnostics.txt

cat diagnostics.txt
```

### Pattern 6: Test Service File Before Deployment

```bash
# Create/modify service file
sudo nano /etc/systemd/system/newapp.service

# Verify syntax
sudo systemd-analyze verify /etc/systemd/system/newapp.service

# Reload and test
sudo systemctl daemon-reload
sudo systemctl start newapp --dry-run

# Check logs
sudo journalctl -u newapp -n 20

# If OK, enable
sudo systemctl enable newapp
```

---

## PART G: REFERENCE TABLE

| Task | Command |
|------|---------|
| Check status | `systemctl status SERVICE` |
| Start service | `sudo systemctl start SERVICE` |
| Stop service | `sudo systemctl stop SERVICE` |
| Restart | `sudo systemctl restart SERVICE` |
| Reload config | `sudo systemctl reload SERVICE` |
| Enable at boot | `sudo systemctl enable SERVICE` |
| Disable at boot | `sudo systemctl disable SERVICE` |
| Enable + start | `sudo systemctl enable --now SERVICE` |
| View logs | `sudo journalctl -u SERVICE -n 50` |
| Follow logs | `sudo journalctl -u SERVICE -f` |
| List services | `systemctl list-units --type=service` |
| Show config | `systemctl cat SERVICE` |
| Edit config | `sudo systemctl edit SERVICE` |
| Verify syntax | `systemd-analyze verify FILE` |
| Boot analysis | `systemd-analyze blame` |
| View dependencies | `systemctl list-dependencies SERVICE` |
| Is running? | `systemctl is-active SERVICE` |
| Is enabled? | `systemctl is-enabled SERVICE` |
| Reload systemd | `sudo systemctl daemon-reload` |
| Failed services | `systemctl list-units --failed` |

---

*System Services and Daemons: Commands Cheatsheet*  
*Quick reference for essential systemd commands*
