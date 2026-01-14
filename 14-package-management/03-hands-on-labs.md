# Package Management Hands-On Labs

Complete practical exercises for package management on Linux systems. All labs are non-destructive and designed for safe experimentation.

**Time Estimate:** 3-3.5 hours for all 8 labs
**Prerequisites:** Modules 01, 02, 06, 13 (or basic Linux command knowledge)
**Safe to Run:** Yes - all labs are read-only or easily reversible

---

## Lab 1: Searching and Installing Packages (45 minutes)

### Objective
Learn to search for packages and understand package information before installation.

### Prerequisites
- Ubuntu/Debian system (or CentOS/RHEL with yum/dnf)
- Internet connection for downloading packages
- Basic sudo access

### Step 1: Update Package Lists

```bash
# UBUNTU/DEBIAN:
sudo apt update

# Expected output:
# Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
# Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
# Reading package lists... Done
```

**Why**: Package lists must be fresh to find the latest versions.

### Step 2: Search for a Package

```bash
# Search for curl
apt search curl

# Expected output shows curl with description
curl - command line tool for transferring data with URLs
curl-www - simple web browser in perl
```

### Step 3: Get Detailed Information

```bash
# Get full package details
apt show curl

# Expected output:
# Package: curl
# Version: 7.68.0-1ubuntu1.7
# Priority: optional
# Section: web
# Maintainer: Ubuntu Developers
# Installed-Size: 404 kB
# Depends: libc6 (>= 2.17), libcurl4 (= 7.68.0-1ubuntu1.7)
# ...
```

**Analysis**: Notice the dependencies - libc6 and libcurl4.

### Step 4: Check Dependencies

```bash
# See what curl depends on
apt-cache depends curl

# Expected output:
# curl
#   Depends: libc6 (>= 2.17)
#   Depends: libcurl4 (= 7.68.0-1ubuntu1.7)
#   Depends: zlib1g (>= 1:1.2.3.4)
```

**Understanding**: curl needs these exact versions of libraries. apt will handle this automatically.

### Step 5: Preview Installation

```bash
# See what would be installed WITHOUT actually installing
apt install --simulate curl

# Expected output:
# Reading package lists... Done
# Building dependency tree...
# The following packages will be NEWLY installed:
#   libcurl4
# The following NEW packages will be installed:
#   curl libcurl4 ...
```

### Step 6: Check if Already Installed

```bash
# See if curl is installed
dpkg -s curl

# Two possible outputs:
# Case 1 (not installed):
# dpkg: error: package 'curl' is not installed and no information is available

# Case 2 (installed):
# Package: curl
# Status: install ok installed
# Installed-Size: 404
```

### Step 7: Install the Package

```bash
# Install curl (will prompt for password)
sudo apt install curl

# Type 'y' and press Enter when asked:
# The following packages will be installed:
#   curl libcurl4
# Processing triggers for man-db ...
```

### Step 8: Verify Installation

```bash
# Check curl is installed
dpkg -s curl | grep Status

# Expected output:
# Status: install ok installed

# Test curl works
curl --version

# Expected output:
# curl 7.68.0 (x86_64-pc-linux-gnu)
# ...
```

### Step 9: Find What Package Provides a Command

```bash
# Use apt-file to find packages
apt-file search /usr/bin/wget

# Expected output:
# wget: /usr/bin/wget

# Or find where a file belongs
dpkg -S /usr/bin/curl

# Expected output:
# curl: /usr/bin/curl
```

### Verification

```bash
# All commands should work without errors:
curl --version                    # ✓ curl installed
apt show curl | head -5           # ✓ package info works
apt-cache depends curl | head     # ✓ dependencies shown
```

### Troubleshooting

- **"E: Could not get lock"**: Another apt process running. Wait or run `lsof /var/lib/apt/lists/lock`
- **"Package not found"**: Run `apt update` first
- **"sudo: command not found"**: Use `su -` to become root instead

