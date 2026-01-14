# Package Management Commands Cheatsheet

Quick reference for 90+ essential package management commands across Debian/Ubuntu and RHEL/CentOS systems.

---

## Section 1: APT - Basic Package Operations (Ubuntu/Debian)

### Search for Packages

| Command | Purpose | Example |
|---------|---------|---------|
| `apt search <name>` | Search all available packages | `apt search curl` |
| `apt-cache search <name>` | Legacy search command | `apt-cache search curl` |
| `apt-cache search --names-only <name>` | Search by package name only | `apt-cache search --names-only ^curl$` |
| `apt-cache search <keyword>` | Search in descriptions | `apt-cache search "web server"` |

**Examples:**
```bash
# Find all web server packages
apt search webserver

# Search for exact package name
apt search --names-only apache2

# List all packages with 'python' in name
apt search python | grep "^python"
```

---

## Section 2: APT - Getting Package Information

| Command | Purpose |
|---------|---------|
| `apt show <package>` | Display detailed package info |
| `apt-cache show <package>` | Legacy - show package details |
| `apt-cache depends <package>` | Show dependencies |
| `apt-cache rdepends <package>` | Show reverse dependencies (what depends on this) |
| `apt-cache policy <package>` | Show available versions and priority |
| `dpkg -s <package>` | Show if package is installed |
| `dpkg -l` | List all installed packages |
| `apt list --installed` | List installed packages (modern) |

**Examples:**
```bash
# Show all curl information
apt show curl

# See what nginx requires
apt-cache depends nginx

# See what depends on curl (uses curl)
apt-cache rdepends curl

# Check curl installation status
dpkg -s curl
Output: Status: install ok installed

# Show all curl versions available
apt-cache policy curl
curl:
  Installed: 7.68.0-1ubuntu1
  Candidate: 7.68.0-1ubuntu1
  Version table:
     7.68.0-1ubuntu1 500

# List only installed packages
apt list --installed | head -20

# List packages with updates available
apt list --upgradable
```

---

## Section 3: APT - Installation

| Command | Purpose | Notes |
|---------|---------|-------|
| `apt install <package>` | Install package | Will install all dependencies |
| `apt install <package1> <package2>` | Install multiple packages | All in one command |
| `apt install <package>=<version>` | Install specific version | e.g., `curl=7.68.0-1` |
| `apt install -y <package>` | Install without prompting | Auto-answer yes |
| `apt install --simulate <package>` | Preview what would be installed | Doesn't actually install |
| `apt install --no-upgrade <package>` | Install, but don't upgrade if exists | Keep current version |

**Examples:**
```bash
# Simple install
sudo apt install curl

# Install without prompting
sudo apt install -y curl openssl

# Install specific version
sudo apt install curl=7.68.0-1ubuntu1

# Preview before installing
sudo apt install --simulate nginx
# Shows what would be installed without doing it

# Install but keep existing version if already present
sudo apt install --no-upgrade curl
```

---

## Section 4: APT - Upgrades

| Command | Purpose | Safety |
|---------|---------|--------|
| `apt update` | Refresh package index | Safe - read only |
| `apt upgrade` | Install updates for installed packages | Safe - no removals |
| `apt dist-upgrade` | Full upgrade with dependency resolution | Risky - can install/remove |
| `apt full-upgrade` | Same as dist-upgrade | Risky - can install/remove |
| `apt-get autoremove` | Remove unused dependency packages | Generally safe |
| `apt autoremove` | Modern version of autoremove | Generally safe |
| `apt autoclean` | Remove old cached packages | Always safe |
| `apt clean` | Remove all cached packages | Always safe |

**Examples:**
```bash
# Update package index (ALWAYS do this first)
sudo apt update

# Safe upgrade (keep system stable)
sudo apt upgrade

# Show what would be upgraded
sudo apt upgrade --simulate

# Full upgrade (can install/remove packages)
sudo apt dist-upgrade

# Remove packages no longer needed
sudo apt autoremove

# Clean old package downloads (free disk space)
sudo apt autoclean
```

