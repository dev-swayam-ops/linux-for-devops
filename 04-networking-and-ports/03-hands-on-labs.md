# 03-hands-on-labs.md: Practical Networking Labs

## Lab Overview

These labs are designed to be completed sequentially. Each builds on the previous ones. They should take 90-120 minutes total to complete.

**Environment Requirements:**
- Ubuntu 20.04+ or Debian 10+ (Preferred for these labs)
- Root or sudo access
- Two network interfaces recommended (eth0 + loopback is minimum)
- Internet connection for some tests

**Important Safety Notes:**
- ⚠️ Use a VM or test system - some changes affect connectivity
- ⚠️ Always run cleanup commands at the end of each lab
- ⚠️ If you lose connectivity, reboot to restore defaults
- ✅ All labs are designed to be non-destructive with cleanup

---

## Lab 1: Discover Your Network Configuration

### Goal
Understand your system's current network setup - interfaces, IP addresses, and basic connectivity.

### Setup
No special setup needed. Just open a terminal.

### Steps

**Step 1: List all network interfaces**
```bash
ip addr show
```

Expected output should show:
- Loopback interface (lo) with 127.0.0.1
- At least one Ethernet/WiFi interface with an IP address

Record:
- Interface name: ________________
- IPv4 address: ________________
- IPv6 address: ________________

**Step 2: Check interface names specifically**
```bash
ip link show | grep -E "^\d|link/ether" | head -6
```

Record all interfaces:
```
______________________________
______________________________
______________________________
```

**Step 3: Get more details about your primary interface**
```bash
# Replace eth0 with your interface name
ip addr show eth0
```

Record:
- MAC address: ________________
- MTU size: ________________

**Step 4: Check if you can reach the internet**
```bash
ping -c 3 8.8.8.8
```

Expected: All 3 packets should receive responses (0% loss)

**Step 5: See your DNS configuration**
```bash
cat /run/systemd/resolve/resolv.conf | grep nameserver
```

Record first DNS server: ________________

### Expected Output

```
$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    link/ether 08:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic eth0

$ ping -c 3 8.8.8.8
64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=15.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=15.1 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=15.3 ms
```

### Verification Checklist

- ☐ Can see at least 2 network interfaces (loopback + one real)
- ☐ Loopback has IP 127.0.0.1
- ☐ Primary interface has an IP address
- ☐ Can ping 8.8.8.8 successfully (0% packet loss)
- ☐ DNS server listed in resolv.conf

### Cleanup

No cleanup needed - this was read-only.

---

## Lab 2: Test Network Connectivity

### Goal
Learn various ways to test if hosts are reachable and understand connection paths.

### Setup

No special setup needed.

### Steps

**Step 1: Basic ping test to public host**
```bash
ping -c 4 google.com
```

Record the average round-trip time: __________ ms

**Step 2: Ping to multiple hosts**
```bash
# Test different types of hosts
ping -c 1 8.8.8.8           # IP address
ping -c 1 google.com        # Domain name
ping -c 1 127.0.0.1         # Localhost
ping -c 1 192.168.1.1       # Your gateway (adjust if different)
```

**Step 3: Trace the path to a host**
```bash
traceroute -m 10 8.8.8.8
```

Count how many hops to reach 8.8.8.8: __________

**Step 4: Test connectivity to specific port (no SSH needed)**
```bash
# Test if port 80 is open on google.com
nc -zv google.com 80
```

Expected: Connection successful or timed out (either is ok)

**Step 5: Find your default gateway**
```bash
ip route | grep default
```

Record gateway IP: ________________

**Step 6: Test connectivity to your gateway**
```bash
# Replace with your gateway from Step 5
ping -c 1 192.168.1.1
```

Should be very fast (< 1ms)

### Expected Output

```
$ ping -c 4 google.com
PING google.com (142.251.35.14) 56(84) bytes of data.
64 bytes from mia07s45-in-f14.1e100.net (142.251.35.14): icmp_seq=1 ttl=119 time=15.2 ms
4 packets transmitted, 4 received, 0% packet loss

$ traceroute -m 10 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 10 hops max, 60 byte packets
 1  _gateway (192.168.1.1)  1.234 ms  1.111 ms  1.098 ms
 2  * * *
 3  203.0.113.5 (203.0.113.5)  8.765 ms  8.654 ms  8.543 ms
 4  8.8.8.8 (8.8.8.8)  15.432 ms  15.321 ms  15.210 ms

$ ip route | grep default
default via 192.168.1.1 dev eth0 proto dhcp metric 100
```

### Verification Checklist

