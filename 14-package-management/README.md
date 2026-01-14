# Module 14: Package Management

## Overview

Package management is the foundation of Linux system administration. It's how you install, update, remove, and manage software on Linux systems. Understanding package management is essential for maintaining system security, stability, and functionality.

**Why This Matters**:
- **Security**: Apply patches and security updates quickly
- **Stability**: Install tested, compatible software versions
- **Efficiency**: Automate software installation at scale
- **Troubleshooting**: Understand dependencies, conflicts, and breakage
- **System Health**: Maintain clean, dependency-aware systems

**Real-World Context**:
Every day, system administrators must:
- Apply security updates to hundreds of systems
- Install specific application versions with dependencies
- Resolve package conflicts and broken dependencies
- Automate software deployment
- Track and manage software across systems

This module teaches you to be efficient and confident with package management—critical for production systems.

---

## Prerequisites

Before starting this module, you should be comfortable with:
- **Module 01**: Linux Basics (command line fundamentals)
- **Module 02**: Advanced Commands (grep, awk, text processing)
- **Module 06**: System Services and Daemons (what packages provide)
- **Module 13**: Logging and Monitoring (understand package logs)

**Recommended Skills**:
- Basic Linux command line usage
- Understanding of file permissions
- Comfort with sudo and privilege escalation
- Basic understanding of software dependencies

---

## Learning Objectives

After completing this module, you will be able to:

### Package Management Fundamentals
- [ ] Understand package formats (deb, rpm) and how they differ
- [ ] Explain package metadata and dependencies
- [ ] Know the difference between package managers and repositories
- [ ] Understand the package installation lifecycle
- [ ] Recognize how packages manage configuration files

### Practical Skills - Debian/Ubuntu (apt)
- [ ] Search for packages using apt
- [ ] Install and remove packages
- [ ] Upgrade systems safely (dist-upgrade)
- [ ] Hold and unhold package versions
- [ ] Configure apt sources and repositories
- [ ] Understand apt update vs upgrade

### Practical Skills - RHEL/CentOS (yum/dnf)
- [ ] Search for packages using yum or dnf
- [ ] Install and remove packages
- [ ] Manage repositories and RPM packages
- [ ] Update systems safely
- [ ] Work with package groups and dependencies

### Advanced Management
- [ ] Troubleshoot broken dependencies
- [ ] Identify and resolve package conflicts
- [ ] Automate package updates
- [ ] Manage multiple systems' packages
- [ ] Use apt/yum for system maintenance
- [ ] Configure automatic security updates

### Security and Maintenance
- [ ] Apply security updates promptly
- [ ] Understand package signatures and authenticity
- [ ] Clean up unused packages
- [ ] Manage package caches
- [ ] Audit installed packages

---

## Module Roadmap

### Core Content Files

| File | Purpose | Time |
|------|---------|------|
| [01-theory.md](01-theory.md) | Package management concepts and architecture | 45 min |
| [02-commands-cheatsheet.md](02-commands-cheatsheet.md) | 90+ commands for apt, yum, dpkg, rpm | 25 min |
| [03-hands-on-labs.md](03-hands-on-labs.md) | 8 practical labs (install, update, troubleshoot) | 2.5-3 hours |

### Practical Tools

| Script | Purpose |
|--------|---------|
| [package-manager.sh](scripts/package-manager.sh) | Universal package operations wrapper |
| [dependency-resolver.sh](scripts/dependency-resolver.sh) | Analyze and fix broken dependencies |
| [apt-update-helper.sh](scripts/apt-update-helper.sh) | Automate safe system updates |

### Learning Path

1. **Read theory** (45 minutes) - Understand package management concepts
2. **Review commands** (25 minutes) - Learn command-line tools
3. **Practice labs** (2.5-3 hours total):
   - Lab 1-2: Search and install packages
   - Lab 3-4: System updates and upgrades
   - Lab 5-6: Manage dependencies and repositories
   - Lab 7-8: Troubleshooting and maintenance

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Package** | Software archive containing binaries, config files, and metadata |
| **Repository** | Server hosting packages (apt repos, yum repos) |
| **Dependency** | Other package required for software to work |
| **Package Manager** | Tool managing installation/removal (apt, yum, dnf) |
| **Metadata** | Package info (version, author, dependencies) |
| **deb** | Debian package format (.deb file) |
| **rpm** | RedHat package format (.rpm file) |
| **Stable** | Tested release channel (recommended for servers) |
| **Conflict** | When packages can't be installed together |
| **Hold** | Prevent automatic updates to a package |
| **Security Update** | Patch for security vulnerabilities |
| **PPA** | Personal Package Archive (Ubuntu third-party repos) |
| **DPKG** | Low-level Debian package tool |
| **RPM** | Low-level RedHat package tool |

---

## Time Estimates

