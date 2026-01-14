# Scripts for Linux Basics Module

This directory contains two production-ready bash scripts that automate common Linux tasks learned in this module. Both scripts exemplify best practices from the Linux Basics module.

## 📋 Overview

| Script | Purpose | Use Case |
|--------|---------|----------|
| `file-organizer.sh` | Organize files by type into subdirectories | Desktop cleanup, Downloads management |
| `permission-checker.sh` | Audit file permissions and identify security issues | Security audits, compliance checks |

---

## 🗂️ file-organizer.sh

### Purpose
Automatically organize files in a directory by type (extension). Creates subdirectories for different file categories and moves files accordingly.

### Features
- **File Categories**: Documents, Images, Videos, Audio, Archives, Other
- **Dry-run Mode**: Preview changes before executing
- **Verbose Mode**: See details of each file operation
- **Safe Operations**: Skips existing files, uses existing directories
- **User-Friendly**: Built-in help and examples

### Installation
```bash
# Make script executable
chmod +x file-organizer.sh

# Optional: Move to system PATH
sudo mv file-organizer.sh /usr/local/bin/file-organizer
```

### Usage

#### Basic Usage
```bash
# Organize current directory
./file-organizer.sh

# Organize specific folder
./file-organizer.sh ~/Downloads

# Organize with dry-run (preview only)
./file-organizer.sh --dry-run ~/Downloads
```

#### With Options
```bash
# Verbose mode - show each file
./file-organizer.sh -v ~/Documents

# Specific directory with long options
./file-organizer.sh --dir ~/Downloads --verbose

# Dry-run with verbose (safest for first run)
./file-organizer.sh --dry-run -v ~/Downloads
```

#### Getting Help
```bash
./file-organizer.sh --help    # Show help
./file-organizer.sh --version # Show version
```

### Example Scenarios

#### Scenario 1: Clean Messy Downloads Folder
```bash
# First, preview what will happen
./file-organizer.sh --dry-run ~/Downloads

# Output:
# [DRY RUN] Would move: photo.jpg → Images/
# [DRY RUN] Would move: document.pdf → Documents/
# [DRY RUN] Would move: song.mp3 → Audio/
# [DRY RUN] Would move: archive.zip → Archives/
# [DRY RUN] Would move: readme.txt → Documents/
#
# Summary:
#   Files moved: 5

# Then execute for real
./file-organizer.sh ~/Downloads

# Output:
# Organizing: /home/alice/Downloads
# ✓ Moved: photo.jpg → Images/
# ✓ Moved: document.pdf → Documents/
# ✓ Moved: song.mp3 → Audio/
# ✓ Moved: archive.zip → Archives/
# ✓ Moved: readme.txt → Documents/
#
# Summary:
#   Files moved: 5
```

#### Scenario 2: Organize Project Assets
```bash
# Move project images and documents into categories
cd ~/my-project/assets
~/file-organizer.sh .

# Result:
# Images/
#   ├── logo.png
#   ├── banner.jpg
#   └── icon.svg
# Documents/
#   ├── README.md
#   ├── DESIGN.pdf
#   └── specs.txt
```

#### Scenario 3: Verbose Organization
```bash
# See exactly what's happening (useful for learning)
./file-organizer.sh -v ~/Desktop

# Output:
# Organizing: /home/alice/Desktop
# + Created directory: Documents/
# ✓ Moved: notes.txt → Documents/
# ✓ Moved: presentation.pptx → Documents/
# + Created directory: Images/
# ✓ Moved: screenshot.png → Images/
# + Created directory: Archives/
# ✓ Moved: backup.zip → Archives/
#
# Summary:
#   Files moved: 4
```

### File Categories

| Category | Extensions |
|----------|-----------|
| **Documents** | pdf, doc, docx, txt, xls, xlsx, ppt, pptx, odt, ods, csv |
| **Images** | jpg, jpeg, png, gif, bmp, svg, webp, tiff, ico |
| **Videos** | mp4, avi, mkv, mov, flv, wmv, m4v |
| **Audio** | mp3, flac, wav, aac, ogg, wma |
| **Archives** | zip, rar, 7z, tar, gz, bz2, xz |
| **Other** | Everything with no recognized extension |

