# Linux Basics: Solutions

## Exercise 1: Directory Navigation and Creation

**Solution:**

```bash
# Navigate to home directory
cd ~

# Create main directory
mkdir projects

# Create subdirectories
mkdir -p projects/webapp/frontend
mkdir -p projects/webapp/backend
mkdir -p projects/scripts

# Verify structure
tree projects
# or use
ls -R projects
```

**Explanation:** `mkdir -p` creates parent directories automatically, making nested structure creation simpler.

---

## Exercise 2: File Creation and Viewing

**Solution:**

```bash
# Create project.txt
echo "This is my project" > project.txt

# Create config.ini
echo -e "[settings]\ndebug=true" > config.ini

# Create data.csv
echo -e "id,name,age\n1,John,30" > data.csv

# View files
cat project.txt
cat config.ini
cat data.csv

# Count lines in data.csv
wc -l data.csv
```

**Explanation:** `echo -e` enables interpretation of backslash escapes like `\n` for newlines. `wc -l` counts lines in a file.

---

## Exercise 3: Copying and Moving Files

**Solution:**

```bash
# Copy single file
cp project.txt project_backup.txt

# Move (rename) file
mv config.ini config_old.ini

# Copy entire directory
cp -r webapp webapp_archive

# Verify all exist
ls -la
ls -la projects/
```

**Explanation:** `cp -r` recursively copies directories and their contents. `mv` can rename or move files.

---

## Exercise 4: File Permissions

**Solution:**

```bash
# Create script file
echo -e "#!/bin/bash\necho \"Deploying...\"" > deploy.sh

# Make it executable
chmod +x deploy.sh

# View permissions
ls -l deploy.sh
# Output: -rwxr-xr-x 1 user user 29 Jan 27 10:00 deploy.sh

# Change to read-write for owner only
chmod 600 deploy.sh

# Verify change
ls -l deploy.sh
# Output: -rw------- 1 user user 29 Jan 27 10:00 deploy.sh
```

**Explanation:** 
- `chmod +x` adds execute permission for all
- `chmod 600` sets permissions to: owner read+write (6), group no access (0), others no access (0)

---

## Exercise 5: Listing and Searching Files

**Solution:**

```bash
# List all files recursively with details
ls -lR projects

# List with human-readable sizes
ls -lh projects

# Find all .txt files
find projects -name "*.txt"

# List only directories
ls -d projects/*/
```

**Explanation:**
- `ls -R` shows recursive listing
- `find -name` pattern matches files
- `ls -d` lists directory entries, not their contents

---

## Exercise 6: File Content Operations

**Solution:**

```bash
# Create sample.log with 10 lines
cat > sample.log << 'EOF'
Starting process
Processing data
Error in line 1
Continuing execution
Data processed successfully
Warning: low memory
Final check
Error in database
Completed successfully
All systems operational
EOF

# Display first 3 lines
head -3 sample.log

# Display last 3 lines
tail -3 sample.log

# Find lines with "error"
grep -i "error" sample.log

# Count total lines
wc -l sample.log

# Display lines 4-7
sed -n '4,7p' sample.log
```

**Explanation:**
- `head -n` shows first n lines
- `tail -n` shows last n lines
- `grep -i` searches case-insensitively
- `sed -n 'X,Yp'` prints lines X through Y

---

## Exercise 7: Working with Text Files

**Solution:**

```bash
# Create inventory.txt
cat > inventory.txt << 'EOF'
apple,5
banana,3
orange,8
mango,2
EOF

# Display file
cat inventory.txt

# Add new line
echo "grape,7" >> inventory.txt

# Replace "apple" with "pineapple"
sed -i 's/apple/pineapple/' inventory.txt

# Sort alphabetically
sort inventory.txt

# Count lines
wc -l inventory.txt
# Output: 5 inventory.txt
```

**Explanation:**
- `>>` appends to file (vs `>` overwrites)
- `sed -i` edits file in-place
- `sort` sorts lines alphabetically

---

## Exercise 8: Understanding File Types

**Solution:**

```bash
# Create text file
echo "Information file" > info.txt

# Create shell script
echo -e "#!/bin/bash\necho 'Hello'" > script.sh

# Create directory
mkdir mydir

# Create symbolic link
ln -s info.txt link_to_info.txt

# Check file types
file info.txt
# Output: ASCII text

file script.sh
# Output: Bourne-Again shell script

file mydir
# Output: directory

file link_to_info.txt
# Output: symbolic link to info.txt
```

**Explanation:** The `file` command identifies file types by examining file content and structure.

---

## Exercise 9: Checking Disk Usage and File Sizes

**Solution:**

```bash
# Current directory disk usage (summary)
du -sh .

# List files with human-readable sizes
ls -lh projects/

# Find largest file in projects
find projects -type f -exec ls -lh {} \; | sort -k5 -h | tail -1

# Total size of projects directory
du -sh projects/

# Free disk space
df -h

# Alternative: show disk usage in descending order
du -ah projects/ | sort -rh | head -5
```

**Explanation:**
- `du -sh` shows total size (s = summary, h = human-readable)
- `ls -lh` shows file sizes in human format
- `df -h` shows filesystem usage
- `sort -rh` sorts by human-readable numbers in reverse

---

## Exercise 10: Combining Multiple Commands

**Solution:**

```bash
# Create process.log with warnings
cat > process.log << 'EOF'
Line 1: Starting
Line 2: Processing
Line 3: WARNING - Check memory
Line 4: Continuing
Line 5: Processing data
Line 6: WARNING - Slow response
Line 7: Ongoing task
Line 8: Verification
Line 9: WARNING - Timeout detected
Line 10: Recovery started
Line 11: System check
Line 12: WARNING - Low disk space
Line 13: Final processing
Line 14: Cleanup
Line 15: WARNING - Cache cleared
Line 16: Optimization
Line 17: Testing
Line 18: WARNING - Minor issues
Line 19: Completion
Line 20: Done
EOF

# Count total lines
wc -l process.log
# Output: 20 process.log

# Count WARNING lines
grep "WARNING" process.log | wc -l
# Output: 5

# Display lines with WARNING (lines 5-10 that contain WARNING)
sed -n '5,10p' process.log | grep "WARNING"

# Save all warnings to file
grep "WARNING" process.log > warnings.txt

# List all files with sizes
ls -lh *.log *.txt | awk '{print $9, $5}'
```

**Explanation:**
- `grep "pattern" file | wc -l` counts matching lines
- `sed -n 'X,Yp'` extracts range, then pipe to `grep`
- `>` redirects output to new file
- `awk '{print $9, $5}'` prints specific columns (filename and size)