---

## Section 5: APT - Removal

| Command | Purpose | Files |
|---------|---------|-------|
| `apt remove <package>` | Uninstall package | Keeps config files |
| `apt purge <package>` | Uninstall + remove config | Removes everything |
| `apt remove <package>` | Remove single package | Dependencies may stay |
| `apt autoremove` | Remove unused dependencies | After removing packages |
| `apt --purge autoremove` | Remove dependencies + configs | Complete cleanup |

**Examples:**
```bash
# Remove a package (keep its config in case of reinstall)
sudo apt remove curl

# Completely remove including config
sudo apt purge curl

# Remove a package and its no-longer-needed dependencies
sudo apt remove curl
sudo apt autoremove

# Remove package and dependencies completely
sudo apt purge curl
sudo apt autoremove

# Check what autoremove would do
sudo apt autoremove --simulate
```

---

## Section 6: DPKG - Low-Level Package Management

| Command | Purpose |
|---------|---------|
| `dpkg -i <file.deb>` | Install local .deb file |
| `dpkg -l` | List all packages |
| `dpkg -l <pattern>` | List packages matching pattern |
| `dpkg -s <package>` | Show package status |
| `dpkg -r <package>` | Remove package |
| `dpkg -P <package>` | Purge package |
| `dpkg --configure -a` | Configure unconfigured packages |
| `dpkg --get-selections` | List installation status of all packages |
| `dpkg -L <package>` | List files in installed package |
| `dpkg -S <file>` | Show which package owns a file |
| `dpkg -c <file.deb>` | List files that would be installed |
| `dpkg --verify` | Verify package integrity |
| `dpkg --verify <package>` | Verify specific package |

**Examples:**
```bash
# Install a downloaded .deb file
sudo dpkg -i curl_7.68.0-1ubuntu1_amd64.deb

# List all installed packages
dpkg -l

# List packages with 'curl' in name
dpkg -l | grep curl

# Show installation status of specific package
dpkg -s curl

# Remove package (low-level)
sudo dpkg -r curl

# List files installed by curl
dpkg -L curl
/usr/bin/curl
/usr/share/doc/curl
...

# Find which package owns /usr/bin/curl
dpkg -S /usr/bin/curl
curl: /usr/bin/curl

# List files that would be in a .deb file
dpkg -c curl_7.68.0-1ubuntu1_amd64.deb

# Check package integrity
sudo dpkg --verify curl
```

---

## Section 7: APT - Version and Hold Management

| Command | Purpose |
|---------|---------|
| `apt-cache policy` | Show all versions available |
| `apt-cache policy <package>` | Show available versions for one package |
| `apt-mark hold <package>` | Prevent package from being upgraded |
| `apt-mark unhold <package>` | Allow package to be upgraded again |
| `apt-mark auto <package>` | Mark as automatically installed (dependency) |
| `apt-mark manual <package>` | Mark as manually installed |
| `apt-mark showhold` | Show packages on hold |
| `apt-mark showauto` | Show automatically installed packages |
| `apt-mark showmanual` | Show manually installed packages |

**Examples:**
```bash
# Show all available versions for curl
apt-cache policy curl

# Hold curl at current version (won't upgrade)
sudo apt-mark hold curl

# Prevent curl from being upgraded
curl is now hold.

# Allow curl to be upgraded again
sudo apt-mark unhold curl

# Show packages on hold
apt-mark showhold

# Mark curl as a dependency (not manually selected)
sudo apt-mark auto curl

# Mark curl as manually selected
sudo apt-mark manual curl

# List all automatically installed packages
apt-mark showauto
```

---

## Section 8: YUM - Basic Operations (RHEL/CentOS 7 and earlier)

| Command | Purpose |
|---------|---------|
| `yum search <name>` | Search available packages |
| `yum info <package>` | Show package information |
| `yum install <package>` | Install package |
| `yum remove <package>` | Remove package |
| `yum update` | Update package index and all packages |
| `yum upgrade` | Same as update |
| `yum list installed` | List installed packages |
| `yum list available` | List available packages |
| `yum check-update` | Check what packages can be updated |
| `yum clean all` | Clean cache |
| `yum grouplist` | List package groups |
| `yum groupinstall <group>` | Install group of packages |

