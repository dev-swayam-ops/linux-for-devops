# Shell Scripting Basics - Commands Cheatsheet

Quick reference for bash syntax and common patterns.

---

## 1. Script Execution

### Running Scripts

```bash
# Method 1: Direct execution (requires execute permission)
chmod +x script.sh
./script.sh

# Method 2: Using bash (no execute permission needed)
bash script.sh

# Method 3: Using sh (POSIX shell)
sh script.sh

# Pass arguments
./script.sh arg1 arg2 arg3
bash script.sh --option value

# Run in background
./script.sh &
bash script.sh > output.log 2>&1 &

# Run with debugging
bash -x script.sh  # Show each command executed
bash -n script.sh  # Check syntax without running
```

### Script Structure Template

```bash
#!/bin/bash
# Shebang (must be first line)

set -euo pipefail
# Set options for safety

# Global variables and constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"

# Function definitions
show_help() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
}

cleanup() {
    # Cleanup code
    true
}

trap cleanup EXIT

# Main function
main() {
    # Main logic
    true
}

# Run main function with all arguments
main "$@"
```

---

## 2. Variables and Assignment

### Basic Variables

```bash
# Assignment (no spaces around =)
name="Alice"
age=30
active=true
array=(1 2 3)

# Using variables
echo "$name"           # Expansion
echo "${name}"         # Expansion with braces
echo "${name}Smith"    # Avoid ambiguity

# Variable expansion variants
${var}                 # Basic
${var:-default}        # Use default if unset
${var:=default}        # Set and use default if unset
${var:+alternate}      # Use alternate if set
${var:?error message}  # Error if unset

# String operations
${var:0:5}            # Substring (first 5 chars)
${var:5}              # From position 5 onward
${#var}               # Length of string
${var//old/new}       # Replace all old with new
${var/old/new}        # Replace first occurrence
${var#pattern}        # Remove prefix matching pattern
${var%pattern}        # Remove suffix matching pattern
```

### Variable Declaration

```bash
# Declare variable type
declare -i count=0       # Integer
declare -a array=()      # Indexed array
declare -A hash=()       # Associative array
declare -r CONSTANT="x"  # Read-only (constant)
declare -x VAR="x"       # Export (environment variable)

# Unset variable
unset variable_name

# Check if variable is set
[[ -v variable_name ]]   # True if set
[[ -z "$var" ]]          # True if empty
[[ -n "$var" ]]          # True if non-empty
```

### Special Variables

```bash
# Positional parameters
$0                  # Script name
$1, $2, $3, ...     # Arguments
$@                  # All arguments (as separate words)
$*                  # All arguments (as single string)
$#                  # Number of arguments
${@:2}              # All arguments from 2 onward
${@:1:3}            # Arguments 1-3

# Process information
$$                  # Current process ID
$?                  # Exit code of last command
$!                  # PID of last background job
$-                  # Current shell options

# Environment
$HOME, $USER, $PWD, $PATH, $SHELL, $HOSTNAME
$RANDOM             # Random number 0-32767
$SECONDS            # Seconds since script started
```

### Arrays

```bash
# Indexed array
fruits=("apple" "banana" "cherry")
fruits[0]="apple"
fruits[1]="banana"
fruits+=("date")             # Append

# Access elements
echo "${fruits[0]}"          # apple
echo "${fruits[@]}"          # all elements
echo "${fruits[*]}"          # all as single string
echo "${#fruits[@]}"         # length

# Iterate
for fruit in "${fruits[@]}"; do
    echo "$fruit"
done

# Associative array (key-value)
declare -A config
config[host]="localhost"
config[port]="8080"
config[debug]="true"

echo "${config[host]}"       # localhost
echo "${!config[@]}"         # all keys

# Iterate over keys
for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done
```

---

## 3. Operators and Arithmetic

### Arithmetic Operations

```bash
# Arithmetic expansion
result=$(( 5 + 3 ))          # 8
result=$(( 10 - 4 ))         # 6
result=$(( 3 * 4 ))          # 12
result=$(( 15 / 3 ))         # 5
result=$(( 17 % 5 ))         # 2 (modulo)
result=$(( 2 ** 3 ))         # 8 (exponent)

# Compound assignment
(( a = 5 ))
(( a += 3 ))                 # a = 8
(( a -= 2 ))                 # a = 6
(( a *= 2 ))                 # a = 12
(( a /= 3 ))                 # a = 4
(( a %= 3 ))                 # a = 1

# Increment/decrement
(( ++a ))                    # Pre-increment
(( a++ ))                    # Post-increment
(( --a ))                    # Pre-decrement
(( a-- ))                    # Post-decrement
```

