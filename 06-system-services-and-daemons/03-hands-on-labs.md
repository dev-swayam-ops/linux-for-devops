# System Services and Daemons: Hands-On Labs

8 progressive labs covering service management from basics to advanced topics. All labs use safe test environments.

---

## Lab 1: Explore Existing Services and Basic Control

**Duration**: 25 minutes
**Difficulty**: Beginner
**Objective**: Understand service ecosystem and basic systemctl commands

### Setup

```bash
# Create working directory
mkdir -p ~/service-labs
cd ~/service-labs

# Verify systemd is installed
systemctl --version
systemd 247.3-7+deb11u2
```

### Hands-On Steps

**Step 1: List and examine system services**
```bash
# List all services
systemctl list-units --type=service

# Count them
systemctl list-units --type=service | wc -l

# Find running services
systemctl list-units --type=service --state=running

# Find failed services
systemctl list-units --type=service --failed

# Find enabled services (will start at boot)
systemctl list-unit-files --type=service --state=enabled | head -20

# Find disabled services
systemctl list-unit-files --type=service --state=disabled | head -20
```

**Step 2: Examine specific running services**
```bash
# Check common services
systemctl status ssh
systemctl status networking
systemctl status systemd-resolved

# Check what you see:
# - loaded: Service file location
# - Active: Current state
# - Process ID (PID)
# - Recent log entries
```

**Step 3: Query service properties**
```bash
# Show a specific property
systemctl show -p MainPID ssh

# Show multiple properties
systemctl show -p MainPID,ExecStart,Restart ssh

# Get all properties
systemctl show ssh

# Check if enabled at boot
systemctl is-enabled ssh
# enabled

# Check if active now
systemctl is-active ssh
# active

# See all enabled services at boot
systemctl list-unit-files | grep enabled | wc -l
```

**Step 4: View service configuration files**
```bash
# Show service file contents
systemctl cat ssh

# Output shows:
# [Unit] - metadata
# [Service] - how to run it
# [Install] - boot behavior

# Show just the file path
grep -o '# /.*' <<< "$(systemctl cat ssh)" | head -1

# Check service file directory
ls -la /lib/systemd/system/ | grep '\.service$' | head -10

# Check local overrides
ls -la /etc/systemd/system/ | grep '\.service$'
```

**Step 5: Service state exploration**
```bash
# Create test case - stop a service temporarily
sudo systemctl stop ssh

# Verify it stopped
systemctl is-active ssh
# inactive

# Check status
sudo systemctl status ssh | head -10

# Restart it
sudo systemctl start ssh

# Verify restarted
systemctl is-active ssh
# active
```

### Verification

```bash
# You should be able to:
systemctl list-units --type=service | grep -q running && echo "✓ Can list services"
systemctl is-active ssh | grep -q active && echo "✓ Can check status"
[ -f /lib/systemd/system/ssh.service ] && echo "✓ Found service file"
```

### Cleanup

```bash
# No special cleanup needed - services still running
echo "Lab 1 complete"
```

---

## Lab 2: Understand Unit Files and Directives

**Duration**: 20 minutes
**Difficulty**: Beginner
**Objective**: Learn to read and understand systemd unit files

### Setup

```bash
# Continue in ~/service-labs
cd ~/service-labs

# Create analysis file
touch service-analysis.txt
```

### Hands-On Steps

**Step 1: Analyze a simple service file**
```bash
# Choose a simple service
systemctl cat ssh > ssh-service.txt
cat ssh-service.txt

# Identify sections
grep "^\[" ssh-service.txt
# [Unit]
# [Service]
# [Install]
```

**Step 2: Examine [Unit] section**
```bash
# Extract Unit section
sed -n '/^\[Unit\]/,/^\[.*\]/p' ssh-service.txt | head -20

# Look for:
# - Description: Human-readable name
# - Documentation: URL to docs
# - After: What must start first
# - Requires: Hard dependency
# - Wants: Soft dependency
```

