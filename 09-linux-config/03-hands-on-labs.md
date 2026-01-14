# Module 09: Linux Configuration - Hands-On Labs

8 practical labs covering configuration management scenarios.

**Total Lab Time**: 280 minutes (4.7 hours)

---

## Lab 1: Exploring the /etc Directory Structure

**Difficulty**: Beginner | **Time**: 30 minutes

### Goal
Understand the organization of system configuration files in /etc directory.

### Setup

```bash
# No special setup needed - examine existing system
```

### Steps

1. **View /etc directory**
   ```bash
   ls -la /etc | head -20
   # Shows top-level files and directories
   ```

2. **Count configuration files**
   ```bash
   find /etc -type f | wc -l
   # Hundreds of config files!
   ```

3. **Explore common subdirectories**
   ```bash
   # Subdirectories with specific purposes
   ls /etc/ssh/
   ls /etc/default/
   ls /etc/systemd/system/
   ls /etc/sysctl.d/
   ```

4. **List SSH configuration files**
   ```bash
   ls -la /etc/ssh/
   # sshd_config, ssh_config, authorized_keys, etc.
   ```

5. **View filesystem mount table**
   ```bash
   cat /etc/fstab
   # Shows which filesystems mount at boot
   ```

6. **Find all .conf files**
   ```bash
   find /etc -name "*.conf" | head -20
   ```

7. **Count by directory**
   ```bash
   find /etc -type f | cut -d/ -f2 | sort | uniq -c | sort -rn
   # See which /etc subdirectories have most files
   ```

8. **Identify critical system files**
   ```bash
   ls -la /etc/passwd /etc/group /etc/shadow /etc/sudoers
   # Core user/group/permission configuration
   ```

### Expected Output

```
$ ls -la /etc | head -20
total 1234
drwxr-xr-x  156 root root   12288 Jan 15 10:00 .
drwxr-xr-x   21 root root    4096 Jan 15 09:45 ..
-rw-r--r--    1 root root      15 Jan 15 09:45 hostname
-rw-r--r--    1 root root    1234 Jan 15 09:45 hosts
drwxr-xr-x    2 root root    4096 Jan 15 10:00 ssh
drwxr-xr-x    2 root root    4096 Jan 15 10:00 sysctl.d
drwxr-xr-x    5 root root    4096 Jan 15 10:00 systemd
...

$ find /etc -type f | wc -l
847

$ ls /etc/ssh/
moduli  ssh_config  sshd_config  ssh_host_ecdsa_key  ssh_host_ecdsa_key.pub
```

### Verification Checklist

- [ ] Can list contents of /etc
- [ ] Know what major subdirectories contain
- [ ] Found SSH configuration files
- [ ] Identified critical system files (passwd, group, shadow)
- [ ] Found .conf and .d directories
- [ ] Understand filesystem mount table in fstab
- [ ] Can search for specific file types

### Cleanup

```bash
# No cleanup needed - only viewed files
```

---

## Lab 2: Safely Viewing and Editing Configuration Files

**Difficulty**: Beginner | **Time**: 30 minutes

### Goal
Learn to safely view and edit configuration files without breaking your system.

### Setup

```bash
# Create test directory
mkdir -p ~/config-test
cd ~/config-test

# Copy a non-critical config for testing
cp /etc/hostname hostname.test
cp /etc/hosts hosts.test
```

### Steps

1. **View file without comments**
   ```bash
   # See active configuration only
   grep -v "^#" hosts.test | grep -v "^$"
   ```

2. **View file with line numbers**
   ```bash
   cat -n hosts.test
   ```

3. **Use less for large files**
   ```bash
   # Try: less hosts.test
   # Press: / to search, n for next, q to quit
   ```

4. **Edit file with nano**
   ```bash
   nano hosts.test
   # Add a comment: # Test entry
   # Save: Ctrl+X, then Y, then Enter
   ```

5. **Compare original and modified**
   ```bash
   diff /etc/hosts hosts.test
   # Shows what changed
   ```

6. **Create backup before editing**
   ```bash
   cp hosts.test hosts.test.backup
   ```

