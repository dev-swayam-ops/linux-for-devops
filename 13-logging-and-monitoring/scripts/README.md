# Logging and Monitoring Scripts

This directory contains practical scripts for log analysis, system monitoring, and automated reporting.

## Scripts Overview

### 1. log-analyzer.sh

**Purpose**: Parse, filter, and analyze log files with statistics

**Requirements**:
- Bash 4.0+
- Standard utilities (grep, awk)
- Log files to analyze

**Key Features**:
- Filter logs by pattern, level, facility, date/time
- Extract IP addresses and usernames
- Count occurrences and show top errors
- Statistical analysis
- Output to file

**Installation**:
```bash
chmod +x log-analyzer.sh
```

**Usage Examples**:

```bash
# Find all errors
./log-analyzer.sh --level err /var/log/syslog

# Top 10 errors
./log-analyzer.sh --top-errors 10 /var/log/syslog

# Extract IPs from failed logins
./log-analyzer.sh --pattern "Failed" --extract IP /var/log/auth.log

# Count by process
./log-analyzer.sh --count-by process /var/log/syslog

# Analyze between times
./log-analyzer.sh --time-range "10:00:00" "11:00:00" /var/log/syslog

# Show statistics
./log-analyzer.sh --stats /var/log/syslog

# Save results to file
./log-analyzer.sh --pattern error --output errors.txt /var/log/syslog
```

**Common Patterns**:

```bash
# Find failed logins with source IPs
./log-analyzer.sh --pattern "Failed password" --extract IP /var/log/auth.log | sort | uniq -c

# Errors in last hour
./log-analyzer.sh --level err --since "$(date +%H:00)" /var/log/syslog

# Top authentication issues
./log-analyzer.sh --facility auth --top-errors 5 /var/log/auth.log

# Activity summary
./log-analyzer.sh --stats /var/log/syslog
```

**Output**: Filtered logs, extracted fields, counts, and statistics

---

### 2. system-monitor.sh

**Purpose**: Real-time system monitoring with alerts

**Requirements**:
- Bash 4.0+
- `top`, `free`, `df`, `ss` (standard utilities)
- Optional: `journalctl` for error tracking

**Key Features**:
- Monitor CPU, memory, disk, load average
- Configurable alert thresholds
- Monitor specific processes
- Log alerts to file
- Top resource consumers
- Real-time updates

**Installation**:
```bash
chmod +x system-monitor.sh
```

**Usage Examples**:

```bash
# Real-time monitoring with defaults
./system-monitor.sh

# Tighter thresholds
./system-monitor.sh --cpu 70 --memory 75 --disk 80

# Monitor specific process
./system-monitor.sh --process nginx --interval 10

# Single snapshot
./system-monitor.sh --once

# Log to file (60 iterations every 5 seconds = 5 minutes)
./system-monitor.sh --log /tmp/monitoring.log --count 60

# Watch a service with tight memory threshold
./system-monitor.sh --process mysql --memory 85

# Save to CSV for analysis
./system-monitor.sh --log /tmp/stats.log --count 120 --interval 30
```

**Alert Thresholds** (can be customized):
- CPU: 80% (default)
- Memory: 80% (default)
- Disk: 85% (default)
- Load Average: 4 (default, relative to cores)

**Output**:
```
[2024-01-15 10:35:42]
✓ CPU: 45% (threshold: 80%)
✓ Memory: 62% (threshold: 80%)
⚠ Disk /: 82%
✓ Load: 1.5 (threshold: 4)
```

**Common Patterns**:

```bash
# Continuous monitoring with alerts
./system-monitor.sh --cpu 75 --memory 75

# Monitor database server
./system-monitor.sh --process mysqld --memory 90 --interval 30

# Quick health check
./system-monitor.sh --once

# Extended monitoring session
./system-monitor.sh --count 720 --interval 10  # 2 hours, updates every 10 seconds

# Log for analysis
./system-monitor.sh --log /tmp/monitor.log --count 1440 --interval 60  # 24 hours of minutely data
```

---

### 3. logwatch-helper.sh

**Purpose**: Setup and manage logwatch for automated log reviews

**Requirements**:
- Root privileges (for installation and cron setup)
- logwatch package (installed via script)

**Key Features**:
- Install logwatch
- Generate daily/weekly reports
- Setup automated daily reporting
- Show installation status
- Support multiple detail levels

**Installation**:
```bash
chmod +x logwatch-helper.sh
```

**Usage Examples**:

```bash
# Check status
./logwatch-helper.sh status

# Install logwatch
sudo ./logwatch-helper.sh install

# Generate test report
./logwatch-helper.sh test

# Generate daily report (Med detail)
./logwatch-helper.sh report-daily

# Generate detailed daily report
./logwatch-helper.sh report-daily --detail High --output /tmp/report.txt

# Generate weekly report
./logwatch-helper.sh report-weekly --detail High

# Setup automatic daily reports
sudo ./logwatch-helper.sh setup-cron

# Disable automatic reports
sudo ./logwatch-helper.sh disable-cron

# Show current configuration
./logwatch-helper.sh config
```

**Detail Levels**:
- **Low**: Summary only
- **Med**: Standard details (default)
- **High**: Detailed analysis

**Output**: HTML or text email reports with log summaries

---

## Installation and Setup

### Prerequisites

**All scripts require**:
- Bash 4.0 or later
- Standard Linux utilities (grep, awk, sed, etc.)

**Distribution-specific**:
- **Ubuntu/Debian**: sysstat package for iostat
- **RHEL/CentOS**: sysstat package for iostat
- **logwatch**: Optional, installed by logwatch-helper.sh

