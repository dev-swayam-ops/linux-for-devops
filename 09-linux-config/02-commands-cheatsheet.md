# Module 09: Linux Configuration - Commands Cheatsheet

Quick reference for configuration management commands and patterns.

---

## Part A: Viewing Configuration Files

### cat - Display entire file

```bash
# View entire configuration
cat /etc/ssh/sshd_config

# View with line numbers
cat -n /etc/ssh/sshd_config

# View with non-printing characters visible
cat -A /etc/ssh/sshd_config
```

### less - View file with pagination

```bash
# View large file page by page
less /etc/ssh/sshd_config

# Search within less: type / then pattern
# Press 'n' for next match, 'q' to quit
```

### head/tail - View beginning or end

```bash
# First 10 lines
head /etc/ssh/sshd_config

# First 20 lines
head -20 /etc/ssh/sshd_config

# Last 10 lines
tail /etc/ssh/sshd_config

# Last 20 lines
tail -20 /etc/ssh/sshd_config

# Follow file as it's written (logs)
tail -f /var/log/syslog
```

### grep - Search configuration

```bash
# Find specific directive
grep "^Port" /etc/ssh/sshd_config
# Output: Port 22

# Find all non-comment lines
grep -v "^#" /etc/ssh/sshd_config

# Find lines that aren't empty or comments
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

# Case-insensitive search
grep -i "port" /etc/ssh/sshd_config

# Show line numbers
grep -n "Port" /etc/ssh/sshd_config

# Search multiple files
grep "^Port" /etc/ssh/*
```

### wc - Count lines/words

```bash
# Count lines in file
wc -l /etc/ssh/sshd_config

# Count words
wc -w /etc/ssh/sshd_config

# Count characters
wc -c /etc/ssh/sshd_config
```

---

## Part B: Editing Configuration Files

### nano - Simple text editor

```bash
# Edit file
sudo nano /etc/ssh/sshd_config

# Key bindings:
# Ctrl+X = Exit
# Ctrl+O = Save
# Ctrl+W = Search
# Ctrl+K = Cut line
# Ctrl+U = Paste line
```

### vi/vim - Advanced text editor

```bash
# Edit file
sudo vim /etc/ssh/sshd_config

# Key commands:
# :q = Quit
# :wq = Save and quit
# :q! = Quit without saving
# /pattern = Search
# i = Insert mode
# Esc = Command mode
# dd = Delete line
# yy = Copy line
# p = Paste
```

### visudo - Safe sudoers editing

```bash
# Edit sudoers safely (validates syntax)
sudo visudo

# Edit specific sudoers file
sudo visudo -f /etc/sudoers.d/mygroup
```

### sed - Stream editor (modify inline)

```bash
# Replace first occurrence on each line
sed 's/old/new/' /etc/file

# Replace all occurrences
sed 's/old/new/g' /etc/file

# Replace and save backup
sed -i.bak 's/old/new/g' /etc/file

# Use different delimiter (useful for paths)
sed 's|/old/path|/new/path|g' /etc/file

# Delete lines matching pattern
sed '/^#/d' /etc/file      # Remove comments
sed '/^$/d' /etc/file      # Remove empty lines

# Show only lines matching pattern
sed -n '/Port/p' /etc/ssh/sshd_config

# Multiple edits
sed -e 's/old1/new1/' -e 's/old2/new2/' /etc/file
```

**Real examples:**
```bash
# Disable root login in SSH
sudo sed -i.bak 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Change SSH port
sudo sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config

# Update network address
sudo sed -i 's/192.168.1.0/10.0.0.0/g' /etc/sysconfig/network

# Comment out a line
sudo sed -i 's/^/#/' /etc/file.conf     # Comment all non-empty lines
sudo sed -i 's/^#*/# /' /etc/file.conf # Comment any line
```

---

## Part C: Configuration Comparison and Diff

### diff - Compare two files

```bash
# Show differences between files
diff /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Show side-by-side
diff -y /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Ignore whitespace differences
diff -w /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Show with context
diff -u /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Recursive directory diff
diff -r /etc/nginx/ /etc/nginx.backup/
```

### patch - Apply difference files

```bash
# Create patch file
diff -u original.conf new.conf > changes.patch

# Apply patch
patch original.conf < changes.patch

# Reverse patch (undo)
patch -R original.conf < changes.patch
```

### git - Version control for configs