7. **Use sed to modify**
   ```bash
   # Replace localhost with 127.0.0.1 (dry-run first)
   sed 's/localhost/127.0.0.1/' hosts.test | head -5
   
   # Then apply with backup
   sed -i.backup2 's/localhost/127.0.0.1/' hosts.test
   ```

8. **Verify the change**
   ```bash
   diff hosts.test.backup2 hosts.test
   # Shows exact changes
   ```

### Expected Output

```
$ grep -v "^#" hosts.test | grep -v "^$"
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback

$ cat -n hosts.test
     1	127.0.0.1	localhost
     2	::1		localhost ip6-localhost ip6-loopback
     3	# Test entry

$ diff hosts.test hosts.test.backup
1c1
< 127.0.0.1	127.0.0.1
> 127.0.0.1	localhost
```

### Verification Checklist

- [ ] Can view active configuration (no comments)
- [ ] Can use nano editor
- [ ] Can use diff to compare files
- [ ] Can backup before editing
- [ ] Can use sed for replacements
- [ ] Understand what changed with diff
- [ ] Know how to keep backup with -i.bak

### Cleanup

```bash
# Remove test directory
rm -rf ~/config-test
```

---

## Lab 3: Viewing and Modifying System Parameters

**Difficulty**: Beginner | **Time**: 30 minutes

### Goal
Learn to view and modify kernel parameters using sysctl.

### Setup

```bash
# No special setup needed - kernel parameters always available
```

### Steps

1. **View all kernel parameters**
   ```bash
   sysctl -a | head -20
   # Shows first 20 parameters
   ```

2. **Search for specific parameter**
   ```bash
   sysctl net.ipv4.tcp_fin_timeout
   # Shows current value
   ```

3. **Search for related parameters**
   ```bash
   sysctl -a | grep tcp | head -10
   # All TCP-related parameters
   ```

4. **View network parameters**
   ```bash
   sysctl net.ipv4.*
   ```

5. **View memory parameters**
   ```bash
   sysctl vm.*
   ```

6. **Modify parameter temporarily**
   ```bash
   # This changes until reboot
   sudo sysctl -w net.ipv4.tcp_fin_timeout=15
   
   # Verify change
   sysctl net.ipv4.tcp_fin_timeout
   # Should show: net.ipv4.tcp_fin_timeout = 15
   ```

7. **Restore original value**
   ```bash
   sudo sysctl -w net.ipv4.tcp_fin_timeout=20
   ```

8. **View all changes that would be applied**
   ```bash
   # Look at sysctl configuration
   cat /etc/sysctl.conf
   
   # Or custom configs
   ls /etc/sysctl.d/
   ```

### Expected Output

```
$ sysctl net.ipv4.tcp_fin_timeout
net.ipv4.tcp_fin_timeout = 20

$ sudo sysctl -w net.ipv4.tcp_fin_timeout=15
net.ipv4.tcp_fin_timeout = 15

$ sysctl net.ipv4.tcp_fin_timeout
net.ipv4.tcp_fin_timeout = 15

$ sysctl vm.*
vm.admin_reserve_kbytes = 8192
vm.compact_unevictable_allowed = 1
vm.dirty_background_bytes = 0
...
```

### Verification Checklist

- [ ] Can view all kernel parameters
- [ ] Can search for specific parameter
- [ ] Can view parameter value with sysctl
- [ ] Can modify temporarily with sysctl -w
- [ ] Can verify change took effect
- [ ] Know changes are lost after reboot (unless in config file)
- [ ] Can find configuration files

### Cleanup

```bash
# No cleanup needed - only viewed/modified temporarily
# All changes revert at reboot anyway
```

---

## Lab 4: Configuration Backup and Restore

**Difficulty**: Intermediate | **Time**: 35 minutes

### Goal
Create comprehensive backups and practice restoring them.

### Setup

```bash
# Create backup directory
mkdir -p ~/backups
cd ~/backups
```

### Steps

1. **Create simple file backup**
   ```bash
   sudo cp /etc/hostname /etc/hostname.backup
   ls -la /etc/hostname*
   ```

