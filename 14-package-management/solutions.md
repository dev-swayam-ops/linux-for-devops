# Package Management: Solutions

## Exercise 1: Update Package Lists

**Solution:**

```bash
# Update local package list
sudo apt update
# Downloads package info from repos

# Check for upgrades
apt list --upgradable
# Output: curl/focal-updates (upgradable)

# Show upgrade summary
sudo apt upgrade --simulate
# Shows what would upgrade without doing it

# Understand apt cache
ls -la /var/lib/apt/lists/
# Cache location

# Verify connectivity
apt update 2>&1 | grep "100%"
# Success = all repos reached
```

**Explanation:** `apt update` = refresh package index. Needed before install/upgrade.

---

## Exercise 2: Search for Packages

**Solution:**

```bash
# Search for package
apt search nginx
# Output: nginx/focal, nginx-full/focal, etc.

# Show package info
apt show nginx
# Output: Version, Depends, Size, Description

# Available versions
apt policy nginx
# Shows available and installed versions

# Description
apt search --names-only "^nginx$"

# Related packages
apt search web | grep -i server
# Find web server packages

# Check if installed
apt list --installed | grep nginx
```

**Explanation:** `apt search` = find. `apt show` = details. `apt policy` = versions.

---

## Exercise 3: Install Packages

**Solution:**

```bash
# Install single package
sudo apt install curl
# Downloads and installs

# Multiple packages
sudo apt install git vim htop
# All at once

# Verify installation
apt list --installed | grep curl
# Output: curl/focal 7.68... [installed]

# Check version
curl --version
# Shows installed version

# Find files
dpkg -L curl | head -10
# Where curl files located
```

**Explanation:** `apt install` = download + configure + install. Creates entry in dpkg.

---

## Exercise 4: Understand Dependencies

**Solution:**

```bash
# Show dependencies
apt depends curl
# What curl needs

# Output:
# curl depends on:
# libc6 (>= 2.17)
# libcurl4
# etc.

# Reverse dependencies (what needs this)
apt rdepends gcc
# All packages needing gcc

# Dependency chain depth
apt depends --recurse nginx
# Shows full tree

# Check conflict packages
apt policy package1 package2
# Show version compatibility

# Broken dependencies (after manual removal)
sudo apt --fix-broken install
# Fixes missing dependencies
```

**Explanation:** Dependencies are automatically installed. Reverse deps = consumers.

---

## Exercise 5: Upgrade Packages

**Solution:**

```bash
# Upgrade all packages
sudo apt upgrade
# Safe upgrade (no removals)

# Full distribution upgrade
sudo apt full-upgrade
# Can remove/add packages

# Simulate first
sudo apt upgrade --simulate
# Shows what would happen

# Upgrade one package
sudo apt install --only-upgrade curl

# Check before/after versions
apt policy curl | head -10

# See changelog
apt changelog curl | head -50

# Post-upgrade check
sudo apt autoremove
# Clean up after upgrade
```

**Explanation:** `upgrade` = safe. `full-upgrade` = can change packages. Always simulate.

---

## Exercise 6: Remove Packages

**Solution:**

```bash
# Remove (keep configuration)
sudo apt remove nginx
# Delete files, keep config

# Remove (delete everything)
sudo apt purge nginx
# Delete files AND config

# Check if gone
apt list --installed | grep nginx
# Should be empty

# Remove unused dependencies
sudo apt autoremove
# Cleans up orphaned libs

# Clean package cache
sudo apt clean
# Removes downloaded .deb files

# Smaller cleanup
sudo apt autoclean
# Keeps recent packages

# Freed space
du -sh /var/cache/apt/archives/
```

**Explanation:** `remove` = leave config. `purge` = complete removal. Saves space after.

---

## Exercise 7: List and Query Packages

**Solution:**

```bash
# All installed packages
apt list --installed
# Long list

# Count packages
apt list --installed | wc -l
# Total installed

# Specific package
apt list --installed | grep curl
# Find if installed

# Package details
dpkg -l curl
# Full details (dpkg format)

# File locations
dpkg -L curl | head -10
# Where curl files are

# Find by file
dpkg -S /usr/bin/curl
# Which package owns this file

# Package size
dpkg-query -W -f='${Package}\t${Size}\n' curl
```

**Explanation:** `apt list` = apt format. `dpkg` = low-level database.

---

## Exercise 8: Handle Package Issues

**Solution:**

```bash
# Fix broken dependencies
sudo apt --fix-broken install
# Installs missing deps

# Check before fixing
sudo apt check
# Detect issues

# Package manager locked
# Wait or:
sudo lsof /var/lib/apt/lists/lock
# Find process
kill -9 PID

# Hold package (don't upgrade)
sudo apt-mark hold curl
# Freeze version

# List held packages
apt-mark showhold
# Show frozen packages

# Unhold package
sudo apt-mark unhold curl
# Allow upgrades again

# Forced version install
sudo apt install curl=7.68.0-1ubuntu1.9
# Downgrade to specific version
```

**Explanation:** Hold = pin version. Fix broken = install missing deps. Policy = check versions.

---

## Exercise 9: Add and Manage Repositories

**Solution:**

```bash
# View repositories
cat /etc/apt/sources.list
# Main repos

# PPA (Personal Package Archive)
sudo add-apt-repository ppa:user/repo-name
# Add third-party repo

# Update after adding
sudo apt update

# Remove repository
sudo add-apt-repository --remove ppa:user/repo-name

# Disabled repos
ls /etc/apt/sources.list.d/

# Manual repo add
sudo nano /etc/apt/sources.list
# Add: deb http://repo.url focal main

# Verify repo key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys KEY_ID

# Search in specific repo
apt-cache policy curl
# Show available from all repos
```

**Explanation:** Repositories = remote package sources. PPAs = user repos. Keys = verify authenticity.

---

## Exercise 10: Create Package Management Plan

**Solution:**

```bash
# Save current package list
apt list --installed > installed_packages.txt

# Export for reinstall
apt-get dselect-upgrade > package_selections.txt

# Create install script
cat > install_packages.sh << 'EOF'
#!/bin/bash
PACKAGES="curl git vim htop nginx mysql-server"

sudo apt update
for pkg in $PACKAGES; do
  sudo apt install -y $pkg
done

sudo apt autoremove -y
echo "Installation complete"
EOF

chmod +x install_packages.sh

# Set up automatic updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure auto-updates
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

# Verify auto-upgrade enabled
cat /etc/apt/apt.conf.d/50unattended-upgrades | grep "Unattended-Upgrade"

# Test the script
./install_packages.sh
```

**Explanation:** Automation = consistent deployments. Auto-upgrades = security. Saved lists = reproducible environments.
