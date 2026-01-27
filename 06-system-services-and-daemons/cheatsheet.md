# System Services and Daemons: Cheatsheet

## Basic Service Management

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl start service` | Start service now | `sudo systemctl start ssh` |
| `systemctl stop service` | Stop service now | `sudo systemctl stop ssh` |
| `systemctl restart service` | Stop then start | `sudo systemctl restart ssh` |
| `systemctl reload service` | Reload config (no stop) | `sudo systemctl reload ssh` |
| `systemctl status service` | Show service status | `systemctl status ssh` |

## Service Enable/Disable

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl enable service` | Start at boot | `sudo systemctl enable ssh` |
| `systemctl disable service` | Don't start at boot | `sudo systemctl disable ssh` |
| `systemctl is-enabled service` | Check if enabled | `systemctl is-enabled ssh` |
| `systemctl is-active service` | Check if running | `systemctl is-active ssh` |
| `systemctl is-failed service` | Check if failed | `systemctl is-failed ssh` |

## Service Listing

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl list-units --type=service` | All loaded services | `systemctl list-units --type=service` |
| `systemctl list-units --state=active` | Only running services | `systemctl list-units --state=active` |
| `systemctl list-units --state=failed` | Failed services | `systemctl list-units --state=failed` |
| `systemctl list-unit-files --type=service` | All available services | `systemctl list-unit-files --type=service` |
| `systemctl list-unit-files --state=enabled` | Enabled services | `systemctl list-unit-files --state=enabled` |

## Logging and Diagnostics

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl -u service` | Service logs | `journalctl -u ssh` |
| `journalctl -u service -n 20` | Last 20 log lines | `journalctl -u ssh -n 20` |
| `journalctl -u service -f` | Follow logs | `journalctl -u ssh -f` |
| `journalctl -u service -b` | Since last boot | `journalctl -u ssh -b` |
| `journalctl -u service --since "time"` | Logs since specific time | `journalctl -u ssh --since "10:00"` |

## Unit File Information

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl cat service` | Show unit file | `systemctl cat ssh` |
| `systemctl show service` | Show service properties | `systemctl show ssh` |
| `systemctl show-dependencies service` | Service dependencies | `systemctl show-dependencies ssh` |
| `systemctl show-dependencies --reverse` | Reverse dependencies | `systemctl show-dependencies ssh --reverse` |
| `systemctl list-dependencies target` | Services in target | `systemctl list-dependencies multi-user.target` |

## System and Target Management

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl get-default` | Current default target | `systemctl get-default` |
| `systemctl set-default target` | Set default target | `sudo systemctl set-default multi-user.target` |
| `systemctl isolate target` | Switch to target now | `sudo systemctl isolate graphical.target` |
| `systemctl list-units --type=target` | Available targets | `systemctl list-units --type=target` |
| `systemctl list-dependencies target` | Services in target | `systemctl list-dependencies multi-user.target` |

## Unit File Sections

| Section | Purpose | Key Directives |
|---------|---------|-----------------|
| `[Unit]` | Metadata | Description, After, Requires, Wants |
| `[Service]` | Execution | Type, ExecStart, ExecStop, Restart |
| `[Install]` | Installation | WantedBy, RequiredBy, Alias |

## Common Service Files Locations

| Location | Purpose |
|----------|---------|
| `/etc/systemd/system/` | Custom and override service files |
| `/usr/lib/systemd/system/` | System-provided service files |
| `/run/systemd/system/` | Runtime-generated service files |

## Service Types

| Type | Behavior |
|------|----------|
| `simple` | Service runs continuously |
| `forking` | Service forks and exits parent |
| `oneshot` | Service runs once then exits |
| `notify` | Service sends ready signal |
| `idle` | Waits until idle before starting |

## Restart Policies

| Policy | Behavior |
|--------|----------|
| `no` | Don't restart on failure |
| `always` | Always restart |
| `on-failure` | Restart only on failure |
| `on-abnormal` | Restart on non-zero exit |
| `on-watchdog` | Restart on watchdog timeout |

## Creating Custom Service File

```ini
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
User=myuser
ExecStart=/usr/local/bin/my-service.sh
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

## Common Commands Quick Reference

| Task | Command |
|------|---------|
| View all services | `systemctl list-unit-files --type=service` |
| Find failing service | `systemctl list-units --state=failed` |
| View service error | `journalctl -u servicename -n 50` |
| Enable service | `sudo systemctl enable servicename` |
| Start service | `sudo systemctl start servicename` |
| Reload after edit | `sudo systemctl daemon-reload` |

## Target Levels

| Target | Purpose | Equivalent |
|--------|---------|-----------|
| `poweroff.target` | System shutdown | Runlevel 0 |
| `rescue.target` | Single user mode | Runlevel 1 |
| `multi-user.target` | Multi-user CLI | Runlevel 3 |
| `graphical.target` | Multi-user GUI | Runlevel 5 |
| `reboot.target` | System reboot | Runlevel 6 |

## Useful Patterns

```bash
# Show only active services
systemctl list-units --type=service --state=active

# Show only failed services
systemctl list-units --type=service --state=failed

# Restart all services
systemctl restart '*'

# Stop all services (dangerous!)
systemctl stop '*'

# View service dependencies
systemctl show-dependencies --all servicename

# Find service by keyword
systemctl list-unit-files | grep keyword
```
