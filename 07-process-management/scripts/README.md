# Module 07 - Scripts Documentation

Production-quality bash scripts for process monitoring and analysis.

## Overview

These scripts provide operational tools for monitoring and analyzing processes, complementing the learning materials in the main module.

**Script Purposes:**
- `process-monitor.sh` - Real-time process monitoring with alerting
- `process-analyzer.sh` - Comprehensive process information gathering

---

## Installation

### Basic Setup

```bash
# Navigate to scripts directory
cd 07-process-management/scripts

# Make scripts executable
chmod +x process-monitor.sh process-analyzer.sh

# Test scripts
./process-monitor.sh --help
./process-analyzer.sh --help
```

### System-Wide Installation

```bash
# Copy to system path
sudo cp process-monitor.sh /usr/local/bin/process-monitor
sudo cp process-analyzer.sh /usr/local/bin/process-analyzer

# Make executable
sudo chmod +x /usr/local/bin/process-monitor
sudo chmod +x /usr/local/bin/process-analyzer

# Verify
process-monitor --version
process-analyzer --help
```

---

## process-monitor.sh

Real-time process monitoring with resource tracking and alerting.

### Quick Start

```bash
# Monitor all processes
./process-monitor.sh

# Monitor specific processes
./process-monitor.sh --processes nginx,mysql,redis

# Watch mode (continuous updates)
./process-monitor.sh --watch --interval 2

# Custom thresholds
./process-monitor.sh --mem-threshold 1000 --cpu-threshold 50
```

### Features

#### 1. Monitor Specific Processes

```bash
# Watch nginx processes
./process-monitor.sh --processes nginx

# Output:
# ✓ nginx (PID 1234): CPU 2.3% Memory 45MB
# ✓ nginx (PID 1235): CPU 1.8% Memory 42MB
```

#### 2. Alert on Thresholds

```bash
# Default thresholds
./process-monitor.sh --processes mysql

# ⚠ MySQL memory high: 850MB > 500MB
# ✓ MySQL CPU: 15.2% (normal)

# Custom thresholds
./process-monitor.sh --processes mysql \
  --mem-threshold 2000 --cpu-threshold 80
```

#### 3. Watch Mode

Continuous monitoring with configurable update interval.

```bash
# Updates every 5 seconds
./process-monitor.sh --watch --processes nginx

# Updates every 1 second
./process-monitor.sh --watch --interval 1 --processes mysql

# Ctrl+C to stop
```

#### 4. Monitor All Heavy Processes

```bash
# Show all processes exceeding thresholds
./process-monitor.sh

# Shows top resource consumers automatically
```

#### 5. Logging

All alerts are logged to `~/.process-monitor.log`:

```bash
# View log
tail -f ~/.process-monitor.log

# Sample log entry:
# [2024-01-15 10:30:42] ALERT: nginx memory high: 650MB
```

### Command-Line Options

| Option | Value | Default | Description |
|--------|-------|---------|-------------|
| `--processes` | LIST | all | Comma-separated process names |
| `--interval` | SEC | 5 | Update interval in watch mode |
| `--watch` | - | false | Enable continuous monitoring |
| `--mem-threshold` | MB | 500 | Memory alert threshold |
| `--cpu-threshold` | % | 80 | CPU alert threshold |
| `--output` | FILE | ~/.process-monitor.log | Log file location |
| `--help` | - | - | Show help message |
| `--version` | - | - | Show version |

### Real-World Examples

#### Example 1: Monitor Web Stack

```bash
# Monitor all components
./process-monitor.sh \
  --processes nginx,mysql,redis \
  --watch \
  --interval 3 \
  --mem-threshold 1000 \
  --cpu-threshold 75
```

#### Example 2: Production Monitoring

```bash
# Run in background, log to file
./process-monitor.sh \
  --processes httpd,mysqld,tomcat \
  --watch \
  --output /var/log/process-monitor.log &

# Tail the log
tail -f /var/log/process-monitor.log
```

#### Example 3: Automated Alerts

