# Advanced Linux Commands: Hands-On Labs

Eight practical labs to master text processing and data manipulation. Complete them in order, following each step carefully.

---

## Setup: Create Lab Environment

Before starting any lab, run these commands:

```bash
# Create sandbox directory for all labs
mkdir -p ~/advanced-labs
cd ~/advanced-labs

# Verify location
pwd
# Should show: /home/username/advanced-labs
```

All labs work in `~/advanced-labs`. This keeps your system safe.

---

## Lab 1: Basic grep Patterns (20 minutes)

### Goal
Learn grep basics: simple searches, pattern matching, and common options.

### Setup

Create test file:
```bash
cat > messages.log << 'EOF'
[INFO] Application started
[ERROR] Connection failed
[WARNING] Retrying connection
[ERROR] Max retries exceeded
[INFO] Attempting fallback
[WARNING] Fallback took 5 seconds
[ERROR] All connections failed
[INFO] Service stopped
EOF
```

Verify file:
```bash
cat messages.log
```

Expected output:
```
[INFO] Application started
[ERROR] Connection failed
[WARNING] Retrying connection
[ERROR] Max retries exceeded
[INFO] Attempting fallback
[WARNING] Fallback took 5 seconds
[ERROR] All connections failed
[INFO] Service stopped
```

### Steps

**Step 1: Simple String Search**
```bash
grep "ERROR" messages.log
```

Expected output (should show 3 lines):
```
[ERROR] Connection failed
[ERROR] Max retries exceeded
[ERROR] All connections failed
```

**Step 2: Case-Insensitive Search**
```bash
grep -i "error" messages.log
```

Should match regardless of case (same output as Step 1).

**Step 3: Count Matches**
```bash
grep -c "ERROR" messages.log
```

Expected output:
```
3
```

**Step 4: Invert Match (Show Non-Matching)**
```bash
grep -v "ERROR" messages.log
```

Expected output (4 lines without ERROR):
```
[INFO] Application started
[WARNING] Retrying connection
[INFO] Attempting fallback
[WARNING] Fallback took 5 seconds
[INFO] Service stopped
```

**Step 5: Show Line Numbers**
```bash
grep -n "ERROR" messages.log
```

Expected output:
```
2:[ERROR] Connection failed
4:[ERROR] Max retries exceeded
7:[ERROR] All connections failed
```

**Step 6: OR Pattern (Extended Regex)**
```bash
grep -E "(ERROR|WARNING)" messages.log
```

Expected output (5 lines with ERROR or WARNING):
```
[ERROR] Connection failed
[WARNING] Retrying connection
[ERROR] Max retries exceeded
[WARNING] Fallback took 5 seconds
[ERROR] All connections failed
```

**Step 7: Anchor Pattern (Start of Line)**
```bash
grep "^\[ERROR\]" messages.log
```

Expected output (3 ERROR lines):
```
[ERROR] Connection failed
[ERROR] Max retries exceeded
[ERROR] All connections failed
```

### Verification Checklist
- [ ] Step 1: Shows 3 ERROR lines
- [ ] Step 2: Shows 3 ERROR lines (case-insensitive)
- [ ] Step 3: Output is `3`
- [ ] Step 4: Shows 4 non-ERROR lines
- [ ] Step 5: Shows line numbers before matches
- [ ] Step 6: Shows 5 lines with ERROR or WARNING
- [ ] Step 7: Shows 3 lines starting with [ERROR]

### Cleanup
```bash
rm messages.log
```

---

## Lab 2: Text Extraction with cut (20 minutes)

### Goal
Learn to extract columns from structured data using cut.

### Setup

Create CSV file:
```bash
cat > sales.csv << 'EOF'
name,month,revenue,region
Alice,January,5000,North
Bob,February,3500,South
Charlie,January,6200,East
Diana,February,4800,West
Eve,January,7100,North
EOF
```

Verify:
```bash
cat sales.csv
```

### Steps

**Step 1: Extract First Field**
```bash
cut -d, -f1 sales.csv
```

Expected output:
```
name
Alice
Bob
Charlie
Diana
Eve
```

**Step 2: Extract Multiple Fields (1 and 3)**
```bash
cut -d, -f1,3 sales.csv
```

