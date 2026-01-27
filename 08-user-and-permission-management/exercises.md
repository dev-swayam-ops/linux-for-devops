# User and Permission Management: Exercises

Complete these exercises to master user and permission management.

## Exercise 1: Create and Manage Users

**Tasks:**
1. Create new user account
2. Verify user creation
3. Show user ID and GID
4. List all users on system
5. View detailed user information

**Hint:** Use `useradd`, `id`, `cat /etc/passwd`, `getent`.

---

## Exercise 2: Manage User Groups

**Tasks:**
1. Create new group
2. Add user to group
3. Create group with specific GID
4. List all groups
5. Show group membership

**Hint:** Use `groupadd`, `usermod -aG`, `cat /etc/group`.

---

## Exercise 3: Understanding File Permissions

**Tasks:**
1. List files with permissions
2. Understand rwx meaning
3. Convert symbolic to octal (755, 644)
4. View permissions in octal format
5. Identify permission patterns

**Hint:** Use `ls -l`, `stat`, understand r=4, w=2, x=1.

---

## Exercise 4: Change File Permissions (chmod)

**Tasks:**
1. Create test file
2. Change with octal: chmod 755
3. Change with symbolic: chmod u+x
4. Change for group: chmod g+r
5. Remove permissions: chmod o-r

**Hint:** Use `chmod 755`, `chmod u+x`, `chmod g-w`.

---

## Exercise 5: Change File Ownership (chown)

**Tasks:**
1. Create test file
2. Change owner: chown newowner file
3. Change owner and group: chown owner:group
4. Recursive change: chown -R owner directory
5. Verify changes with ls -l

**Hint:** Use `chown`, `chgrp`, `sudo` for permission.

---

## Exercise 6: Configure Sudo Access

**Tasks:**
1. Create new user
2. Add to sudo group
3. Test sudo privileges
4. View sudoers file (visudo)
5. Configure sudo without password (advanced)

**Hint:** Use `usermod -aG sudo`, `sudo -l`, `visudo`.

---

## Exercise 7: Special Permissions

**Tasks:**
1. Understand setuid, setgid, sticky bit
2. Find files with setuid
3. Set setuid on file
4. Set sticky bit on directory
5. Verify special permissions

**Hint:** Use `chmod 4755` (setuid), `chmod 2755` (setgid), `chmod 1755` (sticky).

---

## Exercise 8: Directory Permissions

**Tasks:**
1. Create directory structure
2. Set directory permissions
3. Understand execute bit on dirs
4. Set sticky bit on shared dir
5. Test access with different users

**Hint:** Execute bit = traverse directory. Sticky = only owner can delete.

---

## Exercise 9: Umask and Default Permissions

**Tasks:**
1. Check current umask
2. Understand umask calculation
3. Create file and note permissions
4. Change umask temporarily
5. Create another file and compare

**Hint:** Use `umask`, default octal - umask = file permissions.

---

## Exercise 10: Security and Best Practices

Create a real-world scenario.

**Tasks:**
1. Create team project structure
2. Create team group
3. Add multiple users to group
4. Set group permissions
5. Test collaboration access
6. Document security model

**Hint:** Combine useradd, groupadd, chmod, chown with realistic structure.
