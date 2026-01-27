# Security and Firewall: Exercises

Complete these exercises to master Linux security.

## Exercise 1: Firewall Basics with UFW

**Tasks:**
1. Check current firewall status
2. Enable firewall
3. Verify enabled status
4. Show active rules
5. Understand default policies

**Hint:** Use `sudo ufw`, `sudo ufw status verbose`.

---

## Exercise 2: Allow Critical Services

**Tasks:**
1. Allow SSH port (critical!)
2. Allow HTTP (port 80)
3. Allow HTTPS (port 443)
4. List all allowed rules
5. Verify connectivity to each port

**Hint:** Use `sudo ufw allow service` or `sudo ufw allow port/protocol`.

---

## Exercise 3: Block and Deny Rules

**Tasks:**
1. Deny specific port
2. Block unwanted service
3. Delete a rule
4. Show numbered rules
5. Understand rule priority

**Hint:** Use `sudo ufw deny`, `sudo ufw delete`, `sudo ufw status numbered`.

---

## Exercise 4: Source-Based Firewall Rules

**Tasks:**
1. Allow SSH from specific IP
2. Block traffic from IP range
3. Allow to specific interface
4. Combine source and port
5. Test rule effectiveness

**Hint:** Use `sudo ufw allow from IP`, `to any port`.

---

## Exercise 5: Check Open Ports

**Tasks:**
1. List listening ports
2. Show port ownership (process)
3. Check for unauthorized ports
4. Verify firewall allows ports
5. Match firewall rules to open ports

**Hint:** Use `sudo ss -tlnp`, `sudo netstat -tlnp`.

---

## Exercise 6: Default Policies

**Tasks:**
1. Set default deny incoming
2. Set default allow outgoing
3. Understand policy implications
4. Test inbound connections
5. Verify outbound works

**Hint:** Use `sudo ufw default deny incoming`, `allow outgoing`.

---

## Exercise 7: SSH Security Hardening

**Tasks:**
1. Change SSH port (non-standard)
2. Disable password auth (key-only)
3. Disable root login
4. Allow only specific users
5. Update firewall rules for new port

**Hint:** Edit `/etc/ssh/sshd_config`, test before applying.

---

## Exercise 8: Monitor Network Connections

**Tasks:**
1. Show active connections
2. Monitor established connections
3. Check listening services
4. Track connection states
5. Identify suspicious connections

**Hint:** Use `ss`, `netstat`, `lsof`, `watch`.

---

## Exercise 9: Fail2Ban Introduction

**Tasks:**
1. Check if fail2ban installed
2. Monitor SSH login failures
3. Understand fail2ban jails
4. View failed login attempts
5. Check ban duration

**Hint:** Use `fail2ban-client`, `journalctl | grep sshd`.

---

## Exercise 10: Security Hardening Checklist

Create complete security baseline.

**Tasks:**
1. Document firewall rules
2. Configure password policy
3. Disable unnecessary services
4. Set up logging
5. Create hardening guide

**Hint:** Combine all previous exercises + SSH hardening.
