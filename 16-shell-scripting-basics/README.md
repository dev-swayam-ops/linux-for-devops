# Module 16: Shell Scripting Basics

## What You'll Learn

- Write Bash scripts with proper structure
- Use variables and command substitution
- Control flow (if/else, loops)
- Functions and script organization
- Error handling and debugging
- Script best practices
- File permissions and execution

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Complete Module 2: Advanced Commands
- Comfortable with command line
- Understanding of pipes and redirects

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Shebang** | `#!/bin/bash` first line specifies interpreter |
| **Variable** | `$var` or `${var}` for storing values |
| **Command Sub** | `$(command)` or `` `command` `` |
| **Conditional** | `if [ condition ]` control logic |
| **Loop** | `for/while` iterate over items |
| **Function** | `function_name() {}` reusable code blocks |
| **Exit Code** | `$?` success (0) or failure (non-zero) |
| **Quote** | Single vs double vs no quotes for expansion |

## Hands-on Lab: Create and Run Your First Script

### Lab Objective
Write, execute, and test a practical bash script.

### Script Example

```bash
#!/bin/bash

# Filename: backup.sh
# Purpose: Backup files to directory

set -e  # Exit on error

BACKUP_DIR="/tmp/backups"
SOURCE_DIR="/home/user/documents"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup files
if [ -d "$SOURCE_DIR" ]; then
    tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" "$SOURCE_DIR"
    echo "Backup completed: $BACKUP_DIR/backup_$DATE.tar.gz"
else
    echo "Error: Source directory not found"
    exit 1
fi

# Verify backup
if [ -f "$BACKUP_DIR/backup_$DATE.tar.gz" ]; then
    echo "Verification: Backup file exists"
    ls -lh "$BACKUP_DIR/backup_$DATE.tar.gz"
else
    echo "Error: Backup file not created"
    exit 1
fi
```

### Commands

```bash
# Create script file
nano backup.sh

# Make executable
chmod +x backup.sh

# Run script
./backup.sh

# Run with bash explicitly
bash backup.sh

# Run from anywhere
/path/to/backup.sh

# Debug mode
bash -x backup.sh

# Check syntax
bash -n backup.sh
```

### Expected Output

```
Backup completed: /tmp/backups/backup_20250127_143022.tar.gz
Verification: Backup file exists
-rw-r--r-- 1 user user 1.2K Jan 27 14:30 /tmp/backups/backup_20250127_143022.tar.gz
```

## Validation

Confirm successful completion:

- [ ] Created script with shebang line
- [ ] Made script executable
- [ ] Ran script successfully
- [ ] Output shows expected results
- [ ] Verified error handling works
- [ ] Tested with debug mode

## Cleanup

```bash
# Remove test scripts
rm -f backup.sh
rm -rf /tmp/backups
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Missing shebang | Add `#!/bin/bash` as first line |
| Not executable | Use `chmod +x script.sh` |
| Quoting variables | Use quotes: `"$var"` to prevent splitting |
| No error handling | Add `set -e` or check `$?` |
| Hardcoded paths | Use variables for flexibility |

## Troubleshooting

**Q: Script runs but says "command not found"?**
A: Use full path or add to PATH. Check shebang. Use `which command`.

**Q: "Permission denied" error?**
A: Make executable: `chmod +x script.sh`.

**Q: Variables not expanding?**
A: Use double quotes `"$var"`, not single `'$var'`.

**Q: Script works interactively but fails in cron?**
A: Add full paths. Use `set -x` for debugging. Check cron logs.

**Q: How do I pass arguments to scripts?**
A: Use `$1, $2, $3` for positional args. Use `$@` for all args.

## Next Steps

1. Complete all exercises
2. Write practical scripts
3. Learn error handling patterns
4. Explore advanced features
5. Build reusable function libraries
