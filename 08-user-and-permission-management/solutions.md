# User and Permission Management: Solutions

## Exercise 1: Create and Manage Users

**Solution:**

```bash
# Create new user with home directory
sudo useradd -m -s /bin/bash newuser

# Verify creation
cat /etc/passwd | grep newuser
# Output: newuser:x:1001:1001::/home/newuser:/bin/bash

# Show UID/GID
id newuser
# Output:
# uid=1001(newuser) gid=1001(newuser) groups=1001(newuser)

# List all users (extract username)
cat /etc/passwd | cut -d: -f1
# Shows all usernames

# View detailed user info
getent passwd newuser
# Output: newuser:x:1001:1001::/home/newuser:/bin/bash

# Another method - all users
awk -F: '{print $1, "UID:", $3, "GID:", $4}' /etc/passwd
```

**Explanation:** `/etc/passwd` stores user info. `useradd -m` creates home directory.

---

## Exercise 2: Manage User Groups

**Solution:**

```bash
# Create new group
sudo groupadd developers

# Add user to group (existing user)
sudo usermod -aG developers newuser

# Create group with specific GID
sudo groupadd -g 2000 admins

# List all groups
cat /etc/group | cut -d: -f1
# Output: root, daemon, ..., developers, admins

# Show group membership
groups newuser
# Output: newuser : newuser developers

# Show group details
cat /etc/group | grep developers
# Output: developers:x:1001:newuser

# All groups (detailed)
getent group
```