**Step 3: Examine [Service] section**
```bash
# Extract Service section
sed -n '/^\[Service\]/,/^\[.*\]/p' ssh-service.txt

# Key directives to understand:
# - Type=: How daemon runs (simple, forking, oneshot, notify)
# - User/Group: User to run as
# - ExecStart: Command to start service
# - Restart: When to restart (on-failure, always, no)
# - RestartSec: Seconds between restarts
```

**Step 4: Examine [Install] section**
```bash
# Extract Install section
sed -n '/^\[Install\]/,$p' ssh-service.txt

# WantedBy: What target includes this service
# When enabled, creates symlink in that target
```

**Step 5: Compare multiple services**
```bash
# Compare different service types
echo "=== Apache2 ===" >> service-analysis.txt
systemctl cat apache2 | grep -E "^(Type|ExecStart|Restart)" >> service-analysis.txt 2>/dev/null

echo "" >> service-analysis.txt
echo "=== MySQL ===" >> service-analysis.txt
systemctl cat mysql | grep -E "^(Type|ExecStart|Restart)" >> service-analysis.txt 2>/dev/null

echo "" >> service-analysis.txt
echo "=== SSH ===" >> service-analysis.txt
systemctl cat ssh | grep -E "^(Type|ExecStart|Restart)" >> service-analysis.txt 2>/dev/null

cat service-analysis.txt
```

**Step 6: Check service dependencies**
```bash
# View dependencies for a service
systemctl list-dependencies ssh

# See what requires network
systemctl list-dependencies network.target

# Reverse - what depends on this
systemctl list-dependencies --reverse network.target
```

### Verification

```bash
[ -f ssh-service.txt ] && echo "✓ Analyzed SSH service file"
grep -q "^\[Unit\]" ssh-service.txt && echo "✓ Identified Unit section"
grep -q "Type=" ssh-service.txt && echo "✓ Found Type directive"
```

### Cleanup

```bash
rm -f ssh-service.txt service-analysis.txt
```

---

## Lab 3: Create a Custom Test Service

**Duration**: 30 minutes
**Difficulty**: Intermediate
**Objective**: Create and manage a custom systemd service

### Setup

```bash
# Create test application
mkdir -p ~/service-labs/myapp
cd ~/service-labs/myapp

# Create simple test script
cat > myapp.sh << 'EOF'
#!/bin/bash
# Simple test application

PID_FILE="/var/run/myapp.pid"
LOG_FILE="/var/log/myapp.log"

echo $$ > "$PID_FILE"

while true; do
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] myapp is running..." >> "$LOG_FILE"
  sleep 5
done
EOF

chmod +x myapp.sh
```

### Hands-On Steps

**Step 1: Create service file**
```bash
# Create systemd service file
sudo tee /etc/systemd/system/myapp.service > /dev/null << 'EOF'
[Unit]
Description=My Test Application Service
Documentation=https://example.com/docs
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/$(whoami)/service-labs/myapp
ExecStart=/home/$(whoami)/service-labs/myapp/myapp.sh
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Fix path in file (replace $whoami with actual username)
MYUSER=$(whoami)
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/myapp.service
```

**Step 2: Reload systemd**
```bash
# Tell systemd about new service
sudo systemctl daemon-reload

# Verify it's recognized
systemctl cat myapp

# Check syntax
sudo systemd-analyze verify /etc/systemd/system/myapp.service
```

**Step 3: Start and verify service**
```bash
# Start the service
sudo systemctl start myapp

# Check status
sudo systemctl status myapp

# Verify it's running
systemctl is-active myapp

# Get process info
ps aux | grep myapp | grep -v grep

# Check logs
sudo journalctl -u myapp -n 10
```

**Step 4: Test enable/disable**
```bash
# Check if enabled
systemctl is-enabled myapp
# disabled

# Enable it for boot
sudo systemctl enable myapp

# Verify enabled
systemctl is-enabled myapp
# enabled

# Check symlink was created
ls -la /etc/systemd/system/multi-user.target.wants/myapp.service
```

**Step 5: Test restart behavior**
```bash
# Kill the process
sudo killall myapp

# Wait a moment
sleep 3

# Check status - should auto-restart due to "Restart=on-failure"
sudo systemctl status myapp

# Verify it restarted
ps aux | grep myapp | grep -v grep
```

