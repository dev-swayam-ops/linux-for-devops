# Module 01: Linux Basics Commands

## Overview

Linux is an open-source operating system that powers everything from servers and cloud infrastructure to embedded systems and personal computers. The command line (terminal) is where the real power lies. While graphical interfaces are convenient, true control and efficiency come from mastering the command line.

This module teaches you the fundamental commands and concepts that form the foundation of Linux administration and development. Whether you're becoming a DevOps engineer, system administrator, developer, or just want to understand Linux better, these basics are essential.

### Why This Matters

- **Speed:** Typing a command is often faster than clicking through menus
- **Power:** Advanced tasks are usually only available from the command line
- **Automation:** Scripts and automation rely entirely on commands
- **Remote Work:** SSH connections to servers only provide a terminal
- **Career:** Every Linux professional needs these skills
- **Understanding:** The command line exposes how Linux actually works

### Real-World Applications

- Managing servers and cloud instances
- Automating repetitive tasks
- Processing data and logs
- Managing files and permissions
- Troubleshooting system issues
- Writing scripts and automation tools
- Working with version control (git)
- Managing containers and orchestration platforms

## Prerequisites

Before starting this module, you should have:

- A computer with Linux installed (Ubuntu 20.04+, Debian 10+, CentOS 7+) or access to one via SSH
- Alternatively, use Windows Subsystem for Linux (WSL), Docker, or a virtual machine
- Basic understanding of what an operating system is
- Willingness to type and experiment

**No prior Linux or programming experience required!**

## Learning Objectives

After completing this module, you will be able to:

### Basic Navigation
1. Understand the Linux directory structure
2. Navigate between directories
3. Understand absolute and relative paths
4. Know where you are in the filesystem at all times

### File Operations
5. Create, copy, move, and delete files
6. Create and manage directories
7. Understand file types and extensions
8. Safely work with multiple files

### File Content & Viewing
9. View file contents in different ways
10. Search for text within files
11. Sort and filter file contents
12. Understand text processing basics

### File Permissions & Ownership
13. Understand the permission system (rwx)
14. Change file permissions
15. Change file ownership
16. Know when to use different permissions

### Help & Information
17. Use man pages effectively
18. Get help for any command
19. Understand command syntax
20. Know where to find information

### Command Basics
21. Understand command structure and syntax
22. Work with arguments and options
23. Use wildcards and patterns
24. Chain commands together

### System & User Information
25. Understand user accounts and groups
26. View system and user information
27. Manage your own user environment
28. Understand shells and environment variables

## Module Roadmap

```
01-linux-basics-commands/
├── README.md (you are here)
├── 01-theory.md - Core concepts, directory structure, shells
├── 02-commands-cheatsheet.md - 40+ commands with examples
├── 03-hands-on-labs.md - 10 practical labs
└── scripts/
    ├── file-organizer.sh - Organize files by type
    ├── permission-checker.sh - Audit file permissions
    └── README.md - Script documentation
```

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Terminal/Console** | Application where you type Linux commands |
| **Shell** | Program that interprets your commands (usually bash) |
| **Command** | A program or instruction you type (e.g., `ls`, `cd`) |
| **Directory** | A folder that contains files and other directories |
| **Path** | Location of a file or directory in the filesystem |
| **Absolute Path** | Full path from root: `/home/user/documents/file.txt` |
| **Relative Path** | Path from current location: `documents/file.txt` |
| **Root** | `/` - top of the filesystem, or the superuser account |
| **Home Directory** | `/home/username` - your personal directory (shortcut: `~`) |
| **Permission** | Read (r), Write (w), Execute (x) - who can do what |
| **Owner** | User who owns the file |
| **Group** | Set of users with shared permissions |
| **Exit Code** | Number returned by a command (0 = success, non-zero = error) |
| **Standard Output** | Normal output from a command |
| **Standard Error** | Error messages from a command |
| **Pipe** | `\|` - send output of one command to another |
| **Redirect** | `>` or `>>` - send output to a file |
| **Wildcard** | `*`, `?`, `[ ]` - pattern matching for filenames |
| **Environment Variable** | Named value stored in the shell (e.g., `PATH`, `HOME`) |
| **Alias** | Custom shortcut for a command |
| **Script** | File containing commands to run in sequence |
| **Sudo** | "Superuser do" - run command with elevated privileges |

