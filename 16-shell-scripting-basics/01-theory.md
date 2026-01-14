# Shell Scripting Basics - Theory

Foundational concepts and patterns for writing effective bash scripts.

---

## 1. Shell Fundamentals

### What is a Shell?

A shell is a command interpreter - a program that reads commands and executes them. It's the interface between you and the operating system kernel.

```
User Input → Shell (Bash) → OS (Kernel) → Hardware
```

### Shells Available on Linux

| Shell | Name | Characteristics | Usage |
|-------|------|-----------------|-------|
| **bash** | Bourne Again Shell | Most common, feature-rich, widely used | Default on most Linux, scripts |
| **sh** | POSIX Shell | Minimal, portable, standard compliant | Lightweight, scripts, embedded |
| **zsh** | Z Shell | Extended bash, modern features | Interactive shells, power users |
| **fish** | Friendly Interactive Shell | User-friendly, modern syntax | Interactive only, not for scripts |
| **ksh** | Korn Shell | UNIX standard, balanced features | Enterprise systems, AIX |
| **csh/tcsh** | C Shell | C-like syntax, more for interaction | Interactive, less for scripting |

**For this course:** We focus on **bash** (default on Linux).

```bash
# Check your current shell
echo $SHELL

# Check available shells
cat /etc/shells

# Start bash explicitly
bash

# Check bash version
bash --version
```

### Shell Execution Modes

**Interactive Shell:**
```bash
# When you type commands in terminal
$ ls -la
$ grep "pattern" file.txt
$ cd /home
```

**Non-Interactive Shell (Script):**
```bash
# When running a script file
$ bash myscript.sh
$ ./myscript.sh
```

---

## 2. Script Structure

### Basic Script Format

```bash
#!/bin/bash
# Script purpose and description
# Author: Your Name
# Date: 2024-01-15

set -euo pipefail  # Error handling

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/script.log"

# Function definitions
show_help() {
    echo "Usage: $0 [OPTIONS]"
}

# Main script logic
main() {
    # Do the actual work
    echo "Script is running"
}

# Run main function
main "$@"
```

### Line-by-Line Breakdown

**Line 1: Shebang**
```bash
#!/bin/bash
```
- Tells the system which interpreter to use
- Must be first line
- `#!` = shebang, `/bin/bash` = path to bash
- Without it: script runs in current shell (unpredictable)

**Line 2-4: Comments**
```bash
# Script purpose and description
# Author: Your Name
# Date: 2024-01-15
```
- Start with `#`
- First comment block describes script purpose
- Include author and date for documentation

**Line 6: Error Handling Options**
```bash
set -euo pipefail
```
- `-e`: Exit immediately if command fails
- `-u`: Exit if undefined variable is used
- `-o pipefail`: Pipe returns fail status if any command fails
- **Recommended** for all scripts except special cases

**Lines 8-10: Global Variables**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/script.log"
```
- Define constants and variables at top
- Use UPPERCASE for constants
- Avoid hardcoding paths

**Lines 12-14: Function Definitions**
```bash
show_help() {
    echo "Usage: $0 [OPTIONS]"
}
```
- Define functions before using them
- Functions are like subroutines (code reuse)

**Line 18: Main Logic**
```bash
main() {
    # Do the actual work
    echo "Script is running"
}
```
- Put main logic in main() function
- Keeps code organized
- Easier to test and debug

**Line 21: Execution**
```bash
main "$@"
```
- Call main function with all arguments
- `$@` passes all positional parameters

---

## 3. Variables and Data Types

### Variable Declaration and Usage

```bash
# Declare variable (no spaces around =)
name="Alice"
age=30
active=true

# Use variable (always quote!)
echo "Hello, $name"
echo "Age: $age"

# Use with braces (clearer, safer)
echo "Hello, ${name}"

# Unset variable
unset age
```

**Important Rules:**
- No spaces around `=`
- Variable names: alphanumeric and underscore, start with letter
- Single quotes = literal, double quotes = expansion
- Always quote when expanding: "$var" not $var

### Variable Scope

```bash
# Global variable (accessible everywhere)
GLOBAL="visible globally"