**Examples:**
```bash
# Search for curl
yum search curl

# Show curl information
yum info curl

# Install curl
sudo yum install curl

# Install without prompting
sudo yum install -y curl

# Remove curl
sudo yum remove curl

# Update all packages
sudo yum update

# See what can be updated
yum check-update

# List installed packages
yum list installed | head

# Install development tools group
sudo yum groupinstall "Development Tools"
```

---

## Section 9: DNF - Modern Package Manager (RHEL/CentOS 8+)

| Command | Purpose | Notes |
|---------|---------|-------|
| `dnf search <name>` | Search packages | Faster than yum |
| `dnf info <package>` | Show package info | More detailed |
| `dnf install <package>` | Install package | Same as yum |
| `dnf remove <package>` | Remove package | Same as yum |
| `dnf update` | Update everything | Replaces yum update |
| `dnf upgrade` | Upgrade system | Same as update |
| `dnf list installed` | List installed | Same as yum |
| `dnf list available` | List available | Same as yum |
| `dnf check-update` | Check for updates | Same as yum |
| `dnf clean all` | Clean cache | Same as yum |
| `dnf grouplist` | List groups | Same as yum |
| `dnf groupinstall <group>` | Install group | Same as yum |
| `dnf autoremove` | Remove unused deps | Newer feature |
| `dnf mark install <package>` | Mark as manually installed | Track dependency |
| `dnf mark remove <package>` | Mark as dependency | Auto-removable |

**Examples:**
```bash
# Search with better output
dnf search curl

# Install with auto-confirmation
dnf install -y curl

# Install multiple packages
dnf install curl openssl zlib

# See what will be updated
dnf list upgrades

# Update only security patches
dnf update --security

# Full upgrade
dnf upgrade

# Remove unused dependencies
dnf autoremove

# Install development tools
dnf groupinstall "Development Tools"
```

---

## Section 10: RPM - Low-Level Package Tool (RHEL/CentOS)

| Command | Purpose |
|---------|---------|
| `rpm -i <file.rpm>` | Install local .rpm file |
| `rpm -U <file.rpm>` | Upgrade with .rpm file |
| `rpm -e <package>` | Erase/remove package |
| `rpm -q <package>` | Query if package installed |
| `rpm -qa` | List all installed packages |
| `rpm -ql <package>` | List files in package |
| `rpm -qf <file>` | Show which package owns file |
| `rpm -qp <file.rpm>` | Query .rpm file (before installing) |
| `rpm -qpc <file.rpm>` | List files in .rpm file |
| `rpm -qpd <file.rpm>` | List documentation in .rpm file |
| `rpm -V <package>` | Verify package integrity |
| `rpm -Va` | Verify all packages |
| `rpm --checksig <file.rpm>` | Check GPG signature |

**Examples:**
```bash
# Install RPM file
sudo rpm -i curl-7.68.0-1.el8.x86_64.rpm

# Upgrade with RPM
sudo rpm -U curl-7.68.0-1.el8.x86_64.rpm

# Query if curl is installed
rpm -q curl
curl-7.68.0-1.el8.x86_64

# List all packages
rpm -qa

# List curl's files
rpm -ql curl
/usr/bin/curl
/usr/share/doc/curl
...

# Find which package owns /usr/bin/curl
rpm -qf /usr/bin/curl
curl-7.68.0-1.el8.x86_64

# List files in RPM before installing
rpm -qpc curl-7.68.0-1.el8.x86_64.rpm

# Verify curl package integrity
rpm -V curl

# Check RPM signature
rpm --checksig curl-7.68.0-1.el8.x86_64.rpm
```

---

## Section 11: APTITUDE - Advanced APT Frontend (Debian/Ubuntu)

