# Commands Cheatsheet: Security & Firewall

## Quick Reference

### File Permissions & Ownership

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -l` | View file permissions | `ls -l /etc/passwd` → `-rw-r--r-- 1 root root` |
| `chmod` | Change permissions | `chmod 644 file.txt` or `chmod u+x script.sh` |
| `chown` | Change owner | `chown alice:developers file.txt` |
| `chgrp` | Change group | `chgrp sales document.txt` |
| `umask` | View/set default permissions | `umask 077` (restrictive) |
| `stat` | View detailed file info | `stat /etc/passwd` → Shows all metadata |
| `getfacl` | View ACLs | `getfacl file.txt` |
| `setfacl` | Set ACLs | `setfacl -m u:bob:r file.txt` |
| `sudo -l` | View sudo permissions | Shows what commands user can run |

### User & Group Management

| Command | Purpose | Example |
|---------|---------|---------|
| `useradd` | Create user | `sudo useradd -m -s /bin/bash alice` |
| `userdel` | Delete user | `sudo userdel -r alice` (remove home) |
| `usermod` | Modify user | `sudo usermod -aG sudo bob` (add to group) |
| `passwd` | Change password | `passwd` (own) or `sudo passwd bob` |
| `groupadd` | Create group | `sudo groupadd developers` |
| `groupdel` | Delete group | `sudo groupdel developers` |
| `groups` | View user's groups | `groups alice` |
| `id` | View user/group IDs | `id bob` → uid=1001, gid=1002 |
| `w` | View logged-in users | `w` shows who's logged in and what they're doing |
| `last` | View login history | `last` shows last logins |
| `lastb` | View failed logins | `lastb` shows failed login attempts |

### SELinux (RHEL/CentOS)

| Command | Purpose | Example |
|---------|---------|---------|
| `getenforce` | View SELinux mode | Returns: Enforcing, Permissive, Disabled |
| `setenforce` | Change SELinux mode | `sudo setenforce Permissive` (temporary) |
| `sestatus` | Detailed SELinux status | Shows mode, policies, contexts |
| `ls -Z` | View security context | `ls -Z /var/www` |
| `ps -Z` | View process context | `ps -Z` shows running processes with contexts |
| `chcon` | Change context | `sudo chcon -R httpd_sys_content_t /var/www` |
| `semanage` | Manage SELinux policy | `sudo semanage fcontext -a -t type /path` |
| `audit2allow` | Generate policy from denials | `sudo audit2allow -a` (generate rules) |
| `getsebool` | View boolean settings | `getsebool -a` (list all) |
| `setsebool` | Change boolean | `sudo setsebool -P httpd_can_network_connect on` |

### AppArmor (Ubuntu/Debian)

| Command | Purpose | Example |
|---------|---------|---------|
| `aa-status` | View AppArmor status | Shows loaded profiles and modes |
| `aa-logprof` | Generate profile from logs | Interactive tool, creates/updates profiles |
| `aa-enforce` | Enable enforcement | `sudo aa-enforce /etc/apparmor.d/profile` |
| `aa-complain` | Enable complain mode | `sudo aa-complain /etc/apparmor.d/profile` |
| `aa-disable` | Disable profile | `sudo aa-disable /etc/apparmor.d/profile` |
| `apparmor_parser` | Compile profile | `sudo apparmor_parser -r /etc/apparmor.d/profile` |

### Firewall: UFW (Ubuntu)

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ufw status` | View firewall status | Shows enabled/disabled and rules |
| `sudo ufw enable` | Enable firewall | Activates UFW |
| `sudo ufw disable` | Disable firewall | Deactivates UFW |
| `sudo ufw default deny` | Default policy | Drop all incoming (whitelist) |
| `sudo ufw default allow` | Default policy | Allow all incoming (blacklist) |
| `sudo ufw allow 22` | Allow port | `sudo ufw allow 22` (SSH) |
| `sudo ufw allow 80/tcp` | Allow protocol | Allow TCP port 80 |
| `sudo ufw deny 25` | Deny port | Block outgoing mail |
| `sudo ufw delete allow 22` | Remove rule | Delete specific rule |
| `sudo ufw logging on` | Enable logging | Log dropped packets |
| `sudo ufw allow from 192.168.1.0/24` | Allow subnet | Allow specific network |
| `sudo ufw allow from 192.168.1.10 to any port 22` | Allow source | Allow specific IP to specific port |
| `sudo ufw app list` | List app profiles | Show predefined rules |