```bash
# Initialize config repository
cd /etc && sudo git init

# Add and commit
sudo git add ssh/sshd_config
sudo git commit -m "Initial SSH configuration"

# View history
sudo git log --oneline ssh/sshd_config

# See what changed
sudo git diff HEAD~1 ssh/sshd_config

# Show current vs committed
sudo git diff ssh/sshd_config

# Rollback to previous version
sudo git checkout ssh/sshd_config
```

---

## Part D: Configuration Validation

### Syntax checking tools

```bash
# SSH daemon configuration
sudo sshd -t
# Output: Success (no output = good)
# Or: Error messages if syntax problems

# Nginx web server
sudo nginx -t
# Output: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok

# Apache web server
sudo apachectl configtest
# Output: Syntax OK

# Sudo configuration (sudoers file)
sudo -l -f /etc/sudoers
# Lists parsed sudo rules

# JSON validation
python3 -m json.tool /etc/docker/daemon.json

# YAML validation
python3 -c "import yaml; yaml.safe_load(open('/path/to/file.yaml'))"
```

### systemd configuration validation

```bash
# Check systemd syntax
systemd-analyze syntax /etc/systemd/system/myservice.service

# Show service configuration
systemctl cat myservice

# Show effective configuration
systemctl show myservice
```

---

## Part E: Managing Service Configuration

### systemctl - Service control

```bash
# View service configuration
systemctl cat ssh

# Show service status
systemctl status ssh

# Check if service reads config correctly
systemctl try-reload-or-restart ssh

# Enable service at boot
sudo systemctl enable ssh

# Disable service at boot
sudo systemctl disable ssh
```

### Reload vs Restart

```bash
# Reload configuration (service keeps running)
# Better: faster, no downtime
sudo systemctl reload ssh

# Restart service (service stops then starts)
# Necessary when: reload not supported, major changes
sudo systemctl restart ssh

# Try reload, fallback to restart
sudo systemctl try-reload-or-restart ssh
```

### Check service logs

```bash
# Recent log entries
journalctl -u ssh -n 20

# Follow log output
journalctl -u ssh -f

# Since specific time
journalctl -u ssh --since "2024-01-15 10:00:00"

# See service startup errors
systemctl status ssh
```

---

## Part F: Kernel Parameters (sysctl)

### View kernel parameters

```bash
# View all parameters
sysctl -a

# View specific parameter
sysctl net.ipv4.tcp_fin_timeout

# Search for parameter
sysctl -a | grep tcp_fin

# View from specific section
sysctl net.*
```

### Modify kernel parameters

```bash
# Temporary (until reboot)
sudo sysctl -w net.ipv4.tcp_fin_timeout=20

# Permanent (add to /etc/sysctl.conf)
sudo bash -c "echo 'net.ipv4.tcp_fin_timeout=20' >> /etc/sysctl.conf"

# Apply all from file
sudo sysctl -p

# Apply from specific file
sudo sysctl -p /etc/sysctl.d/99-custom.conf
```

**Common parameters:**
```bash
# Network tuning
net.ipv4.tcp_fin_timeout=20
net.core.somaxconn=1024

# Memory
vm.swappiness=10

# File descriptors
fs.file-max=2097152
```

---

## Part G: Backup and Recovery Commands

### Creating backups

```bash
# Single file backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Backup with timestamp
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d-%H%M%S)

# Backup entire directory
sudo tar czf ssh-backup-$(date +%Y%m%d).tar.gz /etc/ssh

# Backup with exclusions
sudo tar czf etc-backup.tar.gz \
  --exclude="/etc/ssl/private" \
  --exclude="/etc/shadow" \
  /etc

# Create compressed backup to remote
tar czf - /etc/ssh | ssh backup@host "cat > /backups/ssh-$(date +%Y%m%d).tar.gz"
```

### Restoring backups

```bash
# Restore single file
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config

# Restore from tar
sudo tar xzf ssh-backup-20240115.tar.gz -C / etc/ssh/sshd_config

# List tar contents
tar tzf ssh-backup-20240115.tar.gz

# Restore to alternate location
tar xzf ssh-backup-20240115.tar.gz -C /tmp/restore-point/
```

---

## Part H: Finding Configuration Files

### locate - Find files by name

```bash
# Find all SSH config files
locate sshd_config

# Find nginx configs
locate nginx.conf

# Update locate database
sudo updatedb
```

### find - Search filesystem