**Explanation:** `-aG` = append to groups (don't replace). GID must be unique.

---

## Exercise 3: Understanding File Permissions

**Solution:**

```bash
# Create test file
touch testfile.txt

# List with permissions
ls -l testfile.txt
# Output: -rw-r--r-- 1 user group 0 Jan 20 10:30 testfile.txt

# Break down: -rw-r--r--
# -       = regular file (d=dir, l=link)
# rw-     = owner (r=4, w=2, x=1 = 6)
# r--     = group (r=4, -=0, -=0 = 4)
# r--     = others (r=4, -=0, -=0 = 4)
# So: 644

# View in octal format
stat -c '%A %a %n' testfile.txt
# Output: -rw-r--r-- 644 testfile.txt

# Directory example
mkdir testdir
ls -ld testdir
# Output: drwxr-xr-x (755)

# Permission meanings:
# r (read) = 4
# w (write) = 2
# x (execute/traverse) = 1
# Total: 7 (all), 5 (r+x), 0 (none)
```

**Explanation:** Three permission sets: owner, group, others. Each: read(4) + write(2) + execute(1).

---

## Exercise 4: Change File Permissions (chmod)

**Solution:**

```bash
# Create test file
echo "test" > file.txt
ls -l file.txt
# Output: -rw-r--r-- 644 file.txt

# Make executable for owner (octal)
chmod 755 file.txt
# Output: -rwxr-xr-x 755

# Symbolic: add execute for user
chmod u+x file.txt
# Same result as above

# Make read-only for everyone
chmod 444 file.txt
# Output: -r--r--r-- 444

# Remove write from group (symbolic)
chmod g-w file.txt

# Add write back to owner
chmod u+w file.txt

# Remove read from others
chmod o-r file.txt
# Output: -rw-r----- 640

# Recursive on directory
mkdir -p dir1/dir2
chmod -R 755 dir1

# Common permissions:
# 777 = rwxrwxrwx (everyone full access)
# 755 = rwxr-xr-x (owner full, others read+execute)
# 644 = rw-r--r-- (owner write, others read only)
# 600 = rw------- (owner only)
```

**Explanation:** Octal = easy for bulk changes. Symbolic = explicit (u=user, g=group, o=others).

---

## Exercise 5: Change File Ownership (chown)

**Solution:**

```bash
# Create test file
touch myfile.txt

# Change owner (requires sudo)
sudo chown newuser myfile.txt
ls -l myfile.txt
# Output: -rw-r--r-- 1 newuser oldgroup 0 Jan 20

# Change owner and group
sudo chown newuser:developers myfile.txt
# Output: -rw-r--r-- 1 newuser developers 0 Jan 20

# Change group only
sudo chgrp developers myfile.txt

# Change for directory recursively
mkdir -p project/src
sudo chown -R newuser:developers project
# All files and subdirs updated

# Verify changes
ls -lR project
# Shows new ownership

# Change back to original
sudo chown originaluser:originalgroup myfile.txt
```

**Explanation:** `chown owner:group` changes both. `-R` applies recursively to all contents.

---

## Exercise 6: Configure Sudo Access

**Solution:**

```bash
# Create test user
sudo useradd -m -s /bin/bash devops

# Add to sudo group (enables sudo)
sudo usermod -aG sudo devops

# User logs out and back in for group to apply
# Or: su - devops

# Test sudo access
sudo -l
# Output: (ALL) ALL (if allowed)

# Show sudoers file (NEVER edit manually!)
sudo visudo
# Add line: devops ALL=(ALL) ALL

# For no-password sudo (security risk)
sudo visudo
# Add: devops ALL=(ALL) NOPASSWD: ALL

# Test sudo works
sudo whoami
# Output: root

# Show sudo history/logs
sudo journalctl SYSLOG_IDENTIFIER=sudo

# Grant specific command only
# In visudo, add: devops ALL=(ALL) /usr/bin/systemctl

# Verify privilege
sudo -l
```

**Explanation:** `sudo` group = sudoers. `visudo` = safe edit. NOPASSWD = risky but convenient.

---

## Exercise 7: Special Permissions

**Solution:**

```bash
# Create test file
touch setuid_test
chmod 755 setuid_test

# Show normal permissions
ls -l setuid_test
# Output: -rwxr-xr-x 755

# Set setuid (4xxx)
chmod 4755 setuid_test
ls -l setuid_test
# Output: -rwsr-xr-x 4755
# Note: 's' instead of 'x' for user

# Set setgid (2xxx)
mkdir setgid_test
chmod 2755 setgid_test
ls -ld setgid_test
# Output: drwxr-sr-x 2755

# Set sticky bit (1xxx)
mkdir shared
chmod 1777 shared
ls -ld shared
# Output: drwxrwxrwt 1777
# Note: 't' at end

# Find files with setuid
find / -perm -4000 2>/dev/null | head -5
# Examples: /usr/bin/sudo, /usr/bin/passwd

# Find with setgid
find / -perm -2000 2>/dev/null | head -5

# Verify special bits
stat -c '%A %a %n' setuid_test
# Output: -rwsr-xr-x 4755
```

**Explanation:** setuid=4, setgid=2, sticky=1. Shown as s/t in ls output.

---

## Exercise 8: Directory Permissions

**Solution:**

```bash
# Create project structure
mkdir -p project/{src,docs,tests}
ls -lR project

# Set directory permissions
# r = list contents
# w = create/delete files
# x = enter directory

chmod 755 project
chmod 755 project/src

# Directory without execute can't traverse
mkdir no_enter
chmod 644 no_enter
cd no_enter  # Error: Permission denied

# Sticky bit on shared directory
mkdir /tmp/shared
chmod 1777 /tmp/shared
ls -ld /tmp/shared
# Output: drwxrwxrwt (sticky)

# Test: only owner can delete (sticky bit)
# User A creates file in shared
# User B cannot delete it (not owner)

# Group write with setgid
mkdir team_project
chown :developers team_project
chmod 2775 team_project
# All files created inherit group

# Verify file inheritance
touch team_project/file.txt
ls -l team_project/file.txt
# Output: user:developers (inherited!)
```

**Explanation:** Execute on dir = traverse. Sticky bit = prevent deletion by non-owners.

---

## Exercise 9: Umask and Default Permissions

**Solution:**

```bash
# Check current umask
umask
# Output: 0022 (octal)

# Understand calculation
# Default file: 666 - 022 = 644
# Default dir:  777 - 022 = 755

# Create file with default umask
touch default_file.txt
ls -l default_file.txt
# Output: -rw-r--r-- 644

# Create directory with default umask
mkdir default_dir
ls -ld default_dir
# Output: drwxr-xr-x 755

# Change umask temporarily
umask 0077
# 666 - 077 = 589 (files)
# 777 - 077 = 700 (dirs)

# Create file with new umask
touch restrictive_file.txt
ls -l restrictive_file.txt
# Output: -rw------- 600 (user only!)

# Create directory
mkdir restrictive_dir
ls -ld restrictive_dir
# Output: drwx------ 700

# Reset umask (umask reverts on shell exit)
umask 0022

# Make umask permanent (add to ~/.bashrc)
echo "umask 0022" >> ~/.bashrc

# Verify
touch another_file.txt
ls -l another_file.txt
# Output: -rw-r--r-- 644
```

**Explanation:** Umask = bits to remove. 022 = remove w for group/others.

---

## Exercise 10: Security and Best Practices

**Solution:**

```bash
# Create team structure
sudo groupadd development
sudo groupadd qa

# Create users
sudo useradd -m -G development dev1
sudo useradd -m -G development dev2
sudo useradd -m -G qa qa1

# Create project directory
mkdir -p /opt/project/{src,tests,docs}
sudo chown -R dev1:development /opt/project

# Set permissions
sudo chmod 2775 /opt/project
sudo chmod 2775 /opt/project/src
sudo chmod 2775 /opt/project/tests
sudo chmod 2775 /opt/project/docs

# Sticky bit on shared areas
sudo chmod 3775 /opt/project/tests

# Test collaboration
# Dev1 creates file
touch /opt/project/src/code.py
ls -l /opt/project/src/code.py
# Output: user:development (inherited!)

# Dev2 can edit (group write)
echo "test" >> /opt/project/src/code.py  # Works!

# QA cannot write (different group)
# qa1 cannot edit (permission denied)

# Verify security model
cat > security_report.txt << 'EOF'
=== Project Security Report ===

User Structure:
- Developers: dev1, dev2 (group: development)
- QA: qa1 (group: qa)

Directory Permissions:
- /opt/project: 2775 (setgid, developers collaborate)
- src/tests/docs: 2775 (inherit group)

File Creation Policy:
- All files inherit development group (setgid)
- Developers can edit each other's files
- QA has read-only access

Access Control:
- dev1, dev2: full access
- qa1: read-only
EOF

cat security_report.txt
```

**Explanation:** Setgid on directory = files inherit group. Combined with group permissions = team collaboration.
