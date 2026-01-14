# Shell Scripting Basics - Hands-On Labs

10 complete hands-on laboratories with real-world applications.

**Total Time:** ~5.5 hours (labs 1-10)

---

## Lab 1: Hello Bash - Your First Script (30 minutes)

### Objective
Learn basic script structure, execution, and output.

### Prerequisites
- Text editor (nano, vim, or VS Code)
- Terminal access
- Bash installed

### Setup
```bash
# Create lab directory
mkdir -p ~/shell-labs/lab1
cd ~/shell-labs/lab1
```

### Step 1: Create Your First Script

```bash
# Open editor
nano hello.sh
```

**Type the following:**
```bash
#!/bin/bash
# My first bash script

echo "Hello, Bash!"
echo "Welcome to shell scripting!"
```

**Save:** Ctrl+O, Enter, Ctrl+X

### Step 2: Check Syntax

```bash
# Check script syntax without running
bash -n hello.sh

# Expected output: (nothing - no errors)
```

### Step 3: Make Script Executable

```bash
# Give execute permission
chmod +x hello.sh

# List with permissions
ls -l hello.sh

# Expected output:
# -rwxr-xr-x 1 user user 89 Jan 15 10:30 hello.sh
```

### Step 4: Execute Script

```bash
# Method 1: Direct execution
./hello.sh

# Expected output:
# Hello, Bash!
# Welcome to shell scripting!

# Method 2: Using bash
bash hello.sh

# Same output
```

### Step 5: Add Script Path to Output

**Edit hello.sh:**
```bash
#!/bin/bash
# My first bash script

echo "Script name: $0"
echo "Script location: $(pwd)"
echo ""
echo "Hello, Bash!"
echo "Welcome to shell scripting!"
```

**Run again:**
```bash
./hello.sh

# Expected output:
# Script name: ./hello.sh
# Script location: /home/user/shell-labs/lab1
# 
# Hello, Bash!
# Welcome to shell scripting!
```

### Step 6: Add Comments and Documentation

**Edit to add comprehensive comments:**
```bash
#!/bin/bash
# Script: hello.sh
# Purpose: Demonstrate basic script structure
# Author: Your Name
# Date: 2024-01-15
# Usage: ./hello.sh

# Print script information
echo "=== Script Information ==="
echo "Script name: $0"
echo "Script location: $(pwd)"
echo ""

# Print greeting
echo "=== Greeting ==="
echo "Hello, Bash!"
echo "Welcome to shell scripting!"
echo ""

# Print timestamp
echo "=== Timestamp ==="
date
```

**Run:**
```bash
./hello.sh

# Expected output shows timestamp of execution
```

### Verification Checklist

- [ ] Script created and saved
- [ ] Syntax validated with `bash -n`
- [ ] Execute permission set
- [ ] Script runs with ./hello.sh
- [ ] Script runs with bash hello.sh
- [ ] Output displays correctly
- [ ] Comments are clear

### Cleanup

```bash
# Keep files for reference
ls -la hello.sh
```

---

## Lab 2: Working with Variables (45 minutes)

### Objective
Master variable declaration, expansion, and scope.

### Setup
```bash
mkdir -p ~/shell-labs/lab2
cd ~/shell-labs/lab2
```

### Step 1: Declare and Use Variables

**Create variables.sh:**
```bash
#!/bin/bash
# Variables demonstration

# Declare variables
name="Alice"
age=30
active=true

# Print variables
echo "Name: $name"
echo "Age: $age"
echo "Active: $active"
```

**Execute:**
```bash
bash variables.sh

# Expected output:
# Name: Alice
# Age: 30
# Active: true
```

### Step 2: Understand Variable Expansion

**Create expansion.sh:**
```bash
#!/bin/bash
# Variable expansion demonstration

message="Hello"

# Different ways to expand variables
echo "Simple: $message"
echo "With braces: ${message}"
echo "In string: ${message}, World!"

# Without quotes (risky)
file="my document.txt"
echo "With quotes: $file"        # Works
ls "$file" 2>/dev/null           # Works (file doesn't exist)
ls $file 2>/dev/null             # Would fail if file existed
```

**Execute:**
```bash
bash expansion.sh

# Expected output shows importance of quoting
```

### Step 3: Command Substitution

**Create substitution.sh:**
```bash
#!/bin/bash
# Command substitution - capture command output

echo "=== Using Command Substitution ==="

# Get current date
current_date=$(date +%Y-%m-%d)
echo "Today's date: $current_date"

# Count files in directory
file_count=$(ls -1 | wc -l)
echo "Files in this directory: $file_count"

# Get username
current_user=$(whoami)
echo "Current user: $current_user"

# Get system uptime
uptime_info=$(uptime -p)
echo "System uptime: $uptime_info"
```

**Execute:**
```bash
bash substitution.sh

# Expected output shows real system information
```

### Step 4: Default Values and Parameter Expansion

**Create defaults.sh:**
```bash
#!/bin/bash
# Parameter expansion with defaults

# Use default if variable is unset
username="${1:-anonymous}"
count="${2:-1}"

echo "Username: $username"
echo "Count: $count"

# Set if unset
database="${DB_NAME:-production_db}"
echo "Database: $database"

# Alternative value if set
message="${1:+Hello $1!}"
echo "Message: $message"
```

**Execute:**
```bash
# No arguments - uses defaults
bash defaults.sh

# Expected output:
# Username: anonymous
# Count: 1
# Database: production_db
# Message: 

# With arguments
bash defaults.sh "Bob" "5"

# Expected output:
# Username: Bob
# Count: 5
# Database: production_db
# Message: Hello Bob!
```

### Step 5: String Manipulation

**Create string_ops.sh:**
```bash
#!/bin/bash
# String operations

text="The Quick Brown Fox"

echo "Original: $text"
echo "Length: ${#text}"
echo "Lowercase: ${text,,}"
echo "UPPERCASE: ${text^^}"

# Substring
echo "First 3 chars: ${text:0:3}"
echo "From position 4: ${text:4}"

# Find and replace
echo "Replace 'Fox' with 'Dog': ${text/Fox/Dog}"
echo "Replace all 'o': ${text//o/O}"

# Remove pattern
echo "Remove 'Quick ': ${text/Quick /}"
```

**Execute:**
```bash
bash string_ops.sh

# Expected output shows all string manipulations
```

### Step 6: Arrays

