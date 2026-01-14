# Module 09: Linux Configuration - Theory

Complete conceptual foundation for understanding and managing Linux system configuration.

---

## Section 1: Understanding Configuration in Linux

### What is Configuration?

Configuration is the process of adjusting system behavior through files, parameters, and settings. Rather than hardcoding behavior, Linux allows runtime configuration through files.

**Three levels of configuration:**

```
┌─────────────────────────────────────────┐
│  Application Configuration              │ ← Application-specific settings
│  (app.conf, .config/app/)               │
├─────────────────────────────────────────┤
│  System Configuration                   │ ← OS-level settings
│  (/etc/*, /etc/sysctl.conf)            │
├─────────────────────────────────────────┤
│  Kernel Parameters                      │ ← Kernel tuning
│  (/proc/sys/*, sysctl)                 │
└─────────────────────────────────────────┘
```

### Why Configuration Files Matter

**Advantages:**
- Change behavior without recompilation
- Survive service restarts (persistent)
- Manage multiple environments (dev/staging/prod)
- Version control configurations
- Deploy consistent settings across servers
- Easy to read, understand, and modify
- No downtime for most changes (just reload)

**Example**: SSH configuration
```bash
# Without configuration file: would need to recompile SSH for each setting
# With configuration file: just edit /etc/ssh/sshd_config and reload

# View SSH configuration
grep "^Port\|^PermitRootLogin" /etc/ssh/sshd_config
# Port 22
# PermitRootLogin no

# Change port
sudo sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config

# Reload (no downtime)
sudo systemctl reload ssh
```

---

## Section 2: The /etc Directory Structure

### What is /etc?

The /etc directory contains system-wide configuration files. The name comes from "etcetera" (the rest) from early Unix.

### Main /etc Directories

```
/etc/
├── passwd              ← User account information
├── group               ← Group information
├── shadow              ← Encrypted passwords
├── sudoers             ← Sudo configuration
├── fstab               ← Filesystem mount table
├── sysctl.conf         ← Kernel parameters
├── hostname            ← System hostname
├── hosts               ← Manual hostname resolution
│
├── ssh/                ← SSH configuration
│   ├── sshd_config     ← SSH daemon configuration
│   └── ssh_config      ← SSH client configuration
│
├── network/            ← Network configuration
│   ├── interfaces      ← Network interfaces (Debian/Ubuntu)
│   └── /
│
├── systemd/            ← Systemd configuration
│   ├── system/         ← System services
│   └── user/           ← User services
│
├── default/            ← Application default settings
│   ├── grub            ← GRUB bootloader defaults
│   ├── nginx           ← Nginx default settings
│   └── ssh             ← SSH service defaults
│
├── logrotate.d/        ← Log rotation rules
├── cron.d/             ← Cron job scheduling
├── init.d/             ← Legacy init scripts (mostly replaced by systemd)
├── modprobe.d/         ← Kernel module configuration
└── sysctl.d/           ← Kernel parameter configuration (newer)
```

### Key System Configuration Files

**Network Configuration**
```bash
/etc/hostname              # System hostname
/etc/hosts                 # Manual hostname to IP mapping
/etc/resolv.conf          # DNS resolver configuration
/etc/network/interfaces   # Network interface setup (Debian/Ubuntu)
/etc/sysconfig/network    # Network configuration (RHEL/CentOS)
```

**User and Permission**
```bash
/etc/passwd               # User account database
/etc/group                # Group database
/etc/shadow               # Encrypted passwords
/etc/sudoers              # Sudo rules
```

**System Behavior**
```bash
/etc/sysctl.conf          # Kernel runtime parameters
/etc/modprobe.conf        # Kernel module options
/etc/fstab                # Filesystem mounts
```

**Services**
```bash
/etc/systemd/system/      # Systemd service units
/etc/ssh/sshd_config      # SSH daemon configuration
/etc/nginx/nginx.conf     # Nginx web server
/etc/mysql/               # MySQL database configuration
/etc/postgresql/          # PostgreSQL configuration
```

---

## Section 3: Configuration File Formats