function show_scope() {
    # Local variable (only in this function)
    local local_var="only here"
    
    echo "Global: $GLOBAL"
    echo "Local: $local_var"
}

show_scope
echo "Local outside function: $local_var"  # Empty!
```

### Special Variables

```bash
# Positional parameters (arguments to script)
$0  # Script name
$1  # First argument
$2  # Second argument
$@  # All arguments as separate words
$*  # All arguments as single string
$#  # Number of arguments

# Example: script.sh file1.txt file2.txt
# $0 = script.sh
# $1 = file1.txt
# $2 = file2.txt
# $@ = ("file1.txt" "file2.txt")
# $# = 2

# Process information
$$  # Process ID of current script
$?  # Exit code of last command (0=success)
$!  # Process ID of last background job

# Environment
$SHELL        # Current shell path
$HOME         # Home directory
$USER         # Current username
$PWD          # Current working directory
$PATH         # Command search paths
$HOSTNAME     # System hostname
```

### Arrays

```bash
# Declare array
fruits=("apple" "banana" "cherry")

# Access element (0-indexed)
echo "${fruits[0]}"  # apple
echo "${fruits[1]}"  # banana

# Get all elements
echo "${fruits[@]}"  # apple banana cherry

# Get array length
echo "${#fruits[@]}"  # 3

# Loop through array
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Add to array
fruits+=("date")

# Declare associative array (key-value)
declare -A config
config[host]="localhost"
config[port]="8080"
config[debug]="true"

echo "${config[host]}"  # localhost
echo "${config[port]}"  # 8080
```

---

## 4. Operators

### Arithmetic Operators

```bash
# Using arithmetic expansion $(( ))
result=$(( 5 + 3 ))      # 8
result=$(( 10 - 4 ))     # 6
result=$(( 3 * 4 ))      # 12
result=$(( 15 / 3 ))     # 5
result=$(( 17 % 5 ))     # 2 (modulo)
result=$(( 2 ** 3 ))     # 8 (exponent)

# Increment/decrement
count=5
count=$(( count + 1 ))   # 6
count=$(( ++count ))     # Pre-increment
count=$(( count++ ))     # Post-increment

# Simpler syntax with (())
(( count++ ))            # Increment
(( count-- ))            # Decrement
(( sum = a + b ))        # Assignment
```

### Comparison Operators (Numeric)

```bash
# Numeric comparison (inside [[ ]])
[[ 5 -eq 5 ]]    # Equal (-eq)
[[ 5 -ne 3 ]]    # Not equal (-ne)
[[ 5 -gt 3 ]]    # Greater than (-gt)
[[ 3 -lt 5 ]]    # Less than (-lt)
[[ 5 -ge 5 ]]    # Greater or equal (-ge)
[[ 3 -le 5 ]]    # Less or equal (-le)

# In arithmetic context
(( 5 == 5 ))     # Equal (can use ==)
(( 5 != 3 ))     # Not equal
(( 5 > 3 ))      # Greater than
(( 3 < 5 ))      # Less than
```

### String Comparison Operators

```bash
# String comparison
[[ "abc" == "abc" ]]     # String equal
[[ "abc" != "def" ]]     # String not equal
[[ "abc" < "def" ]]      # Lexicographic less than
[[ "def" > "abc" ]]      # Lexicographic greater than
[[ -z "string" ]]        # Empty string (-z)
[[ -n "string" ]]        # Non-empty string (-n)

# Pattern matching
[[ "hello" == h* ]]      # Glob pattern
[[ "hello" == *ll* ]]    # Contains pattern
[[ "hello" =~ ^h.*o$ ]]  # Regular expression
```

### Logical Operators

```bash
# AND (both conditions must be true)
if [[ $age -gt 18 && $age -lt 65 ]]; then
    echo "Working age"
fi

# OR (either condition must be true)
if [[ $OS == "Linux" || $OS == "Darwin" ]]; then
    echo "Unix-like system"
fi

# NOT (negate condition)
if [[ ! -f "$file" ]]; then
    echo "File does not exist"
fi

