# Production Scripts for Advanced Linux Commands

Two production-ready scripts that automate common text processing and log analysis tasks. Both scripts demonstrate the advanced commands covered in this module in a practical, reusable way.

---

## 📋 Overview

| Script | Purpose | Use Case |
|--------|---------|----------|
| `log-analyzer.sh` | Analyze log files and extract patterns | Web server logs, system logs, app logs |
| `data-processor.sh` | Extract, transform, validate data | CSV files, structured data, data pipelines |

---

## 🔍 log-analyzer.sh

### Purpose
Automatically detect log format and generate analysis reports. Supports Apache, Nginx, syslog, and application logs.

### Features
- **Auto-detection**: Recognizes log format automatically
- **Statistical analysis**: Count entries, find patterns
- **IP analysis**: Extract top IPs from web logs
- **Error detection**: Identify errors, warnings, failures
- **Flexible output**: Show top N results, filter patterns

### Installation
```bash
chmod +x log-analyzer.sh
# Optional: sudo mv log-analyzer.sh /usr/local/bin/log-analyzer
```

### Usage

#### Basic Analysis
```bash
# Analyze Apache access log
./log-analyzer.sh /var/log/apache2/access.log

# Output:
# Apache/Nginx Access Log Analysis
#
# Total Requests: 1000
#
# Status Codes:
#   200: 950
#   404: 35
#   403: 10
#   500: 5
#
# Top 10 IP Addresses:
#   192.168.1.100: 125 requests
#   192.168.1.101: 98 requests
#   ...
```

#### Analyze System Log
```bash
./log-analyzer.sh /var/log/syslog
```

#### Top N Results
```bash
# Show top 20 IPs instead of 10
./log-analyzer.sh /var/log/apache2/access.log --top 20
```

#### Filter Specific Entries
```bash
# Only analyze lines matching pattern
./log-analyzer.sh /var/log/syslog --filter "kernel"
```

### Real Examples

**Example 1: Web Server Health Check**
```bash
./log-analyzer.sh /var/log/apache2/access.log

# Output shows:
# - Total requests
# - HTTP status distribution
# - Top IPs (potential DoS attacks?)
# - Any 5xx errors (server problems)
```

**Example 2: Security Audit**
```bash
./log-analyzer.sh /var/log/auth.log

# Output shows:
# - Failed login attempts
# - Most active users
# - Potential brute-force patterns
```

**Example 3: Application Monitoring**
```bash
./log-analyzer.sh app.log

# Output shows:
# - Error count
# - Warning count
# - Info messages
# - Most common issues
```

### How It Works

```bash
# Script automatically:
# 1. Detects log format from first line
# 2. Identifies field structure
# 3. Extracts relevant data
# 4. Counts and aggregates
# 5. Shows top results
# 6. Highlights errors/anomalies
```

### Integration with Module Labs

The script uses these Module 02 concepts:
- **grep**: Detect log format, find errors
- **cut**: Extract fields (IP, status, process)
- **sort**: Order results by frequency
- **uniq -c**: Count occurrences
- **awk**: Conditional analysis, filtering

---

## 📊 data-processor.sh

### Purpose
Extract, transform, validate structured data files. Works with CSV, TSV, colon-delimited, and any custom-delimited format.

### Features
- **Flexible delimiters**: CSV, TSV, colon-separated, custom
- **Column extraction**: Select and reorder columns
- **Data validation**: Check consistency
- **Duplicate removal**: Find unique rows
- **Sorting**: Sort by any field, numeric or alphabetic

### Installation
```bash
chmod +x data-processor.sh
# Optional: sudo mv data-processor.sh /usr/local/bin/data-processor
```

### Usage

#### Extract Columns
```bash
# Extract columns 1 and 3 from CSV
./data-processor.sh data.csv --columns 1,3

# Extract columns 1, 3, 5
./data-processor.sh data.csv --columns 1,3,5

# Extract from colon-delimited file
./data-processor.sh /etc/passwd --delimiter ':' --columns 1,3,6
```

#### Validate Data
```bash
# Check if all rows have consistent field count
./data-processor.sh data.csv --validate

# Output example:
# Data Validation Report
#
# Total Lines: 100
# Expected Fields per Line: 5
#
# ✓ Validation Passed - All lines consistent
```

