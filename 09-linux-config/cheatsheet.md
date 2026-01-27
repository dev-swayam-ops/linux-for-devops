# Linux Configuration: Cheatsheet

## Finding Configuration Files

| Command | Purpose | Example |
|---------|---------|---------|
| `find /etc -name "*.conf"` | Find all .conf files | `find /etc -name "*.conf"` |
| `find /etc -type f -name "*ssh*"` | Find SSH configs | `find /etc -type f -name "*ssh*"` |
| `locate servicename.conf` | Locate config by name | `locate sshd_config` |
| `grep -r "setting" /etc/` | Search across /etc | `grep -r "Port" /etc/ssh/` |
| `ls /etc/systemd/system/` | Show systemd configs | `ls /etc/systemd/system/` |

## Viewing Configuration

| Command | Purpose | Example |
|---------|---------|---------|
| `cat filename` | View config file | `cat /etc/ssh/sshd_config` |
| `cat -n filename` | Show line numbers | `cat -n /etc/ssh/sshd_config` |
| `grep -v "^#" file` | Remove comments | `grep -v "^#" sshd_config` |
| `grep -v "^$" file` | Remove blank lines | `grep -v "^$" file` |
| `less filename` | Page through config | `less /etc/nginx/nginx.conf` |

## Editing Configuration

| Command | Purpose | Example |
|---------|---------|---------|
| `nano filename` | Edit with nano | `sudo nano /etc/ssh/sshd_config` |
| `vi filename` | Edit with vi/vim | `sudo vi /etc/ssh/sshd_config` |
| `cat > file << 'EOF'` | Create config | `cat > /tmp/app.conf << 'EOF'` |
| `sed -i 's/old/new/' file` | In-place edit | `sudo sed -i 's/Port 22/Port 2222/' sshd_config` |

## Backup and Restore

| Command | Purpose | Example |
|---------|---------|---------|
| `cp file file.bak` | Simple backup | `sudo cp sshd_config sshd_config.bak` |
| `cp file file.$(date +%Y%m%d)` | Timestamped backup | `sudo cp file file.$(date +%Y%m%d)` |
| `diff file1 file2` | Compare configs | `diff sshd_config sshd_config.bak` |
| `tar -czf backup.tar.gz /etc/` | Archive all configs | `sudo tar -czf backup.tar.gz /etc/` |
| `cp file.bak file` | Restore from backup | `sudo cp sshd_config.bak sshd_config` |

## Validation

| Command | Purpose | Example |
|---------|---------|---------|
| `sshd -t` | Validate SSH config | `sudo sshd -t` |
| `nginx -t` | Validate Nginx config | `sudo nginx -t` |
| `apache2ctl -t` | Validate Apache config | `sudo apache2ctl -t` |
| `systemd-analyze verify` | Validate systemd unit | `sudo systemd-analyze verify ssh.service` |
| `python3 -m json.tool file` | Validate JSON config | `python3 -m json.tool config.json` |

## Service Configuration

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl reload service` | Reload config (live) | `sudo systemctl reload sshd` |
| `systemctl restart service` | Restart service | `sudo systemctl restart sshd` |
| `systemctl status service` | Show service status | `sudo systemctl status sshd` |
| `systemd-analyze cat-config` | Show merged config | `systemd-analyze cat-config sshd` |

## Drop-in Directories

| Command | Purpose | Example |
|---------|---------|---------|
| `mkdir -p /etc/service.d/` | Create drop-in dir | `mkdir -p /etc/ssh/sshd_config.d/` |
| `ls /etc/service.d/` | List drop-in configs | `ls /etc/systemd/system/ssh.service.d/` |
| `systemctl daemon-reload` | Reload systemd | `sudo systemctl daemon-reload` |

## File Permissions for Configs

| Command | Purpose | Example |
|---------|---------|---------|
| `chmod 600 file` | User only (sensitive) | `sudo chmod 600 /etc/sudoers` |
| `chmod 644 file` | User read/write, others read | `sudo chmod 644 /etc/hostname` |
| `chown root:root file` | Set owner | `sudo chown root:root config` |

## Common Config Locations

| Path | Service | Purpose |
|------|---------|---------|
| `/etc/ssh/sshd_config` | SSH | SSH daemon settings |
| `/etc/nginx/nginx.conf` | Nginx | Web server config |
| `/etc/apache2/apache2.conf` | Apache | Web server config |
| `/etc/systemd/system/` | Systemd | Service configurations |
| `/etc/sudoers` | sudo | Privilege escalation rules |
| `/etc/hostname` | System | System hostname |
| `/etc/resolv.conf` | DNS | DNS resolver settings |
| `/etc/fstab` | Mount | Filesystem mounting |
| `/etc/postgresql/` | PostgreSQL | Database config |
| `/etc/mysql/` | MySQL | Database config |

## Config File Formats

| Format | Extension | Tools | Example |
|--------|-----------|-------|---------|
| Text | .conf, .cfg | nano, vi | sshd_config |
| JSON | .json | python -m json.tool | config.json |
| YAML | .yaml, .yml | yamllint | docker-compose.yml |
| INI | .ini | grep, sed | app.ini |
| Systemd | .service | systemctl | ssh.service |

## Safe Editing Workflow

```bash
# 1. Backup
sudo cp original.conf original.conf.bak

# 2. Edit
sudo nano original.conf

# 3. Validate
sudo servicename -t

# 4. Apply
sudo systemctl reload servicename

# 5. Verify
sudo systemctl status servicename
```