```bash
# Find in /etc
find /etc -name "*.conf" | head -20

# Find configuration files modified today
find /etc -name "*.conf" -mtime 0

# Find by size
find /etc -name "*.conf" -size +100k

# Find by owner
find /etc -name "*.conf" -user root

# Execute command on found files
find /etc -name "*.conf" -exec ls -la {} \;
```

### grep - Search file contents

```bash
# Find which file contains setting
grep -r "Port 22" /etc/ssh/

# Search /etc for parameter
grep -r "tcp_fin_timeout" /etc/

# Show filename and line number
grep -rn "tcp_fin_timeout" /etc/
```

---

## Part I: Common Configuration Tasks

### Task 1: Change SSH Port

```bash
# 1. Backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 2. Edit
sudo sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config

# 3. Validate
sudo sshd -t

# 4. Reload
sudo systemctl reload ssh

# 5. Test
ssh -v -p 2222 localhost
```

### Task 2: Enable SSH Key-Only Login

```bash
# 1. Backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 2. Disable password auth
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# 3. Validate
sudo sshd -t

# 4. Reload
sudo systemctl reload ssh

# 5. Verify (have key-based auth ready first!)
ssh-keyscan localhost
```

### Task 3: Find and Fix World-Readable Files

```bash
# Find world-readable config files (potential security issue)
find /etc -type f -perm -004 2>/dev/null | head -10

# Check specific files
ls -la /etc/shadow /etc/shadow-        # Should be 600
ls -la /etc/passwd /etc/group          # Should be 644

# Fix if needed
sudo chmod 600 /etc/shadow
sudo chmod 640 /etc/ssl/private/*
```

### Task 4: Backup All Configuration

```bash
# Backup to external location
BACKUP_DIR="/backup/configs"
sudo mkdir -p "$BACKUP_DIR"

# Full /etc backup
sudo tar czf "$BACKUP_DIR/etc-$(date +%Y%m%d).tar.gz" \
  --exclude="/etc/ssl/private" \
  /etc

# Verify backup
sudo tar tzf "$BACKUP_DIR/etc-$(date +%Y%m%d).tar.gz" | wc -l
```

### Task 5: Deploy Configuration to Multiple Servers

```bash
# Method 1: SCP
for server in web1 web2 web3; do
  sudo scp /etc/nginx/nginx.conf $server:/tmp/
  ssh $server "sudo cp /tmp/nginx.conf /etc/nginx/ && sudo nginx -t && sudo systemctl reload nginx"
done

# Method 2: Ansible (if available)
ansible all -m copy -a "src=/etc/nginx/nginx.conf dest=/etc/nginx/nginx.conf"
ansible all -m command -a "nginx -t && systemctl reload nginx"

# Method 3: Via git
for server in web1 web2 web3; do
  ssh $server "cd /etc && sudo git pull origin main && sudo sysctl -p"
done
```

---

## Part J: Configuration Patterns

### Pattern 1: View Active Configuration (ignoring comments)

```bash
# SSH
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

# Nginx
grep -v "^#" /etc/nginx/nginx.conf | grep -v "^$"

# Apache
grep -v "^#" /etc/apache2/apache2.conf | grep -v "^$"

# Generic command
grep -v "^#" /path/to/config | grep -v "^$"
```

### Pattern 2: Compare Two Versions

```bash
# Side-by-side diff
diff -y --suppress-common-lines /etc/file.old /etc/file.new

# Show only changes
diff /etc/file.old /etc/file.new | grep "^[<>]"

# Generate patch
diff -u /etc/file.old /etc/file.new > changes.patch
```

### Pattern 3: Safely Apply sed Changes

```bash
# Test sed without modifying
sed 's/old/new/g' /etc/file | head -20

# Apply with backup
sed -i.backup 's/old/new/g' /etc/file

# Verify
diff /etc/file /etc/file.backup
```

### Pattern 4: Find and Backup Then Modify

```bash
#!/bin/bash
# Safe modification pattern

FILE="/etc/ssh/sshd_config"
BACKUP_DIR="/backups"
OLD_VALUE="^#Port 22"
NEW_VALUE="Port 2222"

# Create backup
mkdir -p "$BACKUP_DIR"
sudo cp "$FILE" "$BACKUP_DIR/$(basename $FILE).$(date +%Y%m%d-%H%M%S)"

# Show what will change
echo "Will change:"
grep "$OLD_VALUE" "$FILE"

# Apply change
sudo sed -i "s/$OLD_VALUE/$NEW_VALUE/" "$FILE"

# Validate
echo "Validation:"
grep "Port" "$FILE"

# Reload
sudo sshd -t && sudo systemctl reload ssh
```

