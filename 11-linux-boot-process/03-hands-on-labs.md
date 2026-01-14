# Hands-On Labs: Boot Process

All labs should be performed on a **VM or test system**, NOT on a production machine.

---

## Lab 1: Inspect Your Current Boot Sequence

**Goal:** Understand your system's boot parameters and configuration

**Time:** 10 minutes

### Setup

No special setup needed. Work on your current system.

### Steps

1. **Check your firmware type (BIOS or UEFI)**
   ```bash
   ls -la /sys/firmware/efi
   ```
   - If directory exists → **UEFI system**
   - If "No such file" → **BIOS system**

2. **View kernel version and boot command line**
   ```bash
   uname -a
   cat /proc/cmdline
   ```

3. **View detailed boot messages from current boot**
   ```bash
   journalctl -b --no-pager | head -30
   ```

4. **Check boot target**
   ```bash
   systemctl get-default
   ```

5. **Check system uptime (time since last boot)**
   ```bash
   uptime
   ```

6. **View GRUB default configuration** (Debian/Ubuntu)
   ```bash
   cat /etc/default/grub
   ```

### Expected Output

```
$ ls -la /sys/firmware/efi
total 0
drwxr-xr-x  4 root root    0 Jan 15 10:22 .
drwxr-xr-x 16 root root 4096 Jan 15 10:22 ..
drwxr-xr-x  2 root root    0 Jan 15 10:22 efivars
drwxr-xr-x  2 root root    0 Jan 15 10:22 fw_platform_size

$ cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.0-56-generic root=UUID=abc123 ro quiet splash

$ systemctl get-default
graphical.target

$ uptime
 23:45:32 up 2 days,  3:51,  2 users,  load average: 0.15, 0.12, 0.09
```

### Verification Checklist

- [ ] You identified your firmware type
- [ ] You viewed kernel boot parameters
- [ ] You saw at least 30 boot messages
- [ ] You know your current default target
- [ ] You understand uptime format

### Cleanup

No cleanup needed.

---

## Lab 2: Analyze GRUB Configuration

**Goal:** Understand GRUB structure and how to interpret boot entries

**Time:** 15 minutes

### Setup

No special setup needed.

### Steps

1. **View GRUB default settings**
   ```bash
   cat /etc/default/grub
   ```

2. **View generated GRUB config** (first 50 lines)
   ```bash
   head -50 /boot/grub/grub.cfg
   ```

3. **Count total boot menu entries**
   ```bash
   grep -c "^menuentry" /boot/grub/grub.cfg
   ```

4. **Extract first boot entry details**
   ```bash
   grep -A 5 "^menuentry" /boot/grub/grub.cfg | head -10
   ```

5. **Find current kernel version**
   ```bash
   ls -1 /boot/vmlinuz-* | tail -1
   ls -1 /boot/initrd* | tail -1
   ```

6. **Check if GRUB timeout is reasonable**
   ```bash
   grep GRUB_TIMEOUT /etc/default/grub
   ```

### Expected Output

```
$ cat /etc/default/grub
# GRUB boot loader configuration
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Ubuntu"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""

$ grep -c "^menuentry" /boot/grub/grub.cfg
3

$ ls -1 /boot/vmlinuz-*
/boot/vmlinuz-5.15.0-56-generic
/boot/vmlinuz-5.15.0-54-generic

$ ls -1 /boot/initrd*
/boot/initrd.img-5.15.0-56-generic
/boot/initrd.img-5.15.0-54-generic
```

### Verification Checklist

- [ ] You viewed GRUB defaults
- [ ] You understand what `/etc/default/grub` is for
- [ ] You know the difference between `/etc/default/grub` and `/boot/grub/grub.cfg`
- [ ] You counted boot entries
- [ ] You identified your latest kernel

### Cleanup

No cleanup needed.

---

## Lab 3: Examine Boot Logs in Detail

**Goal:** Learn to read and interpret boot messages

**Time:** 20 minutes

### Setup

No special setup needed.

### Steps

1. **Get overall boot statistics**
   ```bash
   systemd-analyze
   ```

2. **Find slowest services during boot** (top 10)
   ```bash
   systemd-analyze blame | head -10
   ```

3. **View critical boot path**
   ```bash
   systemd-analyze critical-chain | head -20
   ```

4. **Check boot messages by priority**
   ```bash
   journalctl -b -p err..alert | head -20
   ```