#### Remove Duplicates
```bash
# Find unique rows (sorts first)
./data-processor.sh data.txt --unique
```

#### Sort Data
```bash
# Sort by field 2 (default: alphabetic)
./data-processor.sh data.csv --delimiter ',' --sort 2

# Sort numerically by field 3
./data-processor.sh salary_data.csv --sort 3 --numeric

# Descending sort (use sort command after)
./data-processor.sh data.csv --sort 2 | sort -r
```

### Real Examples

**Example 1: User Management**
```bash
# Extract usernames and UIDs from /etc/passwd
./data-processor.sh /etc/passwd --delimiter ':' --columns 1,3

# Output:
# root:0
# daemon:1
# bin:2
# sys:3
# alice:1000
# bob:1001
```

**Example 2: Data Quality Check**
```bash
# Validate customer database
./data-processor.sh customers.csv --validate

# Output shows any rows with wrong field count
# Useful before importing to database
```

**Example 3: CSV Column Reordering**
```bash
# Extract specific columns in different order
./data-processor.sh orders.csv --columns 3,1,2

# Reorder to: product, customer, date
# (instead of original: customer, date, product)
```

**Example 4: Salary Analysis**
```bash
# Sort employees by salary (numeric)
./data-processor.sh employees.csv --delimiter ',' --columns 1,3 --sort 2 --numeric

# Shows employees sorted by salary
# Can combine with grep for department filtering
```

### How It Works

```bash
# Process:
# 1. Validate delimiter and field count
# 2. Extract requested columns using awk
# 3. Apply transformations (sort, unique, etc.)
# 4. Output result with summary
```

### Integration with Module Labs

The script uses these Module 02 concepts:
- **cut/awk**: Extract specific fields
- **awk**: Field counting and validation
- **sort**: Order data by field
- **uniq**: Remove consecutive duplicates
- **awk**: Complex field manipulation

---

## 🔗 Integration Examples

### Scenario 1: Web Server Report

```bash
# Generate daily web server health report
#!/bin/bash

echo "=== Daily Web Server Report ==="
./log-analyzer.sh /var/log/apache2/access.log

# Identify problematic IPs
echo ""
echo "=== Potential Threats ==="
grep " 404 " /var/log/apache2/access.log | \
    cut -d' ' -f1 | sort | uniq -c | sort -rn | head -5
```

### Scenario 2: Data Pipeline

```bash
# Import and validate CSV data
#!/bin/bash

echo "Step 1: Validating data..."
./data-processor.sh import_data.csv --validate || exit 1

echo "Step 2: Extracting key fields..."
./data-processor.sh import_data.csv --columns 1,2,3 > processed.csv

echo "Step 3: Removing duplicates..."
./data-processor.sh processed.csv --unique > final.csv

echo "Data ready for import"
```

### Scenario 3: Security Audit

```bash
# Audit system logs for suspicious activity
#!/bin/bash

echo "=== System Security Audit ==="

# Check for auth failures
echo "Failed logins:"
./log-analyzer.sh /var/log/auth.log | grep -c "Failed"

# Check for system errors
echo "System errors:"
./log-analyzer.sh /var/log/syslog | grep -c "error"

# Top error-causing processes
echo "Top error sources:"
grep "error" /var/log/syslog | \
    awk '{print $5}' | cut -d'[' -f1 | sort | uniq -c | sort -rn | head -5
```

---

## 🛠️ Troubleshooting

### "Permission denied" when running script
```bash
# Make script executable
chmod +x log-analyzer.sh
chmod +x data-processor.sh
```

### "Command not found" for awk or grep
```bash
# Install required tools (Ubuntu)
sudo apt-get install gawk grep

# Or (CentOS/RHEL)
sudo yum install gawk grep
```

### Script shows no output
```bash
# Verify file exists and has content
ls -lh /path/to/logfile
wc -l /path/to/logfile

# Try with test file
echo -e "192.168.1.1 - user [14/Jan/2024] GET 200" > test.log
./log-analyzer.sh test.log
```

