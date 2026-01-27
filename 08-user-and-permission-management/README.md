# Module 8: User and Permission Management

## What You'll Learn

- Create and manage users and groups
- Understand Linux file permissions and ownership
- Apply chmod and chown for permission control
- Configure sudo for privilege escalation
- Implement special permissions (setuid, setgid, sticky bit)
- Manage umask and default permissions
- Implement security best practices

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Understand file systems and directories
- Familiar with command-line operations
- Understanding of user accounts

## Key Concepts

| Concept | Description |
|---------|-------------|
| **UID** | User ID - unique identifier for users |
| **GID** | Group ID - unique identifier for groups |
| **rwx** | Read, Write, Execute permissions |
| **chmod** | Change mode (permissions) of files |
| **chown** | Change owner of files |
| **chgrp** | Change group of files |
| **umask** | Default permissions mask |
| **setuid** | Set user ID on execution |
| **setgid** | Set group ID on execution |
| **sticky bit** | Prevent deletion by non-owners |

## Hands-on Lab: Create Users and Manage Permissions

### Lab Objective
Create users, manage permissions, and configure sudo access.

### Commands

```bash
# Create new user
sudo useradd -m -s /bin/bash username

# Create user with home directory and shell
sudo useradd -m -d /home/user1 -s /bin/bash user1

# Set user password
sudo passwd username

# Create group
sudo groupadd groupname

# Add user to group
sudo usermod -aG groupname username

# Show user info
id username

# Show all users
cat /etc/passwd | cut -d: -f1

# Show all groups
cat /etc/group | cut -d: -f1

# View file permissions
ls -l filename

# Symbolic permission display
ls -lh directory/

# View octal permissions
stat -c '%A %a %n' filename

# Change permissions (symbolic)
chmod u+x file.sh

# Change permissions (octal)
chmod 755 script.sh

# Change owner
chown owner:group file

# Change owner recursively
chown -R owner:group directory/

# Show user ID mapping
getent passwd username

# Change user shell
sudo usermod -s /bin/bash username

# Lock user account
sudo usermod -L username

# Unlock user account
sudo usermod -U username

# Delete user
sudo userdel -r username

# View sudoers file
sudo visudo

# Show sudo privileges
sudo -l
```

### Expected Output

```
# id output:
uid=1000(user1) gid=1000(user1) groups=1000(user1),1001(sudo)

# ls -l output:
-rw-r--r-- 1 user1 user1 1234 Jan 20 10:30 file.txt
drwxr-xr-x 2 user1 user1 4096 Jan 20 10:30 directory/

# stat output:
-rw-r--r-- 644 /home/user1/file.txt
```

## Validation

Confirm successful completion:

- [ ] Created new user account
- [ ] Added user to group
- [ ] Changed file permissions with chmod
- [ ] Changed file owner with chown
- [ ] Configured sudo for user
- [ ] Tested permission changes

## Cleanup

```bash
# Remove test user
sudo userdel -r testuser

# Remove test group
sudo groupdel testgroup

# Reset test file permissions
chmod 644 /tmp/test.txt
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Recursive chmod on / | Always specify directory carefully |
| Wrong permission syntax | Use chmod 755 (octal) or u+x (symbolic) |
| Changing root ownership | Be careful with chown on system files |
| Deleting active user | Close their sessions first |
| Forgetting sudo | Prefix commands with `sudo` when needed |

## Troubleshooting

**Q: How do I change file permissions?**
A: Use `chmod 755 file` (octal) or `chmod u+x file` (symbolic).

**Q: Can I add user to sudo?**
A: Yes, use `sudo usermod -aG sudo username` then restart shell.

**Q: How do I view current permissions?**
A: Use `ls -l` to see rwx, `stat file` for octal form.

**Q: What does 755 mean?**
A: Owner=7(rwx), Group=5(r-x), Others=5(r-x).

**Q: How do I reset user password?**
A: Use `sudo passwd username` as root/sudo user.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Practice user and group management
3. Master permission delegation with groups
4. Implement security hardening
5. Learn ACLs and SELinux contexts
