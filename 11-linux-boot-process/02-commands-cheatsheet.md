# Commands Cheatsheet: Boot Process

## Quick Reference

### Boot Information Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `uname -a` | Kernel version, architecture, hostname | `uname -a` → `Linux ubuntu 5.15.0-56-generic ...` |
| `hostnamectl` | System hostname and OS info | `hostnamectl` → Shows "Operating System: Ubuntu 20.04 LTS" |
| `timedatectl` | System time, timezone, NTP status | `timedatectl` → Shows time sync status |
| `systemctl get-default` | Current default boot target | `systemctl get-default` → `multi-user.target` |
| `uptime` | System uptime since last boot | `uptime` → `23:15:52 up 2 days, 3:41` |
| `dmesg` | Kernel messages (current boot) | `dmesg \| tail -20` |
| `journalctl -b` | Journal since last boot | `journalctl -b --no-pager` |

### Firmware & Bootloader Info

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -la /sys/firmware/efi` | Check if UEFI (exists) or BIOS (doesn't exist) | `ls -la /sys/firmware/efi` |
| `efibootmgr` | View/manage UEFI boot entries | `efibootmgr` |
| `dmidecode -t system` | System firmware info | `dmidecode -t system \| grep -i 'system\|manufacturer'` |
| `file /boot/vmlinuz-*` | Check kernel format | `file /boot/vmlinuz-5.15.0-56-generic` |
| `ls -lh /boot/` | View boot directory contents | `ls -lh /boot/` |

### GRUB Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `cat /proc/cmdline` | Boot parameters used | `cat /proc/cmdline` → `root=UUID=abc ro quiet splash` |
| `grub-mkconfig -o /boot/grub/grub.cfg` | Generate GRUB config from defaults | **Debian/Ubuntu** |
| `grub2-mkconfig -o /boot/grub2/grub.cfg` | Generate GRUB config | **RHEL/CentOS** |
| `update-grub` | Regenerate GRUB menu | **Debian/Ubuntu shortcut** |
| `grub-install /dev/sda` | Install GRUB bootloader | `sudo grub-install /dev/sda` |
| `grub-editenv` | Edit GRUB environment | `grub-editenv list` |
| `grub-set-default` | Set default GRUB entry | `sudo grub-set-default 0` (first entry) |

### Kernel & Boot Parameters

| Command | Purpose | Example |
|---------|---------|---------|
| `cat /proc/version` | Kernel version details | Shows kernel release, compiler, etc. |
| `cat /proc/cmdline` | Kernel boot parameters | Shows `root=`, `ro`, `quiet`, etc. |
| `cat /proc/cpuinfo` | CPU info | Shows processors, model, flags |
| `cat /proc/meminfo` | Memory info | Shows RAM usage, caching, swap |
| `sysctl kernel.panic` | Kernel panic reboot timeout | `sysctl kernel.panic` → `kernel.panic = 0` |
| `sysctl -a \| grep boot` | All boot-related parameters | Search sysctl for boot settings |
| `grubby --info=ALL` | RHEL/CentOS - list boot entries | `grubby --info=ALL \| head -20` |
| `grubby --set-default` | RHEL/CentOS - change default entry | `sudo grubby --set-default=/boot/vmlinuz-...` |

### Boot Targets & Services

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl list-units --type=target` | List all targets | Shows rescue, multi-user, graphical, etc. |
| `systemctl list-units --type=service` | List all services | Shows all `.service` units |
| `systemctl get-default` | Current default target | `systemctl get-default` |
| `systemctl set-default multi-user.target` | Change default target | *Requires sudo* |
| `systemctl isolate rescue.target` | Switch to rescue target | Single-user mode (interactive) |
| `systemctl isolate multi-user.target` | Switch to multi-user | Can be done from graphical.target |
| `systemctl status service-name` | Check service status | `systemctl status ssh` |
| `systemctl enable service-name` | Auto-start service at boot | `sudo systemctl enable ssh` |
| `systemctl disable service-name` | Don't auto-start at boot | `sudo systemctl disable apache2` |
| `systemctl list-dependencies multi-user.target` | Show service dependencies | Shows what must start for this target |

### Boot Time Analysis

| Command | Purpose | Example |
|---------|---------|---------|
| `systemd-analyze` | Overall boot time | Shows kernel, initramfs, systemd times |
| `systemd-analyze blame` | Slowest services | Ordered by startup time |
| `systemd-analyze critical-chain` | Critical boot path | Sequential services on critical path |
| `systemd-analyze plot > boot.svg` | Boot sequence as SVG graph | Creates visualization |
| `journalctl --system -b --priority=notice` | Boot messages (recent) | Messages from current boot |
| `journalctl -u service-name -b` | Specific service logs during boot | `journalctl -u ssh -b` |

### Filesystem & Mounting

| Command | Purpose | Example |
|---------|---------|---------|
| `mount` | Currently mounted filesystems | Shows all mounts and options |
| `mount \| grep /boot` | Check /boot mount status | Verify /boot is mounted |
| `lsblk` | Block devices and partitions | Tree view of storage |
| `fdisk -l` | Partition info (all disks) | Lists all partitions and types |
| `blkid` | Block device UUIDs/labels | Shows UUID for each partition |
| `df -h /boot` | /boot filesystem usage | Check if /boot is full |
| `fsck -n /dev/sda1` | Check filesystem (read-only) | No changes, just report errors |
| `cat /etc/fstab` | Filesystem table (mount at boot) | Shows what mounts at startup |