# Using -a and -o in [ ] (older style, not recommended)
[ $a -gt 5 -a $b -lt 10 ]   # AND
[ $a -gt 5 -o $b -lt 10 ]   # OR
```

### File and Directory Tests

```bash
# File tests
[[ -e "/etc/passwd" ]]       # Exists
[[ -f "/etc/passwd" ]]       # Regular file
[[ -d "/home" ]]             # Directory
[[ -L "/etc/ssl" ]]          # Symbolic link
[[ -r "/etc/passwd" ]]       # Readable
[[ -w "/tmp" ]]              # Writable
[[ -x "/usr/bin/bash" ]]     # Executable
[[ -s "/var/log/auth.log" ]] # Non-empty file

# Comparing files
[[ file1 -nt file2 ]]        # Newer than
[[ file1 -ot file2 ]]        # Older than
[[ file1 -ef file2 ]]        # Same file (hard link)
```

---

## 5. Control Flow - Conditionals

### If/Elif/Else Statements

```bash
# Simple if
if [[ $age -ge 18 ]]; then
    echo "Adult"
fi

# If-else
if [[ $status == "active" ]]; then
    echo "Service is running"
else
    echo "Service is stopped"
fi

# If-elif-else (multiple conditions)
if [[ $score -ge 90 ]]; then
    echo "Grade: A"
elif [[ $score -ge 80 ]]; then
    echo "Grade: B"
elif [[ $score -ge 70 ]]; then
    echo "Grade: C"
else
    echo "Grade: F"
fi
```

### Case Statements

```bash
# Switch-like structure for multiple options
case "$action" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting service..."
        ;;
    status)
        echo "Checking status..."
        ;;
    *)  # Default case
        echo "Unknown action: $action"
        exit 1
        ;;
esac
```

**Pattern Matching in Case:**
```bash
case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.jpg | *.png | *.gif)  # Multiple patterns
        echo "Image file"
        ;;
    *)
        echo "Unknown file type"
        ;;
esac
```

---

## 6. Loops and Iteration

### For Loop

```bash
# Loop through list
for fruit in apple banana cherry; do
    echo "Fruit: $fruit"
done

# Loop through array
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    echo "Processing: $file"
done

# C-style for loop
for (( i=1; i<=5; i++ )); do
    echo "Number: $i"
done

# Loop through command output
for line in $(cat /etc/passwd); do
    echo "Line: $line"
done

# Loop through file lines (better than above)
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/passwd
```

### While Loop

```bash
# While condition is true
count=1
while [[ $count -le 5 ]]; do
    echo "Count: $count"
    (( count++ ))
done

# Infinite loop (exit with break or condition)
while true; do
    read -p "Enter command: " cmd
    if [[ $cmd == "quit" ]]; then
        break
    fi
    eval "$cmd"
done

# Read from command
while read -r user shell; do
    echo "User: $user Shell: $shell"
done < <(grep -E '^[^#]' /etc/passwd)
```

### Until Loop

```bash
# Until condition is true (opposite of while)
count=1
until [[ $count -gt 5 ]]; do
    echo "Count: $count"
    (( count++ ))
done
```

### Loop Control

```bash
# Break: exit loop
for i in {1..10}; do
    if [[ $i -eq 5 ]]; then
        break  # Exit loop at 5
    fi
    echo "$i"
done

# Continue: skip to next iteration
for i in {1..10}; do
    if [[ $i -eq 5 ]]; then
        continue  # Skip 5, continue at 6
    fi
    echo "$i"
done
```

---

## 7. Functions

### Function Definition

```bash
# Basic function
my_function() {
    echo "Hello from function"
}

# Call function
my_function

# Function with parameters
greet() {
    local name="$1"
    local age="$2"
    echo "Hello, $name. You are $age years old."
}

greet "Alice" 30
greet "Bob" 25
```

**Rules:**
- Define before calling
- Parameters: `$1`, `$2`, etc. (same as script)
- Use `$@` for all parameters
- Use `local` for local variables

### Return Values

```bash
# Return exit code (0-255)
is_even() {
    local num="$1"
    if (( num % 2 == 0 )); then
        return 0  # Success (even)
    else
        return 1  # Failure (odd)
    fi
}

# Check return value
if is_even 4; then
    echo "4 is even"
else
    echo "4 is odd"
fi

