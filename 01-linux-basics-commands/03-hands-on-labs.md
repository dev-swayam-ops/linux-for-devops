# 03-hands-on-labs.md: Practical Linux Basics Labs

## Lab Overview

These 10 hands-on labs build your practical skills with Linux commands. They're designed to be completed sequentially and include safety features so you can experiment freely.

**Total Time:** 120-150 minutes  
**Difficulty:** Beginner-friendly  
**Prerequisites:** Terminal access, basic reading ability

**Important Safety Notes:**
- ✅ All labs use safe commands that don't damage your system
- ✅ All file operations stay in ~/lab_basics (temporary directory)
- ✅ Every lab includes cleanup steps
- ⚠️ Always read the entire lab before running commands
- ✅ If you make mistakes, just run the cleanup and restart

---

## Lab 1: Navigation and Orientation

### Goal
Get comfortable navigating the filesystem and knowing where you are.

### Steps

**Step 1: Check your current location**
```bash
pwd
```
Record: `________________`

**Step 2: View your home directory**
```bash
echo $HOME
```

**Step 3: Go to your home directory**
```bash
cd ~
pwd
```

**Step 4: Create a lab directory**
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics
pwd
```

**Step 5: List what's in your directory**
```bash
ls -la
```

**Step 6: Create some subdirectories**
```bash
mkdir documents downloads projects
ls -la
```

**Step 7: Navigate around**
```bash
cd documents
pwd
cd ..
pwd
cd ~/lab_basics
```

### Expected Output
```
user@computer:~$ pwd
/home/alice

user@computer:~$ echo $HOME
/home/alice

user@computer:~$ cd ~/lab_basics
user@computer:~/lab_basics$ pwd
/home/alice/lab_basics

user@computer:~/lab_basics$ ls -la
total 12
drwxr-xr-x 5 alice alice 4096 Jan 14 10:30 .
drwxr-xr-x 16 alice alice 4096 Jan 14 10:30 ..
drwxr-xr-x 2 alice alice 4096 Jan 14 10:30 documents
drwxr-xr-x 2 alice alice 4096 Jan 14 10:30 downloads
drwxr-xr-x 2 alice alice 4096 Jan 14 10:30 projects
```

### Verification Checklist
- ☐ Navigated to lab_basics successfully
- ☐ Created three subdirectories
- ☐ Used `pwd` to confirm location
- ☐ Understand current directory vs home directory

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 2: Creating and Viewing Files

### Goal
Create files and view their contents using different methods.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics
```

### Steps

**Step 1: Create empty files**
```bash
touch file1.txt file2.txt
ls -la
```

**Step 2: Add content using echo**
```bash
echo "Hello, Linux!" > greeting.txt
echo "This is a second line" >> greeting.txt
echo "And a third line" >> greeting.txt
```

**Step 3: View the file with cat**
```bash
cat greeting.txt
```

**Step 4: View with line numbers**
```bash
cat -n greeting.txt
```

**Step 5: Show just the first and last lines**
```bash
head -n 1 greeting.txt
tail -n 1 greeting.txt
```

**Step 6: Count contents**
```bash
wc -l greeting.txt
wc -w greeting.txt
wc -c greeting.txt
```

### Expected Output
```
user@computer:~/lab_basics$ cat greeting.txt
Hello, Linux!
This is a second line
And a third line

user@computer:~/lab_basics$ head -n 1 greeting.txt
Hello, Linux!

user@computer:~/lab_basics$ wc -l greeting.txt
3 greeting.txt
```

### Verification Checklist
- ☐ Created three files successfully
- ☐ Viewed file contents with cat
- ☐ Used head and tail
- ☐ Understand file statistics from wc

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 3: Copying, Moving, and Removing Files

