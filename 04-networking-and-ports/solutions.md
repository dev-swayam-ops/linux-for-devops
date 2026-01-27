# Networking and Ports: Solutions

## Exercise 1: Network Interface Discovery

**Solution:**

```bash
# List all network interfaces
ip addr show
# Output:
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
#     inet 127.0.0.1/8 scope host lo
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
#     inet 192.168.1.10/24 brd 192.168.1.255
#     link/ether 00:16:3e:0c:96:c0 brd ff:ff:ff:ff:ff:ff

# Show interface status
ip link show
# Output shows UP or DOWN status

# Alternative: ifconfig (older)
ifconfig

# Get MAC address
ip link show eth0
# or
cat /sys/class/net/eth0/address
```

**Explanation:** `lo` is loopback (localhost), `eth0` is first physical interface. MAC addresses start with `link/ether`.

---

## Exercise 2: IP Address and Routing

**Solution:**

```bash
# Display IP address
ip addr show eth0
# Output:
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>
#     inet 192.168.1.10/24 brd 192.168.1.255

# Show routing table
ip route show
# Output:
# default via 192.168.1.1 dev eth0 proto kernel scope link src 192.168.1.10
# 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.10

# Alternative: route command
route -n
# Output:
# Destination     Gateway         Netmask         Interface
# 0.0.0.0         192.168.1.1     0.0.0.0         eth0
# 192.168.1.0     0.0.0.0         255.255.255.0   eth0

# Extract gateway
ip route | grep default | awk '{print $3}'
# Output: 192.168.1.1

# Calculate network address from IP 192.168.1.10/24
# /24 = 255.255.255.0 netmask
# Network = 192.168.1.0
# Broadcast = 192.168.1.255
```

**Explanation:**
- `/24` = 255.255.255.0 netmask
- First 24 bits are network, last 8 bits are hosts
- Network = 192.168.1.0, Broadcast = 192.168.1.255

---

## Exercise 3: Check Listening Ports

**Solution:**

```bash
# List all listening TCP ports
ss -tlnp
# Output:
# LISTEN  0  128  0.0.0.0:22   0.0.0.0:*  users:(("sshd",pid=1234))
# LISTEN  0  128  0.0.0.0:80   0.0.0.0:*  users:(("apache2",pid=5678))

# List listening UDP ports
ss -ulnp
# Output:
# UNCONN  0  0  0.0.0.0:53  0.0.0.0:*  users:(("systemd-resolve",pid=890))

# Combined TCP and UDP
ss -tlnup

# Check specific port
ss -tlnp | grep :22
# Output:
# LISTEN  0  128  0.0.0.0:22  0.0.0.0:*  users:(("sshd",pid=1234))

# Show process names with ports
ss -tlnp | grep -E "LISTEN|Proto"
```

**Explanation:**
- `-t` = TCP, `-u` = UDP, `-l` = LISTEN, `-n` = numeric, `-p` = process
- Port 22 = SSH, 80 = HTTP, 443 = HTTPS

---

## Exercise 4: Port and Service Mapping

**Solution:**

```bash
# Start HTTP server in background
python3 -m http.server 8000 &
# Output: [1] 12345

# Verify port 8000 is listening
ss -tlnp | grep 8000
# Output:
# LISTEN  0  128  0.0.0.0:8000  0.0.0.0:*  users:(("python3",pid=12345))

# Get details with lsof
lsof -i :8000
# Output:
# COMMAND    PID USER FD   TYPE DEVICE SIZE/OFF NODE NAME
# python3 12345 user 3u  IPv4  98765      0t0  TCP *:8000 (LISTEN)

# Kill the process
kill 12345
# or find by port and kill
fuser -k 8000/tcp

# Verify port is released
ss -tlnp | grep 8000
# (no output = port is free)
```

**Explanation:** Services bind to ports. When process exits, port is released.

---

## Exercise 5: Network Connectivity Testing

**Solution:**

```bash
# Ping localhost (4 packets)
ping -c 4 127.0.0.1
# Output:
# PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
# 64 bytes from 127.0.0.1: icmp_seq=1 time=0.031 ms
# 64 bytes from 127.0.0.1: icmp_seq=2 time=0.025 ms
# 64 bytes from 127.0.0.1: icmp_seq=3 time=0.028 ms
# 64 bytes from 127.0.0.1: icmp_seq=4 time=0.029 ms
# 4 packets transmitted, 4 received, 0% packet loss, time 90ms

# Ping default gateway
ping -c 4 192.168.1.1

# Ping public DNS
ping -c 4 8.8.8.8
# Output may show different RTT based on network distance

# Check packet loss
ping -c 10 example.com | grep "packet loss"
# Example: 0% packet loss = all packets received
# Example: 10% packet loss = 1 packet lost out of 10
```

**Explanation:**
- RTT = milliseconds for packet round trip
- 0% loss = all packets received (good)
- High RTT = slow/distant network

---

## Exercise 6: DNS and Name Resolution

**Solution:**