# Get return code
is_even 5
result=$?
echo "Return code: $result"  # 1
```

### Function Output

```bash
# Capture output
get_date() {
    echo "Current date: $(date +%Y-%m-%d)"
}

output=$(get_date)
echo "$output"

# Multiple returns (return code + output)
get_info() {
    echo "Information here"
    return 0
}

info=$(get_info)
status=$?
echo "Info: $info, Status: $status"
```

### Local Variables

```bash
# Global variable
GLOBAL="I'm global"

demo_scope() {
    # Local variable (only in function)
    local local_var="I'm local"
    
    # Can access global
    echo "Global: $GLOBAL"
    echo "Local: $local_var"
}

demo_scope
echo "Local outside: $local_var"  # Empty
echo "Global outside: $GLOBAL"     # Works
```

---

## 8. Input and Output

### Reading Input

```bash
# Read single line from keyboard
read -p "Enter name: " name
echo "Hello, $name"

# Read without prompt
read name
echo "Hello, $name"

# Read from file (line by line)
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hostname

# Read with default value
read -p "Enter name [Anonymous]: " name
name="${name:-Anonymous}"

# Silent input (password)
read -sp "Enter password: " password
echo ""  # New line after password prompt

# Array input (space-separated)
read -a names
echo "First: ${names[0]}"
```

### Output

```bash
# Echo (simple output)
echo "Hello, World"
echo -n "No newline"          # No newline at end
echo -e "Line1\nLine2"        # Enable escape sequences
echo "First: $name"           # Variable expansion

# Printf (formatted output, like C)
printf "Name: %s\n" "$name"
printf "Age: %d\n" "$age"
printf "Percent: %.2f\n" 3.14159

# Printf format specifiers
%s  # String
%d  # Integer
%f  # Float
%x  # Hexadecimal
%o  # Octal
%.2f # Float with 2 decimals
%-10s # Left-aligned string, 10 chars wide
%10s  # Right-aligned string, 10 chars wide
```

### Redirection

```bash
# Send output to file
echo "Hello" > output.txt           # Overwrite
echo "Hello again" >> output.txt    # Append

# Send stderr to file
command 2> error.log                # Stderr only
command > output.log 2>&1           # Both stdout and stderr

# Use file as input
grep "pattern" < input.txt

# Multiple redirections
command > stdout.log 2> stderr.log  # Separate files

# Pipe: output of one command to input of another
cat file.txt | grep "pattern"
cat file.txt | wc -l
```

---

## 9. Error Handling

### Exit Codes

```bash
# Every command returns exit code
ls /some/path
echo $?  # Check last command's exit code
# 0 = success, non-zero = error

# Use exit codes in conditions
if grep -q "pattern" file.txt; then
    echo "Pattern found"
else
    echo "Pattern not found"
fi
```

### Set Options for Safety

```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on error
#   Script stops if any command fails
#   Without it: errors are ignored

# -u: Exit on undefined variable
#   Script stops if accessing undefined $variable
#   Catches typos like $varname vs $varname

# -o pipefail: Pipe fails if any command fails
#   Without it: only last command's status matters
#   cat file | grep pattern | sort
#   If grep fails, script continues (bad!)
```

### Error Handling with Trap

```bash
#!/bin/bash
set -euo pipefail

# Define cleanup function
cleanup() {
    local status=$?
    echo "Script exited with status $status"
    
    # Clean up temporary files
    rm -f /tmp/temp_*
    
    # Kill background jobs
    jobs -p | xargs kill 2>/dev/null || true
}

# Set trap to run cleanup on EXIT
trap cleanup EXIT

# Set trap for specific signals
trap 'echo "Script interrupted"; exit 1' INT TERM

# Main script
echo "Script started"
# ... do work ...
echo "Script completed"
```

### Validating Input

```bash
# Check if argument provided
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"

# Check if file exists
if [[ ! -f "$filename" ]]; then
    echo "Error: File not found: $filename"
    exit 1
fi

# Check if string is empty
if [[ -z "$name" ]]; then
    echo "Error: Name cannot be empty"
    exit 1
fi

# Check if number is valid
if ! [[ "$age" =~ ^[0-9]+$ ]]; then
    echo "Error: Age must be a number"
    exit 1
