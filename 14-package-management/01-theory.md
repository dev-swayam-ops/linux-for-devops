# Package Management Theory

## 1. What is a Package?

A package is a compressed archive containing:
- **Binaries**: Executable programs
- **Libraries**: Shared code and functions
- **Configuration files**: Default settings
- **Documentation**: Man pages and help files
- **Metadata**: Version, author, dependencies
- **Scripts**: Pre/post installation hooks

### Package Format

```
Package File (.deb or .rpm)
├── Control/Metadata
│   ├── Name, version, architecture
│   ├── Dependencies
│   ├── Maintainer information
│   └── Checksums and signatures
├── Binaries and Libraries
│   └── /usr/bin/*, /usr/lib/*, etc.
├── Configuration
│   └── /etc/*, setup scripts
└── Documentation
    └── Man pages, README, etc.
```

### Example: Installing curl

```
Step 1: Download curl_7.68.0-1ubuntu1_amd64.deb
Step 2: Verify package signature
Step 3: Extract binaries to /usr/bin/
Step 4: Extract libraries to /usr/lib/
Step 5: Run post-install scripts
Step 6: Update package database
Result: curl command available system-wide
```

---

## 2. Package Managers

### What They Do

Package managers are tools that:
1. **Download** packages from repositories
2. **Verify** authenticity and integrity
3. **Resolve** dependencies automatically
4. **Install** files in correct locations
5. **Configure** the system
6. **Track** what's installed for updates/removal

### Package Manager Architecture

```
User Command
    |
    v
Package Manager (apt, yum, dnf)
    |
    +---> Dependency Resolver
    |         (find all required packages)
    |
    +---> Repository Downloader
    |         (fetch .deb or .rpm files)
    |
    +---> Signature Verifier
    |         (ensure authenticity)
    |
    +---> Package Installer
    |         (dpkg, rpm - low-level tool)
    |
    v
System (files installed, database updated)
```

---

## 3. Debian/Ubuntu Package Management

### Architecture

**Ubuntu/Debian packaging**:
- Uses `.deb` format
- DPKG is low-level tool
- APT is high-level package manager
- Repositories provide pre-built packages

### APT Components

```
apt-cache: Search and get package info
apt-get:   Install, upgrade, remove packages
apt-mark:  Hold/unhold versions
apt:        Modern unified tool (combines above)
dpkg:       Low-level package installation
```

### Package Repository Structure

```
Ubuntu Repository
├── Repositories by Release
│   ├── bionic (18.04)
│   ├── focal (20.04)
│   └── jammy (22.04)
├── Package Sections
│   ├── main (officially supported)
│   ├── universe (community-maintained)
│   ├── restricted (proprietary drivers)
│   └── multiverse (licensing issues)
└── Multiple Mirror Servers
    └── For redundancy and speed
```

### Install Process (APT)

```
$ apt install curl
    |
    v
1. Check if curl is installed
2. Search repositories for 'curl'
3. Find all dependencies (libcurl4, etc.)
4. Check if dependencies are available
5. Download .deb files
6. Verify GPG signatures
7. Check disk space
8. Ask for confirmation
    |
    v
$ dpkg --install curl_7.68_amd64.deb
    |
    v
1. Extract files to filesystem
2. Run pre-installation script
3. Update dpkg database
4. Run post-installation script
    |
    v
curl command is now available
```

---

## 4. RedHat/CentOS Package Management

### Architecture

**RHEL/CentOS packaging**:
- Uses `.rpm` format
- RPM is low-level tool
- YUM (old) or DNF (modern) is high-level
- Similar architecture to Debian but different tool names

### YUM vs DNF

```
YUM (Yellow Dog Updater Modified)
├── Older, slower dependency resolver
├── Still widely used on RHEL 7 and earlier
├── Works with RPM format
└── Large ecosystem of plugins

DNF (Dandified YUM)
├── Newer, faster (better libsolv)
├── Default on RHEL 8+ and CentOS 8+
├── Cleaner Python implementation
└── Drop-in replacement for yum
```

### Repository Structure

```
CentOS/RHEL Repository
├── Base (core packages)
├── Updates (security and bug fixes)
├── Extras (additional packages)
└── CodeReady (RHEL subscription content)
```

---

## 5. Dependencies

### What are Dependencies?

A dependency is another package required for software to work.

Example: Installing nginx requires:
```
nginx
├── libc6 (C library - EVERYTHING needs this)
├── libpcre3 (regular expressions)
├── libssl1.1 (encryption)
├── zlib1g (compression)
└── (and possibly more)
```