### Goal
Practice safe file manipulation with safety options.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics
echo "Original content" > original.txt
```

### Steps

**Step 1: Copy a file**
```bash
cp original.txt copy.txt
ls -la
```

**Step 2: Copy with different name**
```bash
cp copy.txt backup.txt
```

**Step 3: Try to copy over existing (be careful!)**
```bash
cp -i copy.txt backup.txt
# Answer: n (don't overwrite)
```

**Step 4: Move (rename) a file**
```bash
mv backup.txt backup_old.txt
ls -la
```

**Step 5: Move file to different directory**
```bash
mkdir old_files
mv backup_old.txt old_files/
ls -la
ls old_files/
```

**Step 6: Copy directory**
```bash
cp -r old_files old_files_backup
ls -la
```

**Step 7: Delete with confirmation**
```bash
rm -i copy.txt
# Answer: y (yes, delete)
ls -la
```

### Expected Output
```
user@computer:~/lab_basics$ ls -la
total 24
drwxr-xr-x 4 alice alice 4096 Jan 14 10:30 .
...
-rw-r--r-- 1 alice alice 16 Jan 14 10:30 original.txt
drwxr-xr-x 2 alice alice 4096 Jan 14 10:30 old_files
drwxr-xr-x 2 alice alice 4096 Jan 14 10:30 old_files_backup

user@computer:~/lab_basics$ ls old_files/
backup_old.txt
```

### Verification Checklist
- ☐ Copied files successfully
- ☐ Renamed file with mv
- ☐ Used -i option for safety
- ☐ Copied directory with -r
- ☐ Understand the difference between cp and mv

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 4: Understanding Permissions

### Goal
Learn how file permissions work and change them safely.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics
echo "Test content" > myfile.txt
echo "#!/bin/bash" > myscript.sh
echo "echo 'Hello from script'" >> myscript.sh
```

### Steps

**Step 1: View file permissions**
```bash
ls -l
```

Record the permissions:
- myfile.txt: `________________`
- myscript.sh: `________________`

**Step 2: Try to execute the script (probably fails)**
```bash
./myscript.sh
# Should show: Permission denied
```

**Step 3: Make script executable**
```bash
chmod +x myscript.sh
ls -l myscript.sh
./myscript.sh
```

**Step 4: Understand numeric permissions**
```bash
chmod 644 myfile.txt
ls -l myfile.txt
# Should show: -rw-r--r--

chmod 755 myscript.sh
ls -l myscript.sh
# Should show: -rwxr-xr-x

chmod 600 myfile.txt
ls -l myfile.txt
# Should show: -rw-------
```

**Step 5: Create a private file**
```bash
echo "Private data" > secret.txt
chmod 700 secret.txt
ls -l secret.txt
```

**Step 6: Change back to normal**
```bash
chmod 644 secret.txt
ls -l secret.txt
```

### Expected Output
```
user@computer:~/lab_basics$ ls -l
total 12
-rw-r--r-- 1 alice alice 21 Jan 14 10:30 myfile.txt
-rw-r--r-- 1 alice alice 40 Jan 14 10:30 myscript.sh

user@computer:~/lab_basics$ ./myscript.sh
bash: ./myscript.sh: Permission denied

user@computer:~/lab_basics$ chmod +x myscript.sh
user@computer:~/lab_basics$ ./myscript.sh
Hello from script

user@computer:~/lab_basics$ ls -l myscript.sh
-rwxr-xr-x 1 alice alice 40 Jan 14 10:30 myscript.sh
```

### Verification Checklist
- ☐ Understood current permissions
- ☐ Made script executable
- ☐ Script ran successfully
- ☐ Used numeric chmod notation
- ☐ Created and protected a private file

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 5: Searching Text with grep

### Goal
Learn to search for text patterns within files.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics

