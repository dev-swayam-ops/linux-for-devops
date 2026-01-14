# 02-commands-cheatsheet.md: Networking Commands Reference

## Quick Access by Use Case

- [View Network Interfaces](#view-network-interfaces)
- [Configure Interfaces](#configure-interfaces)
- [Test Connectivity](#test-connectivity)
- [Check Ports & Services](#check-ports--services)
- [Monitor Network Activity](#monitor-network-activity)
- [DNS & Name Resolution](#dns--name-resolution)
- [Routing & Gateway](#routing--gateway)
- [Network Packet Capture](#network-packet-capture)

---

## View Network Interfaces

### `ip addr show` - Modern Way to View IP Configuration

```bash
# Show all interfaces
ip addr show

# Show specific interface
ip addr show eth0

# Show only IPv4
ip addr show eth0 | grep 'inet '

# Show only IPv6
ip addr show eth0 | grep 'inet6'

# Show in brief format
ip -br addr show
```

**Example Output:**
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 86400sec preferred_lft 86400sec
```

**Understanding the output:**
- `UP,LOWER_UP` = interface is up
- `mtu 1500` = maximum packet size
- `inet 192.168.1.100/24` = IPv4 address with /24 netmask
- `scope global dynamic` = address is dynamic (DHCP)

### `ifconfig` - Legacy Method (Still Works)

```bash
# Show all interfaces
ifconfig

# Show specific interface
ifconfig eth0

# Show only active interfaces (exclude down interfaces)
ifconfig | grep -E '^[^ ]'
```

**Example Output:**
```
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::a00:27ff:fe00:0  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:00:00:00  txqueuelen 1000  (Ethernet)
        RX packets 1234  bytes 567890 (567.8 KB)
        TX packets 1200  bytes 456789 (456.7 KB)
```

**Note:** `ifconfig` is deprecated in newer systems. Use `ip` instead.

### `hostname` - View/Set System Hostname

```bash
# Display current hostname
hostname

# Display fully qualified domain name
hostname -f

# Display domain name
hostname -d

# Display IP address of hostname
hostname -I

# Temporarily set hostname (reverts on reboot)
sudo hostname newhostname
```

### `ethtool` - Interface Details & Diagnostics

```bash
# Show interface statistics and status
ethtool eth0

# Show link status
ethtool eth0 | grep 'Link detected'

# Test interface (requires driver support)
sudo ethtool -t eth0

# Show receive ring buffer
ethtool -g eth0
```

---

## Configure Interfaces

### `ip addr add` - Add IP Address (Temporary)

```bash
# Add a second IP to an interface
sudo ip addr add 192.168.1.200/24 dev eth0

# Add IPv6 address
sudo ip addr add fe80::1/10 dev eth0

# Remove an IP address
sudo ip addr del 192.168.1.200/24 dev eth0
```

**Note:** These changes are temporary and lost on reboot. For permanent changes, edit network configuration files.

### Permanent Interface Configuration (Ubuntu/Debian)

**File: `/etc/netplan/00-installer-config.yaml`** (modern Ubuntu)

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
        use-dns: true
```

**For static IP:**
```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

**Apply changes:**
```bash
sudo netplan apply
```

### Permanent Configuration (RHEL/CentOS)

**File: `/etc/sysconfig/network-scripts/ifcfg-eth0`**

```bash
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

**Restart networking:**
```bash
sudo systemctl restart network
```

### `ip link set` - Bring Interface Up/Down

```bash
# Bring interface up
sudo ip link set eth0 up

# Bring interface down
sudo ip link set eth0 down

# Check interface status
ip link show eth0

# Change MTU (max packet size)
sudo ip link set eth0 mtu 1600
```

---

## Test Connectivity

### `ping` - Test Basic Connectivity

```bash
# Ping a host (press Ctrl+C to stop)
ping 8.8.8.8

# Ping a hostname
ping google.com

# Send specific number of packets (don't wait)
ping -c 5 8.8.8.8

# Show round-trip times
ping -c 5 -i 0.5 8.8.8.8  # 0.5 sec interval

# Larger packet size (test MTU)
ping -s 1472 8.8.8.8      # Maximum before fragmentation
```

**Example Output:**
```
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=15.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=15.1 ms

--- 8.8.8.8 statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4102ms
rtt min/avg/max/mdev = 15.1/15.4/15.7/0.2 ms
```

**Understanding:** `min/avg/max` = round-trip times, `packet loss` = reliability indicator

### `traceroute` - Show Path to Host

```bash
# Trace route to a host
traceroute 8.8.8.8

# Use UDP instead of ICMP (gets past some firewalls)
traceroute -U 8.8.8.8

# Limit number of hops
traceroute -m 10 8.8.8.8

# Don't resolve hostnames (faster)
traceroute -n 8.8.8.8
```

**Example Output:**
```
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  router.home (192.168.1.1)  1.234 ms  1.111 ms  1.098 ms
 2  * * *                                           (timeout)
 3  203.0.113.1 (203.0.113.1)  8.765 ms  8.654 ms  8.543 ms
 4  8.8.8.8 (8.8.8.8)  15.432 ms  15.321 ms  15.210 ms
```

**Understanding:** Each hop shows the path a packet takes. `* * *` means that hop didn't respond.

### `telnet` - Test TCP Connectivity to Port

```bash
# Test if port is open (quit with Ctrl+])
telnet 192.168.1.1 22

# Test web server
telnet example.com 80

# Send HTTP request and see response
telnet example.com 80
GET / HTTP/1.0
[press Enter twice]
```

**Note:** Telnet is insecure. Use SSH for remote management. But telnet is useful for testing port connectivity.

### `nc` (netcat) - Connection Test & Data Transfer

```bash
# Test if port is open (-z = no data transfer)
nc -zv 192.168.1.100 22

# Test multiple ports
nc -zv 192.168.1.100 22 80 443

# Set timeout for test (don't wait forever)
nc -zv -w 2 192.168.1.100 22

# Port scan a range
nc -zv 192.168.1.100 1-1000

# Listen on port for incoming connections
nc -l 5000

# Connect to listening port
nc 192.168.1.100 5000
```

---

## Check Ports & Services

### `netstat` - Network Statistics (Legacy)

```bash
# Show all listening ports (both TCP and UDP)
netstat -tlnp

# Show only TCP listening
netstat -tlnp

# Show only UDP
netstat -ulnp

# Show established connections
netstat -anp | grep ESTABLISHED

# Show listening on specific port
netstat -tlnp | grep :22

# Show all connections (including time-wait)
netstat -an
```

**Example Output:**
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN      1234/mysqld
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      5678/sshd
tcp        0      0 192.168.1.100:22        192.168.1.50:54321      ESTABLISHED 5678/sshd
```

**Key flags:**
- `-t` = TCP
- `-u` = UDP
- `-l` = Listening
- `-n` = Numeric (don't resolve names)
- `-p` = Show PID/Program name
- `-a` = All sockets

### `ss` - Socket Statistics (Modern, Recommended)

```bash
# Show all listening TCP ports
ss -tlnp

# Show all listening UDP ports
ss -ulnp

# Show all sockets (listening and established)
ss -anp

# Show established connections only
ss -anp | grep ESTAB

# Count sockets by state
ss -anp | grep -E 'State|ESTAB' | sort | uniq -c

# Watch sockets in real-time
watch -n 1 'ss -anp'

# Show sockets for specific port
ss -anp | grep :8080

# Show statistics
ss -s
```

**Example Output:**
```
Netid State      Recv-Q Send-Q Local Address:Port    Peer Address:Port Process
tcp   LISTEN     0      128    0.0.0.0:22           0.0.0.0:*          users:(("sshd",pid=5678,fd=4))
tcp   ESTAB      0      0      192.168.1.100:22     192.168.1.50:54321 users:(("sshd",pid=6789,fd=5))
```

### `lsof` - List Open Files (Shows Processes Using Ports)

```bash
# Show all open network connections
lsof -i

# Show specific port
lsof -i :22

# Show specific process
lsof -i -p 1234

# Show TCP only
lsof -i -P -n | grep TCP

# Show what process is listening on all ports
lsof -i -P -n | grep LISTEN

# Show connections to specific host
lsof -i@192.168.1.1
```

**Example Output:**
```
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd     5678 root    4u  IPv4  12345      0t0  TCP *:22 (LISTEN)
sshd     6789 root    5u  IPv4  12346      0t0  TCP 192.168.1.100:22->192.168.1.50:54321 (ESTABLISHED)
```

### `nmap` - Network Port Scanner

```bash
# Scan all ports on a host
nmap 192.168.1.100

# Scan specific ports
nmap -p 22,80,443 192.168.1.100

# Scan common ports only
nmap -F 192.168.1.100

# Scan with service detection
nmap -sV 192.168.1.100

# Scan a subnet
nmap 192.168.1.0/24

# Aggressive scan (slow but detailed)
nmap -A 192.168.1.100

# Scan without host discovery (assume host is up)
nmap -Pn 192.168.1.100
```

**⚠️ Important:** Only scan systems you own or have permission to scan. Unauthorized port scanning may be illegal.

---

## Monitor Network Activity

### `ifstat` - Interface Statistics

```bash
# Show real-time interface statistics
ifstat

# Show every 2 seconds
ifstat -i 2

# Monitor specific interface
ifstat -i eth0 1
```

**Example Output:**
```
     eth0                
 RX Kbps    TX Kbps
  12.34      56.78
  15.23      60.45
```

### `iftop` - Top for Network Interfaces

```bash
# Show real-time bandwidth usage
iftop

# Monitor specific interface
iftop -i eth0

# Show ports
iftop -P

# Aggregate traffic by source IP
iftop -n
```

### `nethogs` - Per-Process Network Usage

```bash
# Show bandwidth by process
sudo nethogs

# Monitor specific interface
sudo nethogs eth0

# Refresh every 2 seconds
sudo nethogs -d 2
```

---

## DNS & Name Resolution

### `nslookup` - Query DNS

```bash
# Look up IP for hostname
nslookup google.com

# Use specific DNS server
nslookup google.com 8.8.8.8

# Reverse DNS (IP to hostname)
nslookup 142.251.32.46

# Find mail servers
nslookup -type=MX gmail.com

# Find all records
nslookup -type=ANY example.com
```

**Example Output:**
```
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   google.com
Address: 142.251.32.46
```

### `dig` - DNS Lookup (More Detailed)

```bash
# Basic lookup
dig google.com

# Short output
dig google.com +short

# Query specific record type
dig google.com MX

# Find mail servers
dig gmail.com MX +short

# Trace DNS resolution path
dig google.com +trace

# Use specific DNS server
dig @8.8.8.8 google.com

# Reverse DNS
dig -x 142.251.32.46
```

**Example Output:**
```
; <<>> DiG 9.16.1-Ubuntu <<>> google.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
...
google.com.		123	IN	A	142.251.32.46
```

### `host` - Simple DNS Lookup

```bash
# Basic lookup
host google.com

# Find mail servers
host -t MX gmail.com

# Verbose output
host -v google.com

# Reverse DNS
host 142.251.32.46
```

**Example Output:**
```
google.com has address 142.251.32.46
google.com has IPv6 address 2607:f8b0:4004:808::200e
google.com mail is handled by 10 smtp.google.com.
```

### `getent` - Query System Databases

```bash
# Look up in /etc/hosts first
getent hosts localhost

# Look up hostname from all sources (files + DNS)
getent hosts google.com

# Check if in /etc/hosts
getent hosts 192.168.1.100
```

### Check DNS Configuration

```bash
# View DNS servers being used
cat /etc/resolv.conf

# Modern Ubuntu (systemd-resolved)
cat /run/systemd/resolve/resolv.conf

# Systemd DNS configuration
cat /etc/systemd/resolved.conf

# Flush DNS cache (systemd)
sudo systemd-resolve --flush-caches
```

---

## Routing & Gateway

### `route` - View & Modify Routing Table

```bash
# Show routing table
route -n

# Show in table format with interface names
route

# Add a route
sudo route add -net 192.168.2.0/24 gw 192.168.1.254 dev eth0

# Add default gateway
sudo route add default gw 192.168.1.1 eth0

# Remove a route
sudo route del -net 192.168.2.0/24
```

**Example Output:**
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         192.168.1.1     0.0.0.0         UG    100    0        0 eth0
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0
127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
```

### `ip route` - Modern Routing Commands

```bash
# Show routing table
ip route show

# Add a route
sudo ip route add 192.168.2.0/24 via 192.168.1.254 dev eth0

# Add default route
sudo ip route add default via 192.168.1.1 dev eth0

# Remove a route
sudo ip route del 192.168.2.0/24 via 192.168.1.254

# Show route to specific destination
ip route show to 8.8.8.8

# Add temporary route (default gateway if none)
sudo ip route add 10.0.0.0/8 via 192.168.1.1
```

### `arp` - Address Resolution Protocol

```bash
# Show ARP table (IP to MAC mappings)
arp -a

# Show for specific interface
arp -i eth0

# Add static ARP entry
sudo arp -s 192.168.1.100 aa:bb:cc:dd:ee:ff

# Delete ARP entry
sudo arp -d 192.168.1.100

# Show in numeric format
arp -n
```

**Example Output:**
```
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.1.1              ether   aa:bb:cc:dd:ee:ff   C                     eth0
192.168.1.50             ether   11:22:33:44:55:66   C                     eth0
```

---

## Network Packet Capture

### `tcpdump` - Capture Network Traffic

```bash
# Capture all traffic on interface (Ctrl+C to stop)
sudo tcpdump -i eth0

# Capture to file
sudo tcpdump -i eth0 -w traffic.pcap

# Read captured file
tcpdump -r traffic.pcap

# Filter by host
sudo tcpdump -i eth0 host 8.8.8.8

# Filter by port
sudo tcpdump -i eth0 port 22

# Filter by protocol
sudo tcpdump -i eth0 icmp       # ICMP (ping)
sudo tcpdump -i eth0 tcp        # TCP only

# Show packet contents in ASCII
sudo tcpdump -i eth0 -A

# Verbose output (show more details)
sudo tcpdump -i eth0 -v

# Simple expression
sudo tcpdump -i eth0 'src host 192.168.1.50 and dst port 22'
```

**Example Output:**
```
tcpdump: listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
14:23:45.123456 IP 192.168.1.50.54321 > 192.168.1.100.22: Flags [S], seq 1234567890
14:23:45.234567 IP 192.168.1.100.22 > 192.168.1.50.54321: Flags [S.], seq 0987654321
```

---

## Command Quick Reference Table

| Task | Command | Notes |
|------|---------|-------|
| View interfaces | `ip addr show` | Modern, preferred |
| View interfaces | `ifconfig` | Legacy but still works |
| View hostname | `hostname` | Show or set system name |
| Test connectivity | `ping -c 5 HOST` | Send 5 packets then stop |
| Trace path | `traceroute -n HOST` | Don't resolve names (faster) |
| Test port | `nc -zv HOST PORT` | Quick port check |
| List listening | `ss -tlnp` | TCP listening, numeric, process |
| List all sockets | `ss -anp` | All sockets with process names |
| Check port usage | `lsof -i :PORT` | Show process using port |
| Scan ports | `nmap -p PORT HOST` | Only scan specified ports |
| DNS lookup | `dig DOMAIN +short` | Simple DNS response |
| Reverse DNS | `dig -x IP` | IP to hostname |
| View routing | `ip route show` | Modern routing table |
| Add route | `sudo ip route add NET via GW` | Temporary route |
| Capture traffic | `sudo tcpdump -i eth0` | Real-time packet capture |
| Monitor bandwidth | `iftop` | Real-time per-interface |

---

## Common Patterns & Examples

### Pattern 1: "Service won't start - port already in use"
```bash
# Find what's using port 8080
lsof -i :8080
# OR
ss -tlnp | grep :8080
# Result: PID 1234 is using port 8080
# Kill it: sudo kill 1234
```

### Pattern 2: "Can't reach server - is it online?"
```bash
ping SERVER                 # Is it alive?
traceroute SERVER          # Where does it stop?
ssh -v user@SERVER         # Verbose SSH to see connection attempt
sudo tcpdump -i eth0 host SERVER  # See actual packets
```

### Pattern 3: "Which ports should be listening?"
```bash
# Production web server should have
ss -tlnp | grep -E ':(22|80|443)'

# Expected output:
# 22   - SSH (management)
# 80   - HTTP (web)
# 443  - HTTPS (web)
```

### Pattern 4: "Set up static IP on Ubuntu"
```bash
# Edit netplan config
sudo nano /etc/netplan/00-installer-config.yaml

# Add:
# ethernets:
#   eth0:
#     addresses: [192.168.1.100/24]
#     gateway4: 192.168.1.1
#     nameservers:
#       addresses: [8.8.8.8, 8.8.4.4]

sudo netplan apply
sudo netplan --debug apply  # Show what changed
```

### Pattern 5: "Check what DNS is being used"
```bash
cat /run/systemd/resolve/resolv.conf  # Modern Ubuntu
cat /etc/resolv.conf                  # Traditional method
systemd-resolve --status              # Systemd DNS status
nslookup google.com                   # Test DNS works
```

---

## RHEL/CentOS Differences

### Checking Interfaces
```bash
# RHEL/CentOS also uses ip (same as Ubuntu now)
ip addr show

# Older RHEL versions
cat /etc/sysconfig/network-scripts/ifcfg-eth0
```

### Restarting Network
```bash
# Modern RHEL/CentOS 8+
sudo systemctl restart network

# Older versions
sudo /etc/init.d/network restart
```

### DNS Configuration (RHEL/CentOS)
```bash
# Traditional
cat /etc/resolv.conf

# Edit
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0
# Add: DNS1=8.8.8.8

# Modern (systemd)
sudo systemctl restart systemd-resolved
```

---

**Next:** Move to [03-hands-on-labs.md](03-hands-on-labs.md) to practice these commands with real exercises.