Expected output:
```
name,revenue
Alice,5000
Bob,3500
Charlie,6200
Diana,4800
Eve,7100
```

**Step 3: Extract Range (Fields 2-4)**
```bash
cut -d, -f2-4 sales.csv
```

Expected output:
```
month,revenue,region
January,5000,North
February,3500,South
January,6200,East
February,4800,West
January,7100,North
```

**Step 4: Extract Just Names and Regions**
```bash
cut -d, -f1,4 sales.csv
```

Expected output:
```
name,region
Alice,North
Bob,South
Charlie,East
Diana,West
Eve,North
```

**Step 5: Work with /etc/passwd**
```bash
cut -d: -f1,3,6 /etc/passwd | head -5
```

Expected output (users, UIDs, home directories):
```
root:0:/root
daemon:1:/usr/sbin
bin:2:/bin
sys:3:/dev
sync:4:/bin
```

### Verification Checklist
- [ ] Step 1: Shows 6 lines (header + 5 names)
- [ ] Step 2: Shows name and revenue columns
- [ ] Step 3: Shows columns 2-4 (month, revenue, region)
- [ ] Step 4: Shows name and region only
- [ ] Step 5: Shows user, UID, home directory

### Cleanup
```bash
rm sales.csv
```

---

## Lab 3: Data Sorting and Deduplication (25 minutes)

### Goal
Learn sort and uniq for organizing and deduplicating data.

### Setup

Create access log sample:
```bash
cat > ip_log.txt << 'EOF'
192.168.1.100
192.168.1.50
192.168.1.100
192.168.1.200
192.168.1.50
192.168.1.100
192.168.1.200
192.168.1.75
192.168.1.75
192.168.1.50
EOF
```

### Steps

**Step 1: Sort the IPs**
```bash
sort ip_log.txt
```

Expected output (sorted):
```
192.168.1.100
192.168.1.100
192.168.1.100
192.168.1.200
192.168.1.200
192.168.1.50
192.168.1.50
192.168.1.50
192.168.1.75
192.168.1.75
```

**Step 2: Remove Duplicates with uniq**
```bash
sort ip_log.txt | uniq
```

Expected output (unique IPs):
```
192.168.1.100
192.168.1.200
192.168.1.50
192.168.1.75
```

**Step 3: Count Occurrences**
```bash
sort ip_log.txt | uniq -c
```

Expected output (count + IP):
```
      3 192.168.1.100
      2 192.168.1.200
      3 192.168.1.50
      2 192.168.1.75
```

**Step 4: Sort by Count (Most Common First)**
```bash
sort ip_log.txt | uniq -c | sort -rn
```

Expected output:
```
      3 192.168.1.100
      3 192.168.1.50
      2 192.168.1.200
      2 192.168.1.75
```

**Step 5: Real Example - Count Users in /etc/passwd**
```bash
cut -d: -f1 /etc/passwd | sort | uniq | wc -l
```

Expected output: A number representing unique users (e.g., 28)

### Verification Checklist
- [ ] Step 1: Shows sorted IPs
- [ ] Step 2: Shows 4 unique IPs (no duplicates)
- [ ] Step 3: Shows count + IP pairs
- [ ] Step 4: Sorted by count, highest first
- [ ] Step 5: Returns number of unique users

### Cleanup
```bash
rm ip_log.txt
```

---

## Lab 4: sed - Stream Editor and Substitution (30 minutes)

### Goal
Learn sed for text replacement and editing.

### Setup

Create configuration file:
```bash
cat > app.conf << 'EOF'
# Application Configuration
database.host=old.db.server
database.port=5432
database.user=appuser
api.endpoint=http://old.api.com/v1
api.timeout=30
log.level=INFO
log.file=/var/log/app.log
cache.enabled=false
EOF
```

### Steps

**Step 1: Simple Substitution (First Occurrence)**
```bash
sed 's/old/new/' app.conf
```

Expected output (only first "old" on each line changes):
```
# Application Configuration
database.host=new.db.server
database.port=5432
database.user=appuser
api.endpoint=http://new.api.com/v1
api.timeout=30
log.level=INFO
log.file=/var/log/app.log
cache.enabled=false
```

Notice only one "old" is replaced per line.