### Comparison Operators

**Numeric (inside [[ ]] or (( )))**
```bash
[[ 5 -eq 5 ]]   # Equal
[[ 5 -ne 3 ]]   # Not equal
[[ 5 -gt 3 ]]   # Greater than
[[ 3 -lt 5 ]]   # Less than
[[ 5 -ge 5 ]]   # Greater or equal
[[ 3 -le 5 ]]   # Less or equal

# Inside (( )) - can use C-style operators
(( 5 == 5 ))
(( 5 != 3 ))
(( 5 > 3 ))
(( 3 < 5 ))
```

**String Comparison**
```bash
[[ "abc" == "abc" ]]   # Equal
[[ "abc" != "def" ]]   # Not equal
[[ "abc" < "def" ]]    # Lexicographic compare
[[ -z "str" ]]         # Empty string
[[ -n "str" ]]         # Non-empty string
[[ "abc" == a* ]]      # Glob pattern match
[[ "abc" =~ ^a.*c$ ]]  # Regex match
```

### Logical Operators

```bash
# AND (&&)
[[ $a -gt 5 && $b -lt 10 ]] || true

# OR (||)
[[ $a -eq 0 || $b -eq 0 ]] || true

# NOT (!)
[[ ! -f "$file" ]] || true

# Within conditions
if [[ $a -gt 5 && $b -lt 10 ]]; then
    echo "Both conditions true"
fi

if [[ $status == "active" || $status == "pending" ]]; then
    echo "Status is active or pending"
fi
```

### File Tests

```bash
# File existence and type
[[ -e "$file" ]]    # Exists
[[ -f "$file" ]]    # Regular file
[[ -d "$dir" ]]     # Directory
[[ -L "$link" ]]    # Symbolic link
[[ -b "$file" ]]    # Block device
[[ -c "$file" ]]    # Character device
[[ -p "$file" ]]    # Named pipe
[[ -S "$file" ]]    # Socket

# File permissions
[[ -r "$file" ]]    # Readable
[[ -w "$file" ]]    # Writable
[[ -x "$file" ]]    # Executable
[[ -u "$file" ]]    # SUID bit set
[[ -g "$file" ]]    # SGID bit set
[[ -k "$file" ]]    # Sticky bit set

# File properties
[[ -s "$file" ]]    # File exists and not empty
[[ -t 1 ]]          # File descriptor 1 (stdout) is a terminal

# File comparison
[[ "$f1" -nt "$f2" ]]   # f1 newer than f2
[[ "$f1" -ot "$f2" ]]   # f1 older than f2
[[ "$f1" -ef "$f2" ]]   # f1 and f2 are same file (hardlink)
```

---

## 4. Control Flow - Conditionals

### If/Elif/Else

```bash
# Simple if
if [[ $age -ge 18 ]]; then
    echo "Adult"
fi

# If-else
if [[ $status == "active" ]]; then
    echo "Running"
else
    echo "Stopped"
fi

# If-elif-else
if [[ $score -ge 90 ]]; then
    echo "A"
elif [[ $score -ge 80 ]]; then
    echo "B"
elif [[ $score -ge 70 ]]; then
    echo "C"
else
    echo "F"
fi

# One-liner
[[ $age -ge 18 ]] && echo "Adult" || echo "Minor"

# Nested if
if [[ $age -ge 18 ]]; then
    if [[ $license == "valid" ]]; then
        echo "Can drive"
    fi
fi
```

### Case Statements

```bash
# Case statement
case "$action" in
    start)
        echo "Starting..."
        ;;
    stop)
        echo "Stopping..."
        ;;
    restart)
        echo "Restarting..."
        ;;
    status)
        echo "Checking status..."
        ;;
    *)
        echo "Unknown action: $action"
        exit 1
        ;;
esac

# Pattern matching with |
case "$filename" in
    *.txt)
        echo "Text file"
        ;;
    *.jpg|*.png|*.gif)
        echo "Image file"
        ;;
    *.pdf)
        echo "PDF document"
        ;;
    *)
        echo "Unknown type"
        ;;
esac

# Case with regex
case "$input" in
    [yY][eE][sS]|[yY])
        echo "Yes"
        ;;
    [nN][oO]|[nN])
        echo "No"
        ;;
esac
```

