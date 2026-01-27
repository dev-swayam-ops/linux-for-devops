# Module 6: System Services and Daemons

## What You'll Learn

- Understand systemd service management
- Start, stop, and restart services
- Enable and disable services at boot
- Check service status and logs
- Create custom systemd service files
- Troubleshoot service failures

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Understanding of processes from Module 2
- Basic file editing skills
- Familiar with system administration concepts

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Service/Daemon** | Background process running continuously |
| **systemd** | Modern init system managing services |
| **Unit File** | Configuration file for systemd service |
| **Target** | Group of services run together (like runlevels) |
| **Socket** | Network endpoint service listens on |
| **Enabled** | Service starts automatically at boot |
| **Active** | Service is currently running |
| **Failed** | Service failed to start or crashed |

## Hands-on Lab: Manage System Services

### Lab Objective
View, control, and monitor system services using systemd.

### Commands

```bash
# List all running services
systemctl list-units --type=service

# Check specific service status
systemctl status ssh
# or
systemctl is-active ssh

# Start a service
sudo systemctl start ssh

# Stop a service
sudo systemctl stop ssh

# Restart a service
sudo systemctl restart ssh

# Reload service (without stopping)
sudo systemctl reload ssh

# Enable service at boot
sudo systemctl enable ssh

# Disable service at boot
sudo systemctl disable ssh

# Check if enabled
systemctl is-enabled ssh

# List enabled services
systemctl list-unit-files --type=service --state=enabled

# List failed services
systemctl list-units --type=service --state=failed

# View service logs
journalctl -u ssh
# Last 10 lines:
journalctl -u ssh -n 10

# Follow logs in real-time
journalctl -u ssh -f

# View service configuration
cat /etc/systemd/system/ssh.service
# or
systemctl cat ssh

# Check service dependencies
systemctl show-dependencies ssh

# View all available services
systemctl list-unit-files --type=service

# Reload systemd after config changes
sudo systemctl daemon-reload

# Check systemd status
systemctl status
```

### Expected Output

```
# systemctl status ssh output:
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/etc/systemd/system/ssh.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2026-01-27 10:00:00 UTC; 2h 30min ago
       Docs: man:sshd(8) man:sshd_config(5)
     Process: 1234 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
   Main PID: 1235 (sshd)
      Tasks: 1 (limit: 2345)
     Memory: 5.2M
     CGroup: /system.slice/ssh.service
             └─1235 /usr/sbin/sshd -D

# journalctl -u ssh -n 5 output:
Jan 27 10:00:00 hostname sshd[1235]: Server listening on 0.0.0.0 port 22.
Jan 27 10:00:00 hostname sshd[1235]: Server listening on :: port 22.
Jan 27 10:15:32 hostname sshd[4567]: Accepted password for user from 192.168.1.100 port 54321
```

## Validation

Confirm successful completion:

- [ ] Listed all running services with `systemctl list-units`
- [ ] Checked service status with `systemctl status`
- [ ] Started and stopped a service
- [ ] Viewed service logs with `journalctl`
- [ ] Enabled/disabled a service
- [ ] Understood systemd unit file structure

## Cleanup

```bash
# Re-enable SSH if you disabled it for testing
sudo systemctl enable ssh
sudo systemctl start ssh

# Verify service is running
systemctl status ssh
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Forgot `sudo` for systemctl | Need privilege: use `sudo systemctl start service` |
| Service won't start | Check logs: `journalctl -u servicename -n 20` |
| `systemctl: command not found` | Old system, update to modern Linux |
| Can't find service name | List all: `systemctl list-unit-files \| grep name` |
| Restarted critical service, lost access | Use `systemctl status` to verify, then SSH won't reconnect |
| Unit file not found | File must be in `/etc/systemd/system/` or `/usr/lib/systemd/system/` |

## Troubleshooting

**Q: How do I see why a service failed?**
A: Use `journalctl -u servicename` to see detailed logs and errors.

**Q: Why isn't my service starting at boot?**
A: Check if enabled: `systemctl is-enabled servicename`. Enable with `systemctl enable`.

**Q: Can I see all services on system?**
A: Use `systemctl list-unit-files --type=service` to see all, enabled/disabled.

**Q: What's the difference between start and enable?**
A: `start` = run now, `enable` = run at next boot. Use both for permanent activation.

**Q: How do I create a custom service?**
A: Create `/etc/systemd/system/myservice.service`, then `systemctl daemon-reload` and `systemctl enable myservice`.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Practice managing common services (SSH, Apache, MySQL)
3. Create custom systemd service files
4. Learn to troubleshoot service failures
5. Explore systemd timers and other unit types