### Firewall: iptables/nftables

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo iptables -L` | List rules | Show all rules |
| `sudo iptables -L -v` | Verbose listing | Shows packet counts |
| `sudo iptables -L -n` | Numeric listing | Shows IPs instead of hostnames |
| `sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT` | Add rule | Allow SSH |
| `sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT` | Insert at top | Higher priority |
| `sudo iptables -D INPUT -p tcp --dport 25 -j DROP` | Delete rule | Remove rule |
| `sudo iptables -F` | Flush rules | Clear all rules (dangerous!) |
| `sudo iptables -P INPUT DROP` | Set policy | Default action if no match |
| `sudo iptables-save` | Save rules | Output to file for backup |
| `sudo iptables-restore < rules.txt` | Restore rules | Load from file |
| `sudo nft list ruleset` | nftables rules | Modern firewall equivalent |

### SSH & Authentication

| Command | Purpose | Example |
|---------|---------|---------|
| `ssh-keygen` | Generate SSH key pair | `ssh-keygen -t rsa -b 4096` |
| `ssh-copy-id` | Install public key | `ssh-copy-id alice@server.com` |
| `ssh -i key.pem user@host` | Use specific key | Connect with private key |
| `ssh -v` | Verbose SSH | Debug connection issues |
| `ssh-agent` | Manage keys in memory | `eval $(ssh-agent)` then `ssh-add` |
| `ssh-add` | Add key to agent | Load key passphrase into memory |
| `ssh-add -l` | List loaded keys | View keys in agent |
| `sudo sshd -T` | Test SSH config | Validate sshd configuration |
| `sudo systemctl restart ssh` | Restart SSH | Apply configuration changes |

### Security Audit & Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo auditctl -l` | List audit rules | Show active rules |
| `sudo auditctl -a always,exit -F arch=b64 -S execve` | Add rule | Audit process execution |
| `sudo ausearch -k key` | Search audit log | Find events by key |
| `sudo audit2why -a` | Explain denials | Show why SELinux denied access |
| `sudo fail2ban-client status` | Fail2ban status | View blocked IPs |
| `sudo netstat -tulpn` | Listening ports | Show services and ports |
| `sudo ss -tulpn` | Socket stats | Modern replacement for netstat |
| `sudo lsof -i` | Open ports | Show processes using network |
| `sudo iptables -L -n -v` | Firewall stats | Show rule hit counts |
| `journalctl -f` | Follow logs | Real-time log viewing |
| `journalctl -u ssh` | Service logs | SSH service logs |
| `journalctl --since "2 hours ago"` | Recent logs | Last 2 hours |

### File Integrity Checking

| Command | Purpose | Example |
|---------|---------|---------|
| `md5sum` | Calculate MD5 hash | `md5sum file.txt` |
| `sha256sum` | Calculate SHA256 hash | `sha256sum file.txt` |
| `sha256sum file.txt > file.txt.sha256` | Store checksum | Create checksum file |
| `sha256sum -c file.txt.sha256` | Verify checksum | Check file integrity |
| `aide --init` | Initialize AIDE | Create baseline |
| `aide --check` | Check file changes | Detect modifications |

### Sudo Management

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo -l` | List privileges | Show what commands user can run |
| `sudo -l -l` | List full commands | Detailed privilege list |
| `sudo visudo` | Edit sudoers file | SAFE editor (checks syntax) |
| `sudo -u user command` | Run as user | `sudo -u www-data whoami` |
| `sudo -i` | Login shell | Change to root, load profile |
| `sudo su -` | Switch to root | Similar to sudo -i |
| `sudo !!` | Repeat last command as sudo | Re-run previous command elevated |

---

## Common Command Patterns

### Viewing & Managing Permissions

```bash
# View permissions in detail
ls -ld /var/www              # Directory details
ls -la /var/www/             # All files including hidden

# Change permissions
chmod 755 script.sh          # rwxr-xr-x (executable script)
chmod 644 document.txt       # rw-r--r-- (readable file)
chmod 700 ~/.ssh             # rwx------ (private directory)

# Add specific permissions
chmod u+x script.sh          # Add execute for user
chmod g+w document.txt       # Add write for group
chmod o-r secret.txt         # Remove read for others

# Change owner
chown alice:developers file.txt   # Change user and group
chown -R alice:developers /var/www # Recursive