5. **View specific service boot logs**
   ```bash
   journalctl -u systemd-fsck-root.service -b
   ```

6. **Check for failed units at boot**
   ```bash
   systemctl list-units --state=failed
   ```

7. **Get kernel messages only**
   ```bash
   dmesg | head -50
   ```

### Expected Output

```
$ systemd-analyze
Startup finished in 2.341s (kernel) + 15.234s (initramfs) + 34.123s (userspace) = 51.698s

$ systemd-analyze blame | head -5
        5.234s apt-daily.service
        3.123s snapd.service
        2.456s ssh.service
        1.234s systemd-tmpfiles-setup.service
        0.890s e2scrub_reap.service

$ systemctl list-units --state=failed
(empty output = no failures)
```

### Verification Checklist

- [ ] You know total system boot time
- [ ] You identified slowest services
- [ ] You understand critical chain concept
- [ ] You can filter journal by priority
- [ ] You know how to check for boot errors

### Cleanup

No cleanup needed.

---

## Lab 4: Modify Kernel Boot Parameters (Temporarily)

**Goal:** Learn to modify boot parameters safely using GRUB

**Time:** 15 minutes

### Setup

You'll need to reboot. Make sure you have another way to access the system if something goes wrong (BIOS/UEFI recovery, live USB, or VM snapshot).

### Steps

1. **View current boot parameters**
   ```bash
   cat /proc/cmdline
   ```

2. **Reboot into GRUB menu**
   ```bash
   sudo reboot
   ```

3. **At GRUB menu, press `e`** to edit

4. **Find the line starting with `linux` or `linuxefi`**
   - This line contains kernel parameters

5. **At end of that line, add a test parameter:**
   ```
   verbose
   ```
   - This enables verbose boot messages

6. **Press `Ctrl+X` to boot with modifications**

7. **System boots with verbose messages** - you should see many more boot messages

8. **After login, verify parameter was used**
   ```bash
   cat /proc/cmdline | grep verbose
   ```

### Expected Output

```
$ cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.0-56-generic root=UUID=abc123 ro verbose

# Boot messages will be verbose (much more output)
```

### Verification Checklist

- [ ] You successfully edited GRUB entry
- [ ] System booted with your parameter
- [ ] Parameter shows in `/proc/cmdline`
- [ ] System is still functional

### Common Issues

| Problem | Solution |
|---------|----------|
| Syntax error when pressing Ctrl+X | Press Escape, try again. Make sure you edited the `linux` line. |
| System won't boot | Reboot again, remove your parameter in GRUB, press Ctrl+X again. |
| Don't see GRUB menu | Hold Shift during boot startup |

### Cleanup

This change is temporary (only for that one boot). On next reboot, parameters are back to normal.

---

## Lab 5: Permanently Modify Kernel Boot Parameters

**Goal:** Make permanent kernel parameter changes via `/etc/default/grub`

**Time:** 20 minutes

### Setup

Save your current GRUB config as backup:
```bash
sudo cp /etc/default/grub /etc/default/grub.bak
```

### Steps

1. **View current GRUB defaults**
   ```bash
   cat /etc/default/grub
   ```

2. **Find the GRUB_CMDLINE_LINUX_DEFAULT line**
   ```bash
   grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
   ```

3. **Edit the file**
   ```bash
   sudo nano /etc/default/grub
   ```
   (Or use vim, gedit, etc.)

4. **Find this line:**
   ```
   GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
   ```

5. **Change it to:**
   ```
   GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3"
   ```
   (loglevel=3 reduces kernel message verbosity)

6. **Save and exit** (Ctrl+O, Enter, Ctrl+X in nano)

7. **Regenerate GRUB configuration**
   ```bash
   sudo update-grub
   ```
   (Debian/Ubuntu) or
   ```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg
   ```
   (RHEL/CentOS)

8. **Verify changes were applied**
   ```bash
   grep -A 2 "^menuentry" /boot/grub/grub.cfg | grep linuxefi | head -1
   ```

9. **Reboot to apply**
   ```bash
   sudo reboot
   ```

10. **After reboot, verify parameter is active**
    ```bash
    cat /proc/cmdline
    ```

### Expected Output

```
$ grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3"

# After update-grub:
$ grep linuxefi /boot/grub/grub.cfg | head -1
        linuxefi /boot/vmlinuz-5.15.0-56-generic root=UUID=abc123 ro quiet splash loglevel=3

# After reboot:
$ cat /proc/cmdline
BOOT_IMAGE=/boot/vmlinuz-5.15.0-56-generic root=UUID=abc123 ro quiet splash loglevel=3
```