```bash
# Resolve hostname to IP
nslookup google.com
# Output:
# Name: google.com
# Address: 142.251.32.14

# Detailed DNS query
dig google.com
# Output:
# ;; ANSWER SECTION:
# google.com. 299 IN A 142.251.32.14

# Reverse DNS lookup
nslookup 8.8.8.8
# Output: 8.8.8.8.in-addr.arpa name = dns.google.

# Check configured DNS servers
cat /etc/resolv.conf
# Output:
# nameserver 8.8.8.8
# nameserver 8.8.4.4

# Show DNS statistics
dig google.com +stats

# Query specific nameserver
dig @8.8.8.8 google.com
```

**Explanation:**
- Resolves domain names to IP addresses
- DNS servers listed in `/etc/resolv.conf`
- Forward DNS: domain → IP
- Reverse DNS: IP → domain

---

## Exercise 7: Trace Route Analysis

**Solution:**

```bash
# Trace route to google.com
traceroute google.com
# Output:
# traceroute to google.com (142.251.32.14), 30 hops max, 60 byte packets
#  1  192.168.1.1  2.345 ms
#  2  isp.gateway  5.123 ms
#  3  core-router  25.456 ms
#  4  142.251.32.14  45.678 ms

# Limit to 15 hops
traceroute -m 15 google.com

# Count hops
traceroute google.com | wc -l

# Identify slow hops (high RTT)
# Note which hop has highest time value

# Save output to file
traceroute google.com > traceroute.txt
```

**Explanation:**
- Shows network path to destination
- Each hop shows latency (ms)
- More hops = longer route
- Rising RTT indicates network congestion

---

## Exercise 8: Network Statistics and Monitoring

**Solution:**

```bash
# Display protocol statistics
ss -s
# Output:
# TCP:   123 ESTABLISHED, 15 LISTEN, 0 CLOSED
# UDP:   5 RX-Q, 0 TX-Q
# INET:  128 total, 15 UDP, 0 TCP, 123 SCTP

# Show TCP statistics
ss -t
# Lists all TCP connections with states

# Show connections by state
ss -t | grep ESTABLISHED | wc -l
# Count established connections

# Show listening sockets
ss -l | grep LISTEN

# Detailed statistics
netstat -s
# Output:
# Ip:
#     234 total packets received
#     0 forwarded
#     0 incoming packets discarded
```

**Explanation:**
- ESTABLISHED = active connection
- LISTEN = waiting for connections
- TIME_WAIT = connection closed, waiting timeout

---

## Exercise 9: Open Files and Network Sockets

**Solution:**

```bash
# List all network files
lsof -i
# Output:
# COMMAND    PID  USER FD  TYPE DEVICE SIZE NODE NAME
# sshd      1234  root 3u  IPv4      0    TCP *:22 (LISTEN)
# sshd      5678  user 3u  IPv4      0    TCP 192.168.1.10:22->192.168.1.20:54321 (ESTABLISHED)

# Show protocol and port numbers
lsof -i -P -n

# Filter TCP connections
ss -t
# Output shows TCP connections with state

# Filter by user
lsof -i -u username

# Find specific service connections
lsof -i -p $(pgrep -f "python3")
# Shows all network files for python3 process

# Show established connections
ss -tan | grep ESTABLISHED
```

**Explanation:**
- lsof = list open files
- `-i` = show network files
- Shows local and remote addresses
- PID identifies which process owns connection

---

## Exercise 10: Network Troubleshooting Scenario

**Solution:**

```bash
# Test connectivity to google.com

# 1. DNS resolution
nslookup google.com
# Output: IP address

# 2. Ping test
ping -c 4 google.com
# Output: packet loss, RTT times

# 3. Trace route
traceroute -m 15 google.com
# Output: hops and latencies

# 4. Port connectivity
telnet google.com 443
# or
nc -zv google.com 443
# Output: Connection successful/refused

# Create summary report
cat > connectivity_report.txt << 'EOF'
=== Connectivity Report ===
Hostname: google.com
IP Address: $(nslookup google.com | grep "Address:" | tail -1)
Ping Status: $(ping -c 1 -q google.com | grep "packet loss")
Route Hops: $(traceroute -m 15 google.com | tail -1 | awk '{print $1}')
Port 443 (HTTPS): $(nc -zv google.com 443 2>&1)
Time: $(date)
EOF

cat connectivity_report.txt
```

**Explanation:** Troubleshooting follows logical progression: DNS → Ping → Route → Ports.

---

**Bonus: Network Interface Configuration**

**Solution:**

```bash
# Detailed interface info
ip addr show eth0
# Output:
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
#     inet 192.168.1.10/24 brd 192.168.1.255

# Show interface statistics
ip -s link show eth0
# Output:
# RX: bytes packets errors dropped overrun
# TX: bytes packets errors dropped overrun

# Check speed/duplex (if available)
ethtool eth0 | grep Speed
# Output: Speed: 1000Mb/s

# Calculate network details
# IP: 192.168.1.10/24
# Netmask: 255.255.255.0
# Network: 192.168.1.0
# Broadcast: 192.168.1.255
# Usable IPs: 192.168.1.1 to 192.168.1.254 (254 hosts)
```

**Explanation:**
- MTU = Maximum Transmission Unit (usually 1500)
- RX/TX = Receive/Transmit bytes
- /24 netmask = 256 total addresses, 254 usable