---

## Lab 2: Understanding Package Versions and Installation (50 minutes)

### Objective
Learn about version management, available versions, and version pinning.

### Step 1: Show Available Versions

```bash
# See all available versions of a package
apt-cache policy curl

# Expected output:
# curl:
#   Installed: 7.68.0-1ubuntu1.7
#   Candidate: 7.68.0-1ubuntu1.7
#   Version table:
#      7.68.0-1ubuntu1.7 500
#         500 http://archive.ubuntu.com/ubuntu focal-updates/main
#      7.68.0-1ubuntu1 500
#         500 http://archive.ubuntu.com/ubuntu focal/main
```

**Understanding**: 
- "Installed" = currently installed version
- "Candidate" = version that would be installed if we upgrade
- "Version table" = all available versions with their sources

### Step 2: Check What Will Be Upgraded

```bash
# See which packages have updates available
apt list --upgradable

# Expected output (if any updates):
# curl/focal-updates 7.68.0-1ubuntu1.7 amd64 [upgradable from: 7.68.0-1ubuntu1]

# Check specific package
apt-cache policy vim

# Shows available versions
```

### Step 3: Install Specific Version

```bash
# Install particular version if available
# First find exact version name
apt-cache policy curl | grep "Version table" -A 5

# Then install:
sudo apt install curl=7.68.0-1ubuntu1

# Expected output:
# The following packages will be DOWNGRADED:
#   curl
# Processing ...
```

**Use case**: Pin to known-working version for compatibility.

### Step 4: Mark Package to Hold (Pin Version)

```bash
# Prevent curl from being upgraded
sudo apt-mark hold curl

# Expected output:
# curl set to manually installed.

# Verify it's on hold
apt-mark showhold

# Expected output:
# curl
```

### Step 5: Test Upgrade With Hold

```bash
# Try to upgrade (curl won't be touched)
sudo apt update && sudo apt upgrade -y

# curl will NOT be in the upgrade list:
# The following packages will be upgraded:
#   (other packages, but NOT curl)
```

### Step 6: Unhold Package

```bash
# Allow curl to be upgraded again
sudo apt-mark unhold curl

# Expected output:
# Cancelled setting 'curl' to manually installed.

# Verify it's no longer held
apt-mark showhold

# Expected output (empty, curl not listed):
# (nothing)
```

### Step 7: Mark Package as Automatic

```bash
# Mark curl as automatically installed (dependency)
sudo apt-mark auto curl

# Check it's marked automatic
apt-mark showauto | grep curl

# Expected output:
# curl
```

**Understanding**: Automatic packages can be removed by autoremove if nothing depends on them.

### Step 8: Mark Package as Manual

```bash
# Mark curl as manually installed
sudo apt-mark manual curl

# Check it's marked manual
apt-mark showmanual | grep curl

# Expected output:
# curl
```

### Step 9: Compare Version Strings

```bash
# Show how version numbers work
apt-cache policy curl wget vim | grep "Version table" -A 3

# Example output:
# curl: Version table:
#      7.68.0-1ubuntu1.7 500
#      7.68.0-1ubuntu1 500
# wget: Version table:
#      1.20.3-1ubuntu2.1 500
```

**Parsing versions**:
```
7.68.0-1ubuntu1.7
^     ^ ^ ^^^^^^^ ^
|     | | |       +-- Ubuntu patch number (security updates)
|     | | +---------- Ubuntu release
|     | +----------- Debian patch level
|     +----------- Minor version
+----------- Major version
```

### Verification

```bash
# All of these should work without errors:
apt-cache policy curl              # ✓ Show versions
apt-mark showhold                  # ✓ Show held packages
apt list --upgradable              # ✓ Show upgradable packages
```

---

## Lab 3: Update and Upgrade Strategies (45 minutes)

### Objective
Understand the difference between update and upgrade, and when to use each.

