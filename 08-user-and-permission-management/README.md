# Module 08: User and Permission Management

## Overview

User and permission management is the foundation of Linux security. Understanding how to create users, manage groups, and control file access is essential for system administrators, DevOps engineers, and anyone managing Linux systems.

### Why This Matters

**Real-World Scenarios:**

1. **Your app crashes with "Permission denied"** - File permissions blocking access
2. **Contractor needs access to specific files** - Create user and assign permissions
3. **Former employee still has access** - Need to remove user and audit permissions
4. **Database service needs specific ownership** - Use chown and special permissions
5. **Security audit finds overly permissive files** - Fix permissions across system
6. **Team needs shared folder for collaboration** - Group-based access control

This module teaches you to:
- Create, modify, and delete users and groups
- Understand and manage file permissions
- Use special permissions (setuid, setgid, sticky bit)
- Control access with umask
- Implement sudo and privilege escalation
- Audit and fix permission issues
- Secure your system against unauthorized access

---

## Prerequisites

**Required Knowledge:**
- Module 01: Linux Basics Commands (file navigation, ls)
- Module 02: Linux Advanced Commands (grep, pipes)
- Module 07: Process Management (understanding processes, ownership)

**System Requirements:**
- Linux system with bash (Ubuntu 18.04+, RHEL 8+, Debian 10+)
- Ability to run commands as root/sudo
- 2GB RAM minimum for labs

**Skills Assumed:**
- Comfortable navigating filesystem
- Understand basic file operations (cp, mv, rm)
- Can write simple bash scripts
- Understand what "root" means

---

## Learning Objectives

### Beginner Level
By completing beginner labs (1-3), you will:
- [ ] Understand user and group concepts
- [ ] List users and groups on system
- [ ] Understand file permission bits (rwx)
- [ ] Read and interpret permission strings
- [ ] Change file ownership (chown, chgrp)
- [ ] Change file permissions (chmod)
- [ ] Use numeric and symbolic permission notation

**Estimated Time**: 80 minutes

### Intermediate Level
By completing intermediate labs (4-8), you will:
- [ ] Create and delete users and groups
- [ ] Modify user properties (passwords, shells, home directories)
- [ ] Understand umask and its impact
- [ ] Use special permissions (setuid, setgid, sticky bit)
- [ ] Understand sudo configuration
- [ ] Troubleshoot permission issues
- [ ] Implement least-privilege access control
- [ ] Audit user and permission settings

**Estimated Time**: 140 minutes

### Advanced Level
By completing advanced sections (scripts, automation), you will:
- [ ] Automate user provisioning
- [ ] Audit permissions programmatically
- [ ] Create permission policies
- [ ] Implement security best practices
- [ ] Troubleshoot complex permission scenarios

**Estimated Time**: 40 minutes

---

## Module Roadmap

### 1. Learning Materials

**[01-theory.md](01-theory.md)** - Conceptual Foundations
- User and group concepts
- File permission model (rwx bits)
- Numeric vs symbolic notation
- File ownership (user and group)
- Special permissions (setuid, setgid, sticky bit)
- umask and default permissions
- Sudo and privilege escalation
- Security considerations

**[02-commands-cheatsheet.md](02-commands-cheatsheet.md)** - Command Reference
- 25+ essential commands with examples
- User management (useradd, usermod, userdel)
- Group management (groupadd, groupmod, groupdel)
- Permission management (chmod, chown, chgrp)
- sudo and access control
- User information (id, whoami, w, last)
- Password management (passwd, chpasswd)
- Quick reference table

**[03-hands-on-labs.md](03-hands-on-labs.md)** - Practical Exercises
- 9 progressive hands-on labs
- Total lab time: 220 minutes
- Labs cover user creation, permissions, special permissions, sudo, auditing

### 2. Production Tools

**[scripts/](scripts/README.md)** - Operational Scripts
- `user-manager.sh` - User and group management automation
- `permission-auditor.sh` - Permission analysis and fixing
- Installation guide and usage examples

