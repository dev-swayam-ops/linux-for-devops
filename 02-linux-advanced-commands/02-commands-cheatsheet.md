# Advanced Linux Commands: Reference Cheatsheet

Quick lookup reference for advanced text processing commands. See [01-theory.md](01-theory.md) for conceptual understanding.

---

## 📋 grep: Search Text Patterns

### Basic Usage
```bash
grep "pattern" file              # Search for pattern
grep -c "pattern" file           # Count matching lines
grep -i "pattern" file           # Case-insensitive search
grep -v "pattern" file           # Invert match (show non-matching)
grep -n "pattern" file           # Show line numbers
grep -l "pattern" file*          # Show only filenames
grep -o "pattern" file           # Show only matched part
```

### Regular Expressions
```bash
grep "^pattern" file             # Start of line
grep "pattern$" file             # End of line
grep "^$" file                   # Empty lines
grep "pattern1\|pattern2" file   # OR (need \ in basic regex)
grep -E "(ERROR|WARNING)" file   # OR (extended regex, cleaner)
grep "p.ttern" file              # . = any character
grep "p[aeiou]ttern" file        # [] = character class
grep "[^0-9]" file               # [^] = not in class
```

### Advanced Options
```bash
grep -E "regex" file             # Extended regex (use -E)
grep -A 3 "pattern" file         # Show 3 lines after match
grep -B 2 "pattern" file         # Show 2 lines before match
grep -C 2 "pattern" file         # Show 2 lines before & after
grep -r "pattern" /dir           # Recursive search in directory
grep -r "pattern" /dir --include="*.log"   # Restrict by file type
grep -F "literal.string" file    # Literal (no regex interpretation)
```

### Real Examples
```bash
# Find all errors in system log
grep "error" /var/log/syslog | head -20

# Count 404 errors in web logs
grep " 404 " /var/log/apache2/access.log | wc -l

# Find lines starting with ERROR or WARNING
grep -E "^(ERROR|WARNING)" /var/log/app.log

# Show context around matches (3 lines before and after)
grep -C 3 "CRITICAL" /var/log/system.log

# Find files containing a pattern (recursive)
grep -r "database_host" /etc/config/ --include="*.conf"

# Case-insensitive search for TODO comments
grep -ri "TODO\|FIXME" src/

# Find IP addresses
grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" /var/log/auth.log
```

---

## ✂️ cut: Extract Columns

### Basic Usage
```bash
cut -d: -f1 /etc/passwd              # Extract field 1 (delimiter :)
cut -d: -f1,3 /etc/passwd            # Extract fields 1 and 3
cut -d: -f1-3 /etc/passwd            # Extract fields 1 through 3
cut -d' ' -f1 access.log             # Extract field 1 (space delimiter)
cut -d, -f2,5 data.csv               # Extract columns 2, 5 (CSV)
```

### Character Position
```bash
cut -c1 file.txt                 # First character of each line
cut -c1-10 file.txt              # First 10 characters
cut -c1-5,10-15 file.txt         # Characters 1-5 and 10-15
cut -c10- file.txt               # From character 10 to end
```

### Options
```bash
cut -d'|' -f1 file               # Using pipe as delimiter
cut --complement -d: -f1 /etc/passwd  # All EXCEPT field 1
cut -s -d: -f1 /etc/passwd       # Skip lines without delimiter
```

### Real Examples
```bash
# Get usernames from /etc/passwd
cut -d: -f1 /etc/passwd

# Extract IP and path from web logs
cut -d' ' -f1,7 /var/log/apache2/access.log | head -10

# Extract email addresses from CSV
cut -d, -f2 contacts.csv | sort -u

# Get HTTP status codes from logs
cut -d' ' -f9 /var/log/apache2/access.log | sort | uniq -c

# Extract columns 3-5 from tab-separated data
cut -f3-5 data.tsv

# Find users in certain groups
cut -d: -f1,4 /etc/group | grep "^docker"
```

---

## 🔄 awk: Transform and Process Data