**Create arrays.sh:**
```bash
#!/bin/bash
# Array operations

# Declare array
fruits=("apple" "banana" "cherry" "date")

echo "=== Array Operations ==="
echo "First fruit: ${fruits[0]}"
echo "Third fruit: ${fruits[2]}"
echo "All fruits: ${fruits[@]}"
echo "Number of fruits: ${#fruits[@]}"

# Loop through array
echo ""
echo "=== Loop Through Array ==="
for fruit in "${fruits[@]}"; do
    echo "- $fruit"
done

# Add to array
fruits+=("elderberry")
echo ""
echo "After adding: ${fruits[@]}"

# Associative array (key-value)
declare -A person
person[name]="Alice"
person[age]="30"
person[city]="Boston"

echo ""
echo "=== Associative Array ==="
echo "Name: ${person[name]}"
echo "Age: ${person[age]}"
echo "City: ${person[city]}"
```

**Execute:**
```bash
bash arrays.sh

# Expected output shows array operations
```

### Verification Checklist

- [ ] Variables declared and used correctly
- [ ] Variable expansion works with and without braces
- [ ] Command substitution captures output
- [ ] Default values work
- [ ] String manipulation functions work
- [ ] Arrays created and accessed
- [ ] Associative arrays work

### Cleanup

```bash
# Review what you learned
cat variables.sh
cat arrays.sh
```

---

## Lab 3: Control Flow - Conditionals (40 minutes)

### Objective
Master if/else statements and case expressions.

### Setup
```bash
mkdir -p ~/shell-labs/lab3
cd ~/shell-labs/lab3
```

### Step 1: Simple If/Else

**Create conditionals.sh:**
```bash
#!/bin/bash
# Conditional statements

age=25

echo "=== Simple If/Else ==="
if [[ $age -ge 18 ]]; then
    echo "You are an adult"
else
    echo "You are a minor"
fi

# File existence check
if [[ -f "/etc/passwd" ]]; then
    echo "/etc/passwd exists"
else
    echo "/etc/passwd not found"
fi
```

**Execute:**
```bash
bash conditionals.sh

# Expected output:
# === Simple If/Else ===
# You are an adult
# /etc/passwd exists
```

### Step 2: If/Elif/Else

**Create grade.sh:**
```bash
#!/bin/bash
# Grade assignment based on score

score="${1:-75}"

echo "Score: $score"
echo ""

if [[ $score -ge 90 ]]; then
    echo "Grade: A (Excellent)"
elif [[ $score -ge 80 ]]; then
    echo "Grade: B (Good)"
elif [[ $score -ge 70 ]]; then
    echo "Grade: C (Satisfactory)"
elif [[ $score -ge 60 ]]; then
    echo "Grade: D (Pass)"
else
    echo "Grade: F (Fail)"
fi
```

**Execute:**
```bash
bash grade.sh 85

# Expected output:
# Score: 85
# 
# Grade: B (Good)

# Try other values
bash grade.sh 45
# Grade: F (Fail)
```

### Step 3: Logical Operators

**Create logic.sh:**
```bash
#!/bin/bash
# Logical operators - AND, OR, NOT

age=25
license="valid"
car="available"

echo "=== AND Operator ==="
if [[ $age -ge 18 && $license == "valid" ]]; then
    echo "Can drive"
else
    echo "Cannot drive"
fi

echo ""
echo "=== OR Operator ==="
if [[ $license == "expired" || $license == "revoked" ]]; then
    echo "License problem"
else
    echo "License OK"
fi

echo ""
echo "=== NOT Operator ==="
if [[ ! -f "/root/.ssh/id_rsa" ]]; then
    echo "SSH key not found in /root"
else
    echo "SSH key found"
fi

echo ""
echo "=== Complex Condition ==="
if [[ $age -ge 18 && $license == "valid" && $car == "available" ]]; then
    echo "Ready for a road trip!"
else
    echo "Not ready"
fi
```

**Execute:**
```bash
bash logic.sh

# Expected output shows all logical operations
```

### Step 4: Case Statement

**Create status.sh:**
```bash
#!/bin/bash
# Case statement for multiple conditions

action="${1:-status}"

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
        echo "Service is running"
        ;;
    *)
        echo "Unknown action: $action"
        echo "Valid actions: start, stop, restart, status"
        exit 1
        ;;
esac
```

**Execute:**
```bash
bash status.sh start
# Starting service...

bash status.sh restart
# Restarting service...

bash status.sh invalid
# Unknown action: invalid
# Valid actions: start, stop, restart, status
```

### Step 5: File and Directory Tests

**Create filetest.sh:**
```bash
#!/bin/bash
# File and directory tests

target="${1:-.}"  # Default to current directory

echo "Testing: $target"
echo ""

if [[ -e "$target" ]]; then
    echo "✓ Exists"
else
    echo "✗ Does not exist"
    exit 1
fi

if [[ -f "$target" ]]; then
    echo "✓ Is a regular file"
    echo "  Size: $(stat -f%z "$target" 2>/dev/null || stat -c%s "$target") bytes"
elif [[ -d "$target" ]]; then
    echo "✓ Is a directory"
    echo "  Contents:"
    ls -la "$target" | head -5
fi

if [[ -r "$target" ]]; then
    echo "✓ Readable"
fi

if [[ -w "$target" ]]; then
    echo "✓ Writable"
fi

if [[ -x "$target" ]]; then
    echo "✓ Executable"
fi
```

**Execute:**
```bash
bash filetest.sh /etc/passwd

# Expected output shows file properties

bash filetest.sh /etc

# Shows directory properties
```

### Verification Checklist

- [ ] If/else statements work correctly
- [ ] If/elif/else chains work
- [ ] Logical operators (&&, ||, !) function
- [ ] Case statements handle multiple options
- [ ] File test operators work
- [ ] Error handling on invalid cases

### Cleanup

```bash
# Keep scripts for reference
ls -la *.sh
```

---

## Lab 4: Loops and Iteration (45 minutes)

### Objective
Master for, while, and until loops for iterating data.

### Setup
```bash
mkdir -p ~/shell-labs/lab4
cd ~/shell-labs/lab4
```

### Step 1: For Loop - Sequences

**Create forloop.sh:**
```bash
#!/bin/bash
# For loop demonstrations

echo "=== Count from 1 to 5 ==="
for i in {1..5}; do
    echo "Number: $i"
done

echo ""
echo "=== Countdown ==="
for i in {5..1}; do
    echo "$i..."
done
echo "Blast off!"

echo ""
echo "=== Even numbers 2-10 ==="
for i in {2..10..2}; do
    echo "$i"
done
```