| Command | Purpose |
|---------|---------|
| `aptitude search <pattern>` | Search with flexible syntax |
| `aptitude show <package>` | Show package details |
| `aptitude install <package>` | Install (can handle complex conflicts) |
| `aptitude remove <package>` | Remove package |
| `aptitude purge <package>` | Remove + config |
| `aptitude upgrade` | Safe upgrade |
| `aptitude dist-upgrade` | Full upgrade |
| `aptitude autoremove` | Remove unused deps |
| `aptitude why <package>` | Show why package is installed |
| `aptitude why-not <package>` | Show why package isn't installed |

**Examples:**
```bash
# Search with pattern
aptitude search '~i~dcurl'  # Installed packages with curl in description

# Show why curl is installed
aptitude why curl

# Show why a package isn't installed
aptitude why-not nginx

# Install with better dependency resolution
sudo aptitude install nginx

# See what would be removed
sudo aptitude remove nginx --simulate
```

---

## Section 12: Repository Management

| Command | Purpose |
|---------|---------|
| `add-apt-repository <ppa>` | Add PPA (Personal Package Archive) |
| `add-apt-repository --remove <ppa>` | Remove PPA |
| `apt-key list` | List trusted GPG keys |
| `apt-key adv --keyserver <server> --recv-keys <key>` | Add GPG key |
| `cat /etc/apt/sources.list` | View package sources |
| `ls /etc/apt/sources.list.d/` | View additional sources |
| `subscription-manager repos` | View RHEL subscription repos |
| `subscription-manager repos --enable <repo>` | Enable RHEL repo |

**Examples:**
```bash
# Add Ubuntu Toolchain PPA
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt update

# Remove a PPA
sudo add-apt-repository --remove ppa:ubuntu-toolchain-r/test

# List trusted keys
apt-key list

# Add key from keyserver
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1234ABCD

# View standard sources
cat /etc/apt/sources.list

# View PPA sources
ls /etc/apt/sources.list.d/
```

---

## Section 13: Cache and Disk Management

| Command | Purpose | Disk Impact |
|---------|---------|-----------|
| `apt clean` | Remove all cached .deb files | Frees space |
| `apt autoclean` | Remove old cached versions | Frees some space |
| `apt cache` | Show cache location | Read only |
| `du -sh /var/cache/apt` | Show apt cache size | Check usage |
| `yum clean all` | Clear YUM cache | Frees space |
| `yum clean packages` | Remove cached packages only | Moderate free |
| `du -sh /var/cache/yum` | Show YUM cache size | Check usage |

**Examples:**
```bash
# Check APT cache size
du -sh /var/cache/apt

# Free up space on Ubuntu
sudo apt clean

# Remove old package versions
sudo apt autoclean

# Check YUM cache on CentOS
du -sh /var/cache/yum

# Clear all YUM cache
sudo yum clean all
```

---

## Section 14: Dependency Analysis

| Command | Purpose |
|---------|---------|
| `apt-cache depends <package>` | Show dependencies |
| `apt-cache rdepends <package>` | Show reverse dependencies |
| `apt-cache broken` | Show broken packages |
| `apt check` | Check for broken packages |
| `apt install -f` | Fix broken packages |
| `apt --fix-broken install` | Attempt to fix broken state |
| `apt install --fix-missing` | Fix missing dependencies |
| `rpm --verify --all` | Check all RPM integrity |

**Examples:**
```bash
# Show what curl depends on
apt-cache depends curl

# Show what depends on curl
apt-cache rdepends curl

# Show reverse dependencies recursively
apt-cache rdepends --recurse curl

# Check for broken packages
apt check

# Attempt to fix broken state
sudo apt --fix-broken install

# Check if nginx has broken dependencies
apt-cache broken | grep nginx
```

---

## Section 15: System-Wide Package Status

| Command | Purpose |
|---------|---------|
| `apt list --installed` | List all installed packages |
| `apt list --upgradable` | List packages with updates |
| `apt list --all-versions` | List all versions available |
| `apt list` | List all packages (installed + available) |
| `dpkg -l` | List with detailed status |
| `dpkg -l grep ii` | List only fully installed |
| `yum list` | List all packages |
| `yum list installed` | List installed on RHEL |
| `rpm -qa` | List all installed on RHEL |

