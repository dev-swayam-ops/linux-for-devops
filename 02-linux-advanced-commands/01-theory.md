# Advanced Linux Commands: Conceptual Foundations

This document explains the "why" behind advanced Linux text processing tools. Understand the concepts, and the tools will make sense.

---

## Section 1: The Unix Philosophy

### Core Principle: Do One Thing Well

The Unix philosophy states that programs should:
1. Do ONE thing
2. Do it WELL
3. Work with other programs

This is why Linux has many small tools instead of one big tool.

```
Command 1 → Output
             ↓
          Command 2 → Output
                       ↓
                    Command 3 → Result
```

Each command processes data and passes it to the next. This is the **pipe** (`|`).

### Why This Matters

Instead of "one tool that does everything," Unix gives you tools that combine:

```bash
# Bad: Try to do everything with one tool
# (doesn't exist)

# Good: Chain specialized tools
cat access.log | grep ERROR | cut -d: -f1 | sort | uniq -c | sort -rn
#  ↓           ↓            ↓            ↓    ↓       ↓
# read file   filter     extract     sort dedupe count
```

This approach is:
- ✅ Flexible (combine in endless ways)
- ✅ Testable (verify each step)
- ✅ Reusable (use same tools everywhere)
- ✅ Scriptable (automate combinations)

---

## Section 2: Text and Data Processing

### What is a Stream?

A stream is a sequence of data flowing from one place to another.

```
File                  Command           Output
│                       │                 │
├─ Line 1              │                  │
├─ Line 2        →  Process        →   Filtered
├─ Line 3              │                  │
└─ Line N              │                  └─ (to file or pipe)
```

Three standard streams:
- **STDIN** (0): Input to a command
- **STDOUT** (1): Output from a command
- **STDERR** (2): Error messages from a command

### How Redirection Works

```bash
command > file        # Redirect STDOUT to file (overwrite)
command >> file       # Redirect STDOUT to file (append)
command < file        # Feed STDIN from file
command 2> file       # Redirect STDERR to file
command 2>&1          # Redirect STDERR to STDOUT
```

### How Pipes Work

```bash
command1 | command2

# What happens:
# 1. command1 runs and produces output (STDOUT)
# 2. That output becomes input (STDIN) to command2
# 3. command2 processes and produces output
# 4. Output goes to screen (or another pipe, or file)
```

**Example:**
```bash
cat logfile.txt | grep ERROR | wc -l

# Step 1: cat logfile.txt
#   → Outputs every line of logfile.txt

# Step 2: | grep ERROR
#   → Takes those lines as input
#   → Filters to only lines containing ERROR

# Step 3: | wc -l
#   → Takes filtered lines as input
#   → Counts them (-l = lines)
#   → Outputs: number
```

---

## Section 3: Regular Expressions (Regex)

### What is Regex?

A regular expression is a pattern language for matching text.

Instead of searching for "ERROR" exactly, regex lets you search for:
- "ERROR or WARNING"
- "An IP address"
- "A line starting with [ERROR]"
- "Any number between 1-3 digits"

### Basic Regex Patterns

| Pattern | Means | Example |
|---------|-------|---------|
| `.` | Any single character | `c.t` matches "cat", "cot", "cut" |
| `*` | Previous char, 0+ times | `ca*t` matches "ct", "cat", "caat" |
| `+` | Previous char, 1+ times | `ca+t` matches "cat", "caat" (not "ct") |
| `?` | Previous char, 0-1 times | `ca?t` matches "ct", "cat" (not "caat") |
| `^` | Start of line | `^ERROR` matches ERROR only at line start |
| `$` | End of line | `ERROR$` matches ERROR only at line end |
| `[abc]` | Any char in brackets | `[aeiou]` matches any vowel |
| `[a-z]` | Range of chars | `[0-9]` matches any digit |
| `[^abc]` | Any char NOT in brackets | `[^0-9]` matches any non-digit |
| `\` | Escape special char | `\.` matches literal dot (not "any char") |
| `\|` | OR (alternation) | `ERROR\|WARNING` matches ERROR or WARNING |
| `()` | Group/capture | `(ERROR\|WARNING): (.+)` captures both |

### Real Examples

```bash
# Match IP address pattern
# \([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}
# Means: 3 groups of (1-3 digits + dot) + 1-3 digits

