# Module 08: User and Permission Management - Commands Cheatsheet

Quick reference for 25+ essential user and permission management commands.

---

## Part A: User Information

### whoami

Show current user.

```bash
whoami
# Returns: alice

# Useful in scripts
if [ "$(whoami)" = "root" ]; then
  echo "Running as root"
fi
```

### id

Show user/group information.

```bash
# Current user
id
# Returns: uid=1000(alice) gid=1000(alice) groups=1000(alice),27(sudo)

# Specific user
id alice

# Get specific field
id -u alice      # Just UID (1000)
id -g alice      # Just primary GID (1000)
id -G alice      # All GIDs (1000 27)
id -n -u alice   # Username instead of UID
```

### w and who

Show logged-in users.

```bash
# All users currently logged in
w
# Shows user, terminal, login time, idle time, command

who
# Simpler version, less detail

# Show only usernames
w | awk '{print $1}' | sort -u
```

### last

Show login history.

```bash
# Recent logins
last

# Specific user
last alice

# Last 5 logins
last -5

# Show still-logged-in users
lastlog | head -5
```

---

## Part B: User Management

### useradd / adduser

Create new user account.

```bash
# Basic user creation
sudo useradd newuser

# With home directory and shell
sudo useradd -m -s /bin/bash newuser

# With specific UID
sudo useradd -u 2000 -m newuser

# With comment/description
sudo useradd -c "John Doe" -m newuser

# Create system user (UID < 1000)
sudo useradd -r -s /usr/sbin/nologin serviceuser

# Options summary
-m           Create home directory
-s SHELL     Set login shell
-u UID       Set specific UID
-g GID       Set primary group
-G GROUPS    Add to secondary groups
-c COMMENT   Full name/comment
-r           Create system user
-d HOME      Specify home directory
```

### usermod

Modify user account.

```bash
# Add user to group (secondary)
sudo usermod -a -G sudo alice
# -a = append (don't remove existing groups)

# Change primary group
sudo usermod -g developers alice

# Change home directory
sudo usermod -d /home/newhome alice

# Change login shell
sudo usermod -s /bin/zsh alice

# Lock user account
sudo usermod -L alice

# Unlock user account
sudo usermod -U alice

# Set comment
sudo usermod -c "Alice Developer" alice

# Common workflow (add to sudo)
sudo usermod -a -G sudo username
```

### userdel

Delete user account.

```bash
# Delete user (keep home directory)
sudo userdel alice

# Delete user and home directory
sudo userdel -r alice

# Remove from all groups
# (automatic when user deleted)
```

### passwd

Manage user passwords.

```bash
# Change own password
passwd
# Prompts for old password, then new

# Change another user's password (as root)
sudo passwd alice

# Set password for new user
sudo passwd newuser

# Lock account
sudo passwd -l alice

# Unlock account
sudo passwd -u alice

# Expire password (force change on next login)
sudo passwd -e alice

# Show password status
sudo passwd -S alice
```

---

## Part C: Group Management

### groupadd

Create new group.

```bash
# Basic group creation
sudo groupadd developers

# With specific GID
sudo groupadd -g 2000 developers

# System group (GID < 1000)
sudo groupadd -r systemgroup

# Create and use
sudo groupadd project-team
sudo usermod -a -G project-team alice
```

### groupmod

Modify group.

```bash
# Change group name
sudo groupmod -n newname oldname

# Change GID
sudo groupmod -g 2001 developers

# Add user to group (via usermod, not groupmod)
sudo usermod -a -G developers alice
```

### groupdel

Delete group.

```bash
# Delete group
sudo groupdel developers

# Cannot delete user's primary group
sudo groupdel alice    # Error if alice's primary group

# Must reassign users first
sudo usermod -g other alice
sudo groupdel alice
```

### gpasswd

Manage group membership (alternative).

```bash
# Add user to group
sudo gpasswd -a alice developers

# Remove user from group
sudo gpasswd -d alice developers

# Set group password (rarely used)
sudo gpasswd developers

# Make user group admin
sudo gpasswd -A alice developers
```

---

## Part D: File Permissions

### chmod

Change file permissions.

```bash
# Numeric notation
chmod 644 file.txt       # rw-r--r--
chmod 755 script.sh      # rwxr-xr-x
chmod 600 secret.key     # rw-------

# Recursive (directory and contents)
chmod -R 755 /home/app

# Symbolic notation
chmod u+x file           # Add execute for owner
chmod g-w file           # Remove write from group
chmod o-r file           # Remove read from others
chmod a=r file           # Everyone read only

# Combining
chmod u+rwx,g+rx,o-rwx file

# With setuid/setgid/sticky
chmod 4755 suid_file     # setuid + rwxr-xr-x
chmod 2755 setgid_file   # setgid + rwxr-xr-x
chmod 1777 sticky_dir    # sticky + rwxrwxrwx
chmod u+s file           # Add setuid
chmod g+s file           # Add setgid
chmod +t dir             # Add sticky bit
```

