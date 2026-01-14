# Module 04: Networking and Ports

## Overview

Networking is fundamental to any Linux system, especially in DevOps environments where servers communicate across networks, handle multiple services, and require secure, reliable connectivity. Understanding how Linux manages network interfaces, IP addressing, ports, and network troubleshooting is essential for:

- **System Administration:** Configuring network interfaces, managing DNS, and handling network connectivity
- **DevOps Engineering:** Setting up container networking, managing microservices communication, and debugging deployment issues
- **Security:** Understanding which ports are listening, controlling network access, and diagnosing network problems
- **Troubleshooting:** Quickly diagnosing connectivity issues, port conflicts, and network bottlenecks

This module covers network fundamentals on Linux, teaching you how to:
- View and configure network interfaces
- Understand IP addressing and routing
- Identify which services are listening on which ports
- Troubleshoot network connectivity
- Work with DNS and hostname resolution
- Monitor network traffic and connections

## Prerequisites

Before starting this module, you should be comfortable with:
- Basic Linux command line navigation (from Module 01)
- Understanding of file editing and permissions
- Basic command pipeline concepts (grep, pipes)
- SSH access to a Linux system

**Recommended Lab Environment:**
- Ubuntu 20.04 LTS or later (or Debian 10+)
- At least 2 network interfaces for some labs (can use virtual adapters)
- Root or sudo access
- SSH server running (optional, but recommended for some labs)

## Learning Objectives

After completing this module, you will be able to:

1. **Network Interface Management**
   - View active network interfaces and their configurations
   - Understand IPv4 and IPv6 addressing
   - Temporarily and permanently configure network interfaces

2. **Port and Service Management**
   - Identify which ports are listening on your system
   - Understand the difference between TCP and UDP ports
   - Map port numbers to services and processes
   - View active network connections

3. **Network Troubleshooting**
   - Test connectivity to remote hosts
   - Trace network paths using traceroute
   - Diagnose DNS resolution issues
   - Monitor network performance and traffic
   - Identify port conflicts and listening services

4. **Network Monitoring & Analysis**
   - Monitor real-time network connections
   - Analyze network statistics
   - Capture and inspect network traffic basics
   - Understand netstat and ss command variations

5. **Security Awareness**
   - Identify unexpected listening services
   - Understand basic firewall concepts
   - Recognize security implications of open ports
   - Best practices for network troubleshooting

## Module Roadmap

```
04-networking-and-ports/
├── README.md (you are here)
├── 01-theory.md - Network concepts, OSI model, addressing, ports
├── 02-commands-cheatsheet.md - Command reference and quick patterns
├── 03-hands-on-labs.md - 8 practical labs you can run immediately
└── scripts/
    ├── port-monitor.sh - Real-time port and connection monitoring
    ├── network-health-check.sh - Network diagnostic utility
    └── README.md - Script documentation
```

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Network Interface** | A connection point to a network (e.g., eth0, wlan0). Each interface has an IP address. |
| **IP Address** | Unique identifier for a device on a network (IPv4: 192.168.1.1, IPv6: fe80::1) |
| **Port** | Numbered endpoint (0-65535) used by applications to communicate; TCP and UDP use different port spaces. |
| **Socket** | A combination of IP address + port + protocol (e.g., 192.168.1.1:8080/TCP). |
| **TCP** | Transmission Control Protocol - reliable, ordered, connection-based (used for HTTP, SSH, FTP). |
| **UDP** | User Datagram Protocol - fast, connectionless, no guarantee (used for DNS, video streaming). |
| **DNS** | Domain Name System - translates domain names (google.com) to IP addresses (142.251.35.14). |
| **Gateway/Router** | Device that connects networks and forwards packets between them. |
| **Routing** | Process of forwarding packets between networks based on routing tables. |
| **Firewall** | Security tool that allows or blocks traffic based on rules. |
| **CIDR** | Classless Inter-Domain Routing notation (e.g., 192.168.1.0/24) for specifying IP ranges. |
| **Localhost** | Special hostname (127.0.0.1 or ::1) referring to the current machine. |
| **Broadcast** | Address that sends packets to all devices on a network (e.g., 192.168.1.255). |
| **MAC Address** | Hardware address of a network interface, used on local networks (48-bit, e.g., aa:bb:cc:dd:ee:ff). |
| **Loopback** | Virtual interface (lo) used for testing, always 127.0.0.1. |
| **netstat** | Network statistics tool showing connections, sockets, and routing tables (often replaced by ss). |
| **ss** | Socket statistics - modern replacement for netstat, faster and more detailed. |

## How to Use This Module

### Learning Path

1. **Start with theory** (01-theory.md)
   - Read about network concepts and OSI model
   - Understand addressing, ports, and protocols
   - Review ASCII diagrams

