# Production Scripts: Memory and Disk Monitoring

Two production-ready bash scripts for automated memory and disk management monitoring.

---

## Overview

These scripts provide real-time monitoring and analysis capabilities for memory and disk resources. Both include error handling, logging, and flexible configuration.

| Script | Purpose | Mode | Features |
|--------|---------|------|----------|
| `disk-monitor.sh` | Filesystem usage monitoring | Single-check or daemon | Thresholds, alerts, color output |
| `memory-analyzer.sh` | Process memory analysis | Report or continuous | Sorting, filtering, multiple formats |

---

## disk-monitor.sh

**Purpose**: Monitor disk usage across all filesystems with configurable alerts

### Features

- Monitor all mounted filesystems simultaneously
- Configurable warning and critical thresholds
- Color-coded output (green/yellow/red)
- Daemon mode for continuous monitoring
- Email alerts on threshold breach
- Filesystem exclusion patterns
- Persistent logging

### Installation

```bash
# Make executable
chmod +x disk-monitor.sh

# Copy to system location (optional)
sudo cp disk-monitor.sh /usr/local/bin/

# Verify installation
./disk-monitor.sh --help
```

### Basic Usage

```bash
# Single check with defaults (80% warning, 90% critical)
./disk-monitor.sh

# Output example:
# === Disk Usage Report: 2024-01-15 14:30:45 ===
# OK:                                            [/] 45G / 100G (45%)
# WARNING:                                       [/home] 180G / 200G (90%)
# CRITICAL:                                      [/var] 95G / 100G (95%)
```

### Advanced Usage

**Run as daemon with custom thresholds**:
```bash
# Monitor every 60 seconds, alert at 75%/85%
./disk-monitor.sh --daemon --warning 75 --critical 85 --interval 60 &

# Output continuously checks, logs to ~/.disk-monitor.log
```

**Send email alerts**:
```bash
# Alert admin@example.com when thresholds exceeded
./disk-monitor.sh --daemon --email admin@example.com --critical 85
```

**Exclude specific filesystems**:
```bash
# Monitor all except tmpfs and loop devices
./disk-monitor.sh --exclude "tmpfs|loop|squashfs"
```

**Custom log location**:
```bash
# Log to specific file
./disk-monitor.sh --log /var/log/disk-monitor.log --daemon
```

### Configuration Examples

**Development monitoring (quick alerts)**:
```bash
./disk-monitor.sh --warning 70 --critical 80
```

**Production monitoring (conservative)**:
```bash
./disk-monitor.sh --daemon \
  --warning 80 \
  --critical 90 \
  --email ops@company.com \
  --interval 300 &  # Check every 5 minutes
```

**Datastore monitoring (tight)**:
```bash
./disk-monitor.sh --daemon \
  --warning 75 \
  --critical 85 \
  --email dba@company.com \
  --exclude "tmpfs|devtmpfs" &
```

### Integration with cron

**Monitor hourly and email if issues**:
```bash
# Add to crontab
0 * * * * /usr/local/bin/disk-monitor.sh \
  --email ops@example.com \
  --critical 85 \
  2>&1 | logger -t disk-monitor
```

**Alert on high usage**:
```bash
# Crontab entry - runs every 5 minutes
*/5 * * * * /usr/local/bin/disk-monitor.sh \
  --warning 80 --critical 90 \
  --email admin@example.com 2>&1 | grep -i "warning\|critical"
```

### Integration with systemd

**Create daemon service** (optional):

```ini
# /etc/systemd/system/disk-monitor.service
[Unit]
Description=Disk Usage Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/disk-monitor.sh --daemon --interval 60
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**Start the service**:
```bash
sudo systemctl enable disk-monitor
sudo systemctl start disk-monitor
sudo systemctl status disk-monitor
```

### Command Reference

```bash
disk-monitor.sh [OPTIONS]

OPTIONS:
  --warning PERCENT       Warning threshold (default: 80)
  --critical PERCENT      Critical threshold (default: 90)
  --interval SECONDS      Check interval in daemon mode (default: 60)
  --daemon                Run as daemon (continuous monitoring)
  --email ADDR            Email address for alerts
  --exclude PATTERN       Regex pattern for filesystems to exclude
  --log FILE              Log file location (default: ~/.disk-monitor.log)
  --help                  Show help
  --version               Show version

EXAMPLES:
  ./disk-monitor.sh
  ./disk-monitor.sh --daemon --warning 75 --critical 85
  ./disk-monitor.sh --email admin@example.com --critical 85
  ./disk-monitor.sh --exclude "tmpfs|/boot"