- ☐ Can ping google.com successfully
- ☐ Round-trip time is under 100ms (indicates good connectivity)
- ☐ Traceroute shows at least 2 hops
- ☐ nc test completes (success or timeout ok)
- ☐ Can ping your gateway
- ☐ Gateway ping time is < 5ms (local network)

### Cleanup

No cleanup needed - this was read-only.

---

## Lab 3: Discover Services Listening on Ports

### Goal
Learn which services are listening for connections on your system and which ports they're using.

### Setup

No special setup needed. Services should already be running.

### Steps

**Step 1: Show all listening TCP ports**
```bash
ss -tlnp
```

Record all services with ports:
```
Port: _________ Service: _________________________
Port: _________ Service: _________________________
Port: _________ Service: _________________________
```

**Step 2: Check if SSH is listening (default port 22)**
```bash
ss -tlnp | grep 22
```

Expected: Should see sshd listening (unless SSH not installed)

**Step 3: Show all listening UDP ports**
```bash
ss -ulnp
```

Expected: Might see DNS (port 53) if systemd-resolved is running

**Step 4: Show all established connections**
```bash
ss -anp | grep ESTAB
```

This shows active connections. Should be few if you're not actively using network services.

**Step 5: Check what's using a specific port (if something is)**
```bash
# Find process using port 22
lsof -i :22
```

**Step 6: Get statistics on all sockets**
```bash
ss -s
```

This shows summary of socket usage (helpful for debugging connection issues).

### Expected Output

```
$ ss -tlnp
State      Recv-Q Send-Q Local Address:Port     Peer Address:Port  Process
LISTEN     0      128        0.0.0.0:22              0.0.0.0:*      users:(("sshd",pid=5678,fd=4))
LISTEN     0      128           [::]:22                 [::]:*      users:(("sshd",pid=5678,fd=5))

$ ss -ulnp
State      Recv-Q Send-Q Local Address:Port     Peer Address:Port  Process
UNCONN     0      0      127.0.0.53%lo:53              0.0.0.0:*      users:(("systemd-resolve",pid=1234,fd=12))

$ ss -s
TCP:   0 ESTABLISHED, 1 SYN-SENT, 0 TIME-WAIT
INET:  2 sockets
TCP6:  1 ESTABLISHED, 0 SYN-SENT, 0 TIME-WAIT
INET6: 1 sockets
```

### Verification Checklist

- ☐ ss -tlnp shows at least 1 listening service
- ☐ SSH (port 22) shown if installed
- ☐ Can identify process names from output
- ☐ lsof -i :22 shows sshd process
- ☐ Socket statistics make sense (few connections = low usage)

### Cleanup

No cleanup needed - this was read-only.

---

## Lab 4: Understand Sockets and Connection States

### Goal
Learn about different connection states and what they mean for troubleshooting.

### Setup

Install netcat to create test connections:
```bash
sudo apt-get install -y netcat
```

### Steps

**Step 1: View current socket states**
```bash
ss -an | grep -E "State|LISTEN|ESTAB|TIME_WAIT" | head -20
```

Record what states you see:
```
_________________________
_________________________
_________________________
```

**Step 2: Set up a listening socket**

In terminal 1, create a simple listener:
```bash
nc -l -p 5555
```

