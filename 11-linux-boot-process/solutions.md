# Linux Boot Process: Solutions

## Exercise 1: View Boot Messages

**Solution:**

```bash
# Show kernel boot messages
dmesg | head -50
# Output: Linux version, BIOS info, hardware detection

# Filter for CPU
dmesg | grep -i "cpu"
# Output: CPU0: Intel Core i7, ...

# Find device detection
dmesg | grep -i "detected"
# Output: Detected 8192 memory regions, ATA Disk detected

# Show errors only
dmesg -l err
# or
dmesg -l err,warn

# All messages since boot
dmesg | tail -20
# Last 20 messages
```

**Explanation:** `dmesg` = kernel ring buffer. `-l` = log level filter.

---

## Exercise 2: Analyze Boot Time

**Solution:**

```bash
# Show systemd boot timing breakdown
systemd-analyze
# Output:
# Startup finished in 2.345s (firmware) + 1.234s (loader) + 
# 3.456s (kernel) + 5.789s (userspace) = 12.824s

# Detailed breakdown per unit
systemd-analyze blame | head -10
# Shows slowest services

# Critical path
systemd-analyze critical-chain
# Shows dependency chain

# Generate boot chart (SVG)
systemd-analyze plot > boot.svg

# View specific boot
systemd-analyze -b -1
# Previous boot
```

**Explanation:** Firmware = BIOS. Loader = GRUB. Kernel = init. Userspace = services.

---

## Exercise 3: Examine GRUB Configuration

**Solution:**

```bash
# View GRUB config
cat /boot/grub/grub.cfg | head -30

# Find default entry
grub-editenv list
# Output: saved_entry=0 (or service name)

# Show kernel command lines
grep "^linux" /boot/grub/grub.cfg | head -5

# Find boot device
grep -E "set root=|search" /boot/grub/grub.cfg | head

# Count boot entries
grep "menuentry" /boot/grub/grub.cfg | wc -l

# GRUB structure:
# menuentry "Ubuntu" { (entry name)
#   linux /boot/vmlinuz-... (kernel)
#   initrd /boot/initramfs-... (initial ram disk)
# }
```

**Explanation:** Don't edit grub.cfg directly. Edit /etc/default/grub, then run update-grub.

---

## Exercise 4: Check Kernel Parameters

**Solution:**

```bash
# View all kernel parameters
cat /proc/cmdline
# Output: BOOT_IMAGE=/boot/vmlinuz-... root=UUID=... ro quiet splash

# Split into readable format
cat /proc/cmdline | tr ' ' '\n'
# Output:
# BOOT_IMAGE=/boot/vmlinuz-5.15.0
# root=UUID=12345678-1234-1234-1234-123456789012
# ro
# quiet
# splash

# Identify key parameters:
# root= : Root filesystem location
# ro : Read-only at boot
# quiet : Suppress boot messages
# ro: Read-only
# rw: Read-write

# Check for single-user mode (emergency)
cat /proc/cmdline | grep -q "single" && echo "Single user"
```

**Explanation:** Parameters affect kernel behavior. Can be edited in GRUB before boot.

---

## Exercise 5: Understand initramfs

**Solution:**

```bash
# List initramfs files
ls -lh /boot/initramfs*
# Output: -rw-r--r-- 45M initramfs-5.15.0-84-generic.img

# Check file type
file /boot/initramfs*
# Output: gzip compressed data

# Compare versions
ls -lh /boot/initramfs* /boot/vmlinuz*

# Show initramfs location
grep initramfs /boot/grub/grub.cfg | head -3

# Purpose: provides temporary filesystem with
# drivers needed before mounting real root
```

**Explanation:** initramfs = temporary root filesystem. Contains drivers for hardware + mount utilities.

---

## Exercise 6: Analyze Boot Journal

**Solution:**