```bash
# Check periodically via cron
# Add to crontab:
*/5 * * * * /usr/local/bin/process-monitor \
  --processes critical_app \
  --mem-threshold 500 \
  --cpu-threshold 90 | \
  grep -q "⚠" && \
  echo "Alert!" | mail -s "Process Alert" admin@example.com
```

#### Example 4: Integration with Systemd

```bash
# Create systemd service for monitoring
sudo tee /etc/systemd/system/process-monitor.service << EOF
[Unit]
Description=Process Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/process-monitor --processes nginx,mysql --watch
Restart=always
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable process-monitor.service
sudo systemctl start process-monitor.service
```

### Output Color Coding

- **✓ (Green)**: Process running, within thresholds
- **⚠ (Yellow)**: Threshold exceeded, warning
- **✗ (Red)**: Process not running, critical alert

---

## process-analyzer.sh

Comprehensive process information gathering and reporting.

### Quick Start

```bash
# Analyze by PID
./process-analyzer.sh --pid 1234

# Analyze by process name
./process-analyzer.sh --name nginx

# JSON output for scripting
./process-analyzer.sh --pid 1234 --format json

# Detailed analysis
./process-analyzer.sh --pid 1234 --detailed
```

### Features

#### 1. Complete Process Information

```bash
./process-analyzer.sh --name nginx

# Shows:
# - PID, PPID, User, Runtime
# - Working directory
# - Full command line
```

#### 2. Memory Breakdown

```bash
# See detailed memory usage
./process-analyzer.sh --pid 1234

# Shows:
# VmPeak: Peak virtual memory
# VmSize: Current virtual memory
# VmRSS: Resident (actual RAM)
# VmData: Heap
# VmStk: Stack
```

#### 3. Open Files Analysis

```bash
# List all file descriptors
./process-analyzer.sh --pid 1234

# Shows:
# FD 0: /dev/pts/0
# FD 1: /dev/pts/0
# FD 3: /var/log/app.log
# Total open: 25
```

#### 4. Process Limits

```bash
# See resource limits
./process-analyzer.sh --pid 1234

# Shows:
# Max file size
# Max open files
# Max stack size
# etc.
```

#### 5. Detailed Analysis

```bash
# Full report with environment and tree
./process-analyzer.sh --pid 1234 --detailed

# Includes:
# - Full command line
# - All environment variables
# - Process tree (parent/child)
# - Resource limits
```

#### 6. JSON Output

```bash
# Machine-readable format
./process-analyzer.sh --pid 1234 --format json

# Output:
# {
#   "timestamp": "2024-01-15T10:30:42+00:00",
#   "process": {
#     "pid": 1234,
#     "ppid": 567,
#     "user": "www-data",
#     "memory": {
#       "vmsize": 95000,
#       "vmrss": 45000
#     }
#   }
# }
```

### Command-Line Options

| Option | Value | Default | Description |
|--------|-------|---------|-------------|
| `--pid` | PID | - | Process ID to analyze |
| `--name` | NAME | - | Process name to analyze |
| `--format` | text/json | text | Output format |
| `--detailed` | - | false | Include detailed information |
| `--help` | - | - | Show help message |
| `--version` | - | - | Show version |

### Real-World Examples

#### Example 1: Debug Application

```bash
# Get full details of failing app
./process-analyzer.sh --name my_app --detailed

# See:
# - Current working directory
# - Environment variables
# - All open files
# - Command line arguments
```

#### Example 2: Memory Leak Investigation

```bash
# Check memory usage of suspect process
./process-analyzer.sh --pid 5678

# Check:
# - VmPeak vs VmSize (growing = leak)
# - VmRSS (actual RAM)
# - Open files count
```

#### Example 3: Generate Report

```bash
# Create JSON report for monitoring system
./process-analyzer.sh --name nginx --format json > \
  /var/metrics/nginx-analysis.json

# Monitoring system can parse and analyze
```

#### Example 4: Continuous Analysis

```bash
# Periodic analysis
while true; do
  clear
  ./process-analyzer.sh --name mysql
  sleep 60
done
```