### Verification Checklist

- [ ] You backed up original GRUB config
- [ ] You edited `/etc/default/grub`
- [ ] You ran `update-grub`
- [ ] Parameter appears in GRUB menu entry
- [ ] System boots successfully
- [ ] Parameter shows in `/proc/cmdline`

### Cleanup

To revert to original:
```bash
sudo cp /etc/default/grub.bak /etc/default/grub
sudo update-grub
sudo reboot
```

---

## Lab 6: Explore systemd Boot Targets

**Goal:** Understand and switch between systemd targets

**Time:** 15 minutes

### Setup

No special setup needed.

### Steps

1. **View current default target**
   ```bash
   systemctl get-default
   ```

2. **List all available targets**
   ```bash
   systemctl list-units --type=target --all
   ```

3. **View what's in multi-user.target**
   ```bash
   systemctl list-dependencies multi-user.target | head -30
   ```

4. **View what's in graphical.target**
   ```bash
   systemctl list-dependencies graphical.target | head -30
   ```

5. **Check which services are enabled at boot**
   ```bash
   systemctl list-unit-files --type=service | grep enabled | head -10
   ```

6. **Check a specific service's boot behavior**
   ```bash
   systemctl is-enabled ssh.service
   systemctl is-enabled snapd.service
   ```

### Expected Output

```
$ systemctl get-default
graphical.target

$ systemctl list-units --type=target --all | head -10
  UNIT                       LOAD   ACTIVE   SUB    DESCRIPTION
  basic.target               loaded active   active Basic System
  cryptsetup.target          loaded inactive dead   Encrypted Volumes
  graphical.target           loaded active   active Graphical Interface
  local-fs-pre.target        loaded active   active Local File Systems (Pre)
  local-fs.target            loaded active   active Local File Systems
  multi-user.target          loaded active   active Multi-User System
  network-online.target      loaded inactive dead   Network is Online
  network.target             loaded active   active Network
  paths.target               loaded active   active Paths

$ systemctl is-enabled ssh.service
enabled

$ systemctl is-enabled snapd.service
enabled
```

### Verification Checklist

- [ ] You know your current default target
- [ ] You listed all available targets
- [ ] You understand the difference between targets
- [ ] You found enabled services
- [ ] You can check service boot behavior

### Cleanup

No cleanup needed.

---

## Lab 7: Boot into Single-User Mode (Safe Mode)

**Goal:** Learn to access single-user mode for troubleshooting

**Time:** 15 minutes

### Setup

This lab requires rebooting. Have a backup method to recover (live USB) in case of issues.

### Steps

1. **Method 1: From running system (interactive rescue mode)**
   ```bash
   sudo systemctl rescue
   ```
   - This enters rescue target (minimal services, root shell)
   - System is still responsive
   - Other users are logged out

2. **Press Enter at any prompt to continue to shell**

3. **Verify you're in rescue mode**
   ```bash
   systemctl get-default
   ```
   This will show `rescue.target`

4. **View what's running**
   ```bash
   ps aux | head -15
   ```

5. **Exit rescue mode**
   ```bash
   exit
   ```
   System returns to default target

### Alternative Method: Boot Parameter

1. **Reboot**
   ```bash
   sudo reboot
   ```

2. **At GRUB menu, press `e` to edit**

3. **Find `linux` or `linuxefi` line**

4. **At end, change `quiet splash` to just `single`**

5. **Press `Ctrl+X` to boot**

6. **System boots into root shell** (no graphical interface)

7. **Verify**
   ```bash
   ps aux | grep -i getty
   ```
   No getty processes (login shells) running

8. **Reboot normally**
   ```bash
   exit
   ```

### Expected Output

```
$ sudo systemctl rescue
[... system switches to rescue mode ...]

Press ENTER to enter the emergency shell.
Ctrl-d, Ctrl-c or systemctl default to exit
exit

# Or single-user boot:
# You get a bare root prompt:
root@ubuntu: #
```

### Verification Checklist

- [ ] You entered rescue target successfully
- [ ] You accessed interactive shell
- [ ] You exited and returned to normal mode
- [ ] System is still fully functional after exiting

### Cleanup

No cleanup needed (exiting rescue mode restores normal operation).

---