### Format 1: Key-Value Pairs (.conf files)

Most Linux config files use key-value format with spaces or equals.

**Example: /etc/ssh/sshd_config**
```
# Comments start with #
Port 22
AddressFamily any
Protocol 2
HostKeys /etc/ssh/ssh_host_rsa_key
HostKeys /etc/ssh/ssh_host_ecdsa_key

# Boolean options (yes/no)
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no

# List values
AcceptEnv LANG LC_*
```

**Characteristics:**
- One setting per line
- Comments with # (sometimes ; or *)
- Whitespace (space or tab) separates key and value
- Case sensitive
- No quotes needed (usually)
- Some options can be specified multiple times

### Format 2: INI-Style Files (.ini, .cfg)

Configuration grouped into sections using [section] headers.

**Example: /etc/php/7.4/apache2/php.ini**
```ini
[PHP]
max_execution_time = 30
max_input_time = 60
memory_limit = 128M
upload_max_filesize = 2M

[Date]
date.timezone = UTC

[Database]
mysqli.default_host = localhost
mysqli.default_user = root
```

**Characteristics:**
- Organized in sections with [section] headers
- Key = Value format
- Comments with ; or #
- Whitespace around = is optional
- Values can be quoted for spaces

### Format 3: YAML Format (.yaml, .yml)

Hierarchical configuration using indentation (common in modern tools).

**Example: /etc/netplan/01-netcfg.yaml**
```yaml
# YAML format: indentation matters!
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
        route-metric: 100
    eth1:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**Characteristics:**
- Indentation indicates hierarchy (spaces, not tabs)
- Keys: values format
- Lists use - for items
- Strings can be quoted or unquoted
- Comments with #
- Very structured and readable

### Format 4: JSON Format

Machine-readable format used by many modern applications.

**Example: /etc/docker/daemon.json**
```json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false
}
```

**Characteristics:**
- Strict syntax (must be valid JSON)
- Key-value pairs in curly braces {}
- Arrays with square brackets []
- No comments allowed (unfortunately)
- Must be validated for correctness

### Format 5: Shell Script Format

Some files are actually shell scripts (usually in /etc/default/).

**Example: /etc/default/grub**
```bash
# /etc/default/grub - GRUB bootloader defaults
# Note: This is sourced as a shell script!

GRUB_TIMEOUT=5
GRUB_DEFAULT=0
GRUB_CMDLINE_LINUX="ro quiet splash"
GRUB_DISABLE_OS_PROBER=false
```

**Characteristics:**
- Sourced as shell script (must be valid bash)
- Variable assignments with VAR=value
- Comments with #
- No spaces around =
- Values often quoted for safety

---

## Section 4: Configuration Hierarchy and Precedence

Configuration files are read in a specific order. The first match wins (or last match, depending on tool).

### Typical Hierarchy (Top to Bottom)

```
1. Command-line arguments          ← Highest priority
   └─ e.g., systemctl restart ssh --debug

2. Environment variables           
   └─ e.g., export DEBUG=1; myapp

3. User configuration (~/)         
   └─ e.g., ~/.ssh/config, ~/.bashrc

4. System-wide configuration (/etc)
   └─ e.g., /etc/ssh/sshd_config

5. Installation defaults (/usr)
   └─ e.g., /usr/share/doc/app/examples/

6. Compiled-in defaults            ← Lowest priority
   └─ e.g., port 22 for SSH
```

### Example: SSH Connection Priority

When connecting via SSH, these are checked in order:

```bash
# 1. Command-line flags (highest priority)
ssh -p 2222 -u user hostname

# 2. User's SSH configuration (~/.ssh/config)
Host myserver
  Hostname example.com
  User alice
  Port 2222

# 3. System-wide SSH configuration (/etc/ssh/ssh_config)
# (rarely used for client config)

# 4. SSH hardcoded defaults (lowest priority)
# Default port: 22
# Default user: current user
```

### Configuration Defaults

Applications come with built-in defaults. Configuration files *override* these defaults, not replace them.

```
Actual Behavior = Built-in Defaults + Configuration File Overrides
```

**Example:**
```bash
# NGINX has many built-in defaults (worker processes, buffer sizes, etc.)
# /etc/nginx/nginx.conf overrides only what's specified