2. **Create timestamped backup**
   ```bash
   sudo cp /etc/hosts /etc/hosts.$(date +%Y%m%d-%H%M%S)
   ls -la /etc/hosts*
   ```

3. **Backup directory with tar**
   ```bash
   sudo tar czf ssh-backup-$(date +%Y%m%d).tar.gz /etc/ssh
   ls -lh ssh-backup-*.tar.gz
   ```

4. **List tar contents**
   ```bash
   tar tzf ssh-backup-*.tar.gz | head -20
   # Shows what's in the backup
   ```

5. **Create selective backup (exclude sensitive files)**
   ```bash
   sudo tar czf etc-partial-backup.tar.gz \
     --exclude="/etc/ssl/private" \
     --exclude="/etc/shadow" \
     /etc | head -100
   ```

6. **Test restore to different location**
   ```bash
   # Don't restore to real location yet - test first
   mkdir -p /tmp/restore-test
   sudo tar xzf ssh-backup-*.tar.gz -C /tmp/restore-test
   ls -la /tmp/restore-test/etc/ssh/
   ```

7. **Modify a config file**
   ```bash
   # Make change to system
   echo "# Test change" | sudo tee -a /etc/hostname
   cat /etc/hostname
   ```

8. **Restore from backup**
   ```bash
   # Restore the modified file
   sudo tar xzf ssh-backup-*.tar.gz -C / etc/ssh/sshd_config
   # Or restore specific file from simple backup
   sudo cp /etc/hosts.backup /etc/hosts
   ```

### Expected Output

```
$ sudo tar czf ssh-backup-$(date +%Y%m%d).tar.gz /etc/ssh
$ ls -lh ssh-backup-*.tar.gz
-rw-r--r-- 1 root root 12K Jan 15 10:30 ssh-backup-20240115.tar.gz

$ tar tzf ssh-backup-20240115.tar.gz | head -10
etc/ssh/
etc/ssh/moduli
etc/ssh/ssh_config
etc/ssh/sshd_config
...

$ mkdir -p /tmp/restore-test && sudo tar xzf ssh-backup-20240115.tar.gz -C /tmp/restore-test
$ ls -la /tmp/restore-test/etc/ssh/
```

### Verification Checklist

- [ ] Created simple file backup
- [ ] Created timestamped backups
- [ ] Created directory backup with tar
- [ ] Listed tar contents
- [ ] Created selective backup with exclusions
- [ ] Tested restore to alternate location
- [ ] Modified configuration
- [ ] Successfully restored from backup
- [ ] Verified restored files match original

### Cleanup

```bash
# Clean up test files
rm -rf /tmp/restore-test
rm -f /etc/hostname.backup /etc/hosts.*
sudo rm -f ssh-backup-*.tar.gz etc-partial-backup.tar.gz
```

---

## Lab 5: Validating Configuration Syntax

**Difficulty**: Intermediate | **Time**: 30 minutes

### Goal
Learn to validate configuration syntax before applying changes.

### Setup

```bash
# Create test config directory
mkdir -p ~/config-validation
cd ~/config-validation

# Copy SSH config for testing
cp /etc/ssh/sshd_config sshd_config.test
```

### Steps

1. **Validate SSH configuration**
   ```bash
   # Correct configuration
   sudo sshd -t -f sshd_config.test
   # No output = success!
   ```

2. **Introduce intentional error**
   ```bash
   # Create bad config
   echo "BadDirective yes" >> sshd_config.test
   
   # Try to validate
   sudo sshd -t -f sshd_config.test
   # Shows: error on line X
   ```

3. **Fix the error**
   ```bash
   # Remove bad line
   sed -i '/BadDirective/d' sshd_config.test
   
   # Validate again
   sudo sshd -t -f sshd_config.test
   # Should succeed now
   ```

4. **Test with Nginx (if installed)**
   ```bash
   # Validate nginx config (if it exists)
   if command -v nginx &> /dev/null; then
     sudo nginx -t
   fi
   ```

5. **Test JSON validation**
   ```bash
   # Create test JSON
   cat > test.json << 'EOF'
   {
     "name": "test",
     "port": 8080
   }
   EOF
   
   # Validate JSON
   python3 -m json.tool test.json
   ```