# Match email addresses
# [a-zA-Z0-9._-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}

# Match time in HH:MM:SS format
# [0-2][0-9]:[0-5][0-9]:[0-5][0-9]

# Match word at start of line
# ^word
```

### Extended vs Basic Regex

**Basic regex** (used by `grep`, `sed` without -E):
```bash
\(group\)     # Parentheses must be escaped with \
a\|b          # Pipe must be escaped with \
\+            # Plus must be escaped with \
\?            # Question mark must be escaped with \
```

**Extended regex** (used by `grep -E`, `sed -E`, `awk`):
```bash
(group)       # Parentheses are special as-is
a|b           # Pipe is special as-is
+             # Plus is special as-is
?             # Question mark is special as-is
```

**Practical rule**: Use extended regex (`-E` flag) for readability:
```bash
grep -E '(ERROR|WARNING)' logfile.txt    # Extended (cleaner)
grep 'ERROR\|WARNING' logfile.txt        # Basic (awkward)
```

---

## Section 4: Data Structures in Linux

### Common Data Formats

#### CSV (Comma-Separated Values)
```
alice,1001,1000,Alice Smith
bob,1002,1001,Bob Jones
charlie,1003,1002,Charlie Brown
```
- **Delimiter**: Comma (`,`)
- **Tool**: `cut` with `-d,`

#### Colon-Separated (like /etc/passwd)
```
root:x:0:0:root:/root:/bin/bash
alice:x:1000:1000:Alice Smith:/home/alice:/bin/bash
```
- **Delimiter**: Colon (`:`)
- **Tool**: `cut` with `-d:`

#### Space/Tab Separated (logs, output)
```
192.168.1.1 alice 2024-01-14 10:30:45 GET /index.html 200
192.168.1.2 bob   2024-01-14 10:31:02 GET /about.html 404
```
- **Delimiter**: Space or tab
- **Tool**: `cut` with `-d' '` or `awk` with `-F' '`

#### JSON (JavaScript Object Notation)
```json
{"name": "alice", "uid": 1000, "group": "users"}
```
- **Delimiter**: Field names in `{}`
- **Tool**: `grep` to find, `cut` to extract, or specialized JSON tools

#### Structured Text
```
ERROR: Connection failed
Time: 2024-01-14 10:30:45
Code: 500
```
- **Delimiter**: Varies
- **Tool**: `grep` to find, `cut` or `awk` to extract, `sed` to rearrange

### Example: Understanding /etc/passwd

```
root:x:0:0:root:/root:/bin/bash
 ↓  ↓ ↓ ↓  ↓    ↓      ↓
 1  2 3 4  5    6      7
```

1. **Username** (alice)
2. **Password** (x = stored in /etc/shadow)
3. **UID** (user ID, 0 = root)
4. **GID** (group ID)
5. **GECOS** (full name, comment)
6. **Home directory** (/home/alice)
7. **Shell** (/bin/bash)

```bash
# Extract username and UID
cut -d: -f1,3 /etc/passwd
# Output: alice:1000

# Extract users with UID > 1000 (non-system)
awk -F: '$3 > 1000 {print $1, $3}' /etc/passwd
# Output: alice 1000
```

### Example: Understanding Apache Access Log

```
192.168.1.1 - alice [14/Jan/2024:10:30:45 +0000] "GET /index.html HTTP/1.1" 200 1234
 ↓        ↓  ↓    ↓                            ↓           ↓      ↓    ↓
 1        2  3    4                            5           6      7    8
```

1. **IP address** (client)
2. **Identity** (usually -)
3. **Username** (or -)
4. **Timestamp** (with timezone)
5. **HTTP method + path + version**
6. **Response code** (200 = OK, 404 = Not Found)
7. **Response size** (bytes)
8. **Referrer and User-Agent** (often cut off for brevity)

```bash
# Count requests by IP
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn

# Find all 404 errors
grep " 404 " access.log

# Top 10 requested URLs
grep "GET" access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -10
```

---

## Section 5: Text Processing Tools Overview

### grep: Filter Lines by Pattern

**Purpose**: Find lines matching a pattern

```
File                     grep             Output
│                         │                 │
├─ Line 1                 │                 │
├─ ERROR in line 2   →  Pattern      →   ERROR in line 2
├─ Line 3                 │                 │
├─ WARNING in 4      →                  WARNING in 4
└─ Line 5                 │                 │
```

**Use When**: You want to filter (keep some lines, discard others)

```bash
grep "ERROR" logfile.txt          # Simple string search
grep "^2024" logfile.txt          # Lines starting with 2024
grep -E "(ERROR|WARNING)" logfile # ERROR or WARNING (extended regex)
grep -c "404" logfile             # Count matching lines
grep -v "success" logfile         # Invert: lines NOT matching
```

### cut: Extract Columns

**Purpose**: Extract specific fields from structured data

```
Input:  alice:x:1000:1000:Alice:/home/alice:/bin/bash
        └─1─┘ ┘ └─3─┘└─4─┘└─────5─────┘└──────6──────┘└──────7──────┘

cut -d: -f1,3,6
Output: alice:1000:/home/alice
```

**Use When**: Data has fixed delimiters (CSV, colon-separated, tab-separated)

```bash
cut -d: -f1 /etc/passwd                # Get usernames
cut -d' ' -f1,7 access.log             # Get IP and path
cut -d, -f2,4,5 data.csv               # Get columns 2,4,5 from CSV
cut -c1-10 file.txt                    # Get first 10 characters
```

### awk: Powerful Transformation

**Purpose**: Process structured data with flexibility

```
Input:  each line becomes fields
        alice:x:1000:1000:Alice:/home/alice
        $1    $2 $3   $4   $5    $6
        
awk -F: '{print $1, $3}'
Output: alice 1000
```

**Use When**: Need complex logic, calculations, or multi-step processing

```bash
awk -F: '{print $1, $3}' /etc/passwd              # Extract fields
awk -F' ' '{s+=$7} END {print s}' access.log      # Sum field
awk '$3 > 1000' /etc/passwd                       # Filter by field
awk '{gsub("old","new"); print}' file.txt         # Replace within awk
```

### sed: Stream Editor (Substitution)

**Purpose**: Replace text in a stream

```
Input:  old text here
        this needs changing

sed 's/old/new/'
Output: new text here
        this needs changing
```

**Use When**: Bulk text replacement, in-place file editing

```bash
sed 's/old/new/g' file.txt              # Replace all (g flag)
sed -i.bak 's/foo/bar/g' file.txt       # Edit in place, keep backup
sed -n '10,20p' file.txt                # Print lines 10-20
sed '/pattern/d' file.txt               # Delete matching lines
```

### sort: Order Lines

**Purpose**: Sort lines by various criteria

```
Input:   charlie
         alice
         bob

sort
Output:  alice
         bob
         charlie
```

**Use When**: Organizing data, preparing for deduplication

```bash
sort -t: -k3 -n /etc/passwd             # Sort by field 3, numeric
sort -r logfile.txt                     # Reverse sort
sort -t, -k2,2nr data.csv               # Sort by 2nd column, numeric, reverse
sort -u logfile.txt                     # Sort and remove duplicates
```

### uniq: Remove or Count Duplicates

**Purpose**: Find unique lines or count occurrences

**Important**: `uniq` only works on SORTED input!

```
Input (sorted):    apple
                   apple
                   banana
                   banana
                   banana
                   cherry

uniq
Output:            apple
                   banana
                   cherry

uniq -c
Output:            2 apple
                   3 banana
                   1 cherry
```

**Use When**: Finding duplicates, counting occurrences

```bash
sort logfile.txt | uniq               # Remove consecutive duplicates
sort logfile.txt | uniq -c            # Count each unique line
sort logfile.txt | uniq -d            # Show only duplicates
sort logfile.txt | uniq -c | sort -rn # Most common lines first
```

### find: Locate Files

**Purpose**: Find files matching criteria

```
Directory tree
├─ file1.txt
├─ file2.log
├─ subdir/
│  ├─ file3.txt
│  └─ file4.log