**Execute:**
```bash
bash forloop.sh

# Expected output shows all iterations
```

### Step 2: For Loop - Arrays

**Create forarray.sh:**
```bash
#!/bin/bash
# Loop through arrays

colors=("red" "green" "blue" "yellow")

echo "=== Loop with for-in ==="
for color in "${colors[@]}"; do
    echo "Color: $color"
done

echo ""
echo "=== Loop with index ==="
for ((i=0; i<${#colors[@]}; i++)); do
    echo "$i: ${colors[$i]}"
done

echo ""
echo "=== Loop through files ==="
for file in *.sh; do
    if [[ -f "$file" ]]; then
        echo "Script: $file ($(wc -l < "$file") lines)"
    fi
done
```

**Execute:**
```bash
bash forarray.sh

# Expected output shows array iteration
```

### Step 3: While Loop - Interactive

**Create whileloop.sh:**
```bash
#!/bin/bash
# While loop example

count=1

echo "=== Simple While Loop ==="
while [[ $count -le 5 ]]; do
    echo "Iteration $count"
    (( count++ ))
done

echo ""
echo "=== While Reading File ==="
echo "Line 1" > test.txt
echo "Line 2" >> test.txt
echo "Line 3" >> test.txt

line_num=1
while IFS= read -r line; do
    echo "Line $line_num: $line"
    (( line_num++ ))
done < test.txt
```

**Execute:**
```bash
bash whileloop.sh

# Expected output shows while loops
```

### Step 4: Until Loop

**Create untilloop.sh:**
```bash
#!/bin/bash
# Until loop - opposite of while

count=1

echo "=== Until Loop ==="
until [[ $count -gt 5 ]]; do
    echo "Count: $count"
    (( count++ ))
done

echo ""
echo "=== Until File Exists ==="
# Simulate waiting (won't actually wait in lab)
target_file="/tmp/test_exists"
attempts=0

until [[ -f "$target_file" ]] || [[ $attempts -ge 3 ]]; do
    echo "Attempt $attempts: File not found yet"
    (( attempts++ ))
done

if [[ -f "$target_file" ]]; then
    echo "File found!"
else
    echo "File not found after 3 attempts"
fi
```

**Execute:**
```bash
bash untilloop.sh

# Expected output
```

### Step 5: Loop Control - Break and Continue

**Create loopcontrol.sh:**
```bash
#!/bin/bash
# Break and continue in loops

echo "=== Continue (skip odd numbers) ==="
for i in {1..10}; do
    if (( i % 2 != 0 )); then
        continue  # Skip odd numbers
    fi
    echo "$i"
done

echo ""
echo "=== Break (stop at 7) ==="
for i in {1..10}; do
    if (( i == 7 )); then
        break     # Stop loop
    fi
    echo "$i"
done

echo ""
echo "=== Menu with Loop Control ==="
while true; do
    echo "Menu:"
    echo "1) Continue"
    echo "2) Break"
    echo "3) Exit"
    read -p "Choose: " choice
    
    case $choice in
        1)
            echo "Continuing..."
            continue
            ;;
        2)
            echo "Breaking..."
            break
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            continue
            ;;
    esac
done
```

**Execute (automated):**
```bash
# Create test input
echo -e "3" | bash loopcontrol.sh

# Expected output shows first two parts, then exits
```

### Step 6: Nested Loops

**Create nested.sh:**
```bash
#!/bin/bash
# Nested loops - multiplication table

echo "=== Multiplication Table ==="
for i in {1..5}; do
    for j in {1..5}; do
        product=$(( i * j ))
        printf "%3d " "$product"
    done
    echo ""
done
```

**Execute:**
```bash
bash nested.sh

# Expected output:
#   1   2   3   4   5 
#   2   4   6   8  10 
#   3   6   9  12  15 
#   4   8  12  16  20 
#   5  10  15  20  25
```

### Verification Checklist

- [ ] For loops iterate correctly
- [ ] While loops work with conditions
- [ ] Until loops work (opposite of while)
- [ ] Continue skips iterations
- [ ] Break exits loops
- [ ] Nested loops work
- [ ] Loop arrays correctly

### Cleanup

```bash
# Clean up test file
rm -f test.txt
```

---

## Lab 5: Functions and Modularity (50 minutes)

### Objective
Write reusable functions with parameters and return values.

### Setup
```bash
mkdir -p ~/shell-labs/lab5
cd ~/shell-labs/lab5
```

### Step 1: Basic Functions

**Create functions.sh:**
```bash
#!/bin/bash
# Function demonstrations

# Function with no parameters
greet() {
    echo "Hello from a function!"
}

# Function with parameters
greet_user() {
    local name="$1"
    echo "Hello, $name!"
}

# Function with multiple parameters
add() {
    local a="$1"
    local b="$2"
    local sum=$(( a + b ))
    echo "Sum: $sum"
}

# Call functions
echo "=== Calling Functions ==="
greet
greet_user "Alice"
add 5 3
```

**Execute:**
```bash
bash functions.sh

# Expected output:
# === Calling Functions ===
# Hello from a function!
# Hello, Alice!
# Sum: 8
```

### Step 2: Return Values

**Create returns.sh:**
```bash
#!/bin/bash
# Function return values

# Return exit code (0=success, 1=failure)
is_even() {
    local num="$1"
    if (( num % 2 == 0 )); then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Return output (use echo)
get_greeting() {
    local name="$1"
    echo "Welcome, $name!"
}

# Check return code
echo "=== Checking Return Codes ==="
if is_even 4; then
    echo "4 is even"
else
    echo "4 is odd"
fi

if is_even 5; then
    echo "5 is even"
else
    echo "5 is odd"
fi

# Capture output
echo ""
echo "=== Capturing Output ==="
greeting=$(get_greeting "Bob")
echo "$greeting"

# Both return code and output
echo ""
echo "=== Both Return Code and Output ==="
safe_divide() {
    if [[ $2 -eq 0 ]]; then
        echo "Error: Division by zero"
        return 1
    fi
    echo "$(( $1 / $2 ))"
    return 0
}

if result=$(safe_divide 10 2); then
    echo "Result: $result"
else
    echo "Division failed"
fi
```

**Execute:**
```bash
bash returns.sh

# Expected output shows return codes and output capture
```

