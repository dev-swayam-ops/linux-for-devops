# Security and Firewall: Cheatsheet

## UFW Firewall

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ufw enable` | Enable firewall | `sudo ufw enable` |
| `sudo ufw disable` | Disable firewall | `sudo ufw disable` |
| `sudo ufw status` | Show firewall status | `sudo ufw status` |
| `sudo ufw status verbose` | Detailed status | `sudo ufw status verbose` |
| `sudo ufw status numbered` | Numbered rules | `sudo ufw status numbered` |
| `sudo ufw allow port` | Allow port | `sudo ufw allow 22` |
| `sudo ufw allow service` | Allow service | `sudo ufw allow ssh` |
| `sudo ufw deny port` | Block port | `sudo ufw deny 3389` |
| `sudo ufw delete allow 22` | Delete rule | `sudo ufw delete allow 22` |
| `sudo ufw delete 2` | Delete by number | `sudo ufw delete 2` |
| `sudo ufw reset` | Reset all rules | `sudo ufw reset` |

## UFW Port Rules

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ufw allow 80/tcp` | TCP port | `sudo ufw allow 80/tcp` |
| `sudo ufw allow 53/udp` | UDP port | `sudo ufw allow 53/udp` |
| `sudo ufw allow 1000:2000/tcp` | Port range | `sudo ufw allow 1000:2000/tcp` |
| `sudo ufw allow in 22` | Incoming | `sudo ufw allow in ssh` |
| `sudo ufw allow out 53` | Outgoing | `sudo ufw allow out 53` |

## UFW Source-Based Rules

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ufw allow from IP` | Allow IP | `sudo ufw allow from 192.168.1.100` |
| `sudo ufw allow from IP/subnet` | Allow subnet | `sudo ufw allow from 192.168.1.0/24` |
| `sudo ufw deny from IP` | Block IP | `sudo ufw deny from 10.0.0.1` |
| `sudo ufw allow from IP to any port 22` | Combo rule | `sudo ufw allow from 192.168.1.100 to any port 22` |
| `sudo ufw allow in on eth0` | Interface | `sudo ufw allow in on eth0 to any port 80` |

## UFW Default Policies

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ufw default deny incoming` | Block all inbound | `sudo ufw default deny incoming` |
| `sudo ufw default allow incoming` | Allow all inbound | `sudo ufw default allow incoming` |
| `sudo ufw default allow outgoing` | Allow all outbound | `sudo ufw default allow outgoing` |
| `sudo ufw default deny outgoing` | Block all outbound | `sudo ufw default deny outgoing` |

## Port and Connection Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ss -tlnp` | TCP listening | `sudo ss -tlnp` |
| `sudo ss -tan` | All TCP | `sudo ss -tan` |
| `sudo ss -tanp` | TCP with process | `sudo ss -tanp` |
| `sudo netstat -tlnp` | TCP listening (old) | `sudo netstat -tlnp` |
| `sudo lsof -i :22` | Process on port | `sudo lsof -i :22` |
| `sudo lsof -i -P -n` | All network connections | `sudo lsof -i -P -n` |

## Connection States

| State | Meaning |
|-------|---------|
| `LISTEN` | Listening for connections |
| `ESTAB` | Established connection |
| `TIME_WAIT` | Closed, waiting timeout |
| `CLOSE_WAIT` | Closing, waiting for close |
| `ESTABLISHED` | Active connection |
| `SYN_SENT` | Connection initiating |
| `SYN_RECV` | Received SYN, responding |

## SSH Security

| Configuration | Setting | Example |
|---------------|---------|---------|
| Change Port | `/etc/ssh/sshd_config` | `Port 2222` |
| Key Auth Only | `PubkeyAuthentication yes` | `PubkeyAuthentication yes` |
| Disable Passwords | `PasswordAuthentication no` | `PasswordAuthentication no` |
| Disable Root | `PermitRootLogin no` | `PermitRootLogin no` |
| Allow Users | `AllowUsers user1 user2` | `AllowUsers user1 user2` |
| Strict Mode | `StrictModes yes` | `StrictModes yes` |
| Protocol | `Protocol 2` | `Protocol 2` |
| X11 Forwarding | `X11Forwarding no` | `X11Forwarding no` |

## SSH Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo sshd -t` | Test SSH config | `sudo sshd -t` |
| `sudo systemctl restart sshd` | Restart SSH | `sudo systemctl restart sshd` |
| `ssh-keygen` | Generate key pair | `ssh-keygen -t rsa` |
| `ssh-copy-id user@host` | Copy public key | `ssh-copy-id user@server.com` |
| `chmod 600 ~/.ssh/id_rsa` | Key permissions | `chmod 600 ~/.ssh/id_rsa` |
| `chmod 644 ~/.ssh/id_rsa.pub` | Public key perms | `chmod 644 ~/.ssh/id_rsa.pub` |

## Fail2Ban

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo systemctl status fail2ban` | Status | `sudo systemctl status fail2ban` |
| `sudo fail2ban-client status` | Jails status | `sudo fail2ban-client status` |
| `sudo fail2ban-client status sshd` | SSH jail | `sudo fail2ban-client status sshd` |
| `sudo fail2ban-client set sshd banip IP` | Ban IP | `sudo fail2ban-client set sshd banip 192.168.1.1` |
| `sudo fail2ban-client set sshd unbanip IP` | Unban IP | `sudo fail2ban-client set sshd unbanip 192.168.1.1` |

## iptables (Advanced)

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo iptables -L -n` | List rules | `sudo iptables -L -n` |
| `sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT` | Add rule | Add SSH rule |
| `sudo iptables -D INPUT 1` | Delete rule | `sudo iptables -D INPUT 1` |
| `sudo iptables -F` | Flush all | `sudo iptables -F` |
| `sudo iptables-save` | Save rules | `sudo iptables-save` |

## Security Files

| File | Purpose | Permissions |
|------|---------|-------------|
| `/etc/ssh/sshd_config` | SSH daemon config | 600 (root:root) |
| `~/.ssh/id_rsa` | Private key | 600 (user:user) |
| `~/.ssh/id_rsa.pub` | Public key | 644 (user:user) |
| `~/.ssh/authorized_keys` | Authorized keys | 600 (user:user) |
| `/etc/shadow` | Password hashes | 600 (root:root) |
| `/etc/sudoers` | Sudo config | 440 (root:root) |

## Logging and Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl -u sshd` | SSH logs | `journalctl -u sshd -n 20` |
| `sudo tail -f /var/log/auth.log` | Auth logs | `sudo tail -f /var/log/auth.log` |
| `grep "Failed password" /var/log/auth.log` | Failed logins | Count failed attempts |
| `sudo fail2ban-client status` | fail2ban status | See bans |
| `sudo ss -tapn | watch` | Monitor connections | `watch -n 1 'sudo ss -tapn'` |

## Common Ports

| Port | Service | Protocol |
|------|---------|----------|
| 22 | SSH | TCP |
| 80 | HTTP | TCP |
| 443 | HTTPS | TCP |
| 3306 | MySQL | TCP |
| 5432 | PostgreSQL | TCP |
| 5900 | VNC | TCP |
| 3389 | RDP | TCP |
| 53 | DNS | TCP/UDP |
| 25 | SMTP | TCP |
| 110 | POP3 | TCP |