### Basic Usage
```bash
awk '{print $1}' file            # Print first field
awk '{print $1, $3}' file        # Print fields 1 and 3
awk -F: '{print $1}' /etc/passwd # Specify delimiter with -F
awk 'NR==5' file                 # Print line number 5
awk 'NR >= 5 && NR <= 10' file   # Print lines 5-10
```

### Filtering and Conditions
```bash
awk '$3 > 1000' /etc/passwd      # Show if field 3 > 1000
awk -F: '$3 > 1000 {print $1}' /etc/passwd  # Complex condition
awk 'length($0) > 100' file      # Lines longer than 100 chars
awk '/pattern/' file             # Lines matching pattern
awk '!/pattern/' file            # Lines NOT matching pattern
```

### Built-in Variables
```bash
awk '{print NR, $0}' file        # NR = line number
awk 'END {print NF}' file        # NF = number of fields (last line's)
awk '{print NF, $0}' file        # Field count for each line
awk 'BEGIN {print "Starting"}' file   # BEGIN block (before processing)
awk 'END {print "Done"}' file    # END block (after processing)
```

### Field Operations
```bash
awk -F: '{print $1, $NF}' /etc/passwd    # First and last field
awk '{gsub("old", "new"); print}' file   # Replace within awk
awk '{$2 = "new"; print}' file           # Modify field
awk '{print toupper($1)}' file           # Convert to uppercase
awk '{print tolower($1)}' file           # Convert to lowercase
```

### Calculations
```bash
awk '{sum += $1} END {print sum}' file   # Sum first field
awk '{sum += $2; count++} END {print sum/count}' file  # Average
awk '$3 ~ /jpg/ {sum += $1} END {print sum}' file  # Conditional sum
awk 'BEGIN {total=0} {total+=$5} END {printf "%.2f\n", total}' file
```

### String Operations
```bash
awk '{print substr($1, 1, 5)}' file      # First 5 chars
awk '{print length($1)}' file            # String length
awk '{print index($1, "x")}' file        # Position of substring
awk 'BEGIN {split("a:b:c", arr, ":"); print arr[2]}'  # Split string
```

### Real Examples
```bash
# Get usernames and their home directories
awk -F: '{print $1, $6}' /etc/passwd

# Sum values in second column
awk '{sum += $2} END {print sum}' data.txt

# Print lines where IP is 192.168.1.x
awk '$1 ~ /192\.168\.1\./ {print}' access.log

# Average file size
ls -l | awk '{sum += $5; count++} END {printf "Average: %.0f\n", sum/count}'

# Count occurrences of each word
awk '{for(i=1; i<=NF; i++) count[$i]++} END {for(word in count) print word, count[word]}' file

# Print every other line
awk 'NR % 2 == 1' file

# Extract fields with custom formatting
awk -F: 'NR > 1 {printf "%s (UID: %s)\n", $1, $3}' /etc/passwd

# Find and count errors by type
awk '/ERROR/ {split($0, a, ":"); count[a[1]]++} END {for(type in count) print type, count[type]}' app.log
```

---

## 🔍 sed: Stream Editor (Text Replacement)

### Basic Substitution
```bash
sed 's/old/new/' file            # Replace first occurrence per line
sed 's/old/new/g' file           # Replace all occurrences (g flag)
sed 's/old/new/2' file           # Replace 2nd occurrence per line
sed 's/old/new/gi' file          # Case-insensitive replace
sed -i 's/old/new/g' file        # Edit file in place
sed -i.bak 's/old/new/g' file    # Edit in place, keep backup
```

### Deletion
```bash
sed '5d' file                    # Delete line 5
sed '5,10d' file                 # Delete lines 5-10
sed '1~2d' file                  # Delete every other line (starting line 1)
sed '/pattern/d' file            # Delete lines matching pattern
sed '/^$/d' file                 # Delete empty lines
sed '/^#/d' file                 # Delete comment lines
```

### Printing (with -n flag)
```bash
sed -n '5p' file                 # Print only line 5
sed -n '5,10p' file              # Print only lines 5-10
sed -n '/pattern/p' file         # Print only matching lines
sed -n '/start/,/end/p' file     # Print from start pattern to end pattern
```