### Step 1: Understand apt update

```bash
# Update only refreshes the package list
sudo apt update

# Expected output:
# Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
# Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
# Reading package lists... Done
```

**Key point**: No packages installed, just list refreshed.

### Step 2: Check What Needs Upgrading

```bash
# See what would be upgraded
apt list --upgradable

# Or use the full simulator:
sudo apt upgrade --simulate

# Expected output (if updates available):
# The following packages will be upgraded:
#   package1 package2 ...
# X upgraded, 0 newly installed, 0 to remove
```

### Step 3: Safe Upgrade

```bash
# Upgrade only installed packages (safe)
sudo apt upgrade

# When prompted, review what's being upgraded:
# The following packages will be upgraded:
#   openssl zlib1g ...
# Do you want to continue? [Y/n] 

# Type 'y' and press Enter
```

**Important**: apt upgrade never installs NEW packages or removes packages.

### Step 4: Understand Unmet Dependencies

```bash
# Sometimes updates need additional setup
# Check for any issues
apt check

# Expected output:
# 0 broken packages
# (if any issues, see Troubleshooting section)
```

### Step 5: Show What dist-upgrade Would Do

```bash
# dist-upgrade can install/remove packages (risky)
sudo apt dist-upgrade --simulate

# Expected output shows more changes:
# The following NEW packages will be installed:
#   (new packages needed for upgrades)
# The following packages will be REMOVED:
#   (packages that conflict)
```

**Warning**: dist-upgrade is aggressive. On production systems, test first.

### Step 6: Autoremove Unused Dependencies

```bash
# After upgrades, remove no-longer-needed packages
sudo apt autoremove --simulate

# Expected output (if anything to remove):
# The following packages will be REMOVED:
#   old-dependency-package
```

**Benefit**: Frees disk space, reduces attack surface.

### Step 7: Clean Package Cache

```bash
# Check cache size
du -sh /var/cache/apt

# Expected output:
# 245M    /var/cache/apt

# Remove old cached packages
sudo apt autoclean

# Remove ALL cached packages
sudo apt clean

# Check new size
du -sh /var/cache/apt

# Expected output (much smaller):
# 2.3M    /var/cache/apt
```

**Use case**: Free disk space on servers with limited storage.

### Step 8: Review Update Log

```bash
# See what packages were recently upgraded
grep "upgrade" /var/log/apt/history.log | tail -5

# Expected output:
# Upgrade: curl (7.68.0-1ubuntu1 -> 7.68.0-1ubuntu1.7), ...
```

### Step 9: Document System State

```bash
# Create list of installed packages
dpkg --get-selections > ~/my-packages.txt

# Check the file
head -20 ~/my-packages.txt

# Expected output:
# adduser                                         install
# apt                                             install
# base-files                                      install
```

**Use case**: Restore to this state later with `dpkg --set-selections < ~/my-packages.txt`

### Verification

```bash
# All these should work:
apt check                      # ✓ Check for issues
apt list --upgradable          # ✓ See upgradable packages
du -sh /var/cache/apt          # ✓ Check cache size
```

---

## Lab 4: Package Removal and Cleanup (40 minutes)

### Objective
Learn safe package removal and how to clean up system dependencies.

### Step 1: Install Test Packages

```bash
# Install some packages to remove later
sudo apt install tree wget

# Verify installed
dpkg -s tree wget | grep Status

# Expected output:
# Status: install ok installed (shown for each)
```

### Step 2: Remove vs Purge

```bash
# Remove tree (keep config files)
sudo apt remove tree

# When prompted: y (yes)
# Expected: tree command removed, but config stays

# Check tree is gone but config remains
which tree

# Expected output:
# (nothing - not in PATH)
```

### Step 3: Purge Package

```bash
# Purge wget (remove + config)
sudo apt purge wget

# When prompted: y (yes)

# Verify completely gone
dpkg -s wget

# Expected:
# dpkg: error: package 'wget' is not installed
```