### How It Works

1. **Scan**: Finds all files in target directory (non-recursive by default)
2. **Categorize**: Identifies file type by extension
3. **Create**: Makes category subdirectories as needed
4. **Move**: Relocates files to appropriate category folders
5. **Report**: Shows summary of operations

### Safety Features

- **Dry-run mode**: Preview changes without making them
- **Confirmation skip**: Won't overwrite existing files
- **Existing directory reuse**: Uses existing category folders
- **Clear feedback**: Shows successes and failures

### Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Permission denied | Run `chmod +x file-organizer.sh` first |
| Directory not found | Verify path exists with `ls -ld /path` |
| No files moved | Check for hidden files or subdirectories |
| "Text file busy" error | Don't move while files are open |

### Learning Value

This script demonstrates:
- **File operations**: `find`, `mv` commands
- **String manipulation**: Extension detection
- **Control flow**: Loops and conditionals
- **Error handling**: Directory creation and file moving
- **User interface**: Help text and verbose output
- **Dry-run pattern**: Useful for destructive operations

---

## 🔐 permission-checker.sh

### Purpose
Scan a directory tree and identify unusual or potentially insecure file permissions. Generate security reports with color-coded warnings.

### Features
- **Comprehensive Audit**: Scans files and directories for permission issues
- **Security Focused**: Detects world-writable, SETUID, and other dangerous permissions
- **Recursive Scanning**: Optional deep directory traversal
- **Color-Coded Output**: Easy identification of issue severity
- **Fix Suggestions**: Recommended chmod commands for each issue
- **Sensitive Detection**: Recognizes private keys, passwords, credentials

### Installation
```bash
# Make script executable
chmod +x permission-checker.sh

# Optional: Move to system PATH
sudo mv permission-checker.sh /usr/local/bin/permission-checker
```

### Usage

#### Basic Usage
```bash
# Check current directory
./permission-checker.sh

# Check specific folder
./permission-checker.sh ~/public_html

# Check home directory recursively
./permission-checker.sh -r ~
```

#### With Options
```bash
# Only show warnings (fewer details)
./permission-checker.sh -w /var

# Check recursively with fix suggestions
./permission-checker.sh -r -f ~/scripts

# Warnings-only and recursive
./permission-checker.sh -w -r ~/
```

#### Getting Help
```bash
./permission-checker.sh --help    # Show help
./permission-checker.sh --version # Show version
```

### Example Scenarios

#### Scenario 1: Check Home Directory for Issues
```bash
# Scan home directory recursively
./permission-checker.sh -r ~

# Output example:
# Scanning: /home/alice
# Mode: RECURSIVE
#
# [!] CRITICAL: /home/alice/.ssh/id_rsa
#     Sensitive file is world-readable (644)
#     Fix: chmod 600 /home/alice/.ssh/id_rsa
#
# [!] WARNING: /home/alice/public_html
#     World-writable (777) - Any user can modify
#     Fix: chmod o-w /home/alice/public_html
#
# [!] WARNING: /usr/bin/sudo
#     SETUID + world-executable (4755) - High security risk
#     Fix: chmod o-x /usr/bin/sudo  # or chmod u-s /usr/bin/sudo
#
# Scan Summary:
#   Total files: 1543
#   Total directories: 287
#   Issues found: 3
```

#### Scenario 2: Quick Warnings-Only Scan
```bash
# Just show critical issues
./permission-checker.sh -w /var

# Output:
# Scanning: /var
#
# [!] CRITICAL: /var/www/uploads
#     World-writable (777) - Any user can modify
#     Fix: chmod o-w /var/www/uploads
#
# [!] CRITICAL: /var/run/secrets
#     Full permissions (777) - Everyone can read/write/execute
#     Fix: chmod 755 /var/run/secrets
#
# Scan Summary:
#   Total files: 89
#   Total directories: 34
#   Issues found: 2
```

