# Package Management Scripts Documentation

Complete reference for three production-ready package management tools. These scripts simplify common operations across Debian/Ubuntu and RHEL/CentOS systems.

---

## Table of Contents

1. [Package Manager Wrapper](#package-manager-wrapper)
2. [Dependency Resolver](#dependency-resolver)
3. [APT Update Helper](#apt-update-helper)
4. [Common Workflows](#common-workflows)
5. [Troubleshooting](#troubleshooting)

---

## Package Manager Wrapper

### Purpose

Unified interface for package management across APT (Debian/Ubuntu) and YUM/DNF (RHEL/CentOS). Automatically detects system type and uses appropriate commands.

### Features

- **Auto-detection** of package manager (apt, yum, dnf)
- **Unified commands** across different systems
- **Color output** for better readability
- **Comprehensive help** with examples
- **Safe operations** with sudo requirements

### Installation

```bash
# Copy script to system
sudo cp package-manager.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/package-manager.sh

# Create alias for easier use
alias pkg="/usr/local/bin/package-manager.sh"
```

### Usage

**Basic Syntax:**
```bash
./package-manager.sh <command> <package>
```

### Commands Reference

#### Search Commands

```bash
# Search for packages
pkg search curl

# Expected output:
# curl - command line tool for transferring data with URLs
# curl-www - simple web browser
```

#### Information Commands

```bash
# Get detailed package info
pkg info curl

# Show all available versions
pkg versions curl

# Show package dependencies
pkg depends curl

# Show reverse dependencies (what uses this)
pkg rdepends nginx

# Check if package is installed
pkg status curl
```

#### Installation Commands

```bash
# Install package (requires sudo)
sudo pkg install curl

# Install multiple packages
sudo pkg install curl nginx openssl

# Check if would install before actually installing
pkg versions curl  # See what version available
sudo pkg install curl
```

#### Removal Commands

```bash
# Remove package (keep config)
sudo pkg remove curl

# Completely remove (remove config too)
sudo pkg purge curl
```

#### System Commands

```bash
# Update package list (Ubuntu/Debian only, requires sudo)
sudo pkg update

# Upgrade all packages (safe - requires sudo)
sudo pkg upgrade

# Full system upgrade (aggressive - requires sudo)
sudo pkg dist-upgrade

# List installed packages
pkg list

# List packages with updates available
pkg list-upgradable

# Remove unused dependencies (requires sudo)
sudo pkg autoremove

# Clean package cache (requires sudo)
sudo pkg clean

# Check system health
pkg check
```

### Real-World Examples

**Example 1: Installing Web Server Stack**

```bash
# Search for packages
pkg search "nginx"
pkg search "php"

# Install with dependencies
sudo pkg install nginx php-fpm php-cli

# Verify installation
pkg status nginx
pkg status php-fpm

# Check dependencies were installed
pkg depends nginx
```

**Example 2: System Update**

```bash
# Check for updates
pkg list-upgradable

# Preview what would be upgraded
pkg versions vim

# Safely upgrade
sudo pkg upgrade

# Clean up old packages
sudo pkg clean
```

**Example 3: Troubleshooting**

```bash
# Check if curl is installed
pkg status curl

# If not installed:
sudo pkg install curl

# Verify installation
curl --version
```

### Integration with Other Tools

**With ansible-playbook:**
```yaml
- name: Install packages using wrapper
  command: /usr/local/bin/package-manager.sh install {{ item }}
  with_items:
    - curl
    - wget
    - vim
```

**With shell scripts:**
```bash
#!/bin/bash
install_package() {
    local pkg=$1
    sudo /usr/local/bin/package-manager.sh install "$pkg"
}

install_package "nginx"
install_package "curl"
```

---

## Dependency Resolver

### Purpose

Diagnose and fix broken package dependencies. Identifies missing libraries, version conflicts, and suggests solutions.

### Features

- **Broken package detection** across distributions
- **Automatic repair** with configurable strategies
- **Dependency analysis** for specific packages
- **Conflict detection** between packages
- **Comprehensive reporting** of system state
- **Logging** of all operations

### Installation

```bash
sudo cp dependency-resolver.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/dependency-resolver.sh

alias dep-resolver="/usr/local/bin/dependency-resolver.sh"
```

### Usage

**Basic Syntax:**
```bash
sudo ./dependency-resolver.sh <option>
```

### Commands Reference

#### Health Check Commands

```bash
# Check for broken packages
sudo dep-resolver --check

# Expected output (if healthy):
# [SUCCESS] No broken packages found

# If broken:
# [ERROR] Broken packages detected!
# ...list of issues...
```

#### Analysis Commands

```bash
# Analyze dependencies for specific package
dep-resolver --analyze curl

# Expected output shows:
# - Direct dependencies (what curl needs)
# - Reverse dependencies (what depends on curl)
# - Version information

# Verify a package's dependencies are satisfied
dep-resolver --verify nginx

# Find package conflicts
dep-resolver --conflicts

# Show orphaned packages (unused dependencies)
dep-resolver --show-orphans
```

#### Fix Commands

```bash
# Attempt to fix broken packages (requires sudo)
sudo dep-resolver --fix

# Remove unused dependencies
sudo dep-resolver --autoremove

# Generate detailed report
dep-resolver --report
```

### Real-World Examples

**Example 1: Fixing Broken Dependencies**

```bash
# Detect issues
sudo dep-resolver --check

# Output: [ERROR] Broken packages detected!
# Package A depends on version 1.0 of Library X
# But version 2.0 is installed

# Attempt automatic fix
sudo dep-resolver --fix

# If that works:
# [SUCCESS] System is now healthy

# If not, analyze the issue
dep-resolver --analyze package-a
```

**Example 2: Understanding Package Dependencies**

```bash
# Show what nginx needs
dep-resolver --analyze nginx

# Output shows:
# Direct Dependencies:
#   nginx depends on libpcre3
#   nginx depends on zlib1g
#   nginx depends on libssl1.1

# Reverse Dependencies:
#   php-fpm depends on nginx
#   certbot-nginx depends on nginx
```

**Example 3: Pre-Update Check**

```bash
# Before doing apt upgrade:
sudo dep-resolver --check

# Generate state report
dep-resolver --report

# If healthy, proceed with update
sudo apt update && sudo apt upgrade -y

# After update, verify again
sudo dep-resolver --check
```

### Integration with Monitoring

**Cron job for daily health check:**
```bash
# /etc/cron.daily/check-dependencies
#!/bin/bash
/usr/local/bin/dependency-resolver.sh --check >> /var/log/dep-check.log 2>&1
```

**With Nagios/Icinga:**
```bash
#!/bin/bash
# Check for broken packages
if sudo /usr/local/bin/dependency-resolver.sh --check &>/dev/null; then
    echo "OK - No broken packages"
    exit 0
else
    echo "CRITICAL - Broken packages detected"
    exit 2
fi
```

---

## APT Update Helper

### Purpose

Automate system updates with safety checks, backup capability, and rollback options. Provides staged upgrades with health monitoring.

### Features

- **Safe update strategies** (apt upgrade vs dist-upgrade)
- **Automatic backups** before updates
- **Health checks** before and after
- **Preview of changes** before applying
- **Security-only updates** option
- **Unattended update setup** for automation
- **Complete logging** for audit trail

### Installation

```bash
# Ubuntu/Debian only (requires apt)
sudo cp apt-update-helper.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/apt-update-helper.sh

alias apt-helper="/usr/local/bin/apt-update-helper.sh"
```

### Usage

**Basic Syntax:**
```bash
sudo ./apt-update-helper.sh <option>
```

### Commands Reference

#### Check and Preview

```bash
# Check for available updates (can run without sudo)
sudo apt-helper --check

# Expected output:
# [i] Checking for available updates...
# [i] Packages available for upgrade:
# curl/focal-updates 7.68.0-1ubuntu1.7 amd64 [upgradable from: 7.68.0-1ubuntu1]
# openssl/focal-updates ...

# Preview what would be changed
sudo apt-helper --preview

# Shows:
# Safe Upgrade (apt upgrade):
#   X upgraded, 0 newly installed, 0 to remove
# Full Upgrade (apt dist-upgrade):
#   X upgraded, Y newly installed, Z to remove
```

#### Update Operations

```bash
# Safe upgrade (RECOMMENDED for production)
sudo apt-helper --safe-update

# Prompts: This will upgrade your system. Continue? (y/N)
# Then performs:
#   1. Save current state
#   2. Check system health
#   3. Preview changes
#   4. Apply upgrade
#   5. Verify system health

# Full system upgrade (AGGRESSIVE)
sudo apt-helper --full-update

# Requires double confirmation:
# Type 'upgrade my system' to continue:

# Security updates only
sudo apt-helper --security-only
```

#### Maintenance Operations

```bash
# Clean package cache (free disk space)
sudo apt-helper --clean

# Show system update status
apt-helper --status

# Expected output:
# System Information:
#   Hostname: myserver
#   Kernel: 5.4.0-42-generic
#   Distro: Ubuntu 20.04 LTS
# Package Statistics:
#   Total installed: 847
#   Available upgrades: 23
# ...
```

#### Automation Setup

```bash
# Setup automatic security updates
sudo apt-helper --unattended-setup

# Then unattended-upgrades will:
#   - Update package index daily
#   - Install security patches automatically
#   - Send email notifications
```

#### Rollback

```bash
# Show available backups
sudo apt-helper --rollback

# Output shows:
# Available backups:
#   /var/backups/apt-update-helper/packages-20240315-143022.txt
#   /var/backups/apt-update-helper/packages-20240314-103456.txt

# To restore (manual):
sudo dpkg --set-selections < /var/backups/apt-update-helper/packages-20240315-143022.txt
sudo apt dselect-upgrade
```

### Real-World Examples

**Example 1: Safe Production Update**

```bash
# 1. Check what's available
sudo apt-helper --check

# 2. Preview changes
sudo apt-helper --preview

# 3. Perform safe upgrade (only upgrades, never removes)
sudo apt-helper --safe-update

# 4. Verify system
systemctl status nginx   # Check web server
curl http://localhost   # Test application

# 5. Cleanup
sudo apt-helper --clean
```

**Example 2: Security Patch Application**

```bash
# Apply security updates immediately
sudo apt-helper --security-only

# Verify critical services
systemctl restart ssh
curl https://example.com
```

**Example 3: Full System Maintenance (Careful)**

```bash
# On development system (non-critical):

# 1. Backup everything first
sudo apt-helper --preview

# 2. Full upgrade
sudo apt-helper --full-update

# 3. Check system
sudo apt-helper --status
apt check

# 4. If issues occur:
sudo apt-helper --rollback
```

### Integration with Cron

**Automatic daily security updates:**
```bash
# /etc/cron.d/apt-update-helper
# Run daily at 2 AM
0 2 * * * root /usr/local/bin/apt-update-helper.sh --security-only >> /var/log/apt-security.log 2>&1
```

**Weekly full update on non-production:**
```bash
# /etc/cron.weekly/apt-full-update
#!/bin/bash
# Only on development systems
if [[ "$(hostname)" == "dev-server" ]]; then
    sudo /usr/local/bin/apt-update-helper.sh --full-update
fi
```

### Log Files

All operations logged to:
```
/var/log/apt-update-helper.log
```

View recent operations:
```bash
tail -50 /var/log/apt-update-helper.log
grep "SUCCESS" /var/log/apt-update-helper.log  # Successful updates
grep "ERROR" /var/log/apt-update-helper.log    # Failed operations
```

---

## Common Workflows

### Workflow 1: Daily System Maintenance

```bash
# 1. Check for updates
pkg list-upgradable

# 2. Review what would change
sudo apt-helper --preview

# 3. Install security updates
sudo apt-helper --security-only

# 4. Cleanup
sudo apt-helper --clean

# 5. Verify health
pkg check
```

### Workflow 2: Emergency Dependency Fix

```bash
# 1. Detect problem
sudo dep-resolver --check

# 2. Analyze affected package
dep-resolver --analyze <broken-package>

# 3. Attempt automatic fix
sudo dep-resolver --fix

# 4. Verify fix worked
sudo dep-resolver --check
```

### Workflow 3: Adding New Software Stack

```bash
# 1. Search for packages
pkg search "docker"
pkg search "docker-compose"

# 2. Analyze dependencies
dep-resolver --analyze docker.io

# 3. Install packages
sudo pkg install docker.io docker-compose

# 4. Verify installation
pkg status docker.io
docker --version
```

### Workflow 4: Pre-Update System Check

```bash
# Before any major update:

# 1. Create backup
sudo apt-helper --preview

# 2. Check dependencies
sudo dep-resolver --check

# 3. Show current state
apt-helper --status

# 4. List held packages
apt-mark showhold

# 5. Proceed or resolve issues
```

---

## Troubleshooting

### Issue: "Could not get lock"

**Problem:**
```
E: Could not get lock /var/lib/apt/lists/lock
```

**Solution:**
```bash
# Wait for other apt to finish
sleep 10

# Or find and kill the blocking process
sudo lsof /var/lib/apt/lists/lock

# Then try again
sudo apt-helper --check
```

### Issue: Broken Dependencies After Update

**Problem:**
```
E: Unable to correct problems, you have held broken packages
```

**Solution:**
```bash
# 1. Use dependency resolver
sudo dep-resolver --check

# 2. Let it attempt fix
sudo dep-resolver --fix

# 3. If still broken, analyze specific package
dep-resolver --analyze <package>

# 4. Manual fix
sudo apt --fix-broken install
```

### Issue: Package Not Found

**Problem:**
```
E: Unable to locate package curl
```

**Solution:**
```bash
# 1. Update package list first
sudo apt update

# 2. Search for package name
pkg search curl

# 3. Check if it exists in your repositories
pkg versions curl

# 4. If not available, add repository if needed
```

### Issue: Disk Space for Updates

**Problem:**
```
E: You don't have enough free space in /var/cache/apt
```

**Solution:**
```bash
# 1. Clean cache
sudo apt-helper --clean

# 2. Check space
df -h /var

# 3. Remove unused packages
sudo pkg autoremove

# 4. Then try update again
```

---

## Best Practices

### Before Updates

1. **Always preview first**: `sudo apt-helper --preview`
2. **Check dependencies**: `sudo dep-resolver --check`
3. **Backup package list**: Done automatically by apt-helper
4. **Schedule maintenance window**: Never update critical production systems during business hours

### During Updates

1. **Use safe upgrade on production**: `sudo apt-helper --safe-update`
2. **Use full upgrade only on development**: `sudo apt-helper --full-update`
3. **Monitor system**: Watch logs and services during update
4. **Have rollback plan**: Know how to revert if needed

### After Updates

1. **Verify health**: `sudo dep-resolver --check`
2. **Test critical services**: `systemctl status <service>` for each critical service
3. **Check logs**: `journalctl -n 50` for recent errors
4. **Update documentation**: Record what was updated and any changes made

### Automation

1. **Setup unattended updates for security patches**: `sudo apt-helper --unattended-setup`
2. **Monitor with cron jobs**: Check system health daily
3. **Log everything**: All scripts output to `/var/log`
4. **Alert on failures**: Set up email notifications

### Security

1. **Never run updates as non-root**: Always use `sudo`
2. **Verify package sources**: Check `/etc/apt/sources.list`
3. **Keep keys updated**: `sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys <KEY>`
4. **Apply security updates immediately**: `sudo apt-helper --security-only`

---

## Performance Tips

### Speed Up Updates

```bash
# Use faster mirror
sudo sed -i 's/archive.ubuntu.com/mirror.example.com/' /etc/apt/sources.list
sudo apt update

# Clean cache before large update
sudo apt-helper --clean

# Parallel download (apt.conf)
echo 'Acquire::http::Pipeline-Depth "5";' | sudo tee -a /etc/apt/apt.conf.d/99parallel
```

### Monitor Performance

```bash
# Show update progress
sudo apt-helper --safe-update

# Watch disk during update
watch -n 1 'df -h / | tail -1'

# Monitor network usage
iftop -i eth0
```

---

## Summary

These three scripts provide comprehensive package management capabilities:

- **package-manager.sh**: Cross-distro package operations
- **dependency-resolver.sh**: Diagnostic and repair tool
- **apt-update-helper.sh**: Safe and auditable update procedures

Master these tools to become proficient at Linux package management across all major distributions.
