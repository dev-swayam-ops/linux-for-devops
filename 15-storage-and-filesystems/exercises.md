# Storage and Filesystems: Exercises

Complete these exercises to master storage management.

## Exercise 1: Identify Storage Devices

**Tasks:**
1. List all disk devices
2. Show partition structure
3. Check partition sizes
4. Identify boot partition
5. Find mounted filesystems

**Hint:** Use `fdisk -l`, `lsblk`, `mount`.

---

## Exercise 2: Understand Filesystems

**Tasks:**
1. Check filesystem types
2. View filesystem details
3. Compare ext4 vs xfs
4. Understand inode structure
5. Show block size info

**Hint:** Use `df -T`, `tune2fs -l`, `stat`.

---

## Exercise 3: Create Partitions

**Tasks:**
1. View partition table
2. Create new partition (fdisk)
3. Verify partition created
4. Set partition type
5. Save partition table

**Hint:** Use `sudo fdisk`, `lsblk` to verify.

---

## Exercise 4: Format Filesystems

**Tasks:**
1. Format with ext4
2. Format with xfs
3. Set filesystem label
4. Verify formatting
5. Show filesystem info

**Hint:** Use `sudo mkfs.ext4/xfs`, `sudo blkid`.

---

## Exercise 5: Mount and Unmount

**Tasks:**
1. Mount filesystem to directory
2. Verify mount point
3. Check mounted filesystems
4. Show usage after mount
5. Unmount filesystem

**Hint:** Use `sudo mount`, `mount`, `df`, `sudo umount`.

---

## Exercise 6: Work with /etc/fstab

**Tasks:**
1. View fstab entries
2. Add new filesystem
3. Test fstab validity
4. Understand UUID vs device
5. Auto-mount on boot

**Hint:** Use `cat /etc/fstab`, `sudo mount -a`, `blkid`.

---

## Exercise 7: Disk Space Analysis

**Tasks:**
1. Check disk usage
2. Identify large directories
3. Monitor inode usage
4. Find unused space
5. Plan capacity

**Hint:** Use `df -h`, `du -sh`, `df -i`, `ncdu`.

---

## Exercise 8: Filesystem Permissions and Quotas

**Tasks:**
1. Check filesystem mount options
2. Show quota status
3. Understand soft/hard limits
4. Monitor user quotas
5. Set grace period

**Hint:** Use `mount`, `quota`, `edquota`.

---

## Exercise 9: Check Filesystem Health

**Tasks:**
1. Check disk errors
2. Run fsck (non-destructive)
3. View SMART status
4. Monitor filesystem performance
5. Detect bad blocks

**Hint:** Use `sudo fsck -n`, `smartctl`, `e2fsck`.

---

## Exercise 10: Plan Storage Strategy

Create comprehensive storage plan.

**Tasks:**
1. Document current layout
2. Plan partition strategy
3. Design LVM structure
4. Set quota policy
5. Create backup schedule

**Hint:** Combine all previous exercises.