**Step 6: Test service stop**
```bash
# Stop the service
sudo systemctl stop myapp

# Verify stopped
systemctl is-active myapp
# inactive

# Check logs for stop message
sudo journalctl -u myapp --no-pager | tail -5
```

### Verification

```bash
# Service file exists
[ -f /etc/systemd/system/myapp.service ] && echo "✓ Service file created"

# Service recognized by systemd
systemctl cat myapp > /dev/null 2>&1 && echo "✓ Service recognized"

# Can start/stop
sudo systemctl start myapp && echo "✓ Service starts"
sudo systemctl stop myapp && echo "✓ Service stops"
```

### Cleanup

```bash
# Disable service
sudo systemctl disable myapp

# Stop if running
sudo systemctl stop myapp

# Remove service file
sudo rm /etc/systemd/system/myapp.service

# Reload systemd
sudo systemctl daemon-reload

# Cleanup app directory
rm -rf ~/service-labs/myapp
```

---

## Lab 4: Service Dependencies and Ordering

**Duration**: 25 minutes
**Difficulty**: Intermediate
**Objective**: Understand and create dependent services

### Setup

```bash
# Create dependencies test structure
mkdir -p ~/service-labs/dependencies
cd ~/service-labs/dependencies

# Create "database" service (mock)
mkdir -p database
cat > database/service.sh << 'EOF'
#!/bin/bash
echo "Database started" >> /tmp/service-order.log
sleep 300
EOF

chmod +x database/service.sh

# Create "app" service (mock)
mkdir -p app
cat > app/service.sh << 'EOF'
#!/bin/bash
echo "App started" >> /tmp/service-order.log
sleep 300
EOF

chmod +x app/service.sh
```

### Hands-On Steps

**Step 1: Create dependent services**
```bash
# Create database service
sudo tee /etc/systemd/system/test-database.service > /dev/null << 'EOF'
[Unit]
Description=Test Database Service
After=network.target

[Service]
Type=simple
ExecStart=/home/$(whoami)/service-labs/dependencies/database/service.sh
Restart=on-failure
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Create app service that depends on database
sudo tee /etc/systemd/system/test-app.service > /dev/null << 'EOF'
[Unit]
Description=Test Application Service
After=test-database.service
Requires=test-database.service

[Service]
Type=simple
ExecStart=/home/$(whoami)/service-labs/dependencies/app/service.sh
Restart=on-failure
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Fix paths
MYUSER=$(whoami)
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/test-database.service
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/test-app.service
```

**Step 2: Reload and verify configuration**
```bash
sudo systemctl daemon-reload

# Verify both services
systemctl cat test-database
systemctl cat test-app

# Check syntax
sudo systemd-analyze verify /etc/systemd/system/test-database.service
sudo systemd-analyze verify /etc/systemd/system/test-app.service
```

**Step 3: Test dependency resolution**
```bash
# View dependencies
systemctl list-dependencies test-app
# test-app.service
# └─ test-database.service

# View reverse dependencies
systemctl list-dependencies --reverse test-database
# test-database.service
# └─ test-app.service
```

**Step 4: Test startup order**
```bash
# Clear order log
sudo rm -f /tmp/service-order.log
sudo touch /tmp/service-order.log

# Start the dependent service
sudo systemctl start test-app

# Wait a moment for both to start
sleep 2

# Check which started first
cat /tmp/service-order.log

# Verify both are running
sudo systemctl status test-database
sudo systemctl status test-app
```

**Step 5: Test dependency failure**
```bash
# Stop database
sudo systemctl stop test-database

# Try to start app (should also stop due to Requires=)
sudo systemctl status test-app
# Should show it's inactive because required service isn't running

# Start database, then app
sudo systemctl start test-database
sleep 1
sudo systemctl start test-app

# Both should be running
sudo systemctl status test-database
sudo systemctl status test-app
```

### Verification

```bash
# Services created
[ -f /etc/systemd/system/test-database.service ] && echo "✓ Database service created"
[ -f /etc/systemd/system/test-app.service ] && echo "✓ App service created"

# Dependency recognized
systemctl list-dependencies test-app | grep -q test-database && echo "✓ Dependency recognized"
```

