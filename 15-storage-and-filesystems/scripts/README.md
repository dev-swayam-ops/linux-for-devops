# Storage and Filesystems - Scripts Directory

Production-ready bash scripts for storage management, filesystem monitoring, and automation.

---

## Scripts Overview

### 1. disk-monitor.sh
**Real-time disk and inode monitoring with alerting.**

#### Purpose
- Monitor disk usage across all filesystems
- Track inode utilization
- Send alerts when thresholds are exceeded
- Identify largest directories
- Generate usage reports

#### Features
- Configurable alert thresholds (default 80%)
- Cooldown mechanism to prevent alert spam
- Email notifications (optional)
- Progress bars and color-coded output
- Logging to `/var/log/disk-monitor.log`
- Continuous monitoring loop

#### Usage
```bash
# Basic monitoring with defaults
./disk-monitor.sh

# Alert at 70% usage instead of 80%
./disk-monitor.sh --threshold 70

# Check every 60 seconds (default 300)
./disk-monitor.sh --interval 60

# Both options
./disk-monitor.sh --threshold 85 --interval 600

# With email alerts
export ADMIN_EMAIL="admin@company.com"
./disk-monitor.sh --threshold 75
```

#### Output Sections
- Disk Usage Report: All mounted filesystems with usage percent
- Inode Usage Report: Inode utilization (useful for file system health)
- Largest Directories: Top 5 directories per mount point

#### Email Configuration
```bash
# Edit to add email support
export ADMIN_EMAIL="ops@company.com"
./disk-monitor.sh

# Or modify script defaults
ADMIN_EMAIL="ops@company.com"
ALERT_COOLDOWN=7200  # 2 hours between alerts
```

#### Running as Service
```bash
# Create systemd service
sudo tee /etc/systemd/system/disk-monitor.service > /dev/null << EOF
[Unit]
Description=Disk Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/disk-monitor.sh --threshold 80 --interval 300
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable disk-monitor
sudo systemctl start disk-monitor
sudo systemctl status disk-monitor
```

---

### 2. filesystem-analyzer.sh
**Detailed filesystem structure and health analysis.**

#### Purpose
- Analyze filesystem composition
- Identify storage usage patterns
- Check filesystem health
- Generate comprehensive reports
- Find optimization opportunities

#### Features
- Detailed inode analysis
- File type breakdown
- Directory enumeration
- Permission analysis (SUID, SGID)
- Symlink and hardlink detection
- Empty file cleanup opportunities
- Filesystem-specific checks (ext4, XFS, Btrfs)
- CSV export for data analysis

#### Usage
```bash
# Analyze root filesystem
./filesystem-analyzer.sh

# Analyze specific filesystem
./filesystem-analyzer.sh /home

# Detailed mode (file-level breakdown)
./filesystem-analyzer.sh /home --detailed

# Export as CSV
./filesystem-analyzer.sh / --csv > storage.csv

# Detailed CSV export
./filesystem-analyzer.sh /var --detailed --csv > var-analysis.csv
```

#### Output Sections
1. **Filesystem Information**
   - Device, type, size, mount options
   - Filesystem-specific details (tune2fs, xfs_info, etc.)

2. **Disk Space Analysis**
   - Top 15 directories by size
   - Helps identify space hogs

3. **File Type Breakdown** (detailed mode)
   - Distribution by file extension
   - Count and percentage for each type

4. **Inode Analysis**
   - Total, used, available inodes
   - Progress bar
   - High-usage warning
   - Directories with most files (detailed mode)

5. **Permission Analysis**
   - SUID/SGID files (security check)
   - World-writable directories
   - Potential security issues

6. **Link Analysis**
   - Symbolic link count
   - Hard link count
   - Top symlink locations

7. **Empty Files Detection**
   - Zero-byte files count
   - Empty directories count
   - Sample empty file listings

8. **Filesystem Health**
   - Filesystem state check
   - Mount count and frequency
   - Last check date
   - Fragmentation analysis (ext4)

