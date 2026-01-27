# Shell Scripting Basics: Cheatsheet

## Script Structure

| Element | Purpose | Example |
|---------|---------|---------|
| `#!/bin/bash` | Shebang (interpreter) | First line of script |
| `set -e` | Exit on error | Stop script if command fails |
| `set -x` | Debug mode | Print commands before execution |
| `set -u` | Error on undefined vars | Fail on $undefined |
| `set -o pipefail` | Fail if pipe fails | Check all commands in pipeline |

## Variables

| Command | Purpose | Example |
|---------|---------|---------|
| `VAR="value"` | Assign variable | `NAME="DevOps"` |
| `$VAR` | Use variable | `echo $VAR` |
| `${VAR}` | Safe expansion | `echo ${VAR}file` |
| `$((expression))` | Arithmetic | `$((10 + 5))` |
| `$(command)` | Command substitution | `$(date)` or `` `date` `` |
| `export VAR` | Export variable | Available to child processes |
| `readonly VAR` | Make constant | Cannot change |

## String Manipulation

| Command | Purpose | Example |
|---------|---------|---------|
| `${#VAR}` | String length | `${#NAME}` |
| `${VAR:0:5}` | Substring | First 5 chars |
| `${VAR:2}` | Substring from position | `${VAR:2}` |
| `${VAR//old/new}` | Replace all | `${PATH//:/\n}` |
| `${VAR/old/new}` | Replace first | `${VAR/a/b}` |
| `${VAR#pattern}` | Remove prefix | `${VAR#*/}` |
| `${VAR%pattern}` | Remove suffix | `${VAR%.*}` |
| `${VAR^^}` | Uppercase | Convert to upper |
| `${VAR,,}` | Lowercase | Convert to lower |

## Command Arguments

| Variable | Purpose | Example |
|----------|---------|---------|
| `$0` | Script name | `./script.sh` → `./script.sh` |
| `$1, $2, $3` | Positional args | First, second, third arg |
| `$#` | Argument count | Number of arguments |
| `$@` | All arguments | Loop through each |
| `$*` | All as string | Single string |
| `$?` | Exit status | 0=success, non-zero=error |

## Conditionals (if/then/else)

| Condition | Purpose | Example |
|-----------|---------|---------|
| `[ -f file ]` | File exists | `if [ -f /etc/passwd ]` |
| `[ -d dir ]` | Directory exists | `if [ -d /home ]` |
| `[ -e path ]` | Path exists | Either file or dir |
| `[ -r file ]` | Readable | `[ -r "$FILE" ]` |
| `[ -w file ]` | Writable | `[ -w "$FILE" ]` |
| `[ -x file ]` | Executable | `[ -x "$FILE" ]` |
| `[ -z string ]` | Empty string | `[ -z "$VAR" ]` |
| `[ -n string ]` | Non-empty string | `[ -n "$VAR" ]` |
| `[ $a -eq $b ]` | Equal numbers | `-eq` equal |
| `[ $a -ne $b ]` | Not equal | `-ne` not equal |
| `[ $a -lt $b ]` | Less than | `-lt` less than |
| `[ $a -gt $b ]` | Greater than | `-gt` greater than |
| `[ $a -le $b ]` | Less or equal | `-le` |
| `[ $a -ge $b ]` | Greater or equal | `-ge` |
| `[ "$s1" = "$s2" ]` | String equal | `=` for strings |
| `[ "$s1" != "$s2" ]` | String not equal | `!=` |
| `[ cond1 -a cond2 ]` | AND | `-a` or `&&` |
| `[ cond1 -o cond2 ]` | OR | `-o` or `\|\|` |
| `[[ $var =~ regex ]]` | Regex match | Extended test |

## If/Else Syntax

| Pattern | Example |
|---------|---------|
| Simple if | `if [ condition ]; then code; fi` |
| If/else | `if [ cond ]; then code1; else code2; fi` |
| If/elif/else | `if [ c1 ]; then code1; elif [ c2 ]; then code2; else code3; fi` |
| Inline | `[ condition ] && action1 \|\| action2` |