### Quick Start

```bash
# Make all scripts executable
chmod +x *.sh

# Install to system path (optional)
sudo cp *.sh /usr/local/bin/

# Test installation
./log-analyzer.sh --help
./system-monitor.sh --help
./logwatch-helper.sh --help
```

---

## Common Use Cases

### Case 1: Troubleshoot High CPU

```bash
# Monitor in real-time
./system-monitor.sh --cpu 60 --once

# Find processes causing it
top -b -n 1 | head -20

# Log details for later analysis
./system-monitor.sh --log /tmp/cpu-analysis.log --count 20 --interval 5
```

### Case 2: Find Failed Logins

```bash
# Analyze auth log
./log-analyzer.sh --facility auth /var/log/auth.log

# Extract attacking IPs
./log-analyzer.sh --pattern "Failed" --extract IP /var/log/auth.log

# Count by IP
./log-analyzer.sh --pattern "Failed" --count-by source /var/log/auth.log
```

### Case 3: Daily Log Review

```bash
# Generate comprehensive report
./logwatch-helper.sh report-daily --detail High --output /tmp/daily-report.txt

# Setup automatic reporting
sudo ./logwatch-helper.sh setup-cron

# View latest report
tail -100 /var/log/logwatch-daily-report.txt
```

### Case 4: Monitor Critical Service

```bash
# Watch nginx continuously with alerts
./system-monitor.sh --process nginx --memory 90 --interval 5

# Log activity for trending
./system-monitor.sh --process nginx --log /tmp/nginx.log --count 720 --interval 60
```

### Case 5: Disk Usage Analysis

```bash
# Get snapshot
./system-monitor.sh --once

# Find largest directories
du -sh /home/* | sort -hr | head -5

# Monitor disk I/O
iostat -x 1 10
```

---

## Integration Examples

### Monitor and Alert on Errors

```bash
#!/bin/bash
# Check for errors and alert

./log-analyzer.sh --level err /var/log/syslog > /tmp/errors.txt

if [ -s /tmp/errors.txt ]; then
    echo "ALERT: Errors found in logs"
    # Could send email, post to Slack, etc.
    mail -s "System Errors" admin@example.com < /tmp/errors.txt
fi
```

### Continuous Monitoring with Logging

```bash
#!/bin/bash
# Monitor every 5 minutes and log results

while true; do
    ./system-monitor.sh --log /var/log/system-monitor.log --count 1 --interval 60
    sleep 300  # 5 minutes
done
```

### Analyze Trends

```bash
#!/bin/bash
# Run 24-hour monitoring for trend analysis

./system-monitor.sh \
    --log /tmp/24h-stats.log \
    --count 1440 \
    --interval 60 \
    --cpu 80 \
    --memory 85

# Analyze results
grep "ALERT" /tmp/24h-stats.log
```

---

## Troubleshooting

### log-analyzer.sh

**Issue**: "No matching entries found"
```bash
# Check file exists and has data
wc -l /var/log/syslog

# Try broader pattern
./log-analyzer.sh /var/log/syslog | head -20
```

**Issue**: Permission denied on log file
```bash
# Many logs require root
sudo ./log-analyzer.sh /var/log/auth.log
```

### system-monitor.sh

**Issue**: Load threshold always triggers
```bash
# Check number of CPU cores
nproc

# Adjust threshold (use cores + 1)
./system-monitor.sh --load 8  # For 8-core system
```

**Issue**: Can't read memory stats
```bash
# Ensure free command works
free -h

# Most systems have this, try:
./system-monitor.sh --once
```

### logwatch-helper.sh

**Issue**: "Logwatch not installed"
```bash
# Install it
sudo ./logwatch-helper.sh install
```

**Issue**: Report generation fails
```bash
# Check if logwatch is actually installed
which logwatch

# Check configuration
./logwatch-helper.sh config
```

---

## Best Practices

1. **Regular Monitoring**
   - Run system-monitor.sh daily or continuously
   - Monitor specific critical processes
   - Set appropriate thresholds

2. **Log Analysis**
   - Analyze logs weekly for trends
   - Look for patterns in errors
   - Extract and review suspicious IPs

3. **Automated Reporting**
   - Setup logwatch-helper for daily summaries
   - Maintain log history for compliance
   - Archive old logs regularly

4. **Alert Response**
   - Act on alerts promptly
   - Document findings
   - Update thresholds based on experience

5. **Data Retention**
   - Keep monitoring logs for trend analysis
   - Archive important security logs
   - Clean up old monitoring data

---

## Integration with Cron

### Automated Monitoring

```bash
# /etc/cron.d/system-monitoring

# Run every 10 minutes
*/10 * * * * /usr/local/bin/system-monitor.sh --once --log /var/log/system-monitor.log

# Daily analysis at midnight
0 0 * * * /usr/local/bin/log-analyzer.sh --stats /var/log/syslog > /var/log/daily-analysis.txt

# Weekly detailed review
0 2 * * 0 /usr/local/bin/logwatch-helper.sh report-weekly --detail High > /var/log/weekly-review.txt
```

---

## Performance Considerations

- **log-analyzer.sh**: Slower on very large files (>1GB)
- **system-monitor.sh**: Minimal overhead, safe for continuous monitoring
- **logwatch-helper.sh**: Background process, won't affect system performance

---

**Last Updated**: 2024
**Compatibility**: Ubuntu/Debian 20.04+, RHEL/CentOS 8+
**License**: Educational use