#### Integration Examples
```bash
# Schedule daily analysis
0 2 * * * /opt/filesystem-analyzer.sh / --csv > /var/reports/daily-analysis.csv

# Monitor specific directory
watch -n 300 '/opt/filesystem-analyzer.sh /home'

# Compare filesystem growth
cron: 0 * * * * /opt/filesystem-analyzer.sh / --csv >> /var/log/fs-hourly.csv

# Alert on high inode usage
/opt/filesystem-analyzer.sh / | grep -i "inode" | mail -s "Inode Status" admin@company.com
```

---

### 3. storage-report.sh
**Comprehensive storage utilization reports in multiple formats.**

#### Purpose
- Generate formatted storage reports
- Create historical data for trend analysis
- Export data for dashboards
- Share reports in HTML format
- Integrate with monitoring systems

#### Features
- Multiple output formats (TEXT, HTML, JSON)
- Disk space summary with progress bars
- Inode usage tracking
- Filesystem type distribution
- Health recommendations
- File export capability
- Automatic historical snapshots
- Machine-readable JSON output

#### Usage
```bash
# Simple text report to console
./storage-report.sh

# HTML report for sharing
./storage-report.sh --format HTML --output /tmp/storage-report.html

# JSON output for parsing
./storage-report.sh --format JSON > storage-data.json

# Save in background
./storage-report.sh --format HTML --output /var/www/html/storage-report.html

# JSON to pipe to jq
./storage-report.sh --format JSON | jq '.disk_usage[] | select(.usage_percent > 80)'
```

#### Output Formats

**TEXT Format:**
```
Formatted ASCII output with:
- Unicode box drawing (╔═╗║╚)
- Progress bars (█░)
- Color coding (if terminal supports)
- Human-readable sizes
- Actionable recommendations
```

**HTML Format:**
```
Interactive web page with:
- Modern CSS styling
- Responsive tables
- Color-coded usage levels
- Charts and progress indicators
- Hover effects
- Print-friendly layout
```

**JSON Format:**
```json
{
  "timestamp": "2024-02-15T14:30:00Z",
  "hostname": "server01",
  "disk_usage": [
    {
      "device": "/dev/sda2",
      "size": "100G",
      "used": "42G",
      "available": "58G",
      "usage_percent": 42
    }
  ],
  "inode_usage": [...]
}
```

#### Automation
```bash
# Daily report to email
0 8 * * * /opt/storage-report.sh --format TEXT | mail -s "Daily Storage Report" ops@company.com

# Weekly HTML report
0 9 * * 1 /opt/storage-report.sh --format HTML --output /var/reports/weekly-$(date +\%Y\%m\%d).html

# JSON for metrics collection
*/5 * * * * /opt/storage-report.sh --format JSON > /var/metrics/storage.json

# Monitoring integration
0 * * * * /opt/storage-report.sh --format JSON | \
  jq -r '.disk_usage[] | select(.usage_percent > 85) | "ALERT: \(.device) at \(.usage_percent)%"' | \
  xargs -I {} echo {} >> /var/log/storage-alerts.log
```

---

### 4. lvm-helper.sh
**Simplified interface for common LVM operations.**

#### Purpose
- Streamline LVM management
- Reduce human error in complex operations
- Provide interactive confirmations
- Show clear operation progress
- Automate common workflows

#### Features
- Interactive confirmations for destructive operations
- Dry-run mode for testing
- Automatic next-step guidance
- Clear progress feedback
- Configuration backup capability
- Error checking and validation
- Support for all major LVM operations

#### Usage

**Creating New Storage:**
```bash
# Create physical volume
sudo ./lvm-helper.sh create-pv /dev/sdb

# Create volume group
sudo ./lvm-helper.sh create-vg vg0 /dev/sdb

# Create logical volume (10GB)
sudo ./lvm-helper.sh create-lv vg0 lv_data 10G

# Format and mount (manual)
sudo mkfs.ext4 /dev/vg0/lv_data
sudo mount /dev/vg0/lv_data /data
```

**Expanding Storage:**
```bash
# Add 5GB to existing logical volume
sudo ./lvm-helper.sh extend-lv /dev/vg0/lv_data 5G

# Resize ext4 filesystem (for ext4)
sudo ./lvm-helper.sh extend-fs /dev/vg0/lv_data /data

# Or for XFS
sudo ./lvm-helper.sh extend-fs /dev/vg0/lv_data /data
```

