# Security and Firewall Scripts

This directory contains practical automation scripts for Linux security and firewall management.

## Scripts Overview

### 1. firewall-rule-manager.sh

**Purpose**: Safe UFW firewall rule management with automatic backups

**Requirements**:
- Ubuntu/Debian with UFW installed
- Root privileges
- Bash 4.0+

**Key Features**:
- ✓ Add/remove firewall rules safely
- ✓ Automatic backup before changes
- ✓ SSH port (22) protection from accidental blocking
- ✓ Source IP-based rules (allow-from)
- ✓ Rule audit and status checking
- ✓ Backup/restore capabilities
- ✓ Port accessibility testing

**Installation**:
```bash
sudo chmod +x firewall-rule-manager.sh
sudo ./firewall-rule-manager.sh help
```

**Usage Examples**:

```bash
# Add allow rule for web server
sudo ./firewall-rule-manager.sh add 80/tcp "HTTP web server"
sudo ./firewall-rule-manager.sh add 443/tcp "HTTPS web server"

# Allow specific IP to access SSH
sudo ./firewall-rule-manager.sh allow-from 192.168.1.100 22

# Deny a port (won't allow port 22)
sudo ./firewall-rule-manager.sh deny 25

# List all rules
sudo ./firewall-rule-manager.sh list

# Backup current configuration
sudo ./firewall-rule-manager.sh backup

# Restore from backup
sudo ./firewall-rule-manager.sh restore /root/.ufw-backups/ufw-backup-TIMESTAMP.sh

# Check firewall status
sudo ./firewall-rule-manager.sh status

# Audit firewall security
sudo ./firewall-rule-manager.sh audit

# Test if port is accessible
sudo ./firewall-rule-manager.sh test-port 8080
```

**Common Patterns**:

```bash
# Web server setup
./firewall-rule-manager.sh add 80/tcp "HTTP"
./firewall-rule-manager.sh add 443/tcp "HTTPS"
./firewall-rule-manager.sh deny 22

# Database server (restrict SSH)
./firewall-rule-manager.sh allow-from 192.168.1.50 22  # Only from admin
./firewall-rule-manager.sh allow-from 192.168.1.100 3306  # MySQL from app server

# Mail server
./firewall-rule-manager.sh add 25/tcp "SMTP"
./firewall-rule-manager.sh add 143/tcp "IMAP"
./firewall-rule-manager.sh add 993/tcp "IMAPS"
./firewall-rule-manager.sh add 587/tcp "SMTP-TLS"
```

**Backup Files Location**: `/root/.ufw-backups/`

**Safety Features**:
- Protects port 22 (SSH) from being denied
- Always backs up before making changes
- Requires confirmation before deletions
- Validates rule syntax before applying

---

### 2. security-auditor.sh

**Purpose**: Comprehensive system security audit with detailed reporting

**Requirements**:
- Linux system (Ubuntu/Debian/RHEL/CentOS)
- Root privileges recommended for full audit
- Bash 4.0+

**Key Features**:
- ✓ File permission auditing
- ✓ SUID/SGID binary detection
- ✓ User and group analysis
- ✓ Sudo configuration review
- ✓ SSH hardening verification
- ✓ Password policy checking
- ✓ Firewall status verification
- ✓ SELinux/AppArmor status
- ✓ Failed login attempt detection
- ✓ Open ports and services analysis
- ✓ File integrity tool checking
- ✓ System update status
- ✓ Security scoring (pass/warn/fail)

**Installation**:
```bash
sudo chmod +x security-auditor.sh
sudo ./security-auditor.sh --help
```

**Usage Examples**:

```bash
# Quick security scan (5 minutes)
sudo ./security-auditor.sh --quick

# Full comprehensive audit (15 minutes)
sudo ./security-auditor.sh --full

# Full audit with report saved to file
sudo ./security-auditor.sh --full --report security-audit-$(date +%Y%m%d).txt

# Quick scan with report
sudo ./security-auditor.sh --quick --report quick-audit.txt
```

**Audit Categories**:

| Category | Checks | Details |
|----------|--------|---------|
| **File Permissions** | /etc/passwd, /etc/shadow, /etc/sudoers, /root | Critical file access controls |
| **World-Writable** | System directories | Detects dangerous permissions |
| **SUID/SGID** | Setuid binaries | Lists privilege escalation binaries |
| **Users** | UID 0 accounts, empty passwords | Anomalous user accounts |
| **Sudo Config** | sudoers syntax, NOPASSWD entries | Privilege escalation audit |
| **SSH Hardening** | Root login, password auth, key auth | Remote access security |
| **Passwords** | Expiration, minimum length, complexity | Password policy compliance |
| **Firewall** | UFW/firewalld status, rules | Network access control |
| **SELinux** | Mode, profiles (if available) | Mandatory access control |
| **AppArmor** | Profiles (if available) | Profile-based confinement |
| **Failed Logins** | Auth log analysis | Brute force detection |
| **Open Ports** | Listening services, insecure services | Network service audit |
| **File Integrity** | AIDE/Tripwire availability | File monitoring tools |
| **Updates** | Package update status | System patching status |
| **Umask** | Default file creation mask | File permission defaults |

