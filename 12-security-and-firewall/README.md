# Module 12: Security and Firewall

## What You'll Learn

- Implement firewall rules with iptables and UFW
- Understand network security basics
- Manage user access and authentication
- Apply principle of least privilege
- Monitor network connections
- Harden system against common attacks
- Work with SELinux basics

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Complete Module 4: Networking & Ports
- Understanding of users and permissions
- Basic networking knowledge

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Firewall** | Network traffic filter rules |
| **iptables** | Kernel firewall management tool |
| **UFW** | User-friendly firewall wrapper |
| **Port** | Endpoint for network connection |
| **Protocol** | TCP, UDP, ICMP |
| **ACL** | Access Control List |
| **SSH Key** | Public key authentication |
| **Sudo** | Privilege escalation control |
| **SELinux** | Security contexts enforcement |

## Hands-on Lab: Configure Firewall Rules

### Lab Objective
Set up basic firewall with UFW and verify rules.

### Commands

```bash
# Check firewall status
sudo ufw status
# or detailed
sudo ufw status verbose

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Allow SSH (important!)
sudo ufw allow ssh
# or specific port
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Block specific port
sudo ufw deny 3389

# Delete rule
sudo ufw delete allow 80/tcp

# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Check open ports
sudo ss -tlnp
# or
sudo netstat -tlnp

# Show IP reputation commands
fail2ban-client status
# Monitor failed logins

# View iptables rules (lower level)
sudo iptables -L -n
```

### Expected Output

```
# ufw status output:
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)

# ss -tlnp output:
State    Recv-Q Send-Q Local Address:Port  Peer Address:Port
LISTEN   0      128    0.0.0.0:22         0.0.0.0:*    users:(("sshd",pid=1234))
```

## Validation

Confirm successful completion:

- [ ] Firewall enabled and verified
- [ ] SSH port allowed (critical!)
- [ ] HTTP/HTTPS rules applied
- [ ] Verified with ss command
- [ ] Default policies set
- [ ] Tested incoming/outgoing traffic

## Cleanup

```bash
# Reset firewall to defaults (careful!)
sudo ufw reset

# Or disable if not needed
sudo ufw disable
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Blocking SSH without escape | Always test SSH before blocking |
| Too restrictive rules | Block by default, allow specific |
| Forgetting to enable | Use `sudo ufw enable` |
| Rules not persistent | UFW auto-persists across reboots |
| Forgot to allow port | Add rule before blocking |

## Troubleshooting

**Q: Can't access SSH after firewall change?**
A: Revert: `sudo ufw reset` or delete blocking rule, or use console if VM.

**Q: How do I see all firewall rules?**
A: Use `sudo ufw status numbered` to see rule numbers.

**Q: How do I allow specific IP?**
A: Use `sudo ufw allow from 192.168.1.100 to any port 22`.

**Q: Should I use UFW or iptables?**
A: UFW = easier. iptables = more control. UFW uses iptables underneath.

**Q: How do I monitor failed logins?**
A: Use `journalctl | grep sshd` or install `fail2ban`.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Master firewall rule patterns
3. Learn fail2ban for intrusion prevention
4. Study SELinux contexts
5. Implement security monitoring
