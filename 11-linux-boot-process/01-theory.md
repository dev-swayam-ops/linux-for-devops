# Theory: Linux Boot Process

## Table of Contents

1. [High-Level Boot Sequence](#high-level-boot-sequence)
2. [Stage 1: BIOS/UEFI](#stage-1-biosuefi)
3. [Stage 2: Bootloader (GRUB)](#stage-2-bootloader-grub)
4. [Stage 3: Kernel Loading](#stage-3-kernel-loading)
5. [Stage 4: Early Kernel Initialization](#stage-4-early-kernel-initialization)
6. [Stage 5: systemd and Service Startup](#stage-5-systemd-and-service-startup)
7. [Runlevels vs Targets](#runlevels-vs-targets)
8. [Boot Parameters](#boot-parameters)
9. [Init Systems Comparison](#init-systems-comparison)

---

## High-Level Boot Sequence

```
┌─────────────────────────────────────────────────┐
│  Power Button Pressed                           │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  1. BIOS/UEFI Firmware Initialization          │
│     • Power-on self-test (POST)                │
│     • Initialize hardware (RAM, storage, etc.) │
│     • Locate boot device                       │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  2. Bootloader (GRUB2)                         │
│     • Load bootloader code into memory         │
│     • Display boot menu (if configured)        │
│     • Load kernel and initramfs                │
│     • Pass control to kernel                   │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  3. Kernel Initialization                      │
│     • Uncompress kernel                        │
│     • Initialize memory management             │
│     • Mount initramfs as root                  │
│     • Load essential drivers                   │
│     • Mount actual root filesystem             │
│     • Prepare /proc, /sys, /dev               │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  4. Init System Startup (systemd)              │
│     • Mount filesystems                        │
│     • Load kernel modules                      │
│     • Configure network                        │
│     • Start services (targets)                │
│     • Mount /home, /var, other filesystems    │
└──────────────┬──────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────┐
│  5. Login Prompt / System Ready                │
│     • Start getty processes (login shells)     │
│     • System fully operational                 │
└─────────────────────────────────────────────────┘
```

---

## Stage 1: BIOS/UEFI

### BIOS (Legacy)

**BIOS** = Basic Input/Output System

The BIOS is firmware stored on a chip on the motherboard. When you power on:

1. **Power-On Self-Test (POST)**
   - CPU tests itself
   - RAM is tested and counted
   - Built-in hardware is tested (storage, network cards, etc.)
   - If something is wrong, you hear beep codes or see error messages

2. **Hardware Discovery**
   - Devices report themselves to BIOS
   - BIOS discovers attached storage devices
   - Display device is initialized

3. **Boot Device Selection**
   - BIOS reads boot order from CMOS (non-volatile memory)
   - Typical order: HDD, SSD, USB, Network, CD-ROM
   - First device with valid bootloader is selected

4. **Bootloader Load**
   - BIOS reads first 512 bytes (Master Boot Record/MBR) from boot device
   - MBR contains partition table and bootloader code
   - First stage bootloader (~446 bytes) is loaded into memory at 0x7C00
   - CPU jumps to 0x7C00, bootloader takes control

**Limitations of BIOS:**
- Only 512-byte boot sector (limited bootloader size)
- MBR partition table supports max 4 primary partitions
- Only 1 MB addressable memory during boot
- No concept of firmware updates

### UEFI (Modern)

**UEFI** = Unified Extensible Firmware Interface

UEFI is the modern replacement for BIOS:

1. **More Powerful**
   - Can access more memory
   - Larger bootloader possible
   - User-friendly interface

2. **EFI Partition**
   - Requires GPT partitioning scheme
   - Has dedicated EFI System Partition (ESP)
   - Can be mounted at `/boot/efi`
   - Contains bootloader and boot configuration

3. **Boot Process**
   - UEFI firmware reads boot order
   - Loads bootloader from EFI partition
   - No 512-byte size limitation
   - Can have multiple boot entries

4. **Advantages**
   - Supports disks > 2 TB
   - Supports more partitions
   - Secure Boot (optional)
   - Better error reporting

**Check which firmware you have:**
```bash
ls -la /sys/firmware/efi
# If directory exists → UEFI
# If doesn't exist → BIOS
```

---

## Stage 2: Bootloader (GRUB)

### What is GRUB?

**GRUB** = Grand Unified Bootloader (version 2 is GRUB2, most common)

GRUB's job:
- Display boot menu (optional)
- Load Linux kernel from disk
- Load initial filesystem (initramfs)
- Pass boot parameters to kernel
- Hand off control to kernel

### GRUB Configuration

**Main config file:** `/boot/grub/grub.cfg` (generated, don't edit manually)

**Source config:** `/etc/default/grub`

Example `/etc/default/grub`:
```bash
GRUB_DEFAULT=0                          # Default menu entry (0 = first)
GRUB_TIMEOUT=5                          # Seconds before auto-boot
GRUB_TIMEOUT_STYLE=menu                 # Show menu
GRUB_DISTRIBUTOR="Ubuntu"               # Distro label
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"    # Default kernel parameters
GRUB_CMDLINE_LINUX=""                   # Additional parameters
GRUB_GFXMODE=1024x768                   # Display resolution
GRUB_DISABLE_RECOVERY=false             # Include recovery mode
```

### Updating GRUB

After editing `/etc/default/grub`, regenerate the config:

```bash
sudo update-grub                         # Debian/Ubuntu
# or
sudo grub2-mkconfig -o /boot/grub2/grub.cfg    # RHEL/CentOS
```

### GRUB Boot Menu Entry

Inside `/boot/grub/grub.cfg`, you see entries like:

```grub
menuentry 'Ubuntu' {
    search --no-floppy --label Ubuntu --set root
    linuxefi /boot/vmlinuz-5.15.0-56-generic root=UUID=abc123 ro quiet splash
    initrdefi /boot/initrd.img-5.15.0-56-generic
}
```

What happens:
1. **search** - Find the Ubuntu partition
2. **linuxefi** - Load kernel file, tell it where root filesystem is (`root=`), other parameters
3. **initrdefi** - Load initial filesystem
4. GRUB passes control to kernel

### Key GRUB Concepts

**Menu entries** - One entry per kernel/OS

**Kernel file** (vmlinuz) - Compressed Linux kernel
- Filename: `vmlinuz-KERNEL-VERSION`
- Location: `/boot/` (accessible before root filesystem mounted)
- Re-generated by kernel updates

**Initramfs** - Initial RAM filesystem
- Minimal filesystem containing drivers, init script
- Loads early, before actual root filesystem
- Contains essential drivers for detecting hardware
- Once real root is mounted, initramfs is discarded
- File: `initrd.img-KERNEL-VERSION`

**Boot parameters** - Options passed to kernel
- `root=` - Device/UUID of root filesystem
- `ro` - Mount root read-only initially
- `quiet` - Suppress boot messages
- `splash` - Show boot splash screen
- Can be modified at boot time by editing GRUB menu entry

---

## Stage 3: Kernel Loading

### Kernel Handoff

1. **BIOS/UEFI loads bootloader** → Bootloader loads kernel
2. **Bootloader jumps to kernel entry point**
   - Kernel is compressed (zImage or bzImage)
   - Decompression happens in-memory
   - Control passes to decompressed kernel code

### What the Kernel Does First

1. **Check CPU features** - Verify CPU supports required features (MMU, PAE, etc.)

2. **Initialize memory management**
   - Set up paging (virtual memory)
   - Initialize kernel memory allocator

3. **Initialize interrupts**
   - Set up interrupt handlers for CPU, hardware devices
   - Timer interrupt setup

4. **Mount initramfs as temporary root**
   - Kernel mounts initramfs as root filesystem at `/`
   - Control passes to init program in initramfs

```
Initial state (after kernel starts):
/
├── bin/
├── sbin/
├── lib/
├── init           ← Small init script or systemd binary
├── proc/          ← Will be mounted as /proc
├── sys/           ← Will be mounted as /sys
└── ...
```

---

## Stage 4: Early Kernel Initialization

### The Initramfs Init Script

The initramfs contains a small init script (or systemd) that:

1. **Mount kernel filesystems**
   ```bash
   mount -t proc proc /proc
   mount -t sysfs sysfs /sys
   mount -t devtmpfs devtmpfs /dev
   ```

2. **Load kernel modules**
   - Storage drivers (SATA, NVMe, RAID)
   - Filesystem drivers (ext4, btrfs, etc.)
   - Network drivers

3. **Detect root filesystem**
   - Find device containing root filesystem
   - Could be: partition on local disk, NFS mount, iSCSI, etc.
   - Uses `root=` parameter from bootloader

4. **Mount root filesystem**
   ```bash
   mount /dev/sda1 /sysroot    # Mount real root
   cd /sysroot
   pivot_root . initramfs      # Switch to real root
   exec /sbin/init             # Start real init system
   ```

5. **Switch to real root**
   - Once real root filesystem is mounted
   - Use `pivot_root` or similar to switch
   - Initramfs is released from memory

**Timeline:**
```
BIOS → GRUB loads kernel → Kernel initializes → 
Kernel loads initramfs as root → Initramfs init script runs → 
Initramfs mounts real root → Switches to real init system
```

### Viewing Boot Messages

Kernel writes boot messages to:
- Kernel ring buffer (volatile, lost at reboot)
- Check with: `dmesg` or `journalctl`

---

## Stage 5: systemd and Service Startup

### systemd Becomes PID 1

After root filesystem switch, systemd starts as PID 1 (init process):

```bash
/sbin/systemd   # Becomes PID 1
```

PID 1 = Special system process:
- Adopts orphaned processes
- Handles shutdown sequence
- Manages all services

### systemd Boot Sequence

```
systemd (PID 1) starts

1. Read /etc/systemd/system/
2. Determine default target (e.g., multi-user.target)
3. Activate default target
4. Target activates service units it depends on
5. Services start in dependency order
6. Once target reached → login prompt appears
```

### Targets (Systemd Runlevels)

Targets define system state:

| Target | SysV Runlevel | Purpose |
|--------|---|---------|
| `poweroff.target` | 0 | System shut down |
| `rescue.target` | 1 | Single-user mode, minimal services |
| `multi-user.target` | 2,3,4 | Multi-user, no GUI |
| `graphical.target` | 5 | Multi-user with GUI |
| `reboot.target` | 6 | System reboot |

**Default target** is usually `multi-user.target` or `graphical.target`

Check default:
```bash
systemctl get-default
```

### Service Startup Order

Services have dependencies. systemd respects them:

```ini
# Example: /etc/systemd/system/myapp.service

[Unit]
Description=My Application
After=network.target        # Start after networking is ready
Wants=network-online.target # Request network to be available
Requires=database.service   # MUST have database running

[Service]
Type=simple
ExecStart=/usr/bin/myapp
Restart=on-failure

[Install]
WantedBy=multi-user.target  # This service belongs to multi-user target
```

systemd ensures:
- `database.service` starts before `myapp.service`
- Networking is initialized before `myapp.service`
- If `database.service` fails, `myapp.service` won't start

### Key Concepts

**Unit** - A resource systemd manages (service, target, socket, timer, etc.)

**Service** - Long-running daemon process
- `.service` files in `/etc/systemd/system/` or `/usr/lib/systemd/system/`

**Target** - Logical grouping of units (replaces runlevels)
- `.target` files
- Multi-user.target groups services needed for multi-user environment

**Socket** - Network or IPC socket
- `.socket` files
- Service can be socket-activated (starts on first connection)

**Timer** - Scheduled execution (like cron)
- `.timer` files

---

## Runlevels vs Targets

### Legacy: Runlevels (SysV Init)

Runlevels (0-6) defined system state:

```
0 - Halt
1 - Single-user mode
2 - Multi-user (Debian/Ubuntu default, no NFS)
3 - Multi-user with networking
4 - Unused
5 - Multi-user with GUI
6 - Reboot
```

Init scripts:
- `/etc/rc.d/rcN.d/` directories (N = runlevel)
- `S` prefix = Start (ascending priority)
- `K` prefix = Kill (descending priority)

Example:
```
/etc/rc.d/rc3.d/
├── S10network    → Start network service
├── S20ssh        → Start SSH
├── S30apache2    → Start Apache
└── K30apache2    → Kill Apache (on shutdown)
```

### Modern: Targets (systemd)

Targets are more flexible:

```
poweroff.target
rescue.target
multi-user.target
graphical.target
reboot.target
```

Can depend on each other:
```
graphical.target
└── Depends on: multi-user.target
    └── Depends on: basic.target, network-online.target
        └── Depends on: network.target, sysinit.target
```

**Advantages of targets:**
- More parallel startup (less sequential waiting)
- Services can be added/removed without scripts
- Dependencies are explicit
- Better for server environments

---

## Boot Parameters

### What Are Boot Parameters?

Kernel parameters are options passed to the kernel at boot time via GRUB.

They control:
- Root device location
- Init system
- Logging levels
- Hardware parameters
- Performance tuning

### Common Parameters

```bash
# ===== ROOT FILESYSTEM =====
root=/dev/sda1              # Device path
root=UUID=12345...          # UUID (preferred, more stable)
root=LABEL=MyLinux          # Partition label

# ===== FILESYSTEM MOUNT =====
ro                          # Mount root read-only initially
rw                          # Mount root read-write (rarely used)

# ===== BOOT TIME CONTROL =====
splash                      # Show boot splash screen
quiet                       # Suppress most boot messages
verbose                     # Show all boot messages
debug                       # Enable debug messages

# ===== SINGLE USER MODE =====
single                      # Boot to single-user mode (root shell)
1                          # Same as single

# ===== KERNEL BEHAVIOR =====
panic=10                    # Reboot after 10 seconds if kernel panic
systemd.unit=rescue.target  # Boot into rescue target instead of default
init=/bin/bash              # Use bash instead of init (emergency only)

# ===== HARDWARE PARAMETERS =====
mem=512M                    # Limit RAM to 512 MB
pci=nomsi                   # Disable MSI interrupts (for some hardware issues)
nomodeset                   # Disable kernel video mode setting (use for GPU issues)

# ===== PERFORMANCE =====
quiet                       # Reduces boot-time I/O
elevator=noop               # Scheduler (deadline, cfq, noop)
```

### How to Pass Parameters

**At boot time** (GRUB menu):
1. Press `e` to edit GRUB entry
2. Find line starting with `linux` or `linuxefi`
3. Add parameters at end: `ro quiet splash myparameter=value`
4. Press `Ctrl+X` to boot with modifications

**Permanently** (modify `/etc/default/grub`):
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
# Change to:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mem=512M"
```
Then run:
```bash
sudo update-grub
```

### Viewing Current Parameters

```bash
cat /proc/cmdline           # Parameters kernel was booted with
```

---

## Init Systems Comparison

### systemd (Modern, Current Standard)

**Characteristics:**
- Parallel service startup
- Dependency-based ordering
- Socket activation
- Timer support
- Integration with logging (journald)
- Powerful CLI (`systemctl`, `journalctl`)

**Adoption:**
- Debian/Ubuntu 15.04+
- CentOS/RHEL 7+
- Most modern distributions

**Boot speed:** Fast, parallelization

**Files:**
- `/etc/systemd/system/` - System-wide units
- `/usr/lib/systemd/system/` - Default units
- `.service`, `.target`, `.socket` files

### SysV Init (Legacy)

**Characteristics:**
- Sequential service startup
- Runlevel-based (0-6)
- Shell scripts
- No dependencies (order determined by filename)

**Adoption:**
- Debian/Ubuntu before 15.04
- CentOS/RHEL 6 and earlier
- Some embedded systems

**Boot speed:** Slower due to sequential startup

**Files:**
- `/etc/rc.d/rcN.d/` directories
- `/etc/init.d/` - Init scripts
- Numbered filenames (S10, K20, etc.)

### Comparison Table

| Aspect | systemd | SysV Init |
|--------|---------|-----------|
| Startup | Parallel | Sequential |
| Config | Units (JSON/ini) | Shell scripts |
| Dependencies | Explicit | Implicit (filename order) |
| Boot speed | ~1-5 seconds | ~5-15 seconds |
| Log viewing | `journalctl` | `/var/log/` files |
| Service control | `systemctl` | `/etc/init.d/` scripts |
| Scalability | Excellent | Limited |

---

## Common Boot Issues and Causes

### Kernel Panic

**Symptom:** System stops, error message like "Kernel panic - not syncing"

**Causes:**
- Missing essential driver
- Incompatible kernel parameter
- Hardware failure
- Corrupted initramfs

**Recovery:**
1. Boot with `ro` parameter
2. Add `nomodeset` if GPU issue
3. Check dmesg for error details

### Grub Not Loading

**Symptom:** BIOS/UEFI fails to find bootloader

**Causes:**
- GRUB not installed on boot partition
- Boot partition not marked as active (MBR)
- Wrong UEFI boot order
- Corrupted MBR/EFI partition

**Recovery:**
- Boot from USB
- Reinstall GRUB: `sudo grub-install /dev/sda`

### Filesystem Check Hangs

**Symptom:** Boot hangs at "Checking filesystem"

**Causes:**
- Corrupted filesystem
- Hardware failure (disk bad sectors)
- UUID mismatch in /etc/fstab

**Recovery:**
- Add `fsck.mode=skip` to GRUB to skip fsck
- Run fsck manually from live USB

---

## Summary

The boot process is a carefully orchestrated sequence:

1. **BIOS/UEFI** - Hardware initialization
2. **GRUB** - Load kernel and initial filesystem
3. **Kernel** - Initialize memory, mount initramfs, find real root
4. **Initramfs** - Load drivers, mount real root filesystem
5. **systemd** - Start services, reach target state
6. **Login** - System ready for user

Understanding this process allows you to:
- Troubleshoot boot failures
- Optimize boot time
- Secure the boot process
- Customize startup behavior
- Manage multi-boot systems
