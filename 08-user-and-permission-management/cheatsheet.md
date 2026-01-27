# User and Permission Management: Cheatsheet

## User Management

| Command | Purpose | Example |
|---------|---------|---------|
| `useradd username` | Create user | `sudo useradd user1` |
| `useradd -m username` | Create with home dir | `sudo useradd -m user1` |
| `useradd -s shell username` | Create with shell | `sudo useradd -s /bin/bash user1` |
| `useradd -d home username` | Custom home | `sudo useradd -d /home/u1 user1` |
| `passwd username` | Set password | `sudo passwd user1` |
| `userdel username` | Delete user | `sudo userdel user1` |
| `userdel -r username` | Delete with home | `sudo userdel -r user1` |
| `usermod -aG group user` | Add to group | `sudo usermod -aG sudo user1` |
| `usermod -s shell user` | Change shell | `sudo usermod -s /bin/bash user1` |
| `usermod -L user` | Lock user | `sudo usermod -L user1` |
| `usermod -U user` | Unlock user | `sudo usermod -U user1` |
| `id username` | Show UID/GID | `id user1` |
| `whoami` | Current user | `whoami` |
| `who` | Logged in users | `who` |
| `w` | Users and load | `w` |
| `last` | Login history | `last` |

## Group Management

| Command | Purpose | Example |
|---------|---------|---------|
| `groupadd groupname` | Create group | `sudo groupadd developers` |
| `groupadd -g gid group` | With specific GID | `sudo groupadd -g 2000 devops` |
| `groupdel groupname` | Delete group | `sudo groupdel developers` |
| `groups username` | User's groups | `groups user1` |
| `members groupname` | Group members | `members developers` |
| `cat /etc/group` | All groups | `cat /etc/group` |
| `getent group` | Group details | `getent group` |

## Permission Viewing

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -l file` | Long format | `ls -l` |
| `ls -ld dir` | Directory mode | `ls -ld /home` |
| `stat file` | Detailed info | `stat file.txt` |
| `stat -c '%A %a' file` | Symbolic and octal | `stat -c '%A %a' file.txt` |

## Permission Modification (chmod)

| Command | Purpose | Example |
|---------|---------|---------|
| `chmod 755 file` | Octal mode | `chmod 755 script.sh` |
| `chmod u+x file` | Add user execute | `chmod u+x file` |
| `chmod g-w file` | Remove group write | `chmod g-w file` |
| `chmod o-r file` | Remove others read | `chmod o-r file` |
| `chmod +x file` | All execute | `chmod +x file` |
| `chmod -R 755 dir` | Recursive | `chmod -R 755 directory` |
| `chmod a=rx file` | Set exact (all read+exec) | `chmod a=rx file` |

## Ownership Modification (chown/chgrp)

| Command | Purpose | Example |
|---------|---------|---------|
| `chown user file` | Change owner | `sudo chown user1 file.txt` |
| `chown user:group file` | Owner and group | `sudo chown user1:group1 file.txt` |
| `chown :group file` | Group only | `sudo chown :group1 file.txt` |
| `chown -R user dir` | Recursive | `sudo chown -R user1 directory` |
| `chgrp group file` | Change group | `sudo chgrp group1 file.txt` |
| `chgrp -R group dir` | Recursive group | `sudo chgrp -R group1 directory` |

## Special Permissions

| Notation | Octal | Meaning | Example |
|----------|-------|---------|---------|
| setuid | 4xxx | User execute as owner | `chmod 4755 file` |
| setgid | 2xxx | Group execute as group | `chmod 2755 dir` |
| sticky | 1xxx | Prevent deletion | `chmod 1777 /tmp` |
| Combined | 7xxx | All three | `chmod 7755 file` |

## Octal Permission Reference

| Octal | Symbolic | Meaning |
|-------|----------|---------|
| 777 | rwxrwxrwx | Full access |
| 755 | rwxr-xr-x | Owner full, others read+execute |
| 644 | rw-r--r-- | Owner write, others read |
| 600 | rw------- | Owner only |
| 700 | rwx------ | Owner full, others none |
| 400 | r-------- | Read-only |
| 000 | --------- | No access |

## Umask

| Command | Purpose | Example |
|---------|---------|---------|
| `umask` | Show current | `umask` |
| `umask 022` | Set temporary | `umask 022` |
| `umask 077` | Restrictive | `umask 077` |

## Sudo Management

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo visudo` | Edit sudoers safely | `sudo visudo` |
| `sudo -l` | Show privileges | `sudo -l` |
| `sudo -u user cmd` | Run as user | `sudo -u user1 whoami` |
| `sudo !!` | Repeat last as sudo | `sudo !!` |
| `usermod -aG sudo user` | Add to sudo | `sudo usermod -aG sudo user1` |

## File Listings

| File | Purpose |
|------|---------|
| `/etc/passwd` | User database |
| `/etc/shadow` | Password hashes |
| `/etc/group` | Group database |
| `/etc/gshadow` | Group passwords |
| `/etc/sudoers` | Sudo configuration |

## Permission Symbols

| Symbol | Meaning |
|--------|---------|
| `-` | Regular file |
| `d` | Directory |
| `l` | Symbolic link |
| `s` | Socket |
| `p` | Named pipe |
| `r` | Read (4) |
| `w` | Write (2) |
| `x` | Execute (1) |
| `s` | Setuid/setgid |
| `t` | Sticky bit |
| `S` | Setuid (no execute) |
| `T` | Sticky (no execute) |

## Common Permissions

| Permission | Use Case | Octal |
|------------|----------|-------|
| Executable script | User execute | 755 |
| Configuration file | Read only | 644 |
| Private file | Owner only | 600 |
| Directory | Navigable | 755 |
| Shared directory | Team access | 2775 |
| Temporary files | World write | 1777 |
| Log file | Append only | 644 |

## UID/GID Reference

| UID/GID | User/Group | Purpose |
|---------|-----------|---------|
| 0 | root | System administrator |
| 1-999 | system | System accounts |
| 1000+ | users | Regular users |

## sudoers Examples

```
# Grant all commands
user ALL=(ALL) ALL

# Grant specific command
user ALL=(ALL) /usr/bin/systemctl

# No password for specific command
user ALL=(ALL) NOPASSWD: /usr/bin/systemctl

# Run as specific user
user ALL=(www-data) /usr/bin/php

# Allow group
%developers ALL=(ALL) ALL
```
