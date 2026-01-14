# Module 08: User and Permission Management - Theory

Comprehensive conceptual foundations for understanding users, groups, and permissions in Linux.

## Table of Contents

1. [User and Group Concepts](#user-and-group-concepts)
2. [User Accounts](#user-accounts)
3. [Groups and Group Membership](#groups-and-group-membership)
4. [File Permission Basics](#file-permission-basics)
5. [Permission Notation](#permission-notation)
6. [File Ownership](#file-ownership)
7. [Special Permissions](#special-permissions)
8. [umask and Default Permissions](#umask-and-default-permissions)
9. [Sudo and Privilege Escalation](#sudo-and-privilege-escalation)
10. [Permission Security Model](#permission-security-model)

---

## User and Group Concepts

### What is a User?

A **user** is a unique account on a Linux system.

```
User = Identity + Access Rights + Home Directory + Shell

Examples:
├─ root (UID 0)
├─ www-data (web service)
├─ mysql (database service)
├─ john (person)
└─ app_user (application)
```

### Why Users Exist

1. **Identification** - Know who did what
2. **Isolation** - Each user has separate space
3. **Access Control** - Restrict who can do what
4. **Audit Trail** - Track user activities
5. **Privilege Separation** - Services run as non-root

### What is a Group?

A **group** is a collection of users with shared permissions.

```
Group = Set of Users with Common Permissions

Example:
developers group:
├─ alice
├─ bob
└─ carol

All three can access /home/shared/code
```

### User vs Group Access

```
File Permissions:
owner: alice (user)
group: developers (group)
others: everyone else

Permissions:
owner:  rwx (alice can do everything)
group:  r-x (bob and carol can read/execute)
others: --- (everyone else blocked)
```

---

## User Accounts

### User Information Storage

User information stored in `/etc/passwd`:

```bash
$ cat /etc/passwd | head -3
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```

Format: `username:password_placeholder:UID:GID:name:home:shell`

```
root          = username
x             = password marker (actual in /etc/shadow)
0             = UID (user ID)
0             = GID (primary group ID)
root          = Full name
/root         = Home directory
/bin/bash     = Login shell
```

### User IDs (UID)

```
UID Assignment:
0              → root (superuser)
1-999          → System users/services
1000+          → Regular users
```

```bash
$ id alice
uid=1000(alice) gid=1000(alice) groups=1000(alice),27(sudo)

uid=1000       → alice's UID
gid=1000       → alice's primary group
groups=...     → all groups alice is member of
```

### User Types

```
System Users (UID < 1000)
├─ www-data (web server)
├─ mysql (database)
├─ postgres (database)
├─ redis (cache)
└─ Purpose: Run services without human login

Regular Users (UID >= 1000)
├─ alice
├─ bob
└─ Purpose: Human accounts
```

### User Home Directory

```bash
/home/username/
├─ .bashrc       (bash configuration)
├─ .profile      (login configuration)
├─ .ssh/         (SSH keys)
├─ Desktop/
└─ Documents/
```

**Ownership**: User owns their home directory

```bash
$ ls -la /home/alice
drwxr-xr-x alice alice /home/alice

alice owns directory
```

---

## Groups and Group Membership

### Group Information Storage

Groups stored in `/etc/group`:

```bash
$ cat /etc/group | head -3
root:x:0:
daemon:x:1:
bin:x:2:
```

Format: `groupname:password_marker:GID:member_list`

### Primary vs Secondary Groups

Every user has:
- **Primary group**: Set when account created (usually username)
- **Secondary groups**: Added with `usermod -G`

```bash
$ id alice
uid=1000(alice) gid=1000(alice) groups=1000(alice),27(sudo),4(adm)

1000(alice)  = Primary group
27(sudo)     = Secondary group 1
4(adm)       = Secondary group 2
```

### Group Membership Types

```
User in Group via Two Mechanisms:

1. Primary Group (GID in /etc/passwd)
   └─ Set at account creation
   └─ One per user
   └─ New files get this group

2. Secondary Groups (/etc/group)
   └─ Multiple allowed
   └─ Need to add explicitly
   └─ Don't affect new file group
```

### Files Created with Group Ownership

```bash
$ touch file.txt
$ ls -la file.txt
-rw-r--r-- alice alice file.txt

File group = alice's PRIMARY group
```

New file gets:
- Owner = creating user
- Group = creating user's primary group
- Permissions = determined by umask

---

## File Permission Basics

### Permission Types

Three permission types for files:

| Permission | Symbol | Number | Meaning |
|------------|--------|--------|---------|
| Read | r | 4 | Can view/read file |
| Write | w | 2 | Can modify file |
| Execute | x | 1 | Can run as program |

For directories:

| Permission | Meaning |
|------------|---------|
| Read (r) | Can list contents |
| Write (w) | Can create/delete files |
| Execute (x) | Can enter directory |

### Three Permission Categories

```
Owner (User):   rwx (7)
Group:          r-x (5)
Others (Other): r-- (4)

Meaning:
Owner can: read, write, execute
Group can: read, execute (not modify)
Others can: read only
```

### Permission Diagram

```
-rw-r--r--
│└─────┬─────┘
│      └─ Others (everyone else): r--
│
├─ Owner (user): rw-
├─ Group: r--
└─ Type: - (file)

Type codes:
- = regular file
d = directory
l = symbolic link
c = character device
b = block device
```

### Permission Examples

```
-rw-r--r--  (644)    Regular file
Owner: rw- (6)       Can read/write
Group: r-- (4)       Can read only
Other: r-- (4)       Can read only

-rwxr-xr-x  (755)    Script/executable
Owner: rwx (7)       Can do anything
Group: r-x (5)       Can read/execute
Other: r-x (5)       Can read/execute

drwxr-xr-x  (755)    Directory
Owner: rwx (7)       Can create/delete
Group: r-x (5)       Can list/enter
Other: r-x (5)       Can list/enter
```

---

## Permission Notation

### Numeric (Octal) Notation

Permissions as three-digit number:

```
r (read)    = 4
w (write)   = 2
x (execute) = 1

Sum values: 4+2+1 = 7 (rwx)

Examples:
7 = rwx (4+2+1)
6 = rw- (4+2+0)
5 = r-x (4+0+1)
4 = r-- (4+0+0)
0 = --- (0+0+0)
```

### Full Permission Number

```
chmod 755 file
 │   └─ Owner=7, Group=5, Other=5
 └─ The command

644 = rw-r--r--
└─ Owner(6), Group(4), Other(4)

777 = rwxrwxrwx
└─ Everyone can do everything (dangerous!)
```

### Symbolic Notation

```
chmod u+x file
 │    │└ Action (+, -, =)
 │    └─ Who (u, g, o, a)
 └─ Command

Who:
u = user (owner)
g = group
o = other
a = all

Action:
+ = add permission
- = remove permission
= = set exactly

Examples:
chmod u+x       Add execute for owner
chmod g-w       Remove write from group
chmod a=r       Everyone can only read
chmod +x        Add execute for all
```

### Converting Between Notations

```
755 = rwxr-xr-x
     └─ Owner=7(rwx), Group=5(r-x), Other=5(r-x)

chmod u=rwx,g=rx,o=rx = chmod 755

-rw-r--r-- = 644
     └─ Owner=6(rw-), Group=4(r--), Other=4(r--)
```

---

## File Ownership

### Owner and Group

Every file has:

```bash
-rw-r--r-- 1 alice developers 1024 date file.txt
         │   │     └─ Group (developers)
         │   └─ Owner (alice)
         └─ Link count
```

**Owner**: User who created/owns file
**Group**: Group associated with file

### Changing Owner (chown)

```bash
# Change owner only
chown alice file.txt

# Change owner and group
chown alice:developers file.txt

# Change owner recursively
chown -R alice:developers /home/alice

# Change only group
chown :developers file.txt
# OR
chgrp developers file.txt
```

### Group Membership Impact

```
File Permission: -rw-r----- (640)
                       └─ Group gets r-- (read)

User alice in "developers" group:
alice opens file → matches owner → uses owner permissions (rw-)

User bob in "developers" group:
bob opens file → matches group → uses group permissions (r--)
```

---

## Special Permissions

### setuid (Set User ID)

When **setuid** bit is set, file runs as owner, not executor.

```
-rwsr-xr-x
   ↑
   setuid bit (s instead of x in owner position)

Normal:
alice executes program → runs as alice

With setuid:
alice executes program → runs as file owner (e.g., root)
```

**Real Examples**:

```bash
$ ls -la /usr/bin/passwd
-rwsr-xr-x root root /usr/bin/passwd

Why? Normal user needs to change own password
Problem: Passwords stored in /etc/shadow (root only)
Solution: passwd binary has setuid bit
Result: When you run passwd, it runs as root temporarily
```

**setuid Notation**:

```
Numeric: 4755
         ↑
         4 = setuid

Symbolic: chmod u+s file

Check: Octal 4000 = setuid bit set
```

### setgid (Set Group ID)

When **setgid** on file: runs as group
When **setgid** on directory: new files inherit directory group

```
-rwxr-sr-x
      ↑
      setgid bit (s in group position)

On File:
Executes as group owner (not user's group)

On Directory:
New files created in directory inherit directory's group
```

**Real Example**:

```bash
# Directory with setgid
drwxr-sr-x developers shared_folder

User creates file in shared_folder:
File owner = user
File group = developers (inherited from directory)
This keeps group assignment consistent
```

**setgid Notation**:

```
Numeric: 2755
         ↑
         2 = setgid

Symbolic: chmod g+s file (file)
         chmod g+s directory
```

### Sticky Bit

When **sticky bit** set on directory, only owner can delete files.

```
drwxrwxrwt
        ↑
        sticky bit (t instead of x in other position)

Example: /tmp directory
Everyone can create files
But only file owner can delete their file
Even if directory is writable by all
```

**Real Example**:

```bash
$ ls -la / | grep tmp
drwxrwxrwt

/tmp is world-writable
But you can't delete other users' files
Because of sticky bit
```

**Sticky Bit Notation**:

```
Numeric: 1777
         ↑
         1 = sticky bit

Symbolic: chmod +t directory
         chmod o+t directory
```

### Special Permission Matrix

```
setuid (4xxx):  Only on files, executes as owner
setgid (2xxx):  On files (execute as group), on dirs (inherit group)
Sticky (1xxx):  On directories, prevent deletion by non-owner

Full chmod:
chmod 4755   setuid + rwxr-xr-x
chmod 2755   setgid + rwxr-xr-x
chmod 1777   sticky + rwxrwxrwx
chmod 7777   all three special + rwxrwxrwx (very rare)
```

---

## umask and Default Permissions

### What is umask?

**umask** is a mask that determines default permissions for new files/directories.

```
umask = 0022

File default:  666 (rw-rw-rw-)
Mask:         -0022 (---−−−w-−w-)
Result:       644 (rw-r--r--)

Directory default: 777 (rwxrwxrwx)
Mask:             -0022 (---−−−w-−w-)
Result:           755 (rwxr-xr-x)
```

### How umask Works

```
umask value subtracted from defaults

Common umask values:
0022  → Files: 644, Dirs: 755 (standard)
0027  → Files: 640, Dirs: 750 (more restrictive)
0077  → Files: 600, Dirs: 700 (very restrictive)
0002  → Files: 664, Dirs: 775 (permissive)
```

### Viewing and Setting umask

```bash
# View current umask
umask

# Set for session
umask 0027

# Make permanent (in ~/.bashrc or ~/.profile)
echo "umask 0027" >> ~/.bashrc
```

### umask by Category

```
First digit: special permissions (usually 0)

For regular files:
666 - 022 = 644 (rw-r--r--)

For directories:
777 - 022 = 755 (rwxr-xr-x)

The subtraction removes those permission bits
```

---

## Sudo and Privilege Escalation

### What is sudo?

**sudo** (superuser do) allows authorized users to run commands as root.

```
$ sudo command
[sudo] password for alice: ****

Command runs as root, but alice is tracked in logs
```

### sudo vs su

```
su (switch user):
su - root
Becomes root completely
Need to type root password

sudo (superuser do):
sudo command
Runs command as root
Need to type your password
Logged and controlled via sudoers
```

### sudo Configuration (/etc/sudoers)

```bash
# Format: user/group HOST = (run_as) COMMAND

root ALL=(ALL) ALL
  ├─ root = user
  ├─ ALL = can run on any host
  ├─ (ALL) = can run as anyone
  └─ ALL = can run any command

%sudo ALL=(ALL) ALL
  ├─ %sudo = group named "sudo"
  ├─ ALL members can run any command
  └─ As any user
```

### sudo Examples

```bash
# Simple: run command as root
sudo apt update

# With password prompt
sudo systemctl restart nginx
[sudo] password for alice:

# Without password for specific command
alice ALL=(ALL) NOPASSWD: /usr/bin/systemctl

# Only specific commands
alice ALL=(ALL) /usr/sbin/useradd, /usr/sbin/userdel
```

### Editing sudoers Safely

```bash
# Always use visudo (validates syntax)
sudo visudo

# Do NOT edit directly
sudo nano /etc/sudoers    # WRONG - can break sudo!

# Specific editor
sudo EDITOR=nano visudo
```

---

## Permission Security Model

### Principle of Least Privilege

Every user/process should have **minimum access needed**.

```
Bad (too permissive):
-rwxrwxrwx file   (777)
Everyone can do everything

Good (least privilege):
-rwxr-x--- file   (750)
Owner: rwx (full)
Group: r-x (read/execute)
Other: --- (nothing)
```

### Permission Examples by Use Case

```
Web Document:
-rw-r--r--   (644)
Owner edits, others read

Executable:
-rwxr-xr-x   (755)
Owner modifies, others execute

Sensitive Data:
-rw-------   (600)
Owner only

Shared Directory:
drwxrwx---   (770)
Owner and group can modify
Others blocked

Public Directory:
drwxr-xr-x   (755)
Everyone can read/execute
Only owner can modify
```

### Security Checklist

```
File Permissions:
□ Check for world-writable files (-rw-rw-rw-)
□ Check for unnecessary execute bits
□ Verify sensitive files are readable only by owner
□ Check for setuid/setgid on unexpected files

Ownership:
□ System binaries owned by root
□ Home directories owned by users
□ Group ownership matches intended group

Users:
□ Disable unused accounts (or use nologin shell)
□ Use strong passwords
□ Regularly review sudo access
□ Remove users when no longer needed

umask:
□ Set appropriate system umask (typically 0022)
□ Home directories should have umask 0027
```

---

## Key Takeaways

1. **Users = Identity** - Every process runs as a user
2. **Groups = Shared Access** - Multiple users with common permissions
3. **rwx Bits = Access Control** - Define what owner/group/other can do
4. **Special Permissions** - setuid, setgid, sticky bit for special cases
5. **umask = Default Permissions** - Controls new file/directory permissions
6. **Least Privilege = Security** - Give minimum access needed
7. **sudo = Controlled Escalation** - Root access via logged, authorized path
8. **Ownership Matters** - Who owns file determines permission application

---

**Ready to practice?** Continue to [02-commands-cheatsheet.md](02-commands-cheatsheet.md)