### Single-User & Recovery

| Command | Purpose | Typical Use |
|---------|---------|-----------|
| `systemctl isolate rescue.target` | Interactive single-user mode | Troubleshooting from running system |
| `systemctl rescue` | Rescue mode (interactive) | Better than above (runs more startup) |
| `init 1` | Single-user mode (legacy) | Older systems |
| **GRUB Edit** | Boot parameters at boot menu | Press `e` in GRUB, add `1` or `single` |
| **Boot from USB** | LiveUSB/recovery | Fixes unbootable system |

---

## Common Command Patterns

### Viewing Boot Messages

```bash
# Full boot messages from current boot
journalctl -b --no-pager

# Last 50 lines
journalctl -b -n 50

# With timestamps, human-readable
journalctl -b --output=short-full

# Messages from specific service during boot
journalctl -u ssh.service -b

# Dmesg (kernel ring buffer only)
dmesg | tail -30

# With timestamps
dmesg -H | tail -30
```

### Modifying Boot Parameters

```bash
# View current boot parameters
cat /proc/cmdline

# Edit GRUB defaults
sudo nano /etc/default/grub

# Look for this line and modify:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# Regenerate GRUB config
sudo update-grub          # Debian/Ubuntu
sudo grub2-mkconfig -o /boot/grub2/grub.cfg  # RHEL/CentOS

# Reboot to apply
sudo reboot
```

### Changing Default Boot Target

```bash
# View current
systemctl get-default

# Change to multi-user (server mode, no GUI)
sudo systemctl set-default multi-user.target

# Change to graphical (with desktop)
sudo systemctl set-default graphical.target

# Temporary switch (until reboot)
sudo systemctl isolate multi-user.target
sudo systemctl isolate graphical.target
```

### Analyzing Boot Performance

```bash
# Overall summary
systemd-analyze

# Services ranked by startup time (slowest first)
systemd-analyze blame

# Critical path to boot
systemd-analyze critical-chain

# Create SVG visualization (open in browser)
systemd-analyze plot > boot.svg

# View a specific service's dependencies
systemctl list-dependencies graphical.target
```

### Checking GRUB Configuration

```bash
# View current GRUB defaults
cat /etc/default/grub

# View generated GRUB config
grep -E '^menuentry|^\tlinux' /boot/grub/grub.cfg | head -20

# View all kernel/initramfs in /boot
ls -lh /boot/vmlinuz-* /boot/initrd*

# Check if GRUB password is enabled
grep -i password /boot/grub/grub.cfg | head
```

### Filesystem Boot Checks

```bash
# Check /boot is mounted
mount | grep /boot

# Check /boot has space
df -h /boot

# List what's using space in /boot
du -sh /boot/*

# Check for old kernels (safe to remove)
ls -lh /boot/vmlinuz-* | head -10

# Remove old kernel packages
sudo apt-get autoremove       # Debian/Ubuntu
sudo yum remove kernel-old    # RHEL/CentOS
```

### Service Boot Behavior

```bash
# Services enabled at boot
systemctl list-unit-files --type=service | grep enabled

# Services disabled at boot
systemctl list-unit-files --type=service | grep disabled

# Check if specific service starts at boot
systemctl is-enabled ssh.service

# Enable service at boot
sudo systemctl enable ssh.service

# Disable service at boot
sudo systemctl disable apache2.service

# View service unit file
cat /etc/systemd/system/myservice.service
# or
cat /usr/lib/systemd/system/myservice.service
```

---

## Troubleshooting Reference

### When System Won't Boot

```bash
# Boot into single-user mode (modify in GRUB)
# Add "single" or "1" to kernel line

# Boot with minimal modules
# Add "nomodeset" if GPU issue
# Add "acpi=off" for ACPI problems

# Check kernel logs (if you can boot from USB)
# Mount root partition, check /var/log
```

### When System is Slow to Boot

```bash
# Identify slow services
systemd-analyze blame

# Disable unnecessary services at boot
sudo systemctl disable apparmor
sudo systemctl disable snapd

# Check for failed services
systemctl list-units --state=failed

# Check background jobs
systemctl list-timers    # Scheduled tasks
jobs                     # Shell jobs
```

### GRUB Corruption or Loss

```bash
# Boot from live USB, chroot to broken system

# Mount root filesystem
sudo mount /dev/sda1 /mnt

# Reinstall GRUB
sudo grub-install --root-directory=/mnt /dev/sda

# Regenerate config
sudo chroot /mnt update-grub
```

---

## Quick Facts

- **GRUB file:** `/boot/grub/grub.cfg` (don't edit directly)
- **GRUB defaults:** `/etc/default/grub` (edit this, run update-grub)
- **Kernel file:** `/boot/vmlinuz-VERSION`
- **Initramfs:** `/boot/initrd.img-VERSION` or `/boot/initramfs-VERSION.img`
- **Default target:** Usually `graphical.target` or `multi-user.target`
- **Single-user mode:** `systemctl rescue` or boot with `single` parameter
- **Boot time check:** `systemd-analyze` command
- **Reboot safely:** `sudo systemctl reboot` or `sudo reboot`
- **Emergency shell:** Boot with `init=/bin/bash` (no systemd)
- **Check firmware:** `ls /sys/firmware/efi` (exists = UEFI, missing = BIOS)