**Output Interpretation**:

```
✓ PASS: Compliant with security best practices
⚠ WARN: Configuration could be improved
✗ FAIL: Immediate security concern
```

**Security Score Formula**:
```
Score = (PASS checks × 100) / Total checks
```

---

### 3. selinux-policy-helper.sh

**Purpose**: SELinux policy management and denial troubleshooting (RHEL/CentOS only)

**Requirements**:
- RHEL/CentOS with SELinux enabled
- Root privileges
- SELinux tools installed: `policycoreutils-python-utils`
- Bash 4.0+

**Key Features**:
- ✓ SELinux status and mode checking
- ✓ Mode switching (enforcing/permissive/disabled)
- ✓ File context viewing and modification
- ✓ SELinux denial analysis
- ✓ Automatic allow policy generation
- ✓ File and directory relabeling
- ✓ Application-specific troubleshooting
- ✓ Policy information lookup

**Installation**:
```bash
sudo chmod +x selinux-policy-helper.sh
sudo yum install policycoreutils-python-utils
sudo ./selinux-policy-helper.sh help
```

**Usage Examples**:

```bash
# Check SELinux status
sudo ./selinux-policy-helper.sh status

# Change to permissive mode (logging only)
sudo ./selinux-policy-helper.sh mode permissive

# Change to enforcing mode (blocking)
sudo ./selinux-policy-helper.sh mode enforcing

# View file contexts
sudo ./selinux-policy-helper.sh contexts /var/www

# Change file context
sudo ./selinux-policy-helper.sh chcon httpd_sys_content_t /var/www/html/file.php

# Analyze recent denials
sudo ./selinux-policy-helper.sh analyze

# Generate policy from denial
sudo ./selinux-policy-helper.sh allow-denial

# Relabel single file
sudo ./selinux-policy-helper.sh relabel-file /path/to/file

# Relabel home directory
sudo ./selinux-policy-helper.sh relabel-home

# Troubleshoot Apache
sudo ./selinux-policy-helper.sh troubleshoot httpd

# Troubleshoot MySQL
sudo ./selinux-policy-helper.sh troubleshoot mysql
```

**SELinux Context Format**:
```
user:role:type:level
```

Example: `system_u:object_r:httpd_sys_content_t:s0`

**Common SELinux Types**:

| Type | Purpose |
|------|---------|
| `httpd_sys_content_t` | Apache readable web content |
| `httpd_sys_rw_content_t` | Apache writable content |
| `mysqld_db_t` | MySQL database files |
| `mysqld_var_run_t` | MySQL runtime files |
| `sshd_key_t` | SSH private keys |
| `user_home_t` | User home directory content |
| `var_log_t` | Log files |

**Application Troubleshooting Support**:

1. **Apache/HTTPD**
   - Checks service context
   - Verifies web root permissions
   - Shows Apache-specific booleans
   - Suggests fixes for common issues

2. **MySQL/MariaDB**
   - Database process context
   - Data directory permissions
   - Service booleans
   - Connectivity troubleshooting

3. **SSH/SSHD**
   - Daemon context
   - Key file contexts
   - Configuration permissions
   - Authentication issues

4. **NFS**
   - NFS service context
   - Shared directory contexts
   - NFS-specific booleans
   - Mount point verification

**Working with Denials**:

```bash
# View recent denials
sudo ./selinux-policy-helper.sh analyze

# Generate custom policy
sudo ./selinux-policy-helper.sh allow-denial

# Load custom policy module
semodule -i custom_policy.pp

# Remove custom policy
semodule -r custom_policy
```

**Relabeling Filesystem**:

```bash
# Relabel single file
sudo ./selinux-policy-helper.sh relabel-file /var/www/html/index.php

# Relabel directory (preserves context)
sudo restorecon -R /var/www/html

# Full filesystem relabel (requires reboot)
sudo ./selinux-policy-helper.sh relabel-all
```

---

## Installation and Setup

### Prerequisites

**All scripts require**:
- Bash 4.0 or later
- Root privileges (sudo)
- Standard Linux utilities (grep, awk, sed, etc.)

**Distribution-specific**:
- **Ubuntu/Debian**: UFW (apt-get install ufw)
- **RHEL/CentOS**: policycoreutils-python-utils for SELinux helper

### Install All Scripts

```bash
# Clone to local directory
cd 12-security-and-firewall/scripts

# Make executable
chmod +x *.sh

# Optional: Install to system path
sudo cp *.sh /usr/local/bin/
```

### Test Installation

```bash
# Test firewall manager
sudo ./firewall-rule-manager.sh help

# Test security auditor
sudo ./security-auditor.sh --quick

# Test SELinux helper (RHEL/CentOS only)
sudo ./selinux-policy-helper.sh status
```

---

## Common Use Cases

### Case 1: Hardening New Server