### Step 3: Function Parameters and Arrays

**Create params.sh:**
```bash
#!/bin/bash
# Function parameters

# Function with any number of parameters
print_args() {
    echo "Total arguments: $#"
    echo "All args: $@"
    
    for i in $(seq 1 $#); do
        echo "  Arg $i: ${!i}"
    done
}

# Using shift to process arguments
process_files() {
    echo "Processing files:"
    while [[ $# -gt 0 ]]; do
        echo "  - $1"
        shift
    done
}

# Array as parameter
sum_array() {
    local sum=0
    for num in "$@"; do
        sum=$(( sum + num ))
    done
    echo "$sum"
}

echo "=== Print Arguments ==="
print_args "one" "two" "three"

echo ""
echo "=== Process Files ==="
process_files "file1.txt" "file2.txt" "file3.txt"

echo ""
echo "=== Sum Array ==="
total=$(sum_array 5 10 15 20)
echo "Total: $total"
```

**Execute:**
```bash
bash params.sh

# Expected output shows parameter handling
```

### Step 4: Local Variables and Scope

**Create scope.sh:**
```bash
#!/bin/bash
# Variable scope demonstration

GLOBAL="I'm global"

modify_global() {
    GLOBAL="Modified globally"
    echo "Inside function: $GLOBAL"
}

use_local() {
    local local_var="I'm local"
    GLOBAL="Also modified"
    
    echo "Local var: $local_var"
    echo "Global var: $GLOBAL"
}

echo "=== Before Functions ==="
echo "Global: $GLOBAL"

echo ""
echo "=== Call modify_global ==="
modify_global

echo ""
echo "=== After modify_global ==="
echo "Global: $GLOBAL"

echo ""
echo "=== Call use_local ==="
use_local

echo ""
echo "=== After use_local ==="
echo "Global: $GLOBAL"
echo "Local (outside): $local_var (empty)"
```

**Execute:**
```bash
bash scope.sh

# Expected output demonstrates scope
```

### Step 5: Recursive Functions

**Create recursion.sh:**
```bash
#!/bin/bash
# Recursive functions

# Factorial using recursion
factorial() {
    local n="$1"
    if (( n <= 1 )); then
        echo 1
    else
        local prev=$(factorial $(( n - 1 )))
        echo $(( n * prev ))
    fi
}

# Countdown using recursion
countdown() {
    local n="$1"
    if (( n <= 0 )); then
        echo "Blastoff!"
    else
        echo "$n..."
        countdown $(( n - 1 ))
    fi
}

echo "=== Factorial ==="
echo "5! = $(factorial 5)"
echo "10! = $(factorial 10)"

echo ""
echo "=== Countdown ==="
countdown 3
```

**Execute:**
```bash
bash recursion.sh

# Expected output:
# === Factorial ===
# 5! = 120
# 10! = 3628800
# 
# === Countdown ===
# 3...
# 2...
# 1...
# Blastoff!
```

### Step 6: Documentation and Help

**Create documented.sh:**
```bash
#!/bin/bash
# Well-documented functions

# Show usage information
show_help() {
    cat << EOF
Usage: $0 [COMMAND] [ARGUMENTS]

Commands:
  add <num1> <num2>        Add two numbers
  multiply <num1> <num2>   Multiply two numbers
  help                     Show this help message

Examples:
  $0 add 5 3
  $0 multiply 4 6

EOF
}

# Add two numbers
# Parameters: $1 (first number), $2 (second number)
# Output: Sum of the two numbers
add() {
    if [[ $# -ne 2 ]]; then
        echo "Error: add requires 2 arguments"
        return 1
    fi
    echo $(( $1 + $2 ))
}

# Multiply two numbers
# Parameters: $1 (first number), $2 (second number)
# Output: Product of the two numbers
multiply() {
    if [[ $# -ne 2 ]]; then
        echo "Error: multiply requires 2 arguments"
        return 1
    fi
    echo $(( $1 * $2 ))
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        return 1
    fi
    
    case "$1" in
        add)
            add "$2" "$3"
            ;;
        multiply)
            multiply "$2" "$3"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            return 1
            ;;
    esac
}

main "$@"
```

**Execute:**
```bash
bash documented.sh add 5 3
# 8

bash documented.sh multiply 4 6
# 24

bash documented.sh help
# Shows help message
```

### Verification Checklist

- [ ] Functions defined and called
- [ ] Parameters passed to functions
- [ ] Return codes work
- [ ] Output captured from functions
- [ ] Local variables scoped correctly
- [ ] Global variables modified appropriately
- [ ] Documentation is clear

### Cleanup

```bash
# Scripts are ready for reference
ls -la *.sh
```

---

## Lab 6: Error Handling and Robustness (40 minutes)

### Objective
Write defensive scripts that handle errors gracefully.

### Setup
```bash
mkdir -p ~/shell-labs/lab6
cd ~/shell-labs/lab6
```

### Step 1: Exit Codes

**Create exitcodes.sh:**
```bash
#!/bin/bash
# Understanding exit codes

# Commands return exit codes
ls /etc/passwd
echo "Exit code: $?"         # 0 (success)

ls /nonexistent 2>/dev/null
echo "Exit code: $?"         # 2 (not found)

# Use exit codes in conditions
if grep -q "root" /etc/passwd; then
    echo "root user found"
    echo "Exit code: $?"      # 0
fi

if grep -q "nosuchuser" /etc/passwd; then
    echo "User found"
else
    echo "User not found"
    echo "Exit code: $?"      # 1 (not found)
fi
```

**Execute:**
```bash
bash exitcodes.sh

# Expected output shows exit codes
```

### Step 2: Set Options for Safety

**Create safescript.sh:**
```bash
#!/bin/bash
set -euo pipefail

# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Pipe fails if any command fails

echo "Script with safety options"

# This would cause exit if -e is set
# ls /nonexistent

# This would cause exit if -u is set
# echo "$undefined_variable"

# Show that we're still running
echo "Script completed successfully"
```

**Execute:**
```bash
bash safescript.sh

# Expected output shows normal execution
```

### Step 3: Input Validation

**Create validate.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Validate argument count
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"

# Validate file exists
if [[ ! -f "$filename" ]]; then
    echo "Error: File not found: $filename"
    exit 1
fi

# Validate file is readable
if [[ ! -r "$filename" ]]; then
    echo "Error: File not readable: $filename"
    exit 1