**Difference**:
- `apt remove` = uninstall binaries, keep config (for reinstall)
- `apt purge` = uninstall everything (complete removal)

### Step 4: Reinstall Previously Removed Package

```bash
# Reinstall tree (config was kept)
sudo apt install tree

# It should remember your previous configuration
```

### Step 5: Install Package with Dependencies

```bash
# Install mariadb-server (has many dependencies)
sudo apt install --simulate mariadb-server | head -20

# Expected (many lines):
# The following NEW packages will be installed:
#   libmysqlclient21 libssl1.1 mariadb-common
#   mariadb-server mariadb-server-10.3 mysql-common ...
```

**Don't actually install** - just preview.

### Step 6: Check Dependencies with apt-cache

```bash
# See why a package is installed (what depends on it)
apt-cache rdepends curl

# Expected (shows what uses curl):
# curl
# Reverse Depends:
#   apt-listchanges
#   git-core
#   ...
```

### Step 7: Find Unused Dependencies

```bash
# See what could be removed
apt autoremove --simulate

# Expected (if anything):
# The following packages will be REMOVED:
#   old-unused-package
```

### Step 8: Remove Unused Automatically

```bash
# Actually remove unused dependencies
sudo apt autoremove

# Expected:
# The following packages will be REMOVED:
#   old-unused-package
# Do you want to continue? [Y/n] 
```

### Step 9: View Removal History

```bash
# See removal history
grep "Remove:" /var/log/apt/history.log | tail -5

# Shows what was removed
```

### Verification

```bash
# Verify removals worked:
dpkg -s tree   # Should show not installed
apt check      # Should show no broken packages
```

---

## Lab 5: Working with Repositories (55 minutes)

### Objective
Add, remove, and manage package repositories (PPAs).

### Step 1: View Current Repositories

```bash
# See standard repositories
cat /etc/apt/sources.list

# Expected output:
# deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
# deb http://archive.ubuntu.com/ubuntu focal-updates main restricted
# deb http://security.ubuntu.com/ubuntu focal-security main restricted
```

**Sections**:
- `main` = officially supported
- `universe` = community-maintained
- `restricted` = closed-source drivers
- `multiverse` = licensing issues

### Step 2: View PPA Sources

```bash
# See Personal Package Archives
ls /etc/apt/sources.list.d/

# Expected (if any PPAs added):
# ubuntu-toolchain-r-test-focal-sources.list
# other-ppa-sources.list

# View PPA content
cat /etc/apt/sources.list.d/ubuntu-toolchain-r-test-focal-sources.list

# Expected output:
# deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu focal main
```

### Step 3: Add a PPA

```bash
# Add Python PPA (example)
sudo add-apt-repository ppa:deadsnakes/ppa

# Expected output:
# PPA for newer Python versions
# Press [ENTER] to continue or ctrl-c to cancel adding it

# Press Enter to confirm

# New source file created:
ls /etc/apt/sources.list.d/ | grep deadsnakes

# Expected:
# deadsnakes-ubuntu-ppa-focal.list
```

### Step 4: Update After Adding PPA

```bash
# Update package list to include new PPA
sudo apt update

# Expected (includes deadsnakes repo):
# Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
# ...
# Get:N http://ppa.launchpad.net/deadsnakes/ppa focal InRelease
```

### Step 5: Search for Package from New PPA

```bash
# Show new Python versions from PPA
apt-cache policy python3.9

# Expected output:
# python3.9:
#   Candidate: 3.9.x-1
#   Version table:
#      3.9.x-1 500
#         500 http://ppa.launchpad.net/deadsnakes/ppa focal/main
```

### Step 6: Install from PPA

```bash
# Install newer Python from PPA
sudo apt install --simulate python3.9

# Expected:
# The following NEW packages will be installed:
#   python3.9

# Don't actually install to keep system clean
```

