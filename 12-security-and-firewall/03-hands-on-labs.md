# Hands-On Labs: Security & Firewall

All labs should be performed on a **VM or test system**, NOT on a production machine.

---

## Lab 1: Audit and Fix File Permissions

**Goal:** Analyze file permissions and identify security issues

**Time:** 20 minutes

### Setup

No special setup needed. Work on your current system.

### Steps

1. **Find files with overly broad permissions**
   ```bash
   # World-writable files (security risk)
   find /home -perm -002 -type f 2>/dev/null
   
   # SUID files (always executable as owner)
   find /usr/bin -perm -4000 2>/dev/null
   ```

2. **Check specific critical files**
   ```bash
   # Passwords (should be readable only by root)
   ls -l /etc/passwd /etc/shadow
   
   # SSH keys (must be private)
   ls -la ~/.ssh/
   
   # Sudo config (must be protected)
   ls -l /etc/sudoers
   ```

3. **View detailed permissions**
   ```bash
   stat /etc/passwd
   stat /etc/shadow
   ```

4. **Create test files and check default permissions**
   ```bash
   touch test-file.txt
   mkdir test-dir
   ls -la test-file.txt test-dir
   
   # Check your umask
   umask
   ```

5. **Fix overly permissive file**
   ```bash
   # Create a file with bad permissions for demo
   echo "secret" > secret.txt
   chmod 666 secret.txt          # Too permissive
   ls -l secret.txt
   
   # Fix it
   chmod 644 secret.txt
   ls -l secret.txt
   ```

### Expected Output

```
$ find /usr/bin -perm -4000 2>/dev/null | head -5
/usr/bin/sudo
/usr/bin/passwd
/usr/bin/chsh
/usr/bin/chfn
/usr/bin/newgrp

$ ls -l /etc/passwd /etc/shadow
-rw-r--r-- 1 root root /etc/passwd
---------- 1 root root /etc/shadow    # root only!

$ ls -la ~/.ssh/
total 24
drwx------ 2 alice alice  .
-rw------- 1 alice alice  id_rsa      # private key: 600
-rw-r--r-- 1 alice alice  id_rsa.pub  # public key: 644

$ stat /etc/shadow
File: /etc/shadow
Access: (0000/----------)  Uid: (    0/    root)  Gid: (    0/    root)
```

### Verification Checklist

- [ ] Found SUID files
- [ ] Verified critical files have correct permissions
- [ ] Understand umask and default permissions
- [ ] Fixed test file permissions

### Cleanup

```bash
rm secret.txt test-file.txt
rmdir test-dir
```

---

## Lab 2: Configure User Permissions with ACLs

**Goal:** Extend file permissions using Access Control Lists

**Time:** 25 minutes

### Setup

Create test users and group:
```bash
sudo groupadd testgroup
sudo useradd -m testuser1
sudo useradd -m testuser2
```

### Steps

1. **Create a shared project directory**
   ```bash
   mkdir ~/project
   echo "Project data" > ~/project/document.txt
   ls -la ~/project/
   ```

2. **View current permissions (no ACL)**
   ```bash
   getfacl ~/project/
   getfacl ~/project/document.txt
   ```

3. **Grant testuser1 read-only access**
   ```bash
   sudo setfacl -m u:testuser1:r ~/project/document.txt
   getfacl ~/project/document.txt
   ```

4. **Grant testuser2 read+write access**
   ```bash
   sudo setfacl -m u:testuser2:rw ~/project/document.txt
   getfacl ~/project/document.txt
   ```

5. **Grant testgroup read access**
   ```bash
   sudo setfacl -m g:testgroup:r ~/project/document.txt
   getfacl ~/project/document.txt
   ```

6. **Set default ACL for future files**
   ```bash
   sudo setfacl -d -m u:testuser1:r ~/project/
   
   # Create new file
   touch ~/project/newfile.txt
   getfacl ~/project/newfile.txt
   ```

7. **Remove specific ACL entry**
   ```bash
   sudo setfacl -x u:testuser2 ~/project/document.txt
   getfacl ~/project/document.txt
   ```

### Expected Output

```
$ getfacl ~/project/document.txt
# file: project/document.txt
# owner: alice
# group: alice
user::rw-
user:testuser1:r--
user:testuser2:rw-
group::---
group:testgroup:r--
mask::rw-
other::---
```