```

### Exit Codes

- `0`: All filesystems OK
- `1`: Warning threshold exceeded
- `2`: Critical threshold exceeded  
- `3`: Error occurred

### Troubleshooting

**Script not executable**:
```bash
chmod +x disk-monitor.sh
```

**Email alerts not working**:
```bash
# Check if mail command exists
which mail

# If missing, install postfix or sendmail
sudo apt-get install mailutils  # Debian/Ubuntu
```

**Permission denied in daemon mode**:
```bash
# Daemon needs root for some operations
sudo ./disk-monitor.sh --daemon

# Or add to sudoers
echo "myuser ALL=(ALL) NOPASSWD: /usr/local/bin/disk-monitor.sh" | sudo tee /etc/sudoers.d/disk-monitor
```

---

## memory-analyzer.sh

**Purpose**: Analyze and report on system and process memory usage

### Features

- Top N memory-consuming processes
- Memory breakdown by user
- Multiple output formats (table, JSON, CSV)
- Continuous monitoring mode
- Real-time memory status
- Swap usage analysis
- Process filtering by size threshold

### Installation

```bash
# Make executable
chmod +x memory-analyzer.sh

# Copy to system location (optional)
sudo cp memory-analyzer.sh /usr/local/bin/

# Verify installation
./memory-analyzer.sh --help
```

### Basic Usage

```bash
# Show top 10 memory consumers
./memory-analyzer.sh

# Output example:
# === System Memory Summary: 2024-01-15 14:35:20 ===
#              total        used        free      shared  buff/cache   available
# Mem:          15Gi        9.4Gi       2.0Gi       1.0Gi       4.2Gi       3.7Gi
# Swap:         7.9Gi          0B       7.9Gi
#
# === Top 10 Memory Consumers ===
# PID        USER       %MEM      RSS(MB)   COMMAND
# ---        ----       -----     -------   -------
# 1234       postgres   12.5      1890      /usr/lib/postgresql/...
# 5678       mysql      8.3       1250      /usr/sbin/mysqld
# 9012       docker     5.2       785       /usr/bin/dockerd
```

### Advanced Usage

**Show top 20, only processes > 100MB**:
```bash
./memory-analyzer.sh --top 20 --threshold 100

# Useful for focusing on major memory consumers
```

**Continuous monitoring mode**:
```bash
# Update every 2 seconds
./memory-analyzer.sh --monitor --interval 2

# Exits with Ctrl+C
```

**JSON output for scripting**:
```bash
# Parse output programmatically
./memory-analyzer.sh --format json

# Output:
# {
#   "timestamp": "2024-01-15T14:35:20+00:00",
#   "processes": [
#     {
#       "pid": 1234,
#       "user": "postgres",
#       "percent_mem": 12.5,
#       "rss_mb": 1890.0,
#       "vsz_mb": 2045.0,
#       "command": "/usr/lib/postgresql/..."
#     }
#   ]
# }
```

**CSV output for analysis**:
```bash
# Export to file for spreadsheet analysis
./memory-analyzer.sh --format csv > memory-usage.csv

# Output can be imported to Excel/LibreOffice
```

### Configuration Examples

**Quick memory audit**:
```bash
./memory-analyzer.sh --threshold 50
```

**Detect memory hogs (> 500MB)**:
```bash
./memory-analyzer.sh --threshold 500 --top 5
```

**Export for reporting**:
```bash
# CSV format
./memory-analyzer.sh --format csv > memory-report-$(date +%Y%m%d).csv

# JSON for API
./memory-analyzer.sh --format json > memory-report-$(date +%Y%m%d).json
```

### Integration with Monitoring

**Cron job for daily reporting**:
```bash
# Add to crontab
0 8 * * * /usr/local/bin/memory-analyzer.sh --format csv \
  > /var/log/memory-report-$(date +\%Y\%m\%d).csv
```

**Alert on high memory usage**:
```bash
#!/bin/bash
# Check if any process using > 1GB

high_mem=$(/usr/local/bin/memory-analyzer.sh --threshold 1000 --format csv | tail -1)

if [ ! -z "$high_mem" ]; then
  echo "ALERT: Process using > 1GB RAM: $high_mem" | \
    mail -s "High Memory Alert" ops@example.com
fi
```

**Monitor memory trend**:
```bash
# Capture snapshots for trending
for i in {1..10}; do
  echo "Sample $i:"
  ./memory-analyzer.sh --threshold 100 | grep "Available memory"
  sleep 60
done
```

### Command Reference

```bash
memory-analyzer.sh [OPTIONS]