### Address Ranges
```bash
sed '1,5s/old/new/g' file        # Replace in lines 1-5 only
sed '/ERROR/,/WARNING/s/foo/bar/' file  # Replace between patterns
sed '1d; $d' file                # Delete first and last line
```

### Hold Buffer Advanced
```bash
sed 'N; s/\n/ /' file            # Join every 2 lines (replace newline with space)
sed '1h; 1d; $G' file            # Move first line to end
```

### Real Examples
```bash
# Replace domain in config files
sed -i.bak 's/old.example.com/new.example.com/g' *.conf

# Remove leading whitespace
sed 's/^[ \t]*//' file

# Convert DOS line endings to Unix
sed 's/\r$//' file.txt

# Comment out lines containing a pattern
sed '/^#/!s/^/#/' file           # Add # to lines not starting with #

# Extract IP addresses (show only matching part)
sed -n 's/.*IP: \([0-9.]*\).*/\1/p' logfile

# Remove specific lines by line number
sed '1d; 3d; 5d' file            # Remove lines 1, 3, 5

# Replace in specific lines only
sed '10,20s/old/new/g' largefile

# Remove duplicate lines (consecutive)
sed '$!N; s/^\(.*\)\n\1$/\1/' file

# Add text before matching line
sed '/pattern/i\NEW_LINE' file

# Add text after matching line
sed '/pattern/a\NEW_LINE' file

# Multiple replacements in one sed command
sed -e 's/old1/new1/g' -e 's/old2/new2/g' file
```

---

## 📊 sort: Arrange Lines

### Basic Sorting
```bash
sort file                        # Sort alphabetically
sort -r file                     # Reverse sort
sort -u file                     # Sort and remove duplicates
sort -n file                     # Numeric sort
sort -nr file                    # Numeric reverse sort
```

### Field-based Sorting
```bash
sort -t: -k3 /etc/passwd         # Sort by field 3 (delimiter :)
sort -t: -k3 -n /etc/passwd      # Sort by field 3, numeric
sort -t, -k2nr data.csv          # Sort by field 2, numeric reverse
sort -t: -k3,3n -k1,1 /etc/passwd  # Sort by field 3 (primary), field 1 (secondary)
```

### Additional Options
```bash
sort -k2,2 file                  # Sort by field 2 only (not rest)
sort -k3.2,3.5 file              # Sort by chars 2-5 of field 3
sort --random-sort file          # Random order
sort -S 1G file                  # Use 1GB memory (for large files)
sort -c file                     # Check if sorted (return status)
```

### Real Examples
```bash
# Sort /etc/passwd by UID (numeric)
sort -t: -k3 -n /etc/passwd

# Sort log entries by timestamp (assuming standard format)
sort -k4 access.log | head -20

# Sort files by size (largest first)
ls -la | sort -k5 -nr

# Sort CSV by multiple columns
sort -t, -k2,2 -k3,3nr data.csv

# Count and sort by frequency
sort | uniq -c | sort -rn
```

---

## 🔄 uniq: Find Unique or Duplicate Lines

### Basic Usage
```bash
uniq file                        # Remove consecutive duplicates
uniq -c file                     # Count occurrences
uniq -d file                     # Show only duplicates
uniq -u file                     # Show only unique lines (no duplicates)
```

### Options
```bash
uniq -i file                     # Case-insensitive
uniq -f1 file                    # Ignore first field
uniq -s5 file                    # Ignore first 5 characters
uniq -w10 file                   # Compare only first 10 characters
```

### Important: uniq Requires Sorted Input
```bash
# ❌ Wrong
uniq file                        # Won't work if not sorted!

# ✅ Correct
sort file | uniq

# ✅ Correct with other operations
sort file | uniq -c | sort -rn
```