### Step 7: Trust Verification

```bash
# Check GPG keys for repositories
apt-key list

# Expected output:
# /etc/apt/trusted.gpg.d/ubuntu-toolchain-r_ubuntu_test.gpg
# -------------------------------------------------------
# pub   rsa4096 ... Key fingerprint: ...
```

**Important**: Only add PPAs from trusted sources.

### Step 8: Remove a PPA

```bash
# Remove the PPA we added
sudo add-apt-repository --remove ppa:deadsnakes/ppa

# Expected:
# [sudo] password for user:
# PPA for newer Python versions
# Press [ENTER] to continue or ctrl-c to cancel removing it

# Press Enter to confirm

# Update package list
sudo apt update

# Python 3.9 no longer available from that PPA
```

### Step 9: Enable/Disable Repository

```bash
# Temporarily disable a repository source
sudo sed -i 's/^deb /# deb /' /etc/apt/sources.list.d/some-ppa.list

# Update to reload
sudo apt update

# Re-enable:
sudo sed -i 's/^# deb /deb /' /etc/apt/sources.list.d/some-ppa.list

# Update again
sudo apt update
```

### Verification

```bash
# Verify current sources:
cat /etc/apt/sources.list        # ✓ Shows standard repos
ls /etc/apt/sources.list.d/      # ✓ Shows PPAs
apt-key list                     # ✓ Shows trusted keys
```

---

## Lab 6: Dependency Resolution and Broken Packages (50 minutes)

### Objective
Understand how dependencies work and how to fix broken packages.

### Step 1: Create Broken Dependency Situation

```bash
# This is educational - we'll simulate the issue

# First, understand current state
apt check

# Expected:
# 0 broken packages
```

### Step 2: Install Package with Specific Dependencies

```bash
# Install sendmail (has many dependencies)
sudo apt install --simulate sendmail-bin

# Expected output (simulated):
# The following NEW packages will be installed:
#   libbsd0 libmilter1.0.1 sendmail sendmail-bin 
#   sendmail-cf sendmail-doc ...
```

**Note**: Don't actually install unless you want these dependencies.

### Step 3: Check Complex Dependency Tree

```bash
# Install debtree to visualize dependencies
sudo apt install debtree

# Show dependency tree
debtree curl

# Expected output (ASCII tree):
# curl
#   libc6 (>= 2.17)
#   libcurl4 (= 7.68.0-1ubuntu1)
#     libc6 (>= 2.17)
#     libnghttp2-14 (>= 1.6.0)
#     libpsl5 (>= 1.14.5-1)
#     libssh2-1 (>= 1.8.0)
#     libssl1.1 (>= 1.1.0)
#     zlib1g (>= 1:1.2.3.4)
#       libc6 (>= 2.17)
```

### Step 4: Check Dependency Satisfaction

```bash
# Check if curl's dependencies are installed
apt-cache depends curl | grep Depends

# Expected:
# Depends: libc6 (>= 2.17)
# Depends: libcurl4 (= 7.68.0-1ubuntu1.7)

# Check if libcurl4 is installed
dpkg -s libcurl4 | grep Status

# Expected:
# Status: install ok installed
```

### Step 5: Understand Reverse Dependencies

```bash
# What packages depend on libcurl4?
apt-cache rdepends libcurl4 | head -20

# Expected output:
# libcurl4
# Reverse Depends:
#   apt-listchanges
#   curl
#   git-core
#   (many more)
```

**Important**: Removing libcurl4 would break all these packages.

### Step 6: Check for Broken Packages

```bash
# Check if any packages have broken dependencies
apt check

# Expected:
# 0 broken packages

# If there were broken packages:
# Reading state information... Done
# You might want to run 'apt --fix-broken install' to correct these.
```

### Step 7: Fix Missing Dependencies

