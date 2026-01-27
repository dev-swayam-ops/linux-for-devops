# Security and Firewall: Solutions

## Exercise 1: Firewall Basics with UFW

**Solution:**

```bash
# Check firewall status
sudo ufw status
# Output: Status: inactive

# Enable firewall
sudo ufw enable
# Output: Firewall is active and enabled on system startup

# Verify enabled
sudo ufw status verbose
# Output: Status: active (Logging: on (low), Default: deny (incoming), allow (outgoing))

# Show active rules
sudo ufw status numbered
# Output list with numbers

# Default policies:
# Incoming: deny (block by default)
# Outgoing: allow (allow by default)
```

**Explanation:** UFW = user-friendly wrapper around iptables. Enable = automatic startup.

---

## Exercise 2: Allow Critical Services

**Solution:**

```bash
# Allow SSH (critical - do this first!)
sudo ufw allow ssh
# or
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow http
# or
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow https
# or
sudo ufw allow 443/tcp

# List allowed rules
sudo ufw status numbered
# Output:
#      To                         Action
# --                         ------
# [ 1] 22/tcp (ssh)            ALLOW IN    Anywhere
# [ 2] 80/tcp (http)           ALLOW IN    Anywhere
# [ 3] 443/tcp (https)         ALLOW IN    Anywhere

# Test connectivity
curl http://localhost:80
# or test from remote
```

**Explanation:** Always allow SSH first. Services use standard ports (80, 443, 22).

---

## Exercise 3: Block and Deny Rules

**Solution:**

```bash
# Deny specific port (example: RDP)
sudo ufw deny 3389

# Block unwanted service
sudo ufw deny 23/tcp
# (telnet - insecure)

# Delete a rule
sudo ufw delete deny 3389
# or by number
sudo ufw delete 2

# Show numbered rules
sudo ufw status numbered
# Output:
#      To                         Action
# [ 1] 22/tcp                    ALLOW IN
# [ 2] 80/tcp                    ALLOW IN
# [ 3] 443/tcp                   ALLOW IN
# [ 4] 3389                      DENY IN

# Rule priority: first match wins
# So allow rules before deny rules matter
```

**Explanation:** Rules processed top-to-bottom. First match wins.

---

## Exercise 4: Source-Based Firewall Rules

**Solution:**

```bash
# Allow SSH from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Block traffic from IP range
sudo ufw deny from 10.0.0.0/8

# Allow to specific interface
sudo ufw allow in on eth0 to any port 80

# Combine source, port, protocol
sudo ufw allow from 192.168.1.0/24 to any port 443 proto tcp

# Show all rules (verbose)
sudo ufw status numbered

# Test from specific IP
ssh -p 22 user@target

# Numbered rules allow deletion
sudo ufw delete 4
```

**Explanation:** Source rules restrict by IP/subnet. More specific rules = higher priority.

---

## Exercise 5: Check Open Ports

**Solution:**

```bash
# List listening ports with process info
sudo ss -tlnp
# Output:
# State  Recv-Q Send-Q Local Address:Port Peer   Foreign Address:Port
# LISTEN 0      128    0.0.0.0:22   *      users:(("sshd",pid=1234))
# LISTEN 0      511    0.0.0.0:80   *      users:(("nginx",pid=5678))

# Alternative with netstat
sudo netstat -tlnp
# Same output, older tool

# Check specific port
sudo ss -tlnp | grep 22
# Output: SSH on port 22

# Find unauthorized ports
sudo ss -tlnp | grep LISTEN | awk '{print $4}' | sort

# Match to firewall rules
sudo ufw status | grep ALLOW

# Compare listening vs allowed
# Should be subset: allowed rules >= listening ports
```

**Explanation:** `ss` = newer. `netstat` = older. `-t` = TCP, `-l` = listening, `-n` = numeric, `-p` = process.

---

## Exercise 6: Default Policies

**Solution:**

```bash
# Set default deny incoming (security first)
sudo ufw default deny incoming
# Blocks all incoming unless explicitly allowed

# Set default allow outgoing (normal operation)
sudo ufw default allow outgoing
# Allows all outgoing unless explicitly denied

# Show current defaults
sudo ufw status | grep Default
# Output: Default: deny (incoming), allow (outgoing)

# Implications:
# Deny incoming = safe against port scans
# Allow outgoing = services can initiate connections

# Test inbound (should fail without rules)
telnet localhost 9999
# Connection refused (denied by default)

# Test outbound (should work)
ping 8.8.8.8
# ICMP packets allowed (unless blocked)

# Common default pattern:
# - Deny all incoming
# - Allow all outgoing
# - Whitelist specific inbound ports
```