---

## 5. Loops

### For Loop

```bash
# For loop over values
for item in apple banana cherry; do
    echo "Fruit: $item"
done

# For loop over array
for item in "${array[@]}"; do
    echo "Item: $item"
done

# For loop with C-style syntax
for (( i=1; i<=10; i++ )); do
    echo "Number: $i"
done

# For loop with seq
for i in $(seq 1 10); do
    echo "Number: $i"
done

# For loop over command output
for line in $(cat file.txt); do
    echo "Line: $line"
done

# Loop with break and continue
for i in {1..10}; do
    if [[ $i -eq 3 ]]; then
        continue  # Skip 3
    fi
    if [[ $i -eq 7 ]]; then
        break     # Stop at 7
    fi
    echo "$i"
done
```

### While Loop

```bash
# While condition is true
count=1
while [[ $count -le 5 ]]; do
    echo "Count: $count"
    (( count++ ))
done

# While reading lines from file
while IFS= read -r line; do
    echo "Line: $line"
done < input.txt

# While reading from command
while IFS= read -r line; do
    echo "User: $line"
done < <(grep -E '^[^#]' /etc/passwd)

# Infinite loop
while true; do
    echo "Running..."
    sleep 1
done

# Using read with timeout
while IFS= read -t 5 -r input; do
    echo "You entered: $input"
done
```

### Until Loop

```bash
# Until condition becomes true
count=1
until [[ $count -gt 5 ]]; do
    echo "Count: $count"
    (( count++ ))
done

# Infinite until
until false; do
    # Loop forever until broken
    true
done
```

### Loop Control

```bash
# Break: exit loop
for i in {1..10}; do
    if [[ $i -eq 5 ]]; then
        break
    fi
    echo "$i"
done

# Continue: skip to next iteration
for i in {1..10}; do
    if [[ $i -eq 5 ]]; then
        continue
    fi
    echo "$i"
done

# Exit from nested loops
for i in {1..3}; do
    for j in {1..3}; do
        if [[ $j -eq 2 ]]; then
            break 2  # Break out of both loops
        fi
        echo "$i,$j"
    done
done
```

---

## 6. Functions

### Function Definition

```bash
# Basic function
my_function() {
    echo "Hello"
}

# Function with parameters
greet() {
    local name="$1"
    local greeting="$2"
    echo "$greeting, $name"
}

# Function with multiple parameters
add() {
    local a="$1"
    local b="$2"
    local sum=$(( a + b ))
    echo "$sum"
}

# Call function
my_function
greet "Alice" "Hello"
result=$(add 5 3)
echo "5 + 3 = $result"
```

### Function Parameters

```bash
# Access parameters
function_name() {
    echo "Script: $0"
    echo "Function: ${FUNCNAME[0]}"
    echo "Param 1: $1"
    echo "Param 2: $2"
    echo "All params: $@"
    echo "Num params: $#"
    echo "All as string: $*"
}

# Shift parameters (useful in loops)
process_args() {
    while (( $# > 0 )); do
        echo "Processing: $1"
        shift  # Remove $1, shift all parameters
    done
}

# Named parameters (shift+validate)
process_file() {
    local filename="$1"
    if [[ ! -f "$filename" ]]; then
        echo "Error: File not found" >&2
        return 1
    fi
    
    # Process file
    cat "$filename"
}

# Default parameters
func_with_defaults() {
    local param1="${1:-default_value}"
    local param2="${2:-another_default}"
    echo "$param1 $param2"
}

func_with_defaults "value"  # param2 gets default
func_with_defaults          # both get defaults
```

### Function Return Values

```bash
# Return exit code (success/failure)
is_even() {
    local num="$1"
    if (( num % 2 == 0 )); then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Check return code
if is_even 4; then
    echo "4 is even"
fi

# Get return code
is_even 5
status=$?
echo "Status: $status"  # 1

# Return output (captured)
get_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
}

timestamp=$(get_timestamp)
echo "Time: $timestamp"

# Both return code and output
safe_divide() {
    if [[ $2 -eq 0 ]]; then
        echo "Error: division by zero" >&2
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

### Local Variables

```bash
# Local variables (function scope only)
my_function() {
    local local_var="only in function"
    global_var="visible outside"
}

my_function
echo "$local_var"      # Empty
echo "$global_var"     # Set

