# Shell Scripting Basics: Solutions

## Exercise 1: Create Simple Script

**Solution:**

```bash
# Create script file
cat > hello.sh << 'EOF'
#!/bin/bash

echo "Hello, World!"
echo "Script is running successfully"
EOF

# Make executable
chmod +x hello.sh

# Run script
./hello.sh
# Output:
# Hello, World!
# Script is running successfully

# View contents
cat hello.sh
```

**Explanation:** Shebang tells system to use bash. `chmod +x` makes executable. `./` runs in current directory.

---

## Exercise 2: Use Variables

**Solution:**

```bash
#!/bin/bash

# Declare variables
NAME="DevOps Engineer"
VERSION="1.0"

# Command substitution
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

# Display variables
echo "Name: $NAME"
echo "Version: $VERSION"
echo "Date: $DATE"
echo "Time: $TIME"

# Combine variables
GREETING="Hello $NAME on $DATE"
echo "$GREETING"

# Export variable
export MY_VAR="exported_value"
echo "Exported: $MY_VAR"
```

**Output:**
```
Name: DevOps Engineer
Version: 1.0
Date: 2025-01-27
Time: 14:30:22
Hello DevOps Engineer on 2025-01-27
Exported: exported_value
```

**Explanation:** Variables = storage. `$(command)` = run command and capture output. Export = available to subshells.

---

## Exercise 3: Accept Command Arguments

**Solution:**

```bash
#!/bin/bash

echo "Script name: $0"
echo "First arg: $1"
echo "Second arg: $2"
echo "Third arg: $3"
echo "All args: $@"
echo "Total args: $#"

# Process all arguments
echo "Processing arguments:"
for arg in "$@"; do
    echo "  - $arg"
done
```

**Usage:**
```bash
chmod +x args.sh
./args.sh foo bar baz

# Output:
# Script name: ./args.sh
# First arg: foo
# Second arg: bar
# Third arg: baz
# All args: foo bar baz
# Total args: 3
# Processing arguments:
#   - foo
#   - bar
#   - baz
```

**Explanation:** $0=script name. $1-$9=positional args. $@=all args. $#=count.

---

## Exercise 4: Conditional Logic

**Solution:**

```bash
#!/bin/bash

FILE="/etc/hostname"
DIR="/home"

# Test file existence
if [ -f "$FILE" ]; then
    echo "File exists: $FILE"
else
    echo "File not found"
fi

# Test directory existence
if [ -d "$DIR" ]; then
    echo "Directory exists: $DIR"
fi

# Compare numbers
a=10
b=20
if [ $a -eq $b ]; then
    echo "Equal"
elif [ $a -lt $b ]; then
    echo "$a is less than $b"
fi

# Compare strings
user="admin"
if [ "$user" = "admin" ]; then
    echo "Admin detected"
fi

# Multiple conditions
if [ -f "$FILE" ] && [ -r "$FILE" ]; then
    echo "File exists and is readable"
fi

# Logical OR
if [ "$user" = "admin" ] || [ "$user" = "root" ]; then
    echo "Privileged user"
fi
```

**Output:**
```
File exists: /etc/hostname
Directory exists: /home
10 is less than 20
Admin detected
File exists and is readable
Privileged user
```

**Explanation:** -f=file, -d=directory, -eq=equal, -lt=less than, =string equality, &&=AND, ||=OR.

---

## Exercise 5: Loop Through Items

**Solution:**

```bash
#!/bin/bash

# For loop with list
echo "For loop:"
for fruit in apple banana orange; do
    echo "  $fruit"
done

# Loop through command output
echo "Loop through files:"
for file in $(ls /etc/passwd /etc/group 2>/dev/null); do
    echo "  $file"
done

# While loop with counter
echo "While loop (count to 5):"
i=1
while [ $i -le 5 ]; do
    echo "  Count: $i"
    i=$((i + 1))
done

# Break out of loop
echo "Loop with break:"
for i in 1 2 3 4 5; do
    if [ $i -eq 3 ]; then
        break
    fi
    echo "  $i"
done

# Continue to next iteration
echo "Loop with continue:"
for i in 1 2 3 4 5; do
    if [ $i -eq 3 ]; then
        continue
    fi
    echo "  $i"
done
```

**Output:**
```
For loop:
  apple
  banana
  orange
Loop through files:
  /etc/passwd
  /etc/group
While loop (count to 5):
  Count: 1
  Count: 2
  Count: 3
  Count: 4
  Count: 5
Loop with break:
  1
  2
Loop with continue:
  1
  2
  4
  5
```

**Explanation:** for=iterate list. while=repeat while true. break=exit loop. continue=skip to next.

---

## Exercise 6: Create Functions

**Solution:**

```bash
#!/bin/bash

# Simple function
greet() {
    echo "Hello from function!"
}

# Function with arguments
add_numbers() {
    local num1=$1
    local num2=$2
    local sum=$((num1 + num2))
    echo "$sum"
}

# Function with return value
check_file() {
    if [ -f "$1" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Function with output
get_date() {
    date +"%Y-%m-%d"
}

# Call functions
greet
result=$(add_numbers 10 20)
echo "Sum: $result"

if check_file "/etc/hostname"; then
    echo "File found"
else
    echo "File not found"
fi

TODAY=$(get_date)
echo "Today: $TODAY"
```