## Lab 8: Analyze and Optimize Boot Time

**Goal:** Identify slow services and optimize boot sequence

**Time:** 20 minutes

### Setup

No special setup needed.

### Steps

1. **Get overall boot timing**
   ```bash
   systemd-analyze
   ```

2. **Find slowest services**
   ```bash
   systemd-analyze blame | head -15
   ```

3. **View boot dependency chain**
   ```bash
   systemd-analyze critical-chain | head -20
   ```

4. **Generate boot sequence visualization**
   ```bash
   systemd-analyze plot > /tmp/boot.svg
   ```

5. **View the SVG** (copy to browser or use GIMP)
   ```bash
   file /tmp/boot.svg
   ```

6. **Identify candidates for disabling**
   ```bash
   systemctl list-unit-files --type=service | grep enabled | tail -20
   ```

7. **For example, if snapd is slow and you don't use snaps:**
   ```bash
   # Check if snapd is slow
   systemd-analyze blame | grep snapd
   
   # Check what it does
   systemctl cat snapd.service | head -20
   
   # Disable if you don't need it
   sudo systemctl disable snapd.service
   
   # After reboot, check improvement
   systemd-analyze
   ```

### Expected Output

```
$ systemd-analyze
Startup finished in 2.341s (kernel) + 8.456s (initramfs) + 28.123s (userspace) = 38.920s

$ systemd-analyze blame | head -10
       8.234s snapd.service
       5.123s apt-daily.service
       2.456s ssh.service
       1.890s systemd-tmpfiles-setup.service
       1.234s e2scrub_reap.service

$ systemd-analyze critical-chain
graphical.target @28.123s
└─multi-user.target @28.123s
  └─ssh.service @25.667s +2.456s
    └─network-online.target @5.234s
      └─systemd-resolved.service @4.123s
```

### Verification Checklist

- [ ] You know total boot time
- [ ] You identified slowest services
- [ ] You understand critical chain
- [ ] You found services to optimize
- [ ] You know how to disable services

### Cleanup

To revert service changes:
```bash
sudo systemctl enable snapd.service
sudo reboot
```

---

## Lab 9: Create Custom GRUB Boot Entry

**Goal:** Add a custom boot menu entry to GRUB

**Time:** 20 minutes

### Setup

Backup GRUB config first:
```bash
sudo cp /etc/default/grub /etc/default/grub.bak
sudo cp -r /etc/grub.d /etc/grub.d.bak
```

### Steps

1. **Create custom GRUB entry directory**
   ```bash
   sudo mkdir -p /etc/grub.d
   ```

2. **Create a custom entry script**
   ```bash
   sudo nano /etc/grub.d/40_custom_recovery
   ```

3. **Paste this content:**
   ```bash
   #!/bin/sh
   exec tail -n +3 $0
   
   # Custom recovery entry
   menuentry "Ubuntu Recovery (Verbose)" {
       search --no-floppy --label Ubuntu --set root
       linuxefi /boot/vmlinuz-5.15.0-56-generic root=UUID=YOUR-UUID-HERE ro single verbose
       initrdefi /boot/initrd.img-5.15.0-56-generic
   }
   ```

4. **Important: Replace `YOUR-UUID-HERE` with your actual UUID**
   ```bash
   sudo blkid | grep "TYPE=\"ext4\"" | head -1
   # Copy the UUID value
   ```

5. **Make the file executable**
   ```bash
   sudo chmod +x /etc/grub.d/40_custom_recovery
   ```

6. **Regenerate GRUB config**
   ```bash
   sudo update-grub
   ```

7. **Verify entry was added**
   ```bash
   grep -A 3 "Ubuntu Recovery" /boot/grub/grub.cfg
   ```

8. **Reboot and look at GRUB menu**
   ```bash
   sudo reboot
   ```
   Your new entry should appear in the menu

### Expected Output

```
$ sudo blkid
/dev/sda1: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="ext4"

$ grep -A 3 "Ubuntu Recovery" /boot/grub/grub.cfg
menuentry "Ubuntu Recovery (Verbose)" {
    search --no-floppy --label Ubuntu --set root
    linuxefi /boot/vmlinuz-5.15.0-56-generic root=UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890 ro single verbose
    initrdefi /boot/initrd.img-5.15.0-56-generic
}

# In GRUB menu at boot:
Ubuntu
Ubuntu (safe mode, recovery)
Advanced options for Ubuntu
Ubuntu Recovery (Verbose)    <-- Your new entry
Memory test (memtest86+)
```

