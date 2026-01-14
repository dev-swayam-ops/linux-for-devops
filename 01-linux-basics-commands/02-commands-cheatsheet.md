# 02-commands-cheatsheet.md: Essential Linux Commands Reference

## Quick Navigation

- [Navigation Commands](#navigation-commands)
- [File Viewing Commands](#file-viewing-commands)
- [File Operations](#file-operations)
- [Directory Operations](#directory-operations)
- [File Permissions](#file-permissions)
- [File Ownership](#file-ownership)
- [Text Search & Processing](#text-search--processing)
- [File Search](#file-search)
- [System Information](#system-information)
- [Help & Documentation](#help--documentation)
- [Useful Combinations](#useful-combinations)
- [Quick Reference Table](#quick-reference-table)

---

## Navigation Commands

### `pwd` - Print Working Directory

Shows your current location in the filesystem.

```bash
pwd
# Output: /home/alice/documents

pwd -L                    # Show logical path (follow symlinks)
pwd -P                    # Show physical path (actual location)
```

**When to use:** When you're lost and need to know where you are.

---

### `cd` - Change Directory

Move to a different directory.

```bash
cd /home/alice            # Go to absolute path
cd documents              # Go to relative directory (if in /home/alice)
cd ..                     # Go up one directory
cd ../..                  # Go up two directories
cd ~                      # Go to home directory
cd                        # Go to home directory (shortcut)
cd -                      # Go back to previous directory
cd /home/alice/documents/ # Full path with trailing slash (also works)
```

**Useful patterns:**
```bash
cd ~/projects             # Go to projects in home
cd /tmp                   # Go to temporary directory
cd /                      # Go to root
```

**Note:** `cd` is a built-in shell command, not a program. This matters because it changes the shell's current directory.

---

### `ls` - List Files and Directories

Show contents of a directory.

**Basic usage:**
```bash
ls                        # List files in current directory
ls /home/alice            # List files in specific directory
ls /home/alice/documents  # Path with multiple levels
```

**Common options:**
```bash
ls -a                     # All files (including hidden starting with .)
ls -l                     # Long format (detailed information)
ls -h                     # Human-readable sizes (KB, MB, GB)
ls -la                    # All files in long format
ls -lh                    # Long format with human-readable sizes
ls -lah                   # Combination of all above

ls -t                     # Sort by modification time (newest first)
ls -r                     # Reverse sort order
ls -S                     # Sort by file size

ls -d                     # List directory itself, not contents
ls -R                     # Recursive (show subdirectories)
ls -i                     # Show inode numbers
```

**Practical examples:**
```bash
ls -lah ~/                # See all files in home with sizes
ls -lt /tmp               # Show /tmp sorted by newest first
ls -lh Documents/*.pdf    # Show all PDFs with sizes
ls -la | head -20         # Show first 20 files
ls -R /home/alice         # Show alice and all subdirectories
```

**Understanding ls -l output:**
```
-rw-r--r-- 1 alice users 1234 Jan 14 10:30 report.txt
│││││││││  │ │     │     │    │  │   │   │
│││││││││  │ │     │     │    │  │   │   └─ Filename
│││││││││  │ │     │     │    │  │   └───── Hour:minute
│││││││││  │ │     │     │    │  └───────── Month
│││││││││  │ │     │     │    └──────────── Day
│││││││││  │ │     │     └─────────────── Size in bytes
│││││││││  │ │     └─────────────────── Group owner
│││││││││  │ └───────────────────────── User owner
│││││││││  └─────────────────────────── Link count
└──┬──────┘ Permission bits
  File type (-=regular, d=directory, l=link)
```

---

## File Viewing Commands

### `cat` - Concatenate and Display Files

Show entire file contents. Best for small files.

```bash
cat file.txt              # Show contents
cat file1.txt file2.txt   # Show multiple files
cat file.txt | head -20   # Show first 20 lines (via pipe)
```

**Useful options:**
```bash
cat -n file.txt           # Number all lines
cat -b file.txt           # Number non-empty lines
cat -A file.txt           # Show invisible characters (tabs, spaces, end-of-line)
```

**Examples:**
```bash
cat report.txt            # Read a report
cat ~/.bashrc             # View shell configuration
cat /etc/hostname         # View system hostname
```

---

### `less` and `more` - Page Through Files

View large files one page at a time.

```bash
less large_file.txt       # Paginate through file
more large_file.txt       # Older paging tool (less is preferred)
```

**Navigation in less:**
```bash
Space                     # Next page
b                         # Previous page
g                         # Go to beginning
G                         # Go to end
/pattern                  # Search for pattern
n                         # Next search result
N                         # Previous search result
q                         # Quit
```

**Examples:**
```bash
less /var/log/syslog      # View system log
less report.txt           # Browse through document
```

---

### `head` - Show First Lines

Display the beginning of a file.

```bash
head file.txt             # Show first 10 lines (default)
head -n 20 file.txt       # Show first 20 lines
head -n 5 file.txt        # Show first 5 lines
head -c 100 file.txt      # Show first 100 bytes
```

**Examples:**
```bash
head -n 1 file.txt        # Show header line
head /var/log/syslog      # Show first messages
```

---

### `tail` - Show Last Lines

Display the end of a file.

```bash
tail file.txt             # Show last 10 lines (default)
tail -n 20 file.txt       # Show last 20 lines
tail -f file.txt          # Follow (watch for new lines) - great for logs!
tail -c 100 file.txt      # Show last 100 bytes
```

**Examples:**
```bash
tail -f /var/log/syslog   # Watch system log in real-time
tail -n 5 file.txt        # Show last 5 lines
tail -f application.log & # Watch log in background
```

---

### `wc` - Word/Line Count

Count words, lines, bytes.

```bash
wc file.txt               # Lines, words, bytes
wc -l file.txt            # Line count only
wc -w file.txt            # Word count only
wc -c file.txt            # Byte count only
wc -m file.txt            # Character count
wc -L file.txt            # Longest line length
```

**Examples:**
```bash
wc -l *.txt               # Count lines in all .txt files
cat *.log | wc -l         # Total lines in all logs
ls | wc -l                # Number of files in directory
```

---

## File Operations

### `cp` - Copy Files

Copy one or more files.

```bash
cp file.txt file_backup.txt       # Simple copy
cp file.txt /tmp/                 # Copy to directory (keeps name)
cp /home/alice/file.txt ./        # Copy from elsewhere to current dir
cp file.txt file2.txt file3.txt /backup/  # Copy multiple to directory
```

**Common options:**
```bash
cp -i file.txt backup.txt         # Interactive (ask before overwrite)
cp -r directory/ backup/          # Recursive (copy directory and contents)
cp -p file.txt backup.txt         # Preserve permissions and timestamps
cp -v file.txt backup.txt         # Verbose (show what's happening)
cp -f file.txt backup.txt         # Force (overwrite without asking)
```

**Practical examples:**
```bash
cp -r ~/project ~/project_backup  # Backup entire project
cp -v *.txt backup/               # Copy all txt files with feedback
cp -i file.txt file.txt.old       # Safe backup (ask before overwrite)
```

**Important:** If destination is a directory, the file is copied INTO it. If destination is a file, it's copied to that name.

---

### `mv` - Move or Rename Files

Move files to new location or rename them.

```bash
mv old_name.txt new_name.txt      # Rename file
mv file.txt /home/alice/          # Move to directory
mv /home/alice/file.txt ~/        # Move from elsewhere to home
mv file1.txt file2.txt file3.txt /backup/  # Move multiple files
```

**Common options:**
```bash
mv -i file.txt backup.txt         # Interactive (ask before overwrite)
mv -v file.txt backup.txt         # Verbose (show what's happening)
mv -f file.txt backup.txt         # Force (overwrite without asking)
```

**Examples:**
```bash
mv report_draft.txt report.txt     # Rename when done
mv ~/downloads/*.pdf ~/documents/  # Move PDFs to documents
mv -i *.tmp /tmp/                  # Move temp files, ask first
```

**Key difference from cp:** `mv` removes the original. `cp` keeps it.

---

### `rm` - Remove Files

Delete files permanently. **BE CAREFUL!**

```bash
rm file.txt               # Delete single file
rm file1.txt file2.txt    # Delete multiple files
rm *.txt                  # Delete all .txt files (dangerous!)
rm /path/to/file.txt      # Delete absolute path
```

**Common options:**
```bash
rm -i file.txt            # Interactive (ask before deleting) - USE THIS!
rm -f file.txt            # Force (no asking, suppress errors)
rm -v file.txt            # Verbose (show what's being deleted)
rm -r directory/          # Recursive (delete directory and contents)
```

**Safe practices:**
```bash
rm -i file.txt            # Safe: ask first
rm -i *.txt               # Safe: ask for each file
rm -r -i directory/       # Safe: ask before deleting dir

# Dangerous patterns to AVOID:
rm -rf /                  # DON'T: Delete entire filesystem
rm -r *                   # DON'T: Delete everything
```

---

### `touch` - Create Empty File or Update Timestamp

Create a new empty file or update modification time.

```bash
touch newfile.txt         # Create empty file
touch file1.txt file2.txt # Create multiple files
touch existing.txt        # Update modification time to now
```

**Examples:**
```bash
touch README.md           # Create readme file
touch .gitignore          # Create hidden file
touch -d "2020-01-01" old.txt  # Set specific date
```

---

## Directory Operations

### `mkdir` - Make Directory

Create one or more directories.

```bash
mkdir mydir               # Create single directory
mkdir dir1 dir2 dir3      # Create multiple directories
mkdir /path/to/mydir      # Create in specific location
```

**Common options:**
```bash
mkdir -p path/to/deeply/nested/dir  # Create parent directories as needed
mkdir -m 755 mydir        # Create with specific permissions
mkdir -v mydir            # Verbose (show what's created)
```

**Examples:**
```bash
mkdir -p ~/projects/my_app/src  # Create entire path
mkdir Documents Downloads Projects  # Create multiple
```

---

### `rmdir` - Remove Empty Directory

Delete a directory (only if empty).

```bash
rmdir emptydir            # Remove empty directory
rmdir dir1 dir2           # Remove multiple empty directories
rmdir /path/to/empty/     # Remove with path
```

**If directory not empty:** Use `rm -r` instead.

```bash
rm -r mydir/              # Remove directory and contents
```

---

## File Permissions

### `chmod` - Change Mode (Permissions)

Change file or directory permissions.

**Using numeric notation:**
```bash
chmod 644 file.txt        # rw-r--r-- (owner rw, others r)
chmod 755 script.sh       # rwxr-xr-x (owner rwx, others rx)
chmod 700 private.txt     # rwx------ (owner only, full access)
chmod 600 secrets.txt     # rw------- (owner rw, others nothing)
```

**Using symbolic notation:**
```bash
chmod +x script.sh        # Add execute for all
chmod u+w file.txt        # Add write for user (owner)
chmod g-w file.txt        # Remove write for group
chmod o-r file.txt        # Remove read for others
chmod a=r file.txt        # Set to read-only for all
chmod u=rwx,g=rx,o=      # Set specific for each (user rwx, group rx, other none)
```

**Permissions:**
```bash
r = read (4)
w = write (2)
x = execute (1)

u = user (owner)
g = group
o = others
a = all
```

**Common options:**
```bash
chmod -R 755 directory/   # Recursive (directory and contents)
chmod -v 755 file.txt     # Verbose (show what changed)
```

**Examples:**
```bash
chmod 755 script.sh       # Make script executable
chmod 644 *.txt           # Make all .txt readable by all
chmod -R 700 secret/      # Private directory, owner only
chmod a-w file.txt        # Remove write from everyone
```

---

## File Ownership

### `chown` - Change Owner

Change file owner and/or group. Requires sudo.

```bash
chown alice file.txt      # Change owner to alice
chown alice:users file.txt  # Change owner and group
chown :users file.txt     # Change group only
```

**Common options:**
```bash
chown -R alice:users dir/ # Recursive (directory and contents)
chown -v alice file.txt   # Verbose
```

**Examples:**
```bash
sudo chown alice report.txt  # Alice now owns it
sudo chown -R alice:users ~/  # Recursive ownership
sudo chown :www-data webfiles/  # Change group only
```

---

### `chgrp` - Change Group

Change file group.

```bash
chgrp users file.txt      # Change group to users
chgrp -R users directory/ # Recursive
```

---

## Text Search & Processing

### `grep` - Global Regular Expression Print

Search for lines matching a pattern.

```bash
grep "pattern" file.txt   # Find lines containing pattern
grep -i "pattern" file.txt  # Case-insensitive search
grep -n "pattern" file.txt  # Show line numbers
grep -c "pattern" file.txt  # Count matching lines
grep -v "pattern" file.txt  # Show lines NOT matching (inverse)
grep -r "pattern" .       # Recursive search in directory
grep -l "pattern" *.txt   # Show filenames only
```

**Examples:**
```bash
grep "error" logfile.txt           # Find error messages
grep -in "warning" *.log           # Find all warnings (case-insensitive)
grep -r "TODO" ~/projects          # Find all TODO comments
grep "^#" config.txt               # Find comment lines
grep "[0-9]" file.txt              # Lines containing numbers
grep -c "error" /var/log/syslog   # Count errors
```

---

### `sort` - Sort Lines

Sort lines in a file.

```bash
sort file.txt             # Sort alphabetically
sort -n file.txt          # Sort numerically
sort -r file.txt          # Reverse sort
sort -u file.txt          # Unique (remove duplicates)
sort file.txt -o sorted.txt  # Save to file
```

**Examples:**
```bash
sort names.txt            # Alphabetical list
sort -n numbers.txt       # Numeric order
sort -u duplicates.txt    # Remove duplicate lines
```

---

### `uniq` - Remove Consecutive Duplicates

Remove or report duplicate lines (must be sorted first).

```bash
sort file.txt | uniq      # Remove consecutive duplicates
uniq -c file.txt          # Count occurrences
uniq -d file.txt          # Show only duplicates
uniq -u file.txt          # Show only unique lines
```

**Examples:**
```bash
cat data.txt | sort | uniq  # Remove all duplicates
sort users.txt | uniq -c    # Count how many times each user appears
```

---

### `sed` - Stream Editor

Search and replace text (covered more in Module 02).

```bash
sed 's/old/new/' file.txt     # Replace first occurrence per line
sed 's/old/new/g' file.txt    # Replace all occurrences
sed '5d' file.txt             # Delete line 5
sed -i 's/old/new/g' file.txt # Modify file in place
```

---

### `awk` - Text Processing

Extract columns and process text (covered more in Module 02).

```bash
awk '{print $1}' file.txt     # Print first field/column
awk -F: '{print $1}' /etc/passwd  # Use : as separator
awk '{print NF}' file.txt     # Print number of fields
```

---

## File Search

### `find` - Search for Files

Search for files matching criteria.

```bash
find . -name "*.txt"      # Find all .txt files from current dir
find / -name "file.txt"   # Find in entire filesystem (slow!)
find /home -name "*.pdf"  # Find PDFs in /home
find . -type f -name "*.log"  # Find regular files ending in .log
find . -type d -name "backup"  # Find directories named backup
```

**Common options:**
```bash
find . -name "*.txt" -type f  # By name and type
find . -size +1M          # Files larger than 1 MB
find . -mtime -7          # Modified in last 7 days
find . -user alice        # Files owned by alice
find . -perm 777          # Files with 777 permissions
```

**Examples:**
```bash
find ~ -name "*.jpg" -type f  # Find all JPG images
find /tmp -type f -mtime +30  # Find files modified >30 days ago
find . -name "*.tmp" -delete  # Find and delete temp files
```

---

## System Information

### `echo` - Print Text

Display text or variable values.

```bash
echo "Hello, World!"      # Print text
echo $HOME                # Print variable value
echo $USER                # Print username
echo $PWD                 # Print current directory
echo "Line1"; echo "Line2"  # Multiple echo commands
```

**Options:**
```bash
echo -n "text"            # Don't add newline
echo -e "a\tb\tc"         # Interpret backslash escapes (\t=tab, \n=newline)
```

---

### `whoami` - Current User

Show your username.

```bash
whoami                    # Shows: alice
```

---

### `id` - User and Group Information

Show user ID and group memberships.

```bash
id                        # Full info for current user
id -u                     # Just the UID
id -g                     # Just the main GID
id -G                     # All group IDs
id alice                  # Info for specific user
```

---

### `uname` - System Information

Show system and kernel information.

```bash
uname -a                  # All information
uname -s                  # Kernel name (Linux)
uname -r                  # Kernel release
uname -m                  # Machine hardware
uname -n                  # Hostname
```

---

### `date` - Current Date and Time

Display current date and time.

```bash
date                      # Full date/time
date +%Y-%m-%d           # Just date: 2025-01-14
date +%H:%M:%S           # Just time: 10:30:45
date "+%A, %B %d, %Y"   # Formatted: Tuesday, January 14, 2025
```

---

## Help & Documentation

### `man` - Manual Pages

Read documentation for commands.

```bash
man ls                    # Manual page for ls
man grep                  # Manual page for grep
man -k "copy"            # Search for pages about "copy"
man -f chmod             # Show page summary
```

**Navigation:**
```bash
Space                     # Next page
b                         # Previous page
/pattern                  # Search for pattern
n                         # Next search result
q                         # Quit
```

---

### `--help` Flag

Most commands support quick help.

```bash
ls --help                 # Quick help for ls
grep --help              # Quick help for grep
cat --help               # Quick help for cat
```

---

### `info` - Extended Documentation

More detailed than man pages (if available).

```bash
info ls                   # Info about ls
info --index "command"    # Search
```

---

### `help` - Shell Built-in Help

Help for built-in commands.

```bash
help cd                   # Help for cd builtin
help echo                 # Help for echo builtin
help export              # Help for export
```

---

## Useful Combinations

### Pipe and Chain Commands

```bash
# Show first 10 .txt files
ls *.txt | head -10

# Find and count
find . -name "*.log" | wc -l

# Search and show line numbers
grep -rn "error" . | head -20

# Process: sort → unique → count
cat file.txt | sort | uniq -c

# Multiple commands
cd /tmp; ls -la; cd ~

# Command on multiple files
cat *.txt | grep "important" | head -5
```

---

### Counting and Summarizing

```bash
# Count files
ls -1 | wc -l

# Count lines in all txt files
cat *.txt | wc -l

# Find which line appears most
cat file.txt | sort | uniq -c | sort -rn | head -1

# Count occurrences by user
grep -r "user" . | cut -d: -f1 | sort | uniq -c
```

---

### Finding and Processing

```bash
# Find large files
find . -type f -size +100M

# Find and display
find . -name "*.txt" -exec cat {} \;

# Find modified recently
find . -type f -mtime -7

# Find old files
find . -type f -mtime +30 -delete  # BE CAREFUL!
```

---

## Quick Reference Table

| Command | Purpose | Quick Example |
|---------|---------|---------------|
| `pwd` | Show current directory | `pwd` |
| `cd` | Change directory | `cd /home/alice` |
| `ls` | List files | `ls -lah` |
| `cat` | Show file contents | `cat file.txt` |
| `head` | Show first lines | `head -n 10 file.txt` |
| `tail` | Show last lines | `tail -f log.txt` |
| `less` | Page through file | `less large.txt` |
| `cp` | Copy file | `cp file.txt backup.txt` |
| `mv` | Move/rename file | `mv old.txt new.txt` |
| `rm` | Delete file | `rm -i file.txt` |
| `mkdir` | Create directory | `mkdir mydir` |
| `rmdir` | Remove empty directory | `rmdir emptydir` |
| `touch` | Create empty file | `touch newfile.txt` |
| `chmod` | Change permissions | `chmod 755 script.sh` |
| `chown` | Change owner | `sudo chown alice file.txt` |
| `grep` | Search text | `grep "pattern" file.txt` |
| `find` | Find files | `find . -name "*.txt"` |
| `sort` | Sort lines | `sort file.txt` |
| `uniq` | Remove duplicates | `sort file.txt \| uniq` |
| `wc` | Count lines/words | `wc -l file.txt` |
| `echo` | Print text | `echo "Hello"` |
| `whoami` | Current user | `whoami` |
| `date` | Current date | `date` |
| `man` | Show help | `man ls` |

---

**Next Step:** Move to [03-hands-on-labs.md](03-hands-on-labs.md) to practice these commands with real exercises.

**Tip:** Don't memorize all commands. Learn the most common ones first, then refer back here as needed.