**Output:**
```
Hello from function!
Sum: 30
File found
Today: 2025-01-27
```

**Explanation:** Functions = code blocks. `local` = function scope. Return value = exit code. `$()` = capture output.

---

## Exercise 7: Error Handling

**Solution:**

```bash
#!/bin/bash

set -e  # Exit on error

# Function to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile.txt 2>/dev/null
}

trap cleanup EXIT

# Check exit status
ls /nonexistent 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Directory doesn't exist"
fi

# Validate input
validate_input() {
    if [ -z "$1" ]; then
        echo "Error: Argument required" >&2
        return 1
    fi
}

# Try-catch pattern
if validate_input "$1"; then
    echo "Input valid: $1"
else
    echo "Validation failed"
    exit 1
fi

# Error handling with message
create_file() {
    if ! touch /tmp/test_file; then
        echo "Error: Cannot create file" >&2
        return 1
    fi
    echo "File created successfully"
}

create_file || echo "File creation failed"
```

**Output:**
```
Directory doesn't exist
Input valid: somearg
File created successfully
Cleaning up...
```

**Explanation:** set -e=exit on error. trap=cleanup handler. $?=exit code. >&2=error output.

---

## Exercise 8: File Operations

**Solution:**

```bash
#!/bin/bash

# Read file line by line
echo "Reading /etc/passwd:"
while IFS=: read -r username password uid gid; do
    if [ "$uid" -ge 1000 ]; then
        echo "  User: $username (UID: $uid)"
    fi
done < /etc/passwd | head -3

# Check permissions
echo "Checking permissions:"
ls -l /etc/hostname | awk '{print $1, $NF}'

# Write to file
echo "Writing to file:"
cat > /tmp/myfile.txt << 'EOF'
Line 1
Line 2
Line 3
EOF

# Append to file
echo "Line 4" >> /tmp/myfile.txt
cat /tmp/myfile.txt

# Process multiple files
echo "Processing files:"
for file in /tmp/myfile.txt; do
    echo "  File: $file"
    wc -l "$file"
done
```

**Output:**
```
Reading /etc/passwd:
  User: user (UID: 1000)
Checking permissions:
-rw-r--r-- /etc/hostname
Writing to file:
Line 1
Line 2
Line 3
Line 4
Processing files:
  File: /tmp/myfile.txt
  4 /tmp/myfile.txt
```

**Explanation:** IFS=read delimiter. <file=read from file. >>append. while loop=line by line.

---

## Exercise 9: String Manipulation

**Solution:**

```bash
#!/bin/bash

STRING="DevOps_Engineer"

# Extract substring
echo "Original: $STRING"
echo "First 6 chars: ${STRING:0:6}"
echo "From position 7: ${STRING:7}"

# Replace text
REPLACED="${STRING//_/ }"
echo "Replaced underscore: $REPLACED"

# Convert case
echo "Uppercase: ${STRING^^}"
echo "Lowercase: ${STRING,,}"

# Count characters
echo "Length: ${#STRING}"

# Validate with regex
if [[ "$STRING" =~ ^[A-Za-z_]+$ ]]; then
    echo "Valid pattern"
fi

# Remove prefix/suffix
VAR="prefix_data_suffix"
echo "Remove prefix: ${VAR#prefix_}"
echo "Remove suffix: ${VAR%_suffix}"
```

**Output:**
```
Original: DevOps_Engineer
First 6 chars: DevOps
From position 7: Engineer
Replaced underscore: DevOps Engineer
Uppercase: DEVOPS_ENGINEER
Lowercase: devops_engineer
Length: 15
Valid pattern
Remove prefix: data_suffix
Remove suffix: prefix_data
```

**Explanation:** `${var:start:len}`=substring. `${var//old/new}`=replace. `${#var}`=length. `=~`=regex match.

---

## Exercise 10: Build Practical Script

**Solution:**

```bash
#!/bin/bash

set -e

# Functions
show_help() {
    cat << 'EOF'
Usage: system_info.sh [OPTION]

Options:
  -u, --users      Show active users
  -d, --disk       Show disk usage
  -m, --memory     Show memory usage
  -a, --all        Show all info
  -h, --help       Show this help
EOF
}

show_users() {
    echo "=== Active Users ==="
    w -h | awk '{print $1}' | sort -u
}

show_disk() {
    echo "=== Disk Usage ==="
    df -h | grep -v tmpfs | tail -5
}

show_memory() {
    echo "=== Memory Usage ==="
    free -h
}

# Validate arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Process arguments
case "$1" in
    -u|--users)  show_users ;;
    -d|--disk)   show_disk ;;
    -m|--memory) show_memory ;;
    -a|--all)    show_users; show_disk; show_memory ;;
    -h|--help)   show_help ;;
    *)           echo "Unknown option"; show_help; exit 1 ;;
esac
```

**Output:**
```bash
./system_info.sh -a

=== Active Users ===
root
user

=== Disk Usage ===
/dev/sda1  30G  10G  20G  33% /
/dev/sdb1  50G 100M  50G   1% /mnt

=== Memory Usage ===
              total        used        free
Mem:           7.8G        2.3G        5.5G
```

**Explanation:** case=multi-option handling. Functions=organization. Error handling=reliability. Help=usability.