### Verification Checklist

- [ ] Custom entry script created and made executable
- [ ] Entry appears in GRUB config after update-grub
- [ ] Entry appears in GRUB menu at boot
- [ ] (Optional) Entry boots successfully to rescue shell

### Cleanup

To remove custom entry:
```bash
sudo rm /etc/grub.d/40_custom_recovery
sudo update-grub
```

---

## Lab 10: Configure GRUB Password Protection

**Goal:** Secure GRUB with password to prevent unauthorized boot parameter changes

**Time:** 15 minutes

### Setup

Backup GRUB first:
```bash
sudo cp /etc/default/grub /etc/default/grub.bak
```

### Steps

1. **Create GRUB password hash**
   ```bash
   sudo grub-mkpasswd-pbkdf2
   ```
   (Enter a test password like `test123`)

2. **Copy the resulting hash** (long string starting with `grub.pbkdf2...`)

3. **Edit GRUB configuration**
   ```bash
   sudo nano /etc/default/grub
   ```

4. **Add these lines at the end:**
   ```bash
   GRUB_DISABLE_RECOVERY="true"
   set superusers="root"
   password_pbkdf2 root grub.pbkdf2.sha512.10000.LONG-HASH-HERE
   ```
   (Replace `LONG-HASH-HERE` with your actual hash)

5. **Save and exit**

6. **Update GRUB configuration**
   ```bash
   sudo update-grub
   ```

7. **Verify password is set**
   ```bash
   grep -i password /boot/grub/grub.cfg | head -2
   ```

8. **Reboot to test**
   ```bash
   sudo reboot
   ```

9. **At GRUB menu, press `e` to edit**
   - Should ask for password
   - If you press Escape, you'll continue to boot normally
   - System requires password to modify boot parameters

### Expected Output

```
$ sudo grub-mkpasswd-pbkdf2
Enter password:
Reenter password:
PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.1A2B3C...

# In GRUB menu at boot:
# When you press 'e', a prompt appears:
[  ]: _    # Password prompt

# If you press 'e' without entering password, you get back to menu
```

### Verification Checklist

- [ ] Password hash generated
- [ ] Added to `/etc/default/grub`
- [ ] `update-grub` ran successfully
- [ ] At boot, password required to edit entries
- [ ] Normal boot still works without password

### Cleanup

To remove password:
```bash
sudo cp /etc/default/grub.bak /etc/default/grub
sudo update-grub
sudo reboot
```

---

## Bonus Lab: View Boot Dependencies as Graph

**Goal:** Visualize systemd boot sequence

**Time:** 10 minutes

### Steps

1. **Generate boot sequence visualization**
   ```bash
   systemd-analyze plot > /tmp/boot.svg
   ```

2. **View the SVG file**
   ```bash
   file /tmp/boot.svg
   ls -lh /tmp/boot.svg
   ```

3. **If on desktop, open with browser**
   ```bash
   firefox /tmp/boot.svg &
   ```
   Or copy the file and view on another machine

4. **Analyze the diagram**
   - Horizontal axis = time
   - Boxes = services
   - Arrows = dependencies
   - Wide boxes = slow services

### Expected Output

The SVG shows a timeline with all services, clearly showing:
- Which services run in parallel
- Which services depend on others
- Relative duration of each service
- Critical path to boot completion

---

## Summary Table of All Labs

| Lab | Goal | Key Commands | Time |
|-----|------|------|------|
| 1 | Inspect boot sequence | `journalctl -b`, `uname -a` | 10 min |
| 2 | Analyze GRUB config | `cat /etc/default/grub` | 15 min |
| 3 | Examine boot logs | `systemd-analyze`, `journalctl` | 20 min |
| 4 | Modify parameters (temp) | GRUB edit at boot | 15 min |
| 5 | Modify parameters (perm) | `/etc/default/grub` + `update-grub` | 20 min |
| 6 | Explore systemd targets | `systemctl list-dependencies` | 15 min |
| 7 | Single-user mode | `systemctl rescue` or boot param | 15 min |
| 8 | Optimize boot time | `systemd-analyze blame` | 20 min |
| 9 | Custom GRUB entry | `/etc/grub.d/` scripts | 20 min |
| 10 | GRUB password | `grub-mkpasswd-pbkdf2` | 15 min |

**Total time:** 2-2.5 hours (with reboots)