fi

# Validate file is not empty
if [[ ! -s "$filename" ]]; then
    echo "Error: File is empty: $filename"
    exit 1
fi

# File is valid
echo "File is valid: $filename"
wc -l "$filename"
```

**Execute:**
```bash
# Create test file
echo "test content" > testfile.txt

# Run validation
bash validate.sh testfile.txt

# Test with missing file
bash validate.sh nonexistent.txt
# Error: File not found: nonexistent.txt
```

### Step 4: Trap for Cleanup

**Create cleanup.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Create temporary directory
temp_dir=$(mktemp -d)
echo "Temp directory: $temp_dir"

# Define cleanup function
cleanup() {
    local status=$?
    echo "Cleaning up..."
    rm -rf "$temp_dir"
    exit $status
}

# Set trap to run cleanup on exit
trap cleanup EXIT

# Create some temporary files
touch "$temp_dir/file1.txt"
touch "$temp_dir/file2.txt"
echo "Created files in $temp_dir"

# List files
ls -la "$temp_dir"

echo "Script completed"
# cleanup() will run automatically on exit
```

**Execute:**
```bash
bash cleanup.sh

# Expected output shows temp dir creation and cleanup
```

### Step 5: Error Messages

**Create errors.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Function to display error
error() {
    echo "ERROR: $*" >&2  # Output to stderr
    exit 1
}

# Function to display warning
warn() {
    echo "WARNING: $*" >&2
}

# Function to display info
info() {
    echo "INFO: $*"
}

# Usage
info "Starting script"

if [[ ! -d "/home" ]]; then
    error "/home directory not found"
fi

info "Found /home directory"

if [[ ! -f "/etc/hostname" ]]; then
    warn "No /etc/hostname found"
fi

info "Script completed"
```

**Execute:**
```bash
bash errors.sh

# Expected output shows info messages
```

### Step 6: Defensive Script Example

**Create backup.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Configuration
SOURCE="${1:-.}"
BACKUP_DIR="${2:-.backup}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

# Error handling
error() {
    echo "ERROR: $*" >&2
    exit 1
}

info() {
    echo "INFO: $*"
}

# Validate source
if [[ ! -d "$SOURCE" ]]; then
    error "Source directory not found: $SOURCE"
fi

info "Source: $SOURCE"
info "Backup dir: $BACKUP_DIR"

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Create backup
if tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")" 2>/dev/null; then
    info "Backup created: $BACKUP_FILE"
    ls -lh "$BACKUP_FILE"
else
    error "Backup failed"
fi
```

**Execute:**
```bash
mkdir -p /tmp/test_source
echo "test file" > /tmp/test_source/file.txt

bash backup.sh /tmp/test_source /tmp/test_backup

# Expected output shows backup creation
ls -lh /tmp/test_backup/
```

### Verification Checklist

- [ ] Exit codes understood and checked
- [ ] Safety options (set -euo) implemented
- [ ] Input validation working
- [ ] Cleanup function created with trap
- [ ] Error messages sent to stderr
- [ ] Script handles errors gracefully
- [ ] Defensive script example works

### Cleanup

```bash
# Clean up test files
rm -f testfile.txt
rm -rf /tmp/test_source /tmp/test_backup
```

---

## Lab 7: Reading and Processing Data (45 minutes)

### Objective
Master reading user input and file processing.

### Setup
```bash
mkdir -p ~/shell-labs/lab7
cd ~/shell-labs/lab7
```

### Step 1: Reading User Input

**Create interactive.sh:**
```bash
#!/bin/bash
# Interactive input

echo "=== Simple Read ==="
read -p "Enter your name: " name
echo "Hello, $name!"

echo ""
echo "=== Read with Default ==="
read -p "Enter color [blue]: " color
color="${color:-blue}"
echo "You chose: $color"

echo ""
echo "=== Silent Input (password) ==="
read -sp "Enter password: " password
echo ""  # New line after password
echo "Password length: ${#password}"

echo ""
echo "=== Read Multiple Values ==="
read -p "Enter first and last name: " first last
echo "First: $first"
echo "Last: $last"
```

**Execute (automated):**
```bash
# Provide input through pipe
(echo "Alice"; echo ""; echo "secret"; echo "John Doe") | bash interactive.sh

# Or run interactively
bash interactive.sh  # Type values manually
```

### Step 2: Reading Files

**Create fileread.sh:**
```bash
#!/bin/bash
# Reading files line by line

# Create test file
cat > data.txt << 'EOF'
apple
banana
cherry
date
elderberry
EOF

echo "=== Read with While Loop ==="
count=0
while IFS= read -r line; do
    (( count++ ))
    echo "$count: $line"
done < data.txt

echo ""
echo "=== Read into Array ==="
mapfile -t fruits < data.txt
echo "Total items: ${#fruits[@]}"
for fruit in "${fruits[@]}"; do
    echo "- $fruit"
done
```

**Execute:**
```bash
bash fileread.sh

# Expected output shows file contents
```

### Step 3: Processing Command Output

**Create cmdoutput.sh:**
```bash
#!/bin/bash
# Process output from commands

echo "=== Process List Command ==="
ps aux | grep bash | while read -r line; do
    if [[ ! $line =~ grep ]]; then
        echo "Process: $line"
    fi
done

echo ""
echo "=== Parse Disk Usage ==="
df -h | tail -n +2 | while read -r line; do
    filesystem=$(echo "$line" | awk '{print $1}')
    usage=$(echo "$line" | awk '{print $5}')
    echo "$filesystem: $usage"
done

echo ""
echo "=== Count Users ==="
count=$(wc -l < /etc/passwd)
echo "Total users: $count"
```

**Execute:**
```bash
bash cmdoutput.sh

# Expected output shows processed command data
```

### Step 4: Text Parsing

**Create parsing.sh:**
```bash
#!/bin/bash
# Parsing structured data

# Create CSV file
cat > users.csv << 'EOF'
name,age,city
alice,30,boston
bob,25,newyork
charlie,35,chicago
EOF

echo "=== Parse CSV ==="
while IFS=',' read -r name age city; do
    if [[ "$name" != "name" ]]; then  # Skip header
        printf "%-10s %3d %10s\n" "$name" "$age" "$city"
    fi
done < users.csv

echo ""
echo "=== Parse Passwd File ==="
head -3 /etc/passwd | while IFS=: read -r user passwd uid gid rest; do
    echo "User: $user (UID: $uid)"
done
```