**Step 2: Global Substitution (All Occurrences)**
```bash
sed 's/old/new/g' app.conf
```

Expected output (all "old" replaced):
```
# Application Configuration
database.host=new.db.server
database.port=5432
database.user=appuser
api.endpoint=http://new.api.com/v1
api.timeout=30
log.level=INFO
log.file=/var/log/app.log
cache.enabled=false
```

**Step 3: Delete Lines Matching Pattern**
```bash
sed '/^#/d' app.conf
```

Expected output (comment lines removed):
```
database.host=old.db.server
database.port=5432
database.user=appuser
api.endpoint=http://old.api.com/v1
api.timeout=30
log.level=INFO
log.file=/var/log/app.log
cache.enabled=false
```

**Step 4: Print Only Matching Lines**
```bash
sed -n '/database/p' app.conf
```

Expected output (only database lines):
```
database.host=old.db.server
database.port=5432
database.user=appuser
```

**Step 5: Extract Database Configuration**
```bash
sed -n '/database/p' app.conf | sed 's/database\.//' | sed 's/=/: /'
```

Expected output (formatted database config):
```
host: old.db.server
port: 5432
user: appuser
```

**Step 6: Test Replacement Before Applying**
```bash
# First, preview the changes
sed 's/old/production/g' app.conf

# Then apply to file with backup
sed -i.backup 's/old/production/g' app.conf

# Verify the backup was created
ls -la app.conf*
```

Expected: Both `app.conf` and `app.conf.backup` exist

**Step 7: Verify the File Was Modified**
```bash
cat app.conf | grep -E "(production|old)" | head -3
```

Expected output (should show "production", not "old"):
```
database.host=production.db.server
api.endpoint=http://production.api.com/v1
```

### Verification Checklist
- [ ] Step 1: Shows first "old" replaced with "new"
- [ ] Step 2: Shows all "old" replaced with "new"
- [ ] Step 3: Shows no comment lines
- [ ] Step 4: Shows only database lines
- [ ] Step 5: Shows formatted database config
- [ ] Step 6: Backup created successfully
- [ ] Step 7: Verify changes applied to app.conf

### Cleanup
```bash
rm app.conf app.conf.backup
```

---

## Lab 5: awk - Data Transformation (35 minutes)

### Goal
Learn awk for flexible data processing and calculations.

### Setup

Create employee data:
```bash
cat > employees.txt << 'EOF'
name:department:salary:years
Alice:Engineering:95000:5
Bob:Sales:65000:3
Charlie:Engineering:105000:7
Diana:Sales:70000:4
Eve:Marketing:75000:2
Frank:Engineering:98000:6
Grace:Marketing:72000:3
EOF
```

Verify:
```bash
cat employees.txt
```

### Steps

**Step 1: Extract Fields with awk**
```bash
awk -F: '{print $1, $2}' employees.txt
```

Expected output (name and department):
```
name department
Alice Engineering
Bob Sales
Charlie Engineering
Diana Sales
Eve Marketing
Frank Engineering
Grace Marketing
```

**Step 2: Print With Formatting**
```bash
awk -F: '{printf "%-10s %15s\n", $1, $2}' employees.txt
```

Expected output (aligned columns):
```
name       department
Alice      Engineering
Bob                Sales
Charlie    Engineering
Diana            Sales
Eve          Marketing
Frank      Engineering
Grace        Marketing
```

**Step 3: Filter by Condition**
```bash
awk -F: '$3 > 80000 {print $1, $3}' employees.txt
```

Expected output (salaries > 80000):
```
Alice 95000
Charlie 105000
Frank 98000
```

**Step 4: Calculate Average Salary**
```bash
awk -F: 'NR > 1 {sum += $3; count++} END {print "Average: $" int(sum/count)}' employees.txt
```

Expected output:
```
Average: $83428
```

**Step 5: Count by Department**
```bash
awk -F: 'NR > 1 {dept[$2]++} END {for (d in dept) print d, dept[d]}' employees.txt
```

Expected output (department and count):
```
Engineering 3
Sales 2
Marketing 2
```

**Step 6: Sort by Salary (Descending)**
```bash
awk -F: 'NR > 1' employees.txt | sort -t: -k3 -nr
```

