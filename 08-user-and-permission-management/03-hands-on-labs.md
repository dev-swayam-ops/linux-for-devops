# Module 08: User and Permission Management - Hands-On Labs

9 practical labs covering user creation, group management, permissions, and security.

**Total Lab Time**: 220 minutes (3.7 hours)

---

## Lab 1: Understanding User and Group Information

**Difficulty**: Beginner | **Time**: 20 minutes

### Goal
Learn to view and interpret user and group information on the system.

### Setup

```bash
# No special setup needed - examine existing users/groups
```

### Steps

1. **View current user**
   ```bash
   whoami
   # Returns: your username
   ```

2. **Get detailed user information**
   ```bash
   id
   # Returns: uid=1000(username) gid=1000(username) groups=1000(username),27(sudo)
   ```

3. **View all system users**
   ```bash
   cat /etc/passwd | head -10
   # Shows: root, daemon, bin, sys, sync, games, man, lp, mail, news
   ```

4. **Parse passwd file format**
   ```bash
   head -2 /etc/passwd
   
   # Format explained:
   grep "^root:" /etc/passwd | cut -d: -f1-7
   # root:x:0:0:root:/root:/bin/bash
   # └─ username:password:UID:GID:name:home:shell
   ```

5. **View all groups**
   ```bash
   cat /etc/group | head -10
   ```

6. **Find your primary group**
   ```bash
   id -gn
   # Returns: your_username (usually same as username)
   ```

7. **Check logged-in users**
   ```bash
   w
   # Shows: user, terminal, login time, idle, current command
   ```

8. **View login history**
   ```bash
   last | head -10
   # Shows: username, terminal, host, login time, logout time, duration
   ```

### Expected Output

```
$ whoami
alice

$ id
uid=1000(alice) gid=1000(alice) groups=1000(alice),27(sudo),4(adm)

$ cat /etc/passwd | grep ^alice
alice:x:1000:1000:Alice User:/home/alice:/bin/bash

$ w
 10:30:42 up 5:12,  1 user,  load average: 0.05, 0.03, 0.01
USER     TTY      FROM   LOGIN@   IDLE  JCPU  PCPU WHAT
alice    pts/0    localhost 10:15 15:32 0.3s 0.1s bash
```

### Verification Checklist

- [ ] Can view current user with whoami
- [ ] Can interpret id output (UID, GID, groups)
- [ ] Can view /etc/passwd and understand format
- [ ] Can find own user entry in passwd
- [ ] Can view groups
- [ ] Can see logged-in users with w
- [ ] Can view login history with last

### Cleanup

```bash
# No cleanup needed - only viewed system info
```

---

## Lab 2: Understanding File Permissions

**Difficulty**: Beginner | **Time**: 20 minutes

### Goal
Learn to read, interpret, and understand file permissions.

### Setup

```bash
# Create test files
mkdir -p /tmp/perm-test
cd /tmp/perm-test

# Create various files
touch file1.txt
mkdir directory1
echo "#!/bin/bash" > script.sh
```

### Steps

1. **View file permissions**
   ```bash
   ls -la /tmp/perm-test/
   
   # Output:
   # -rw-r--r-- 1 alice alice 0 date file1.txt
   # drwxr-xr-x 2 alice alice 4096 date directory1
   # -rw-r--r-- 1 alice alice 13 date script.sh
   ```

2. **Interpret permission string**
   ```bash
   # -rw-r--r--
   # ^          file type (- = regular file, d = directory)
   #  ^^        owner permissions (rw-)
   #    ^^      group permissions (r--)
   #       ^^   other permissions (r--)
   
   # Numeric equivalent: 644
   # 6 (owner: rw-) + 4 (group: r--) + 4 (other: r--)
   ```

3. **Check numeric permissions**
   ```bash
   stat -c "%a %A %n" /tmp/perm-test/*
   
   # Output:
   # 644 -rw-r--r-- file1.txt
   # 755 drwxr-xr-x directory1
   # 644 -rw-r--r-- script.sh
   ```