(Leaves it running - don't close!)

**Step 3: Check the listening socket (in terminal 2)**
```bash
ss -tlnp | grep 5555
```

You should see LISTEN state on port 5555.

**Step 4: Connect to the listening socket**

In terminal 2:
```bash
nc 127.0.0.1 5555
```

(This creates a connection - leave it running)

**Step 5: Observe the established connection (terminal 3)**
```bash
ss -anp | grep 5555
```

Expected output: Two sockets, one LISTEN, one ESTAB

```
Example output:
LISTEN 0  1         127.0.0.1:5555      0.0.0.0:*   
ESTAB  0  0  127.0.0.1:5555  127.0.0.1:38765
ESTAB  0  0  127.0.0.1:38765 127.0.0.1:5555
```

**Step 6: Close the connection and watch state change**

In terminal 2 (the client), press Ctrl+C to close.

In terminal 3, immediately run:
```bash
ss -anp | grep 5555
```

You might catch a TIME_WAIT state (brief delay before closing).

**Step 7: Close the server**

In terminal 1, press Ctrl+C to close the listener.

### Expected Output

```
$ ss -tlnp | grep 5555
LISTEN 0  1         127.0.0.1:5555      0.0.0.0:*   users:(("nc",pid=12345,fd=3))

$ ss -anp | grep 5555  # (while connected)
LISTEN 0  1         127.0.0.1:5555      0.0.0.0:*   users:(("nc",pid=12345,fd=3))
ESTAB  0  0    127.0.0.1:5555   127.0.0.1:45678    users:(("nc",pid=12346,fd=3))
ESTAB  0  0 127.0.0.1:45678    127.0.0.1:5555    users:(("nc",pid=12346,fd=4))
```

### Verification Checklist

- ☐ Saw LISTEN state when nc was listening
- ☐ Saw ESTAB state when connected
- ☐ Understood that there are 2 sockets for each connection
- ☐ Saw TIME_WAIT state when closing (or at least confirmed it exists)
- ☐ Can map states to actual network events

### Cleanup

Kill any remaining nc processes:
```bash
pkill -f "nc -l"
pkill nc
```

---

## Lab 5: DNS Resolution

### Goal
Understand how DNS works and test name resolution on your system.

### Setup

No special setup needed.

### Steps

**Step 1: Resolve a hostname to IP**
```bash
dig google.com +short
```

Record the IP address returned: ________________

**Step 2: Query for specific record types**
```bash
# Get mail server
dig gmail.com MX +short

# Get name servers
dig gmail.com NS +short

# Get all records (verbose)
dig google.com
```

**Step 3: Use the host command**
```bash
host google.com
```

Compare output with dig (should be same IP).

**Step 4: Reverse DNS lookup**
```bash
dig -x 8.8.8.8
```

Or:
```bash
host 8.8.8.8
```

Record the hostname: ________________

**Step 5: Check what DNS servers your system uses**
```bash
cat /run/systemd/resolve/resolv.conf | grep nameserver
```

Record DNS servers:
```
_________________________
_________________________
```

**Step 6: Query specific DNS server**
```bash
# Query Google's DNS
dig @8.8.8.8 google.com +short

# Query your local DNS
dig @YOUR-DNS-SERVER google.com +short
```

**Step 7: Trace DNS resolution**
```bash
dig google.com +trace +short
```

This shows the chain of nameservers queried to resolve google.com.

### Expected Output

```
$ dig google.com +short
142.251.35.14
2607:f8b0:4004:808::200e

$ dig gmail.com MX +short
5 gmail-smtp-in.l.google.com.
10 alt1.gmail-smtp-in.l.google.com.
20 alt2.gmail-smtp-in.l.google.com.

$ host google.com
google.com has address 142.251.35.14
google.com has IPv6 address 2607:f8b0:4004:808::200e
google.com mail is handled by 10 smtp.google.com.

$ dig -x 8.8.8.8
; <<>> DiG 9.16.1 <<>> -x 8.8.8.8
; (1 server found)
; Got answer:
dns.google has address 8.8.8.8
```

### Verification Checklist

- ☐ dig command returned IP address for google.com
- ☐ host command showed same IP
- ☐ Reverse DNS returned a hostname
- ☐ Can see configured DNS servers
- ☐ Different DNS server returned same IP
- ☐ Trace showed multiple nameservers in chain

### Cleanup

No cleanup needed - this was read-only.

---

## Lab 6: Routing and Gateways

### Goal
Understand how packets are routed and see your system's routing table.

### Setup

No special setup needed.

### Steps

**Step 1: View your routing table**
```bash
ip route show
```

Record the default route:
```
Via: ________________ Dev: ________________
```

**Step 2: Show routing table in traditional format**
```bash
route -n
```

Note: Same information, different format than `ip route show`.

**Step 3: Trace what happens to a local packet**
```bash
# For a host on same network (local)
traceroute 192.168.1.1        # Replace with local network

# For a host on internet
traceroute 8.8.8.8
```

Expected:
- Local host: Usually 1 hop (direct)
- Internet host: Multiple hops through gateway

**Step 4: Check specific route**
```bash
ip route show to 8.8.8.8
```

This shows which route would be used for 8.8.8.8 (should be default route).

**Step 5: See all routes matching a pattern**
```bash
ip route show to 192.168
```

This shows routes for your local network.

**Step 6: (Optional) Add a temporary route**
```bash
# Add a route to a network via a gateway
sudo ip route add 10.0.0.0/8 via 192.168.1.1

# Verify it was added
ip route show | grep 10.0.0.0

# Remove it (cleanup)
sudo ip route del 10.0.0.0/8
```

### Expected Output

```
$ ip route show
default via 192.168.1.1 dev eth0 proto dhcp metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100 metric 100
169.254.0.0/16 dev eth0 proto kernel scope link metric 256

$ route -n
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    100    0        0 eth0
192.168.1.0     0.0.0.0         255.255.255.0   U     100    0        0 eth0
169.254.0.0     0.0.0.0         255.255.0.0     U     256    0        0 eth0

$ traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (192.168.1.1)  1.234 ms  1.111 ms  1.098 ms
 2  * * *
 3  203.0.113.5 (203.0.113.5)  8.765 ms  8.654 ms  8.543 ms
 4  8.8.8.8 (8.8.8.8)  15.432 ms  15.321 ms  15.210 ms
```

### Verification Checklist

- ☐ Can see default route in routing table
- ☐ Local network (192.168.x.x) shows direct connection
- ☐ Understand difference between gateway and interface
- ☐ traceroute to local network shows 1 hop
- ☐ traceroute to internet shows multiple hops
- ☐ Can identify which interface each route uses

### Cleanup

Cleanup temporary route if you added one:
```bash
sudo ip route del 10.0.0.0/8
```

---

## Lab 7: Port Conflicts and Service Management

### Goal
Identify port conflicts and understand how to find which process is using a port.

### Setup

First, let's find an unused port and start a test service:

```bash
# Find a high port that's not in use
ss -tlnp | grep -E ':[5-9][0-9]{3}' | wc -l
```

### Steps

**Step 1: Find all services listening on system**
```bash
ss -tlnp
```

Record how many services are listening: __________

**Step 2: Find which process is using port 22 (SSH)**
```bash
lsof -i :22
```

Record the process name: ________________

**Step 3: Try to bind to an already-used port**
```bash
# Try to start a service on port 22 (will fail)
nc -l -p 22
```

Expected: Will show permission error (22 is reserved) or "Address already in use" error.

**Step 4: Start a service on high port (should work)**
```bash
# Terminal 1 - start listener
nc -l -p 7777

# Terminal 2 - check it's listening
ss -tlnp | grep 7777
```

Verify port 7777 shows in listening state.

**Step 5: Find the process using port 7777**
```bash
lsof -i :7777
```

You should see the nc process with PID.

**Step 6: Check which ports could cause conflicts**
```bash
# Common ports that might have services
ss -tlnp | grep -E ':(22|80|443|3306|5432)'
```

Record which common ports are in use:
```
_________________________
_________________________
_________________________
```

**Step 7: Kill the test service**
```bash
pkill -f "nc -l"
```

Verify it's gone:
```bash
ss -tlnp | grep 7777
```

Should return nothing.

### Expected Output

```
$ lsof -i :22
COMMAND  PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sshd    5678 root    4u  IPv4  23456      0t0  TCP *:22 (LISTEN)

$ ss -tlnp | grep 7777
LISTEN 0  1         0.0.0.0:7777      0.0.0.0:*  users:(("nc",pid=12345,fd=3))

$ lsof -i :7777
COMMAND  PID  USER FD  TYPE DEVICE SIZE/OFF NODE NAME
nc      12345 user  3u IPv4  23457      0t0  TCP localhost:7777 (LISTEN)

$ ss -tlnp | grep -E ':(22|80|443)'
LISTEN 0  128  0.0.0.0:22  0.0.0.0:*  users:(("sshd",pid=5678,fd=4))
```

### Verification Checklist

- ☐ Found SSH service on port 22
- ☐ lsof showed process using port 22
- ☐ Could start service on port 7777
- ☐ lsof correctly identified process using 7777
- ☐ Killing service removed it from listening ports
- ☐ Understand how to troubleshoot port conflicts

### Cleanup

Ensure test service is stopped:
```bash
pkill -f "nc -l"
pkill nc
```

---

## Lab 8: Network Monitoring and Performance

### Goal
Learn to monitor network activity and understand network statistics.

### Setup

Install additional tools:
```bash
sudo apt-get install -y iftop nethogs
```

Note: iftop and nethogs require sudo to run fully.

### Steps

**Step 1: Check interface statistics**
```bash
ip -s link show eth0
```

Record current statistics:
```
RX packets: ________________
TX packets: ________________
RX bytes: ________________
TX bytes: ________________
```

**Step 2: Watch statistics change over time**
```bash
# Monitor eth0 for 5 seconds
watch -n 1 'ip -s link show eth0'  # Press Ctrl+C after a few updates
```

Note how RX/TX packets increase.

**Step 3: Get socket statistics**
```bash
ss -s
```

Record summary:
```
TCP sockets: ________________
UDP sockets: ________________
```

**Step 4: Monitor connections in real-time (optional if you have internet)**
```bash
# Show established connections
watch -n 1 'ss -anp | grep ESTAB'
```

Press Ctrl+C after a few updates.

**Step 5: Check interface speed and status**
```bash
ethtool eth0 | grep -E 'Speed|Duplex|Link'
```

Record interface info:
```
Speed: ________________
Duplex: ________________
Link: ________________
```

**Step 6: View all interface statistics**
```bash
ss -i
```

Shows statistics for all interfaces.

**Step 7: Look for network errors**
```bash
# Check for errors on interface
ip -s link show eth0 | grep -E 'dropped|errors|overrun'
```

Expected: Should be 0 errors for healthy network.

### Expected Output

```
$ ip -s link show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
    RX:  bytes packets errors dropped overrun mcast   
    1234567  89012  0      0       0      0
    TX:  bytes packets errors dropped carrier collsns
    9876543  65432  0      0       0      0

$ ss -s
TCP:   5 ESTABLISHED, 0 SYN-SENT, 0 TIME-WAIT
INET:  7 sockets
TCP6:  1 ESTABLISHED, 0 SYN-SENT, 0 TIME-WAIT
INET6: 1 sockets

$ ethtool eth0 | grep -E 'Speed|Duplex|Link'
    Speed: 1000Mb/s
    Duplex: Full
    Link detected: yes
```

### Verification Checklist

- ☐ Can see interface RX/TX statistics
- ☐ Statistics change when network is active
- ☐ Socket statistics make sense
- ☐ Interface speed/duplex shown
- ☐ No errors reported on interface
- ☐ Can track network performance metrics

### Cleanup

No cleanup needed for this lab.

---

## Bonus: Capture Network Traffic (Optional)

### Goal
Understand what happens at the packet level.

### Setup

tcpdump is usually pre-installed. Verify:
```bash
which tcpdump
```

### Steps

**Step 1: Capture traffic on loopback**
```bash
# Terminal 1 - start capture
sudo tcpdump -i lo -c 10 -A

# While that's running, Terminal 2 - generate traffic
ping -c 5 127.0.0.1
```

The tcpdump should show ICMP packets from ping.

**Step 2: Filter by protocol**
```bash
# Capture only ICMP
sudo tcpdump -i eth0 icmp

# In another terminal, generate ICMP:
ping -c 3 8.8.8.8
```

**Step 3: Capture to file**
```bash
# Capture for 30 seconds
sudo tcpdump -i eth0 -w traffic.pcap -c 100

# While running, generate traffic:
# ping 8.8.8.8 in another terminal

# Read the file
tcpdump -r traffic.pcap
```

### Expected Output

```
$ sudo tcpdump -i lo -c 5 -A
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), snapshot length 262144 bytes
14:23:45.123456 IP localhost.45678 > localhost.5555: Flags [S], seq 1234567890, ...
14:23:45.123457 IP localhost.5555 > localhost.45678: Flags [S.], seq 0987654321, ...
...
```

### Verification Checklist

- ☐ tcpdump captured packets
- ☐ Packets matched protocol filter (ICMP)
- ☐ Could capture to file
- ☐ Could read captured file
- ☐ Understand packet structure basics

### Cleanup

Remove captured file:
```bash
rm -f traffic.pcap
```

---

## Summary of Labs Completed

After completing all labs, you should understand:

1. **Lab 1** - How to view and understand your network configuration
2. **Lab 2** - How to test connectivity to remote hosts
3. **Lab 3** - How to find what services are listening on your system
4. **Lab 4** - How socket connections work and states they go through
5. **Lab 5** - How DNS resolution works on your system
6. **Lab 6** - How routing tables direct traffic
7. **Lab 7** - How to identify port conflicts and services
8. **Lab 8** - How to monitor network performance

---

## Troubleshooting If Labs Fail

| Issue | Solution |
|-------|----------|
| "Permission denied" | Add `sudo` to the command |
| "Command not found" | Install the package: `sudo apt-get install PACKAGE` |
| "Connection refused" | Service not listening or firewall blocking |
| "No route to host" | Check routing with `ip route show` |
| "DNS resolution failed" | Check `/run/systemd/resolve/resolv.conf` |
| "Address already in use" | Another service using that port (find with `lsof -i :PORT`) |

---

## Real-World Application

These skills apply directly to:

- **DevOps:** Debugging container networking, service discovery
- **SysAdmin:** Configuring servers, troubleshooting connectivity
- **Security:** Identifying unexpected services, detecting open ports
- **Development:** Testing application network connectivity
- **Troubleshooting:** Quickly diagnosing network issues

---

**Next Step:** Review the [scripts/](scripts/) folder for automated networking tools you can use in production environments.
