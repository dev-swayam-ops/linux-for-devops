# Linux Advanced Commands: Solutions

## Exercise 1: Searching with Find

**Solution:**

```bash
# Create test directory with files
mkdir -p test_search
cd test_search
echo "Report content" > report.txt
echo "id,name,value" > data.csv
echo "#!/bin/bash" > script.sh
touch image.jpg
echo "[config]" > config.ini

# Find all .txt files
find . -name "*.txt"

# Find files modified in last 7 days
find . -mtime -7

# Find files larger than 1MB
find . -size +1M

# Execute ls -lh on found files
find . -name "*.txt" -exec ls -lh {} \;
```

**Explanation:** `find` with `-exec` runs commands on matched files. `{}` represents each found file. `-mtime` shows modification time (negative = within days).

---

## Exercise 2: Pattern Matching with Grep

**Solution:**

```bash
# Create sample log
cat > server.log << 'EOF'
2024-01-27 10:00:01 ERROR Database connection failed
2024-01-27 10:00:05 INFO Starting application
2024-01-27 10:00:10 WARNING Memory usage high
2024-01-27 10:00:15 ERROR API timeout
2024-01-27 10:00:20 INFO Request processed
2024-01-27 10:00:25 ERROR Disk space critical
EOF

# Search for ERROR lines
grep "ERROR" server.log

# Find lines NOT containing INFO
grep -v "INFO" server.log

# Count ERROR occurrences
grep -c "ERROR" server.log
# Output: 3

# Case-insensitive search
grep -i "error" server.log

# Show line numbers
grep -n "ERROR" server.log
# Output:
# 1:2024-01-27 10:00:01 ERROR Database connection failed
# 4:2024-01-27 10:00:15 ERROR API timeout

# Show 2 lines before and after
grep -B2 -A2 "ERROR" server.log
```

**Explanation:** `grep -v` inverts match (excludes), `-c` counts, `-i` ignores case, `-n` shows line numbers, `-B/-A` shows context.

---

## Exercise 3: Text Processing with Sed

**Solution:**

```bash
# Create config file
cat > app.conf << 'EOF'
server.port=8080
server.host=localhost
debug=false
timeout=30
EOF

# Replace port value
sed 's/8080/9000/' app.conf

# Replace in-place
sed -i 's/8080/9000/' app.conf

# Delete a line containing "debug"
sed -i '/debug/d' app.conf

# Insert line after matching pattern
sed -i '/timeout/a database.host=127.0.0.1' app.conf

# Show only matching lines
sed -n '/server/p' app.conf

# Verify changes
cat app.conf
```

**Explanation:**
- `s/old/new/` substitutes first match
- `s/old/new/g` substitutes all matches
- `d` deletes lines
- `i\` inserts before; `a\` appends after
- `-i` modifies file in-place
- `-n` with `p` prints only matched lines

---

## Exercise 4: Process Management

**Solution:**

```bash
# List all processes
ps aux

# Filter Python processes
ps aux | grep python

# Sort by memory usage (descending)
ps aux --sort=-%mem | head -10

# Start background job
sleep 3600 &

# Monitor with watch
watch -n 1 'ps aux | grep sleep'

# Find process by name
pgrep -a sleep

# Kill by name
killall sleep

# Show process tree
pstree -p

# Count total processes
ps aux | wc -l
```

**Explanation:** `ps aux` shows all processes. `--sort=-%mem` sorts by memory descending. `pgrep` finds PID by name. `pstree` shows parent-child relationships.

---

## Exercise 5: Piping and Redirection

**Solution:**

```bash
# Create sample log
cat > app.log << 'EOF'
INFO: Process started
ERROR: Connection failed
WARNING: Timeout detected
ERROR: Database error
INFO: Recovery completed
EOF

# Chain multiple commands
grep "ERROR" app.log | wc -l
# Output: 2

# Redirect stdout and stderr separately
command > output.txt 2> errors.txt

# Redirect both to same file
command > output.txt 2>&1

# Append instead of overwrite
echo "new line" >> output.txt

# Three-command pipeline
cat app.log | grep "ERROR" | cut -d: -f2

# Capture both streams
ls /nonexistent 2>&1 | tee all_output.txt

# Complex example: Count errors by type
grep "ERROR" app.log | cut -d: -f2 | sort | uniq -c
```

**Explanation:**
- `>` overwrites, `>>` appends
- `2>` redirects errors, `2>&1` combines stdout+stderr
- `|` pipes output to next command
- `tee` saves to file AND shows output

---

## Exercise 6: Advanced Grep Patterns

**Solution:**

```bash
# Create data file
cat > data.txt << 'EOF'
Contact: user@example.com
Server IP: 192.168.1.1
Port: 8080
Admin: admin@company.org
Internal IP: 10.0.0.5
EOF