| Component | Time | Difficulty |
|-----------|------|-----------|
| Reading 01-theory.md | 45 minutes | Beginner |
| Review 02-commands-cheatsheet.md | 25 minutes | Beginner |
| Lab 1: Search and install packages | 20 minutes | Beginner |
| Lab 2: Package information | 20 minutes | Beginner |
| Lab 3: System updates | 20 minutes | Beginner |
| Lab 4: Safe upgrade procedures | 25 minutes | Intermediate |
| Lab 5: Manage repositories | 25 minutes | Intermediate |
| Lab 6: Broken dependencies | 25 minutes | Intermediate |
| Lab 7: Dependency analysis | 25 minutes | Intermediate |
| Lab 8: Automate updates | 25 minutes | Intermediate |
| **Total** | **3-3.5 hours** | - |

---

## How to Use This Module

### For Self-Study
1. Start with README.md (this file) for context
2. Read 01-theory.md to understand concepts
3. Use 02-commands-cheatsheet.md as reference
4. Work through 03-hands-on-labs.md in order
5. Explore scripts and modify for your needs

### For Classroom
1. Use theory as lecture material
2. Demonstrate commands live from cheatsheet
3. Have students work through labs (individually or in pairs)
4. Show script examples and discuss modifications
5. Assign troubleshooting scenarios from labs

### For Reference
- Bookmark commands cheatsheet for quick lookup
- Use package-manager.sh for common operations
- Refer to labs when troubleshooting real issues
- Review dependency-resolver.sh for complex problems

---

## Important Notes & Safety

### Lab Safety
- ✓ All labs are **mostly read-only** (search, list, info)
- ✓ Installation labs use test/small packages (safe)
- ✓ Upgrade labs can run on test systems
- ✓ Safe to practice on Ubuntu/CentOS VMs
- ✓ Recommended: Use VM snapshots before upgrade labs

### Best Practices
- Always **backup before major upgrades** on production
- Use **dist-upgrade carefully** (can break systems)
- **Understand dependencies** before removing packages
- **Keep package cache** for offline installation
- **Document critical packages** for your systems

### Common Mistakes
- Upgrading without reading package changelogs
- Removing dependencies without checking
- Installing from untrusted repositories
- Not keeping security updates current
- Mixing repositories (Ubuntu + Debian, etc.)

---

## Module Success Criteria

You've completed this module successfully when you can:

- [ ] Explain how package managers work (apt vs yum)
- [ ] Search for and install packages confidently
- [ ] Understand and resolve dependencies
- [ ] Update systems safely (dist-upgrade)
- [ ] Add and manage repositories securely
- [ ] Troubleshoot broken package states
- [ ] Automate package updates
- [ ] Know what packages are installed and why
- [ ] Choose between package versions
- [ ] Explain package metadata and signatures

---

## Prerequisites to Other Modules

This module prepares you for:
- **Module 15**: Storage and Filesystems (understand filesystem packages)
- **Module 16**: Shell Scripting Basics (create package automation)
- **Module 17**: Troubleshooting and Scenarios (package issues in troubleshooting)

---

## Recommended Tools & Environment

### For Labs
- **OS**: Ubuntu 20.04+ or CentOS 8+ (VM recommended)
- **Tools**:
  - `apt`, `apt-get`, `apt-cache` (Ubuntu/Debian)
  - `yum` or `dnf` (CentOS/RHEL)
  - `dpkg` (Debian package tool)
  - `rpm` (RedHat package tool)
  - `aptitude` (advanced package manager)

### Installation (if needed)
```bash
# On Ubuntu/Debian
sudo apt update
sudo apt install aptitude

# On RHEL/CentOS
sudo yum install yum-utils
```

---

## Quick Start

To get started immediately:

```bash
# Search for a package
apt search nginx              # Ubuntu/Debian
yum search nginx              # CentOS/RHEL

# List installed packages
apt list --installed          # Ubuntu/Debian
rpm -qa                       # CentOS/RHEL

# Get package info
apt show curl                 # Ubuntu/Debian
yum info curl                 # CentOS/RHEL

# Install a package
sudo apt install curl         # Ubuntu/Debian
sudo yum install curl         # CentOS/RHEL

# Update system
sudo apt update && sudo apt upgrade        # Ubuntu/Debian
sudo yum update                            # CentOS/RHEL
```

---

## File Organization

```
14-package-management/
├── README.md                    # This file (overview & roadmap)
├── 01-theory.md                 # Package management theory
├── 02-commands-cheatsheet.md    # Command reference (90+ commands)
├── 03-hands-on-labs.md          # 8 practical labs
└── scripts/
    ├── README.md                # Scripts documentation
    ├── package-manager.sh       # Universal wrapper tool
    ├── dependency-resolver.sh   # Fix broken dependencies
    └── apt-update-helper.sh     # Safe update automation
```

---

## Next Steps

1. **Start with 01-theory.md** to understand the concepts
2. **Review 02-commands-cheatsheet.md** for tools you'll use
3. **Work through 03-hands-on-labs.md** hands-on
4. **Explore scripts/** for automation examples
5. **Practice on your own systems** for real experience

Good luck, and happy learning! 📦🐧