Expected output (highest to lowest salary):
```
Charlie:Engineering:105000:7
Alice:Engineering:95000:5
Frank:Engineering:98000:6
Eve:Marketing:75000:2
Diana:Sales:70000:4
Grace:Marketing:72000:3
Bob:Sales:65000:3
```

**Step 7: Complex Report**
```bash
awk -F: 'NR > 1 {
    dept[$2] += $3
    count[$2]++
} 
END {
    for (d in dept)
        printf "%s: %d people, avg salary: $%d\n", d, count[d], int(dept[d]/count[d])
}' employees.txt
```

Expected output (department summary):
```
Engineering: 3 people, avg salary: $99333
Sales: 2 people, avg salary: $67500
Marketing: 2 people, avg salary: $73500
```

### Verification Checklist
- [ ] Step 1: Shows name and department columns
- [ ] Step 2: Shows formatted output with aligned columns
- [ ] Step 3: Shows only high earners (>80000)
- [ ] Step 4: Shows average salary calculation
- [ ] Step 5: Shows departments with counts
- [ ] Step 6: Salary sorted highest to lowest
- [ ] Step 7: Department summary with averages

### Cleanup
```bash
rm employees.txt
```

---

## Lab 6: Real-World Log Analysis (40 minutes)

### Goal
Combine multiple tools to analyze a realistic web server access log.

### Setup

Create sample access log (Apache format):
```bash
cat > access.log << 'EOF'
192.168.1.100 - alice [14/Jan/2024:10:30:45 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - bob [14/Jan/2024:10:31:12 +0000] "GET /about.html HTTP/1.1" 200 5678
192.168.1.100 - alice [14/Jan/2024:10:31:45 +0000] "GET /products.html HTTP/1.1" 404 0
192.168.1.102 - charlie [14/Jan/2024:10:32:10 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.101 - bob [14/Jan/2024:10:32:55 +0000] "POST /api/login HTTP/1.1" 200 145
192.168.1.100 - alice [14/Jan/2024:10:33:20 +0000] "GET /products.html HTTP/1.1" 404 0
192.168.1.101 - bob [14/Jan/2024:10:34:00 +0000] "GET /admin.html HTTP/1.1" 403 0
192.168.1.102 - charlie [14/Jan/2024:10:34:45 +0000] "GET /contact.html HTTP/1.1" 200 3456
192.168.1.100 - alice [14/Jan/2024:10:35:10 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.103 - david [14/Jan/2024:10:35:55 +0000] "GET /robots.txt HTTP/1.1" 404 0
EOF
```

Verify:
```bash
wc -l access.log
```

Expected: 10 lines

### Steps

**Step 1: Count Total Requests**
```bash
wc -l access.log
```

Expected output:
```
10 access.log
```

**Step 2: Count Requests by Status Code**
```bash
cut -d' ' -f9 access.log | sort | uniq -c | sort -rn
```

Expected output:
```
      6 200
      3 404
      1 403
```

**Step 3: Top IPs Making Requests**
```bash
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn
```

Expected output:
```
      4 192.168.1.100
      3 192.168.1.101
      2 192.168.1.102
      1 192.168.1.103
```

**Step 4: Find 404 Errors**
```bash
grep " 404 " access.log | cut -d' ' -f7
```

Expected output (URLs with 404):
```
/products.html
/products.html
/robots.txt
```

**Step 5: Count 404s by IP**
```bash
grep " 404 " access.log | cut -d' ' -f1 | sort | uniq -c
```

Expected output:
```
      2 192.168.1.100
      1 192.168.1.103
```

**Step 6: Extract Usernames and Count Requests**
```bash
cut -d' ' -f3 access.log | sort | uniq -c | sort -rn
```

Expected output:
```
      4 alice
      3 bob
      2 charlie
      1 david
```

**Step 7: Most Requested URLs**
```bash
cut -d'"' -f2 access.log | awk '{print $2}' | sort | uniq -c | sort -rn
```

Expected output:
```
      2 /index.html
      2 /products.html
      1 /about.html
      1 /api/login
      1 /admin.html
      1 /contact.html
      1 /robots.txt
```