---

## Integration Patterns

### Pattern 1: Monitor with Systemd Timer

```bash
# Service file
sudo tee /etc/systemd/system/process-check.service << EOF
[Unit]
Description=Process Check
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/process-monitor --processes nginx,mysql
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Timer file
sudo tee /etc/systemd/system/process-check.timer << EOF
[Unit]
Description=Process Check Timer

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

# Enable
sudo systemctl daemon-reload
sudo systemctl enable --now process-check.timer
```

### Pattern 2: Alert on Anomalies

```bash
#!/bin/bash
# alert-on-process.sh

PROCESS="nginx"
CHECK=$(/usr/local/bin/process-monitor --processes "$PROCESS")

if echo "$CHECK" | grep -q "⚠"; then
  # Send alert
  echo "$CHECK" | mail -s "Process Alert: $PROCESS" admin@example.com
fi
```

### Pattern 3: Automated Debugging

```bash
#!/bin/bash
# debug-on-failure.sh

APP="my_app"
PID=$(pgrep "$APP")

if [ -z "$PID" ]; then
  # Process dead, generate report
  /usr/local/bin/process-analyzer --name "$APP" --detailed \
    > "/var/logs/debug-$APP-$(date +%s).log"
fi
```

### Pattern 4: Performance Dashboard

```bash
#!/bin/bash
# dashboard.sh

while true; do
  clear
  echo "=== PROCESS DASHBOARD ==="
  echo "Time: $(date)"
  echo ""
  /usr/local/bin/process-monitor --processes nginx,mysql,redis
  sleep 5
done
```

---

## Troubleshooting

### "Permission denied" errors

```bash
# Some /proc files require appropriate permissions
sudo ./process-monitor.sh
sudo ./process-analyzer.sh
```

### Process name not found

```bash
# Verify process exists
pgrep -a nginx

# If not found, process may have stopped
# Try with exact name
./process-analyzer.sh --name nginx
```

### JSON parsing fails

```bash
# Validate JSON output
./process-analyzer.sh --pid 1234 --format json | jq .

# If error, check process still running
ps -p 1234
```

### Memory readings inaccurate

```bash
# /proc readings depend on kernel version
# Use multiple tools to verify
ps aux | grep process_name
cat /proc/[PID]/status

# Combine for accuracy
```

---

## Advanced Usage

### Monitoring Multiple Applications

```bash
#!/bin/bash
# monitor-fleet.sh

APPS=("nginx" "mysql" "redis" "mongodb")

for app in "${APPS[@]}"; do
  echo "=== $app ==="
  ./process-analyzer.sh --name "$app" --format json | jq .
  echo ""
done
```

### Continuous Reporting

```bash
# Log process stats every minute
while true; do
  echo "=== $(date) ===" >> /var/log/process-stats.log
  ./process-monitor.sh --processes nginx,mysql >> /var/log/process-stats.log
  sleep 60
done
```

### Integration with Prometheus

```bash
#!/bin/bash
# process-exporter.sh

# Export metrics in Prometheus format
PID=$(pgrep nginx)
if [ -n "$PID" ]; then
  MEM=$(cat /proc/$PID/status | grep VmRSS | awk '{print $2*1024}')
  CPU=$(ps -p $PID -o %cpu= | xargs)
  
  echo "process_memory_bytes{process=\"nginx\"} $MEM"
  echo "process_cpu_percent{process=\"nginx\"} $CPU"
fi
```

---

## Version Information

- **Script Version**: 1.0.0
- **Compatible**: Linux with bash 4.0+
- **Tested**: Ubuntu 20.04+, Debian 10+, RHEL 8+

---

**For more information**, see the main module documentation:
- [README.md](../README.md) - Module overview
- [01-theory.md](../01-theory.md) - Concepts and theory
- [02-commands-cheatsheet.md](../02-commands-cheatsheet.md) - Commands reference
- [03-hands-on-labs.md](../03-hands-on-labs.md) - Practical exercises