4. **Identify permission differences**
   ```bash
   ls -la /tmp/perm-test/
   
   # Notice:
   # - File permissions: 644 (rw-r--r--)
   # - Directory permissions: 755 (rwxr-xr-x)
   # Why? Directories need execute bit to enter
   ```

5. **View special permissions**
   ```bash
   # Check for setuid/setgid files
   ls -la /usr/bin/passwd
   # -rwsr-xr-x   (note 's' instead of 'x' in owner)
   # This is setuid - runs as owner (root)
   ```

6. **Compare different permissions**
   ```bash
   # Create files with different perms
   touch restrictive.txt
   touch public.txt
   
   stat -c "%a %n" restrictive.txt public.txt
   ```

7. **Understand directory permissions**
   ```bash
   mkdir testdir
   # drwxr-xr-x (755)
   
   # r = can list contents
   # w = can create/delete files inside
   # x = can enter directory (cd into it)
   ```

8. **Check default permissions (umask)**
   ```bash
   umask
   # Returns: 0022
   
   # This means:
   # Files: 666 - 022 = 644 (rw-r--r--)
   # Dirs: 777 - 022 = 755 (rwxr-xr-x)
   ```

### Expected Output

```
$ ls -la /tmp/perm-test/
total 12
drwxr-xr-x 3 alice alice 4096 Jan 15 10:30 .
drwxrwxrwt 14 root root 4096 Jan 15 10:30 ..
-rw-r--r-- 1 alice alice 0 Jan 15 10:30 file1.txt
drwxr-xr-x 2 alice alice 4096 Jan 15 10:30 directory1
-rw-r--r-- 1 alice alice 13 Jan 15 10:30 script.sh

$ stat -c "%a %A %n" /tmp/perm-test/*
644 -rw-r--r-- file1.txt
755 drwxr-xr-x directory1
644 -rw-r--r-- script.sh
```

### Verification Checklist

- [ ] Can interpret permission strings (rwx notation)
- [ ] Can convert between symbolic and numeric
- [ ] Can identify file type (-, d, l, etc.)
- [ ] Can separate owner/group/other permissions
- [ ] Can use stat command
- [ ] Understand why directories have execute bit
- [ ] Know default permissions (umask impact)

### Cleanup

```bash
rm -rf /tmp/perm-test
```

---

## Lab 3: Changing Permissions with chmod

**Difficulty**: Beginner | **Time**: 25 minutes

### Goal
Practice changing file permissions using numeric and symbolic notation.

### Setup

```bash
mkdir -p /tmp/chmod-test
cd /tmp/chmod-test

# Create test files
touch file.txt
mkdir directory
echo "#!/bin/bash" > script.sh
```

### Steps

1. **Check initial permissions**
   ```bash
   ls -la
   # All files start at 644/-rw-r--r--
   ```

2. **Change to read-only (numeric)**
   ```bash
   chmod 444 file.txt
   ls -la file.txt
   # -r--r--r-- 1 alice alice 0 date file.txt
   ```

3. **Make owner only (numeric)**
   ```bash
   chmod 600 file.txt
   ls -la file.txt
   # -rw------- 1 alice alice 0 date file.txt
   ```

4. **Make executable (numeric)**
   ```bash
   chmod 755 script.sh
   ls -la script.sh
   # -rwxr-xr-x 1 alice alice 13 date script.sh
   
   # Can now execute it
   ./script.sh    # Would run (if valid script)
   ```

5. **Use symbolic notation - add permission**
   ```bash
   chmod 644 file.txt
   chmod u+x file.txt     # Add execute for owner
   ls -la file.txt
   # -rwxr--r-- 1 alice alice 0 date file.txt
   ```

6. **Use symbolic notation - remove permission**
   ```bash
   chmod g-r file.txt     # Remove read from group
   chmod o-r file.txt     # Remove read from other
   ls -la file.txt
   # -rwx------ 1 alice alice 0 date file.txt
   ```

