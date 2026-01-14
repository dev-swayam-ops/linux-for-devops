# scripts/ - Production-Ready Networking Tools

This folder contains production-ready bash scripts for network diagnostics and monitoring.

## Scripts Included

### 1. port-monitor.sh
Real-time monitoring of listening ports and network connections.

**Purpose:** Quickly identify which services are listening, what ports they're using, and detect port conflicts.

**Key Features:**
- List all listening TCP/UDP ports
- Monitor specific ports in real-time
- Show active connections
- Identify processes using ports
- Watch mode for continuous monitoring

**Basic Usage:**
```bash
# Show all listening ports
./port-monitor.sh

# Watch ports every 2 seconds
./port-monitor.sh -w 2

# Monitor specific port
./port-monitor.sh -p 8080

# Show active connections
./port-monitor.sh -c
```

**Examples:**
```bash
# Find what's using port 3306 (MySQL)
sudo ./port-monitor.sh -p 3306

# Monitor SSH (port 22) in real-time
sudo ./port-monitor.sh -w 1 -p 22

# Show all listening services
sudo ./port-monitor.sh --listen

# Check UDP ports (DNS, etc.)
sudo ./port-monitor.sh --udp
```

**Troubleshooting Scenarios:**
```bash
# Port already in use?
sudo ./port-monitor.sh -p 8080

# Which services are listening?
sudo ./port-monitor.sh -l

# Someone making unusual connections?
sudo ./port-monitor.sh -c -w 5
```

---

### 2. network-health-check.sh
Comprehensive network diagnostic tool for troubleshooting connectivity issues.

**Purpose:** Quickly diagnose network problems by running a series of connectivity and configuration checks.

**Key Features:**
- Check local interfaces and IP configuration
- Verify internet connectivity
- Test DNS resolution
- Validate routing
- Identify listening services
- Check for unusual connections
- Optional specific host testing
- Detailed diagnostics with verbose mode

**Basic Usage:**
```bash
# Full health check
./network-health-check.sh

# Quick check (30 seconds)
./network-health-check.sh -q

# Check specific host
./network-health-check.sh -h google.com

# Detailed output
./network-health-check.sh --full -v
```

**Examples:**
```bash
# Quick connectivity verification
./network-health-check.sh -q

# Debug connectivity to specific server
./network-health-check.sh -h 192.168.1.100

# Verbose diagnostics
./network-health-check.sh --verbose

# Check after network reconfiguration
./network-health-check.sh --full
```

**What It Checks:**
1. Network interfaces present and active
2. IP addresses assigned
3. Localhost connectivity (127.0.0.1)
4. Gateway reachability
5. Internet connectivity (multiple hosts)
6. DNS name resolution
7. Reverse DNS
8. Listening ports (normal vs unusual)
9. Established connections count
10. Optional: Specific host connectivity and path

**Exit Codes:**
- 0 = All checks passed
- 1 = Some checks failed (warnings)
- 2 = Critical failure (no internet)

---

## Installation

### Make Scripts Executable

```bash
chmod +x port-monitor.sh
chmod +x network-health-check.sh
```

### Add to PATH (Optional)

To run from anywhere:

```bash
# Create symlinks in /usr/local/bin
sudo ln -s $(pwd)/port-monitor.sh /usr/local/bin/port-monitor
sudo ln -s $(pwd)/network-health-check.sh /usr/local/bin/network-health-check

# Then use from anywhere:
port-monitor -w 5
network-health-check -q
```

---

## Requirements

### Required Commands (Usually Pre-installed)
- `bash` (4.0+)
- `ss` (socket statistics) - modern Linux
- `ip` (iproute2)
- `ping` (iputils)

### Optional (For Full Functionality)
- `dig` or `nslookup` (DNS queries)
- `traceroute` (path tracing)
- `sudo` (for process information)

### Installation if Missing (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install -y \
    iputils-ping \
    net-tools \
    dnsutils \
    traceroute \
    iproute2
```

### Installation (RHEL/CentOS)

```bash
sudo yum install -y \
    iputils \
    net-tools \
    bind-utils \
    traceroute \
    iproute
```

---

## Usage Patterns

### Pattern 1: Troubleshooting Can't Connect to Server

```bash
# First, check if your own network is okay
./network-health-check.sh -q

# Then check if the specific server is reachable
./network-health-check.sh -h 192.168.1.100

# Check what ports it has open
sudo ./port-monitor.sh -p 22  # Check SSH
sudo ./port-monitor.sh -p 80  # Check HTTP
```

### Pattern 2: Finding Port Conflicts

```bash
# Application won't start - port in use?
sudo ./port-monitor.sh -p 8080

# Kill the process if needed:
sudo kill -9 $(lsof -t -i :8080)

# Verify it's gone:
sudo ./port-monitor.sh -p 8080  # Should be clear
```

### Pattern 3: Monitoring Network for Issues

```bash
# Continuous monitoring (watch every second)
sudo ./port-monitor.sh -w 1 -c

# Or periodic checks
while true; do
    clear
    ./network-health-check.sh
    sleep 30