# Find email addresses
grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' data.txt

# Extract IP addresses
grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' data.txt

# Lines starting with specific text
grep "^Server" data.txt

# Lines ending with specific text
grep "\.org$" data.txt

# Words with variable patterns
grep -E "^[A-Z][a-z]+" data.txt

# Complex pattern with extended regex
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' data.txt
```

**Explanation:**
- `-E` enables extended regex
- `^` matches line start, `$` matches end
- `[abc]` matches a, b, or c
- `+` means one or more, `*` means zero or more
- `-o` shows only matched part

---

## Exercise 7: Archiving and Compression

**Solution:**

```bash
# Create files to archive
mkdir -p backup/{docs,scripts}
echo "Document" > backup/docs/report.txt
echo "Script" > backup/scripts/deploy.sh

# Create tar archive
tar -cvf backup.tar backup/

# Create compressed tar.gz
tar -czf backup.tar.gz backup/

# List contents without extracting
tar -tf backup.tar
tar -tzf backup.tar.gz

# Extract to specific directory
mkdir -p restore
tar -xzf backup.tar.gz -C restore/

# Compare sizes
du -sh backup/
du -sh backup.tar
du -sh backup.tar.gz
# Output: original is larger than compressed
```

**Explanation:**
- `tar -cvf` creates uncompressed archive (c=create, v=verbose, f=file)
- `tar -czf` creates gzip compressed (z=gzip)
- `tar -tf` lists contents
- `tar -xf` extracts (x=extract)

---

## Exercise 8: Sorting and Unique Operations

**Solution:**

```bash
# Create inventory
cat > inventory.txt << 'EOF'
apple,10
banana,5
apple,8
orange,3
banana,5
grape,2
EOF

# Sort alphabetically
sort inventory.txt

# Sort by quantity (numeric, reverse)
sort -t',' -k2 -rn inventory.txt

# Remove duplicates
sort -u inventory.txt

# Show only duplicates
sort inventory.txt | uniq -d

# Count occurrences
sort inventory.txt | uniq -c

# Top 5 most frequent items
cat inventory.txt | cut -d',' -f1 | sort | uniq -c | sort -rn | head -5
```

**Explanation:**
- `sort` sorts lines
- `-t','` sets delimiter
- `-k2` sorts by 2nd field
- `-n` numeric sort, `-r` reverse
- `uniq` removes consecutive duplicates (use after sort)
- `uniq -c` counts occurrences

---

## Exercise 9: Cutting and Joining Columns

**Solution:**

```bash
# Create CSV file
cat > users.csv << 'EOF'
id,name,email,department
1,Alice,alice@example.com,Engineering
2,Bob,bob@example.com,Sales
3,Carol,carol@example.com,Engineering
EOF

# Extract name and email columns
cut -d',' -f2,3 users.csv

# Change delimiter (CSV to colon)
cut -d',' -f2,3 users.csv | sed 's/,/:/g'

# Extract by character position
cut -c1-5 users.csv

# Filter specific columns and rows
grep "Engineering" users.csv | cut -d',' -f1,2

# Combine with other processing
cut -d',' -f2,4 users.csv | sort | uniq
```

**Explanation:**
- `cut -d','` sets delimiter
- `-f2,3` selects fields 2 and 3
- `-c1-5` selects characters 1-5
- Can combine with grep, sort, uniq

---

## Exercise 10: Combining Advanced Techniques

**Solution:**

```bash
# Create large log file
cat > app.log << 'EOF'
2024-01-27 10:00:01 INFO Request received
2024-01-27 10:00:02 ERROR Database timeout
2024-01-27 10:00:03 INFO Data processed
2024-01-27 10:00:04 ERROR Connection failed
2024-01-27 10:00:05 WARNING Memory low
2024-01-27 10:00:06 ERROR Database timeout
2024-01-27 10:00:07 INFO Complete
EOF

# Count ERROR entries
grep "ERROR" app.log | wc -l
# Output: 3

# Extract timestamps
grep "ERROR" app.log | cut -d' ' -f1,2

# Find errors with database context
grep -i "database" app.log | grep "ERROR"

# Create error summary
grep "ERROR" app.log | cut -d' ' -f3- | sort | uniq -c | sort -rn

# Top 3 most common errors
grep "ERROR" app.log | cut -d' ' -f4- | cut -d' ' -f1-2 | sort | uniq -c | sort -rn | head -3

# Export results
grep "ERROR" app.log | cut -d' ' -f1,2,4- > error_summary.log
```

**Explanation:** This combines grep for filtering, cut for column extraction, sort for ordering, uniq for deduplication, and pipes to create an analysis pipeline.
