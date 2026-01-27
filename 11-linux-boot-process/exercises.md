# Linux Boot Process: Exercises

Complete these exercises to understand the boot sequence.

## Exercise 1: View Boot Messages

**Tasks:**
1. Show kernel boot messages
2. Filter for specific messages
3. Find CPU initialization
4. Check device detection
5. View error messages only

**Hint:** Use `dmesg`, `dmesg | grep`, `dmesg -l`.

---

## Exercise 2: Analyze Boot Time

**Tasks:**
1. Show systemd boot timing
2. Break down boot phases
3. Identify slow components
4. Generate boot chart
5. Compare boot times

**Hint:** Use `systemd-analyze`, `systemd-analyze plot`, compare outputs.

---

## Exercise 3: Examine GRUB Configuration

**Tasks:**
1. View GRUB config file
2. Identify default boot entry
3. Find kernel lines
4. Show boot device
5. Understand GRUB syntax

**Hint:** Use `cat /boot/grub/grub.cfg`, `grub-editenv list`.

---

## Exercise 4: Check Kernel Parameters

**Tasks:**
1. View current kernel parameters
2. Identify important parameters
3. Find root filesystem
4. Check boot mode (single/multi)
5. Show all kernel arguments

**Hint:** Use `cat /proc/cmdline`, `cat /proc/cmdline | tr ' ' '\n'`.

---

## Exercise 5: Understand initramfs

**Tasks:**
1. List initramfs files
2. Check file sizes
3. Compare versions
4. Find initramfs location
5. Understand initramfs purpose

**Hint:** Use `ls -lh /boot/initramfs*`, `file /boot/initramfs*`.

---

## Exercise 6: Analyze Boot Journal

**Tasks:**
1. View this boot's journal
2. Show previous boots
3. Filter by severity
4. Find startup errors
5. Check service startup order

**Hint:** Use `journalctl -b`, `journalctl --list-boots`, `-p err`.

---

## Exercise 7: Monitor Boot Performance

**Tasks:**
1. Check which unit is slowest
2. Identify service dependencies
3. Find parallel vs sequential boots
4. Check target completion time
5. Analyze critical path

**Hint:** Use `systemd-analyze critical-chain`, `systemd-analyze`.

---

## Exercise 8: Check Boot Sequence

**Tasks:**
1. View default runlevel
2. Show system targets
3. Check active target
4. List boot-time services
5. Understand systemd targets

**Hint:** Use `systemctl get-default`, `systemctl list-units --type=target`.

---

## Exercise 9: Boot Parameters and Options

**Tasks:**
1. Document current kernel params
2. Find ro (read-only) parameter
3. Identify root parameter
4. Check quiet vs verbose mode
5. Understand param purposes

**Hint:** Use `cat /proc/cmdline`, Linux kernel documentation.

---

## Exercise 10: Boot Recovery Scenarios

Create a recovery reference guide.

**Tasks:**
1. Document GRUB emergency commands
2. List single-user mode procedure
3. Create boot failure checklist
4. Know disk recovery commands
5. Test recovery knowledge

**Hint:** Combine GRUB, single mode, fsck knowledge.
