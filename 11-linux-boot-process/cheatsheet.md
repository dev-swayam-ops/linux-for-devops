# Linux Boot Process: Cheatsheet

## Boot Message Viewing

| Command | Purpose | Example |
|---------|---------|---------|
| `dmesg` | Show kernel boot messages | `dmesg` |
| `dmesg -l` | Filter by log level | `dmesg -l err` |
| `dmesg -H` | Human-readable timestamps | `dmesg -H` |
| `dmesg -c` | Clear ring buffer | `sudo dmesg -c` |
| `journalctl -b` | Show this boot's logs | `journalctl -b` |

## systemd Boot Analysis

| Command | Purpose | Example |
|---------|---------|---------|
| `systemd-analyze` | Show boot timing | `systemd-analyze` |
| `systemd-analyze blame` | Slowest services | `systemd-analyze blame` |
| `systemd-analyze plot` | Boot chart | `systemd-analyze plot > boot.svg` |
| `systemd-analyze critical-chain` | Dependency chain | `systemd-analyze critical-chain` |
| `systemd-analyze verify` | Verify units | `systemd-analyze verify` |

## GRUB Configuration

| Command | Purpose | Example |
|---------|---------|---------|
| `cat /boot/grub/grub.cfg` | View GRUB config | `cat /boot/grub/grub.cfg` |
| `grub-editenv list` | Show default entry | `grub-editenv list` |
| `update-grub` | Apply /etc/default/grub changes | `sudo update-grub` |
| `grub-mkconfig` | Regenerate grub.cfg | `sudo grub-mkconfig -o /boot/grub/grub.cfg` |
| `grub-install` | Install GRUB | `sudo grub-install /dev/sda` |

## Boot Information

| Command | Purpose | Example |
|---------|---------|---------|
| `cat /proc/cmdline` | Show kernel parameters | `cat /proc/cmdline` |
| `cat /proc/version` | Kernel version | `cat /proc/version` |
| `cat /proc/cpuinfo` | CPU info | `cat /proc/cpuinfo` |
| `uname -a` | System info | `uname -a` |
| `last reboot` | Boot history | `last reboot` |

## Kernel Parameters (in /proc/cmdline)

| Parameter | Meaning |
|-----------|---------|
| `root=` | Root filesystem device/UUID |
| `ro` | Read-only at boot |
| `rw` | Read-write |
| `quiet` | Suppress boot messages |
| `splash` | Show boot splash |
| `single` | Single-user mode |
| `emergency` | Emergency shell |
| `systemd.unit=` | Target to boot |
| `BOOT_IMAGE=` | Kernel image path |

## systemd Boot Targets

| Target | Purpose | Command |
|--------|---------|---------|
| `multi-user.target` | Multi-user mode (no GUI) | `systemctl isolate multi-user.target` |
| `graphical.target` | GUI mode | `systemctl isolate graphical.target` |
| `rescue.target` | Rescue mode | `systemctl isolate rescue.target` |
| `emergency.target` | Emergency mode | `systemctl isolate emergency.target` |

## systemd Unit Management

| Command | Purpose | Example |
|---------|---------|---------|
| `systemctl get-default` | Show default target | `systemctl get-default` |
| `systemctl set-default` | Set default target | `sudo systemctl set-default multi-user.target` |
| `systemctl list-dependencies` | Show target dependencies | `systemctl list-dependencies graphical.target` |
| `systemctl list-units --type=target` | Show all targets | `systemctl list-units --type=target` |
| `systemctl status` | Show current target | `systemctl status` |

## Boot File Locations

| Path | Purpose |
|------|---------|
| `/boot/grub/grub.cfg` | GRUB configuration |
| `/etc/default/grub` | GRUB settings (edit this) |
| `/boot/vmlinuz-*` | Kernel images |
| `/boot/initramfs-*` | Initial RAM filesystem |
| `/proc/cmdline` | Kernel boot parameters |
| `/proc/version` | Kernel version |
| `/sys/firmware` | Firmware info |

## Boot Journal Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `journalctl -b` | This boot | `journalctl -b` |
| `journalctl -b -1` | Previous boot | `journalctl -b -1` |
| `journalctl --list-boots` | Show all boots | `journalctl --list-boots` |
| `journalctl -b -p err` | Boot errors | `journalctl -b -p err` |
| `journalctl -u unit -b` | Specific unit boot | `journalctl -u ssh -b` |

## GRUB Emergency Commands

| Command | Purpose |
|---------|---------|
| `ls` | List devices/partitions |
| `echo` | Print variables |
| `set` | Set variables |
| `insmod` | Load modules |
| `help` | Show help |
| `boot` | Boot system |
| `linux` | Load kernel |
| `initrd` | Load initramfs |

## Boot Recovery

| Scenario | Command |
|----------|---------|
| Access GRUB menu | Hold Shift/ESC during boot |
| Edit GRUB entry | Press 'e' in GRUB menu |
| Boot single-user | Add `single` to kernel line |
| GRUB command line | Press 'c' in GRUB menu |
| Boot live system | Use live USB/ISO |
| Check disk | `sudo fsck -n /dev/sda1` |
| Repair disk | `sudo fsck -y /dev/sda1` |
| Reinstall GRUB | `sudo grub-install /dev/sda` |

## initramfs

| Command | Purpose | Example |
|---------|---------|---------|
| `ls -lh /boot/initramfs*` | List initramfs | `ls -lh /boot/initramfs*` |
| `file /boot/initramfs*` | Check type | `file /boot/initramfs*` |
| `dracut` | Rebuild initramfs | `sudo dracut -f` |
| `update-initramfs` | Update initramfs (Debian) | `sudo update-initramfs -u` |

## Boot Sequence Overview

```
BIOS/UEFI
    ↓
GRUB Bootloader
    ↓
Load Kernel + initramfs
    ↓
Kernel Initialization
    ↓
Mount Root Filesystem
    ↓
Start systemd (PID 1)
    ↓
Load Services (systemd units)
    ↓
Reach Default Target (multi-user/graphical)
```