7. **Set exact permissions (symbolic)**
   ```bash
   chmod a=r file.txt     # Everyone read only
   ls -la file.txt
   # -r--r--r-- 1 alice alice 0 date file.txt
   
   chmod a+x file.txt     # Add execute for all
   ls -la file.txt
   # -r-xr-xr-x 1 alice alice 0 date file.txt
   ```

8. **Change directory permissions**
   ```bash
   chmod 755 directory
   ls -ld directory
   # drwxr-xr-x 2 alice alice 4096 date directory
   ```

9. **Recursive permission change**
   ```bash
   # Create nested structure
   mkdir -p structure/level1/level2
   ls -R structure
   
   # Change all recursively
   chmod -R 755 structure
   ls -R structure
   # All directories now 755
   ```

### Expected Output

```
$ chmod 755 script.sh
$ ls -la script.sh
-rwxr-xr-x 1 alice alice 13 Jan 15 10:40 script.sh

$ chmod u+x file.txt
$ ls -la file.txt
-rwxr--r-- 1 alice alice 0 Jan 15 10:41 file.txt

$ chmod a=r file.txt
$ ls -la file.txt
-r--r--r-- 1 alice alice 0 Jan 15 10:42 file.txt
```

### Verification Checklist

- [ ] Can use chmod with numeric notation
- [ ] Can use chmod with symbolic notation
- [ ] Can add/remove/set permissions
- [ ] Can apply to owner/group/other
- [ ] Can change directories
- [ ] Can use recursive -R flag
- [ ] Can verify changes with ls -la

### Cleanup

```bash
rm -rf /tmp/chmod-test
```

---

## Lab 4: Ownership with chown and chgrp

**Difficulty**: Intermediate | **Time**: 25 minutes

### Goal
Learn to change file ownership and group membership.

### Setup

```bash
mkdir -p /tmp/chown-test
cd /tmp/chown-test

# Create test files
touch testfile.txt

# Create test group (requires sudo)
sudo groupadd testgroup
```

### Steps

1. **View current ownership**
   ```bash
   ls -la testfile.txt
   # -rw-r--r-- 1 alice alice 0 date testfile.txt
   # Owner: alice, Group: alice
   ```

2. **Change owner (requires sudo)**
   ```bash
   sudo chown root testfile.txt
   ls -la testfile.txt
   # -rw-r--r-- 1 root alice 0 date testfile.txt
   # Owner now: root
   ```

3. **Change back to user**
   ```bash
   sudo chown alice testfile.txt
   ls -la testfile.txt
   # -rw-r--r-- 1 alice alice 0 date testfile.txt
   ```

4. **Change group (requires sudo)**
   ```bash
   sudo chgrp testgroup testfile.txt
   ls -la testfile.txt
   # -rw-r--r-- 1 alice testgroup 0 date testfile.txt
   # Group now: testgroup
   ```

5. **Change both owner and group together**
   ```bash
   sudo chown root:testgroup testfile.txt
   ls -la testfile.txt
   # -rw-r--r-- 1 root testgroup 0 date testfile.txt
   ```

6. **Change back using colon notation**
   ```bash
   sudo chown alice:alice testfile.txt
   ls -la testfile.txt
   ```

7. **Create directory for recursive test**
   ```bash
   mkdir -p mydir/level1
   touch mydir/file1.txt
   touch mydir/level1/file2.txt
   
   ls -laR mydir
   ```

8. **Change ownership recursively**
   ```bash
   sudo chown -R root:testgroup mydir
   ls -laR mydir
   # All files and directories: owner=root, group=testgroup
   ```

9. **Change back**
   ```bash
   sudo chown -R alice:alice mydir
   ls -laR mydir
   ```

### Expected Output

```
$ ls -la testfile.txt
-rw-r--r-- 1 alice alice 0 Jan 15 11:00 testfile.txt

$ sudo chown root:testgroup testfile.txt

$ ls -la testfile.txt
-rw-r--r-- 1 root testgroup 0 Jan 15 11:01 testfile.txt

$ sudo chown -R alice:alice mydir
$ ls -laR mydir
mydir:
drwxr-xr-x 3 alice alice 4096 Jan 15 11:02 .
drwxrwxrwt 14 root root 4096 Jan 15 11:02 ..
-rw-r--r-- 1 alice alice 0 Jan 15 11:02 file1.txt
drwxr-xr-x 2 alice alice 4096 Jan 15 11:02 level1
```