fi
```

---

## 10. Best Practices and Style

### Naming Conventions

```bash
# Constants: UPPERCASE
readonly DB_HOST="localhost"
readonly MAX_RETRIES=3

# Variables: lowercase with underscores
user_name="Alice"
file_count=42

# Functions: lowercase with underscores
display_help() { ... }
validate_input() { ... }
process_file() { ... }

# Avoid single letters except loops
for i in "${array[@]}"; do ... fi  # OK in short loop
for item in "${array[@]}"; do ... fi  # Better elsewhere
```

### Quoting Variables

```bash
# Always quote variables to handle spaces
filename="my file.txt"

# Wrong (breaks with spaces)
cat $filename           # Error: my: not found

# Correct
cat "$filename"         # Works

# Always use quotes around expansions
echo "$var"            # Safe
echo "${var}"          # Also safe, clearer
echo $var              # Risky, avoid

# Quoting arrays
for file in "$@"; do   # Correct, preserves spaces
    echo "File: $file"
done

for file in $@; do     # Wrong, breaks on spaces
    echo "File: $file"
done
```

### Comments and Documentation

```bash
#!/bin/bash
# Script: backup_database.sh
# Purpose: Automated daily backup of production database
# Author: DevOps Team
# Date: 2024-01-15
# Usage: ./backup_database.sh [--dry-run] [--output /path]

# Global configuration
readonly DB_USER="backupuser"
readonly DB_PASS="${DB_PASSWORD:-/etc/backup.pwd}"
readonly BACKUP_DIR="/backups"

# Function to perform backup
backup_database() {
    # Check database connectivity before starting
    if ! mysqladmin ping &> /dev/null; then
        echo "Error: Cannot connect to database"
        return 1
    fi
    
    # Create backup file with timestamp
    local backup_file="${BACKUP_DIR}/db-$(date +%Y%m%d-%H%M%S).sql"
    
    # Perform backup
    mysqldump -u "$DB_USER" -p"$DB_PASS" database > "$backup_file"
    
    return $?
}
```

### Function Organization

```bash
#!/bin/bash
set -euo pipefail

# Usage: show_help
# Displays help message
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] FILE

Options:
  -h, --help      Show this help
  -v, --verbose   Verbose output
  -d, --dry-run   Show what would happen
EOF
}

# Usage: validate_file <filename>
# Returns: 0 if file is valid, 1 otherwise
validate_file() {
    local filename="$1"
    
    if [[ ! -f "$filename" ]]; then
        echo "Error: File not found: $filename" >&2
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    # Parse arguments
    local verbose=0
    
    if [[ $# -lt 1 ]]; then
        show_help
        return 1
    fi
    
    # Process file
    local file="$1"
    if ! validate_file "$file"; then
        return 1
    fi
    
    echo "Processing: $file"
}

main "$@"
```

### Performance Tips

```bash
# Avoid unnecessary subshells
# Bad: output=$(cat file.txt) | wc -l
# Good:
mapfile -t lines < file.txt
echo "${#lines[@]}"

# Use built-in commands instead of external
# Bad: NAME=$(echo "$string" | cut -d' ' -f1)
# Good: NAME="${string%% *}"  (parameter expansion)

# Avoid unnecessary loops
# Bad:
for file in *.txt; do
    cat "$file"
done

# Good:
cat *.txt

# Use [[ ]] instead of [ ]
# Bad: [ "$var" = "value" ]
# Good: [[ $var == value ]]
```

---

## Summary

**Key Concepts:**
1. **Structure:** Shebang, error handling, functions, main logic
2. **Variables:** Declare, scope, special variables, arrays
3. **Operators:** Arithmetic, comparison, logical, file tests
4. **Control Flow:** If/else, case statements
5. **Loops:** For, while, until with break/continue
6. **Functions:** Definition, parameters, return values, local variables
7. **I/O:** Reading input, output formatting, redirection
8. **Error Handling:** Exit codes, trap, set options, validation
9. **Best Practices:** Naming, quoting, comments, organization
10. **Style:** Consistent formatting, security-aware design

---

**Next:** [02-commands-cheatsheet.md](02-commands-cheatsheet.md)
