# 01-theory.md: Networking Fundamentals & Concepts

## Table of Contents
1. [OSI Model & Network Layers](#osi-model--network-layers)
2. [IP Addressing](#ip-addressing)
3. [Ports & Protocols](#ports--protocols)
4. [Sockets & Connections](#sockets--connections)
5. [Routing & Gateways](#routing--gateways)
6. [DNS & Name Resolution](#dns--name-resolution)
7. [Network Interfaces](#network-interfaces)
8. [Common Network Commands Overview](#common-network-commands-overview)

---

## OSI Model & Network Layers

The **OSI (Open Systems Interconnection) Model** is a 7-layer framework for understanding how computer networks work. For Linux networking, we typically focus on the bottom 5 layers:

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 7: Application Layer                                 │
│  HTTP, HTTPS, SSH, FTP, DNS, SMTP                          │
│  (What you see: web pages, email, remote terminals)        │
├─────────────────────────────────────────────────────────────┤
│  Layer 6: Presentation Layer                               │
│  Encryption, compression, translation                       │
├─────────────────────────────────────────────────────────────┤
│  Layer 5: Session Layer                                    │
│  Session management, connection state                       │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: Transport Layer                    ← WE FOCUS HERE│
│  TCP (reliable), UDP (fast)                                 │
│  Ports 0-65535, connections, reliability                    │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: Network Layer                      ← AND HERE     │
│  IP (v4 & v6), routing, addressing                          │
│  Determines how packets travel between networks             │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: Data Link Layer                                  │
│  MAC addresses, switches, local delivery                    │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: Physical Layer                                   │
│  Cables, signals, electrical transmission                   │
└─────────────────────────────────────────────────────────────┘
```

### Why the OSI Model Matters

When troubleshooting network issues, you diagnose from bottom to top:

| Layer | Symptom | Check Command |
|-------|---------|--------------|
| Physical (1) | "No link" indicator | `ethtool eth0` |
| Link (2) | No MAC address, bad cables | `ip link show` |
| Network (3) | Wrong IP, no route to host | `ip route show` |
| Transport (4) | Port unreachable, connection refused | `netstat -an` / `ss -an` |
| Application (7) | Service not responding, wrong data | Check service logs |

---

## IP Addressing

### IPv4 Addressing (Still the most common)

An **IPv4 address** is a 32-bit number written as 4 decimal octets (0-255):

```
192.168.1.100
│   │    │   │
└───┴────┴───┘ Each number is 0-255 (8 bits)
```

#### Address Classes (Historical, now using CIDR)

```
Class A: 1.0.0.0 - 126.255.255.255      (8 bits for host)
Class B: 128.0.0.0 - 191.255.255.255    (16 bits for host)
Class C: 192.0.0.0 - 223.255.255.255    (24 bits for host)
```

**Modern approach: CIDR Notation**

Instead of classes, we use **CIDR (Classless Inter-Domain Routing)** notation:

```
192.168.1.0/24
         ││
         └┴─ /24 means "first 24 bits are network, last 8 bits are host"

Network: 192.168.1.0
Usable IPs: 192.168.1.1 - 192.168.1.254
Broadcast: 192.168.1.255
Netmask: 255.255.255.0 (in dotted decimal)
```

#### Special Addresses

```
0.0.0.0             → Default route / "all interfaces"
127.0.0.1           → Localhost (loopback)
127.x.x.x           → Loopback network (127.0.0.0/8)
169.254.0.0/16      → Link-local (auto-configured if DHCP fails)
192.168.0.0/16      → Private network (not routable on internet)
10.0.0.0/8          → Private network
172.16.0.0/12       → Private network
255.255.255.255     → Limited broadcast (subnet broadcast)
x.x.x.0             → Network address (historically)
x.x.x.255           → Broadcast address
```

**Private vs Public:**
- **Private IPs** (10.x, 172.16-31.x, 192.168.x) cannot be routed on the internet
- **Public IPs** are globally unique and routable; used for real servers
- **RFC 1918** defines private IP ranges

### IPv6 Addressing (The Future)

IPv6 uses 128 bits (16 bytes), written as hex:

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
    or shortened:
2001:db8:85a3::8a2e:370:7334
           ││
           └┴─ :: represents one or more groups of zeros
```

**Why IPv6?**
- Much larger address space (2^128 vs 2^32)
- Built-in security (IPSec)
- Simpler header structure

**Common IPv6 addresses:**
```
::1                 → IPv6 localhost
fe80::1             → Link-local address (auto-configured)
ff02::1             → Multicast (all devices on link)
```

---

## Ports & Protocols

### Port Basics

A **port** is a 16-bit number (0-65535) that identifies a specific service on a machine:

```
IP Address      Identifies the COMPUTER
Port            Identifies the SERVICE on that computer

Example: 192.168.1.100:22 → SSH service on that computer
         192.168.1.100:80 → HTTP service on that computer
```

### Port Ranges

```
0-1023          → Well-known ports (system/reserved)
                   Require root/sudo to listen
                   SSH=22, HTTP=80, HTTPS=443, etc.

1024-49151      → Registered ports
                   Applications can bind here without root
                   MySQL=3306, PostgreSQL=5432, etc.

49152-65535     → Dynamic/private ports
                   Used for temporary client connections
```

### Common Protocols & Ports

| Port | Protocol | Use | Type |
|------|----------|-----|------|
| 22 | SSH | Secure remote login | TCP |
| 80 | HTTP | Web browsing (unencrypted) | TCP |
| 443 | HTTPS | Web browsing (encrypted) | TCP |
| 53 | DNS | Domain name resolution | UDP/TCP |
| 25 | SMTP | Email sending | TCP |
| 110 | POP3 | Email retrieval | TCP |
| 143 | IMAP | Email retrieval | TCP |
| 3306 | MySQL | Database | TCP |
| 5432 | PostgreSQL | Database | TCP |
| 6379 | Redis | Cache/Database | TCP |
| 3389 | RDP | Remote desktop (Windows) | TCP |
| 8080 | HTTP Alt | Common web application port | TCP |
| 8443 | HTTPS Alt | Common secure web app port | TCP |

### TCP vs UDP

```
TCP (Transmission Control Protocol)
├─ Connection-based (handshake required)
├─ Reliable (retransmits lost packets)
├─ Ordered (packets arrive in order)
├─ Slower (more overhead)
└─ Uses: HTTP, SSH, FTP, email

UDP (User Datagram Protocol)
├─ Connectionless (fire and forget)
├─ Unreliable (no retransmission)
├─ Unordered (order not guaranteed)
├─ Faster (minimal overhead)
└─ Uses: DNS, video streaming, online games, VoIP
```

**When to use which?**
- **Use TCP** when reliability matters more than speed (file transfer, email, banking)
- **Use UDP** when speed matters more than reliability (real-time video, gaming, VoIP)

---

## Sockets & Connections

### What is a Socket?

A **socket** is the endpoint of a network communication channel. It's a combination of:

```
Socket = IP Address + Port + Protocol

Example sockets:
  192.168.1.100:22/TCP    → SSH listening
  192.168.1.100:80/TCP    → HTTP listening
  127.0.0.1:3306/TCP      → MySQL listening locally
  192.168.1.200:54321/TCP → A client connection (random port)
```

### Socket States (TCP)

When examining connections with `netstat` or `ss`, you'll see these states:

```
LISTEN          → Service is listening for connections
ESTABLISHED     → Active connection
TIME_WAIT       → Connection closed, waiting for packets to die
CLOSE_WAIT      → Peer has closed, waiting for local close
FIN_WAIT_1/2    → Waiting for final close
SYN_SENT        → Initiating connection
SYN_RECV        → Received connection request
CLOSING         → Both sides closing
```

### TCP Three-Way Handshake

When a client connects to a server:

```
Client                          Server
  │                              │
  ├─ SYN (want to connect) ─────>│
  │                              │
  │<───── SYN-ACK (ok, hello) ────┤
  │                              │
  ├───── ACK (confirmed) ──────>│
  │                              │
  └─────── ESTABLISHED ─────────>│
```

This is why TCP is reliable but slower - it requires this handshake overhead.

---

## Routing & Gateways

### Routing Tables

A **routing table** tells the OS: "If I need to send a packet to this destination, send it through this gateway."

```
Destination         Gateway           Interface
────────────────    ──────────────    ──────────
0.0.0.0/0           192.168.1.1       eth0 (default route)
192.168.1.0/24      0.0.0.0 (direct)  eth0
192.168.2.0/24      192.168.1.254     eth0 (via router)
127.0.0.1           0.0.0.0           lo (loopback)
```

**Default route (0.0.0.0/0)** is used for all traffic not matching specific routes.

### Gateway vs Router

```
Gateway = A single interface that connects to another network
Router  = A device that operates gateways and makes routing decisions

Your Linux system can BE a gateway/router:
  2+ network interfaces connected to different networks
  Forwarding traffic between them (IP forwarding enabled)
```

### Common Routing Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Destination unreachable" | No route to destination | Add route or use default gateway |
| "Network unreachable" | No gateway for that network | Configure gateway or interface |
| "Host unreachable" | Host down or unreachable | Check connectivity, firewall |

---

## DNS & Name Resolution

### DNS (Domain Name System)

DNS translates **human-readable names** to **IP addresses**:

```
You type:     google.com
DNS resolves: 142.251.32.46
Your browser connects to: 142.251.32.46:443
```

### DNS Components

```
┌────────────────────────────────────────┐
│  Your Computer (DNS Client)            │
│  - Needs to find an IP address         │
│  - Asks DNS server                     │
└────────────────────────────────────────┘
           │ Query: "What is google.com?"
           ↓
┌────────────────────────────────────────┐
│  Recursive Resolver (ISP DNS)          │
│  - Usually provided by ISP             │
│  - Finds the answer and returns it     │
└────────────────────────────────────────┘
           │ Query to root nameserver
           ├─> Query to TLD nameserver (.com)
           ├─> Query to authoritative nameserver
           │ Response: IP address
           ↓
┌────────────────────────────────────────┐
│  Your Computer (DNS Client)            │
│  - Receives IP: 142.251.32.46         │
│  - Connects to that IP                 │
└────────────────────────────────────────┘
```

### DNS Resolution on Linux

**Configuration file:** `/etc/resolv.conf`

```bash
nameserver 8.8.8.8         # Google DNS
nameserver 8.8.4.4         # Google DNS backup
search example.com         # Default domain suffix
```

**On modern Ubuntu (systemd-resolved):**
```bash
/etc/systemd/resolved.conf  # Main config
/run/systemd/resolve/resolv.conf  # Generated
```

### Name Resolution Order

Linux tries these methods in order (via `/etc/nsswitch.conf`):

```
1. Local hosts file (/etc/hosts)
2. DNS servers (from /etc/resolv.conf)
3. NIS or LDAP (if configured)
```

**Why /etc/hosts matters:**
```bash
127.0.0.1       localhost
::1             localhost
192.168.1.100   myserver
```

This lets you reference `myserver` locally without DNS!

---

## Network Interfaces

### Interface Types

| Type | Purpose | Example |
|------|---------|---------|
| Ethernet | Wired network | eth0, ens33, enp0s3 |
| Wireless | WiFi | wlan0, wlp3s0 |
| Loopback | Local testing (always 127.0.0.1) | lo |
| Bridge | Connect multiple interfaces | br0 |
| Virtual | VPN, containers, virtualization | tun0, veth123 |
| Bonding | Combine multiple interfaces for redundancy | bond0 |

### Interface Naming Schemes

**Old style (still works):**
```
eth0, eth1, wlan0, lo
(Simple but unpredictable across reboots)
```

**Modern Predictable Names (Systemd):**
```
enp0s3   → Ethernet, on PCI bus 0, slot 3
wlp2s0   → Wireless, on PCI bus 2, slot 0
lo       → Loopback (unchanged)
```

**Why predictable names matter:**
- Same hardware always gets same name
- Network scripts are reliable
- Easy to identify specific interfaces

### Interface Configuration

```
Interface has properties:
  ├─ MAC Address (hardware identifier)
  ├─ IPv4 Address (e.g., 192.168.1.100)
  ├─ IPv4 Netmask (e.g., 255.255.255.0)
  ├─ IPv6 Address (e.g., fe80::1/10)
  ├─ Gateway
  ├─ DNS Servers
  └─ MTU (max packet size, typically 1500)
```

### Static vs Dynamic

```
DHCP (Dynamic Host Configuration Protocol)
├─ Client sends: "I need an IP address"
├─ Server responds: "Here's 192.168.1.100"
├─ Lease expires after a time (usually hours)
├─ Requires DHCP server (usually router)
└─ Easy for workstations, risky for servers

Static IP
├─ You assign a specific IP manually
├─ Never changes (unless you change it)
├─ Required for servers and critical systems
├─ Must not conflict with other devices
└─ Requires careful management
```

---

## Common Network Commands Overview

### Quick Command Reference

```bash
# Check all interfaces
ifconfig              # (old, deprecated)
ip addr show          # (modern, preferred)

# Check specific interface
ip addr show eth0

# See which ports are listening
netstat -tlnp         # (old)
ss -tlnp              # (modern, faster)

# Test connectivity
ping 8.8.8.8

# Trace route to a host
traceroute 8.8.8.8

# Check DNS resolution
nslookup google.com
dig google.com
host google.com

# Find what's using a port
lsof -i :80
netstat -tlnp | grep :80

# See active connections
netstat -an
ss -an

# Check routing table
route -n
ip route show
```

### Network Information Hierarchy

```
System Level
  ↓
Interfaces (eth0, wlan0, etc)
  ├─ IP Address Configuration
  ├─ MAC Address
  └─ Statistics (packets, errors)
  ↓
Routes (routing table)
  ├─ Where to send packets
  └─ Which interface/gateway to use
  ↓
Ports & Sockets
  ├─ What services are listening
  └─ What connections are established
  ↓
Services (actual running programs)
  └─ Process using that port
```

### Monitoring Network Traffic

**Real-time interface statistics:**
```bash
iftop               # Top network interfaces
nethogs             # Per-process bandwidth usage
vnstat              # Historical statistics
ss -s               # Summary statistics
```

---

## Key Concepts Summary

### The Network Stack (How a Packet Flows)

```
Application writes data → HTTP GET request
         ↓
Transport adds port info → Wraps in TCP header
         ↓
Network adds IP info → Wraps in IP header
         ↓
Link layer adds MAC → Wraps in Ethernet header
         ↓
Physical sends → Over the wire/WiFi
         ↓
────────── Network ──────────
         ↓
Physical receives → From the wire
         ↓
Link layer checks → Verify MAC address
         ↓
Network checks → Verify IP address
         ↓
Transport checks → Verify port
         ↓
Application reads → Passes to service listening on port
```

### Critical Mental Models

1. **IP addresses identify computers; ports identify services on those computers**
2. **Every connection has two sockets (client and server)**
3. **Routing tables determine the path packets take**
4. **DNS converts names to IPs (but isn't always available)**
5. **TCP is reliable but slower; UDP is fast but unreliable**
6. **Services listen on ports; clients connect to ports**
7. **Firewalls control which connections are allowed**

### Troubleshooting Mindset

When a network problem occurs, ask these questions in order:

1. **Can I reach the local network?** (ping gateway)
2. **Can I reach the internet?** (ping 8.8.8.8)
3. **Is DNS working?** (nslookup google.com)
4. **Is the service listening?** (netstat/ss on target host)
5. **Is the service responding?** (telnet/nc to port)
6. **Is firewall blocking?** (check firewall rules)
7. **Is routing correct?** (traceroute to see path)

---

## Next Steps

- ✅ Review this theory section multiple times
- ✅ Look up the OSI model in your own words
- ✅ Run the commands in section "Common Network Commands Overview"
- ✅ Check your own system's network configuration with `ip addr show`
- ✅ See what's listening on your system with `ss -tlnp`

**Ready for practical work?** Move to [02-commands-cheatsheet.md](02-commands-cheatsheet.md) to learn the specific commands and their options.