### chown

Change file owner.

```bash
# Change owner only
chown alice file.txt

# Change owner and group
chown alice:developers file.txt

# Recursive
chown -R alice:developers /home/app

# Change only group (alternative to chgrp)
chown :developers file.txt

# Keep existing permissions with -P
chown -P alice:developers file.txt
```

### chgrp

Change file group.

```bash
# Change group
chgrp developers file.txt

# Recursive
chgrp -R developers /shared/project

# Follow symlinks
chgrp -L developers /path
```

---

## Part E: Permission Viewing

### ls -l

List files with permissions.

```bash
ls -la

# Output:
# -rw-r--r-- 1 alice developers 1024 date file.txt
# │└────┬────┘   │     │         └─ Group
# │     └─ Others│     └─ Owner
# └─ Owner       └─ User

# Just directories
ls -ld /home/alice

# Numeric permissions
stat file.txt | grep Access
# Shows in both symbolic and numeric format

# Recursive
ls -laR /home
```

### stat

Show detailed file information.

```bash
# All details
stat file.txt

# Just permissions
stat -c "%a %A %n" file.txt
# Output: 644 -rw-r--r-- file.txt

# Numeric permission only
stat -c "%a" file.txt    # Returns: 644
```

### getfacl

Show ACL (if using extended ACLs).

```bash
# Show file ACLs
getfacl file.txt

# For directory
getfacl -d /directory
```

---

## Part F: Security and Auditing

### find

Find files with specific permissions.

```bash
# Find world-writable files (security risk)
find / -type f -perm -002 2>/dev/null

# Find setuid files
find / -type f -perm -4000 2>/dev/null

# Find setgid files
find / -type f -perm -2000 2>/dev/null

# Find files without execute in group/other
find / -type f -perm -004 -prune

# Find by owner
find / -owner alice -type f
```

### grep (with permission files)

Search passwd/group files.

```bash
# Find user in passwd
grep alice /etc/passwd

# Find group in group file
grep developers /etc/group

# Get user's UID
grep alice /etc/passwd | cut -d: -f3

# Get group's GID
grep developers /etc/group | cut -d: -f3

# Find all users with nologin shell
grep nologin /etc/passwd
```

### sudo

Execute as root/another user.

```bash
# Run command as root
sudo command

# List allowed commands
sudo -l

# Edit sudoers (safe method)
sudo visudo

# Run as specific user
sudo -u otheruser command

# Keep environment
sudo -E command

# No password prompt (if configured)
sudo -n command
```

---

## Part G: Permission Patterns

### Common Permission Sets

```bash
# Regular file, user edits
chmod 644 file.txt    # -rw-r--r--

# Executable script
chmod 755 script.sh   # -rwxr-xr-x

# Sensitive file
chmod 600 secret.key  # -rw-------

# Shared folder
chmod 2770 /shared    # drwxrws--- (setgid)

# Public folder
chmod 755 /public     # drwxr-xr-x

# Temp directory
chmod 1777 /tmp       # drwxrwxrwt (sticky)

# Private home
chmod 700 /home/user  # drwx------

# Shared home for team
chmod 750 /home/user  # drwxr-x---
```

### Fixing Permission Issues

```bash
# Find and fix world-writable files
find / -type f -perm -002 -exec chmod o-w {} \;

# Fix all home directories to 700
find /home -maxdepth 1 -type d -exec chmod 700 {} \;

# Fix all files to 644, directories to 755
find /path -type f -exec chmod 644 {} \;
find /path -type d -exec chmod 755 {} \;

# Remove setuid from user files
find /home -type f -perm -4000 -exec chmod u-s {} \;
```

---

## Part H: Sudo Configuration

### sudoers File Examples

```bash
# Basic: user can run anything
alice ALL=(ALL) ALL

# Group: all members can run anything
%sudo ALL=(ALL) ALL

# Specific command: only this command
alice ALL=(ALL) /usr/bin/systemctl

# Multiple commands
alice ALL=(ALL) /usr/bin/systemctl, /usr/bin/nginx

# No password required
alice ALL=(ALL) NOPASSWD: /usr/bin/systemctl

# Password-less for specific command only
alice ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx

# Run as specific user
alice ALL=(ALL) /usr/sbin/useradd

# All hosts (for distributed systems)
alice ALL=(ALL) ALL

# Specific host only
alice HOSTNAME=(ALL) ALL
```

