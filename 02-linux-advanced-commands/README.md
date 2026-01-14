# Module 02: Linux Advanced Commands

## 🎯 Overview

Advanced command-line tools are the backbone of Linux system administration, DevOps automation, and data processing. This module teaches you to manipulate, search, and analyze data using powerful text processing utilities like `grep`, `sed`, `awk`, and `cut`. Master these tools and you'll become exponentially more productive in daily Linux work.

### Why This Matters

**Real-World Applications:**
- **Log Analysis**: Parse and analyze server logs (Apache, Nginx, syslog)
- **Data Processing**: Extract, transform, and filter structured data (CSV, JSON, logs)
- **System Administration**: Batch file modifications, permission audits, system reports
- **DevOps Automation**: Parse configuration files, validate outputs, automate workflows
- **Security**: Search for patterns in logs, detect anomalies, audit system files
- **Development**: Process text files, generate reports, automate testing

**Career Impact:**
- 90% of Linux tasks involve text processing and searching
- Essential for junior to senior SysAdmin/DevOps roles
- Foundation for writing production-grade bash scripts
- Critical for system troubleshooting and debugging

---

## 📋 Prerequisites

### Required Knowledge
- ✅ Module 01: Linux Basics Commands (file navigation, permissions, basic commands)
- ✅ Comfortable with terminal and basic shell usage
- ✅ Understanding of file structure and paths
- ✅ Basic understanding of file permissions

### System Requirements
- **OS**: Ubuntu 20.04+ / CentOS 8+ / Debian 10+
- **Tools**: bash, grep, sed, awk, cut, sort, uniq, find, xargs
- **Environment**: Terminal access (local VM, SSH, or WSL2)
- **Storage**: 500 MB free space for labs
- **Time**: 6-8 hours total (theory + hands-on practice)

### Recommended Setup
```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install build-essential gawk mawk sed grep

# For CentOS/RHEL
sudo yum install -y gawk sed grep
```

---

## 🎓 Learning Objectives

After completing this module, you will be able to:

### Core Competencies (Beginner+)
- [ ] Use `grep` with regular expressions to search text patterns
- [ ] Apply `cut` to extract specific columns from structured data
- [ ] Use `awk` to process and transform text data
- [ ] Apply `sort` and `uniq` for data aggregation
- [ ] Chain commands with pipes to solve complex problems

### Intermediate Skills
- [ ] Write `sed` scripts for text substitution and deletion
- [ ] Create advanced `find` queries with multiple conditions
- [ ] Use `xargs` to process multiple files efficiently
- [ ] Work with file comparison tools (`diff`, `comm`)
- [ ] Debug and optimize text processing pipelines

### Advanced Applications
- [ ] Parse server logs for troubleshooting
- [ ] Extract data from config files automatically
- [ ] Generate reports from structured data
- [ ] Validate and clean messy data
- [ ] Automate system administration tasks

### Real-World Scenarios
- [ ] Analyze Apache/Nginx access logs
- [ ] Extract fields from CSV and JSON data
- [ ] Find and bulk modify text in multiple files
- [ ] Generate system audit reports
- [ ] Process backup and log rotation data

---

## 📚 Module Roadmap

This module is organized as follows:

```
02-linux-advanced-commands/
├── README.md                    ← You are here
├── 01-theory.md                 ← Conceptual foundations (30 min)
├── 02-commands-cheatsheet.md    ← Command reference (reference)
├── 03-hands-on-labs.md          ← Practical exercises (4-6 hours)
└── scripts/
    ├── log-analyzer.sh          ← Parse and analyze logs
    ├── data-processor.sh        ← Transform and extract data
    └── README.md                ← Script documentation
```

### How to Use This Module

1. **Start with Theory** (30 minutes)
   - Read [01-theory.md](01-theory.md) for conceptual understanding
   - Review ASCII diagrams and mental models
   - Understand the "why" behind each tool

2. **Reference While Practicing** (as needed)
   - Keep [02-commands-cheatsheet.md](02-commands-cheatsheet.md) open while working
   - Look up command syntax and examples
   - Copy-paste examples to experiment