### Verification Checklist

- [ ] Created ACL entries for users
- [ ] Verified permissions with getfacl
- [ ] Set default ACL for directory
- [ ] Removed ACL entry successfully

### Cleanup

```bash
rm -rf ~/project
sudo userdel -r testuser1 testuser2
sudo groupdel testgroup
```

---

## Lab 3: Configure sudo Privileges

**Goal:** Grant selective privilege escalation with sudo

**Time:** 20 minutes

### Setup

Create test user:
```bash
sudo useradd -m devops
```

### Steps

1. **View sudo configuration**
   ```bash
   sudo visudo -c         # Check syntax
   sudo cat /etc/sudoers  # View sudoers file
   
   # Or safer:
   sudo visudo --check
   ```

2. **Check current user's sudo privileges**
   ```bash
   sudo -l               # What can this user do?
   ```

3. **Add user to sudo group (for admin)**
   ```bash
   sudo usermod -aG sudo devops
   
   # Test (switch to devops user)
   sudo sudo -u devops sudo -l
   ```

4. **Create specific sudo rule without password**
   ```bash
   sudo visudo
   
   # Add this line:
   # devops ALL=(ALL) NOPASSWD: /usr/bin/systemctl
   # This allows devops to control systemd without password
   ```

5. **Create rule allowing specific command as specific user**
   ```bash
   sudo visudo
   
   # Add:
   # devops ALL=(www-data) /usr/bin/id
   # This allows: sudo -u www-data /usr/bin/id
   ```

6. **View sudo command history**
   ```bash
   sudo journalctl SYSLOG_IDENTIFIER=sudo
   # or
   grep "sudo:" /var/log/auth.log | tail -10
   ```

### Expected Output

```
$ sudo -l
Matching Defaults entries for alice on ubuntu:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User alice may run the following commands:
    (ALL : ALL) ALL    # Can run anything
```

### Verification Checklist

- [ ] Viewed sudoers file safely
- [ ] Added sudo privileges
- [ ] Created specific allow rules
- [ ] Viewed sudo command logs

### Cleanup

```bash
sudo userdel -r devops
```

---

## Lab 4: SSH Key-Based Authentication

**Goal:** Set up passwordless SSH with key pairs

**Time:** 25 minutes

### Setup

Have another Linux system or user account for SSH testing.

### Steps

1. **Generate SSH key pair**
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/lab-key -N ""
   # Creates: ~/.ssh/lab-key (private) and ~/.ssh/lab-key.pub (public)
   
   ls -la ~/.ssh/lab-key*
   ```

2. **Check permissions**
   ```bash
   stat ~/.ssh/lab-key
   # Should be 600 (rw-------)
   ```

3. **View the keys**
   ```bash
   cat ~/.ssh/lab-key.pub     # This goes on servers
   cat ~/.ssh/lab-key         # Keep this secret!
   ```

4. **Copy public key to server**
   ```bash
   # Option 1: Using ssh-copy-id
   ssh-copy-id -i ~/.ssh/lab-key.pub user@server.com
   
   # Option 2: Manual
   cat ~/.ssh/lab-key.pub | ssh user@server.com "cat >> ~/.ssh/authorized_keys"
   ```

5. **Test SSH connection with key**
   ```bash
   ssh -i ~/.ssh/lab-key user@server.com
   # Should connect without password
   ```

6. **Set up SSH agent (remember passphrase)**
   ```bash
   eval $(ssh-agent)
   ssh-add ~/.ssh/lab-key
   # Enter passphrase once
   
   # Now SSH remembers it
   ssh user@server.com
   ```

7. **View loaded keys in agent**
   ```bash
   ssh-add -l
   ```

### Expected Output

```
$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/lab-key -N ""
Generating public/private rsa key pair.
Your identification has been saved in ~/.ssh/lab-key
Your public key has been saved in ~/.ssh/lab-key.pub
The key fingerprint is:
SHA256:xxxxxxxxxxxxx alice@ubuntu

$ ls -la ~/.ssh/lab-key*
-rw------- 1 alice alice 3389 Jan 15 10:30 lab-key
-rw-r--r-- 1 alice alice  744 Jan 15 10:30 lab-key.pub