6. **Test bad JSON**
   ```bash
   # Create invalid JSON (missing quote)
   cat > test-bad.json << 'EOF'
   {
     "name: "test",
     "port": 8080
   }
   EOF
   
   # Try to validate
   python3 -m json.tool test-bad.json
   # Shows JSON error
   ```

7. **Use diff to check differences**
   ```bash
   # Compare modified and original
   diff /etc/ssh/sshd_config sshd_config.test
   # Should be minimal if only testing
   ```

8. **Validate YAML (if available)**
   ```bash
   # Create YAML
   cat > test.yaml << 'EOF'
   name: test
   port: 8080
   EOF
   
   # Validate
   python3 -c "import yaml; yaml.safe_load(open('test.yaml')); print('Valid YAML')"
   ```

### Expected Output

```
$ sudo sshd -t -f sshd_config.test
(no output = good)

$ echo "BadDirective yes" >> sshd_config.test
$ sudo sshd -t -f sshd_config.test
/etc/ssh/sshd_config.test: line 112: Bad configuration option: "BadDirective"
/etc/ssh/sshd_config.test: terminating, 1 bad configuration options

$ python3 -m json.tool test.json
{
    "name": "test",
    "port": 8080
}

$ python3 -m json.tool test-bad.json
Expecting value: line 2 column 10 (char 10)
```

### Verification Checklist

- [ ] Can validate SSH configuration syntax
- [ ] Can identify syntax errors
- [ ] Can fix errors
- [ ] Can validate JSON format
- [ ] Can catch malformed JSON
- [ ] Can validate YAML format
- [ ] Understand importance of validation
- [ ] Know multiple validation tools

### Cleanup

```bash
# Remove test files
rm -rf ~/config-validation
```

---

## Lab 6: Using sed and awk for Configuration Modification

**Difficulty**: Intermediate | **Time**: 40 minutes

### Goal
Learn to use sed and awk for reliable configuration file modifications.

### Setup

```bash
# Create test directory
mkdir -p ~/sed-awk-test
cd ~/sed-awk-test

# Copy test file
cp /etc/ssh/sshd_config sshd_config.test
```

### Steps

1. **View lines matching pattern with sed**
   ```bash
   # Show lines containing "Port"
   sed -n '/Port/p' sshd_config.test
   ```

2. **Replace first occurrence on each line**
   ```bash
   # Replace (dry-run - no output modification)
   sed 's/^#Port 22/Port 2222/' sshd_config.test | grep Port
   ```

3. **Replace all occurrences with backup**
   ```bash
   # Make backup and change
   sed -i.bak 's/^#PasswordAuthentication yes/PasswordAuthentication no/' sshd_config.test
   
   # Show difference
   diff sshd_config.test.bak sshd_config.test
   ```

4. **Delete lines matching pattern**
   ```bash
   # Remove comment lines
   sed '/^#/d' sshd_config.test | head -20
   ```

5. **Remove empty lines**
   ```bash
   # Remove blank lines
   sed '/^$/d' sshd_config.test | wc -l
   ```

6. **Use awk to show specific fields**
   ```bash
   # Show only directive names (first field)
   awk -F' ' '{print $1}' sshd_config.test | grep -v "^$" | sort -u | head -20
   ```

7. **Use awk to count directives**
   ```bash
   # Count different directive types
   awk -F' ' '{print $1}' sshd_config.test | grep -v "^#" | grep -v "^$" | sort | uniq -c | sort -rn
   ```

8. **Combine sed and awk**
   ```bash
   # Remove comments, then parse
   sed '/^#/d' sshd_config.test | sed '/^$/d' | awk '{print $1}' | sort -u
   ```

### Expected Output

```
$ sed -n '/Port/p' sshd_config.test
#Port 22

$ sed 's/^#Port 22/Port 2222/' sshd_config.test | grep Port
Port 2222

$ diff sshd_config.test.bak sshd_config.test
5c5
< #PasswordAuthentication yes
---
> PasswordAuthentication no

$ sed '/^#/d' sshd_config.test | head -20
(shows active config only)

$ awk -F' ' '{print $1}' sshd_config.test | sort -u | head -20
Accept
Address
Ciphers
Host
...
```