3. **Do the Hands-On Labs** (4-6 hours)
   - Follow [03-hands-on-labs.md](03-hands-on-labs.md) in order
   - Start with simple labs, progress to complex
   - Use the provided setup scripts
   - Verify expected output after each step

4. **Explore the Scripts** (30 minutes)
   - Review [scripts/README.md](scripts/README.md)
   - Run log-analyzer.sh and data-processor.sh
   - Understand how to integrate tools

5. **Practice and Apply** (ongoing)
   - Solve real problems using these tools
   - Process actual log files or data
   - Create your own text processing pipelines
   - Share solutions with others

---

## 📖 Quick Glossary

### Essential Terms

| Term | Definition |
|------|-----------|
| **grep** | Global search with regular expression and print - search text for patterns |
| **sed** | Stream editor - apply transformations to text in a pipeline |
| **awk** | Pattern scanning and processing language - powerful text processing |
| **cut** | Remove sections from each line - extract columns from data |
| **pipe** | `\|` - connect command output to another command's input |
| **regex** | Regular expression - pattern language for matching text |
| **escape** | `\` - remove special meaning from next character |
| **field** | Column in structured data (CSV, logs, etc.) |
| **delimiter** | Character separating fields (comma, space, colon, etc.) |
| **stream** | Continuous flow of data from command or file |
| **STDIN** | Standard input - data fed to a command |
| **STDOUT** | Standard output - data printed by a command |
| **anchor** | `^` (start of line) or `$` (end of line) in regex |
| **quantifier** | `*`, `+`, `?`, `{}` - specify repetition in regex |
| **character class** | `[abc]` or `[a-z]` - match any character in bracket |
| **lookahead** | `(?=pattern)` - assert what follows without matching |
| **lookahead** | `(?!pattern)` - assert what doesn't follow without matching |
| **capture group** | `(pattern)` - group matched text for reference |
| **substitution** | Replace one pattern with another text |
| **backreference** | `\1`, `\2` - refer to captured groups in replacement |

---

## 🔄 Common Workflows

### Workflow 1: Log Analysis
```bash
# Parse Apache access log
grep "404" /var/log/apache2/access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -5
# Shows: Top 5 IPs with 404 errors
```

### Workflow 2: Data Extraction
```bash
# Extract usernames and IDs from /etc/passwd
awk -F: '{print $1, $3}' /etc/passwd | grep -v "^_" | sort
# Shows: username and UID sorted
```

### Workflow 3: Configuration Processing
```bash
# Find all IP addresses in config files
grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' *.conf | cut -d: -f2 | sort -u
# Shows: Unique IP addresses across config files
```

### Workflow 4: Bulk Text Replacement
```bash
# Replace all occurrences across files
sed -i.bak 's/old.domain/new.domain/g' *.conf
# Makes changes in place, keeping backup with .bak extension
```

### Workflow 5: File Comparison and Sync
```bash
# Find files in dir1 but not in dir2
comm -23 <(ls dir1 | sort) <(ls dir2 | sort)
# Shows: Files unique to dir1
```

---

## ⏱️ Time Breakdown

| Phase | Duration | Content |
|-------|----------|---------|
| **Theory** | 30 min | Conceptual foundations, ASCII diagrams |
| **Commands Intro** | 20 min | Basic usage of each tool |
| **Lab 1-3** | 45 min | Simple grep, cut, sort exercises |
| **Lab 4-6** | 90 min | sed, awk, xargs intermediate exercises |
| **Lab 7-8** | 90 min | Complex multi-command pipelines |
| **Scripts Exploration** | 30 min | Understanding and running production scripts |
| **Practice & Review** | 60 min | Revisit labs, create own examples |
| **TOTAL** | **6-8 hours** | Complete mastery |

---

## 🔒 Safety and Best Practices

### Important Rules

🚫 **DO NOT:**
- Run commands on production systems without testing first
- Use `sed -i` without creating backups (always use `sed -i.bak`)
- Forget to test regex patterns before applying to large files
- Assume file format won't change (validate with `head`, `file`, `wc`)
- Pipe to `rm` without absolute certainty

✅ **DO:**
- Test commands on small sample files first
- Use `--dry-run` or preview modes when available
- Create backups before batch operations
- Verify patterns match expected data
- Use version control for important configurations
- Document complex pipelines with comments

### Lab Safety

All labs use a sandboxed directory: `~/advanced-labs/`

```bash
# Create sandbox
mkdir -p ~/advanced-labs
cd ~/advanced-labs