### Dependency Types

1. **Must Have** (required for package to work at all)
   - Example: nginx requires libssl for HTTPS
   
2. **Recommended** (should have for full functionality)
   - Example: curl recommends ca-certificates for HTTPS validation
   
3. **Suggested** (nice to have, optional)
   - Example: vim suggests vim-common
   
4. **Conflicts** (cannot be installed together)
   - Example: php-fpm and libapache2-mod-php conflict

### Dependency Resolution

```
User: apt install nginx
    |
    v
Resolver checks:
  - Is nginx available? Yes
  - Does nginx have unmet dependencies?
  - Is libpcre3 installed? No -> add to install list
  - Does libpcre3 have dependencies? Check...
  - Is libssl1.1 installed? No -> add to install list
  - ...continue recursively...
    |
    v
Install Queue:
  1. libc6 (if needed)
  2. libssl1.1
  3. libpcre3
  4. zlib1g
  5. nginx
    |
    v
Install all in correct order
```

### Broken Dependencies

When dependencies cannot be satisfied:

```
Situation: Remove package A that package B depends on
Result: Package B is now "broken" (has unmet dependencies)

Solutions:
1. Reinstall the removed package
2. Remove package B as well
3. Install alternative that provides dependency
```

---

## 6. Version Management

### Version Numbers

Standard format: `MAJOR.MINOR.PATCH`

Example: `7.68.0` (curl)
- **7** = Major version (significant changes)
- **68** = Minor version (new features, backwards compatible)
- **0** = Patch version (bug fixes, security patches)

### Package Versions in Repositories

```
Stable Channel
├── 7.60.0 (well-tested, older)
├── 7.64.0 (tested, still receiving updates)
└── 7.68.0 (current stable release)

Testing Channel
└── 7.75.0 (will be next stable, currently testing)

Unstable Channel
└── 7.80.0 (development version, may break)
```

### Version Pinning (Holding)

```
Without pinning:
  curl 7.60.0 → apt upgrade → curl 7.64.0 → curl 7.68.0
  (package manager decides which version)

With pinning:
  curl 7.60.0 → apt upgrade → curl 7.60.0
  (stay on specific version even if newer available)

Use cases:
- Application requires specific version
- Testing compatibility before upgrading
- Stability on production systems
```

---

## 7. Package Lifecycle

### States of a Package

```
Not Installed
    |
    v
  [download from repo]
    |
    v
Installed
    |
    +---> [apt upgrade] ---> Upgraded Version
    |
    +---> [apt remove] ---> Removed (files deleted)
    |
    `---> [apt purge] ---> Purged (removed + config deleted)
```

### Installation States

```
Fresh Install
  └─ No pre-existing configuration

Upgrade
  ├─ New version installed
  ├─ Old version uninstalled
  └─ Configuration usually preserved

Downgrade
  └─ Installing older version
      (not supported by apt, risky)
```

### Configuration Files

```
Package includes default configuration: /etc/nginx/nginx.conf

User modifies it: /etc/nginx/nginx.conf (customized)

Upgrade happens:
  Case 1: No user changes → replace with new default
  Case 2: User changed it → ask what to do
    Options: Keep user version, use new version, or diff

Removal:
  apt remove → keeps configuration
  apt purge → deletes configuration too
```

---

## 8. System Update Strategies

### apt update vs apt upgrade

**apt update**:
- Downloads package lists from repositories
- Updates local index of available versions
- Does NOT install anything
- Safe to run anytime (read-only)

```
$ apt update
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
Reading package lists... Done
Building dependency tree... Done
```

**apt upgrade**:
- Installs newer versions of installed packages
- Never removes packages
- Never installs NEW packages
- Safe - won't break system

```
$ apt upgrade
Reading package lists... Done
Building dependency tree...
The following packages will be upgraded:
  curl openssl zlib1g
3 upgraded, 0 newly installed, 0 to remove
```

**apt dist-upgrade** (or upgrade to full version):
- Installs newer versions
- CAN install new packages (if needed for upgrades)
- CAN remove packages (if conflicts)
- More aggressive than upgrade
- RISKY on production systems

```
$ apt dist-upgrade
Reading package lists... Done
The following packages will be upgraded:
  linux-image linux-generic (kernel upgrade!)