### Verification Checklist

- [ ] Can view ownership with ls -la
- [ ] Can change owner with chown
- [ ] Can change group with chgrp
- [ ] Can change both with chown user:group
- [ ] Can use recursive -R flag
- [ ] Understand colon notation
- [ ] Verify ownership changes

### Cleanup

```bash
rm -rf /tmp/chown-test
sudo groupdel testgroup
```

---

## Lab 5: Create and Manage Users

**Difficulty**: Intermediate | **Time**: 30 minutes

### Goal
Create user accounts and learn user management.

### Setup

```bash
# Nothing needed to start
```

### Steps

1. **Create a new user**
   ```bash
   sudo useradd testuser
   
   # Verify creation
   id testuser
   # uid=1001(testuser) gid=1001(testuser) groups=1001(testuser)
   ```

2. **Check user was added to passwd**
   ```bash
   grep testuser /etc/passwd
   # testuser:x:1001:1001::/home/testuser:/bin/sh
   ```

3. **Create user with home directory**
   ```bash
   sudo userdel testuser      # Remove previous
   
   sudo useradd -m -s /bin/bash testuser2
   
   # Verify home directory exists
   ls -la /home/testuser2
   ```

4. **Create user with specific UID**
   ```bash
   sudo useradd -u 2000 -m -s /bin/bash testuser3
   
   id testuser3
   # uid=2000(testuser3) gid=2000(testuser3) groups=2000(testuser3)
   ```

5. **Add comment to user**
   ```bash
   sudo useradd -c "Test User Account" -m testuser4
   
   grep testuser4 /etc/passwd
   # testuser4:x:1004:1004:Test User Account:/home/testuser4:/bin/sh
   ```

6. **Set password for user**
   ```bash
   sudo passwd testuser2
   # Enter password when prompted
   
   # Verify password set
   sudo passwd -S testuser2
   # Shows: testuser2 P date 0 99999 7 -1 (P = password set)
   ```

7. **Modify user (add to group)**
   ```bash
   # First create a group
   sudo groupadd testgroup2
   
   # Add user to group (append, don't remove other groups)
   sudo usermod -a -G testgroup2 testuser2
   
   # Verify
   id testuser2
   # groups=1001(testuser2),1002(testgroup2)
   ```

8. **Change user's shell**
   ```bash
   sudo usermod -s /bin/zsh testuser2
   
   grep testuser2 /etc/passwd
   # Should show /bin/zsh at end
   ```

9. **List all users**
   ```bash
   getent passwd | grep test
   # Shows all test users
   
   # Count regular users
   awk -F: '$3 >= 1000' /etc/passwd | wc -l
   ```

### Expected Output

```
$ id testuser2
uid=1001(testuser2) gid=1001(testuser2) groups=1001(testuser2)

$ grep testuser2 /etc/passwd
testuser2:x:1001:1001::/home/testuser2:/bin/bash

$ ls -la /home/testuser2
total 24
drwxr-xr-x  2 testuser2 testuser2 4096 Jan 15 11:20 .
drwxrwxr-x 13 root      root      4096 Jan 15 11:20 ..
-rw-r--r--  1 testuser2 testuser2  220 Jan 15 11:20 .bash_logout
```

### Verification Checklist

- [ ] Can create user with useradd
- [ ] Can create user with home directory (-m)
- [ ] Can set specific UID
- [ ] Can add comment to user
- [ ] Can set password with passwd
- [ ] Can modify user with usermod
- [ ] Can add user to group
- [ ] Can verify user creation
- [ ] Can change user shell

### Cleanup

```bash
# Delete test users
sudo userdel -r testuser2
sudo userdel -r testuser3
sudo userdel -r testuser4

# Delete group
sudo groupdel testgroup2
```

---

## Lab 6: Create and Manage Groups