# All work happens here - safe from system files
```

### Backup Practice

```bash
# Always backup before sed -i
cp important-file.conf important-file.conf.bak

# Or use sed with auto-backup
sed -i.backup 's/old/new/g' file.conf

# Or test with sed (no -i) first
sed 's/old/new/g' file.conf | head -5  # Preview changes
```

---

## 🎯 Key Concepts at a Glance

### The Data Processing Pipeline

```
Input File/Stream
       ↓
   grep (filter)
       ↓
    cut/awk (extract)
       ↓
   sort/uniq (aggregate)
       ↓
   sed/awk (transform)
       ↓
   Output/Action
```

### Why Each Tool Exists

| Tool | Strength | Best For |
|------|----------|----------|
| **grep** | Pattern matching | Finding lines that match |
| **cut** | Simple extraction | Fixed-column data (CSV, logs) |
| **awk** | Flexible processing | Complex multi-step transformations |
| **sed** | Stream editing | In-place text replacement |
| **sort** | Organizing | Ordering and grouping data |
| **uniq** | Deduplication | Finding unique/duplicate values |
| **find** | File location | Locating files with complex criteria |
| **xargs** | Batch processing | Running commands on multiple results |

### Mental Model: The Unix Philosophy

Each tool does ONE thing well:
- **grep** = filter ✓
- **cut** = extract ✓
- **awk** = transform ✓
- **sed** = substitute ✓

Chain them together to solve complex problems.

---

## 📚 Command Quick Reference

| Command | What It Does | Example |
|---------|-------------|---------|
| `grep` | Search for text patterns | `grep ERROR logfile.txt` |
| `grep -E` | Use extended regex | `grep -E "^error:\|^warn:"` |
| `cut` | Extract columns | `cut -d: -f1,3 /etc/passwd` |
| `awk` | Process structured data | `awk -F: '{print $1}'` |
| `sed` | Stream edit/substitute | `sed 's/old/new/g'` |
| `sort` | Sort lines | `sort -t: -k3 -n` (sort by 3rd field) |
| `uniq` | Remove duplicates | `uniq -c -d` (show duplicates with count) |
| `find` | Locate files | `find . -name "*.log" -mtime +7` |
| `xargs` | Pass results as args | `find . -name "*.tmp" \| xargs rm` |
| `tr` | Translate characters | `tr 'a-z' 'A-Z'` (uppercase) |
| `diff` | Compare files | `diff file1 file2` |
| `comm` | Compare sorted files | `comm file1 file2` |
| `paste` | Merge lines | `paste file1 file2` |

---

## 🚀 Getting Started

### Step 1: Verify Prerequisites
```bash
# Check you have required tools
which grep sed awk cut sort find
# All should return paths like /bin/grep, /bin/sed, etc.
```

### Step 2: Create Lab Environment
```bash
# Make a safe working directory
mkdir -p ~/advanced-labs
cd ~/advanced-labs

# Verify you're in right place
pwd
# Should show: /home/username/advanced-labs
```

### Step 3: Read Theory
```bash
# Open the theory document
cat ../01-theory.md | less