```bash
# If dependencies are missing, fix them
sudo apt --fix-broken install

# Expected (if any issues):
# The following packages will be FIXED:
#   broken-package
# Do you want to continue? [Y/n]

# If nothing broken:
# Reading package lists... Done
```

### Step 8: Understand Hold Status

```bash
# Sometimes broken dependencies happen due to held versions
apt-mark showhold

# If something is held, but something else depends on a newer version,
# we might have conflicts. To resolve:

# Option 1: Unhold the package
sudo apt-mark unhold <package>

# Option 2: Install compatible version
sudo apt install --fix-missing
```

### Step 9: Use Aptitude for Complex Resolution

```bash
# Aptitude often handles complex conflicts better
sudo apt install aptitude

# Try to install with aptitude
sudo aptitude install <package>

# Aptitude will suggest solutions interactively:
# Accept recommended solution (type 'y')
# Or suggest alternatives (type 'n' to see alternatives)
```

### Verification

```bash
# Verify no broken packages:
apt check                    # ✓ 0 broken packages
debtree curl | head -10      # ✓ Dependency tree shown
apt-cache depends curl       # ✓ Dependencies listed
```

---

## Lab 7: System Update and Maintenance Procedures (55 minutes)

### Objective
Learn safe procedures for updating systems with minimal downtime and risk.

### Step 1: Document Current State

```bash
# Save list of installed packages
mkdir -p ~/backup
dpkg --get-selections > ~/backup/packages-before.txt

# Save held packages
apt-mark showhold > ~/backup/held-before.txt

# Show current versions
apt list --installed > ~/backup/installed-before.txt
```

### Step 2: Check for Held Packages

```bash
# See if anything is pinned to specific version
apt-mark showhold

# Expected (might be empty):
# (nothing, or list of held packages)

# If you want to hold something:
sudo apt-mark hold nginx

# Later release with:
sudo apt-mark unhold nginx
```

### Step 3: Dry Run of Update

```bash
# Preview what update will do (non-destructive)
sudo apt update --dry-run

# Preview what upgrade will do
sudo apt upgrade --dry-run

# Expected (shows changes):
# Reading package lists... Done
# The following packages can be upgraded:
#   ...
```

### Step 4: Perform Update

```bash
# Refresh package list (safe)
sudo apt update

# Expected:
# Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
# ...
# Reading package lists... Done
```

### Step 5: Perform Safe Upgrade

```bash
# Upgrade installed packages (safe - no removals)
sudo apt upgrade

# Review what will be upgraded:
# The following packages will be upgraded:
#   curl openssl zlib1g
# Do you want to continue? [Y/n]

# Type 'y' and press Enter
```

**Benefit**: apt upgrade only updates existing packages, never removes anything.

### Step 6: Check for Issues After Upgrade

```bash
# Verify system health
apt check

# Expected:
# 0 broken packages

# Check that critical services still run
systemctl status ssh
systemctl status networking

# Expected:
# ● ssh.service - OpenBSD Secure Shell server
#    Loaded: loaded
#    Active: active (running)
```

### Step 7: Remove Unused Dependencies

```bash
# After upgrade, remove no-longer-needed packages
sudo apt autoremove --dry-run

# If output shows packages to remove:
# The following packages will be REMOVED:
#   old-package

# Actually remove them:
sudo apt autoremove

# Type 'y' when prompted
```

### Step 8: Clean Disk Space

```bash
# Remove package cache
sudo apt autoclean    # Remove old package versions
sudo apt clean        # Remove all cached packages

# Check new disk usage
df -h /var

# Especially useful on servers with limited storage
```

### Step 9: Verify System Health After Maintenance

```bash
# Run comprehensive checks
apt check                    # ✓ No broken packages
systemctl status ssh         # ✓ SSH working
curl https://example.com     # ✓ Network working
journalctl --since "5 min"   # ✓ No error messages

# Compare current state to backup
dpkg --get-selections > ~/backup/packages-after.txt
diff ~/backup/packages-before.txt ~/backup/packages-after.txt | head -20
```