**Difficulty**: Intermediate | **Time**: 20 minutes

### Goal
Create groups and manage group membership.

### Setup

```bash
# Nothing needed to start
```

### Steps

1. **Create a group**
   ```bash
   sudo groupadd developers
   
   # Verify in group file
   grep developers /etc/group
   ```

2. **Check group ID (GID)**
   ```bash
   grep developers /etc/group
   # developers:x:1001:
   # GID = 1001
   ```

3. **Create another group**
   ```bash
   sudo groupadd qa
   ```

4. **Create users**
   ```bash
   sudo useradd -m -s /bin/bash alice
   sudo useradd -m -s /bin/bash bob
   sudo useradd -m -s /bin/bash charlie
   ```

5. **Add users to developers group**
   ```bash
   sudo usermod -a -G developers alice
   sudo usermod -a -G developers bob
   
   # Verify
   id alice
   id bob
   ```

6. **Add users to qa group**
   ```bash
   sudo usermod -a -G qa bob
   sudo usermod -a -G qa charlie
   ```

7. **View group membership**
   ```bash
   # View group and members
   grep developers /etc/group
   # developers:x:1001:alice,bob
   
   grep qa /etc/group
   # qa:x:1002:bob,charlie
   ```

8. **Use getent to view**
   ```bash
   getent group developers
   # developers:x:1001:alice,bob
   ```

9. **List all members of a group**
   ```bash
   getent group developers | cut -d: -f4
   # alice,bob
   ```

### Expected Output

```
$ grep developers /etc/group
developers:x:1001:alice,bob

$ id alice
uid=1000(alice) gid=1000(alice) groups=1000(alice),1001(developers)

$ id bob
uid=1001(bob) gid=1001(bob) groups=1001(bob),1001(developers),1002(qa)

$ getent group developers
developers:x:1001:alice,bob
```

### Verification Checklist

- [ ] Can create group with groupadd
- [ ] Can add user to group with usermod -a -G
- [ ] Can view group in /etc/group
- [ ] Can list group members
- [ ] Can verify membership with id command
- [ ] Can use getent to view groups
- [ ] Understand primary vs secondary groups

### Cleanup

```bash
# Delete users
sudo userdel -r alice
sudo userdel -r bob
sudo userdel -r charlie

# Delete groups
sudo groupdel developers
sudo groupdel qa
```

---

## Lab 7: Special Permissions (setuid, setgid, sticky bit)

**Difficulty**: Intermediate | **Time**: 30 minutes

### Goal
Understand and apply special permissions.

### Setup

```bash
mkdir -p /tmp/special-test
cd /tmp/special-test

# Create test files and directory
touch setuid-test
touch setgid-test
mkdir shared-dir
```

### Steps

1. **Understand setuid (Set User ID)**
   ```bash
   # Check existing setuid file
   ls -la /usr/bin/passwd
   # -rwsr-xr-x (note 's' in owner execute position)
   
   # Get numeric: 4755
   stat -c "%a" /usr/bin/passwd
   # 4755 (first digit 4 = setuid)
   ```

2. **Add setuid to test file (numeric)**
   ```bash
   chmod 4755 setuid-test
   ls -la setuid-test
   # -rwsr-xr-x (s replaces x)
   ```

3. **Add setuid using symbolic**
   ```bash
   chmod u+s setuid-test
   ls -la setuid-test
   # -rwsr-xr-x
   ```

4. **Remove setuid**
   ```bash
   chmod u-s setuid-test
   ls -la setuid-test
   # -rwxr-xr-x (x returns)
   ```

5. **Understand setgid on files**
   ```bash
   chmod 2755 setgid-test
   ls -la setgid-test
   # -rwxr-sr-x (s in group execute position)
   ```

6. **Understand setgid on directories**
   ```bash
   chmod 2755 shared-dir
   ls -ld shared-dir
   # drwxr-sr-x (s in group execute position)
   
   # When user creates file here, inherits group
   ```

7. **Create group for setgid test**
   ```bash
   sudo groupadd testgroup
   sudo chgrp testgroup shared-dir
   ```