## How to Use This Module

### Learning Path

1. **Start with theory** (01-theory.md)
   - Read about the Linux filesystem structure
   - Understand the shell and how commands work
   - Learn about users, permissions, and environment variables
   - Review ASCII diagrams

2. **Learn the commands** (02-commands-cheatsheet.md)
   - Start with the most common commands
   - Run each command on your own system to see output
   - Try variations with different options
   - Build muscle memory

3. **Practice with labs** (03-hands-on-labs.md)
   - Follow labs in order (they build on each other)
   - Don't rush - understand each step
   - Check your work against expected output
   - Always run cleanup commands

4. **Explore the scripts** (scripts/)
   - Understand what each script does
   - Run them on your system
   - Modify and experiment
   - Learn by example

### Time Estimate

- Reading theory: 60-90 minutes
- Command practice: 60-90 minutes
- Hands-on labs: 120-150 minutes
- **Total:** 5-6 hours

### Environment Setup

**For Debian/Ubuntu:**
```bash
# Update package lists
sudo apt-get update

# Install some useful tools for labs
sudo apt-get install -y tree man-db ncurses-bin

# Verify bash is available
bash --version
```

**For RHEL/CentOS:**
```bash
# Update packages
sudo yum update -y

# Install useful tools
sudo yum install -y tree man-db

# Verify bash
bash --version
```

**Verify Your Setup:**
```bash
# Check Linux version
uname -a

# Check bash version
echo $BASH_VERSION

# Check if we can create files (needed for labs)
touch ~/test.txt && rm ~/test.txt && echo "Setup OK"
```

## Safety Notes

- ✅ All labs use safe commands that don't harm your system
- ⚠️ Never run unknown commands with `sudo` without understanding them
- ⚠️ Be careful with `rm` command - deleted files are hard to recover
- ✅ All labs include cleanup steps to remove test files
- ✅ Use a VM or test system if you're unsure
- ✅ Read the command description before running it

## Key Concepts at a Glance

### Linux Directory Structure
```
/               ← Root of entire filesystem
├── /bin        ← Essential commands (ls, cat, etc)
├── /home       ← User home directories
├── /etc        ← Configuration files
├── /tmp        ← Temporary files (deleted on reboot)
├── /var        ← Variable data (logs, caches)
├── /usr        ← User programs and data
├── /root       ← Root user home directory
└── /opt        ← Optional software
```

### Command Structure
```
command [options] [arguments]

Examples:
ls                           # List files
ls -la                       # List all files, long format
cp file1.txt file2.txt      # Copy file1 to file2
ls *.txt                     # List all .txt files
```

### File Permissions
```
-rw-r--r-- 1 user group 1234 Jan 14 10:30 file.txt
│││││││││
││└──┴──┘ Others permissions (r--: read only)
│└──┬──┘ Group permissions (r--: read only)
└──┬─── Owner permissions (rw-: read, write)

Permission values:
r (read) = 4
w (write) = 2
x (execute) = 1
```

### Common Workflows

**Workflow 1: Find and View a File**
```bash
cd ~/Documents          # Navigate to directory
ls -la                  # List what's there
cat report.txt          # View the file
```

**Workflow 2: Create and Edit Files**
```bash
cd ~/projects           # Go to projects
mkdir my-project        # Create directory
cd my-project           # Enter it
nano README.md          # Create/edit file
ls -la                  # Verify it exists
```

**Workflow 3: Search and Filter**
```bash
grep "error" logfile.txt        # Find lines with "error"
ls -la | grep "\.txt$"          # Find .txt files in listing
find . -name "*.log"            # Find all .log files
```

**Workflow 4: Organize Files**
```bash
mkdir backup            # Create backup folder
cp *.txt backup/        # Copy all .txt files there
ls backup/              # Verify they're there
rm *.txt                # Remove originals (careful!)
```