done
```

### Pattern 4: Debugging Connectivity After Network Change

```bash
# After changing network config:
sudo systemctl restart networking

# Verify everything is working:
./network-health-check.sh --full -v

# Check specific services still listening:
sudo ./port-monitor.sh -p 22
sudo ./port-monitor.sh -p 80
```

### Pattern 5: Security - Finding Unexpected Services

```bash
# List all listening ports
sudo ./port-monitor.sh -l

# Look for ports you don't recognize
# Then identify what's using them with:
sudo lsof -i :PORTNUM

# Or check with netstat:
sudo netstat -tlnp | grep PORTNUM
```

---

## Real-World Scenarios

### Scenario 1: Docker Container Can't Reach Network

```bash
# Container reports network error
docker exec CONTAINER ./network-health-check.sh -q

# Check host networking
./network-health-check.sh

# Check port mappings
sudo ./port-monitor.sh -p CONTAINERPORT
```

### Scenario 2: Web Application Deployment

```bash
# Before deploying to port 8080:
sudo ./port-monitor.sh -p 8080  # Verify port is free

# After deployment:
sudo ./port-monitor.sh -w 2 -p 8080  # Monitor connections

# Verify health:
./network-health-check.sh -h localhost:8080
```

### Scenario 3: Database Server Issues

```bash
# Is MySQL accepting connections?
sudo ./port-monitor.sh -p 3306

# Is it in weird connection state?
sudo ./port-monitor.sh -c

# Quick health check:
./network-health-check.sh --verbose
```

### Scenario 4: Network Reconfiguration

```bash
# Before: Document current state
./network-health-check.sh --full > before.txt
sudo ./port-monitor.sh -l > ports-before.txt

# After: Verify no regression
./network-health-check.sh --full > after.txt
sudo ./port-monitor.sh -l > ports-after.txt

# Compare:
diff before.txt after.txt
```

---

## Performance & Safety

### Performance Impact
- **port-monitor.sh:** Minimal - just queries `/proc` and kernel
- **network-health-check.sh:** Low - runs quick tests, completes in <10 seconds

### Safety Notes
- ✅ Scripts are read-only by default (no configuration changes)
- ✅ Safe to run multiple times
- ✅ Can run with or without sudo (more info with sudo)
- ⚠️ `sudo` needed to see process names and some diagnostics
- ⚠️ tcpdump/packet capture requires root

### Running in Production
```bash
# Schedule periodic health checks
crontab -e

# Add:
# Check network every 5 minutes
*/5 * * * * /path/to/network-health-check.sh >> /var/log/network-health.log

# Monitor ports every hour
0 * * * * sudo /path/to/port-monitor.sh -l >> /var/log/port-monitor.log
```

---

## Customization

### Modify Check Host
Edit the `CHECK_HOST` variable in `network-health-check.sh`:

```bash
# Change from Google DNS
CHECK_HOST="8.8.8.8"

# To your own server
CHECK_HOST="192.168.1.1"
```

### Add Custom Checks
Add functions to either script for your specific needs:

```bash
check_custom() {
    print_section "My Custom Check"
    # Your code here
    check_result "My Check Name" "PASS" "Details"
}
```

### Color Customization
Edit color variables at the top:

```bash
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
# ... customize as needed
```

---

## Troubleshooting the Scripts

| Issue | Solution |
|-------|----------|
| "Permission denied" | Run with `sudo` or make executable: `chmod +x script.sh` |
| "ss: command not found" | Install: `sudo apt-get install iproute2` |
| "dig: command not found" | Install: `sudo apt-get install dnsutils` |
| "No output" | Check: `bash script.sh` with explicit shell |
| Colors not showing | Pipe to `cat` to see raw codes: `./script.sh \| cat` |

---

## Integration with Other Tools

### With Monitoring Systems
```bash
# Nagios/Icinga check
./network-health-check.sh > /dev/null && echo "OK" || echo "FAIL"

# Export for Prometheus
port_count=$(./port-monitor.sh -l 2>/dev/null | wc -l)
echo "network_ports{type=\"listening\"} $port_count"
```

### With Logging
```bash
# Log all checks
./network-health-check.sh --verbose >> /var/log/network-diagnostics.log 2>&1

# Monitor continuously
watch -n 60 ./network-health-check.sh
```

### With Alerting
```bash
# Alert if critical check fails
./network-health-check.sh && \
  echo "Network OK" || \
  { echo "Network FAIL" | mail -s "Network Alert" admin@example.com; }
```

---

## Further Learning

- Run `./port-monitor.sh --help` for detailed help
- Run `./network-health-check.sh --help` for detailed help
- Check the main module files for command details
- Reference man pages: `man ss`, `man ip`, `man netstat`

---

## Support & Contributing

To extend these scripts:

1. Preserve the `set -euo pipefail` for reliability
2. Add comments for clarity
3. Follow the existing color/formatting conventions
4. Test on both Ubuntu and CentOS
5. Include usage examples in headers

---

**Last Updated:** January 14, 2025  
**Script Version:** 1.0  
**Tested On:** Ubuntu 20.04+, Debian 10+, CentOS 7+

For issues or improvements, review the script comments or refer to the module documentation.