### Complete Maintenance Script

```bash
#!/bin/bash
# Safe system update procedure

echo "Step 1: Backup current state"
mkdir -p ~/backup
dpkg --get-selections > ~/backup/packages-$(date +%Y%m%d).txt

echo "Step 2: Update package list"
sudo apt update

echo "Step 3: Check system health"
apt check

echo "Step 4: Preview upgrade"
sudo apt upgrade --simulate

echo "Step 5: Perform upgrade"
sudo apt upgrade -y

echo "Step 6: Remove unused packages"
sudo apt autoremove -y

echo "Step 7: Clean cache"
sudo apt clean

echo "Step 8: Verify health"
apt check
echo "Update complete!"
```

### Verification

```bash
# All of these should succeed:
apt check                           # ✓ No broken packages
diff ~/backup/packages-before.txt ~/backup/packages-after.txt  # ✓ Shows changes
curl https://example.com           # ✓ Network still works
```

---

## Lab 8: Troubleshooting Package Problems (50 minutes)

### Objective
Diagnose and fix common package management issues.

### Common Issue 1: "Could Not Get Lock"

**Problem:**
```
E: Could not get lock /var/lib/apt/lists/lock - open (11: Resource temporarily unavailable)
```

**Cause**: Another apt process is running (apt update, unattended-upgrades, snap)

**Solution:**
```bash
# Find what's using apt
sudo lsof /var/lib/apt/lists/lock

# Expected output shows the process holding the lock:
# COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
# apt-get   12345 root   10w   REG  ...  /var/lib/apt/lists/lock

# Wait for it to finish, or if stuck:
sudo kill 12345

# Or force unlock:
sudo rm /var/lib/apt/lists/lock
sudo apt update

# Or wait for automatic removal of lock:
sleep 60 && sudo apt update
```

### Common Issue 2: "Unable to Correct Problems, Held Broken Packages"

**Problem:**
```
E: Unable to correct problems, you have held broken packages.
```

**Cause**: Package dependencies cannot be satisfied

**Solution:**
```bash
# Check what's wrong
apt check

# Show broken packages
sudo apt --fix-broken install --dry-run

# Try automatic fix
sudo apt --fix-broken install

# If that doesn't work:
# Check what packages are held
apt-mark showhold

# Unhold problematic packages
sudo apt-mark unhold <package>

# Try again
sudo apt install -f
```

### Common Issue 3: "Dependency is not installable"

**Problem:**
```
E: Unable to locate package libcurl4
E: Could not find a version for the dependency 'libcurl4'
```

**Cause**: Repository doesn't have the required version

**Solution:**
```bash
# Update package list (might be out of date)
sudo apt update

# Check available versions
apt-cache policy libcurl4

# If not available in current repos, add the right repository:
sudo add-apt-repository <appropriate-ppa>
sudo apt update

# Or search for alternative package
apt-cache search curl | grep library

# Use alternative package name
sudo apt install <alternative-package>
```

### Common Issue 4: "Version Problems"

**Problem:**
```
The following packages have unmet dependencies:
  nginx : Depends: libpcre3 but it is not going to be installed
```

**Cause**: Version conflict or dependency chain broken

**Solution:**
```bash
# Check the actual dependency
apt-cache depends nginx

# See what version is available
apt-cache policy libpcre3

# Install step-by-step, handling each dependency
sudo apt install libpcre3
sudo apt install nginx

# Or use dist-upgrade to resolve automatically
sudo apt dist-upgrade --dry-run
sudo apt dist-upgrade
```

### Common Issue 5: "Package Cache Corruption"

**Problem:**
```
E: Error reading the database
E: Invalid operation
```

**Cause**: dpkg database is corrupted