**Execute:**
```bash
bash parsing.sh

# Expected output shows parsed data
```

### Step 5: Data Transformation

**Create transform.sh:**
```bash
#!/bin/bash
# Transform data

# Create input data
cat > numbers.txt << 'EOF'
10
20
30
40
50
EOF

echo "=== Sum Numbers ==="
sum=0
while read -r num; do
    sum=$(( sum + num ))
done < numbers.txt
echo "Sum: $sum"

echo ""
echo "=== Count and Average ==="
count=0
sum=0
while read -r num; do
    sum=$(( sum + num ))
    (( count++ ))
done < numbers.txt
average=$(( sum / count ))
echo "Count: $count"
echo "Sum: $sum"
echo "Average: $average"

echo ""
echo "=== Find Max ==="
max=0
while read -r num; do
    if (( num > max )); then
        max=$num
    fi
done < numbers.txt
echo "Maximum: $max"
```

**Execute:**
```bash
bash transform.sh

# Expected output shows calculations
```

### Verification Checklist

- [ ] User input read correctly
- [ ] File read line by line
- [ ] Command output processed
- [ ] Structured data parsed
- [ ] Data transformed and calculated
- [ ] Edge cases handled

### Cleanup

```bash
# Remove test files
rm -f data.txt users.csv numbers.txt
```

---

## Lab 8: Real-World Script - System Monitor (60 minutes)

### Objective
Combine all concepts into a practical system monitoring script.

### Setup
```bash
mkdir -p ~/shell-labs/lab8
cd ~/shell-labs/lab8
```

### Step 1: Create Monitoring Script

**Create sysmonitor.sh:**
```bash
#!/bin/bash
# System monitoring script
# Purpose: Display system health information
# Usage: ./sysmonitor.sh [--detailed] [--output FILE]

set -euo pipefail

# Configuration
SCRIPT_NAME="$(basename "$0")"
DETAILED=0
OUTPUT_FILE=""

# Functions
show_help() {
    cat << EOF
$SCRIPT_NAME - System Monitor

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -d, --detailed    Show detailed information
  -o, --output FILE Save output to file
  -h, --help        Show this help

Example:
  $SCRIPT_NAME --detailed --output report.txt

EOF
}

# Display header
show_header() {
    echo "╔══════════════════════════════════════════════╗"
    echo "║        SYSTEM HEALTH MONITOR                 ║"
    echo "╠══════════════════════════════════════════════╣"
    echo "║ Generated: $(date '+%Y-%m-%d %H:%M:%S')          ║"
    echo "║ Hostname:  $(hostname | cut -c1-35)            ║"
    echo "╚══════════════════════════════════════════════╝"
}

# CPU Information
show_cpu_info() {
    echo ""
    echo "=== CPU Information ==="
    if [[ -f /proc/cpuinfo ]]; then
        cores=$(grep -c "processor" /proc/cpuinfo)
        echo "CPU Cores: $cores"
    fi
    
    load=$(uptime | grep -oP '(?:load average: ).*' || echo "N/A")
    echo "Load Average: $load"
}

# Memory Information
show_memory_info() {
    echo ""
    echo "=== Memory Information ==="
    
    if [[ -f /proc/meminfo ]]; then
        total_kb=$(grep "^MemTotal" /proc/meminfo | awk '{print $2}')
        avail_kb=$(grep "^MemAvailable" /proc/meminfo | awk '{print $2}')
        used_kb=$(( total_kb - avail_kb ))
        
        total_mb=$(( total_kb / 1024 ))
        used_mb=$(( used_kb / 1024 ))
        avail_mb=$(( avail_kb / 1024 ))
        
        percent=$(( (used_mb * 100) / total_mb ))
        
        echo "Total:     ${total_mb}MB"
        echo "Used:      ${used_mb}MB"
        echo "Available: ${avail_mb}MB"
        echo "Usage:     ${percent}%"
    fi
}

# Disk Information
show_disk_info() {
    echo ""
    echo "=== Disk Information ==="
    
    df -h | tail -n +2 | while read -r line; do
        filesystem=$(echo "$line" | awk '{print $1}')
        usage=$(echo "$line" | awk '{print $5}')
        mounted=$(echo "$line" | awk '{print $6}')
        
        usage_percent=$(echo "$usage" | sed 's/%//')
        
        if (( usage_percent >= 80 )); then
            status="⚠ WARNING"
        else
            status="OK"
        fi
        
        printf "%-20s %5s %s\n" "$filesystem" "$usage" "$status"
    done
}

# Process Information
show_process_info() {
    echo ""
    echo "=== Top Processes (by memory) ==="
    
    ps aux --sort=-%mem | head -6 | tail -5 | while read -r line; do
        user=$(echo "$line" | awk '{print $1}')
        pid=$(echo "$line" | awk '{print $2}')
        mem=$(echo "$line" | awk '{print $4}')
        cmd=$(echo "$line" | awk '{print $11}')
        
        printf "PID %-6s %5s%% %s\n" "$pid" "$mem" "$cmd"
    done
}

# System Uptime
show_uptime_info() {
    echo ""
    echo "=== System Uptime ==="
    uptime_info=$(uptime -p 2>/dev/null || uptime)
    echo "$uptime_info"
}

# Services Status
show_services_info() {
    echo ""
    echo "=== Critical Services ==="
    
    services=("ssh" "cron" "network")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "✓ $service: Running"
        else
            echo "✗ $service: Stopped"
        fi
    done
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--detailed)
                DETAILED=1
                shift
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Collect output
    {
        show_header
        show_uptime_info
        show_cpu_info
        show_memory_info
        show_disk_info
        show_process_info
        
        if [[ $DETAILED -eq 1 ]]; then
            show_services_info
        fi
        
        echo ""
    } > "${OUTPUT_FILE:-.}" && {
        if [[ -z "$OUTPUT_FILE" ]]; then
            cat  # Output to stdout
        else
            echo "Report saved to: $OUTPUT_FILE"
        fi
    }
}

main "$@"
```

**Make executable:**
```bash
chmod +x sysmonitor.sh
```

### Step 2: Test the Script

**Execute basic:**
```bash
./sysmonitor.sh

# Expected output shows system health
```

**Execute detailed:**
```bash
./sysmonitor.sh --detailed

# Shows more information
```

**Save to file:**
```bash
./sysmonitor.sh --detailed --output report.txt
cat report.txt
```

