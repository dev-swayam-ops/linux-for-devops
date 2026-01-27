# Linux Advanced Commands: Cheatsheet

## Find Command

| Option | Purpose | Example |
|--------|---------|---------|
| `find /path -name` | Search by filename | `find . -name "*.txt"` |
| `find -type f` | Find files only | `find . -type f` |
| `find -type d` | Find directories only | `find . -type d` |
| `find -type l` | Find symbolic links | `find . -type l` |
| `find -mtime -7` | Modified within 7 days | `find . -mtime -7` |
| `find -size +1M` | Larger than 1MB | `find . -size +1M` |
| `find -user` | Files owned by user | `find . -user username` |
| `find -exec` | Execute command on match | `find . -name "*.log" -exec rm {} \;` |
| `find -delete` | Delete found files | `find . -name "*.tmp" -delete` |

## Grep - Pattern Matching

| Option | Purpose | Example |
|--------|---------|---------|
| `grep pattern file` | Search for pattern | `grep "error" log.txt` |
| `grep -i` | Case-insensitive | `grep -i "ERROR" file.txt` |
| `grep -v` | Invert match (exclude) | `grep -v "INFO" log.txt` |
| `grep -c` | Count matches | `grep -c "error" log.txt` |
| `grep -n` | Show line numbers | `grep -n "error" log.txt` |
| `grep -B2` | Show 2 lines before | `grep -B2 "error" file.txt` |
| `grep -A3` | Show 3 lines after | `grep -A3 "error" file.txt` |
| `grep -l` | Show only filenames | `grep -l "error" *.log` |
| `grep -E` | Extended regex | `grep -E '[0-9]{3}' file.txt` |
| `grep -o` | Show only matches | `grep -oE '[a-z]+' file.txt` |

## Sed - Stream Editor

| Option | Purpose | Example |
|--------|---------|---------|
| `sed 's/old/new/'` | Substitute first match | `sed 's/foo/bar/' file.txt` |
| `sed 's/old/new/g'` | Substitute all matches | `sed 's/foo/bar/g' file.txt` |
| `sed -i` | Edit file in-place | `sed -i 's/foo/bar/' file.txt` |
| `sed 'd'` | Delete lines | `sed '/pattern/d' file.txt` |
| `sed 'Xd'` | Delete specific line | `sed '5d' file.txt` |
| `sed 'a\text'` | Append after line | `sed '/pattern/a\newline' file.txt` |
| `sed 'i\text'` | Insert before line | `sed '/pattern/i\newline' file.txt` |
| `sed -n 'p'` | Print specific lines | `sed -n '5,10p' file.txt` |

## Process Management

| Command | Purpose | Example |
|---------|---------|---------|
| `ps aux` | List all processes | `ps aux` |
| `ps -ef` | Full format listing | `ps -ef` |
| `ps aux --sort=%mem` | Sort by memory | `ps aux --sort=-%mem` |
| `pgrep` | Find PID by name | `pgrep python` |
| `pgrep -a` | Find with full command | `pgrep -a python` |
| `pstree` | Show process tree | `pstree -p` |
| `top` | Real-time processes | `top` |
| `htop` | Interactive process viewer | `htop` |
| `jobs` | List background jobs | `jobs` |
| `bg` | Resume job in background | `bg %1` |
| `fg` | Bring to foreground | `fg %1` |
| `kill PID` | Terminate process | `kill 1234` |
| `kill -9` | Force kill | `kill -9 1234` |
| `killall name` | Kill by name | `killall python` |

## Pipes and Redirection

| Symbol | Purpose | Example |
|--------|---------|---------|
| `\|` | Pipe to next command | `cat file.txt \| grep "error"` |
| `>` | Redirect to file (overwrite) | `echo "text" > file.txt` |
| `>>` | Append to file | `echo "text" >> file.txt` |
| `2>` | Redirect stderr | `command 2> errors.txt` |
| `2>&1` | Redirect stderr to stdout | `command > output.txt 2>&1` |
| `&>` | Redirect all to file | `command &> output.txt` |
| `<` | Input from file | `grep "pattern" < file.txt` |
| `tee` | Save and display | `command \| tee output.txt` |

## Sorting and Unique

| Command | Purpose | Example |
|---------|---------|---------|
| `sort` | Sort lines alphabetically | `sort file.txt` |
| `sort -n` | Numeric sort | `sort -n numbers.txt` |
| `sort -r` | Reverse sort | `sort -r file.txt` |
| `sort -t',' -k2` | Sort by field 2 (delimited) | `sort -t',' -k2 data.csv` |
| `sort -u` | Sort and remove duplicates | `sort -u file.txt` |
| `uniq` | Remove consecutive duplicates | `sort file.txt \| uniq` |
| `uniq -c` | Count occurrences | `sort file.txt \| uniq -c` |
| `uniq -d` | Show only duplicates | `sort file.txt \| uniq -d` |

## Cutting and Extracting

| Command | Purpose | Example |
|---------|---------|---------|
| `cut -d',' -f1` | Extract field 1 (CSV) | `cut -d',' -f1,3 data.csv` |
| `cut -c1-5` | Extract characters 1-5 | `cut -c1-10 file.txt` |
| `cut -d: -f1` | Extract by delimiter | `cut -d: -f1 /etc/passwd` |
| `awk '{print $1}'` | Extract column 1 | `awk '{print $1}' file.txt` |
| `awk -F,` | Set field separator | `awk -F, '{print $2}' file.csv` |

## Compression and Archives

| Command | Purpose | Example |
|---------|---------|---------|
| `tar -cvf` | Create archive | `tar -cvf backup.tar dir/` |
| `tar -czf` | Create gzip archive | `tar -czf backup.tar.gz dir/` |
| `tar -tf` | List archive contents | `tar -tf backup.tar` |
| `tar -xf` | Extract archive | `tar -xf backup.tar` |
| `tar -xzf` | Extract gzip archive | `tar -xzf backup.tar.gz` |
| `tar -C` | Extract to directory | `tar -xzf backup.tar.gz -C /path` |
| `gzip file` | Compress file | `gzip largefile.txt` |
| `gunzip file.gz` | Decompress | `gunzip file.gz` |
| `zip -r` | Create zip archive | `zip -r backup.zip dir/` |
| `unzip` | Extract zip | `unzip backup.zip` |

## Regular Expressions (Extended)

| Pattern | Matches | Example |
|---------|---------|---------|
| `.` | Any character | `g.t` matches "got", "git" |
| `*` | Zero or more | `a*b` matches "b", "ab", "aab" |
| `+` | One or more | `a+` matches "a", "aa", "aaa" |
| `?` | Zero or one | `colou?r` matches "color", "colour" |
| `^` | Start of line | `^ERROR` matches "ERROR" at start |
| `$` | End of line | `error$` matches line ending with "error" |
| `[abc]` | Any of a, b, c | `[0-9]` matches any digit |
| `[a-z]` | Range a to z | `[A-Z]` matches uppercase letters |
| `[^abc]` | Not a, b, or c | `[^0-9]` matches non-digits |
| `(abc)` | Group | `(cat\|dog)` matches "cat" or "dog" |
| `\|` | OR operator | `cat\|dog` matches "cat" or "dog" |

## Text Processing Comparison

| Use Case | Command |
|----------|---------|
| Find and replace text | `sed 's/old/new/g'` |
| Filter lines | `grep pattern` |
| Extract columns | `cut -d',' -f2` |
| Sort and count | `sort \| uniq -c` |
| Transform lines | `awk '{print $1, $3}'` |
| Search files | `find . -name "*.txt"` |