### Verification Checklist

- [ ] Can use sed to show matching lines
- [ ] Can replace text with sed
- [ ] Can delete lines with sed
- [ ] Can use -i.bak for backup
- [ ] Can verify changes with diff
- [ ] Can use awk to extract fields
- [ ] Can combine sed and awk
- [ ] Understand piping between tools

### Cleanup

```bash
# Remove test directory
rm -rf ~/sed-awk-test
```

---

## Lab 7: Creating Custom Configuration Files

**Difficulty**: Intermediate | **Time**: 30 minutes

### Goal
Create custom configuration files from scratch.

### Setup

```bash
# Create custom config directory
mkdir -p ~/custom-configs
cd ~/custom-configs
```

### Steps

1. **Create simple key-value config**
   ```bash
   cat > app.conf << 'EOF'
   # Application Configuration
   # Created: $(date)

   # Database settings
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=appuser
   DB_PASS=secret123

   # Server settings
   SERVER_PORT=8080
   SERVER_WORKERS=4
   DEBUG=false
   EOF
   ```

2. **Create INI-style config**
   ```bash
   cat > app.ini << 'EOF'
   [database]
   host = localhost
   port = 5432
   user = appuser

   [server]
   port = 8080
   workers = 4
   debug = false

   [logging]
   level = INFO
   file = /var/log/app.log
   EOF
   ```

3. **Create YAML config**
   ```bash
   cat > app.yaml << 'EOF'
   database:
     host: localhost
     port: 5432
     user: appuser
     password: secret123

   server:
     port: 8080
     workers: 4
     debug: false

   logging:
     level: INFO
     file: /var/log/app.log
   EOF
   ```

4. **Create JSON config**
   ```bash
   cat > app.json << 'EOF'
   {
     "database": {
       "host": "localhost",
       "port": 5432,
       "user": "appuser"
     },
     "server": {
       "port": 8080,
       "workers": 4,
       "debug": false
     }
   }
   EOF
   ```

5. **Validate each format**
   ```bash
   # INI is text only - check syntax manually
   cat app.ini
   
   # YAML validation
   python3 -c "import yaml; yaml.safe_load(open('app.yaml')); print('YAML valid')"
   
   # JSON validation
   python3 -m json.tool app.json
   ```

6. **Create shell-sourced config**
   ```bash
   cat > app-env << 'EOF'
   # Shell configuration file (can be sourced)
   export APP_NAME="MyApp"
   export APP_VERSION="1.0"
   export APP_PORT=8080
   export APP_DEBUG=false
   EOF
   
   # Test sourcing
   source app-env
   echo "App: $APP_NAME v$APP_VERSION on port $APP_PORT"
   ```

7. **Create merged configuration**
   ```bash
   # Create base config
   cat > defaults.conf << 'EOF'
   # Default configuration
   PORT=8080
   WORKERS=4
   TIMEOUT=30
   EOF
   
   # Create custom overrides
   cat > custom.conf << 'EOF'
   # Custom overrides
   PORT=9000
   EOF
   
   # Merge (custom overrides defaults)
   cat defaults.conf custom.conf | sort -u
   ```

8. **Create config with includes**
   ```bash
   cat > main.conf << 'EOF'
   # Main configuration
   PORT=8080
   WORKERS=4
   
   # Include additional configs
   # Note: This pattern varies by application
   # Some apps support: include other.conf
   # Others need manual concatenation
   EOF
   ```

### Expected Output

```
$ python3 -c "import yaml; yaml.safe_load(open('app.yaml')); print('YAML valid')"
YAML valid

$ python3 -m json.tool app.json
{
    "database": {
        "host": "localhost",
        "port": 5432,
        "user": "appuser"
    },
    ...
}

$ source app-env && echo "App: $APP_NAME v$APP_VERSION on port $APP_PORT"
App: MyApp v1.0 on port 8080

$ cat defaults.conf custom.conf | sort -u
PORT=9000
TIMEOUT=30
WORKERS=4
```