cat > sample_log.txt << 'EOF'
2025-01-14 10:00:00 INFO: Application started
2025-01-14 10:01:05 DEBUG: Loading configuration
2025-01-14 10:01:10 INFO: Configuration loaded
2025-01-14 10:02:15 ERROR: Connection failed to database
2025-01-14 10:02:20 WARN: Retrying connection
2025-01-14 10:02:25 INFO: Connection established
2025-01-14 10:03:00 ERROR: Invalid user input
2025-01-14 10:04:00 INFO: Processing complete
EOF
```

### Steps

**Step 1: Find lines with ERROR**
```bash
grep "ERROR" sample_log.txt
```

**Step 2: Find lines with error (case-insensitive)**
```bash
grep -i "error" sample_log.txt
```

**Step 3: Find lines NOT containing ERROR**
```bash
grep -v "ERROR" sample_log.txt
```

**Step 4: Find lines and show line numbers**
```bash
grep -n "ERROR" sample_log.txt
```

**Step 5: Count matching lines**
```bash
grep -c "ERROR" sample_log.txt
grep -c "INFO" sample_log.txt
```

**Step 6: Search multiple files**
```bash
echo "ERROR: Something went wrong" > error.txt
grep -r "ERROR" .
```

**Step 7: Show only filenames**
```bash
grep -l "ERROR" *.txt
```

### Expected Output
```
user@computer:~/lab_basics$ grep "ERROR" sample_log.txt
2025-01-14 10:02:15 ERROR: Connection failed to database
2025-01-14 10:03:00 ERROR: Invalid user input

user@computer:~/lab_basics$ grep -c "INFO" sample_log.txt
4

user@computer:~/lab_basics$ grep -l "ERROR" *.txt
error.txt
sample_log.txt
```

### Verification Checklist
- ☐ Found lines with grep
- ☐ Used -i for case-insensitive
- ☐ Used -v to invert
- ☐ Counted occurrences
- ☐ Searched multiple files

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 6: Sorting and Uniquifying

### Goal
Process and organize data using sort and uniq.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics

cat > names.txt << 'EOF'
Charlie
Alice
Bob
Alice
David
Charlie
Eve
Bob
Frank
Charlie
EOF
```

### Steps

**Step 1: View unsorted file**
```bash
cat names.txt
```

**Step 2: Sort alphabetically**
```bash
sort names.txt
```

**Step 3: Sort and remove duplicates**
```bash
sort names.txt | uniq
```

**Step 4: Sort and count occurrences**
```bash
sort names.txt | uniq -c
```

**Step 5: Find which name appears most**
```bash
sort names.txt | uniq -c | sort -rn | head -1
```

**Step 6: Show only duplicates**
```bash
sort names.txt | uniq -d
```

**Step 7: Show only unique names (appearing once)**
```bash
sort names.txt | uniq -u
```

### Expected Output
```
user@computer:~/lab_basics$ sort names.txt
Alice
Alice
Bob
Bob
Charlie
Charlie
Charlie
David
Eve
Frank

user@computer:~/lab_basics$ sort names.txt | uniq -c
      2 Alice
      2 Bob
      3 Charlie
      1 David
      1 Eve
      1 Frank

user@computer:~/lab_basics$ sort names.txt | uniq -d
Alice
Bob
Charlie
```

### Verification Checklist
- ☐ Sorted data successfully
- ☐ Removed duplicates
- ☐ Counted occurrences
- ☐ Found most frequent item
- ☐ Identified duplicate names

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 7: Finding Files

### Goal
Learn to search for files using find and understand globbing.

### Setup
```bash
mkdir -p ~/lab_basics/documents/old
mkdir -p ~/lab_basics/downloads
mkdir -p ~/lab_basics/projects

cd ~/lab_basics
touch documents/report.txt
touch documents/summary.txt
touch documents/old/archive.txt
touch downloads/image.jpg
touch downloads/video.mp4
touch projects/script.sh
touch projects/script.py
touch projects/README.md
```

### Steps

**Step 1: List all files (globbing)**
```bash
ls *.txt
ls documents/*.txt
ls **/*.txt  # Might not work, shows why find is better
```

**Step 2: Find all files**
```bash
find . -type f
```

**Step 3: Find specific file type**
```bash
find . -name "*.txt"
find . -name "*.py"
find . -name "*.md"
```

**Step 4: Find directories**
```bash
find . -type d
```

**Step 5: Find files modified today**
```bash
find . -type f -mtime 0
```

