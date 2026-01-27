# Linux Configuration: Solutions

## Exercise 1: Find Configuration Files

**Solution:**

```bash
# List all .conf files
find /etc -name "*.conf" 2>/dev/null | head -20

# SSH configuration
find /etc -name "*ssh*" -type f
# Output: /etc/ssh/sshd_config, /etc/ssh/ssh_config

# Nginx config
find /etc -name "*nginx*" -type f
# Output: /etc/nginx/nginx.conf

# Count config files
find /etc -name "*.conf" 2>/dev/null | wc -l
# Output: 145

# Search for specific setting
grep -r "Port 22" /etc/ssh/
# Output: /etc/ssh/sshd_config:Port 22
```

**Explanation:** `-name` filters by filename. `/dev/null` suppresses permission errors.

---

## Exercise 2: Understand Config File Format

**Solution:**

```bash
# SSH config without comments/blanks
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
# Output:
# Port 22
# PermitRootLogin prohibit-password
# PubkeyAuthentication yes

# Show active settings with line numbers
cat -n /etc/ssh/sshd_config | grep -v "^[[:space:]]*[0-9]*[[:space:]]*#"

# Find defaults in manual
man sshd_config | head -50

# Count configuration lines
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$" | wc -l
# Output: 7 active settings
```

**Explanation:** `^#` = line starting with #. `^$` = empty line.

---

## Exercise 3: Create Safe Backups

**Solution:**

```bash
# Simple backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Timestamped backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d_%H%M%S).bak

# Backup multiple files
for file in /etc/ssh/sshd_config /etc/sudoers; do
  sudo cp "$file" "$file.bak.$(date +%Y%m%d)"
done

# Verify backup
diff /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
# No output = identical

# List backups
ls -lh /etc/ssh/sshd_config*
```

**Explanation:** Date format: `%Y%m%d_%H%M%S` = YYYYMMDD_HHMMSS.

---

## Exercise 4: Edit Configuration Files

**Solution:**

```bash
# Create test config
cat > /tmp/test.conf << 'EOF'
# Sample config
setting1=value1
setting2=value2
# setting3=disabled
EOF

# Edit with nano
nano /tmp/test.conf
# Edit, save (Ctrl+O), exit (Ctrl+X)

# View edited file
cat /tmp/test.conf

# Restore from backup
cp /tmp/test.conf.bak /tmp/test.conf

# Or undo with git if available
git checkout /tmp/test.conf
```

**Explanation:** Always test edits in /tmp first, not in /etc.

---

## Exercise 5: Validate Configuration Syntax

**Solution:**

```bash
# Create invalid config
echo "PermitRootLogin yes invalid_option" > /tmp/bad_sshd.conf

# Validate SSH config
sudo sshd -t -f /tmp/bad_sshd.conf
# Output: line 1: Unsupported option "invalid_option"

# Fix the config
echo "PermitRootLogin no" > /tmp/good_sshd.conf

# Validate fixed config
sudo sshd -t -f /tmp/good_sshd.conf
# Output: (empty = valid)

# Nginx validation
sudo nginx -t
# Output: nginx: configuration file test is successful

# JSON validation
python3 -m json.tool config.json > /dev/null
```

**Explanation:** Service-specific validators: `sshd -t`, `nginx -t`, `apache2ctl -t`.

---

## Exercise 6: Understand Config Directories

**Solution:**

```bash
# View /etc structure
ls -la /etc/ | head -20

# Find all .d directories
find /etc -maxdepth 1 -type d -name "*.d" | sort
# Output:
# /etc/systemd.d
# /etc/sudoers.d
# /etc/ssh/sshd_config.d

# List drop-in configs
ls -la /etc/systemd/system/ssh.service.d/

# View merged config
systemd-analyze cat-config sshd

# Precedence: single file overridden by .d files
# Example: /etc/ssh/sshd_config + /etc/ssh/sshd_config.d/*.conf
```

**Explanation:** `.d` directories allow modular configs without editing main file.

---

## Exercise 7: Reload vs Restart Services

**Solution:**

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
# Change: Port 2222

# Reload (apply without restart - faster)
sudo systemctl reload sshd
# Active connections stay open

# Restart (full restart - slower)
sudo systemctl restart sshd
# All connections drop briefly

# Verify change
sudo ss -tlnp | grep sshd
# Output: LISTEN ... :2222 ... sshd

# Monitor startup time
time sudo systemctl restart sshd
# real 0m0.234s (example)

# Reload time is faster than restart
time sudo systemctl reload sshd
# real 0m0.123s (faster)
```

**Explanation:** Reload = apply changes, restart = stop then start (might drop connections).

---

## Exercise 8: Manage Drop-in Configurations

**Solution:**

```bash
# Create drop-in directory
sudo mkdir -p /etc/systemd/system/ssh.service.d/

# Create override file
sudo tee /etc/systemd/system/ssh.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/sbin/sshd -D -p 2222
EOF

# Reload systemd
sudo systemctl daemon-reload

# Verify merged config
systemd-analyze cat-config ssh.service
# Shows main config + override

# Start service
sudo systemctl restart ssh

# Check listening port
sudo ss -tlnp | grep sshd
# Output: Port 2222 (from override)
```

**Explanation:** Drop-in overrides main config. `ExecStart=` clears previous, then set new value.

---

## Exercise 9: Search and Filter Configs

**Solution:**

```bash
# Find all listen ports
grep -r "Port\|Listen" /etc/ssh/ /etc/nginx/ 2>/dev/null
# Output: /etc/ssh/sshd_config:Port 22

# Find enabled services
systemctl list-unit-files | grep enabled
# Output: ssh.service enabled

# Grep with context (3 lines before/after)
grep -C 3 "PermitRootLogin" /etc/ssh/sshd_config

# Count occurrences
grep -c "^[^#]" /etc/ssh/sshd_config
# Output: 7

# Find files modified in last day
find /etc -mtime -1 -type f -name "*.conf"
```

**Explanation:** `-r` = recursive. `-C` = context. `-c` = count.

---

## Exercise 10: Configuration Best Practices

**Solution:**

```bash
# Backup all configs
sudo tar -czf ~/config_backup_$(date +%Y%m%d).tar.gz /etc/

# Create change checklist
cat > change_checklist.txt << 'EOF'
[ ] Backup current config
[ ] Validate new config
[ ] Test in non-prod
[ ] Document changes
[ ] Apply to production
[ ] Verify changes
[ ] Monitor for issues
EOF

# Safe workflow script
#!/bin/bash
SERVICE="sshd"
CONFIG="/etc/ssh/sshd_config"

# Backup
sudo cp $CONFIG $CONFIG.bak

# Edit
sudo nano $CONFIG

# Validate
if sudo sshd -t; then
  echo "Config valid, reloading..."
  sudo systemctl reload $SERVICE
else
  echo "Config invalid, reverting..."
  sudo cp $CONFIG.bak $CONFIG
fi
```

**Explanation:** Best practices: backup, validate, test, document, monitor.
