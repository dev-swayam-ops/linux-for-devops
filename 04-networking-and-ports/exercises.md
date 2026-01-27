# Networking and Ports: Exercises

Complete these exercises to master Linux networking commands.

## Exercise 1: Network Interface Discovery

**Tasks:**
1. List all network interfaces
2. Identify the interface connected to network (not loopback)
3. Show IP address for each interface
4. Find the MAC address (hardware address)
5. Check interface status (UP/DOWN)

**Hint:** Use `ip addr show`, `ip link show`, or `ifconfig`.

---

## Exercise 2: IP Address and Routing

**Tasks:**
1. Display your current IP address
2. Show the default gateway
3. List complete routing table
4. Identify the network mask (netmask)
5. Determine your network address

**Example:** If IP is 192.168.1.10/24, network is 192.168.1.0

**Hint:** Use `ip addr show`, `ip route show`, or `route -n`.

---

## Exercise 3: Check Listening Ports

**Tasks:**
1. List all ports in LISTEN state
2. Identify which services are listening
3. Find a specific port (e.g., port 22 for SSH)
4. Show the PID of listening processes
5. Check both TCP and UDP ports

**Hint:** Use `ss -tlnp` (TCP), `ss -ulnp` (UDP), or `netstat -an`.

---

## Exercise 4: Port and Service Mapping

Create a simple Python HTTP server on port 8000.

**Tasks:**
1. Start a simple server:
   ```bash
   python3 -m http.server 8000
   ```
   (Run in background)

2. Verify port 8000 is listening
3. Identify the process using netstat/ss
4. Find the PID
5. Stop the server and confirm port is released

**Hint:** Use `ss -tlnp | grep 8000`.

---

## Exercise 5: Network Connectivity Testing

**Tasks:**
1. Ping localhost (127.0.0.1) - 4 packets
2. Ping your gateway
3. Ping a public DNS server (8.8.8.8)
4. Check packet loss percentage
5. Note RTT (round trip time)

**Hint:** Use `ping -c 4 address` to send 4 packets only.

---

## Exercise 6: DNS and Name Resolution

**Tasks:**
1. Resolve a hostname to IP: `nslookup google.com`
2. Check reverse DNS lookup
3. View your system's configured DNS servers
4. Try another public DNS server
5. Use `dig` command for detailed DNS info

**Hint:** Check `/etc/resolv.conf` for DNS servers.

---

## Exercise 7: Trace Route Analysis

**Tasks:**
1. Trace route to google.com
2. Note number of hops
3. Identify slow hops (high latency)
4. Trace route to a distant server
5. Compare routing to nearby vs distant hosts

**Hint:** Use `traceroute google.com` or `traceroute -m 15`.

---

## Exercise 8: Network Statistics and Monitoring

**Tasks:**
1. Display TCP/IP statistics
2. Check number of established connections
3. Show listen queue depth
4. Identify most used ports
5. Monitor for TIME_WAIT connections

**Hint:** Use `ss -s`, `ss -t`, `netstat -s`.

---

## Exercise 9: Open Files and Network Sockets

**Tasks:**
1. List all open network files (sockets)
2. Show connections in ESTABLISHED state
3. Filter for specific protocol (TCP)
4. Identify which user owns each connection
5. Find a specific service's connections

**Hint:** Use `lsof -i`, `lsof -i -P -n`, `ss -anp`.

---

## Exercise 10: Network Troubleshooting Scenario

Create a scenario to test connectivity and diagnose issues.

**Tasks:**
1. Test connectivity to a server:
   - Ping it
   - Trace route to it
   - Resolve DNS
   - Check if port is open

2. Document findings in a file
3. Create a summary report with format:
   - Hostname
   - IP Address
   - Connectivity (Y/N)
   - Route hops
   - Open ports

**Example server:** google.com, cloudflare.com, or any public service

---

**Bonus Exercise:** Network Interface Configuration

**Tasks:**
1. Show IP configuration in detail
2. Check interface speed and duplex
3. View interface statistics (RX/TX bytes)
4. Identify broadcast address
5. Calculate network size from netmask