### Cleanup

```bash
# Stop services
sudo systemctl stop test-app test-database

# Remove service files
sudo rm /etc/systemd/system/test-app.service /etc/systemd/system/test-database.service

# Reload systemd
sudo systemctl daemon-reload

# Remove test files
rm -rf ~/service-labs/dependencies /tmp/service-order.log
```

---

## Lab 5: Debug Failed Services

**Duration**: 30 minutes
**Difficulty**: Intermediate
**Objective**: Diagnose and fix service startup failures

### Setup

```bash
mkdir -p ~/service-labs/debug
cd ~/service-labs/debug

# Create broken service script
cat > broken.sh << 'EOF'
#!/bin/bash
# This script has intentional issues

echo "Starting broken service..."
exit 1  # Exit with error
EOF

chmod +x broken.sh

# Create fixed service script
cat > fixed.sh << 'EOF'
#!/bin/bash
echo "Fixed service running"
sleep 300
EOF

chmod +x fixed.sh
```

### Hands-On Steps

**Step 1: Create broken service**
```bash
# Create service that will fail
sudo tee /etc/systemd/system/test-broken.service > /dev/null << 'EOF'
[Unit]
Description=Broken Test Service
After=network.target

[Service]
Type=simple
ExecStart=/home/$(whoami)/service-labs/debug/broken.sh
Restart=no
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

MYUSER=$(whoami)
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/test-broken.service

sudo systemctl daemon-reload
```

**Step 2: Trigger the failure**
```bash
# Try to start
sudo systemctl start test-broken

# Check status - should show failed
sudo systemctl status test-broken

# Show detailed error
sudo systemctl status test-broken -l

# Expected output will show exit code and why it failed
```

**Step 3: Use journalctl to investigate**
```bash
# View logs for failed service
sudo journalctl -u test-broken -n 20

# Get most recent error
sudo journalctl -u test-broken --no-pager | tail -10

# Show with timestamps
sudo journalctl -u test-broken -o short

# Show full message details
sudo journalctl -u test-broken -o verbose
```

**Step 4: Check service configuration for errors**
```bash
# Show full service configuration
systemctl cat test-broken

# Verify syntax
sudo systemd-analyze verify /etc/systemd/system/test-broken.service

# Extract specific directives
grep "ExecStart=" /etc/systemd/system/test-broken.service

# Test the ExecStart command manually
/home/$(whoami)/service-labs/debug/broken.sh
echo $?  # Should show 1 (failure)
```

**Step 5: Fix the service**
```bash
# Update to use working script
sudo sed -i 's|broken.sh|fixed.sh|' /etc/systemd/system/test-broken.service

# Or edit directly
sudo systemctl edit --full test-broken

# Verify change
systemctl cat test-broken | grep ExecStart

# Reload systemd
sudo systemctl daemon-reload

# Test the ExecStart command
/home/$(whoami)/service-labs/debug/fixed.sh &
sleep 1
jobs -l
kill %1 2>/dev/null

# Try to start service again
sudo systemctl start test-broken

# Check status - should be active now
sudo systemctl status test-broken

# Verify in logs
sudo journalctl -u test-broken -n 5
```

**Step 6: Analyze startup issues diagnostically**
```bash
# Check if dependencies are met
systemctl list-dependencies test-broken

# Check if PreExec would fail
systemctl cat test-broken | grep "Exec"

# Check permissions of script file
ls -la ~/service-labs/debug/fixed.sh

# Check user/group
systemctl show -p User,Group test-broken

# Manually run command as service user
sudo -u root /home/$(whoami)/service-labs/debug/fixed.sh

# Check return codes
echo $?
```

### Verification

```bash
# Service file exists and is syntactically valid
sudo systemd-analyze verify /etc/systemd/system/test-broken.service && \
  echo "✓ Service syntax valid"

# Service can start
sudo systemctl start test-broken && echo "✓ Service starts successfully"

# Service is running
systemctl is-active test-broken | grep -q active && echo "✓ Service is active"
```