#### Scenario 3: Check Web Server Permissions
```bash
# Audit web server files
./permission-checker.sh -r ~/public_html

# Output:
# Scanning: /home/alice/public_html
# Mode: RECURSIVE
#
# [i] INFO: /home/alice/public_html/index.html
#     File permissions: 644
#
# [!] WARNING: /home/alice/public_html/upload
#     World-executable file (755) - Anyone can run
#     Fix: chmod o-x /home/alice/public_html/upload
#
# [!] CRITICAL: /home/alice/public_html/.env
#     Sensitive file is world-readable (644)
#     Fix: chmod 600 /home/alice/public_html/.env
#
# Scan Summary:
#   Total files: 127
#   Total directories: 18
#   Issues found: 2
```

#### Scenario 4: Check Scripts Directory
```bash
# Check shell scripts for security
./permission-checker.sh -f ~/scripts

# Output:
# Scanning: /home/alice/scripts
#
# [i] INFO: /home/alice/scripts/backup.sh
#     File permissions: 755
#
# [!] WARNING: /home/alice/scripts/deploy.sh
#     SETUID bit set (4755) - Check if necessary
#     Fix: chmod u-s /home/alice/scripts/deploy.sh
#
# Scan Summary:
#   Total files: 12
#   Total directories: 2
#   Issues found: 1
```

### Issues Detected

#### CRITICAL Issues
| Issue | Meaning | Risk | Fix Example |
|-------|---------|------|------------|
| World-writable | Anyone can modify | Data corruption | `chmod o-w file` |
| 777 permissions | Full open access | Security breach | `chmod 755 dir` |
| 666 permissions | All can read/write | Data exposure | `chmod 644 file` |
| SETUID + world-exec | Program runs as owner + executable by all | Privilege escalation | `chmod o-x file` |
| Sensitive world-readable | Keys/passwords readable by others | Credential theft | `chmod 600 file` |

#### WARNING Issues
| Issue | Meaning | Concern |
|-------|---------|---------|
| SETUID bit | Program runs with owner's privileges | Check necessity |
| SETGID bit | Program runs with group's privileges | Check necessity |
| World-executable file | Any user can run | Verify intentional |

#### INFO Messages (details only)
| Message | Context |
|---------|---------|
| Regular file permissions | Standard file modes |
| Directory permissions | Standard directory modes |

### Common Security Patterns

#### Safe File Permissions
```bash
# Regular files - readable by all, writable by owner
chmod 644 regular-file.txt

# Executable scripts/programs - readable and executable by all
chmod 755 script.sh

# Private files (passwords, keys)
chmod 600 private.key

# Private directories
chmod 700 private-dir
```

#### Common Fixes by Issue
```bash
# Remove world-writable permission
chmod o-w file.txt          # 777 → 775 or 755 depending on others

# Remove world-readable from sensitive files
chmod go-r private.key      # Make readable by owner only

# Fix world-executable on scripts
chmod o-x unnecessary       # Remove "other execute" permission

# Make file readable/writable by owner only
chmod 600 secret.txt

# Make directory accessible by owner only
chmod 700 private-dir
```

### Output Severity Levels

| Severity | Symbol | Color | Meaning |
|----------|--------|-------|---------|
| CRITICAL | [!] | RED | Immediate security concern |
| WARNING | [!] | YELLOW | Requires review/attention |
| INFO | [i] | BLUE | Informational only |

### How It Works

1. **Scan**: Traverses directory tree (optionally recursive)
2. **Check**: Evaluates each file's permissions
3. **Detect**: Identifies security issues
4. **Report**: Displays issues with fixes
5. **Summary**: Shows total files, directories, and issues

### Learning Value

This script demonstrates:
- **Permissions**: chmod, stat, permission bits
- **Security patterns**: Detecting dangerous configurations
- **File scanning**: find with type filtering
- **Arithmetic**: Octal permission calculations
- **Pattern matching**: Identifying sensitive filenames
- **Color output**: Making terminal output user-friendly
- **Error handling**: Graceful handling of permission denied