**Step 8: Generate Simple Report**
```bash
echo "=== Web Server Log Analysis ==="
echo ""
echo "Total Requests: $(wc -l < access.log)"
echo "Successful (200): $(grep -c ' 200 ' access.log)"
echo "Not Found (404): $(grep -c ' 404 ' access.log)"
echo "Forbidden (403): $(grep -c ' 403 ' access.log)"
echo ""
echo "Top IP:"
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -1 | awk '{print $2, $3 " requests"}'
```

Expected output:
```
=== Web Server Log Analysis ===

Total Requests: 10
Successful (200): 6
Not Found (404): 3
Forbidden (403): 1

Top IP:
192.168.1.100 4 requests
```

### Verification Checklist
- [ ] Step 1: Count shows 10 lines
- [ ] Step 2: Shows status codes with counts
- [ ] Step 3: Shows IPs with request counts
- [ ] Step 4: Shows URLs that returned 404
- [ ] Step 5: Shows IPs with 404 errors
- [ ] Step 6: Shows users with request counts
- [ ] Step 7: Shows most requested URLs
- [ ] Step 8: Report shows analysis summary

### Cleanup
```bash
rm access.log
```

---

## Lab 7: Complex Pipeline - Finding Problematic Users (45 minutes)

### Goal
Combine grep, awk, cut, sort to solve a realistic problem.

### Setup

Create authentication log sample:
```bash
cat > auth.log << 'EOF'
Jan 14 10:00:15 server sshd[1234]: Invalid user alice from 192.168.1.100 port 22
Jan 14 10:00:20 server sshd[1235]: Invalid user bob from 192.168.1.101 port 22
Jan 14 10:00:25 server sshd[1236]: Invalid user alice from 192.168.1.100 port 22
Jan 14 10:00:30 server sshd[1237]: Invalid user charlie from 192.168.1.102 port 22
Jan 14 10:00:35 server sshd[1238]: Invalid user alice from 192.168.1.100 port 22
Jan 14 10:00:40 server sshd[1239]: Invalid user bob from 192.168.1.101 port 22
Jan 14 10:00:45 server sshd[1240]: Invalid user david from 192.168.1.103 port 22
Jan 14 10:00:50 server sshd[1241]: Invalid user eve from 192.168.1.104 port 22
Jan 14 10:00:55 server sshd[1242]: Invalid user alice from 192.168.1.100 port 22
Jan 14 10:01:00 server sshd[1243]: Invalid user bob from 192.168.1.101 port 22
EOF
```

### Steps

**Step 1: Count Login Attempts by User**
```bash
grep "Invalid user" auth.log | awk '{print $8}' | sort | uniq -c | sort -rn
```

Expected output:
```
      4 alice
      3 bob
      1 charlie
      1 david
      1 eve
```

**Step 2: Identify Suspicious IPs (>2 attempts)**
```bash
grep "Invalid user" auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | awk '$1 > 2 {print $2, $1 " attempts"}'
```

Expected output:
```
192.168.1.100 4 attempts
192.168.1.101 3 attempts
```

**Step 3: Show Failed Login Attempts with User and IP**
```bash
grep "Invalid user" auth.log | awk '{printf "%s from %s\n", $8, $11}' | sort
```

Expected output:
```
alice from 192.168.1.100
alice from 192.168.1.100
alice from 192.168.1.100
alice from 192.168.1.100
bob from 192.168.1.101
bob from 192.168.1.101
bob from 192.168.1.101
charlie from 192.168.1.102
david from 192.168.1.103
eve from 192.168.1.104
```

**Step 4: Find Users Attacking from Multiple IPs**
```bash
grep "Invalid user" auth.log | awk '{print $8, $11}' | sort -u | cut -d' ' -f1 | sort | uniq -c | awk '$1 > 1 {print}'
```

Expected output (none in this case):
```
```

**Step 5: Generate Security Report**
```bash
cat > security_report.sh << 'SCRIPT'
#!/bin/bash

echo "=== Failed Login Attempts Report ==="
echo ""
echo "Total Attempts: $(grep -c 'Invalid user' auth.log)"
echo ""
echo "Top 3 Targeted Usernames:"
grep "Invalid user" auth.log | awk '{print $8}' | sort | uniq -c | sort -rn | head -3 | awk '{printf "%s. %s (%d attempts)\n", NR, $2, $1}'
echo ""
echo "Top 3 Attacking IP Addresses:"
grep "Invalid user" auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -3 | awk '{printf "%s. %s (%d attempts)\n", NR, $2, $1}'
echo ""
echo "High-Risk IPs (>2 attempts):"
grep "Invalid user" auth.log | awk '{print $11}' | sort | uniq -c | awk '$1 > 2 {printf "  %s: %d attempts\n", $2, $1}'
SCRIPT

chmod +x security_report.sh
./security_report.sh
```

