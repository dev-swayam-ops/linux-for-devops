# Linux Basics: Cheatsheet

## File and Directory Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `pwd` | Print working directory | `pwd` |
| `cd` | Change directory | `cd /home/user/projects` |
| `cd ~` | Go to home directory | `cd ~` |
| `cd -` | Go to previous directory | `cd -` |
| `ls` | List files | `ls` |
| `ls -l` | Long format listing | `ls -l` |
| `ls -la` | List all files including hidden | `ls -la` |
| `ls -lh` | Human-readable sizes | `ls -lh` |
| `ls -R` | Recursive listing | `ls -R` |
| `mkdir` | Create directory | `mkdir mydir` |
| `mkdir -p` | Create nested directories | `mkdir -p a/b/c` |
| `rmdir` | Remove empty directory | `rmdir mydir` |
| `rm -r` | Remove directory recursively | `rm -r mydir` |
| `tree` | Show directory tree | `tree projects` |

## File Operations

| Command | Purpose | Example |
|---------|---------|---------|
| `touch` | Create empty file | `touch file.txt` |
| `cat` | Display file content | `cat file.txt` |
| `echo` | Print text | `echo "Hello"` |
| `echo > file` | Write to file (overwrite) | `echo "text" > file.txt` |
| `echo >> file` | Append to file | `echo "text" >> file.txt` |
| `cp` | Copy file | `cp file1.txt file2.txt` |
| `cp -r` | Copy directory | `cp -r dir1 dir2` |
| `mv` | Move/rename file | `mv oldname.txt newname.txt` |
| `rm` | Delete file | `rm file.txt` |
| `file` | Identify file type | `file script.sh` |

## File Viewing Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `head` | Show first lines | `head -5 file.txt` |
| `tail` | Show last lines | `tail -10 file.txt` |
| `wc` | Count lines/words/bytes | `wc -l file.txt` |
| `grep` | Search text pattern | `grep "error" log.txt` |
| `grep -i` | Case-insensitive search | `grep -i "warning" file.txt` |
| `grep -n` | Show line numbers | `grep -n "error" file.txt` |

## Permissions and Ownership

| Command | Purpose | Example |
|---------|---------|---------|
| `chmod` | Change file permissions | `chmod 755 script.sh` |
| `chmod +x` | Add execute permission | `chmod +x script.sh` |
| `chmod -x` | Remove execute permission | `chmod -x script.sh` |
| `ls -l` | View permissions | `ls -l file.txt` |
| `chown` | Change owner | `chown user:group file.txt` |

## Disk and System

| Command | Purpose | Example |
|---------|---------|---------|
| `df -h` | Disk space usage | `df -h` |
| `du -sh` | Directory size | `du -sh .` |
| `du -ah` | Detailed disk usage | `du -ah *` |
| `free -h` | Memory usage | `free -h` |
| `whoami` | Current user | `whoami` |
| `date` | Current date/time | `date` |

## Text Editing and Processing

| Command | Purpose | Example |
|---------|---------|---------|
| `sed` | Stream editor | `sed 's/old/new/' file.txt` |
| `sed -i` | Edit file in-place | `sed -i 's/old/new/' file.txt` |
| `sort` | Sort lines | `sort file.txt` |
| `sort -rh` | Reverse human-readable sort | `sort -rh sizes.txt` |
| `uniq` | Remove duplicates | `uniq file.txt` |
| `cut` | Extract columns | `cut -d',' -f2 data.csv` |

## Special Symbols and Operators

| Symbol | Purpose | Example |
|--------|---------|---------|
| `>` | Redirect output (overwrite) | `echo "text" > file.txt` |
| `>>` | Append output to file | `echo "text" >> file.txt` |
| `\|` | Pipe output to next command | `cat file.txt \| grep error` |
| `*` | Wildcard (any characters) | `rm *.txt` |
| `?` | Single character wildcard | `ls file?.txt` |
| `~` | Home directory | `cd ~` |
| `.` | Current directory | `./script.sh` |
| `..` | Parent directory | `cd ..` |

## File Permissions (Octal)

| Number | Permissions | Meaning |
|--------|-------------|---------|
| `7` | rwx | Read, Write, Execute |
| `6` | rw- | Read, Write |
| `5` | r-x | Read, Execute |
| `4` | r-- | Read only |
| `0` | --- | No permissions |

**Examples:**
- `chmod 755` = rwxr-xr-x (owner full, others read+execute)
- `chmod 644` = rw-r--r-- (owner read+write, others read)
- `chmod 600` = rw------- (owner only read+write)

## Common Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + C` | Stop running command |
| `Ctrl + Z` | Suspend process |
| `Ctrl + A` | Go to start of line |
| `Ctrl + E` | Go to end of line |
| `Ctrl + U` | Clear line |
| `Ctrl + L` | Clear screen |
| `Tab` | Auto-complete |
| `↑ / ↓` | Command history |