**Solution:**
```bash
# Reconfigure dpkg
sudo dpkg --configure -a

# Clean apt cache
sudo apt clean

# Rebuild package cache
sudo apt update

# Verify integrity
apt check

# If still broken:
sudo rm -rf /var/lib/apt/lists/*
sudo mkdir -p /var/lib/apt/lists/partial
sudo apt update
```

### Common Issue 6: "Signature Verification Failed"

**Problem:**
```
E: The following signatures couldn't be verified because the public key is unavailable: NO_PUBKEY 1234ABCD
```

**Cause**: GPG key for repository is missing

**Solution:**
```bash
# Add the missing key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1234ABCD

# Or add key directly
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 1234ABCD

# Update package list
sudo apt update

# If key not available, you can skip verification (not recommended):
sudo apt update --allow-unauthenticated
```

### Common Issue 7: "Package Conflicts"

**Problem:**
```
E: Unable to correct problems, you have held broken packages.
(package1 conflicts with package2)
```

**Cause**: Two packages cannot be installed together

**Solution:**
```bash
# See what conflicts
apt-cache depends --conflicts <package1>

# Remove conflicting package
sudo apt remove <conflicting-package>

# Install the needed package
sudo apt install <desired-package>

# Or find alternative that provides same functionality
apt-cache search <functionality>
apt install <alternative>
```

### Common Issue 8: "Out of Disk Space"

**Problem:**
```
E: You don't have enough free space in /var/cache/apt/archives/
```

**Cause**: Package cache is full

**Solution:**
```bash
# Check disk usage
df -h /var/cache/apt

# Clean cache
sudo apt clean        # Removes all cached packages

# Clean package lists
sudo apt autoclean    # Removes only old versions

# Remove unused dependencies
sudo apt autoremove

# Check space again
df -h /var/cache/apt
```

### Diagnostic Commands

```bash
# When things go wrong, run these:

# Check overall system health
apt check

# Show error log
cat /var/log/apt/term.log | tail -50

# Check apt configuration
apt-config dump | grep -i ^apt

# Show dpkg errors
dpkg --audit

# Check which packages are broken
apt show <problem-package>

# See dependency chain
apt-cache depends --all <package>

# Verify package integrity
sudo dpkg --verify
```

### Prevention Best Practices

```bash
# 1. Always update before installing new packages
sudo apt update

# 2. Preview before installing
sudo apt install --simulate <package>

# 3. Keep backups of package lists
dpkg --get-selections > ~/packages-backup.txt

# 4. Test in VM before production
# 5. Use apt upgrade, not dist-upgrade
# 6. Keep system clean
sudo apt autoremove && sudo apt autoclean

# 7. Subscribe to security updates
sudo apt install unattended-upgrades
```

### Verification

```bash
# All common issues should be fixable with these commands:
apt check                        # ✓ Check for issues
apt --fix-broken install         # ✓ Fix broken packages
sudo dpkg --configure -a         # ✓ Reconfigure packages
sudo apt clean && apt autoclean  # ✓ Clean cache
```

---

## Lab Completion Checklist

- [x] Lab 1: Searched, installed, and verified packages
- [x] Lab 2: Understood versions and pinning strategies
- [x] Lab 3: Practiced update and upgrade procedures
- [x] Lab 4: Removed packages and cleaned dependencies
- [x] Lab 5: Added, removed, and managed repositories
- [x] Lab 6: Resolved dependencies and fixed broken packages
- [x] Lab 7: Performed safe system maintenance
- [x] Lab 8: Troubleshooted common package problems

## Summary

You now understand:
1. **Package searching** and information gathering
2. **Version management** and pinning strategies
3. **Safe update procedures** for system stability
4. **Package removal and cleanup** to save space
5. **Repository management** for accessing more software
6. **Dependency resolution** and conflict handling
7. **Maintenance procedures** for production systems
8. **Troubleshooting** common package problems

These labs provided hands-on experience with 90+ commands and real-world scenarios. Continue practicing to master package management!