### Step 3: Create Log Monitor Script

**Create logmonitor.sh:**
```bash
#!/bin/bash
# Log file monitor - track system events
# Usage: ./logmonitor.sh [--pattern PATTERN] [--lines 10]

set -euo pipefail

PATTERN="${1:-error}"
LINES="${2:-10}"
LOG_FILE="/var/log/syslog"

# Check if log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file not found: $LOG_FILE"
    exit 1
fi

# Check if readable
if [[ ! -r "$LOG_FILE" ]]; then
    echo "Error: Cannot read log file (try sudo)"
    exit 1
fi

echo "=== Recent log entries matching: $PATTERN ==="
echo ""

# Search and display log entries
grep -i "$PATTERN" "$LOG_FILE" | tail -n "$LINES" || true

echo ""
echo "Total matching entries: $(grep -ci "$PATTERN" "$LOG_FILE" || echo "0")"
```

**Make executable and test:**
```bash
chmod +x logmonitor.sh

# Try with sudo
sudo ./logmonitor.sh "error" 5

# Or without sudo (may have fewer results)
./logmonitor.sh "error" 5
```

### Verification Checklist

- [ ] sysmonitor.sh displays CPU info
- [ ] Memory information is correct
- [ ] Disk usage shown accurately
- [ ] Top processes listed
- [ ] Command line options work
- [ ] Output can be saved to file
- [ ] logmonitor.sh reads log files
- [ ] Log pattern matching works

### Cleanup

```bash
# Keep scripts for reference
rm -f report.txt
```

---

## Lab 9: Configuration Management (50 minutes)

### Objective
Parse and manage configuration files with scripts.

### Setup
```bash
mkdir -p ~/shell-labs/lab9
cd ~/shell-labs/lab9
```

### Step 1: Create Config Parser

**Create confparse.sh:**
```bash
#!/bin/bash
# Configuration file parser and validator

# Create sample config file
cat > app.conf << 'EOF'
# Application Configuration
# Lines starting with # are comments

server_host=localhost
server_port=8080
database_name=myapp
database_user=admin
database_pass=secret123
debug_mode=false
max_connections=100

# Cache settings
cache_enabled=true
cache_ttl=3600
EOF

echo "=== Configuration File ==="
cat app.conf
echo ""

# Function to parse config
parse_config() {
    local config_file="$1"
    local var_name="$2"
    
    # Find variable and get value
    grep "^${var_name}=" "$config_file" | cut -d'=' -f2
}

# Function to load all variables
load_config() {
    local config_file="$1"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        
        # Set variable dynamically
        eval "CONFIG_${key}='$value'"
    done < "$config_file"
}

echo "=== Parse Individual Values ==="
host=$(parse_config "app.conf" "server_host")
port=$(parse_config "app.conf" "server_port")

echo "Server Host: $host"
echo "Server Port: $port"

echo ""
echo "=== Load All Config Values ==="
load_config "app.conf"

# Access loaded values
echo "Database: $CONFIG_database_name"
echo "User: $CONFIG_database_user"
echo "Debug: $CONFIG_debug_mode"
```

**Execute:**
```bash
bash confparse.sh

# Expected output shows config parsing
```

### Step 2: Configuration Validator

**Create confvalidate.sh:**
```bash
#!/bin/bash
# Configuration validator

# Create config with issues
cat > server.conf << 'EOF'
port=8080
host=localhost
timeout=30
max_retries=3
ssl_enabled=true
EOF

validate_config() {
    local config_file="$1"
    local valid=true
    
    echo "Validating: $config_file"
    echo ""
    
    # Check required keys
    required_keys=("port" "host" "timeout")
    
    for key in "${required_keys[@]}"; do
        if grep -q "^${key}=" "$config_file"; then
            value=$(grep "^${key}=" "$config_file" | cut -d'=' -f2)
            echo "✓ $key: $value"
        else
            echo "✗ $key: MISSING"
            valid=false
        fi
    done
    
    echo ""
    if [[ "$valid" == true ]]; then
        echo "✓ Configuration is valid"
        return 0
    else
        echo "✗ Configuration has errors"
        return 1
    fi
}

# Run validation
validate_config "server.conf"

echo ""
echo "=== Check for Invalid Values ==="

# Validate port is numeric
port=$(grep "^port=" server.conf | cut -d'=' -f2)
if [[ $port =~ ^[0-9]+$ ]]; then
    echo "✓ Port is numeric: $port"
else
    echo "✗ Port is invalid: $port"
fi

# Validate boolean
ssl=$(grep "^ssl_enabled=" server.conf | cut -d'=' -f2)
if [[ "$ssl" =~ ^(true|false)$ ]]; then
    echo "✓ SSL setting is valid: $ssl"
else
    echo "✗ SSL setting invalid: $ssl"
fi
```

**Execute:**
```bash
bash confvalidate.sh

# Expected output shows validation
```

### Step 3: Create Config Generator

**Create confgen.sh:**
```bash
#!/bin/bash
# Generate configuration template

generate_config() {
    local app_name="$1"
    local config_file="${app_name}.conf"
    
    cat > "$config_file" << EOF
# Configuration for $app_name
# Generated: $(date)

# Server Settings
server_host=localhost
server_port=8080
server_timeout=30

# Database Settings
db_host=localhost
db_port=5432
db_name=${app_name}_db
db_user=${app_name}_user

# Application Settings
log_level=INFO
debug_mode=false
max_connections=50

# Cache Settings
cache_enabled=true
cache_ttl=3600

EOF
    
    echo "Configuration template created: $config_file"
}

# Generate configs for different apps
generate_config "webserver"
generate_config "api"

echo ""
echo "=== Generated Files ==="
ls -la *.conf
```

**Execute:**
```bash
bash confgen.sh

# Check generated configs
cat webserver.conf
```

### Verification Checklist

- [ ] Config file parsed correctly
- [ ] Individual values extracted
- [ ] All values loaded into variables
- [ ] Validation detects missing keys
- [ ] Type validation works
- [ ] Config template generated

### Cleanup

```bash
# Remove generated config files
rm -f app.conf server.conf webserver.conf api.conf
```

---

## Lab 10: Practical Application - Backup Utility (60 minutes)

### Objective
Build a complete backup automation script combining all concepts.

### Setup
```bash
mkdir -p ~/shell-labs/lab10
cd ~/shell-labs/lab10
mkdir -p {source,backups,logs}
```