### Cleanup

```bash
# Stop service
sudo systemctl stop test-broken

# Remove service file
sudo rm /etc/systemd/system/test-broken.service

# Reload systemd
sudo systemctl daemon-reload

# Remove test directory
rm -rf ~/service-labs/debug
```

---

## Lab 6: Resource Limits and Cgroups

**Duration**: 25 minutes
**Difficulty**: Intermediate
**Objective**: Limit service resource consumption

### Setup

```bash
mkdir -p ~/service-labs/limits
cd ~/service-labs/limits

# Create resource-heavy test script
cat > heavy.sh << 'EOF'
#!/bin/bash
# Resource consumer

# Try to use lots of memory
data=""
for i in {1..100}; do
  data+=$(seq 1 100000 | tr '\n' 'x')
  echo "Allocated chunk $i"
  sleep 1
done

sleep 300
EOF

chmod +x heavy.sh
```

### Hands-On Steps

**Step 1: Create unlimited service**
```bash
# Service without resource limits
sudo tee /etc/systemd/system/test-unlimited.service > /dev/null << 'EOF'
[Unit]
Description=Unlimited Resource Test Service
After=network.target

[Service]
Type=simple
ExecStart=/home/$(whoami)/service-labs/limits/heavy.sh
Restart=on-failure
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

MYUSER=$(whoami)
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/test-unlimited.service

sudo systemctl daemon-reload
```

**Step 2: Create limited service**
```bash
# Service with resource limits
sudo tee /etc/systemd/system/test-limited.service > /dev/null << 'EOF'
[Unit]
Description=Limited Resource Test Service
After=network.target

[Service]
Type=simple
ExecStart=/home/$(whoami)/service-labs/limits/heavy.sh
Restart=on-failure
StandardOutput=journal

# Resource limits
MemoryLimit=50M
TasksMax=10
CPUQuota=25%

[Install]
WantedBy=multi-user.target
EOF

MYUSER=$(whoami)
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/test-limited.service

sudo systemctl daemon-reload
```

**Step 3: Verify limits are configured**
```bash
# Show unlimited service configuration
systemctl cat test-unlimited | grep -E "^(Memory|Tasks|CPU)"

# Show limited service configuration
systemctl cat test-limited | grep -E "^(Memory|Tasks|CPU)"

# Extract just the limits
systemctl show test-limited -p MemoryLimit,TasksMax,CPUQuota
```

**Step 4: Check cgroup configuration**
```bash
# Start the limited service
sudo systemctl start test-limited

# Get PID
PID=$(systemctl show -p MainPID test-limited | cut -d= -f2)
echo "Service PID: $PID"

# Check cgroup
cat /proc/$PID/cgroup | head -5

# Check memory limit
cat /sys/fs/cgroup/memory/system.slice/test-limited.service/memory.limit_in_bytes

# Check actual memory used
cat /sys/fs/cgroup/memory/system.slice/test-limited.service/memory.usage_in_bytes | awk '{print $1/1024/1024 " MB"}'
```

**Step 5: Monitor resource usage**
```bash
# Watch memory usage over time
watch -n 1 'systemctl show test-limited -p MemoryCurrent'

# Or using ps
watch -n 1 'ps aux | grep test-limited | grep -v grep'

# Check if OOM killer activated
dmesg | tail -20 | grep -i "out of memory"
```

**Step 6: Compare resource usage**
```bash
# Start unlimited version
sudo systemctl start test-unlimited

sleep 5

# Check both
echo "=== Unlimited Service ==="
ps aux | grep test-unlimited | grep -v grep

echo ""
echo "=== Limited Service ==="
ps aux | grep test-limited | grep -v grep

# Get memory difference
echo ""
echo "=== Memory Check ==="
systemctl show test-unlimited -p MemoryCurrent
systemctl show test-limited -p MemoryCurrent
```

### Verification

```bash
# Service file has limits
grep -q "MemoryLimit" /etc/systemd/system/test-limited.service && \
  echo "✓ Memory limit configured"

grep -q "TasksMax" /etc/systemd/system/test-limited.service && \
  echo "✓ Tasks limit configured"

grep -q "CPUQuota" /etc/systemd/system/test-limited.service && \
  echo "✓ CPU limit configured"
```