# Or: less ../01-theory.md
```

### Step 4: Start with Lab 1
```bash
# Instructions in 03-hands-on-labs.md
# Follow Lab 1: Basic grep patterns
```

---

## 📖 How to Navigate Each File

### 01-theory.md
- **Purpose**: Understand WHY and HOW
- **Read**: Start to finish, but skim code examples first
- **Use**: Reference ASCII diagrams when confused
- **Time**: 25-30 minutes

### 02-commands-cheatsheet.md
- **Purpose**: Quick lookup reference
- **Read**: Skim categories, read as needed during labs
- **Use**: Keep open while working, copy-paste examples
- **Time**: Reference only (don't memorize)

### 03-hands-on-labs.md
- **Purpose**: Hands-on practice and mastery
- **Read**: One lab at a time
- **Do**: Complete setup → steps → verification
- **Use**: Follow exactly, then experiment
- **Time**: 4-6 hours total

### scripts/
- **Purpose**: See how tools combine in real code
- **Read**: After completing labs 1-4
- **Use**: Run on real data, modify for your needs
- **Time**: 30 minutes

---

## ✅ Success Criteria

You'll know you've mastered this module when you can:

- [ ] Write a `grep` command with regex to find specific patterns
- [ ] Use `awk` to extract and calculate on structured data
- [ ] Create a `sed` script to perform bulk text replacements
- [ ] Combine multiple commands with pipes to solve real problems
- [ ] Analyze a real log file and extract actionable insights
- [ ] Optimize a slow pipeline by choosing the right tool
- [ ] Debug a text processing command by testing pieces separately
- [ ] Write a bash script combining these tools for automation

---

## 🔄 Progression Path

### After This Module
- ✅ Ready for: Module 03 (Crontab & Scheduling)
- ✅ Ready for: Module 16 (Shell Scripting Basics)
- ✅ Ready for: Module 13 (Logging & Monitoring)
- ✅ Foundation for: DevOps automation scripts

### Building on Module 01
- Extends: File navigation and basic commands
- Uses: Pipes, redirection, file operations
- Bridges: To scripting and advanced automation

---

## 📞 Getting Help

### Within This Module
1. Check the Glossary (above) for term definitions
2. Review Command Quick Reference (above) for syntax
3. Look up specific command in 02-commands-cheatsheet.md
4. Search 03-hands-on-labs.md for similar example

### External Resources
- **Man pages**: `man grep`, `man awk`, `man sed`, `man cut`
- **Online regex tester**: regex101.com (test patterns before using)
- **Stack Overflow**: Tag with `sed` or `awk` when stuck
- **AWK tutorial**: gnu.org/software/gawk/manual

### Troubleshooting
- **Command not found**: Install with `apt-get install gawk` (Ubuntu)
- **Regex not matching**: Test pattern at regex101.com
- **sed not replacing**: Make sure pattern has escape `\` when needed
- **Pipe not working**: Check first command has output, second accepts stdin

---

## 🎯 Next Steps

**Ready to start?**

1. ✅ Verify you have the prerequisites (5 min)
2. ✅ Create your lab environment (5 min)
3. ✅ Read 01-theory.md (25 min)
4. ✅ Start with Lab 1 in 03-hands-on-labs.md (30 min)
5. ✅ Continue through all 8 labs (4-6 hours)
6. ✅ Review and master with scripts (30 min)

**Estimated Total Time**: 6-8 hours

**Recommendation**: Dedicate 2-3 hours per session over 2-3 days for best retention.

---

## 📊 Module Statistics

- **Commands Covered**: 50+
- **Hands-On Labs**: 8
- **Production Scripts**: 2
- **Learning Time**: 6-8 hours
- **Prerequisites**: Module 01
- **Difficulty**: Beginner to Intermediate
- **Real-World Relevance**: ⭐⭐⭐⭐⭐ (Essential)

---

## 📝 Files in This Module

| File | Purpose | Time |
|------|---------|------|
| README.md | This overview | 10 min |
| 01-theory.md | Conceptual foundations | 25 min |
| 02-commands-cheatsheet.md | Command reference | Reference |
| 03-hands-on-labs.md | Practical exercises | 4-6 hours |
| scripts/log-analyzer.sh | Production script | 15 min |
| scripts/data-processor.sh | Production script | 15 min |
| scripts/README.md | Script documentation | 5 min |

---

## 🎓 Module 02: Linux Advanced Commands

**Welcome to one of the most important modules in your Linux journey.**

Advanced text processing is not just a skill—it's a superpower. Every line of work with Linux involves these tools in some form. Master them, and you'll see systems through a different lens.

**Let's get started.** → Read [01-theory.md](01-theory.md) next.

---

*Module 02: Linux Advanced Commands*
*Part of the Linux for DevOps Learning Repository*
