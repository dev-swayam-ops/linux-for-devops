# Module 1: Linux Basics Commands

## What You'll Learn

- Navigate the Linux filesystem using essential commands
- Create, view, and manage files and directories
- Understand file permissions and basic ownership
- Work with text files efficiently
- Manage user sessions and system information

## Prerequisites

- Access to a Linux terminal (Ubuntu, CentOS, or any Linux distribution)
- Basic understanding of terminal/command line
- Administrator or sudo privileges (for some exercises)

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Filesystem Hierarchy** | Directory structure: /, /home, /var, /etc, /bin, /usr |
| **File Permissions** | Read (r), Write (w), Execute (x) for owner, group, others |
| **Path Types** | Absolute paths start with /; Relative paths are relative to current directory |
| **Hidden Files** | Files starting with . are hidden; use `ls -a` to view |
| **Standard Streams** | stdin, stdout, stderr for input/output redirection |

## Hands-on Lab: Navigate and Manage Files

### Lab Objective
Create a project directory, manage files, and explore permissions.

### Commands

```bash
# Navigate to home directory
cd ~

# Create a project directory
mkdir learning-linux
cd learning-linux

# Create subdirectories
mkdir docs scripts data

# Create files
echo "Project started" > README.txt
echo "#!/bin/bash" > scripts/setup.sh

# List files with details
ls -la

# Check current directory
pwd

# View file content
cat README.txt

# Copy file
cp README.txt docs/README_backup.txt

# Move file
mv README.txt docs/

# Change permissions (make script executable)
chmod +x scripts/setup.sh

# List files in scripts directory
ls -lh scripts/

# Display tree structure (if available)
tree
```

### Expected Output

```
total 24
drwxr-xr-x  5 user user 4096 Jan 27 10:00 .
drwxr-xr-x 20 user user 4096 Jan 27 10:00 ..
drwxr-xr-x  2 user user 4096 Jan 27 10:00 data
drwxr-xr-x  2 user user 4096 Jan 27 10:00 docs
drwxr-xr-x  2 user user 4096 Jan 27 10:00 scripts

/home/user/learning-linux

docs/:
-rw-r--r-- 1 user user 16 Jan 27 10:00 README.txt
-rw-r--r-- 1 user user 16 Jan 27 10:00 README_backup.txt

scripts/:
-rwxr-xr-x 1 user user 11 Jan 27 10:00 setup.sh
```

## Validation

Confirm you have completed this lab:

- [ ] Created `learning-linux` directory with 3 subdirectories
- [ ] Created files in appropriate directories
- [ ] Executed `ls -la` and saw proper directory listing
- [ ] Changed script permissions to executable (+x)
- [ ] Successfully copied and moved files
- [ ] Verified permissions changed using `ls -lh`

## Cleanup

```bash
# Return to home directory
cd ~

# Remove entire project (optional)
rm -rf learning-linux
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| `command not found` | Command may not be installed or not in PATH |
| `Permission denied` | Use `chmod +x` to add execute permission |
| `No such file or directory` | Check path spelling and use `pwd`, `ls` to verify location |
| Deleting wrong files | Always use `ls` before `rm`; test paths first |
| Not using quotes | Use quotes when paths contain spaces: `"my folder"` |

## Troubleshooting

**Q: How do I see hidden files?**
A: Use `ls -a` or `ls -la` to include hidden files starting with a dot.

**Q: How do I move back to the previous directory?**
A: Use `cd -` to go to the previous directory.

**Q: What's the difference between `rm` and `rm -r`?**
A: `rm` deletes files; `rm -r` deletes directories and their contents recursively.

**Q: Can I undo a deleted file?**
A: Regular `rm` doesn't use trash; deleted files are unrecoverable. Always double-check before deleting.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Practice until you're comfortable with navigation and file operations
3. Explore advanced commands in Module 2
4. Try combining commands with pipes and redirection