8. **Test setgid inheritance**
   ```bash
   # Create file in setgid directory
   touch shared-dir/newfile.txt
   
   ls -la shared-dir/
   # newfile.txt has group = testgroup (inherited)
   ```

9. **Sticky bit on directory**
   ```bash
   chmod 1777 shared-dir
   ls -ld shared-dir
   # drwxrwxrwt (t in other execute position)
   
   # Now users can create files but only owner can delete
   ```

10. **View all special permissions together**
    ```bash
    # Create file with all three
    chmod 7755 setuid-test
    ls -la setuid-test
    # -rwsr-sr-t (sets all three special bits)
    
    stat -c "%a" setuid-test
    # 7755
    ```

### Expected Output

```
$ chmod 4755 setuid-test
$ ls -la setuid-test
-rwsr-xr-x 1 alice alice 0 Jan 15 12:00 setuid-test

$ chmod g+s shared-dir
$ ls -ld shared-dir
drwxr-sr-x 2 alice testgroup 4096 Jan 15 12:01 shared-dir

$ chmod +t shared-dir
$ ls -ld shared-dir
drwxr-sr-t 2 alice testgroup 4096 Jan 15 12:02 shared-dir

$ stat -c "%a %A %n" setuid-test
4755 -rwsr-xr-x setuid-test
```

### Verification Checklist

- [ ] Can identify setuid bit (s in owner execute)
- [ ] Can identify setgid bit (s in group execute)
- [ ] Can identify sticky bit (t in other execute)
- [ ] Can set special bits with chmod (numeric 4/2/1xxx)
- [ ] Can set special bits with chmod (symbolic u+s, g+s, +t)
- [ ] Can remove special bits
- [ ] Can verify with ls -la and stat
- [ ] Understand setgid inheritance on directories

### Cleanup

```bash
rm -rf /tmp/special-test
sudo groupdel testgroup
```

---

## Lab 8: Understanding and Using Sudo

**Difficulty**: Intermediate | **Time**: 25 minutes

### Goal
Understand sudo configuration and privilege escalation.

### Setup

```bash
# Make sure you have sudo access
sudo whoami
# Should show: root
```

### Steps

1. **Check current sudo access**
   ```bash
   sudo -l
   # Shows what user can run
   ```

2. **Find your user in sudoers**
   ```bash
   sudo grep $USER /etc/sudoers
   # Or check /etc/sudoers.d/ files
   ls /etc/sudoers.d/
   ```

3. **View sudoers safely**
   ```bash
   sudo visudo -c
   # -c flag validates syntax only, doesn't edit
   ```

4. **Run command as root**
   ```bash
   whoami
   # Returns: your username
   
   sudo whoami
   # Returns: root
   ```

5. **Create test user without sudo**
   ```bash
   sudo useradd -m -s /bin/bash nosudouser
   ```

6. **Try to run sudo as this user** (will fail)
   ```bash
   # Switch to test user (with password if you know it)
   # This demonstrates limited access
   ```

7. **Check sudo group membership**
   ```bash
   groups
   # Check if 'sudo' is listed (usually is)
   
   getent group sudo
   # Lists members of sudo group
   ```

8. **See password requirement**
   ```bash
   # When using sudo, you're prompted for password
   # This is YOUR password, not root password
   
   sudo whoami
   # [sudo] password for username: (enter your password)
   ```

9. **View sudo log (if available)**
   ```bash
   sudo tail -20 /var/log/auth.log | grep sudo
   # Shows sudo usage history
   ```

### Expected Output

```
$ sudo -l
Matching Defaults entries for alice on ubuntu:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User alice may run the following commands on ubuntu:
    (ALL) ALL

$ sudo whoami
root

$ groups
alice adm cdrom sudo dip plugdev lpadmin sambashare
```

### Verification Checklist

- [ ] Can check sudo access with sudo -l
- [ ] Can run command as root with sudo
- [ ] Understand password is YOUR password, not root
- [ ] Can find user in sudoers configuration
- [ ] Can use sudo visudo to safely view config
- [ ] Understand sudo group on Ubuntu/Debian
- [ ] Can see sudo usage in logs

