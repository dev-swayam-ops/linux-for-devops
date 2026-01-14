# Scripts: Boot Process Utilities

This directory contains practical scripts for analyzing, validating, and optimizing the Linux boot process.

## Overview

All scripts follow these principles:
- Safe to run (no destructive operations by default)
- Comprehensive error handling
- Color-coded output for easy reading
- Detailed help messages

## Scripts

### 1. boot-analyzer.sh

**Purpose:** Comprehensive boot sequence analysis and performance metrics

**Features:**
- Overall boot time statistics
- Identification of slowest services
- Boot dependency visualization
- Firmware type detection (BIOS/UEFI)
- Current boot configuration summary
- Optimization suggestions

**Usage:**
```bash
# Quick summary
./boot-analyzer.sh --quick

# Full analysis with all checks
./boot-analyzer.sh --full

# Find slowest services
./boot-analyzer.sh --services

# Generate boot timeline visualization
./boot-analyzer.sh --timeline
```

**Example Output:**
```
Linux Boot - Quick Summary
Kernel: 5.15.0-56-generic (x86_64)
Current Boot Parameters: root=UUID=abc ro quiet splash

Overall Boot Time:
  Startup finished in 2.341s (kernel) + 15.234s (userspace) = 17.575s

Top 15 Slowest Services:
  5.234s snapd.service
  3.123s apt-daily.service
  2.456s ssh.service
```

**Common Use Cases:**
- Performance troubleshooting: Find slow services
- Boot optimization: Identify candidates for disabling
- Documentation: Generate boot timeline for analysis

---

### 2. grub-config-validator.sh

**Purpose:** Validate GRUB configuration and detect common issues

**Features:**
- GRUB installation verification
- Configuration file validation
- Boot partition health check
- Menu entry verification
- GRUB password configuration check
- Automated repair suggestions

**Usage:**
```bash
# Full validation (check everything)
sudo ./grub-config-validator.sh --full

# Check only configuration files
./grub-config-validator.sh --config

# Backup current GRUB configuration
sudo ./grub-config-validator.sh --backup

# Attempt automatic repair
sudo ./grub-config-validator.sh --repair
```

**Example Output:**
```
GRUB Configuration Validator
✓ GRUB2 tools installed
✓ /etc/default/grub exists
✓ /boot/grub/grub.cfg exists
ℹ GRUB timeout: 5s
✓ Boot menu timeout: 5s
Number of boot entries: 3
```

**Common Use Cases:**
- Verify GRUB after updates
- Detect configuration problems before booting
- Backup GRUB before making changes
- Troubleshoot boot menu issues

---

### 3. kernel-param-optimizer.sh

**Purpose:** Analyze kernel parameters and suggest optimizations

**Features:**
- Current parameter analysis
- Boot time optimization suggestions
- Performance tuning recommendations
- Hardware-specific suggestions
- Debugging options guidance
- Security parameter analysis
- Configuration templates

**Usage:**
```bash
# Analyze current parameters
./kernel-param-optimizer.sh --analyze

# Get all optimization suggestions
./kernel-param-optimizer.sh --suggest

# Performance-focused optimizations
./kernel-param-optimizer.sh --performance

# Boot-time focused optimizations
./kernel-param-optimizer.sh --boot
```

**Example Output:**
```
Current Kernel Boot Parameters:
  BOOT_IMAGE=/boot/vmlinuz-5.15.0-56-generic
  root=UUID=abc123
  ro
  quiet
  splash

Boot Time Optimizations:
✓ quiet parameter is set (reduces boot messages)
ℹ loglevel: NOT SET (default is 7, very verbose)
→ Suggestion: Add 'loglevel=3' to reduce kernel message verbosity
```

**Common Use Cases:**
- Tune kernel parameters for workload
- Get optimization recommendations
- Generate GRUB configuration templates
- Debug hardware-specific issues

---

## How to Use These Scripts

### Preparation

1. **Make scripts executable:**
   ```bash
   chmod +x boot-analyzer.sh
   chmod +x grub-config-validator.sh
   chmod +x kernel-param-optimizer.sh
   ```

2. **Optional: Add to PATH**
   ```bash
   sudo cp *.sh /usr/local/bin/
   # Then run directly: boot-analyzer.sh --quick
   ```

### Typical Workflow

1. **Analyze current boot performance:**
   ```bash
   ./boot-analyzer.sh --quick
   ```

2. **Identify slow services:**
   ```bash
   ./boot-analyzer.sh --services
   ```

3. **Check GRUB configuration:**
   ```bash
   sudo ./grub-config-validator.sh --full
   ```

4. **Get optimization suggestions:**
   ```bash
   ./kernel-param-optimizer.sh --suggest
   ```

5. **Apply recommended changes:**
   ```bash
   # Edit GRUB defaults
   sudo nano /etc/default/grub
   
   # Regenerate GRUB config
   sudo update-grub
   
   # Reboot to apply
   sudo reboot
   ```

---

## Script Details

### All Scripts Share These Features

**Help Support:**
```bash
./script.sh --help
./script.sh -h
```

**Error Handling:**
- Scripts use `set -euo pipefail` for safe execution
- Clear error messages indicate what went wrong
- No destructive operations without explicit confirmation

**Output:**
- Color-coded for easy scanning (green=OK, yellow=warning, red=error)
- Structured sections with headers
- Detailed explanations of findings

---

## Advanced Usage

### Run All Checks Sequentially

```bash
#!/bin/bash
# Complete boot system analysis

echo "=== Boot Performance Analysis ==="
./boot-analyzer.sh --quick

echo ""
echo "=== GRUB Configuration Check ==="
sudo ./grub-config-validator.sh --config

echo ""
echo "=== Kernel Parameter Suggestions ==="
./kernel-param-optimizer.sh --analyze
```

### Generate Comprehensive Boot Report

```bash
# Create a timestamped report
./boot-analyzer.sh --full > boot-report-$(date +%Y%m%d).txt
```

### Monitor Boot Performance Over Time

```bash
# Run analysis daily
0 8 * * * /home/user/scripts/boot-analyzer.sh --quick >> /tmp/boot-performance.log
```

---

## Troubleshooting

### Script Won't Run

**Error:** `bash: ./boot-analyzer.sh: Permission denied`

**Fix:**
```bash
chmod +x boot-analyzer.sh
```

### Missing Commands

**Error:** `command not found`

**Fix:**
- Install required tools: `sudo apt install systemd-tools`
- Some features require specific packages (efibootmgr, etc.)

### Permission Denied

**Error:** `Operation not permitted`

**Fix:**
- Run with `sudo` where needed
- Scripts indicate which operations need elevated privileges

---

## Safety Notes

✓ **Safe Operations** (don't require sudo):
- Analyzing current parameters
- Reading logs
- Displaying configuration

⚠️ **Elevated Privilege Required** (use sudo):
- GRUB configuration validation
- Bootloader operations
- Kernel parameter modification

❌ **Destructive** (use only if necessary):
- Repair mode in grub-config-validator
- System modifications

---

## Related Documentation

- [01-theory.md](../01-theory.md) - Boot process concepts
- [02-commands-cheatsheet.md](../02-commands-cheatsheet.md) - Boot commands reference
- [03-hands-on-labs.md](../03-hands-on-labs.md) - Practical boot exercises

---

## Contributing Improvements

These scripts are designed to be:
- **Maintainable** - Clear variable names, comments
- **Extensible** - Easy to add new checks
- **Cross-distribution** - Work on Debian, Ubuntu, RHEL, CentOS

Suggestions for improvements welcome!
