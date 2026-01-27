# Module 4: Networking and Ports

## What You'll Learn

- Understand Linux networking fundamentals and TCP/IP
- Configure and manage network interfaces
- Monitor network connectivity and traffic
- Check open ports and listening services
- Work with DNS and name resolution
- Use network diagnostic tools effectively

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Basic understanding of IP addresses and ports
- Familiarity with TCP/IP concepts
- Network access required to test connectivity

## Key Concepts

| Concept | Description |
|---------|-------------|
| **IP Address** | Unique identifier for device on network (IPv4/IPv6) |
| **Port** | Endpoint for network communication (0-65535) |
| **Socket** | Combination of IP address and port for connection |
| **Protocol** | Rules for communication (TCP, UDP, ICMP) |
| **Localhost** | Special IP 127.0.0.1 refers to local machine |
| **Network Interface** | Physical or virtual network adapter (eth0, wlan0) |
| **Netstat/ss** | Tools to view network connections and listening ports |
| **DNS** | System that translates domain names to IP addresses |

## Hands-on Lab: Check Ports and Network Configuration

### Lab Objective
Discover network interfaces, check open ports, and monitor network connections.

### Commands

```bash
# Display network interfaces
ip addr show
# or older command:
ifconfig

# Show routing table
ip route show
# or:
route -n

# Check listening ports and services
ss -tlnp
# or older:
netstat -tlnp

# Check specific port (e.g., 80)
ss -tlnp | grep :80

# Show all network connections
ss -anp

# Trace route to a host
traceroute google.com
# or:
traceroute -m 15 google.com

# Check DNS resolution
nslookup google.com
# or:
dig google.com

# Ping a host
ping -c 4 8.8.8.8

# Show network statistics
ss -s
netstat -s

# Monitor real-time network traffic
ifstat
# or:
nethogs

# Check open files (network connections)
lsof -i -P -n

# Display TCP connections
ss -t

# Display UDP connections
ss -u

# Check specific service port
sudo lsof -i :8080
```

### Expected Output

```
# ip addr show output:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.10/24 brd 192.168.1.255

# ss -tlnp output:
LISTEN  0  128  0.0.0.0:22   0.0.0.0:*  users:(("sshd",pid=1234,fd=3))
LISTEN  0  128  0.0.0.0:80   0.0.0.0:*  users:(("apache2",pid=5678,fd=4))

# ping output:
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 time=45.2 ms
4 packets transmitted, 4 received, 0% packet loss
```

## Validation

Confirm successful completion:

- [ ] Displayed network interfaces with `ip addr show`
- [ ] Identified listening ports with `ss -tlnp`
- [ ] Traced route to external host
- [ ] Resolved DNS name to IP address
- [ ] Verified network connectivity with ping
- [ ] Understood the relationship between services and ports

## Cleanup

```bash
# No cleanup needed for this lab
# All commands are read-only monitoring

# If you created test services, remove them:
sudo systemctl stop test-service
sudo systemctl disable test-service
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| `ss: command not found` | Install with: `sudo apt install iproute2` |
| `netstat` deprecated | Use `ss` instead (modern replacement) |
| Forgot sudo for ports < 1024 | Need privilege to see some details |
| Wrong port format | Ports are numbers (1-65535), not service names |
| Can't resolve hostname | Check DNS: `cat /etc/resolv.conf` |
| Interface not showing | Interface may be down: `ip link` shows status |

## Troubleshooting

**Q: How do I find what's listening on port 8080?**
A: Use `ss -tlnp | grep 8080` or `lsof -i :8080`

**Q: Why can't I see processes for some ports?**
A: Some ports require root/sudo. Try: `sudo ss -tlnp`

**Q: How do I check if a server is reachable?**
A: Use ping: `ping -c 4 example.com` (4 packets)

**Q: How can I test if a port is open?**
A: Use telnet: `telnet example.com 80` or nc: `nc -zv example.com 80`

**Q: What's the difference between ss and netstat?**
A: `ss` is newer, faster, and has better features. `netstat` is deprecated.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Learn firewall rules and port security
3. Monitor network performance over time
4. Understand how services bind to ports
5. Practice diagnosing network connectivity issues