```bash
# View this boot's journal
journalctl -b
# All messages since last boot

# Previous boots
journalctl --list-boots
# Output:
# -2 (Jan 20 10:00-15:00, 5h)
# -1 (Jan 21 09:00-12:00, 3h)
#  0 (Jan 21 13:00-present, 1h30m)

# View previous boot
journalctl -b -1

# Filter by severity
journalctl -b -p err
# Errors and critical

# Show startup errors
journalctl -b -u systemd
# systemd-specific logs

# Check service startup time
journalctl -b | grep "Started\|Failed"
```

**Explanation:** journalctl = systemd journal. `-b` = this boot. `-u` = unit filter.

---

## Exercise 7: Monitor Boot Performance

**Solution:**

```bash
# Slowest units
systemd-analyze blame | head -5
# Output:
#  8.234s postgresql.service
#  6.123s docker.service
#  3.456s ssh.service

# Critical path (dependency chain)
systemd-analyze critical-chain
# Output: graphical.target @5.789s
#   └─multi-user.target @5.789s
#     └─ssh.service @2.333s
#       └─network-online.target @1.234s

# Graph dependencies
systemd-analyze plot | head
# Shows graphical boot sequence

# Identify parallelizable services
systemd-analyze verify --user
```

**Explanation:** Services running in parallel boot faster. Critical path = bottleneck.

---

## Exercise 8: Check Boot Sequence

**Solution:**

```bash
# Default system target
systemctl get-default
# Output: graphical.target (or multi-user.target)

# List all targets
systemctl list-units --type=target --all
# Output:
# basic.target loaded active active Basic System
# multi-user.target loaded active active Multi-User System
# graphical.target loaded active active Graphical Interface

# Show boot-time services
systemctl list-dependencies --type=service graphical.target
# Services required for graphical target

# Check active target
systemctl status
# Shows current target

# Get boot process order
systemctl list-dependencies graphical.target
```

**Explanation:** Targets = systemd goals. Boot runs services to reach default target.

---

## Exercise 9: Boot Parameters and Options

**Solution:**

```bash
# Current kernel parameters
cat /proc/cmdline
# Output: BOOT_IMAGE=/boot/vmlinuz-5.15.0-84 root=UUID=... ro quiet splash

# Common parameters:
# ro = Read-only at boot
# rw = Read-write
# root=/dev/sda1 = Root filesystem
# quiet = Suppress messages
# splash = Show boot splash
# single = Single-user mode
# emergency = Emergency shell
# systemd.unit=rescue.target = Boot to rescue

# Document parameters
echo "Kernel Boot Parameters:" > boot_params.txt
cat /proc/cmdline >> boot_params.txt

# Analyze parameter purposes
# root= : Mounts root filesystem
# ro : Prevents early writes
# quiet : Hides non-critical boot output
```

**Explanation:** Parameters modify kernel behavior. Edit in GRUB menu with 'e' key.

---

## Exercise 10: Boot Recovery Scenarios

**Solution:**

```bash
# Recovery Guide

# Scenario 1: Can't boot - access GRUB emergency
# At GRUB menu (hold Shift/ESC):
# Press 'c' for GRUB command line
# Commands: ls, echo, help, insmod, set

# Scenario 2: Boot into single-user mode
# Edit GRUB entry (press 'e'):
# Find line: linux /boot/vmlinuz-... root=...
# Add: single
# Press Ctrl+X to boot

# Scenario 3: Root filesystem corrupted
# Boot from live USB
# Mount root: mount /dev/sda1 /mnt
# Check: fsck -n /dev/sda1
# Repair: fsck -y /dev/sda1

# Scenario 4: Reinstall GRUB
# Boot from live USB
# mount /dev/sda1 /mnt
# grub-install --root-directory=/mnt /dev/sda

# Boot Recovery Checklist
cat > boot_recovery_checklist.txt << 'EOF'
[ ] Check BIOS boot device order
[ ] Verify disk is detected
[ ] Try GRUB recovery console
[ ] Boot single-user mode
[ ] Check root filesystem
[ ] Run fsck if needed
[ ] Verify /boot partition
[ ] Check grub.cfg file
[ ] Test kernel parameters
[ ] Reinstall GRUB if needed
EOF
```

**Explanation:** Multiple recovery paths. Always keep live USB ready. Test GRUB recovery commands.