```bash
# Run comprehensive audit
sudo ./security-auditor.sh --full --report initial-audit.txt

# Configure firewall
sudo ./firewall-rule-manager.sh add 22/tcp "SSH admin access"
sudo ./firewall-rule-manager.sh add 80/tcp "HTTP"
sudo ./firewall-rule-manager.sh add 443/tcp "HTTPS"

# Audit again
sudo ./security-auditor.sh --full --report hardened-audit.txt
```

### Case 2: Troubleshooting SELinux Denials

```bash
# Check what's being denied
sudo ./selinux-policy-helper.sh analyze

# Switch to permissive for testing
sudo ./selinux-policy-helper.sh mode permissive

# Test application
# <run your application>

# Generate policy for denials
sudo ./selinux-policy-helper.sh allow-denial

# Switch back to enforcing
sudo ./selinux-policy-helper.sh mode enforcing
```

### Case 3: Regular Security Review

```bash
# Monthly security audit
sudo ./security-auditor.sh --quick --report monthly-audit-$(date +%Y-%m).txt

# Review firewall rules
sudo ./firewall-rule-manager.sh audit

# Check for failed logins
sudo tail -100 /var/log/auth.log | grep "Failed password"
```

### Case 4: Firewall Maintenance

```bash
# Backup current configuration
sudo ./firewall-rule-manager.sh backup

# Make changes
sudo ./firewall-rule-manager.sh add 8080/tcp "Application server"

# Audit results
sudo ./firewall-rule-manager.sh audit

# Rollback if needed
sudo ./firewall-rule-manager.sh restore /root/.ufw-backups/ufw-backup-TIMESTAMP.sh
```

---

## Troubleshooting

### firewall-rule-manager.sh

**Issue**: "UFW not installed"
```bash
# Solution
sudo apt-get update
sudo apt-get install ufw
```

**Issue**: "Permission denied"
```bash
# Solution - Run with sudo
sudo ./firewall-rule-manager.sh add 80/tcp
```

**Issue**: "SSH port already blocked"
```bash
# Recovery - Reboot and boot with different port, or use rescue mode
# Prevent with: never run 'deny 22' on production systems
```

### security-auditor.sh

**Issue**: "Some checks require root privileges"
```bash
# Solution - Run with sudo
sudo ./security-auditor.sh --full
```

**Issue**: "Incomplete results"
```bash
# Solution - Some systems don't have all tools
# This is normal - script handles missing tools gracefully
```

### selinux-policy-helper.sh

**Issue**: "SELinux tools not found"
```bash
# Solution
sudo yum install policycoreutils-python-utils
```

**Issue**: "SELinux not available"
```bash
# This script only works on RHEL/CentOS with SELinux
# Use security-auditor.sh on other distributions
```

**Issue**: "audit2allow: no denials to allow"
```bash
# Solution - No recent denials found
# Check that auditd is running and denials are being logged
sudo systemctl status auditd
```

---

## Best Practices

1. **Always backup before changes**
   - firewall-rule-manager does this automatically
   - Keep backups for 30+ days

2. **Test in permissive mode first**
   - SELinux: Use permissive mode before enforcing
   - Firewall: Test on non-production first

3. **Document your changes**
   - Keep audit reports
   - Comment why rules exist
   - Version control configurations

4. **Regular audits**
   - Monthly: Run security-auditor
   - Quarterly: Full comprehensive review
   - After changes: Immediate verification

5. **Alert on security issues**
   - Monitor failed logins
   - Watch for unusual network activity
   - Set up log monitoring (e.g., fail2ban)

---

## Additional Resources

### Documentation Links

- [UFW Documentation](https://wiki.ubuntu.com/UncomplicatedFirewall)
- [SELinux User Guide](https://github.com/SELinuxProject/selinux)
- [AppArmor Documentation](https://gitlab.com/apparmor/apparmor/-/wikis/home)
- [Linux Security Module Documentation](https://www.kernel.org/doc/html/latest/admin-guide/LSM/)

### Related Tools

```bash
# Firewall management
sudo ufw status
sudo iptables -L
sudo firewall-cmd --list-all

# Security checking
aide --check
tripwire --check
lynis audit system

# Log analysis
sudo ausearch -m avc  # SELinux denials
sudo tail -f /var/log/auth.log  # Authentication
sudo journalctl -u sshd  # SSH daemon logs
```

---

## Script Statistics

| Script | Lines | Functions | Checks |
|--------|-------|-----------|--------|
| firewall-rule-manager.sh | 300+ | 12 | Firewall rules, backup/restore |
| security-auditor.sh | 550+ | 18 | 15+ security categories |
| selinux-policy-helper.sh | 480+ | 16 | SELinux management, troubleshooting |

---

## Support and Contributing

For issues, suggestions, or improvements:

1. Run with `--help` for command usage
2. Check script comments for implementation details
3. Review security best practices in theory documentation
4. Consult related modules in parent directory

---

**Last Updated**: 2024
**Compatibility**: Ubuntu/Debian 20.04+, RHEL/CentOS 8+
**License**: Educational use for Linux training