# Common secure permissions
chmod 600 file               # Owner read/write only
chmod 644 file               # Owner rw, group/other read
chmod 755 dir                # Owner rwx, group/other rx
chmod 700 dir                # Owner rwx only (private)
```

### ACL Management

```bash
# View ACLs
getfacl file.txt

# Grant read to user bob
setfacl -m u:bob:r file.txt

# Grant read+write to group sales
setfacl -m g:sales:rw document.txt

# Remove specific ACL entry
setfacl -x u:bob file.txt

# Set default ACLs for new files in directory
setfacl -d -m u:alice:rwx /project/
```

### User & Group Creation

```bash
# Create user with home directory
sudo useradd -m -s /bin/bash alice
# Set password
sudo passwd alice

# Create system user (no login)
sudo useradd -r -s /bin/false www-user

# Create group
sudo groupadd developers

# Add user to group
sudo usermod -aG developers alice

# View user details
id alice
id -Gn alice              # Just group names
```

### Firewall Rules (UFW)

```bash
# Enable and set default policy
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow common services
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS

# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Deny specific port
sudo ufw deny 25          # SMTP

# Delete rule
sudo ufw delete allow 80

# View status
sudo ufw status numbered  # With line numbers
```

### SSH Key Setup

```bash
# Generate key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/mykey

# Copy public key to server
ssh-copy-id -i ~/.ssh/mykey.pub user@server.com

# Or manually add to server
cat ~/.ssh/mykey.pub | ssh user@server.com "cat >> ~/.ssh/authorized_keys"

# Use specific key
ssh -i ~/.ssh/mykey user@server.com

# SSH agent (remember passphrase)
eval $(ssh-agent)
ssh-add ~/.ssh/mykey
ssh user@server.com       # No passphrase needed

# Check agent loaded keys
ssh-add -l
```

### Security Auditing

```bash
# Find SUID files (potential risk)
find / -perm -4000 2>/dev/null

# Find world-writable files
find / -perm -002 -type f 2>/dev/null

# Find files with overly broad permissions
find / -perm 777 2>/dev/null

# Check for empty password fields
awk -F: '($2==""){print $1}' /etc/shadow

# View failed login attempts
lastb | head -20

# Listening ports
sudo netstat -tulpn | grep LISTEN

# Recent logins
last | head -10
```

### SELinux (RHEL/CentOS)

```bash
# Check SELinux status
getenforce                    # Returns mode
sestatus                      # Detailed status
ps -Z                         # Process contexts

# Change context
chcon -t httpd_sys_content_t /var/www/html

# Restore context (from policy)
restorecon -R /var/www/html

# View boolean settings
getsebool httpd_can_network_connect

# Set boolean (permanent)
sudo setsebool -P httpd_can_network_connect on

# Generate policy from denial logs
sudo audit2allow -a
```

---

## Troubleshooting Security Issues

### Permission Denied Errors

```bash
# Check file permissions
ls -l file.txt

# Check your user/group
id

# Check if in required group
groups

# Fix permissions
chmod 644 file.txt        # If owner
sudo chown user:group file.txt  # If wrong owner
```

### Firewall Blocking Legitimate Traffic

```bash
# Check rules
sudo ufw status
sudo iptables -L -v

# Test connectivity
telnet server.com 22      # Test port connectivity
nc -zv server.com 80      # netcat port test

# Temporarily allow for testing
sudo ufw allow 8080
# Test
sudo ufw delete allow 8080  # Remove test rule
```

### SELinux Denials

```bash
# Check for denials
journalctl | grep "SELinux"
ausearch -m denied

# See why
sudo audit2why -a

# Generate policy
sudo audit2allow -a

# Apply policy
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www(/.*)?"
restorecon -R /var/www
```

---

## Quick Facts

- **File permissions**: Owner (3 bits), Group (3 bits), Other (3 bits)
- **SUID files**: Run as owner → Security risk, audit regularly
- **Default policy**: Whitelist (allow specific) is more secure than blacklist
- **SSH keys**: 4096-bit RSA recommended for new keys
- **umask 077**: Very restrictive (files: 600, dirs: 700)
- **ACLs**: Extend beyond user/group/other
- **SELinux**: Type enforcement prevents privilege escalation
- **AppArmor**: Profile-based confinement (Ubuntu/Debian)
- **sudo -l**: Always check what you're allowed to do
- **Fail2ban**: Blocks IPs with repeated failed logins
