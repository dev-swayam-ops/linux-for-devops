# Module 11: Linux Boot Process

## What You'll Learn

- Understand the Linux boot sequence from BIOS to kernel
- Navigate GRUB bootloader configuration
- Analyze kernel initialization and logs
- Recover from boot failures
- Understand systemd boot process
- Monitor boot performance
- Work with boot parameters

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Comfortable with command-line navigation
- Understanding of files and permissions
- Basic knowledge from Module 6 (systemd)

## Key Concepts

| Concept | Description |
|---------|-------------|
| **BIOS/UEFI** | Firmware that starts bootloader |
| **GRUB** | Grand Unified Bootloader - loads kernel |
| **Kernel** | Linux core that initializes hardware |
| **initramfs** | Initial RAM filesystem for boot |
| **systemd** | Init system that starts services after kernel |
| **Boot Parameters** | Kernel arguments passed at boot |
| **RunLevel** | System mode (single-user, multi-user) |
| **Boot Order** | Priority of boot devices |

## Hands-on Lab: Examine Boot Process

### Lab Objective
Analyze boot logs and understand the boot sequence.

### Commands

```bash
# View boot messages
dmesg | head -50

# Show last boot time
last reboot | head -5

# View systemd boot analysis
systemd-analyze
# Shows: Startup finished in ...

# Detailed boot chart
systemd-analyze plot > boot.svg

# View GRUB configuration
cat /boot/grub/grub.cfg | head -20

# Show default boot entry
grub-editenv list

# View kernel parameters used
cat /proc/cmdline

# Check initramfs
ls -lh /boot/initramfs*

# View boot journal
journalctl -b
# -b = this boot

# Show previous boots
journalctl --list-boots

# Check boot messages
journalctl -b -p err
# Shows errors only

# View grub menu (edit on next boot)
# Press 'e' during boot

# Get system boot time
systemd-analyze time
```

### Expected Output

```
# systemd-analyze output:
Startup finished in 2.345s (firmware) + 1.234s (loader) + 3.456s (kernel) + 5.789s (userspace) = 12.824s

# dmesg output:
[    0.000000] Linux version 5.15.0-84-generic (build@ubuntu) ...
[    0.000000] KERNEL supported cpus:
[    0.000000] x86/fpu: Supporting XSAVE feature ...
```

## Validation

Confirm successful completion:

- [ ] Viewed kernel boot messages with dmesg
- [ ] Analyzed systemd boot time
- [ ] Identified default GRUB entry
- [ ] Found kernel parameters
- [ ] Reviewed boot journal
- [ ] Understood boot sequence

## Cleanup

```bash
# No cleanup needed - read-only operations
# Boot logs are system information
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Modifying GRUB config directly | Use grub-mkconfig, then update-grub |
| Kernel panic at boot | Boot with single-user mode from GRUB |
| Lost GRUB | Reinstall with live USB/recovery mode |
| Unbootable after config | Keep backups of /boot and grub.cfg |
| Forgetting to run update-grub | Changes to /etc/default/grub need update-grub |

## Troubleshooting

**Q: How do I access GRUB menu?**
A: Hold Shift or ESC during boot. Edit with 'e', boot with Ctrl+X.

**Q: System won't boot - what happened?**
A: Check BIOS boot order, verify disk isn't corrupted, boot from live USB.

**Q: How do I see kernel boot messages?**
A: Use `dmesg` or `journalctl -b` to view kernel logs.

**Q: What are kernel parameters?**
A: Arguments passed to kernel at boot. View with `cat /proc/cmdline`.

**Q: How do I boot into single-user mode?**
A: Edit GRUB entry, add `single` to kernel line, press Ctrl+X.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Study GRUB configuration deep-dive
3. Learn about initramfs customization
4. Master boot failure recovery
5. Explore systemd-boot (UEFI alternative)