Expected output:
```
=== Failed Login Attempts Report ===

Total Attempts: 10

Top 3 Targeted Usernames:
1. alice (4 attempts)
2. bob (3 attempts)
3. charlie (1 attempts)

Top 3 Attacking IP Addresses:
1. 192.168.1.100 (4 attempts)
2. 192.168.1.101 (3 attempts)
3. 192.168.1.102 (1 attempts)

High-Risk IPs (>2 attempts):
  192.168.1.100: 4 attempts
  192.168.1.101: 3 attempts
```

### Verification Checklist
- [ ] Step 1: Shows users with attempt counts
- [ ] Step 2: Shows IPs with >2 attempts
- [ ] Step 3: Shows user/IP pairs, sorted
- [ ] Step 4: Correctly identifies users from multiple IPs
- [ ] Step 5: Security report generates correctly

### Cleanup
```bash
rm auth.log security_report.sh
```

---

## Lab 8: Data Processing Pipeline - CSV Report Generation (50 minutes)

### Goal
Create a realistic end-to-end data processing pipeline.

### Setup

Create sample customer data CSV:
```bash
cat > customers.csv << 'EOF'
id,name,email,region,purchases,total_spent,signup_date
1,Alice Smith,alice@example.com,North,15,2500.50,2023-01-15
2,Bob Johnson,bob@example.com,South,8,1200.00,2023-02-20
3,Charlie Brown,charlie@example.com,East,22,4500.75,2022-06-10
4,Diana Prince,diana@example.com,West,5,750.25,2023-11-01
5,Eve Davis,eve@example.com,North,18,3200.00,2023-03-12
6,Frank Wilson,frank@example.com,South,12,2100.50,2023-05-22
7,Grace Lee,grace@example.com,East,9,1500.00,2023-08-30
8,Henry Martinez,henry@example.com,West,25,5000.00,2022-12-01
EOF
```

### Steps

**Step 1: Count Records**
```bash
wc -l customers.csv
```

Expected output:
```
9 customers.csv
```

(8 customers + 1 header)

**Step 2: Total Revenue**
```bash
awk -F, 'NR > 1 {sum += $6} END {printf "Total Revenue: $%.2f\n", sum}' customers.csv
```

Expected output:
```
Total Revenue: $20651.00
```

**Step 3: Average Order Value**
```bash
awk -F, 'NR > 1 {revenue += $6; purchases += $5} END {printf "Avg Order Value: $%.2f\n", revenue/purchases}' customers.csv
```

Expected output:
```
Avg Order Value: $163.73
```

**Step 4: Top Customers by Revenue**
```bash
awk -F, 'NR > 1 {print $2, $6}' customers.csv | sort -t' ' -k2 -nr | head -3
```

Expected output:
```
Henry Martinez 5000
Charlie Brown 4500.75
Eve Davis 3200
```

**Step 5: Customers by Region**
```bash
awk -F, 'NR > 1 {region[$4]++; spent[$4] += $6} END {for (r in region) printf "%s: %d customers, $%.2f total\n", r, region[r], spent[r]}' customers.csv | sort
```

Expected output:
```
East: 2 customers, $6000.75 total
North: 2 customers, $5700.50 total
South: 2 customers, $3300.50 total
West: 2 customers, $5750.25 total
```

**Step 6: High-Value Customers (>$3000 spent)**
```bash
awk -F, 'NR > 1 && $6 > 3000 {printf "%s: $%.2f\n", $2, $6}' customers.csv
```

Expected output:
```
Alice Smith: $2500.50
Charlie Brown: $4500.75
Eve Davis: $3200.00
Henry Martinez: $5000.00
```

