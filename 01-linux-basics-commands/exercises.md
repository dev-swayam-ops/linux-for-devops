# Linux Basics: Exercises

Complete the following exercises to practice fundamental Linux commands.

## Exercise 1: Directory Navigation and Creation

Create the following directory structure in your home directory:

```
projects/
├── webapp/
│   ├── frontend/
│   └── backend/
└── scripts/
```

**Tasks:**
1. Navigate to home directory
2. Create the `projects` directory
3. Create the subdirectories as shown above
4. Display the full directory tree

**Hint:** Use `mkdir -p` to create nested directories.

---

## Exercise 2: File Creation and Viewing

Create three files with the following names and content:

- `project.txt` - Write: "This is my project"
- `config.ini` - Write: "[settings]" and "debug=true" on separate lines
- `data.csv` - Write: "id,name,age" and "1,John,30" on separate lines

**Tasks:**
1. Create all three files
2. Display content of each file
3. Count lines in `data.csv`

**Hint:** Use `echo` with `>` for creation or use text editors like `nano`.

---

## Exercise 3: Copying and Moving Files

**Tasks:**
1. Copy `project.txt` to `project_backup.txt`
2. Move `config.ini` to `config_old.ini`
3. Copy entire `webapp` directory to `webapp_archive`
4. Verify all files exist

---

## Exercise 4: File Permissions

**Tasks:**
1. Create a script file named `deploy.sh` with content: `#!/bin/bash\necho "Deploying..."`
2. Make it executable (add execute permission)
3. View its permissions using `ls -l`
4. Change permissions to read-write for owner only: `chmod 600 deploy.sh`
5. Verify the permission change

---

## Exercise 5: Listing and Searching Files

**Tasks:**
1. List all files in `projects` directory recursively
2. List all files with detailed information (size, date, permissions)
3. Find all `.txt` files in the projects directory
4. List only directories (not files) in projects

**Hint:** Use `ls -R`, `ls -lh`, `find`, and `ls -d`.

---

## Exercise 6: File Content Operations

Create a file named `sample.log` with 10 lines of random content.

**Tasks:**
1. Display the first 3 lines
2. Display the last 3 lines
3. Display all lines containing the word "error" (create some in content)
4. Count total lines
5. Display lines 4-7

**Hint:** Use `head`, `tail`, `grep`, `wc`, and `sed`.

---

## Exercise 7: Working with Text Files

Create a file `inventory.txt` with:
```
apple,5
banana,3
orange,8
mango,2
```

**Tasks:**
1. Display the file content
2. Add a new line: `grape,7`
3. Replace "apple" with "pineapple"
4. Sort the file alphabetically
5. Count total lines

**Hint:** Use `echo >>`, `sed -i`, `sort`, and `wc -l`.

---

## Exercise 8: Understanding File Types

**Tasks:**
1. Create a text file `info.txt`
2. Create a shell script `script.sh`
3. Create a directory `mydir`
4. Create a symbolic link to `info.txt`
5. Use `file` command to identify the type of each

**Hint:** Use `ln -s` for symbolic links.

---

## Exercise 9: Checking Disk Usage and File Sizes

**Tasks:**
1. Check current directory disk usage
2. List files with human-readable sizes (KB, MB, GB)
3. Find the largest file in projects directory
4. Display total size of projects directory
5. Show free disk space on the system

**Hint:** Use `du -sh`, `ls -lh`, `du -ah`, and `df -h`.

---

## Exercise 10: Combining Multiple Commands

Create a file `process.log` with 20 lines of text containing some lines with "WARNING".

**Tasks:**
1. Count total lines
2. Count lines containing "WARNING"
3. Display lines 5-10 that contain "WARNING" (if any)
4. Save all warnings to a new file `warnings.txt`
5. List all files created in this exercise with their sizes

**Hint:** Use pipes `|`, `grep`, `wc -l`, `head`, `tail`, and redirections `>`.