2. **Learn the commands** (02-commands-cheatsheet.md)
   - Focus on the most common commands first
   - Run each command on your system to see actual output
   - Build muscle memory with the patterns

3. **Practice with labs** (03-hands-on-labs.md)
   - Follow labs in order (they build on each other)
   - Don't rush - understand each step
   - Use the verification checklist
   - Always run cleanup after each lab

4. **Explore the scripts** (scripts/)
   - Understand what each script does
   - Run them on your system
   - Modify and experiment with them

### Time Estimate

- Reading theory: 45-60 minutes
- Command practice: 30-45 minutes
- Hands-on labs: 90-120 minutes
- **Total:** 3-4 hours

### Environment Setup

**For Debian/Ubuntu:**
```bash
# Install required tools
sudo apt-get update
sudo apt-get install -y net-tools iputils-ping dnsutils netcat nmap traceroute

# Verify installations
ifconfig --version
ping --version
netstat --version
```

**For RHEL/CentOS:**
```bash
# Install required tools
sudo yum install -y net-tools bind-utils iputils netcat-openbsd nmap traceroute

# Verify installations
ifconfig --version
ping --version
netstat --version
```

**Recommended:** Use a virtual machine so you can safely experiment without affecting production systems.

## Safety Notes

- ⚠️ Some labs involve network configuration changes. Use a VM or test environment.
- ⚠️ Never disable firewall rules without understanding the consequences.
- ⚠️ Port scanning (nmap) should only be used on systems you own or have permission to test.
- ⚠️ Always use `sudo` carefully - networking changes can disconnect your system.
- ✅ All labs include cleanup steps to restore your system to a safe state.

## Key Concepts at a Glance

### Network Layers (Simplified)
```
Application Layer     → Services (HTTP, SSH, DNS)
Transport Layer       → Ports & Protocols (TCP/UDP)
Internet Layer        → IP Addressing & Routing
Link Layer            → MAC Addresses & Physical
```

### Common Ports (Remember These)
```
Port 22   → SSH (secure shell)
Port 80   → HTTP (web)
Port 443  → HTTPS (secure web)
Port 53   → DNS
Port 25   → SMTP (email)
Port 3306 → MySQL
Port 5432 → PostgreSQL
Port 6379 → Redis
Port 8080 → Common alternate web port
```

### Network Diagnosis Workflow
```
1. Check if system is online: ping
2. Check own interface: ifconfig / ip addr
3. Check listening ports: netstat / ss
4. Check routing: route / ip route
5. Check DNS: nslookup / dig
6. Check connectivity: traceroute
7. Check active connections: netstat / ss
8. Monitor traffic: iftop / tcpdump
```

## Troubleshooting Common Issues

| Problem | Command to Check | Likely Cause |
|---------|------------------|--------------|
| Can't reach any host | `ping 8.8.8.8` | No internet connection or firewall |
| Can't reach specific host | `ping hostname` → `traceroute hostname` | Routing issue or host down |
| Port won't bind | `sudo netstat -tlnp \| grep :PORT` | Port already in use or permission denied |
| DNS not working | `nslookup google.com` | DNS server not configured or unavailable |
| Slow network | `iftop` or `nethogs` | High traffic or bandwidth issue |
| Wrong IP address | `ip addr show` → `hostname -I` | Interface misconfigured |

## What's Next After This Module?

- **Module 05:** Memory and Disk Management - Understand resource utilization
- **Module 12:** Security and Firewall - Secure your network interfaces
- **Module 13:** Logging and Monitoring - Monitor network activity long-term
- **Module 17:** Troubleshooting and Scenarios - Real-world network problems

## Resources & References

### Man Pages to Read
```bash
man ifconfig
man ip
man netstat
man ss
man ping
man traceroute
man nslookup
man dig
man nc
man nmap
```

### Command Categories in This Module

**Interface Management:** ifconfig, ip, hostname
**Connectivity Testing:** ping, traceroute, telnet, nc
**Port & Service Discovery:** netstat, ss, lsof, nmap
**DNS & Resolution:** nslookup, dig, host, getent
**Monitoring:** iftop, nethogs, tcpdump (basics)

## Getting Started

1. ✅ Read this entire README
2. ✅ Work through 01-theory.md
3. ✅ Reference 02-commands-cheatsheet.md while practicing
4. ✅ Complete 03-hands-on-labs.md in order
5. ✅ Explore the scripts in scripts/
6. ✅ Try modifying scripts for your own use cases

---

**Ready to start?** Begin with [01-theory.md](01-theory.md) to understand the concepts, then move to the commands and labs.

**Questions about networking?** Each lab section includes troubleshooting tips. Check the common issues section above, then refer to the relevant man pages.

Good luck! 🚀