**Step 6: Combine multiple criteria**
```bash
find . -type f -name "*.txt" -o -name "*.md"
```

**Step 7: Execute command on found files**
```bash
find . -name "*.txt" -exec wc -l {} \;
```

### Expected Output
```
user@computer:~/lab_basics$ find . -name "*.txt"
./documents/report.txt
./documents/summary.txt
./documents/old/archive.txt

user@computer:~/lab_basics$ find . -type d
.
./documents
./documents/old
./downloads
./projects

user@computer:~/lab_basics$ find . -type f | wc -l
8
```

### Verification Checklist
- ☐ Used globbing patterns
- ☐ Found files by name
- ☐ Found files by type
- ☐ Filtered by modification time
- ☐ Executed commands on results

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 8: Piping and Redirection

### Goal
Chain commands together and redirect output.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics

cat > people.txt << 'EOF'
Alice:Engineer
Bob:Manager
Charlie:Engineer
David:Designer
Eve:Engineer
Frank:Manager
EOF
```

### Steps

**Step 1: Redirect output to file**
```bash
cat people.txt > people_backup.txt
cat people_backup.txt
```

**Step 2: Append to file**
```bash
echo "Grace:Engineer" >> people_backup.txt
cat people_backup.txt
```

**Step 3: Pipe output to another command**
```bash
cat people.txt | grep "Engineer"
```

**Step 4: Chain multiple commands**
```bash
cat people.txt | grep "Engineer" | wc -l
```

**Step 5: Count lines and save to file**
```bash
cat people.txt | wc -l > count.txt
cat count.txt
```

**Step 6: Complex pipeline**
```bash
cat people.txt | cut -d: -f2 | sort | uniq -c
```

**Step 7: Redirect errors**
```bash
ls /nonexistent 2> error.txt
cat error.txt
```

### Expected Output
```
user@computer:~/lab_basics$ cat people.txt | grep "Engineer"
Alice:Engineer
Charlie:Engineer
Eve:Engineer

user@computer:~/lab_basics$ cat people.txt | cut -d: -f2 | sort | uniq -c
      2 Designer
      3 Engineer
      2 Manager
```

### Verification Checklist
- ☐ Redirected output to file
- ☐ Appended to file
- ☐ Piped commands together
- ☐ Chained multiple commands
- ☐ Saved counts to file
- ☐ Redirected errors

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 9: Text Processing with cut and awk

### Goal
Extract specific columns from structured data.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics

cat > users.txt << 'EOF'
alice:1001:Alice Smith:Engineer
bob:1002:Bob Johnson:Manager
charlie:1003:Charlie Brown:Designer
david:1004:David Lee:Engineer
eve:1005:Eve Davis:Manager
EOF
```

### Steps

**Step 1: Extract first field (colon-separated)**
```bash
cut -d: -f1 users.txt
```

**Step 2: Extract name and job**
```bash
cut -d: -f3,4 users.txt
```

**Step 3: Extract with different separator**
```bash
echo "Name,Age,City" | cut -d, -f1,3
```

**Step 4: Use awk to print first field**
```bash
awk -F: '{print $1}' users.txt
```

**Step 5: Use awk to print multiple fields**
```bash
awk -F: '{print $1 " -> " $3}' users.txt
```

**Step 6: Count fields**
```bash
awk -F: '{print NF}' users.txt | head -1
```

**Step 7: Filter and print**
```bash
awk -F: '$4 == "Engineer" {print $1, $3}' users.txt
```

### Expected Output
```
user@computer:~/lab_basics$ cut -d: -f1 users.txt
alice
bob
charlie
david
eve

user@computer:~/lab_basics$ awk -F: '{print $1 " -> " $3}' users.txt
alice -> Alice Smith
bob -> Bob Johnson
charlie -> Charlie Brown
david -> David Lee
eve -> Eve Davis

user@computer:~/lab_basics$ awk -F: '$4 == "Engineer" {print $1, $3}' users.txt
alice Alice Smith
david David Lee
```