OPTIONS:
  --top N               Show top N memory consumers (default: 10)
  --threshold MB        Minimum MB to display (default: 50)
  --format FORMAT       Output format: table, json, csv (default: table)
  --monitor             Run in monitor mode (continuous)
  --interval SECONDS    Update interval for monitor mode (default: 5)
  --swap                Include swap memory in analysis
  --help                Show help
  --version             Show version

EXAMPLES:
  ./memory-analyzer.sh
  ./memory-analyzer.sh --top 20 --threshold 100
  ./memory-analyzer.sh --monitor --interval 2
  ./memory-analyzer.sh --format json
  ./memory-analyzer.sh --format csv > report.csv
```

### Understanding Output

**Memory Summary**:
- `MemTotal`: Total system RAM
- `MemFree`: Unused memory (usually low, normal)
- `MemAvailable`: Actually available without swapping (most important)
- `Buffers`: Kernel temporary buffers (can be freed)
- `Cached`: Filesystem cache (can be freed)

**Process Columns**:
- `PID`: Process ID
- `USER`: Process owner
- `%MEM`: Percentage of total RAM
- `RSS(MB)`: Resident Set Size (actually in RAM)
- `VSZ(MB)`: Virtual memory size (including swapped/mapped)
- `COMMAND`: Process executable

**Memory Status Indicators**:
- 🟢 GREEN: Available memory > 1000MB (healthy)
- 🟡 YELLOW: Available memory 500-1000MB (caution)
- 🔴 RED: Available memory < 500MB (critical)

### Troubleshooting

**No processes showing**:
```bash
# Adjust threshold lower
./memory-analyzer.sh --threshold 10
```

**Permission denied**:
```bash
# May need sudo for some process info
sudo ./memory-analyzer.sh

# Or make script setuid (not recommended)
```

**JSON parsing errors**:
```bash
# Validate JSON output
./memory-analyzer.sh --format json | jq '.'

# If error, check for special characters in process names
```

---

## Using Both Scripts Together

**System health check**:
```bash
#!/bin/bash
# Check both memory and disk

echo "=== SYSTEM RESOURCE HEALTH CHECK ==="
echo ""

echo "Memory Status:"
./memory-analyzer.sh --threshold 100 | head -20

echo ""
echo "Disk Status:"
./disk-monitor.sh

echo ""
echo "Check complete"
```

**Automated monitoring setup**:
```bash
# Terminal 1: Continuous disk monitoring
./disk-monitor.sh --daemon --warning 80 --critical 90 &

# Terminal 2: Continuous memory monitoring
./memory-analyzer.sh --monitor --interval 5 &

# Kill with: killall disk-monitor.sh memory-analyzer.sh
```

**Scheduled reporting**:
```bash
#!/bin/bash
# Hourly system report

REPORT_DIR="/var/log/system-reports"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$REPORT_DIR"

# Memory report
echo "=== Memory Report ===" > "$REPORT_DIR/memory-$TIMESTAMP.txt"
./memory-analyzer.sh --threshold 50 >> "$REPORT_DIR/memory-$TIMESTAMP.txt"

# Disk report
echo "=== Disk Report ===" > "$REPORT_DIR/disk-$TIMESTAMP.txt"
./disk-monitor.sh >> "$REPORT_DIR/disk-$TIMESTAMP.txt"

# Archive old reports
find "$REPORT_DIR" -name "*.txt" -mtime +30 -delete
```

---

## Performance Considerations

**disk-monitor.sh**:
- Lightweight: Uses df (fast)
- Runs in <1 second per check
- Safe for frequent execution (every minute)
- Daemon mode safe with 60+ second intervals

**memory-analyzer.sh**:
- Moderate overhead: Parses all processes
- Takes 1-2 seconds per run
- Safe for frequent execution (every 5+ minutes)
- Monitor mode updates as fast as refresh interval allows

---

## Security Notes

- Run disk-monitor daemon as root for full filesystem access
- memory-analyzer needs root to see all processes
- Email alerts require working mail server
- Logs stored in user home by default, change for production
- Review excluded filesystem patterns before production use
- Test alert emails before deploying to production

---

## Support and Debugging

**Enable verbose logging**:
```bash
# Add to script or run with bash -x
bash -x disk-monitor.sh

# Shows each command as executed
```

**Check logs**:
```bash
# View monitoring logs
tail -f ~/.disk-monitor.log
```

**Test email functionality**:
```bash
# Verify mail command works
echo "Test" | mail -s "Test Subject" admin@example.com
```

---

*Memory and Disk Management Scripts*
*Production-ready bash scripts for resource monitoring*