**Step 7: Generate Comprehensive Report**
```bash
cat > report.sh << 'SCRIPT'
#!/bin/bash

echo "========================================"
echo "    Customer Analytics Report"
echo "========================================"
echo ""
echo "== Summary Statistics =="
total_customers=$(tail -n +2 customers.csv | wc -l)
total_revenue=$(awk -F, 'NR > 1 {sum += $6} END {printf "%.2f", sum}' customers.csv)
avg_revenue=$(awk -F, 'NR > 1 {sum += $6; count++} END {printf "%.2f", sum/count}' customers.csv)
total_purchases=$(awk -F, 'NR > 1 {sum += $5} END {print sum}' customers.csv)

echo "Total Customers: $total_customers"
echo "Total Revenue: \$$total_revenue"
echo "Average Revenue per Customer: \$$avg_revenue"
echo "Total Purchases: $total_purchases"
echo ""

echo "== Top 5 Customers =="
awk -F, 'NR > 1 {print $2, $6}' customers.csv | sort -t' ' -k2 -nr | head -5 | nl -v 1 | awk '{printf "%d. %s: $%s\n", $1, $2, $3}'
echo ""

echo "== Revenue by Region =="
awk -F, 'NR > 1 {region[$4] += $6} END {for (r in region) printf "%s: $%.2f\n", r, region[r]}' customers.csv | sort -t: -k2 -nr
echo ""

echo "== Growth Metrics =="
echo "Customers who spent >$3000: $(awk -F, 'NR > 1 && $6 > 3000' customers.csv | wc -l)"
echo "Average purchases per customer: $(awk -F, 'NR > 1 {sum += $5; count++} END {printf "%.1f", sum/count}' customers.csv)"

SCRIPT

chmod +x report.sh
./report.sh
```

Expected output:
```
========================================
    Customer Analytics Report
========================================

== Summary Statistics ==
Total Customers: 8
Total Revenue: $20651.00
Average Revenue per Customer: $2581.38
Total Purchases: 114

== Top 5 Customers ==
1. Henry Martinez: $5000.00
2. Charlie Brown: $4500.75
3. Eve Davis: $3200.00
4. Alice Smith: $2500.50
5. Frank Wilson: $2100.50

== Revenue by Region ==
East: $6000.75
North: $5700.50
West: $5750.25
South: $3300.50

== Growth Metrics ==
Customers who spent >$3000: 4
Average purchases per customer: 14.3
```

### Verification Checklist
- [ ] Step 1: Count shows 9 lines (8 + header)
- [ ] Step 2: Total revenue calculation correct
- [ ] Step 3: Average order value calculated
- [ ] Step 4: Top customers sorted by revenue
- [ ] Step 5: Revenue by region with totals
- [ ] Step 6: Shows high-value customers >$3000
- [ ] Step 7: Comprehensive report generates

### Cleanup
```bash
rm customers.csv report.sh
```

---

## Summary: What You've Learned

By completing these 8 labs, you now understand:

✅ **grep**: Search and filter text patterns  
✅ **cut**: Extract columns from structured data  
✅ **sort** + **uniq**: Organize and deduplicate  
✅ **sed**: Bulk text replacement and editing  
✅ **awk**: Flexible data transformation  
✅ **Piping**: Combine tools to solve complex problems  
✅ **Real-world**: Log analysis and report generation  
✅ **Automation**: Write scripts that process data at scale

---

## Next Steps

1. **Practice**: Revisit any lab you found challenging
2. **Explore**: Try labs on your own data files
3. **Combine**: Mix and match these tools for new problems
4. **Automate**: Write bash scripts using these tools
5. **Advanced**: Proceed to Module 16 (Shell Scripting Basics)

---

## Troubleshooting

### "Command not found"
```bash
# Install missing tools
sudo apt-get install gawk mawk
```

### "Unexpected operator" in awk
Check for unescaped special characters. Use `'` quotes around awk programs:
```bash
awk 'BEGIN {print "test"}'  # Correct
awk BEGIN {print "test"}    # Wrong
```

### sed not replacing in place
Always use `-i.bak` to create a backup first:
```bash
sed -i.bak 's/old/new/g' file.txt
```

### Pipe not working
Verify first command outputs data:
```bash
cat file.txt              # Should show content
cat file.txt | grep "x"   # Now should filter
```

---

*Advanced Linux Commands: Hands-On Labs*
*Master text processing through practical application*