### Verification Checklist

- [ ] Created key-value config
- [ ] Created INI-style config
- [ ] Created YAML config
- [ ] Created JSON config
- [ ] Created shell-sourced config
- [ ] Validated YAML format
- [ ] Validated JSON format
- [ ] Sourced shell config successfully

### Cleanup

```bash
# Remove test directory
rm -rf ~/custom-configs
```

---

## Lab 8: Configuration Testing and Troubleshooting

**Difficulty**: Intermediate | **Time**: 40 minutes

### Goal
Practice identifying and fixing configuration issues.

### Setup

```bash
# Create test directory
mkdir -p ~/config-troubleshoot
cd ~/config-troubleshoot

# Copy SSH config for testing
cp /etc/ssh/sshd_config sshd_test
```

### Steps

1. **Check current configuration is valid**
   ```bash
   # Original should be valid
   sudo sshd -t -f sshd_test
   ```

2. **Create common mistake #1: Typo**
   ```bash
   # Misspell directive
   sed -i 's/^HostKey/HostKye/' sshd_test
   
   # Try to validate
   sudo sshd -t -f sshd_test
   # Should show error about HostKye
   ```

3. **Fix the typo**
   ```bash
   # Correct the typo
   sed -i 's/HostKye/HostKey/' sshd_test
   
   # Validate
   sudo sshd -t -f sshd_test
   ```

4. **Create common mistake #2: Wrong value format**
   ```bash
   # Reset
   cp /etc/ssh/sshd_config sshd_test
   
   # Change Port to non-numeric
   sed -i 's/^#Port 22/Port twentytwo/' sshd_test
   
   # Validate
   sudo sshd -t -f sshd_test
   # Should error on invalid port value
   ```

5. **Fix and use valid value**
   ```bash
   sed -i 's/Port twentytwo/Port 2222/' sshd_test
   sudo sshd -t -f sshd_test
   ```

6. **Create mistake #3: Missing or wrong quotes**
   ```bash
   # Add a Banner line with unquoted spaces (may cause issues)
   echo "Banner /etc/ssh/banner with spaces" >> sshd_test
   
   # Try to validate
   sudo sshd -t -f sshd_test
   # May show error depending on SSH version
   ```

7. **Fix with proper quoting**
   ```bash
   sed -i 's/Banner .*with spaces/Banner "\/etc\/ssh\/banner with spaces"/' sshd_test
   sudo sshd -t -f sshd_test
   ```

8. **Compare with original to find differences**
   ```bash
   # See what changed from original
   diff /etc/ssh/sshd_config sshd_test
   
   # Count differences
   diff /etc/ssh/sshd_config sshd_test | wc -l
   ```

### Expected Output

```
$ sudo sshd -t -f sshd_test
/etc/ssh/sshd_test: line 20: unsupported option "HostKye".

$ sed -i 's/HostKye/HostKey/' sshd_test
$ sudo sshd -t -f sshd_test
(success - no output)

$ sudo sshd -t -f sshd_test
sshd_test: line 5: Bad port 'twentytwo'

$ diff /etc/ssh/sshd_config sshd_test
20a21
> Banner "/etc/ssh/banner with spaces"
```

### Verification Checklist

- [ ] Can validate configuration correctly
- [ ] Can identify typos
- [ ] Can find invalid values
- [ ] Can fix formatting issues
- [ ] Can use diff to find changes
- [ ] Can recover from errors
- [ ] Understand error messages
- [ ] Know proper config value formats

### Cleanup

```bash
# Remove test directory
rm -rf ~/config-troubleshoot
```

---

## Summary

After completing all 8 labs, you can:

✓ Navigate and understand /etc directory structure  
✓ Safely view and edit configuration files  
✓ Modify kernel parameters with sysctl  
✓ Create comprehensive backups  
✓ Validate configuration syntax  
✓ Use sed and awk for modifications  
✓ Create custom configuration files  
✓ Identify and fix configuration problems  

**Total Time**: 280 minutes (4.7 hours) of hands-on learning

**Next Step**: Explore the production scripts in [scripts/README.md](scripts/README.md)