### Real Examples
```bash
# Count unique IPs and show most common
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -10

# Find duplicate lines and count them
sort file | uniq -d -c

# Show only unique lines (no duplicates at all)
sort file | uniq -u

# Count unique users
cut -d: -f1 /etc/passwd | sort | uniq | wc -l

# Find duplicate entries (appear more than once)
sort data.txt | uniq -c | awk '$1 > 1 {print $2}'

# Remove consecutive duplicate lines (keep one)
sort log.txt | uniq > log-unique.txt
```

---

## 🔎 find: Locate Files

### Basic Finding
```bash
find . -name "pattern"           # Find by name
find . -name "*.log"             # Find by extension
find . -iname "pattern"          # Case-insensitive name
find . -type f                   # Find files only
find . -type d                   # Find directories only
find . -type l                   # Find symbolic links
```

### Size and Time
```bash
find . -size +100M               # Larger than 100 MB
find . -size -10k                # Smaller than 10 KB
find . -mtime +7                 # Modified more than 7 days ago
find . -mtime -1                 # Modified within last 24 hours
find . -atime +30                # Accessed more than 30 days ago
```

### Permissions and Ownership
```bash
find . -perm 644                 # Exact permissions
find . -perm -u+w                # User has write permission
find . -user alice               # Owned by user alice
find . -group sudo               # Owned by group sudo
```

### Actions
```bash
find . -name "*.tmp" -exec rm {} \;   # Delete matching files
find . -name "*.log" -exec ls -lh {} \;  # List files with details
find . -type f -newer file            # Files newer than file
find . -name "*.bak" -delete           # Delete (shorthand for -exec rm)
```

### Multiple Conditions
```bash
find . -name "*.log" -type f -mtime +7  # All conditions must match
find . \( -name "*.log" -o -name "*.txt" \)  # OR condition
find . -name "*.tmp" -not -user root    # NOT condition
```

### Depth Control
```bash
find . -maxdepth 1               # Don't search subdirectories
find . -mindepth 2 -maxdepth 3   # Search only 2-3 levels deep
```

### Real Examples
```bash
# Find all log files modified in last 7 days
find /var/log -name "*.log" -mtime -7 -type f

# Find large files (>500MB) in home directory
find ~ -type f -size +500M -exec ls -lh {} \;

# Find and delete old temporary files
find /tmp -name "*.tmp" -mtime +30 -delete

# Find files with insecure permissions (world-writable)
find . -type f -perm -002

# Find backup files recursively
find . -name "*backup*" -o -name "*.bak"

# Count files by type
find . -type f -name "*.log" | wc -l

# Find recently modified Python files
find . -name "*.py" -mtime -1 -type f

# Find empty files
find . -type f -size 0
```

---

## 🔗 xargs: Batch Process Results

### Basic Usage
```bash
find . -name "*.tmp" | xargs rm              # Delete many files
grep "pattern" file | cut -d: -f1 | xargs du -sh  # Process results
cat filelist.txt | xargs chmod 644           # Apply command to many args
```

### Options
```bash
xargs -0                         # Use null separator (safer)
xargs -n1                        # Pass 1 argument per command
xargs -n3                        # Pass 3 arguments per command
xargs -I{} command {} \;         # Replace {} with each arg
xargs -I{} -n1 command {} \;     # Combine -n and -I
xargs -p                         # Prompt before execution
xargs --verbose                  # Show command before running
```

### Real Examples
```bash
# Find and delete files (safer with -0)
find . -name "*.bak" -print0 | xargs -0 rm

# Apply chmod to files found by find
find . -name "*.sh" -type f | xargs chmod +x

# Count total size of files matching pattern
find . -name "*.log" -type f | xargs du -sh | tail -1

# Process one file at a time
ls *.csv | xargs -I{} process_file {}

# Search multiple files with grep
find /var/log -name "*.log" -type f | xargs grep "ERROR"

# Run command with prompt before each execution
ls *.txt | xargs -p cat

# Rename files using xargs
ls *.oldext | sed 's/\.oldext$//' | xargs -I {} mv {}.oldext {}.newext

# Parallel processing with multiple cores
cat file_list.txt | xargs -P 4 -I{} process_file {}
```

---

## 📝 tr: Translate/Transform Characters