$ ssh -i ~/.ssh/lab-key user@server.com
Welcome to server!
$ 
# Note: No password prompt!
```

### Verification Checklist

- [ ] Generated RSA key pair
- [ ] Public key copied to server
- [ ] SSH works without password
- [ ] SSH agent configured

### Cleanup

```bash
# Remove from server
ssh user@server.com "grep -v 'lab-key' ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp && mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys"

# Or remove key locally
rm ~/.ssh/lab-key ~/.ssh/lab-key.pub
```

---

## Lab 5: Basic UFW Firewall Rules

**Goal:** Configure Ubuntu firewall with common rules

**Time:** 20 minutes

### Setup

Ubuntu system with UFW installed (default on Ubuntu).

### Steps

1. **Check firewall status**
   ```bash
   sudo ufw status
   # Should show: Status: inactive
   ```

2. **Set default policies**
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```

3. **Enable firewall**
   ```bash
   sudo ufw enable
   # Confirm: y
   ```

4. **Verify status**
   ```bash
   sudo ufw status
   # Shows: Status: active
   ```

5. **Allow SSH (important: don't lock yourself out!)**
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw status numbered
   ```

6. **Allow HTTP and HTTPS**
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw status numbered
   ```

7. **Allow specific IP**
   ```bash
   sudo ufw allow from 192.168.1.100 to any port 3306
   # Allows only this IP to port 3306 (MySQL)
   ```

8. **Deny specific service**
   ```bash
   sudo ufw deny 25
   # Block SMTP (no outgoing email)
   ```

9. **Delete a rule**
   ```bash
   sudo ufw delete deny 25
   # Or with line number:
   sudo ufw delete 5
   ```

10. **View detailed logging**
    ```bash
    sudo ufw logging on
    # Check logs
    sudo journalctl -u ufw -f
    ```

### Expected Output

```
$ sudo ufw status numbered
     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 443/tcp                    ALLOW IN    Anywhere
[ 4] 3306                       ALLOW IN    192.168.1.100
```

### Verification Checklist

- [ ] Firewall enabled
- [ ] SSH rule created (don't lock yourself out!)
- [ ] HTTP/HTTPS rules added
- [ ] Specific IP rule working
- [ ] Rule deletion successful

### Cleanup

```bash
# To disable firewall (restore to start)
sudo ufw disable

# Or keep it and just remove rules
sudo ufw delete allow 80/tcp
sudo ufw delete allow 443/tcp
```

---

## Lab 6: Firewall for Web Server

**Goal:** Configure firewall rules for Apache/Nginx web server

**Time:** 30 minutes

### Setup

Have a web server installed (Apache2 or Nginx).

### Steps

1. **Check if UFW is running**
   ```bash
   sudo ufw status
   ```

2. **View UFW application profiles**
   ```bash
   sudo ufw app list
   # Should show: Nginx Full, Nginx HTTP, Nginx HTTPS, Apache Full, etc.
   ```

3. **Allow using application profile**
   ```bash
   # For Apache:
   sudo ufw allow "Apache Full"
   # or Nginx:
   sudo ufw allow "Nginx Full"
   ```

4. **Verify rules**
   ```bash
   sudo ufw status numbered
   ```

5. **Test connectivity (from another machine)**
   ```bash
   curl http://server-ip
   curl https://server-ip
   ```

6. **Allow only HTTP (not HTTPS)**
   ```bash
   sudo ufw delete "Apache Full"
   sudo ufw allow "Apache HTTP"
   ```

7. **Allow from specific network only**
   ```bash
   sudo ufw delete "Apache HTTP"
   sudo ufw allow from 192.168.1.0/24 to any port 80
   ```

8. **Check logs for blocked connections**
   ```bash
   sudo tail -f /var/log/ufw.log
   # Or from another machine, try accessing from non-allowed IP
   ```

### Expected Output

```
$ sudo ufw app list
Available applications:
  Apache
  Apache Full
  Apache Secure
  Nginx Full
  Nginx HTTP
  Nginx HTTPS

$ sudo ufw status numbered
     To                         Action      From
     --                         ------      ----
[ 1] 80/tcp                     ALLOW IN    192.168.1.0/24
[ 2] 443/tcp                    ALLOW IN    192.168.1.0/24
```

### Verification Checklist

- [ ] Used UFW application profiles
- [ ] Web server accessible from allowed networks
- [ ] Blocked networks cannot access
- [ ] Rules match security policy

### Cleanup

```bash
sudo ufw delete "Apache Full"
# or restore to defaults
```

---

## Lab 7: SELinux Basic Operations (RHEL/CentOS)

**Goal:** Work with SELinux contexts and enforce/permissive mode

**Time:** 25 minutes

### Setup

RHEL/CentOS system with SELinux (Ubuntu uses AppArmor instead).

### Steps

1. **Check SELinux status**
   ```bash
   getenforce
   # Returns: Enforcing, Permissive, or Disabled
   
   sestatus
   # Detailed status
   ```

2. **View SELinux mode**
   ```bash
   grep "^SELINUX=" /etc/selinux/config
   ```

3. **Check file contexts**
   ```bash
   ls -Z /var/www/html
   # Shows contexts: user:role:type:level
   ```

4. **Switch to permissive mode (temporary)**
   ```bash
   sudo setenforce Permissive
   getenforce
   # Returns: Permissive
   ```

5. **Create test directory and file**
   ```bash
   mkdir ~/test-dir
   echo "test" > ~/test-dir/file.txt
   ls -Z ~/test-dir/
   ```

6. **Change context**
   ```bash
   sudo chcon -t user_home_t ~/test-dir/file.txt
   ls -Z ~/test-dir/file.txt
   ```

7. **Restore context from policy**
   ```bash
   sudo restorecon -R ~/test-dir/
   ls -Z ~/test-dir/
   ```

8. **Check for denials**
   ```bash
   sudo journalctl | grep "SELinux"
   ausearch -m denied
   ```

9. **Switch back to enforcing (be careful!)**
   ```bash
   sudo setenforce Enforcing
   getenforce
   ```

### Expected Output

```
$ getenforce
Enforcing

$ ls -Z /var/www/html
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 index.html

$ sudo setenforce Permissive
$ getenforce
Permissive
```

### Verification Checklist

- [ ] Viewed SELinux status and mode
- [ ] Checked file contexts
- [ ] Switched between modes
- [ ] Changed and restored contexts
- [ ] Understood denial messages

### Cleanup

```bash
rm -rf ~/test-dir
sudo setenforce Enforcing  # Return to enforcing if changed
```

---

## Lab 8: Monitor Security Events

**Goal:** View and analyze security-related logs and events

**Time:** 20 minutes

### Setup

No special setup needed.

### Steps

1. **View failed login attempts**
   ```bash
   sudo lastb | head -20
   # Shows failed login attempts
   ```

2. **View successful logins**
   ```bash
   sudo last | head -20
   # Shows successful logins
   ```

3. **Check sudo command history**
   ```bash
   sudo journalctl SYSLOG_IDENTIFIER=sudo
   # or
   sudo grep "sudo:" /var/log/auth.log | tail -20
   ```

4. **View failed sudo attempts**
   ```bash
   sudo grep "sudo.*COMMAND=" /var/log/auth.log | grep -v "ACCEPT" | head -10
   ```

5. **Check SSH login attempts**
   ```bash
   sudo grep "sshd.*Failed password" /var/log/auth.log | wc -l
   # Count failed attempts
   
   sudo grep "sshd.*Accepted" /var/log/auth.log | tail -10
   # Recent successful logins
   ```

6. **View firewall blocks**
   ```bash
   sudo journalctl -u ufw -f
   # View in real-time
   ```

7. **Check audit logs**
   ```bash
   sudo auditctl -l
   # View audit rules
   
   sudo ausearch -m failed
   # View failed events
   ```

8. **Check user/group changes**
   ```bash
   sudo grep "useradd\|userdel\|usermod" /var/log/auth.log
   ```

### Expected Output

```
$ sudo lastb | head -5
bob      ssh      192.168.1.50     Sat Jan 15 10:30 - 10:32 (00:01)
alice    ssh      192.168.1.100    Fri Jan 14 22:15 - 22:17 (00:01)

$ sudo journalctl SYSLOG_IDENTIFIER=sudo | tail -5
Jan 15 10:45:30 ubuntu sudo: alice : TTY=pts/0 ; PWD=/home/alice ; USER=root ; COMMAND=/usr/bin/systemctl status ssh

$ sudo grep "sshd.*Failed password" /var/log/auth.log | wc -l
12
```

### Verification Checklist

- [ ] Viewed failed login attempts
- [ ] Checked sudo command logs
- [ ] Found SSH login history
- [ ] Viewed firewall blocks
- [ ] Understood log formats

### Cleanup

No cleanup needed (viewing only).

---

## Lab 9: Security Hardening Checklist

**Goal:** Apply security best practices to a system

**Time:** 30-45 minutes

### Setup

A test VM or system you can modify.

### Steps

1. **Check and fix file permissions**
   ```bash
   # Critical files should be root-owned with restricted permissions
   sudo ls -la /etc/passwd /etc/shadow /etc/group /etc/sudoers
   
   # Fix if needed
   sudo chmod 644 /etc/passwd
   sudo chmod 000 /etc/shadow
   ```

2. **Verify SSH hardening**
   ```bash
   # Backup SSH config
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
   
   # Key hardening settings:
   sudo grep -E "^(Port|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)" /etc/ssh/sshd_config
   
   # Consider:
   # Port 22 (non-standard is security through obscurity, not real security)
   # PermitRootLogin no (good)
   # PasswordAuthentication no (requires SSH keys, more secure)
   # PubkeyAuthentication yes (use SSH keys)
   ```

3. **Check firewall status**
   ```bash
   sudo ufw status
   # Should be active
   
   # Check default policies
   sudo ufw status | grep "Default:"
   # Should be: Default: deny (incoming), allow (outgoing)
   ```

4. **Review sudo configuration**
   ```bash
   sudo visudo -c
   # Check syntax
   
   # Should have:
   # - Limited users with sudo access
   # - Specific commands per user
   # - Logging enabled
   ```

5. **Check unnecessary services**
   ```bash
   sudo systemctl list-units --type service --state running | wc -l
   # Count running services
   
   # Identify and disable unnecessary ones
   sudo systemctl list-unit-files --state enabled | grep -E "telnet|ftp|rsh"
   # Should be empty
   ```

6. **Verify SELinux/AppArmor**
   ```bash
   # On RHEL/CentOS:
   getenforce
   # Should be: Enforcing
   
   # On Ubuntu/Debian:
   sudo aa-status
   # Should show enforced profiles
   ```

7. **Check for weak user accounts**
   ```bash
   # Users with empty passwords
   sudo awk -F: '($2==""){print $1}' /etc/shadow
   # Should be empty
   
   # Users without login shell
   sudo grep nologin /etc/passwd
   # System users should have /nologin
   ```

8. **Enable system auditing**
   ```bash
   sudo systemctl enable auditd
   sudo systemctl status auditd
   ```

9. **Check failed login monitoring**
   ```bash
   # Install fail2ban (optional)
   sudo apt install fail2ban     # Debian/Ubuntu
   sudo yum install fail2ban     # RHEL/CentOS
   
   sudo systemctl enable fail2ban
   sudo systemctl status fail2ban
   ```

10. **Document security settings**
    ```bash
    # Create security checklist
    cat > security-audit.txt << 'EOF'
    SECURITY AUDIT CHECKLIST
    
    [ ] SSH key-only authentication enabled
    [ ] Root login disabled (SSH)
    [ ] Firewall active with default deny
    [ ] Sudo access limited to essential users
    [ ] SELinux/AppArmor enforcing
    [ ] Unnecessary services disabled
    [ ] File permissions correct (/etc/shadow = 000)
    [ ] Auditing enabled
    [ ] Fail2ban running
    [ ] Regular backups configured
    [ ] Security updates enabled
    [ ] SSH port configured (non-default)
    [ ] SSH timeout configured
    [ ] Strong passwords enforced (sudoers)
    [ ] User accounts audited
    EOF
    
    cat security-audit.txt
    ```

### Expected Output

```
$ sudo ufw status
Status: active

Default policy: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere

$ getenforce
Enforcing

$ sudo systemctl list-unit-files --type service --state enabled | wc -l
25
```

### Verification Checklist

- [ ] SSH hardened (keys preferred)
- [ ] Firewall active and configured
- [ ] SELinux/AppArmor enforcing
- [ ] Unnecessary services disabled
- [ ] Sudo access restricted
- [ ] File permissions correct
- [ ] Auditing enabled
- [ ] All checklist items addressed

### Cleanup

```bash
# Restore original SSH config if testing
sudo mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
sudo systemctl restart ssh
```

---

## Lab 10: Troubleshoot Permission Issues

**Goal:** Diagnose and fix permission-related problems

**Time:** 20 minutes

### Setup

Create a permission problem scenario.

### Steps

1. **Create problematic file**
   ```bash
   # Create as root with restrictive permissions
   sudo bash -c 'echo "secret data" > /tmp/secret.txt'
   sudo chmod 000 /tmp/secret.txt
   
   # Try to read as normal user
   cat /tmp/secret.txt
   # Error: Permission denied
   ```

2. **Diagnose the problem**
   ```bash
   # Check file details
   ls -la /tmp/secret.txt
   stat /tmp/secret.txt
   
   # Check your user
   id
   ```

3. **Fix: Change permissions**
   ```bash
   sudo chmod 644 /tmp/secret.txt
   cat /tmp/secret.txt
   # Now works!
   ```

4. **Create group permission problem**
   ```bash
   # Create group and user
   sudo groupadd teamA
   sudo usermod -aG teamA $USER
   # User needs to log out/in or use: newgrp teamA
   
   # Create group-owned file
   sudo bash -c 'echo "team data" > /tmp/team.txt'
   sudo chown :teamA /tmp/team.txt
   sudo chmod 640 /tmp/team.txt
   
   # Try to read (might fail if not in group)
   cat /tmp/team.txt
   ```

5. **Fix: Add to group**
   ```bash
   groups
   # Check if teamA is listed
   
   # If not, log out and back in
   # Or use: newgrp teamA
   
   cat /tmp/team.txt
   # Now works!
   ```

6. **Create directory permission problem**
   ```bash
   # Directory with no execute (can't enter)
   sudo mkdir /tmp/locked
   sudo chmod 600 /tmp/locked
   
   # Try to enter
   cd /tmp/locked
   # Error: Permission denied
   
   # Lists directory itself, not contents
   ls -la /tmp/locked
   # Error: Permission denied
   ```

7. **Fix: Add execute permission**
   ```bash
   sudo chmod 700 /tmp/locked
   # Now can enter and access files
   ls -la /tmp/locked
   # Works!
   ```

8. **Identify and fix SUID issues**
   ```bash
   # Find SUID programs
   sudo find /usr/bin -perm -4000 -type f | head -5
   
   # These run as owner regardless of who executes them
   # Example: passwd runs as root so users can change passwords
   ```

### Expected Output

```
$ ls -la /tmp/secret.txt
---------- 1 root root 12 Jan 15 10:30 /tmp/secret.txt

$ cat /tmp/secret.txt
cat: /tmp/secret.txt: Permission denied

# After chmod:
$ ls -la /tmp/secret.txt
-rw-r--r-- 1 root root 12 Jan 15 10:30 /tmp/secret.txt

$ cat /tmp/secret.txt
secret data
```

### Verification Checklist

- [ ] Identified permission problems
- [ ] Used stat and ls -l for diagnosis
- [ ] Fixed permission issues
- [ ] Understood permission bits
- [ ] Understood execute bit for directories

### Cleanup

```bash
sudo rm -f /tmp/secret.txt /tmp/team.txt
sudo rm -rf /tmp/locked
sudo groupdel teamA
```

---

## Summary Table of All Labs

| Lab | Goal | Key Skills | Time |
|-----|------|-----------|------|
| 1 | Audit file permissions | stat, chmod, find | 20 min |
| 2 | Configure ACLs | getfacl, setfacl, user access | 25 min |
| 3 | Setup sudo privileges | visudo, privilege escalation | 20 min |
| 4 | SSH key authentication | ssh-keygen, ssh-copy-id, agents | 25 min |
| 5 | Basic firewall rules | ufw, rules, policies | 20 min |
| 6 | Firewall for web server | ufw profiles, service access | 30 min |
| 7 | SELinux operations | getenforce, chcon, contexts | 25 min |
| 8 | Monitor security events | logs, journalctl, audit | 20 min |
| 9 | Security hardening | best practices checklist | 30-45 min |
| 10 | Troubleshoot permissions | diagnosis, fixing issues | 20 min |

**Total time:** 3-3.5 hours (with all labs)