---

## Part K: Quick Reference Table

| Task | Command | Notes |
|------|---------|-------|
| View file | `cat /etc/file` | Use less for large files |
| Search file | `grep pattern /etc/file` | Use -v to invert, -i for case-insensitive |
| Edit file | `sudo nano /etc/file` | Or vim, visudo for sudoers |
| Replace text | `sudo sed -i 's/old/new/' /etc/file` | Always backup with -i.bak |
| Compare files | `diff file1 file2` | Use -u for unified diff |
| Validate SSH | `sudo sshd -t` | Run before reloading |
| Reload service | `sudo systemctl reload sshd` | Faster than restart |
| Restart service | `sudo systemctl restart sshd` | Necessary for major changes |
| View logs | `journalctl -u sshd -f` | Follow with -f flag |
| View sysctl param | `sysctl param.name` | Apply with -w (temp) or -p (permanent) |
| Backup file | `sudo cp file file.backup` | Use $(date +%Y%m%d) for timestamp |
| Restore file | `sudo cp file.backup file` | Verify before reloading service |
| Find files | `find /etc -name "*.conf"` | Add -mtime 0 for today's changes |
| Search all files | `grep -r pattern /etc` | Add -n for line numbers |

---

## Part L: Best Practices and Tips

### Best Practice 1: Always Backup First
```bash
# Golden rule: backup before every edit
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%s)
```

### Best Practice 2: Validate Before Applying
```bash
# Test the change will work
sudo sshd -t
# Only reload if validation passes
sudo systemctl reload ssh
```

### Best Practice 3: Keep Previous SSH Session Open
```bash
# Terminal 1: Make change
ssh user@server
sudo nano /etc/ssh/sshd_config

# Terminal 2: Test new connection before closing Terminal 1
ssh -p 2222 user@server    # Test new port

# If Terminal 2 works, Terminal 1 can be closed safely
```

### Best Practice 4: Use Version Control
```bash
cd /etc && sudo git init
sudo git config user.email "admin@example.com"
sudo git add ssh/
sudo git commit -m "Initial SSH configuration"
# Now track all changes with git
```

### Best Practice 5: Document Changes
```bash
# Add comment explaining why
sudo bash -c 'echo "
# Changed 2024-01-15 by Alice
# Reason: Disable password auth for security
# Ticket: SEC-1234
PasswordAuthentication no
" >> /etc/ssh/sshd_config'
```

### Common Mistake 1: Forgetting to Reload
```bash
# Wrong: Changed file but didn't reload
sudo sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
# Service still using old config!

# Right: Also reload
sudo sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
sudo systemctl reload ssh    # <-- This is essential
```

### Common Mistake 2: Editing Backup by Accident
```bash
# Wrong: Editing backup instead of original
sudo nano /etc/ssh/sshd_config.backup
# Changes are lost!

# Right: Edit original, keep backup
sudo nano /etc/ssh/sshd_config
# If error, restore: cp sshd_config.backup sshd_config
```

### Common Mistake 3: Not Validating Syntax
```bash
# Wrong: Apply without validation
sudo sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
sudo systemctl reload ssh
# Error: SSH won't start!

# Right: Validate first
sudo sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
sudo sshd -t                      # Check syntax
sudo systemctl reload ssh         # Reload if good
```

### Common Mistake 4: Removing Comments
```bash
# Wrong: Delete comments while editing
# Old comment: Port 22
Port 2222
# Now forgot why this was changed!

# Right: Keep context
# Changed from: Port 22 (default SSH port)
# Reason: Need non-standard port for security
Port 2222
```

### Common Mistake 5: Testing Without Backup
```bash
# Wrong: Make change without backup
sudo sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
# Error! Now no easy rollback

# Right: Backup first
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
sudo sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
# Can easily: cp sshd_config.backup sshd_config
```

---

## Summary

| Category | Key Commands |
|----------|--------------|
| **View** | cat, less, head, tail, grep |
| **Edit** | nano, vim, sed, visudo |
| **Compare** | diff, patch, git diff |
| **Validate** | sshd -t, nginx -t, sysctl -p |
| **Manage** | systemctl, sysctl |
| **Backup** | cp, tar, git commit |
| **Search** | find, locate, grep -r |

**Remember**: Safety first! Always backup, always validate, always test!

---

**Ready for hands-on labs?** → Continue to [03-hands-on-labs.md](03-hands-on-labs.md)
