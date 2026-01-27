# Linux Configuration: Exercises

Complete these exercises to master configuration management.

## Exercise 1: Find Configuration Files

**Tasks:**
1. List all .conf files in /etc
2. Find SSH configuration
3. Find nginx configuration
4. Count total config files
5. Search for specific setting

**Hint:** Use `find /etc -name "*.conf"`, `locate sshd_config`.

---

## Exercise 2: Understand Config File Format

**Tasks:**
1. View SSH config without comments
2. Identify active settings
3. Find default values
4. Show config with line numbers
5. Compare with man page defaults

**Hint:** Use `grep -v "^#"`, `grep -v "^$"`, `cat -n`.

---

## Exercise 3: Create Safe Backups

**Tasks:**
1. Backup SSH config
2. Backup sudoers file
3. Timestamp backups
4. Store in separate location
5. Verify backup integrity

**Hint:** Use `cp`, date command, `diff` for verification.

---

## Exercise 4: Edit Configuration Files

**Tasks:**
1. Create test config file
2. Edit with nano
3. Save changes
4. View edited file
5. Restore from backup

**Hint:** Use `nano`, test files in /tmp first.

---

## Exercise 5: Validate Configuration Syntax

**Tasks:**
1. Create invalid config
2. Validate with tool
3. Fix syntax errors
4. Re-validate
5. Apply valid config

**Hint:** Use `sshd -t`, service-specific validators.

---

## Exercise 6: Understand Config Directories

**Tasks:**
1. View /etc directory structure
2. Find drop-in config directories (.d)
3. List all .d directories
4. Understand precedence
5. View merged configuration

**Hint:** Use `ls -la /etc/`, `find /etc -type d -name "*.d"`.

---

## Exercise 7: Reload vs Restart Services

**Tasks:**
1. Edit service configuration
2. Reload service (apply without restart)
3. Restart service (full restart)
4. Verify changes applied
5. Monitor startup time difference

**Hint:** Use `systemctl reload` vs `systemctl restart`.

---

## Exercise 8: Manage Drop-in Configurations

**Tasks:**
1. Create drop-in directory
2. Create drop-in config file
3. Understand override behavior
4. Verify merged result
5. Test override precedence

**Hint:** Create `/etc/systemd/system/service.d/override.conf`.

---

## Exercise 9: Search and Filter Configs

**Tasks:**
1. Find all listen ports in configs
2. Find all enabled services
3. Grep across multiple config files
4. Show config with context
5. Count occurrences of setting

**Hint:** Use `grep -r`, `grep -C`, `grep -c`.

---

## Exercise 10: Configuration Best Practices

Create a safe config management workflow.

**Tasks:**
1. Backup current configs
2. Create change checklist
3. Validate before applying
4. Test in safe environment
5. Document changes made

**Hint:** Use cp, diff, scripts for consistency.