### Cleanup

```bash
# Stop both services
sudo systemctl stop test-unlimited test-limited

# Remove service files
sudo rm /etc/systemd/system/test-unlimited.service \
        /etc/systemd/system/test-limited.service

# Reload systemd
sudo systemctl daemon-reload

# Remove test directory
rm -rf ~/service-labs/limits
```

---

## Lab 7: View Service Logs with Journalctl

**Duration**: 20 minutes
**Difficulty**: Beginner
**Objective**: Master journalctl for service troubleshooting

### Setup

```bash
mkdir -p ~/service-labs/logging
cd ~/service-labs/logging
```

### Hands-On Steps

**Step 1: Explore journal storage**
```bash
# Check journal size
sudo journalctl --disk-usage

# Find where journals are stored
ls -lah /var/log/journal/

# Check journal statistics
sudo journalctl --stat

# Get oldest entry
sudo journalctl -o short --reverse | head -3

# Get newest entry
sudo journalctl -o short | tail -3
```

**Step 2: Query logs by service**
```bash
# Last 20 SSH logs
sudo journalctl -u ssh -n 20

# All SSH logs from today
sudo journalctl -u ssh --since today

# SSH logs with full details
sudo journalctl -u ssh -o verbose | head -30

# SSH logs in JSON format
sudo journalctl -u ssh -o json | head -c 500

# Multiple services at once
sudo journalctl -u ssh -u networking -n 10
```

**Step 3: Filter by priority**
```bash
# Errors and above
sudo journalctl -p err

# Only warnings
sudo journalctl -p warning

# Debug level for a service
sudo journalctl -u nginx -p debug

# Info through error (range)
sudo journalctl -p info..err
```

**Step 4: Time-based queries**
```bash
# Since time
sudo journalctl -u ssh --since "1 hour ago"

# Since date
sudo journalctl -u ssh --since "2024-01-15"

# Date range
sudo journalctl -u ssh --since "2024-01-15 10:00" --until "2024-01-15 11:00"

# Since last boot
sudo journalctl -u ssh -b

# Previous boot
sudo journalctl -u ssh -b -1
```

**Step 5: Advanced filtering**
```bash
# Show with no paging
sudo journalctl -u ssh --no-pager | head -20

# Reverse order (newest first)
sudo journalctl -u ssh -r -n 10

# Follow in real-time
sudo journalctl -u ssh -f

# Search for keyword
sudo journalctl -u ssh -G "connection refused"

# Multiple grep conditions
sudo journalctl -u ssh | grep -i "error\|failed"
```

**Step 6: Export and analyze**
```bash
# Export to text file
sudo journalctl -u ssh --since today --no-pager > ssh-logs.txt

# Export to JSON
sudo journalctl -u ssh --since today -o json > ssh-logs.json

# Count log entries by service
sudo journalctl --since today | grep -oP 'systemd\[1\]: Started \K[^/]*' | sort | uniq -c

# Find failed services
sudo journalctl | grep -i "failed\|error" | tail -10
```

### Verification

```bash
# Can query logs
sudo journalctl -u ssh -n 1 > /dev/null && echo "✓ Can query logs"

# Can export logs
sudo journalctl -u ssh -n 10 --no-pager > test.log && [ -s test.log ] && echo "✓ Can export logs"

# Can filter by time
sudo journalctl --since "1 hour ago" | grep -q . && echo "✓ Can filter by time"

rm -f test.log
```

### Cleanup

```bash
# No special cleanup - just exercise complete
```

---

## Lab 8: Create and Manage Service Timers

**Duration**: 25 minutes
**Difficulty**: Intermediate
**Objective**: Use systemd timers as cron alternative

### Setup

```bash
mkdir -p ~/service-labs/timers
cd ~/service-labs/timers

# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
echo "Backup started at $(date)" >> /tmp/backup.log
sleep 5
echo "Backup completed at $(date)" >> /tmp/backup.log
EOF

chmod +x backup.sh

# Clear log
rm -f /tmp/backup.log
```