### visudo Usage

```bash
# Edit sudoers safely (validates syntax)
sudo visudo

# Use specific editor
sudo EDITOR=nano visudo

# Check sudoers syntax
sudo visudo -c

# Show effective sudoers for user
sudo -l

# Show detailed sudoers
sudo -l -l
```

---

## Part I: Viewing System Configuration

### /etc Files

```bash
# View all users
cat /etc/passwd

# Format: username:x:UID:GID:name:home:shell

# View all groups
cat /etc/group

# Format: groupname:x:GID:members

# View group membership
getent group groupname

# View all users in a group
getent group developers | cut -d: -f4
```

### Shadow Files

```bash
# Password aging info (requires root)
sudo cat /etc/shadow

# Format: username:password_hash:days_modified:...

# Password status
sudo passwd -S alice
# Shows: lock/password status and aging info
```

---

## Part J: User Session Management

### who and w

```bash
# Who is logged in
who

# Detailed info
w

# Just usernames
w | awk '{print $1}' | sort -u

# User statistics
lastlog | head -10

# Sessions per user
w | tail -n +3 | awk '{print $1}' | sort | uniq -c
```

### Logging Out/Session Control

```bash
# Force user logout (if they're causing problems)
# Find their session
who

# Kill their session
sudo pkill -u alice

# Or via w
w | grep alice
```

---

## Part K: Quick Reference Table

| Task | Command |
|------|---------|
| Show current user | whoami |
| Show user/group info | id alice |
| List logged-in users | w |
| Show login history | last |
| Create user | sudo useradd -m alice |
| Modify user | sudo usermod -G sudo alice |
| Delete user | sudo userdel -r alice |
| Change password | passwd |
| Create group | sudo groupadd developers |
| Delete group | sudo groupdel developers |
| Change permissions (numeric) | chmod 755 file |
| Change permissions (symbolic) | chmod u+x file |
| Change owner | sudo chown alice file |
| Change group | sudo chgrp developers file |
| Find world-writable files | find / -perm -002 |
| Find setuid files | find / -perm -4000 |
| List sudoers | sudo -l |
| Edit sudoers | sudo visudo |
| Check permissions | ls -la file |
| Show full details | stat file |
| Find user files | find / -user alice |
| Find group files | find / -group developers |
| Add to sudo group | sudo usermod -a -G sudo alice |
| Change shell | sudo usermod -s /bin/zsh alice |
| Lock account | sudo passwd -l alice |
| Unlock account | sudo passwd -u alice |

---

## Part L: Tips and Best Practices

### Best Practices

1. **Use useradd with -m** - Always create home directory
   ```bash
   sudo useradd -m -s /bin/bash newuser    # Good
   sudo useradd newuser                    # Bad - no home
   ```

2. **Use -a with usermod -G** - Don't remove existing groups
   ```bash
   sudo usermod -a -G sudo alice           # Good - add to sudo
   sudo usermod -G sudo alice              # Bad - removes other groups!
   ```

3. **Prefer visudo for sudoers** - Validates syntax
   ```bash
   sudo visudo                             # Good
   sudo nano /etc/sudoers                  # Bad - can break system
   ```

4. **Check permissions before changing** - Verify current state
   ```bash
   ls -la file
   # Then change only what's needed
   ```

5. **Use umask for defaults** - Set in shell profile
   ```bash
   umask 0027        # Restrictive (640/750)
   # In ~/.bashrc for persistence
   ```

6. **Regular permission audits** - Find problems
   ```bash
   find / -type f -perm -002     # World-writable files
   find / -type f -perm -4000    # setuid files
   ```

### Common Mistakes

1. **Using chmod 777** - Way too permissive
   ```bash
   # Wrong
   chmod 777 file.txt
   
   # Right
   chmod 755 file.txt    # Or appropriate value
   ```

2. **Forgetting sudo** - Can't modify without elevation
   ```bash
   # Wrong
   useradd newuser
   
   # Right
   sudo useradd -m newuser
   ```

3. **Not using -a with usermod -G** - Removes groups
   ```bash
   # Wrong
   sudo usermod -G sudo alice    # Removes other groups!
   
   # Right
   sudo usermod -a -G sudo alice
   ```

4. **Editing /etc/sudoers directly** - Can break sudo
   ```bash
   # Wrong
   sudo nano /etc/sudoers
   
   # Right
   sudo visudo
   ```

---

**Ready for hands-on practice?** Continue to [03-hands-on-labs.md](03-hands-on-labs.md)