### Step 1: Create Backup Script

**Create backup-utility.sh:**
```bash
#!/bin/bash
# Backup Utility - Automated backup with rotation
# Purpose: Back up directories with automatic cleanup
# Usage: ./backup-utility.sh --source /path/to/backup --retention 7

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE_DIR="$SCRIPT_DIR/backups"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/backup-$(date +%Y%m%d).log"

SOURCE_DIR=""
RETENTION_DAYS=7
DRY_RUN=0

# Functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR" "$@"
    exit 1
}

info() {
    log "INFO" "$@"
}

show_help() {
    cat << EOF
Backup Utility

Usage: $0 [OPTIONS]

Options:
  --source DIR         Directory to backup
  --retention DAYS     Keep backups for N days (default: 7)
  --dry-run            Show what would be backed up
  --help               Show this help

Examples:
  $0 --source /home/user --retention 14
  $0 --source ./source --dry-run

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source)
                SOURCE_DIR="$2"
                shift 2
                ;;
            --retention)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# Validate source
validate_source() {
    if [[ -z "$SOURCE_DIR" ]]; then
        error "No source directory specified (use --source)"
    fi
    
    if [[ ! -d "$SOURCE_DIR" ]]; then
        error "Source directory not found: $SOURCE_DIR"
    fi
    
    info "Source: $SOURCE_DIR"
}

# Create backup
create_backup() {
    local source="$1"
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    local backup_dir="$BACKUP_BASE_DIR/$backup_name"
    local backup_file="$backup_dir/data.tar.gz"
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    info "Creating backup: $backup_name"
    
    if [[ $DRY_RUN -eq 1 ]]; then
        info "[DRY-RUN] Would create: $backup_file"
        info "[DRY-RUN] Would compress: $source"
        return 0
    fi
    
    # Create tar.gz backup
    if tar -czf "$backup_file" -C "$(dirname "$source")" "$(basename "$source")" 2>/dev/null; then
        local size=$(du -h "$backup_file" | cut -f1)
        info "Backup created successfully: $size"
        echo "$backup_file" > "$backup_dir/metadata.txt"
        echo "Created: $(date)" >> "$backup_dir/metadata.txt"
        return 0
    else
        error "Backup creation failed"
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    local cutoff_time=$(date -d "$RETENTION_DAYS days ago" +%s 2>/dev/null || date -v-${RETENTION_DAYS}d +%s)
    
    info "Cleaning up backups older than $RETENTION_DAYS days"
    
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        return 0
    fi
    
    for backup_dir in "$BACKUP_BASE_DIR"/backup-*; do
        if [[ ! -d "$backup_dir" ]]; then
            continue
        fi
        
        dir_time=$(stat -c %Y "$backup_dir" 2>/dev/null || stat -f %m "$backup_dir")
        
        if (( dir_time < cutoff_time )); then
            if [[ $DRY_RUN -eq 1 ]]; then
                info "[DRY-RUN] Would remove: $(basename $backup_dir)"
            else
                info "Removing old backup: $(basename $backup_dir)"
                rm -rf "$backup_dir"
            fi
        fi
    done
}

# Show backup status
show_status() {
    info "=== Backup Status ==="
    
    if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
        info "No backups created yet"
        return 0
    fi
    
    local total_size=$(du -sh "$BACKUP_BASE_DIR" | cut -f1)
    info "Total backup size: $total_size"
    
    info "Recent backups:"
    ls -lhd "$BACKUP_BASE_DIR"/backup-* 2>/dev/null | tail -5 | while read -r line; do
        info "  $line"
    done || info "  (none)"
}

# Main
main() {
    parse_args "$@"
    
    # Create directories
    mkdir -p "$BACKUP_BASE_DIR" "$LOG_DIR"
    
    info "=========================================="
    info "Backup Utility Started"
    info "=========================================="
    
    validate_source
    create_backup "$SOURCE_DIR"
    cleanup_old_backups
    show_status
    
    info "Backup process completed"
}

main "$@"
```

**Make executable:**
```bash
chmod +x backup-utility.sh
```

### Step 2: Test Backup Script

**Create test source:**
```bash
# Create files to backup
mkdir -p source/data
echo "Important data" > source/data/file1.txt
echo "More data" > source/data/file2.txt
echo "Config file" > source/config.conf
```

**Run backup:**
```bash
# Dry run first
./backup-utility.sh --source ./source --dry-run

# Actual backup
./backup-utility.sh --source ./source --retention 7

# Check created backups
ls -la backups/
```

### Step 3: Verify and Restore

**Create restore script (optional):**
```bash
#!/bin/bash
# Simple restore script

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <backup_dir>"
    exit 1
fi

backup_dir="$1"

if [[ ! -f "$backup_dir/data.tar.gz" ]]; then
    echo "Error: No backup file found"
    exit 1
fi

restore_dir="restored-$(date +%s)"
mkdir -p "$restore_dir"

tar -xzf "$backup_dir/data.tar.gz" -C "$restore_dir"

echo "Backup restored to: $restore_dir"
ls -la "$restore_dir"
```

**Use restore script:**
```bash
chmod +x restore.sh

# Find latest backup
latest_backup=$(ls -td backups/backup-* | head -1)

# Restore
./restore.sh "$latest_backup"

# Verify
ls -la restored-*
```

### Verification Checklist

- [ ] Backup script creates tar.gz files
- [ ] Backups stored in correct directory
- [ ] Metadata file created
- [ ] Dry-run mode works
- [ ] Old backups cleaned up
- [ ] Backup status displayed
- [ ] Restore works correctly
- [ ] Log file created

### Cleanup

```bash
# Optional: remove lab files
# rm -rf source backups logs *.sh
```

---

## Summary

**10 Labs Completed:**

1. ✓ Basic script structure and execution
2. ✓ Variables and data types
3. ✓ Conditionals and control flow
4. ✓ Loops and iteration
5. ✓ Functions and modularity
6. ✓ Error handling and robustness
7. ✓ Reading and processing data
8. ✓ System monitoring (real-world)
9. ✓ Configuration management
10. ✓ Backup utility (complete application)

**Skills Mastered:**

- Script structure and best practices
- Variables, arrays, and operators
- Control flow (if/case/loops)
- Functions with parameters and returns
- Error handling and validation
- File and user input processing
- Real-world automation patterns

---

**Next:** [scripts/](scripts/) - Production-ready script examples