### Hands-On Steps

**Step 1: Create service and timer units**
```bash
# Create service (the actual work)
sudo tee /etc/systemd/system/backup.service > /dev/null << 'EOF'
[Unit]
Description=Backup Service
After=network.target

[Service]
Type=oneshot
User=root
ExecStart=/home/$(whoami)/service-labs/timers/backup.sh
StandardOutput=journal

[Install]
WantedBy=timers.target
EOF

# Create timer (the scheduler)
sudo tee /etc/systemd/system/backup.timer > /dev/null << 'EOF'
[Unit]
Description=Backup Timer
Requires=backup.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

MYUSER=$(whoami)
sudo sed -i "s|\$(whoami)|$MYUSER|g" /etc/systemd/system/backup.service

sudo systemctl daemon-reload
```

**Step 2: Enable and start timer**
```bash
# Enable timer
sudo systemctl enable backup.timer

# Start timer
sudo systemctl start backup.timer

# Verify timer is running
systemctl list-timers backup.timer

# Check status
sudo systemctl status backup.timer
```

**Step 3: Run service manually**
```bash
# Run the backup service immediately
sudo systemctl start backup.service

# Wait for completion
sleep 6

# Check logs
cat /tmp/backup.log

# Should show two entries (one from now, plus from scheduled run)
```

**Step 4: Check timer and service relationship**
```bash
# Show timer configuration
systemctl cat backup.timer

# Show service configuration
systemctl cat backup.service

# View dependencies
systemctl list-dependencies backup.timer

# Check what triggers the service
systemctl show backup.timer -p Triggers
```

**Step 5: View active timers**
```bash
# List all active timers
systemctl list-timers

# Show details for our timer
systemctl list-timers backup.timer

# Get next scheduled run time
systemctl list-timers backup.timer --all
```

**Step 6: Advanced timer options**
```bash
# Create daily timer (midnight)
sudo tee /etc/systemd/system/daily-check.timer > /dev/null << 'EOF'
[Unit]
Description=Daily Check Timer

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# View timer unit time specifications
man 7 systemd.time | head -50

# Load new timer
sudo systemctl daemon-reload

# Show the daily timer
systemctl cat daily-check.timer
```

### Verification

```bash
# Timer file exists
[ -f /etc/systemd/system/backup.timer ] && echo "✓ Timer created"

# Timer is running
systemctl is-active backup.timer | grep -q active && echo "✓ Timer active"

# Service exists
[ -f /etc/systemd/system/backup.service ] && echo "✓ Service created"

# Logs recorded
[ -f /tmp/backup.log ] && echo "✓ Backup executed"
```

### Cleanup

```bash
# Stop timer
sudo systemctl stop backup.timer

# Disable timer
sudo systemctl disable backup.timer

# Remove timer and service files
sudo rm /etc/systemd/system/backup.timer \
        /etc/systemd/system/backup.service \
        /etc/systemd/system/daily-check.timer

# Reload systemd
sudo systemctl daemon-reload

# Remove test directory and logs
rm -rf ~/service-labs/timers /tmp/backup.log
```

---

## Lab Summary

| Lab # | Topic | Time | Difficulty | Skills |
|-------|-------|------|------------|--------|
| 1 | Explore services | 25 min | Beginner | List, status, query |
| 2 | Understand units | 20 min | Beginner | Read config, understand directives |
| 3 | Create service | 30 min | Intermediate | Write service file, manage lifecycle |
| 4 | Dependencies | 25 min | Intermediate | Requires, After, ordering |
| 5 | Debug failures | 30 min | Intermediate | Logs, systemd-analyze, troubleshoot |
| 6 | Resource limits | 25 min | Intermediate | cgroups, MemoryLimit, CPUQuota |
| 7 | Journalctl | 20 min | Beginner | Query logs, filtering, export |
| 8 | Timers | 25 min | Intermediate | Create timers, schedule tasks |

**Total Time**: 200 minutes (3.3 hours)

---

*System Services and Daemons: Hands-On Labs*  
*Complete all labs to master systemd service management*
