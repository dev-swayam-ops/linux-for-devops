# Module 9: Linux Configuration Management

## What You'll Learn

- Understand Linux configuration file formats
- Locate and edit system configuration files
- Validate configuration syntax before applying
- Backup and restore configurations safely
- Manage multiple configuration sources
- Understand service-specific config directories

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Basic file editing skills (nano/vi)
- Understanding of systemd from Module 6

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Config File** | Text file with settings (usually /etc/) |
| **.d Directories** | Drop-in directory for modular configs |
| **Syntax Validation** | Check config before applying |
| **Backup** | Save original before changes |
| **Reload vs Restart** | Apply changes without restart |
| **Config Merge** | Combine multiple config sources |

## Hands-on Lab: Edit and Validate Configuration

### Lab Objective
Edit a config file, validate syntax, and apply changes safely.

### Commands

```bash
# Find config files
find /etc -name "*.conf" | head -10

# View SSH configuration
cat /etc/ssh/sshd_config

# Backup before editing
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Edit configuration
sudo nano /etc/ssh/sshd_config

# Validate SSH config syntax
sudo sshd -t

# Check config without editing
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

# View systemd config directory
ls -la /etc/systemd/system/

# View drop-in configs
ls -la /etc/systemd/system/ssh.service.d/

# Reload service after config change
sudo systemctl reload sshd

# Check service status
sudo systemctl status sshd

# View configuration with defaults merged
systemd-analyze cat-config sshd
```

### Expected Output

```
# sshd -t (no output = valid)
# (empty = syntax is correct)

# grep output (removes comments):
Port 22
PermitRootLogin prohibit-password
PubkeyAuthentication yes
```

## Validation

Confirm successful completion:

- [ ] Located config files in /etc
- [ ] Backed up original configuration
- [ ] Edited config file safely
- [ ] Validated syntax before applying
- [ ] Reloaded service
- [ ] Verified changes took effect

## Cleanup

```bash
# Restore original if needed
sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config

# Reload to apply
sudo systemctl reload sshd
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Editing without backup | Always backup before changes |
| Invalid syntax | Validate before reload/restart |
| Forgetting sudo | Config edits require root privilege |
| Not reloading | Changes don't apply until reload |
| Editing active service | Test in non-prod first |

## Troubleshooting

**Q: How do I find all config files?**
A: Use `find /etc -name "*.conf"` or `grep -r "setting" /etc/`.

**Q: How do I validate config syntax?**
A: Use `sshd -t` for SSH, `nginx -t` for Nginx, service-specific tools.

**Q: Config not applying after edit?**
A: Reload service: `sudo systemctl reload servicename`.

**Q: How do I revert changes?**
A: Restore from backup: `sudo cp /etc/service.conf.bak /etc/service.conf`.

**Q: Where are drop-in configs?**
A: Check `/etc/service.d/` or `/etc/systemd/system/service.d/`.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Practice safe configuration management
3. Learn configuration management tools (Ansible)
4. Master /etc directory structure
5. Study service-specific configs (nginx, apache, postgresql)