### Cleanup

```bash
# Delete test user
sudo userdel -r nosudouser
```

---

## Lab 9: Auditing and Fixing Permissions

**Difficulty**: Intermediate | **Time**: 25 minutes

### Goal
Find and fix permission problems on a system.

### Setup

```bash
mkdir -p /tmp/audit-test
cd /tmp/audit-test

# Create files with various permission issues
touch world-writable.txt
touch setuid-binary
mkdir shared-folder

# Set problematic permissions
chmod 666 world-writable.txt    # World-writable file!
chmod 4755 setuid-binary
chmod 777 shared-folder         # World-writable directory!
```

### Steps

1. **Find world-writable files (security risk)**
   ```bash
   find /tmp/audit-test -type f -perm -002
   # -002 = world-writable
   # Returns: world-writable.txt
   ```

2. **Find setuid files**
   ```bash
   find /tmp/audit-test -type f -perm -4000
   # -4000 = has setuid bit
   # Returns: setuid-binary
   ```

3. **Find setgid files**
   ```bash
   find /tmp/audit-test -type f -perm -2000
   # -2000 = has setgid bit
   ```

4. **Find files owned by specific user**
   ```bash
   find /tmp/audit-test -user $USER
   # Lists all files owned by you
   ```

5. **Fix world-writable file**
   ```bash
   # Remove world-writable permission
   chmod o-w world-writable.txt
   ls -la world-writable.txt
   # Should be: -rw-rw-r-- now
   ```

6. **Fix overly permissive directory**
   ```bash
   chmod 755 shared-folder
   ls -ld shared-folder
   # Should be: drwxr-xr-x now
   ```

7. **Audit all home directory permissions**
   ```bash
   ls -la /home/$USER
   # Home directory should be 700 or 750
   # Check: drwx------  or  drwxr-x---
   ```

8. **Fix home directory if needed**
   ```bash
   chmod 700 /home/$USER
   ls -ld /home/$USER
   # Should be: drwx------
   ```

9. **Create permission audit script concept**
   ```bash
   # Find problematic files in /tmp
   echo "=== World-writable files in /tmp/audit-test ==="
   find /tmp/audit-test -type f -perm -002
   
   echo "=== Files with setuid/setgid ==="
   find /tmp/audit-test -type f \( -perm -4000 -o -perm -2000 \)
   
   echo "=== Directories with full access ==="
   find /tmp/audit-test -type d -perm -002
   ```

### Expected Output

```
$ find /tmp/audit-test -type f -perm -002
/tmp/audit-test/world-writable.txt

$ ls -la /tmp/audit-test/world-writable.txt
-rw-rw-rw- 1 alice alice 0 Jan 15 12:30 world-writable.txt

$ chmod o-w world-writable.txt

$ ls -la /tmp/audit-test/world-writable.txt
-rw-rw-r-- 1 alice alice 0 Jan 15 12:31 world-writable.txt

$ find /tmp/audit-test -type f -perm -002
(returns nothing - fixed!)
```

### Verification Checklist

- [ ] Can find world-writable files with find
- [ ] Can find setuid/setgid files
- [ ] Can identify and fix permission issues
- [ ] Can use find with -perm flag
- [ ] Can fix files with chmod
- [ ] Understand security implications
- [ ] Can audit directories
- [ ] Can create audit scripts

### Cleanup

```bash
rm -rf /tmp/audit-test
```

---

## Summary

After completing these 9 labs, you should be comfortable with:

✓ Understanding user and group concepts  
✓ Reading and interpreting permissions  
✓ Changing file permissions and ownership  
✓ Creating and managing users and groups  
✓ Understanding and using special permissions  
✓ Using sudo for privilege escalation  
✓ Auditing and fixing permission issues  
✓ Applying security best practices  

**Total Time**: 220 minutes of hands-on learning

---

**Next**: Explore the production scripts in [scripts/README.md](scripts/README.md) for real-world automation patterns.
