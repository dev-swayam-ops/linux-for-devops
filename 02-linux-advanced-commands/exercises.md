# Linux Advanced Commands: Exercises

Complete these exercises to master advanced Linux command techniques.

## Exercise 1: Searching with Find

Create multiple files in a test directory with different extensions.

**Tasks:**
1. Create a directory `test_search` with files: `report.txt`, `data.csv`, `script.sh`, `image.jpg`, `config.ini`
2. Find all `.txt` files recursively
3. Find all files modified in the last 7 days
4. Find files larger than 1MB
5. Execute a command on found files (e.g., list their details)

**Hint:** Use `find -name`, `find -type`, `find -mtime`, `-size`, and `-exec`.

---

## Exercise 2: Pattern Matching with Grep

Create a file `server.log` with various log entries (errors, warnings, info).

**Tasks:**
1. Search for lines containing "ERROR"
2. Find lines NOT containing "INFO"
3. Count occurrences of a specific pattern
4. Search using case-insensitive matching
5. Display line numbers with matches
6. Show 2 lines before and after matches

**Hint:** Use `grep`, `grep -v`, `-c`, `-i`, `-n`, `-B`, `-A`.

---

## Exercise 3: Text Processing with Sed

Create a configuration file `app.conf` with settings like:
```
server.port=8080
server.host=localhost
debug=false
timeout=30
```

**Tasks:**
1. Replace a value (e.g., port 8080 with 9000)
2. Delete specific lines
3. Insert a new line after a match
4. Make changes only on matching lines
5. Undo changes (work on copies)

**Hint:** Use `sed -i`, `s///`, `d`, `i\`, `-n p`, and test with `-e`.

---

## Exercise 4: Process Management

**Tasks:**
1. List all running processes
2. Filter to show only Python processes
3. Sort processes by memory usage
4. Start a background job and monitor it
5. Kill a specific process by name
6. Show process hierarchy for a parent process

**Hint:** Use `ps`, `grep`, `pstree`, `jobs`, `killall`, `pgrep`.

---

## Exercise 5: Piping and Redirection

**Tasks:**
1. Combine multiple commands with pipes
2. Redirect stdout and stderr separately
3. Redirect both to the same file
4. Append output instead of overwriting
5. Use pipe to pass output between 3+ commands
6. Capture both output and errors

Example: Filter a large log file → search for errors → save to file → count lines

**Hint:** Use `|`, `>`, `>>`, `2>`, `2>&1`, `&>`.

---

## Exercise 6: Advanced Grep Patterns

Create a file `data.txt` with mixed content including emails, IP addresses, numbers, and text.

**Tasks:**
1. Find all lines with email addresses
2. Extract all IP addresses
3. Find lines starting with specific text
4. Find lines ending with specific text
5. Search for words with variable patterns
6. Use extended regex for complex patterns

**Hint:** Use `grep -E` (extended), anchors `^` and `$`, character classes `[0-9]`, repetition `+`, `*`.

---

## Exercise 7: Archiving and Compression

**Tasks:**
1. Create multiple files and directories
2. Create a tar archive
3. Compress with gzip (tar.gz)
4. List contents without extracting
5. Extract to a specific directory
6. Compare compressed vs uncompressed sizes

**Hint:** Use `tar -cvf`, `-czf`, `-tf`, `-tzf`, `-xf`, `du -sh`.

---

## Exercise 8: Sorting and Unique Operations

Create a file `inventory.txt` with duplicate product names and quantities.

**Tasks:**
1. Sort alphabetically
2. Sort by number (quantities)
3. Remove duplicate entries
4. Show duplicates only
5. Count occurrences of each entry
6. Sort and find top 5 entries

**Hint:** Use `sort`, `sort -n`, `uniq`, `uniq -d`, `uniq -c`, `-k` for key sorting.

---

## Exercise 9: Cutting and Joining Columns

Create a CSV file with: `id,name,email,department`

**Tasks:**
1. Extract specific columns (e.g., name and email)
2. Change delimiter (CSV to colon-separated)
3. Extract range of columns
4. Work with fixed-width formats
5. Combine with other commands to filter

**Hint:** Use `cut -d`, `-f`, `cut -c` for character positions.

---

## Exercise 10: Combining Advanced Techniques

**Scenario:** Analyze a large application log file (create sample with 100+ lines).

**Tasks:**
1. Find all ERROR entries and count them
2. Extract timestamps from logs
3. Filter errors from past 5 lines containing "database"
4. Create summary: timestamp, error type, frequency
5. Export results to structured format
6. Identify top 3 most common errors

**Hint:** Combine `grep`, `cut`, `sort`, `uniq -c`, pipes, and redirections.