---

## 🔗 Integration Examples

### Scenario: Weekly Cleanup and Security Audit

```bash
#!/bin/bash
# weekly-maintenance.sh - Run weekly cleanup and security check

echo "=== Weekly Maintenance ==="
echo ""

echo "Step 1: Organizing Downloads..."
~/scripts/file-organizer.sh ~/Downloads

echo ""
echo "Step 2: Security audit of home directory..."
~/scripts/permission-checker.sh -r ~

echo ""
echo "=== Maintenance Complete ==="
```

### Scenario: CI/CD Pipeline Check

```bash
#!/bin/bash
# deploy-check.sh - Verify security before deployment

echo "Checking permissions in deployment directory..."
~/scripts/permission-checker.sh -w ~/deploy

if [ $? -ne 0 ]; then
    echo "FAIL: Security issues found!"
    exit 1
fi

echo "PASS: All permissions verified"
exit 0
```

### Scenario: Automated Cleanup Before Backup

```bash
#!/bin/bash
# backup-prep.sh - Organize and clean before backup

BACKUP_DIR=~/backups/$(date +%Y-%m-%d)

# Organize desktop
echo "Organizing Desktop..."
~/scripts/file-organizer.sh ~/Desktop

# Create backup list
echo "Creating backup manifest..."
~/scripts/permission-checker.sh -r ~ > $BACKUP_DIR/permission-audit.txt

# Proceed with backup
echo "Backup ready"
```

---

## 🛠️ Troubleshooting

### Scripts Won't Execute
```bash
# Make scripts executable
chmod +x file-organizer.sh
chmod +x permission-checker.sh

# Verify
ls -l *.sh
```

### Permission Denied on System Directories
```bash
# Use sudo for system paths (careful!)
sudo ~/scripts/permission-checker.sh -r /var

# Or check individual files
~/scripts/permission-checker.sh -w /etc
```

### No Output or Results
```bash
# Use verbose mode to see what's happening
./file-organizer.sh -v .
./permission-checker.sh -w .

# Check if directory exists
test -d /path/to/dir && echo "exists" || echo "not found"
```

### Script Modifies Files Unexpectedly
```bash
# Always use dry-run first!
./file-organizer.sh --dry-run /path

# Review output, then run without --dry-run
./file-organizer.sh /path
```

---

## 📚 Learning Path

These scripts build on Linux Basics concepts:

1. **File Operations**: `find`, `mv`, `ls -l`
2. **Permissions**: `chmod`, octal notation, symbolic notation
3. **Control Flow**: Loops, conditionals
4. **Functions**: Modularity and reusability
5. **Error Handling**: `set -euo pipefail`, exit codes
6. **User Interface**: Help text, color output, documentation

### Related Labs
- **Lab 3**: Copying, Moving, Removing - Foundation for `file-organizer.sh`
- **Lab 4**: Understanding Permissions - Foundation for `permission-checker.sh`
- **Lab 7**: Finding Files - Used in both scripts

---

## 🚀 Quick Start

```bash
# 1. Make scripts executable
chmod +x file-organizer.sh permission-checker.sh

# 2. Test with dry-run (preview only)
./file-organizer.sh --dry-run ~/Downloads

# 3. Run for real
./file-organizer.sh ~/Downloads

# 4. Check security
./permission-checker.sh -r ~
```

---

## 📝 Notes

- Both scripts use `set -euo pipefail` for safety
- Scripts are POSIX-compatible (work on Ubuntu, CentOS, macOS)
- Always use `--dry-run` before modifying files
- Use `-w` or `--warnings` to reduce output verbosity
- Scripts demonstrate production-quality bash patterns

## 📖 Further Reading

- **Module 01**: Linux Basics Commands (theory and hands-on labs)
- **Lab 3**: File operations deep dive
- **Lab 4**: Permissions and ownership
- **Lab 7**: Finding files with `find` command
- Bash scripting best practices in Module 16

---

*Scripts created for Linux for DevOps learning repository - Module 01: Linux Basics Commands*