# Shadowing global with local
GLOBAL_VAR="global"

shadow_var() {
    local GLOBAL_VAR="local"  # Local copy
    echo "Inside: $GLOBAL_VAR" # local
}

shadow_var
echo "Outside: $GLOBAL_VAR"    # global

# Function variables
func_info() {
    echo "Function name: ${FUNCNAME[0]}"
    echo "Caller: ${FUNCNAME[1]}"
    echo "Line number: ${BASH_LINENO[0]}"
}
```

---

## 7. Input and Output

### Reading Input

```bash
# Read from keyboard (interactive)
read name
echo "You entered: $name"

# Read with prompt
read -p "Enter name: " name

# Read without echo (password)
read -sp "Enter password: " password
echo ""  # New line

# Read into array
read -a words
echo "First word: ${words[0]}"

# Read specific number of characters
read -n 5 input  # Read 5 characters

# Read with timeout
read -t 10 input  # Timeout after 10 seconds

# Read from file
while IFS= read -r line; do
    echo "Line: $line"
done < filename.txt

# Read from stdin
command | while read -r line; do
    echo "Read: $line"
done
```

### Output

```bash
# Basic echo
echo "Hello, World"

# Echo without newline
echo -n "Hello"

# Echo with escape sequences
echo -e "Line1\nLine2\tTabbed"

# Printf (formatted output)
printf "Hello, %s\n" "$name"
printf "Number: %d\n" "$count"
printf "Float: %.2f\n" "$value"

# Printf format specifiers
%s    # String
%d    # Integer
%f    # Float
%x    # Hexadecimal
%o    # Octal
%.2f  # Float with 2 decimals
%10s  # Right-align in 10 chars
%-10s # Left-align in 10 chars

# Redirect to file
echo "Output" > file.txt         # Overwrite
echo "Append" >> file.txt        # Append

# Send to stderr
echo "Error message" >&2

# Send both stdout and stderr to file
command > output.txt 2>&1
command &> output.txt
```

### Redirection

```bash
# Output redirection
command > file          # Stdout to file (overwrite)
command >> file         # Stdout to file (append)
command 2> file         # Stderr to file
command 2>&1            # Stderr to stdout
command &> file         # Both stdout and stderr

# Input redirection
command < file          # File to stdin
command < <(other_cmd)  # Process substitution

# Pipe
command1 | command2     # Output to input

# Here documents
cat << EOF
Line 1
Line 2
EOF

# Here strings
while read -r line; do
    echo "$line"
done <<< "$variable"
```

---

## 8. String Operations

### String Manipulation

```bash
# Get substring
str="hello world"
echo "${str:0:5}"       # hello
echo "${str:6}"         # world
echo "${str:0:${#str}-1}"  # Remove last char

# Get length
echo "${#str}"          # 11

# Replace (first occurrence)
echo "${str/world/universe}"   # hello universe

# Replace all occurrences
echo "${str//o/O}"      # hellO wOrld

# Remove pattern from start
echo "${str#hello }"    # world

# Remove pattern from end
echo "${str%world}"     # hello 

# Remove longest pattern from start
text="/path/to/file"
echo "${text##*/}"      # file (filename)
echo "${text%/*}"       # /path/to (directory)

# Convert case
echo "${str^^}"         # HELLO WORLD (uppercase)
echo "${str,,}"         # hello world (lowercase)

# Check if contains
[[ $str == *"world"* ]] && echo "Contains"

# Index of substring
index="${str%%world*}"  # Length of prefix
echo "${#index}"        # 6 (position of world)
```

### String Testing

```bash
# Empty string
[[ -z "$var" ]]         # True if empty
[[ -n "$var" ]]         # True if non-empty
[[ $var ]]              # True if non-empty (shorthand)

# String comparison
[[ "$str" == "value" ]]
[[ "$str" != "value" ]]
[[ "$str" < "value" ]]  # Lexicographic
[[ "$str" > "value" ]]

# Pattern matching
[[ "$str" == pat* ]]    # Glob pattern
[[ "$str" =~ pattern ]]  # Regular expression

# String in string
[[ "$str" == *"substring"* ]]
```

---

## 9. Error Handling

### Exit Codes

```bash
# Check exit code
command
echo $?                 # 0 = success, non-zero = error

# Use in condition
if command; then
    echo "Success"
else
    echo "Failed with code $?"
fi

# Command || fallback
command || echo "Command failed"

