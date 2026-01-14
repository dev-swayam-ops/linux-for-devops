# Module 06 - Scripts Documentation

Production-quality bash scripts for systemd service monitoring and reporting.

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [daemon-monitor.sh](#daemon-monitorsh)
4. [service-status-reporter.sh](#service-status-reportersh)
5. [Integration Patterns](#integration-patterns)
6. [Troubleshooting](#troubleshooting)

---

## Overview

These scripts provide operational tools for managing and monitoring systemd services in production environments. They complement the learning materials in the main module by providing real-world examples of service management automation.

**Script Purposes:**
- `daemon-monitor.sh` - Real-time service monitoring with alerting
- `service-status-reporter.sh` - Comprehensive reporting in multiple formats

**Common Requirements:**
- Linux system with systemd (Ubuntu 18.04+, RHEL 8+, Fedora 21+)
- Bash 4.0+
- Standard utilities: systemctl, journalctl, ps, awk, grep

---

## Installation

### Basic Setup

```bash
# Navigate to scripts directory
cd /path/to/linux-for-devops/06-system-services-and-daemons/scripts

# Make scripts executable
chmod +x daemon-monitor.sh service-status-reporter.sh

# Optional: Test execution
./daemon-monitor.sh --help
./service-status-reporter.sh --help
```

### System-Wide Installation

```bash
# Copy to system path
sudo cp daemon-monitor.sh /usr/local/bin/daemon-monitor
sudo cp service-status-reporter.sh /usr/local/bin/service-status-reporter

# Make executable
sudo chmod +x /usr/local/bin/daemon-monitor
sudo chmod +x /usr/local/bin/service-status-reporter

# Verify
daemon-monitor --version
service-status-reporter --help
```

### Log Directory Setup (Optional)

```bash
# Create log directory for daemon-monitor
mkdir -p ~/.daemon-monitor
chmod 700 ~/.daemon-monitor

# Or system-wide logs (requires root)
sudo mkdir -p /var/log/daemon-monitor
sudo chmod 755 /var/log/daemon-monitor
```

---

## daemon-monitor.sh

Real-time monitoring tool for systemd services with memory and CPU tracking.

### Quick Start

```bash
# Show help
./daemon-monitor.sh --help

# Monitor all services
./daemon-monitor.sh

# Monitor specific services
./daemon-monitor.sh --services ssh mysql nginx

# Watch mode (updates every 5 seconds)
./daemon-monitor.sh --watch

# Custom thresholds
./daemon-monitor.sh --mem-threshold 1000 --cpu-threshold 50
```

### Features

#### 1. Service Status Monitoring

Provides real-time status of services with PID and state information.

```bash
# Basic status check
./daemon-monitor.sh

# Output:
# Service: ssh
#   Status: active (running)
#   PID: 12345
#   Memory: 15.2 MB
#   CPU: 0.1%
#   State: ✓
```

#### 2. Memory Threshold Alerting

Alert when services consume more than specified memory.

```bash
# Default threshold: 500MB
./daemon-monitor.sh

# Custom threshold (1GB)
./daemon-monitor.sh --mem-threshold 1000

# Will show warning:
# ⚠ WARNING: mysqld memory usage: 1250 MB (threshold: 1000 MB)
```

#### 3. CPU Threshold Alerting

Track CPU usage and alert on high consumption.

```bash
# Default threshold: 80%
./daemon-monitor.sh

# Custom threshold (50%)
./daemon-monitor.sh --cpu-threshold 50

# Output shows color-coded CPU:
# - Green: < threshold
# - Yellow: warning zone
# - Red: critical
```

#### 4. Watch Mode (Continuous Monitoring)

Continuous monitoring with configurable update interval.

```bash
# Update every 5 seconds (default)
./daemon-monitor.sh --watch

# Update every 2 seconds
./daemon-monitor.sh --watch --interval 2

# Monitor specific services in watch mode
./daemon-monitor.sh --watch --services ssh mysql nginx
```

#### 5. Failed Service Detection

Automatically detect and highlight failed services.

```bash
# Failed services shown in RED with X mark
./daemon-monitor.sh

# Example output for failed service:
# Service: httpd
#   Status: failed (dead)
#   State: ✗ FAILED
#   Last Attempt: 2 minutes ago
```

#### 6. Logging and Persistence

All alerts and state changes logged to file.

```bash
# Default log location: ~/.daemon-monitor.log
./daemon-monitor.sh

# View logs
tail -f ~/.daemon-monitor.log

# Log entries show timestamp and state changes:
# [2024-01-15 10:30:42] Service: ssh - State: running
# [2024-01-15 10:35:15] Service: mysql - ALERT: Memory threshold exceeded (650MB > 500MB)
```

### Command-Line Options

| Option | Value | Default | Description |
|--------|-------|---------|-------------|
| `--services` | service1 service2 | all | Monitor specific services |
| `--interval` | seconds | 5 | Update interval in watch mode |
| `--watch` | - | false | Enable continuous watch mode |
| `--mem-threshold` | MB | 500 | Memory alert threshold |
| `--cpu-threshold` | % | 80 | CPU alert threshold |
| `--help` | - | - | Show help message |
| `--version` | - | - | Show version |

### Output Color Coding

- **Green (✓)**: Service running, within thresholds
- **Yellow (⚠)**: Service running, threshold warning
- **Red (✗)**: Service failed or critical threshold exceeded
- **Gray (○)**: Service inactive/stopped

### Real-World Examples

#### Example 1: Monitor Web Services

```bash
# Monitor Apache, Nginx, and related services
./daemon-monitor.sh --services apache2 nginx mysql redis-server \
  --mem-threshold 800 --watch

# Updates every 5 seconds showing:
# - Service status (running/stopped/failed)
# - Memory and CPU usage
# - Alerts if thresholds exceeded
```

#### Example 2: Production Monitoring with Notifications

```bash
# Check services and exit with appropriate code
./daemon-monitor.sh --services httpd mysqld

# Exit codes:
# 0 = All services healthy
# 1 = Warning (threshold exceeded)
# 2 = Critical (service failed or critical threshold)

# Use with notifications:
if ! ./daemon-monitor.sh --services httpd mysqld; then
  echo "Service alert detected" | mail -s "Service Alert" admin@example.com
fi
```

#### Example 3: Integration with Cron

```bash
# Add to crontab for periodic checks
0 */6 * * * /usr/local/bin/daemon-monitor --services nginx mysql \
  --output /var/log/service-checks.log 2>&1

# Every 6 hours, check nginx and mysql, log results
```

### Troubleshooting

#### "Permission denied" on service operations

```bash
# Some operations require root
sudo ./daemon-monitor.sh --services httpd mysql

# Alternative: Add user to systemd-journal group
sudo usermod -a -G systemd-journal $USER
# Log out and back in for changes to take effect
```

#### Memory reading returns 0

```bash
# /proc may not be readable for some processes
# This is normal for system services
# Run with elevated privileges if needed:
sudo ./daemon-monitor.sh
```

#### Watch mode shows stale data

```bash
# Restart watch mode to refresh
# Press Ctrl+C and re-run:
./daemon-monitor.sh --watch
```

---

## service-status-reporter.sh

Comprehensive service status reporting tool with multiple output formats.

### Quick Start

```bash
# Text report (default)
./service-status-reporter.sh

# JSON format
./service-status-reporter.sh --format json

# CSV for analysis
./service-status-reporter.sh --format csv

# Save to file
./service-status-reporter.sh --format json --output report.json
```

### Features

#### 1. Table Format (Default)

Human-readable ASCII table format with summary statistics.

```bash
./service-status-reporter.sh

# Output:
# ╔════════════════════════════════════════════════════════════════╗
# ║         SYSTEMD SERVICE STATUS REPORT                          ║
# ║         2024-01-15 10:30:42                                    ║
# ╚════════════════════════════════════════════════════════════════╝
#
# SUMMARY
# ────────────────────────────────────────────────────────────────
# Enabled Services:    45
# Running Services:    42
# Failed Services:     1
```

#### 2. JSON Format

Structured data for programmatic consumption.

```bash
./service-status-reporter.sh --format json

# Output:
# {
#   "timestamp": "2024-01-15T10:30:42+00:00",
#   "summary": {
#     "enabled_services": 45,
#     "running_services": 42,
#     "failed_services": 1
#   },
#   "services": [
#     {
#       "name": "ssh.service",
#       "load": "loaded",
#       "active": "running"
#     },
#     ...
#   ]
# }
```

#### 3. CSV Format

Spreadsheet-compatible output for analysis.

```bash
./service-status-reporter.sh --format csv

# Output:
# Service,Load,Active,PID,Memory(MB),CPU(%)
# ssh.service,loaded,running,1234,15.2,0.1
# mysql.service,loaded,running,5678,250.5,2.3
# httpd.service,loaded,failed,,0,0
```

#### 4. Detailed Analysis

Extended information including boot performance and slowest services.

```bash
# Add detailed analysis
./service-status-reporter.sh --detailed

# Includes:
# - Boot performance metrics
# - Slowest services at startup
# - Failed service details
# - Resource usage breakdown
```

#### 5. Failed Services Focus

Report only on failed services for quick troubleshooting.

```bash
./service-status-reporter.sh --failed-only

# Shows:
# - Only failed services
# - Last error output
# - Status history
```

### Command-Line Options

| Option | Value | Default | Description |
|--------|-------|---------|-------------|
| `--format` | table/json/csv | table | Output format |
| `--detailed` | - | false | Include detailed analysis |
| `--failed-only` | - | false | Show only failed services |
| `--output` | filename | stdout | Write to file |
| `--help` | - | - | Show help message |
| `--version` | - | - | Show version |

### Real-World Examples

#### Example 1: Generate Daily Report

```bash
# Create daily report for auditing
# Add to crontab:
0 0 * * * /usr/local/bin/service-status-reporter \
  --format json --output /var/reports/services-$(date +\%Y\%m\%d).json

# Creates: /var/reports/services-20240115.json
```

#### Example 2: Email Failed Services

```bash
# Create report of failed services and email
/usr/local/bin/service-status-reporter --failed-only > /tmp/failed.txt

if [ -s /tmp/failed.txt ]; then
  cat /tmp/failed.txt | mail -s "Failed Services Report" admin@example.com
fi
```

#### Example 3: Performance Tracking

```bash
# Track boot performance over time
date >> /var/log/boot-performance.log
/usr/local/bin/service-status-reporter --format csv >> /var/log/boot-performance.log

# Collect data periodically for trend analysis
```

#### Example 4: Integration with Monitoring

```bash
# Export data for monitoring system (Prometheus, Grafana, etc.)
./service-status-reporter.sh --format json --output /var/metrics/services.json

# Monitoring agent can read this file and send to central system
```

---

## Integration Patterns

### Pattern 1: Systemd Timer for Regular Monitoring

Create a systemd service + timer for automatic monitoring.

```bash
# /etc/systemd/system/service-monitor.service
[Unit]
Description=Service Status Monitoring
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/daemon-monitor --services httpd mysql
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target

---

# /etc/systemd/system/service-monitor.timer
[Unit]
Description=Service Status Monitoring Timer
Requires=service-monitor.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
AccuracySec=1min

[Install]
WantedBy=timers.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable service-monitor.timer
sudo systemctl start service-monitor.timer

# Verify
sudo systemctl status service-monitor.timer
```

### Pattern 2: Cron-Based Reporting

Add scripts to crontab for scheduled reporting.

```bash
# /etc/cron.d/service-reports
# Run monitoring every hour and reporting every day

0 * * * * root /usr/local/bin/daemon-monitor --services nginx mysql > /dev/null 2>&1

0 0 * * * root /usr/local/bin/service-status-reporter \
  --format json --output /var/reports/daily-$(date +\%Y\%m\%d).json
```

### Pattern 3: Emergency Response

Chain scripts with alerting for critical situations.

```bash
#!/bin/bash
# emergency-response.sh

REPORT=$(/usr/local/bin/service-status-reporter --failed-only)

if [ -n "$REPORT" ]; then
  # Failed services detected
  ALERT="⚠ CRITICAL: Failed Services Detected\n\n$REPORT"
  
  # Send email
  echo -e "$ALERT" | mail -s "CRITICAL Alert" sysadmin@company.com
  
  # Write to syslog
  logger "$ALERT"
  
  # Trigger incident (optional)
  # curl -X POST https://incident-api.example.com/alerts \
  #   -d "severity=critical" -d "message=$ALERT"
  
  exit 1
fi

exit 0
```

### Pattern 4: Dashboard Display

Create a continuously-updated status display.

```bash
#!/bin/bash
# service-dashboard.sh

while true; do
  clear
  echo "════════════════════════════════════════════"
  echo "   SYSTEMD SERVICE DASHBOARD"
  echo "   Updated: $(date '+%H:%M:%S')"
  echo "════════════════════════════════════════════"
  echo ""
  
  /usr/local/bin/daemon-monitor --services nginx mysql redis postgresql
  
  sleep 5
done
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Scripts show "Permission denied"

**Solution:**
```bash
# Check file permissions
ls -la daemon-monitor.sh service-status-reporter.sh

# Make executable if needed
chmod +x daemon-monitor.sh service-status-reporter.sh

# For system-wide scripts
sudo chmod +x /usr/local/bin/daemon-monitor
```

#### Issue: No output from monitor script

**Solution:**
```bash
# Check if services exist
systemctl list-units --type=service --all

# Run with explicit service names
./daemon-monitor.sh --services ssh sudo

# Check error output
./daemon-monitor.sh 2>&1 | head -20
```

#### Issue: High memory readings

**Solution:**
```bash
# This is normal for large services
# Memory includes all process memory

# To see detailed breakdown:
ps aux | grep service_name

# To see process details:
cat /proc/PID/status | grep Vm
```

#### Issue: Cannot read /proc for some services

**Solution:**
```bash
# Run with sudo for system processes
sudo ./daemon-monitor.sh

# Alternative: Add user to required groups
sudo usermod -a -G systemd-journal $USER
sudo usermod -a -G adm $USER

# Log out and back in
```

#### Issue: Cron script not executing

**Solution:**
```bash
# Ensure full path to script
# In crontab, use absolute paths:
0 * * * * /usr/local/bin/daemon-monitor

# Test cron execution:
sudo -u your_user /usr/local/bin/daemon-monitor

# Check cron logs:
sudo grep CRON /var/log/syslog
```

### Debug Mode

Enable debug output to troubleshoot issues:

```bash
# Run with debug (set -x)
bash -x daemon-monitor.sh

# Or add temporary debug lines:
# echo "DEBUG: Variable value = $variable"
```

### Getting Help

For additional help, refer to:

1. Script help text: `./daemon-monitor.sh --help`
2. Main module documentation: See `../01-theory.md` and `../02-commands-cheatsheet.md`
3. System documentation: `man systemctl`, `man journalctl`
4. Lab exercises: See `../03-hands-on-labs.md` for practical examples

---

## Advanced Usage

### Log Analysis

Analyze daemon-monitor logs for trends:

```bash
# Show all alerts from today
grep "ALERT" ~/.daemon-monitor.log

# Count failed service instances
grep "FAILED" ~/.daemon-monitor.log | wc -l

# Find services with repeated issues
grep "ALERT\|FAILED" ~/.daemon-monitor.log | \
  awk '{print $NF}' | sort | uniq -c | sort -rn
```

### Automated Remediation

Combine with auto-restart logic:

```bash
#!/bin/bash
# auto-restart-failed.sh

FAILED=$(/usr/local/bin/service-status-reporter --failed-only)

for service in $FAILED; do
  echo "Attempting to restart $service..."
  sudo systemctl restart "$service"
  sleep 2
  
  # Check if restart succeeded
  if ! sudo systemctl is-active --quiet "$service"; then
    echo "ERROR: $service still failed after restart" >&2
  fi
done
```

### Custom Monitoring

Extend scripts for environment-specific needs:

```bash
# Example: Add database health check
# Modify daemon-monitor.sh to include:

check_service_health() {
  local service=$1
  
  # Standard checks
  systemctl is-active --quiet "$service" || return 1
  
  # Custom health check for mysql
  if [ "$service" = "mysql" ]; then
    mysql -u root -e "SELECT 1" > /dev/null 2>&1 || return 1
  fi
  
  return 0
}
```

---

## Version Information

- **Script Version**: 1.0.0
- **Last Updated**: January 2024
- **Compatible**: Linux with systemd (Ubuntu 18.04+, RHEL 8+, Fedora 21+)
- **Bash Version**: 4.0 or higher required

## License

These scripts are part of the Linux for DevOps learning repository and are provided as educational and operational tools.