## Key Commands at a Glance

| Command | Purpose | Example |
|---------|---------|---------|
| `ls` | List files | `ls -la` |
| `cd` | Change directory | `cd /home/user` |
| `pwd` | Print working directory | `pwd` |
| `mkdir` | Make directory | `mkdir newdir` |
| `cp` | Copy file | `cp file1 file2` |
| `mv` | Move/rename file | `mv old.txt new.txt` |
| `rm` | Remove file | `rm file.txt` |
| `cat` | Show file contents | `cat file.txt` |
| `grep` | Search text | `grep "pattern" file.txt` |
| `chmod` | Change permissions | `chmod 755 file` |
| `chown` | Change owner | `sudo chown user:group file` |
| `man` | Show manual page | `man ls` |
| `echo` | Print text | `echo "Hello"` |
| `find` | Search for files | `find . -name "*.txt"` |
| `head` | Show first lines | `head -n 5 file.txt` |
| `tail` | Show last lines | `tail -n 5 file.txt` |

## Troubleshooting Common Issues

| Problem | Command to Check | Solution |
|---------|------------------|----------|
| Lost - don't know where I am | `pwd` | Use to see current location |
| Can't find a file | `find . -name filename` | Search entire current directory |
| Permission denied | `ls -la filename` | Check permissions, might need `sudo` |
| Command not found | `which commandname` | Command might not be installed |
| Can't read file | `cat filename` → `head filename` | Try head if file too large |
| Made a mistake | Consult cleanup steps | All labs have cleanup commands |
| Deleted file accidentally | Can't recover without backup | Use `find` to look in trash if available |

## What's Next After This Module?

- **Module 02:** Linux Advanced Commands - Master grep, sed, awk, cut
- **Module 03:** Crontab and Scheduling - Automate tasks
- **Module 04:** Networking and Ports - Work with network interfaces
- **Module 05:** Memory and Disk - Manage system resources
- **Module 08:** User and Permission Management - Multi-user systems

## Getting Started

1. ✅ Read this entire README
2. ✅ Work through 01-theory.md
3. ✅ Reference 02-commands-cheatsheet.md while practicing
4. ✅ Complete 03-hands-on-labs.md in order (don't skip!)
5. ✅ Explore the scripts in scripts/
6. ✅ Try modifying and creating your own scripts

## Resources & References

### Man Pages to Start With
```bash
man ls          # File listing
man cd          # Change directory
man mkdir       # Make directory
man cp          # Copy files
man grep        # Search text
man chmod       # Change permissions
man man         # How to use man pages!
```

### Online Resources
- `help` command - Built-in shell help (`help cd`)
- `info` command - More detailed than man (`info ls`)
- `--help` flag - Quick help for most commands (`ls --help`)

### Key Topics Covered
1. **Directory Structure** - How files are organized
2. **Navigation** - Moving around the filesystem
3. **File Operations** - Creating, copying, moving, deleting
4. **Viewing Content** - Different ways to see file contents
5. **Text Search** - Finding what you need
6. **Permissions** - Access control
7. **Ownership** - Who owns what
8. **Help Systems** - Getting information
9. **Command Syntax** - How to speak Linux
10. **Variables & Environment** - System configuration

## Success Criteria

By the end of this module, you should be able to:

- ✅ Navigate the filesystem confidently
- ✅ Create, view, and manipulate files
- ✅ Understand and change file permissions
- ✅ Search for files and text
- ✅ Get help for any command
- ✅ Read command documentation
- ✅ Use wildcards and patterns
- ✅ Chain commands together
- ✅ Understand the file structure
- ✅ Complete all 10 hands-on labs

---

**Ready to start?** Begin with [01-theory.md](01-theory.md) to understand the concepts, then move to the commands and labs.

**Questions about Linux?** Check the troubleshooting section above, then refer to man pages using `man COMMAND`.

**Found an issue?** All labs are designed to be reversible with cleanup commands. Don't worry about making mistakes!

Good luck! You're about to master the Linux command line. 🚀