# Command && continue
command && echo "Command succeeded"

# Custom exit codes
exit 0                  # Success
exit 1                  # General error
exit 2                  # Misuse of shell command
exit 127                # Command not found
exit 128 + n            # Fatal error (signal n)
```

### Set Options

```bash
# Exit on error
set -e
# or
set -o errexit

# Exit on undefined variable
set -u
# or
set -o nounset

# Pipe fails if any command fails
set -o pipefail

# All options
set -euo pipefail

# Disable error on undefined
set +u

# Check if option is set
[[ $- == *x* ]] && echo "Debug mode on"
```

### Error Handling with Trap

```bash
# Cleanup function
cleanup() {
    local status=$?
    echo "Cleaning up..."
    rm -f /tmp/tempfile
    exit $status
}

# Set trap to run on exit
trap cleanup EXIT

# Set trap for specific signals
trap 'echo "Interrupted"; exit 1' INT TERM

# Set trap for error
trap 'echo "Error on line $LINENO"; exit 1' ERR

# Remove trap
trap - EXIT
```

### Input Validation

```bash
# Check argument count
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Validate file exists
if [[ ! -f "$1" ]]; then
    echo "Error: File not found: $1"
    exit 1
fi

# Validate number
if ! [[ "$input" =~ ^[0-9]+$ ]]; then
    echo "Error: Must be a number"
    exit 1
fi

# Validate not empty
if [[ -z "$var" ]]; then
    echo "Error: Variable cannot be empty"
    exit 1
fi

# Validate choice
if [[ ! " start stop restart " =~ " $action " ]]; then
    echo "Error: Invalid action"
    exit 1
fi
```

---

## 10. Debugging

### Debug Techniques

```bash
# Run script with debug output
bash -x script.sh

# Debug from within script
set -x                 # Turn on debug
some_commands
set +x                 # Turn off debug

# Verbose output
bash -v script.sh      # Show each line as read

# Check syntax
bash -n script.sh      # No execution, just check

# Debug specific function
debug_function() {
    set -x
    # Function code
    set +x
}

# Add debug output
DEBUG=1 bash script.sh
# In script:
if [[ ${DEBUG:-0} == 1 ]]; then
    echo "DEBUG: variable=$variable"
fi
```

### Common Issues

```bash
# Variables have spaces (always quote!)
file="my file.txt"
cat $file           # Error
cat "$file"         # Correct

# Wrong comparison
[[ 10 > 5 ]] && echo "true"  # String compare
(( 10 > 5 )) && echo "true"  # Numeric

# Undefined variable
if [[ -n "$undefined" ]]; then  # Safe (quoted)
    echo "Set"
fi

# Pipe to loop (subshell issue)
cat file | while read line; do
    variable="$line"
done
echo "$variable"    # Empty (subshell)

# Fix with process substitution
while read line; do
    variable="$line"
done < <(cat file)
echo "$variable"    # Works
```

---

## Quick Reference by Task

### Task: Parse Command Line Arguments

```bash
# Simple args
filename="$1"
count="$2"

# With validation
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <file> <count>"
    exit 1
fi

# With options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            filename="$2"
            shift 2
            ;;
        -c|--count)
            count="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
```

### Task: Process File Line by Line

```bash
# Method 1: While loop (preserves variables)
while IFS= read -r line; do
    echo "Processing: $line"
done < filename.txt

# Method 2: For loop (simple, less flexible)
for line in $(cat filename.txt); do
    echo "Processing: $line"
done

# Method 3: mapfile (load all at once)
mapfile -t lines < filename.txt
for line in "${lines[@]}"; do
    echo "Processing: $line"
done
```

### Task: Find Files and Process

```bash
# Find and process files
find . -type f -name "*.txt" | while read -r file; do
    echo "Processing: $file"
    wc -l "$file"
done

# Or with for loop
for file in *.txt; do
    [[ -f "$file" ]] || continue
    echo "Processing: $file"
done
```

### Task: Array Operations

```bash
# Create array
array=("a" "b" "c")

# Add element
array+=("d")

# Loop with index
for ((i=0; i<${#array[@]}; i++)); do
    echo "$i: ${array[$i]}"
done

# Filter array
filtered=()
for item in "${array[@]}"; do
    [[ $item != "b" ]] && filtered+=("$item")
done
```

---

**Next:** [03-hands-on-labs.md](03-hands-on-labs.md)