## Loops

| Loop Type | Syntax | Example |
|-----------|--------|---------|
| For list | `for item in list; do code; done` | `for i in 1 2 3` |
| For range | `for ((i=0; i<10; i++))` | C-style loop |
| For glob | `for file in *.txt` | All text files |
| While | `while [ condition ]; do code; done` | Loop while true |
| Until | `until [ condition ]; do code; done` | Loop until true |
| Break | `break` | Exit loop |
| Continue | `continue` | Skip to next |

## Functions

| Syntax | Purpose | Example |
|--------|---------|---------|
| `function_name() { code }` | Define function | `greet() { echo hello; }` |
| `function function_name { }` | Alternative syntax | Function keyword |
| `function_name arg1 arg2` | Call function | Pass arguments |
| `$1, $2, $3` | Function args | Positional parameters |
| `return 0` | Success | Exit code 0 |
| `return 1` | Failure | Exit code non-zero |
| `local var` | Local variable | Function scope only |

## Input/Output

| Command | Purpose | Example |
|---------|---------|---------|
| `echo "text"` | Print to stdout | `echo "Hello"` |
| `printf "format" arg` | Formatted print | `printf "%s\n" $VAR` |
| `read -r var` | Read input | `read -r username` |
| `read -p "prompt" var` | Prompt and read | `read -p "Enter: " var` |
| `> file` | Redirect to file | Overwrite |
| `>> file` | Append to file | Add to end |
| `< file` | Read from file | Input |
| `2>&1` | Redirect stderr | Combine stdout/stderr |
| `2>/dev/null` | Suppress errors | Discard stderr |
| `\| command` | Pipe to command | Pass output |

## File Operations

| Command | Purpose | Example |
|---------|---------|---------|
| `[ -f file ]` | Test file exists | `if [ -f "$file" ]` |
| `[ -d dir ]` | Test dir exists | `if [ -d "$dir" ]` |
| `[ -s file ]` | File not empty | Check size > 0 |
| `cat file` | Read file | `while read -r line` |
| `touch file` | Create file | `touch newfile` |
| `rm file` | Delete file | `rm "$file"` |
| `cp src dst` | Copy file | `cp source destination` |
| `mv src dst` | Move file | `mv old new` |
| `mkdir dir` | Create directory | `mkdir -p "$dir"` |

## Error Handling

| Pattern | Purpose | Example |
|---------|---------|---------|
| `set -e` | Exit on error | Fail fast |
| `trap cleanup EXIT` | Cleanup function | Run on exit |
| `$?` | Last exit code | `[ $? -eq 0 ]` |
| `\|\| action` | On failure | `command \|\| echo error` |
| `&& action` | On success | `command && echo ok` |
| `if ! command` | Negate | `if ! grep -q pattern` |

## Arrays

| Command | Purpose | Example |
|---------|---------|---------|
| `arr=(val1 val2 val3)` | Create array | `colors=(red green blue)` |
| `${arr[0]}` | First element | Index starts at 0 |
| `${arr[@]}` | All elements | `for i in "${arr[@]}"` |
| `${#arr[@]}` | Array length | Number of elements |
| `arr+=(value)` | Append | Add to array |

## Case Statement

| Syntax | Example |
|--------|---------|
| `case $VAR in pattern) code ;; esac` | Match pattern |
| `*) default ;;` | Default case |
| `pattern\|alt)` | Multiple patterns |

## Useful Commands

| Command | Purpose |
|---------|---------|
| `bash -n script` | Check syntax |
| `bash -x script` | Debug (show commands) |
| `shellcheck script` | Lint script |
| `chmod +x script` | Make executable |
| `./script` | Run script |
| `bash script` | Run with explicit bash |
| `source script` | Execute in current shell |
| `which command` | Find command path |
| `type command` | Show command info |