find . -name "*.txt"
Output: ./file1.txt
        ./subdir/file3.txt
```

**Use When**: Locating files by name, type, date, size, permissions

```bash
find . -name "*.log"                    # By name
find . -type f -mtime +7                # Modified > 7 days ago
find . -type d -name "backup*"          # Directories with name pattern
find . -size +100M                      # Larger than 100 MB
find . -name "*.tmp" -exec rm {} \;     # Delete matching files
```

### xargs: Pass Results as Arguments

**Purpose**: Convert piped input into command arguments

```
Input (from pipe):  file1.txt
                    file2.txt
                    file3.txt

xargs wc -l
Output: Command becomes: wc -l file1.txt file2.txt file3.txt
        → 10 file1.txt
          20 file2.txt
          30 file3.txt
          60 total
```

**Use When**: Need to process many files or apply commands to search results

```bash
find . -name "*.tmp" | xargs rm         # Delete many files
grep "ERROR" logs/* | cut -d: -f1 | sort -u | xargs du -sh
```

---

## Section 6: ASCII Diagrams

### Data Processing Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    Text Processing Pipeline                      │
└─────────────────────────────────────────────────────────────────┘

INPUT: /var/log/apache2/access.log (raw data)
   ↓
   ├─→ grep " 404 " (filter: keep only 404s)
   │    10,000 lines → 500 lines
   ↓
   ├─→ cut -d' ' -f1 (extract IP addresses)
   │    500 lines → 500 IPs
   ↓
   ├─→ sort (organize)
   │    [randomized] → [sorted]
   ↓
   ├─→ uniq -c (count occurrences)
   │    500 IPs → IP + count (deduplicated)
   ↓
   ├─→ sort -rn (sort by count, reverse)
   │    [by IP] → [most common first]
   ↓
   ├─→ head -5 (take first 5)
   │    All results → Top 5 IPs
   ↓
OUTPUT: Top 5 IPs causing 404 errors
```

### grep Processing

```
Pattern Matching:
─────────────────
Input: apple
       apple pie
       apple tree
       banana
       apples
       pineapple

grep "^apple"          grep "apple$"          grep "appl"
Output: apple          Output: apple          Output: apple
        apple pie             pineapple              apple pie
        apple tree                                  apple tree
        apples                                      apples
                                                    pineapple
```

### awk Field Processing

```
Line:  alice:x:1000:1000:Alice Smith:/home/alice:/bin/bash
Fields: $1    $2 $3   $4   $5           $6           $7

awk -F: '$3 > 1000 {print $1": "$6}' /etc/passwd

Process:
1. Split by `:` (delimiter)
2. Check: Is field $3 (UID) > 1000?
3. If yes: Print field $1 and field $6
4. If no: Skip this line

Example output:
alice: /home/alice
bob: /home/bob
```

### sed Substitution

```
sed 's/old/new/g' file.txt

Process:
─────────
Line 1: "old name is old"
        ^         ^
        └─match ──┘

Substitute (s) first old → new, g flag means global (all)

Result: "new name is new"

Before: old name is old
        old text old
        older code old
        no old stuff

After:  new name is new
        new text new
        newer code new
        no new stuff
```

---

## Section 7: Common Patterns

### Pattern 1: Log Analysis

```bash
# Template
cat logfile | grep "pattern" | cut -d'delimiter' -f1,2,3 | sort | uniq -c | sort -rn

# Real example: Find top IPs causing errors
grep "ERROR" /var/log/syslog | cut -d' ' -f5 | sort | uniq -c | sort -rn | head -10

# What this does:
# 1. Find lines with ERROR
# 2. Extract the IP (field 5)
# 3. Count unique IPs
# 4. Sort by count, show top 10
```

### Pattern 2: Data Extraction

```bash
# Template
cut -d'delimiter' -f'column_numbers' datafile | sort | uniq

# Real example: List unique users who logged in
grep "session opened" /var/log/auth.log | cut -d' ' -f10 | sort -u

# What this does:
# 1. Find session lines
# 2. Extract username (field 10)
# 3. Remove duplicates, keep unique
```

### Pattern 3: Bulk Replacement

```bash
# Template
sed -i.backup 's/old_pattern/new_pattern/g' file_or_pattern

# Real example: Update server in all configs
sed -i.bak 's/old.server.com/new.server.com/g' *.conf

# What this does:
# 1. Replace all occurrences (g flag)
# 2. Edit in place (-i), keep backup (.bak)
# 3. Apply to all .conf files
```

### Pattern 4: Filter and Count

```bash
# Template
grep "pattern" file | cut -d'delimiter' -f'column' | sort | uniq -c | sort -rn

# Real example: Count access by user agent
grep "2024" /var/log/apache2/access.log | grep "Mozilla" | awk -F'"' '{print $6}' | sort | uniq -c | sort -rn

# What this does:
# 1. Find recent logs (2024)
# 2. Keep only Firefox users
# 3. Extract user agent (field 6)
# 4. Count by agent, show most common first
```

---

## Section 8: Mental Models

### Model 1: Think of grep as a Filter

```
Stream of water flowing down
             ↓
    ┌────────filter─────────┐
    ↓                       ↓
(matches)              (doesn't match)
(passes through)        (stops)
```

**Grep** filters: some lines pass (match), some stop (don't match).

### Model 2: Think of awk as a Transformer

```
Raw input:    alice:1000:/home/alice
              ↓
              └─→ Split by delimiter
              ↓
              $1    $3    $6
              ↓
              └─→ Combine in new way
              ↓
Output:       alice (1000)
```

**awk** transforms: takes input, breaks it up, reassembles in new form.

### Model 3: Think of sed as a Find & Replace

```
Before:  I have old code
         old is outdated
         old system

After:   I have new code
         new is outdated
         new system
```

**sed** substitutes: finds pattern, replaces with new text, outputs result.

### Model 4: Think of sort as Organizing

```
Unsorted:  charlie
           alice
           bob

Sorted:    alice
           bob
           charlie
```

**sort** organizes: puts lines in specific order (alphabetical, numeric, etc.).

### Model 5: Think of uniq as Deduplication

```
Before (sorted):  apple
                  apple
                  apple
                  banana
                  banana
                  cherry

After (uniq):     apple
                  banana
                  cherry

With -c count:    3 apple
                  2 banana
                  1 cherry
```

**uniq** deduplicates: removes consecutive identical lines (only if sorted first!).

---

## Section 9: Execution Flow

### How a Pipe Actually Executes

```
$ cat file.txt | grep ERROR | cut -d: -f1 | sort | uniq -c

1. cat file.txt
   ├─ Reads file
   └─ Outputs to STDOUT

2. grep ERROR
   ├─ Receives STDOUT from cat (as STDIN)
   ├─ Filters to lines with ERROR
   └─ Outputs matching lines

3. cut -d: -f1
   ├─ Receives STDOUT from grep (as STDIN)
   ├─ Extracts field 1 (delimiter :)
   └─ Outputs field 1 from each line

4. sort
   ├─ Receives STDOUT from cut (as STDIN)
   ├─ Sorts all lines alphabetically
   └─ Outputs sorted lines

5. uniq -c
   ├─ Receives STDOUT from sort (as STDIN)
   ├─ Counts consecutive duplicates
   └─ Outputs count + line to terminal

STDOUT → STDIN → STDOUT → STDIN → ... → STDOUT to terminal
```

### Why Order Matters

```bash
# Correct
sort logfile | uniq -c | sort -rn
(sorts first, then uniq works correctly, then sorts by count)

# Wrong
uniq -c logfile | sort
(uniq can't find duplicates if not sorted first)

# Wrong
sort | uniq -c logfile
(uniq can't read from file AND pipe at same time)
```

---

## Section 10: Common Mistakes and How to Avoid Them

### Mistake 1: Forgetting to Sort Before uniq

```bash
# ❌ Wrong (uniq won't work correctly)
cat file | uniq -c

# ✅ Correct
cat file | sort | uniq -c
```

**Why**: `uniq` only compares consecutive lines. If duplicates aren't together, `uniq` can't find them.

### Mistake 2: Using sed -i Without Backup

```bash
# ❌ Wrong (no backup if something goes wrong)
sed -i 's/old/new/g' important.conf

# ✅ Correct (keeps backup)
sed -i.bak 's/old/new/g' important.conf

# ✅ Also correct (create your own backup)
cp important.conf important.conf.bak
sed -i 's/old/new/g' important.conf
```

**Why**: If sed makes a mistake, you lose the original data.

### Mistake 3: Regex Without Testing

```bash
# ❌ Wrong (test on 1000s of files and break)
sed -i 's/complex.regex.pattern/replacement/g' *.txt

# ✅ Correct (test first)
sed 's/complex.regex.pattern/replacement/g' sample.txt | head
# Review output, then:
sed -i 's/complex.regex.pattern/replacement/g' *.txt
```

**Why**: Regex patterns can match unexpected things. Always test on small sample first.

### Mistake 4: Piping to Destructive Commands

```bash
# ❌ Wrong (if find results are wrong, files are deleted!)
find . -name "*.tmp" | xargs rm

# ✅ Correct (verify first)
find . -name "*.tmp" | xargs ls -lh
# Review the list, then:
find . -name "*.tmp" | xargs rm

# ✅ Also correct (safer with -i flag)
find . -name "*.tmp" -exec rm -i {} \;
```

**Why**: If you get the find criteria wrong, you could delete wrong files.

### Mistake 5: Assuming Field Numbers

```bash
# ❌ Wrong (field numbers can change, breaks script)
awk '{print $2}' logfile

# ✅ Correct (specify delimiter explicitly)
awk -F' ' '{print $2}' logfile

# ✅ Better (use field names if available)
awk -F: '$3 > 1000 {print $1, $6}' /etc/passwd  # Clearer intent
```

**Why**: If input format changes, field numbers might not be what you expect.

---

## Section 11: Performance Considerations

### Understanding Command Performance

```bash
# Slow (searches entire file for every line)
while read line; do
    grep "$line" otherfile
done < largefile

# Fast (searches once, efficiently)
grep -f largefile otherfile
```

### When to Use Each Tool

| Scenario | Best Tool | Why |
|----------|-----------|-----|
| Filter lines | `grep` | Optimized for pattern matching |
| Extract columns | `cut` | Fast for fixed-position fields |
| Complex transformations | `awk` | Flexible, handles calculations |
| In-place substitution | `sed -i` | Stream-based, memory efficient |
| Sorting many lines | `sort` | Optimized for large datasets |
| Counting unique | `sort \| uniq` | Faster than most alternatives |
| Finding files | `find` | Searches entire directory tree |
| Running commands on results | `xargs` | Batches operations efficiently |

### Rule of Thumb

1. **First, make it work** (correctness)
2. **Then, make it right** (readability)
3. **Then, optimize if needed** (performance)

Most text processing is fast enough. Focus on correctness first.

---

## Summary: Tools at a Glance

| Tool | Does What | Example |
|------|-----------|---------|
| **grep** | Filter lines | `grep ERROR logfile` |
| **cut** | Extract columns | `cut -d: -f1 /etc/passwd` |
| **awk** | Transform data | `awk '{print $1, $3}'` |
| **sed** | Replace text | `sed 's/old/new/g'` |
| **sort** | Order lines | `sort -t: -k3 -n` |
| **uniq** | Remove duplicates | `sort \| uniq -c` |
| **find** | Locate files | `find . -name "*.log"` |
| **xargs** | Batch commands | `find . -name "*.tmp" \| xargs rm` |

**Remember**: Each tool does ONE thing well. Combine them with pipes to solve complex problems.

---

*Advanced Linux Commands: Conceptual Foundations*
*Understanding the "why" enables mastery of the "how"*