**Monitoring:**
```bash
# Check current LVM status
sudo ./lvm-helper.sh show-status

# List volume groups
sudo ./lvm-helper.sh show-vg

# Backup configuration
sudo ./lvm-helper.sh backup-config
```

**Cleanup:**
```bash
# Remove logical volume (asks for confirmation)
sudo ./lvm-helper.sh remove-lv /dev/vg0/lv_data
```

#### Dry-Run Mode
```bash
# Preview operations without making changes
sudo ./lvm-helper.sh --dry-run create-lv vg0 lv_test 5G

# Output shows what would happen:
# [DRY-RUN] lvcreate -L 5G -n lv_test vg0
```

#### Common Workflows

**Single-Command Expansion (requires manual steps):**
```bash
#!/bin/bash
# Script to safely expand LV with one command

LV_PATH="/dev/vg0/lv_data"
MOUNT_POINT="/data"
SIZE_TO_ADD="5G"

sudo lvm-helper.sh extend-lv "$LV_PATH" "$SIZE_TO_ADD"
sudo lvm-helper.sh extend-fs "$LV_PATH" "$MOUNT_POINT"

echo "Expansion complete!"
```

**Automated VG Creation:**
```bash
#!/bin/bash
# Create VG with multiple LVs

VG_NAME="vg_backup"
PV_DEVICE="/dev/sdb"

sudo lvm-helper.sh create-pv "$PV_DEVICE"
sudo lvm-helper.sh create-vg "$VG_NAME" "$PV_DEVICE"
sudo lvm-helper.sh create-lv "$VG_NAME" "lv_hourly" 20G
sudo lvm-helper.sh create-lv "$VG_NAME" "lv_daily" 30G
sudo lvm-helper.sh create-lv "$VG_NAME" "lv_monthly" 50G

# Format filesystems
for lv in hourly daily monthly; do
    sudo mkfs.ext4 "/dev/$VG_NAME/lv_$lv"
done
```

---

## Common Tasks

### Task: Monitor Disk Usage in Real-Time
```bash
# Terminal 1: Start monitor
./disk-monitor.sh --interval 60 --threshold 80

# Terminal 2: Check active monitoring
ps aux | grep disk-monitor
tail -f /var/log/disk-monitor.log
```

### Task: Find Space Hogs
```bash
# Quick analysis
./filesystem-analyzer.sh / | grep -A 5 "LARGEST"

# Detailed with file breakdown
./filesystem-analyzer.sh /home --detailed | less
```

### Task: Generate Shareable Report
```bash
# Create HTML report
./storage-report.sh --format HTML --output /tmp/storage-report.html

# Open in browser
xdg-open /tmp/storage-report.html

# Or copy to web server
sudo cp /tmp/storage-report.html /var/www/html/
# Access at http://server/storage-report.html
```

### Task: Expand Full Disk Without Downtime
```bash
# 1. Add new disk to VM/system
# 2. Partition and set up LVM
sudo ./lvm-helper.sh create-pv /dev/sdc
sudo ./lvm-helper.sh create-vg vg_new /dev/sdc

# 3. Create new LV and move data
sudo ./lvm-helper.sh create-lv vg_new lv_home 100G
sudo mkfs.ext4 /dev/vg_new/lv_home
sudo rsync -avz /home/ /mnt/temp/
sudo mount /dev/vg_new/lv_home /home

# 4. Or extend existing
sudo ./lvm-helper.sh extend-lv /dev/vg0/lv_home 50G
sudo ./lvm-helper.sh extend-fs /dev/vg0/lv_home /home
```

---

## Installation

### Quick Setup
```bash
# Copy scripts to system location
sudo cp disk-monitor.sh /usr/local/bin/
sudo cp filesystem-analyzer.sh /usr/local/bin/
sudo cp storage-report.sh /usr/local/bin/
sudo cp lvm-helper.sh /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/{disk-monitor,filesystem-analyzer,storage-report,lvm-helper}.sh

# Optional: Create symlinks without .sh
sudo ln -s /usr/local/bin/disk-monitor.sh /usr/local/bin/disk-monitor
```