# If nginx.conf doesn't specify worker_processes, NGINX uses its default (usually = CPU count)
# If nginx.conf specifies worker_processes 8, it uses 8 instead

# View effective configuration
nginx -T  # Shows configuration with defaults
```

---

## Section 5: Common Configuration Files Deep Dive

### Network Configuration

**File**: /etc/network/interfaces (Debian/Ubuntu)

```bash
# Loopback interface (internal traffic)
auto lo
iface lo inet loopback

# Ethernet interface with DHCP
auto eth0
iface eth0 inet dhcp

# Ethernet interface with static IP
auto eth1
iface eth1 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Reload configuration:**
```bash
sudo systemctl restart networking
# Or newer systems:
sudo netplan apply
```

### SSH Daemon Configuration

**File**: /etc/ssh/sshd_config

**Important directives:**
```bash
# Port to listen on
Port 22

# Network address to listen on
ListenAddress 0.0.0.0
ListenAddress ::

# Root login
PermitRootLogin no

# Password authentication (disable for key-based only)
PasswordAuthentication no

# Public key authentication
PubkeyAuthentication yes

# X11 forwarding
X11Forwarding yes

# Banner before login
Banner /etc/ssh/banner

# Logging level
LogLevel VERBOSE
```

**Validate SSH configuration:**
```bash
sudo sshd -t
# No output = good!
# If errors, it shows them
```