**Explanation:** Principle of least privilege: deny by default, allow as needed.

---

## Exercise 7: SSH Security Hardening

**Solution:**

```bash
# Before: ensure SSH allowed in firewall!
sudo ufw allow 2222/tcp
# (if changing from 22)

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Change port to non-standard (add line):
Port 2222

# Disable password auth (uncomment/change):
PubkeyAuthentication yes
PasswordAuthentication no

# Disable root login:
PermitRootLogin no

# Allow specific users only:
AllowUsers user1 user2

# Restart SSH
sudo systemctl restart sshd

# Validate SSH config
sudo sshd -t
# Output: (empty = valid)

# Test new configuration
ssh -p 2222 user@localhost

# Update firewall for new port
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp

# Security checklist:
# ✓ Non-standard port
# ✓ Key-based auth only (no passwords)
# ✓ Root cannot login
# ✓ Specific users allowed
# ✓ Firewall rules updated
```

**Explanation:** Always have alternative access before SSH changes. Test before applying.

---

## Exercise 8: Monitor Network Connections

**Solution:**

```bash
# Show all active connections
ss -tan
# -t = TCP, -a = all, -n = numeric

# Show with process info
sudo ss -tapn

# Monitor established connections
ss -tan | grep ESTAB
# Established connections only

# Check listening services
sudo ss -tlnp
# What's listening

# Real-time monitoring
watch -n 1 'ss -tan'
# Updates every 1 second

# Find suspicious connections
ss -tan | grep -E "ESTAB|TIME_WAIT" | wc -l

# Identify by port
sudo lsof -i :22
# What's using port 22

# Track connections to log
sudo ss -tapn > /tmp/connections.txt

# Monitor specific protocol
ss -U
# Unix sockets
```

**Explanation:** `ss` = state socket. Shows all connections. Monitor for unauthorized access.

---

## Exercise 9: Fail2Ban Introduction

**Solution:**

```bash
# Check if fail2ban installed
sudo systemctl status fail2ban
# or
fail2ban-client --version

# Monitor SSH failures
journalctl | grep "sshd" | tail -20

# View fail2ban jails
sudo fail2ban-client status
# Output: Status: Running, Jails: sshd

# Check sshd jail
sudo fail2ban-client status sshd
# Output: Jail sshd, Currently banned: 0

# View failed attempts
sudo journalctl -u fail2ban | tail -20

# Manual ban (test)
sudo fail2ban-client set sshd banip 192.168.1.100

# Unban
sudo fail2ban-client set sshd unbanip 192.168.1.100

# Check config
sudo cat /etc/fail2ban/jail.d/defaults-debian.conf

# Ban duration (maxretry before ban):
# bantime = 600 seconds
# maxretry = 6 attempts
# findtime = 600 second window
```

**Explanation:** fail2ban = automatic IP blocking after login failures. Prevents brute force.

---

## Exercise 10: Security Hardening Checklist

**Solution:**

```bash
# Create hardening guide
cat > /tmp/security_hardening.txt << 'EOF'
=== Linux Security Hardening Checklist ===

FIREWALL:
[ ] UFW enabled
[ ] Default policies: deny incoming, allow outgoing
[ ] SSH allowed (before other changes!)
[ ] Only required ports open
[ ] No unnecessary services listening

SSH HARDENING:
[ ] Changed to non-standard port (optional, 2222+)
[ ] Public key authentication enabled
[ ] Password authentication disabled
[ ] Root login disabled
[ ] Specific users allowed only
[ ] Config validated (sshd -t)
[ ] Connection tested before closing

SYSTEM ACCESS:
[ ] Strong password policy enforced
[ ] Sudo configured for specific users
[ ] No plaintext passwords in configs
[ ] SSH keys with strong passphrases
[ ] /etc/shadow permissions correct (600)

LOGGING & MONITORING:
[ ] SSH auth logs monitored
[ ] fail2ban installed and running
[ ] Firewall rules logged
[ ] Failed login attempts tracked
[ ] Systemd journal retention set

SERVICES:
[ ] Unnecessary services disabled
[ ] Unused packages removed
[ ] Automatic updates configured
[ ] No world-writable files
[ ] SUID/SGID files audited

HARDENING COMMANDS:
# Enable firewall
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow ssh

# SSH hardening (edit /etc/ssh/sshd_config)
sudo systemctl restart sshd

# Monitor
sudo fail2ban-client status
journalctl -u sshd -n 20

# Verify open ports
sudo ss -tlnp
EOF

cat /tmp/security_hardening.txt
```

**Explanation:** Comprehensive security = defense in depth. Multiple layers of protection.