### Delimiter issues with special characters
```bash
# Tab delimiter (use literal tab or \t)
./data-processor.sh file.tsv --delimiter $'\t'

# Pipe delimiter
./data-processor.sh file.txt --delimiter '|'

# Semicolon
./data-processor.sh file.csv --delimiter ';'
```

---

## 📚 Learning Value

These scripts demonstrate:

**Advanced Commands Used:**
- `grep` for pattern matching and auto-detection
- `cut` for field extraction
- `awk` for complex field processing
- `sort` and `uniq` for aggregation
- `wc` for counting

**Bash Scripting Patterns:**
- Command-line argument parsing
- Color-coded output for readability
- Automatic format detection
- Error handling with `set -euo pipefail`
- Function organization
- Help documentation

**Real-World Practices:**
- Production script structure
- Flexible option handling
- Safe error management
- User-friendly output
- Integration-ready design

---

## 🔄 Extending the Scripts

### Add New Log Format to log-analyzer.sh

Modify the `detect_log_format()` function:
```bash
detect_log_format() {
    local file="$1"
    local first_line=$(head -1 "$file")
    
    # Add your custom pattern detection
    if [[ "$first_line" =~ "your_pattern" ]]; then
        echo "your_format"
    fi
    # ... existing patterns
}
```

Then add analysis function:
```bash
analyze_your_format() {
    # Your analysis logic
}
```

### Add Delimiter Support to data-processor.sh

The script already supports any delimiter. Just pass it:
```bash
./data-processor.sh data.txt --delimiter '|' --columns 1,3
```

### Create Custom Reports

Use the scripts as foundation for specialized reports:
```bash
# Daily stats script
#!/bin/bash
DATE=$(date +%Y-%m-%d)
./log-analyzer.sh /var/log/apache2/access.log > daily_report_$DATE.txt
echo "Report saved to daily_report_$DATE.txt"
```

---

## 🚀 Quick Start

```bash
# 1. Make scripts executable
chmod +x log-analyzer.sh
chmod +x data-processor.sh

# 2. Test log analyzer
./log-analyzer.sh /var/log/syslog

# 3. Test data processor
echo -e "a,b,c\n1,2,3\n4,5,6" > test.csv
./data-processor.sh test.csv --columns 1,3

# 4. Combine in a pipeline
./log-analyzer.sh /var/log/apache2/access.log | grep "IPs" | head -5
```

---

## 📖 Related Labs

These scripts apply concepts from:
- **Lab 1**: grep patterns and filtering
- **Lab 3**: sort and uniq for aggregation
- **Lab 5**: awk for data transformation
- **Lab 6**: Real-world log analysis
- **Lab 8**: Data processing pipelines

Review those labs to understand the underlying commands.

---

## 📋 Features Comparison

| Feature | log-analyzer.sh | data-processor.sh |
|---------|-----------------|------------------|
| Auto-detect format | ✅ | - |
| Extract columns | - | ✅ |
| Count entries | ✅ | ✅ |
| Sort results | ✅ | ✅ |
| Find duplicates | ✅ | ✅ |
| Validate data | - | ✅ |
| Error highlighting | ✅ | - |
| Multiple formats | 4 formats | Custom delim |

---

## 🎓 Educational Benefits

By studying and using these scripts, you learn:

1. **Integration**: How individual commands combine to solve real problems
2. **Automation**: How to build tools that save time and reduce errors
3. **Design**: How to structure code for maintainability and reuse
4. **Best Practices**: Error handling, user feedback, documentation
5. **Performance**: Using efficient tools for large datasets

---

## 📞 Common Tasks

### Task 1: Analyze Yesterday's Errors
```bash
find /var/log -name "*.log" -mtime 1 -exec ./log-analyzer.sh {} \;
```

### Task 2: Export Data for Analysis
```bash
./data-processor.sh database_export.csv --columns 1,2,3,5 > analysis_data.csv
```

### Task 3: Find Duplicate Records
```bash
./data-processor.sh records.csv --unique | diff - records.csv
```

### Task 4: Sort by Multiple Fields
```bash
./data-processor.sh data.csv --sort 2 | ./data-processor.sh /dev/stdin --sort 1
```

---

*Production Scripts for Advanced Linux Commands*  
*Demonstrating real-world applications of text processing tools*