### Basic Usage
```bash
tr 'a-z' 'A-Z'                   # Convert lowercase to uppercase
tr 'A-Z' 'a-z'                   # Convert uppercase to lowercase
tr -d ' '                        # Delete spaces
tr -d '\n'                       # Delete newlines
tr -s ' '                        # Squeeze multiple spaces to one
```

### Character Classes
```bash
tr '[:lower:]' '[:upper:]'       # Lowercase to uppercase (POSIX)
tr '[:digit:]' '#'               # Replace digits with #
tr -d '[:space:]'                # Remove all whitespace
tr -d '[:punct:]'                # Remove punctuation
```

### Real Examples
```bash
# Convert to uppercase
echo "hello" | tr 'a-z' 'A-Z'    # Output: HELLO

# Remove newlines
tr -d '\n' < file.txt            # Single line output

# Swap two characters
tr ',' ';' < data.csv            # Replace commas with semicolons

# Remove non-printable characters
tr -cd '[:print:]' < file        # Keep only printable chars

# Create password: random string
tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16
```

---

## 📋 Other Useful Commands

### comm: Compare Sorted Files
```bash
comm file1 file2                 # Show unique to file1, unique to file2, common
comm -12 file1 file2             # Show only common lines
comm -13 file1 file2             # Show lines unique to file2
comm -23 file1 file2             # Show lines unique to file1
```

### diff: Show File Differences
```bash
diff file1 file2                 # Show differences
diff -u file1 file2              # Unified format (for patches)
diff -y file1 file2              # Side-by-side comparison
diff -r dir1 dir2                # Recursive directory comparison
```

### paste: Merge Lines
```bash
paste file1 file2                # Merge lines side-by-side (tab separator)
paste -d: file1 file2            # Use : as separator
paste -d'\n' file1 file2         # Merge on separate lines (interleave)
```

### head/tail: Show File Portions
```bash
head -20 file                    # First 20 lines
tail -20 file                    # Last 20 lines
head -c 100 file                 # First 100 bytes
tail -c 100 file                 # Last 100 bytes
tail -f file                     # Follow file (watch for updates)
head -n -10 file                 # All but last 10 lines
```

### wc: Count Lines/Words/Characters
```bash
wc -l file                       # Count lines
wc -w file                       # Count words
wc -c file                       # Count bytes
wc -m file                       # Count characters
```

---

## 💡 Quick Reference Table

| Task | Command |
|------|---------|
| Find ERROR lines | `grep ERROR file` |
| Extract field 1 (colon delim) | `cut -d: -f1 file` |
| Sum field 3 | `awk '{sum+=$3} END {print sum}' file` |
| Replace old with new | `sed 's/old/new/g' file` |
| Sort by field 2 | `sort -t: -k2 file` |
| Count unique lines | `sort file \| uniq \| wc -l` |
| Find *.log files | `find . -name "*.log"` |
| Delete results of find | `find . -name "*.tmp" -delete` |
| Show line 5-10 | `sed -n '5,10p' file` |
| Show lines with ERROR after line | `grep -A3 ERROR file` |
| Convert lowercase | `tr 'a-z' 'A-Z'` |
| Compare files | `diff file1 file2` |
| Top 10 most common | `sort file \| uniq -c \| sort -rn \| head` |
| Process many files | `find . -name "*.txt" \| xargs cat` |
| Extract IPs | `grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}'` file |

---

## 🔗 Common Pipelines

### Log Analysis
```bash
grep "ERROR" /var/log/app.log | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
```

### Data Extraction
```bash
awk -F: '$3 > 1000 {print $1, $6}' /etc/passwd | sort
```

### Bulk Text Replacement
```bash
find . -name "*.conf" -type f -exec sed -i.bak 's/old/new/g' {} \;
```

### File Organization
```bash
find . -name "*.log" -mtime +7 | xargs gzip
```

### Data Validation
```bash
cut -d, -f1 data.csv | sort -u | wc -l
```

---

*Advanced Linux Commands: Reference Cheatsheet*
*Keep this open while practicing commands*