### Dependencies
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y coreutils util-linux e2fsprogs xfsprogs lvm2 quota

# Optional for enhanced features
sudo apt install -y mailutils ncdu iotop sysstat

# For HTML report browser opening
sudo apt install -y xdg-utils
```

### Permissions Setup
```bash
# Create backup directory
sudo mkdir -p /var/backups/lvm
sudo chmod 755 /var/backups/lvm

# Create log directory
sudo mkdir -p /var/log
sudo chmod 755 /var/log

# Allow non-root monitoring (optional, less secure)
sudo visudo
# Add: your_user ALL=(ALL) NOPASSWD: /usr/local/bin/disk-monitor.sh
```

---

## Troubleshooting

### disk-monitor.sh Issues
```bash
# Check log for errors
tail -f /var/log/disk-monitor.log

# Test email configuration
echo "Test" | mail -s "Test Alert" admin@company.com

# Run with debug output
bash -x ./disk-monitor.sh --threshold 70
```

### filesystem-analyzer.sh Issues
```bash
# Check permissions on target
ls -ld /var
stat /var

# Run with verbose find
find /var -type f 2>&1 | head -20

# Fix permission errors
sudo ./filesystem-analyzer.sh /root
```

### storage-report.sh Issues
```bash
# Validate JSON output
./storage-report.sh --format JSON | jq .

# Check HTML in browser for rendering
firefox /tmp/storage-report.html

# Look for CSV data issues
./storage-report.sh --format CSV | head -20
```

### lvm-helper.sh Issues
```bash
# Check LVM status
sudo pvdisplay
sudo vgdisplay
sudo lvdisplay

# Verify device access
ls -l /dev/vg0/

# Check filesystem mount
mount | grep /dev/vg0
```

---

## Performance Considerations

### For Large Filesystems (>1TB)
- Use `--detailed` flag sparingly with filesystem-analyzer.sh
- Increase disk-monitor check interval to 600+ seconds
- Run analyzer during off-peak hours
- Use CSV export to analyze data offline

### For Many Small Files (>1M files)
- Focus on inode usage with df -i
- Use filesystem-analyzer.sh without --detailed
- Consider find command resource usage

### For Production Systems
- Set appropriate thresholds in disk-monitor
- Configure email alerts for critical levels
- Schedule reports during low-traffic periods
- Use dry-run mode before LVM operations

---

## Integration Examples

### With Cron
```bash
# Daily storage analysis at 2 AM
0 2 * * * /usr/local/bin/filesystem-analyzer.sh / --csv >> /var/log/daily-storage.csv

# Hourly disk check
0 * * * * /usr/local/bin/storage-report.sh --format JSON > /tmp/storage-latest.json

# Weekly HTML report
0 9 * * 0 /usr/local/bin/storage-report.sh --format HTML --output /var/www/html/weekly.html
```

### With Monitoring Systems
```bash
# Nagios/Icinga
check_disk=/usr/local/bin/check-disk.sh
/usr/local/bin/disk-monitor.sh --threshold 85 | grep "CRITICAL"

# Prometheus
node_filesystem_avail_bytes / node_filesystem_size_bytes * 100
# Parse storage-report.sh JSON output into Prometheus format
```

### With Logging
```bash
# Send reports to syslog
./disk-monitor.sh 2>&1 | logger -t disk-monitor -p local0.info

# Analyze multiple servers
for server in server1 server2 server3; do
    ssh $server ./filesystem-analyzer.sh / --csv > analysis-$server.csv
done
```

---

## Security Considerations

- Scripts use `set -euo pipefail` for safety
- LVM operations require root (sudo)
- Dry-run mode available before destructive operations
- Interactive confirmations prevent accidental deletion
- Configuration backups before changes
- Validate device paths before operations

---

## References

- `disk-monitor.sh`: Process monitoring, threshold alerts, logging
- `filesystem-analyzer.sh`: Filesystem inspection, health checks
- `storage-report.sh`: Report generation, data export, visualization
- `lvm-helper.sh`: LVM management, interactive operations

For detailed options and examples, run each script with `--help`.