**Reload SSH (doesn't disconnect you):**
```bash
sudo systemctl reload ssh
```

### System Parameters (Kernel Tuning)

**File**: /etc/sysctl.conf or /etc/sysctl.d/99-custom.conf

**Common parameters:**
```bash
# Network tuning
net.ipv4.tcp_fin_timeout = 20          # FIN packet timeout
net.core.somaxconn = 1024              # Max listen queue
net.ipv4.tcp_max_syn_backlog = 2048    # SYN queue size

# Memory
vm.swappiness = 10                     # How aggressive to use swap
vm.dirty_ratio = 30                    # Dirty page ratio for writeback

# File descriptors
fs.file-max = 2097152                  # Max open files system-wide
fs.inode-max = 1048576                 # Max inode cache
```

**Apply sysctl settings:**
```bash
# Apply single parameter
sudo sysctl -w net.ipv4.tcp_fin_timeout=20

# Apply all from file
sudo sysctl -p /etc/sysctl.conf

# View current value
sysctl net.ipv4.tcp_fin_timeout
```

### Filesystem Mounts

**File**: /etc/fstab (filesystem table)

```bash
# Device          Mount       Filesystem  Options           Dump Pass
/dev/sda1         /           ext4        defaults,errors=remount-ro 0 1
/dev/sda2         /boot       ext4        defaults          0 2
/dev/mapper/swap  none        swap        sw                0 0
tmpfs             /tmp        tmpfs       size=2G,nodev     0 0

# NFS mount
nfs.server:/export  /mnt/nfs  nfs         rsize=8192,wsize=8192 0 0
```

**Options explained:**
```
defaults    = rw,suid,dev,exec,auto,nouser,async
errors=remount-ro = remount read-only on error
sw          = swap device
nodev       = don't allow device files
noexec      = don't allow executable files
```

**Apply changes:**
```bash
# Test mount (without reboot)
sudo mount -a

# Verify
mount | grep /dev
```

---

## Section 6: Safe Configuration Editing

### The Golden Rules

**Rule 1: Always backup before editing**
```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d-%H%M%S)
```

**Rule 2: Validate syntax before applying**
```bash
# SSH
sudo sshd -t

# Nginx
sudo nginx -t

# JSON
python3 -m json.tool config.json

# YAML
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"
```

**Rule 3: Use safe editing tools**
```bash
# Use sed with -i.bak to keep backup
sudo sed -i.bak 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config

# Use visudo for sudoers (syntax-checks automatically)
sudo visudo

# Use systemctl edit for systemd files (syntax-checks)
sudo systemctl edit nginx
```

**Rule 4: Test after applying**
```bash
# SSH configuration change
sudo systemctl reload ssh
ssh -v localhost    # Test connection

# Nginx configuration change
sudo nginx -t && sudo systemctl reload nginx
curl http://localhost   # Test web server
```

**Rule 5: Know how to rollback**
```bash
# Immediate rollback
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl reload ssh

# Or restore from version control
cd /etc && sudo git checkout ssh/sshd_config
```

### Safe Editing Workflow

```
1. Backup original
   └─ sudo cp /etc/file /etc/file.backup

2. Make change (carefully!)
   └─ sudo nano /etc/file
   └─ Or: sudo sed -i 's/old/new/' /etc/file

3. Validate syntax
   └─ sudo service-check-config   (if available)
   └─ sudo diff /etc/file /etc/file.backup

4. Apply to service
   └─ sudo systemctl reload servicename

5. Test functionality
   └─ Verify service works with new config

6. Keep backup for reference
   └─ sudo mv /etc/file.backup /etc/file.old
```

---

## Section 7: Configuration Backup and Recovery

### Why Backup?

- Configuration mistakes can break services
- Need to recover after accidental changes
- Want to know what changed (git diff)
- Need version history
- Must restore to other systems

### Simple Backup Strategy

```bash
# Create backup directory
sudo mkdir -p /backup/etc-configs
sudo chmod 700 /backup/etc-configs

# Backup critical configs
sudo tar czf /backup/etc-configs/ssh-backup-$(date +%Y%m%d).tar.gz \
  /etc/ssh

# Backup entire /etc (large but comprehensive)
sudo tar czf /backup/etc-backup-$(date +%Y%m%d).tar.gz \
  /etc \
  --exclude="/etc/ssl/private" \
  --exclude="/etc/shadow"
```

### Using Git for Configuration

```bash
# Initialize repo
sudo git init /etc
cd /etc

# Configure git
sudo git config user.email "admin@example.com"
sudo git config user.name "System Admin"

# Add and commit
sudo git add ssh/sshd_config
sudo git commit -m "Initial SSH configuration"

# Track changes
sudo git log --oneline ssh/sshd_config

# See what changed
sudo git diff HEAD~1 ssh/sshd_config

# Rollback
sudo git checkout ssh/sshd_config
```

**Remember**: Don't track sensitive files
```bash
echo "shadow" >> /etc/.gitignore
echo "ssl/private" >> /etc/.gitignore
```

### Restore from Backup

```bash
# List backup contents
sudo tar tzf /backup/etc-backup-20240115.tar.gz | head -20

# Restore single file
sudo tar xzf /backup/etc-backup-20240115.tar.gz -C / etc/ssh/sshd_config

# Restore entire backup
sudo tar xzf /backup/etc-backup-20240115.tar.gz -C /restore-point/
```

---

## Section 8: Configuration Best Practices

### Best Practice 1: Use Directories for Modular Config

Instead of one large config file, split into logical pieces:

```
/etc/sysctl.conf             ← Old way (monolithic)

/etc/sysctl.d/
├── 10-kernel-security.conf
├── 20-network-tuning.conf
├── 30-vm-settings.conf
└── 99-custom.conf          ← New way (modular)
```

**Advantages:**
- Easy to find specific setting
- Can disable single setting without editing main file
- Different teams can manage different configs
- Clearer intent of each file

### Best Practice 2: Use Descriptive Comments

```bash
# Good: Explains WHY
# Reduce FIN timeout to handle TIME_WAIT states faster
# This is needed for high-traffic web servers with many connections
net.ipv4.tcp_fin_timeout = 20

# Bad: No context
net.ipv4.tcp_fin_timeout = 20
```

### Best Practice 3: Keep Original Comments

Many config files have helpful comments. Don't remove them:

```bash
# Good: Keep comments, add override
# Original: Port 22
# Override for non-standard SSH port
Port 2222

# Bad: Removed original comment context
Port 2222
```

### Best Practice 4: Document Changes

```bash
# /etc/ssh/sshd_config - Modified 2024-01-15
# Changed by: Alice (alice@example.com)
# Reason: Enable key-based auth only for security
# Ticket: SEC-1234

# Allow key-based authentication
PubkeyAuthentication yes

# Disable password authentication (was: yes)
PasswordAuthentication no
```

### Best Practice 5: Use Version Control

Track configuration changes in git:

```bash
git log -p /etc/ssh/sshd_config      # See all changes
git show HEAD:/etc/ssh/sshd_config    # See current version
git blame /etc/ssh/sshd_config        # See who changed what
```

### Best Practice 6: Validate Before Deploying

Never deploy untested configuration:

```bash
# 1. Test on dev system
vagrant up dev-system
vagrant ssh dev-system
sudo sshd -t              # Validate syntax

# 2. Verify functionally
ssh-keyscan -t rsa dev-system

# 3. Deploy to production
ansible-playbook deploy-ssh-config.yml --limit=production
```

---

## Section 9: Configuration Validation Tools

### Manual Syntax Validation

```bash
# SSH
sudo sshd -t

# Nginx
sudo nginx -t

# Apache
sudo apachectl configtest

# Systemd
systemd-analyze verify /etc/systemd/system/myservice.service

# Sudo
sudo -l -f /etc/sudoers

# JSON
python3 -m json.tool /etc/docker/daemon.json

# YAML
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"
```

### Diff and Compare

```bash
# Compare old vs new
diff /etc/ssh/sshd_config /etc/ssh/sshd_config.new

# Compare running config vs file
systemctl status sshd | grep -A 100 "Main PID"

# Show what changed
sudo git diff /etc/ssh/sshd_config
```

### Check Effective Configuration

```bash
# Show configuration with defaults applied
nginx -T          # Shows effective nginx config
```

---

## Section 10: Common Configuration Mistakes and Recovery

### Mistake 1: Typo in SSH Config

**Problem**: Misspelled directive breaks SSH

**Solution**:
```bash
# Bad: "ListnAddress" instead of "ListenAddress"
sudo sshd -t    # Shows error

# Fix
sudo sed -i 's/ListnAddress/ListenAddress/' /etc/ssh/sshd_config
sudo sshd -t    # Validates

# Reload
sudo systemctl reload ssh
```

### Mistake 2: Wrong Permissions in Config

**Problem**: Config file too readable, security issue

**Solution**:
```bash
# Check permissions
ls -la /etc/ssh/sshd_config
# Should be: -rw-r----- 1 root root

# Fix
sudo chmod 640 /etc/ssh/sshd_config
sudo systemctl reload ssh
```

### Mistake 3: Locked Out via SSH

**Problem**: Made SSH change that blocks access

**Solution**:
```bash
# Use console access (if available)
# OR use another SSH session to test before closing first one

# Test before reloading
ssh -o ConnectTimeout=5 hostname "sudo sshd -t"

# If error, don't reload!
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config

# Test again
ssh hostname "echo 'connected'"
```

**Prevention**:
```bash
# Keep existing session open while testing
# In Terminal 1:
ssh user@host
# Now make changes...

# In Terminal 2:
ssh user@host    # Test new connection
# If works, great! If not, change back in Terminal 1
```

### Mistake 4: Applied Config Missing Reload

**Problem**: Changed config file but service didn't pick it up

**Solution**:
```bash
# After changing config, MUST reload or restart

# Some services support reload (no downtime)
sudo systemctl reload sshd

# Some must be restarted
sudo systemctl restart nginx
```

---

## Summary of Key Concepts

1. **Configuration files** control Linux behavior without recompilation
2. **/etc directory** is where system configuration lives
3. **Multiple formats** exist: conf, ini, yaml, json, shell
4. **Hierarchy exists**: command-line > env > user > system > defaults
5. **Always backup** before making changes
6. **Validate syntax** before applying configuration
7. **Use reload** when possible (faster than restart)
8. **Version control** configurations for history and rollback
9. **Test changes** before deploying to production
10. **Document why** changes were made, not just what

---

**Ready for hands-on practice?** → Continue to [03-hands-on-labs.md](03-hands-on-labs.md)