3 upgraded, 2 newly installed, 1 to remove
```

### Update Philosophy

```
Production System:
  1. Schedule maintenance window
  2. Backup critical data
  3. apt update (get latest info)
  4. apt upgrade (install security patches)
  5. Test critical services
  6. If working: Done
  7. If broken: Rollback from backup

Aggressive Update:
  1. apt update
  2. apt dist-upgrade
  3. Reboot if kernel updated
  4. Full system is now latest
  5. Risk: Could break something
```

---

## 9. Security in Package Management

### GPG Signatures

Every package is signed with GPG key to verify:
1. **Authenticity**: Package came from Ubuntu/RedHat
2. **Integrity**: Package wasn't modified in transit

```
Package Flow:
Ubuntu Maintainer
    |
    v
Signs package with private key
    |
    v
Publishes to repository
    |
    v
User downloads package
    |
    v
Verifies with public key (automatic by apt)
    |
    v
If verification fails: STOP, don't install
```

### Repository Trust

```
Default Ubuntu repositories:
  ✓ Maintained by Canonical
  ✓ Signed with Canonical's GPG key
  ✓ Security team reviews packages
  ✓ Safe to use

Third-party PPA:
  ⚠ Maintained by community members
  ⚠ Varying levels of review
  ⚠ Add carefully, remove if suspicious

Security updates:
  ✓ Available quickly (usually same day)
  ✓ Installed separately if critical
  ✓ Important to stay current
```

### Update Security

```
Timeline:
Vulnerability announced
    |
    v (same day)
Ubuntu patches it
    |
    v
Available via apt update
    |
    v (you run apt upgrade)
System is patched

If you don't run apt upgrade:
  System remains vulnerable
  Attackers can exploit known vulnerabilities
```

---

## 10. Troubleshooting Common Issues

### Broken Dependencies

**Problem**: "E: Unable to correct problems, you have held broken packages"

**Cause**: Package depends on something that can't be installed

**Solutions**:
```
1. Check what's wrong:
   apt check

2. Try to fix:
   apt --fix-broken install

3. If still broken, remove the problematic package:
   apt remove <package>
```

### Repository Errors

**Problem**: "E: Could not get lock /var/lib/apt/lists/lock"

**Cause**: Another apt process is running (apt update, unattended-upgrades)

**Solutions**:
```
1. Wait for other apt to finish:
   lsof /var/lib/apt/lists/lock

2. Kill if stuck (careful!):
   sudo killall apt-get

3. Clean lock if corrupt:
   sudo rm /var/lib/apt/lists/lock
```

### Package Conflicts

**Problem**: "E: Unable to correct problems, you have held broken packages"

**Cause**: Two packages need different versions of same library

**Solutions**:
```
1. Install one package first, understand requirements:
   apt install package-a
   
2. Then install second:
   apt install package-b

3. Or use dist-upgrade to resolve:
   apt dist-upgrade

4. Last resort: remove one package:
   apt remove package-a
```

---

## 11. Best Practices

### Security
1. **Keep systems updated**: Run apt update && apt upgrade weekly
2. **Use signed packages**: Only install from trusted repositories
3. **Subscribe to security updates**: Know when patches available
4. **Minimize installed packages**: Less software = smaller attack surface
5. **Pin critical versions**: Prevent accidental breaking upgrades

### Maintenance
1. **Understand dependencies**: Know why packages are installed
2. **Keep package cache**: apt clean removes downloaded packages
3. **Document systems**: Track why specific packages installed
4. **Test before production**: Never first upgrade to production
5. **Maintain backups**: Before any major upgrade

### Efficiency
1. **Batch updates**: Combine apt commands when possible
2. **Use apt instead of apt-get**: More user-friendly
3. **Automate updates**: unattended-upgrades for servers
4. **Monitor disk space**: Large package caches consume space
5. **Use mirrors**: Faster downloads, less bandwidth

---

## Summary

Key Takeaways:

1. **Packages are archives** containing binaries, libraries, config, and metadata
2. **Package managers** automatically resolve dependencies and install
3. **APT vs YUM** are high-level managers; dpkg/rpm are low-level
4. **Dependencies** are automatically resolved, but can conflict
5. **Repositories** are the source of packages (must be trusted)
6. **apt update** refreshes package info; **apt upgrade** installs updates
7. **dist-upgrade** is aggressive and can break things
8. **Security updates** are critical - stay current
9. **Version pinning** holds packages to specific versions
10. **Troubleshooting** usually involves checking dependencies or cache

The next sections teach practical command usage and hands-on experience with these concepts.