### 3. Verification

**[COMPLETION-STATUS.md](COMPLETION-STATUS.md)** - Module Summary
- Content inventory and status
- Learning objectives achievement
- Quality assurance checklist
- Module statistics

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **User** | Linux account for a person, service, or application |
| **Group** | Collection of users with shared permissions |
| **UID** | User ID - unique identifier for user |
| **GID** | Group ID - unique identifier for group |
| **Permission** | Access right (read, write, execute) on file/directory |
| **Owner** | User who created/owns file |
| **Permission Bits** | rwx for owner, group, other (9 bits total) |
| **Numeric Notation** | 777 style permissions (octal digits) |
| **Symbolic Notation** | u+x style permissions (letters) |
| **chmod** | Change file mode (permissions) |
| **chown** | Change owner of file |
| **chgrp** | Change group of file |
| **setuid** | Special bit - execute as owner, not user |
| **setgid** | Special bit - execute as group, or inherit group |
| **Sticky Bit** | Special bit - only owner can delete from directory |
| **umask** | Mask that determines default permissions for new files |
| **sudo** | Execute command as root/another user with escalation |
| **Privilege Escalation** | Gaining higher-level access rights |
| **root** | Superuser with UID 0 and all permissions |
| **Least Privilege** | Security principle - users get minimum needed access |

---

## Common Workflows

### Workflow 1: Create User and Set Up Home

```bash
# Create user with home directory
sudo useradd -m -s /bin/bash newuser

# Set password
sudo passwd newuser

# Verify
id newuser
ls -la /home/newuser
```

### Workflow 2: Fix Permission Denied Error

```bash
# Find the problematic file
ls -la /path/to/file

# Identify needed permission
# Is it owner issue? → use chown
# Is it permission issue? → use chmod
# Is it group issue? → use chgrp

# Fix owner
sudo chown username:groupname /path/to/file

# Fix permissions
sudo chmod 644 /path/to/file
```

### Workflow 3: Create Shared Folder for Team

```bash
# Create directory
sudo mkdir -p /shared/project

# Create group
sudo groupadd project-team

# Add users to group
sudo usermod -a -G project-team user1
sudo usermod -a -G project-team user2

# Set ownership to group
sudo chown :project-team /shared/project

# Set permissions (group can read/write)
sudo chmod 2770 /shared/project
```

### Workflow 4: Understand and Change Permissions

```bash
# View permissions
ls -la file.txt
# -rw-r--r-- 1 user group 1024 date file.txt

# Owner can read/write, group/other can read
# Change to rwx------ (owner only)
chmod 700 file.txt

# Change to rw-rw---- (owner and group)
chmod 660 file.txt
```

### Workflow 5: Grant Sudo Access

```bash
# Add user to sudo group (Debian/Ubuntu)
sudo usermod -a -G sudo username

# Or edit sudoers file directly (RHEL/CentOS)
sudo visudo
# Add: username ALL=(ALL) ALL

# Test (user must log out and back in)
sudo whoami    # Should return "root"
```

---

## Module Features

### Hands-On Learning
- 9 complete, safe labs ranging from 15-40 minutes each
- Progressive difficulty (beginner to advanced)
- Real-world user and permission scenarios
- All labs use safe test accounts (no production impact)

### Practical Tools
- 2 production-ready automation scripts
- User provisioning automation
- Permission auditing and fixing
- Security-focused implementations

### Comprehensive Documentation
- 10+ theory sections with ASCII diagrams
- 25+ commands with 60+ real-world examples
- Quick reference tables
- Permission matrix diagrams
- Troubleshooting guides
- Security best practices

### Security-Conscious Design
- Least privilege principles throughout
- Safe sudoers configuration
- Permission hardening examples
- Audit and verification workflows

---

## Success Criteria

After completing this module, you should be able to:

1. **Manage users** - Create, modify, delete users and reset passwords
2. **Manage groups** - Create groups and manage membership
3. **Understand permissions** - Read and interpret rwx notation
4. **Change permissions** - Use chmod with numeric and symbolic notation
5. **Fix ownership** - Use chown and chgrp appropriately
6. **Troubleshoot access** - Diagnose and fix permission issues
7. **Implement sudo** - Configure privilege escalation safely
8. **Apply security** - Use least privilege and special permissions
9. **Audit permissions** - Find and fix overly permissive files

---

## How to Use This Module

### Recommended Study Path

1. **Read Module Overview** (this file)
   - 5 minutes for context

2. **Study Theory** ([01-theory.md](01-theory.md))
   - 60 minutes to understand concepts
   - Focus on permission model and special permissions
   - Review diagrams carefully

3. **Reference Commands** ([02-commands-cheatsheet.md](02-commands-cheatsheet.md))
   - Use while doing labs
   - Try examples in terminal
   - Build command fluency

4. **Complete Labs** ([03-hands-on-labs.md](03-hands-on-labs.md))
   - Work through in order (1-9)
   - 220 minutes total
   - Each lab builds on previous knowledge

5. **Explore Scripts** ([scripts/](scripts/README.md))
   - Review production scripts
   - Try examples
   - Adapt for your needs

### Lab Environment Setup

```bash
# Recommended: Use a VM to practice safely
# All labs use test accounts, safe to run

# Navigate to module
cd 08-user-and-permission-management

# Make scripts executable
chmod +x scripts/*.sh

# Start with lab 1
# Follow instructions in 03-hands-on-labs.md
```

---

## What's Covered vs. What's Not

### Covered in This Module
- User and group management fundamentals
- File and directory permissions
- Special permissions and setuid/setgid
- umask and default permissions
- sudo configuration and privilege escalation
- Permission troubleshooting
- Security best practices
- User auditing

### Related to Other Modules
- **Module 07**: Process Management (process ownership)
- **Module 06**: System Services (daemon users)
- **Module 13**: Logging and Monitoring (user activity tracking)
- **Module 12**: Security and Firewall (advanced security)

### Out of Scope
- Advanced SELinux policies
- ACL (Access Control Lists) in depth
- LDAP and directory services
- Advanced sudo plugins
- PAM (Pluggable Authentication Modules)

---

## Troubleshooting This Module

### Cannot run sudo commands

```bash
# Verify user is in sudo group
groups username

# If not, add to sudo group
sudo usermod -a -G sudo username

# User must log out and back in
```

### Permission denied on own file

```bash
# Check ownership
ls -la file

# Fix if needed
sudo chown username:username file

# Check permissions
chmod 644 file    # rw-r--r--
```

### Can't create user

```bash
# Verify running as root/sudo
whoami

# Check if user already exists
id newuser
# If exists, use different name
```

---

## Next Steps After This Module

### Immediate
- Practice user/group creation
- Audit your own system permissions
- Set up shared folders for teams
- Configure sudo for your users

### Then Study
- **Module 12**: Security and Firewall
- **Module 13**: Logging and Monitoring (track user actions)

### Advanced Topics
- PAM (authentication modules)
- SELinux policies
- LDAP and centralized authentication
- Advanced sudo configurations

---

## Module Statistics

| Metric | Value |
|--------|-------|
| Theory Sections | 10+ |
| Documented Commands | 25+ |
| Real Examples | 60+ |
| Hands-On Labs | 9 |
| Lab Time | 220 minutes |
| Production Scripts | 2 |
| ASCII Diagrams | 8+ |

---

## Quick Start (TL;DR)

```bash
# Verify system
whoami
id

# Start first lab
cat 03-hands-on-labs.md | head -100

# Make scripts executable
chmod +x scripts/*.sh

# Run a script
./scripts/user-manager.sh --help
```

---

**Ready to start?** Begin with [01-theory.md](01-theory.md) or jump to [03-hands-on-labs.md](03-hands-on-labs.md) if you prefer learning by doing!

---

**Module Version**: 1.0.0  
**Status**: Complete  
**Last Updated**: January 2024