### Verification Checklist
- ☐ Extracted fields with cut
- ☐ Changed field separator
- ☐ Used awk to process text
- ☐ Filtered and formatted output
- ☐ Combined fields with awk

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Lab 10: Combining Everything

### Goal
Use multiple commands together to solve a real-world problem.

### Setup
```bash
mkdir -p ~/lab_basics
cd ~/lab_basics

cat > web_access.log << 'EOF'
192.168.1.100 - - [14/Jan/2025:10:00:00] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - - [14/Jan/2025:10:01:05] "GET /about.html HTTP/1.1" 200 5678
192.168.1.100 - - [14/Jan/2025:10:02:10] "GET /contact.html HTTP/1.1" 404 0
192.168.1.102 - - [14/Jan/2025:10:03:15] "POST /login HTTP/1.1" 200 890
192.168.1.101 - - [14/Jan/2025:10:04:20] "GET /index.html HTTP/1.1" 200 1234
192.168.1.100 - - [14/Jan/2025:10:05:25] "GET /products.html HTTP/1.1" 200 3456
192.168.1.103 - - [14/Jan/2025:10:06:30] "GET /services.html HTTP/1.1" 200 2345
192.168.1.102 - - [14/Jan/2025:10:07:35] "GET /index.html HTTP/1.1" 200 1234
EOF
```

### Scenario: Analyze Web Server Logs

**Task 1: Find all 404 errors**
```bash
grep "404" web_access.log
```

**Task 2: Count total requests per IP**
```bash
cut -d' ' -f1 web_access.log | sort | uniq -c
```

**Task 3: List unique IPs**
```bash
cut -d' ' -f1 web_access.log | sort -u
```

**Task 4: Find successful requests (200 status)**
```bash
grep " 200 " web_access.log | wc -l
```

**Task 5: Show most active IP**
```bash
cut -d' ' -f1 web_access.log | sort | uniq -c | sort -rn | head -1
```

**Task 6: Extract and count files accessed**
```bash
grep "GET\|POST" web_access.log | \
  awk '{print $7}' | \
  cut -d'/' -f2 | \
  sort | uniq -c | sort -rn
```

**Task 7: Create a report**
```bash
{
  echo "=== Web Access Log Report ==="
  echo "Total requests: $(wc -l < web_access.log)"
  echo "Total errors: $(grep -c '404\|500' web_access.log)"
  echo "Unique IPs: $(cut -d' ' -f1 web_access.log | sort -u | wc -l)"
  echo "=== Top IPs ==="
  cut -d' ' -f1 web_access.log | sort | uniq -c | sort -rn | head -3
} > report.txt

cat report.txt
```

### Expected Output
```
=== Web Access Log Report ===
Total requests: 8
Total errors: 1
Unique IPs: 3
=== Top IPs ===
      3 192.168.1.100
      2 192.168.1.101
      2 192.168.1.102
```

### Verification Checklist
- ☐ Found error patterns
- ☐ Counted requests per IP
- ☐ Identified most active IP
- ☐ Created summary report
- ☐ Chained multiple commands effectively

### Cleanup
```bash
cd ~
rm -r lab_basics
```

---

## Summary of Skills Learned

After completing all labs, you now know:

✅ Navigate the filesystem confidently
✅ Create, view, and manipulate files safely
✅ Understand and change permissions
✅ Search for text and files
✅ Process and organize data
✅ Chain commands for powerful results
✅ Extract and analyze information
✅ Solve real-world problems

---

## Troubleshooting Lab Issues

| Issue | Solution |
|-------|----------|
| "Permission denied" | Use `chmod +x` to make executable |
| "File not found" | Check current directory with `pwd`, use correct path |
| "Command not found" | Make sure command is spelled correctly |
| "No matches found" | Wildcard pattern might not match, check with `ls` |
| Deleted wrong file | Check if it's in trash or use `find` to look |

---

**Next:** Review the [scripts/](scripts/) folder for automation tools you can build on these skills.

**Tip:** These labs are repeatable. Run them again to reinforce learning!