**Examples:**
```bash
# List all installed packages
apt list --installed

# List packages with available upgrades
apt list --upgradable

# Check if specific package can be upgraded
apt list --upgradable | grep nginx

# Count installed packages
apt list --installed | wc -l
Outputs: 847 packages installed

# List packages installed on RHEL
yum list installed

# Count installed on RHEL
rpm -qa | wc -l
```

---

## Section 16: Package Information Details

| Command | Purpose |
|---------|---------|
| `apt-cache policy` | Show all repository priorities |
| `apt-cache stats` | Show cache statistics |
| `apt-cache dump` | Dump package cache |
| `apt-cache dotty <package>` | Show dependency graph |
| `debtree <package>` | Visual dependency tree |
| `apt-file list <package>` | List files before installing |
| `apt-file search <file>` | Find which package owns file |

**Examples:**
```bash
# Show all available versions and priorities
apt-cache policy

# Show cache statistics
apt-cache stats
Total package names: 12345 (9876)

# List files in nginx before installing
apt-file list nginx

# Find which package contains /etc/nginx.conf
apt-file search nginx.conf

# Show dependency tree
debtree nginx
```

---

## Section 17: Advanced Queries

| Command | Purpose |
|---------|---------|
| `apt search --names-only ~d<regex>` | Search dependencies |
| `apt search ~prequired` | Show required packages |
| `apt search ~pstandard` | Show standard priority |
| `apt search ~o` | Show obsolete packages |
| `apt search ~M` | Show only manually installed |
| `apt search ~A` | Show only automatically installed |
| `dpkg --get-selections` | Get full selection status |
| `dpkg --set-selections <file>` | Restore selections from file |

**Examples:**
```bash
# Show only required packages
apt search ~prequired | head

# Show manually installed packages
apt search ~M | head

# Get selection status of all packages
dpkg --get-selections > ~/packages.txt

# Restore to a previous state
sudo dpkg --set-selections < ~/packages.txt
```

---

## Quick Reference Table

| Task | Ubuntu/Debian | RHEL/CentOS 7 | RHEL/CentOS 8+ |
|------|---------------|---------------|----------------|
| Search package | `apt search` | `yum search` | `dnf search` |
| Install | `apt install` | `yum install` | `dnf install` |
| Remove | `apt remove` | `yum remove` | `dnf remove` |
| Update index | `apt update` | (automatic) | (automatic) |
| Upgrade packages | `apt upgrade` | `yum update` | `dnf update` |
| Full system upgrade | `apt dist-upgrade` | `yum update` | `dnf upgrade` |
| Remove unused | `apt autoremove` | (manual) | `dnf autoremove` |
| Clean cache | `apt clean` | `yum clean all` | `dnf clean all` |
| List installed | `apt list --installed` | `yum list installed` | `dnf list installed` |
| Show package info | `apt show` | `yum info` | `dnf info` |
| Low-level tool | `dpkg` | `rpm` | `rpm` |
| Advanced frontend | `aptitude` | (none) | (none) |

---

## Tips and Tricks

**Batch Operations:**
```bash
# Install multiple packages at once
apt install curl nginx openssl -y

# Update and upgrade in one go
apt update && apt upgrade -y

# Remove multiple packages
apt remove apache2 nginx -y
```

**Safe Testing:**
```bash
# Preview what would happen
apt install --simulate nginx

# Actually install without simulate
apt install nginx
```

**Finding Packages:**
```bash
# Find packages matching pattern
apt search "^python"

# Find which package owns a file
apt-file search /usr/bin/curl

# Check where package is from
apt-cache policy curl
```

**Maintenance:**
```bash
# Full cleanup (safe)
apt clean && apt autoclean && apt autoremove -y

# Check system health
apt check

# Fix broken state
apt --fix-broken install
```

This cheatsheet provides quick access to 90+ essential commands. For detailed help, use `man apt`, `man yum`, or `man rpm`.
