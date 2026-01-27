# Networking and Ports: Cheatsheet

## Network Configuration Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `ip addr show` | Show IP addresses | `ip addr show` |
| `ip addr show eth0` | Show specific interface | `ip addr show eth0` |
| `ip link show` | Show link status | `ip link show` |
| `ip route show` | Show routing table | `ip route show` |
| `route -n` | Numeric routing table | `route -n` |
| `ifconfig` | Interface configuration (old) | `ifconfig eth0` |
| `hostname` | Show/set hostname | `hostname` |
| `hostnamectl` | Systemd hostname | `hostnamectl set-hostname name` |

## Port and Socket Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `ss -tlnp` | TCP listening ports | `ss -tlnp` |
| `ss -ulnp` | UDP listening ports | `ss -ulnp` |
| `ss -anp` | All sockets with PID | `ss -anp` |
| `ss -t` | TCP connections | `ss -t` |
| `ss -u` | UDP connections | `ss -u` |
| `ss -l` | Only listening sockets | `ss -l` |
| `netstat -tlnp` | Listening ports (old) | `netstat -tlnp` |
| `netstat -an` | All connections numeric | `netstat -an` |

## Network Testing Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `ping -c 4` | Test connectivity | `ping -c 4 8.8.8.8` |
| `ping -W 2` | Timeout 2 seconds | `ping -W 2 google.com` |
| `traceroute` | Show network path | `traceroute google.com` |
| `traceroute -m 15` | Max 15 hops | `traceroute -m 15 google.com` |
| `mtr` | Real-time traceroute | `mtr google.com` |
| `telnet host port` | Test port connection | `telnet example.com 80` |
| `nc -zv host port` | Port scan netcat | `nc -zv example.com 80` |
| `curl` | HTTP request | `curl http://example.com` |

## DNS Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `nslookup host` | Lookup hostname | `nslookup google.com` |
| `dig host` | Detailed DNS query | `dig google.com` |
| `dig @ns host` | Query specific nameserver | `dig @8.8.8.8 google.com` |
| `host hostname` | Simple DNS lookup | `host example.com` |
| `cat /etc/resolv.conf` | View DNS servers | `cat /etc/resolv.conf` |
| `getent hosts` | Query /etc/hosts file | `getent hosts localhost` |

## Open Files and Network Sockets

| Command | Purpose | Example |
|---------|---------|---------|
| `lsof -i` | List network files | `lsof -i` |
| `lsof -i :port` | Check specific port | `lsof -i :8080` |
| `lsof -i -P -n` | Numeric format | `lsof -i -P -n` |
| `lsof -u user` | User's files | `lsof -u username` |
| `lsof -p pid` | Process files | `lsof -p 1234` |
| `fuser port/tcp` | Find process by port | `fuser 8080/tcp` |
| `fuser -k port/tcp` | Kill by port | `fuser -k 8080/tcp` |

## Network Statistics

| Command | Purpose | Example |
|---------|---------|---------|
| `ss -s` | Socket statistics | `ss -s` |
| `netstat -s` | Protocol statistics | `netstat -s` |
| `ip -s link` | Interface statistics | `ip -s link show eth0` |
| `ip -s addr` | Address statistics | `ip -s addr show` |
| `cat /proc/net/tcp` | TCP connections file | `cat /proc/net/tcp` |
| `cat /proc/net/udp` | UDP connections file | `cat /proc/net/udp` |

## Connection States

| State | Meaning |
|-------|---------|
| `LISTEN` | Waiting for incoming connections |
| `ESTABLISHED` | Active connection |
| `TIME_WAIT` | Connection closed, waiting timeout |
| `CLOSE_WAIT` | Waiting to close |
| `SYN_SENT` | Connection initiation sent |
| `SYN_RECV` | Connection request received |
| `CLOSING` | Both sides closing |
| `CLOSED` | Connection closed |

## Port Ranges and Common Ports

| Service | Port | Protocol |
|---------|------|----------|
| SSH | 22 | TCP |
| HTTP | 80 | TCP |
| HTTPS | 443 | TCP |
| DNS | 53 | TCP/UDP |
| SMTP | 25 | TCP |
| POP3 | 110 | TCP |
| IMAP | 143 | TCP |
| MySQL | 3306 | TCP |
| PostgreSQL | 5432 | TCP |
| Redis | 6379 | TCP |
| MongoDB | 27017 | TCP |

## Port Ranges

| Range | Purpose |
|-------|---------|
| 0-1023 | Well-known ports (privileged) |
| 1024-49151 | Registered ports |
| 49152-65535 | Dynamic/private ports |

## Firewall and Security

| Command | Purpose | Example |
|---------|---------|---------|
| `sudo ufw status` | Check firewall status | `sudo ufw status` |
| `sudo ufw allow port` | Allow port | `sudo ufw allow 80` |
| `sudo ufw deny port` | Block port | `sudo ufw deny 8080` |
| `sudo iptables -L` | List firewall rules | `sudo iptables -L` |
| `sudo iptables -L -n` | Numeric rules | `sudo iptables -L -n` |

## Performance and Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `ifstat` | Interface statistics | `ifstat -i eth0` |
| `nethogs` | Network usage by process | `sudo nethogs` |
| `iftop` | Traffic by interface | `sudo iftop -i eth0` |
| `nload` | Network load meter | `nload -u h` |
| `vnstat` | Traffic statistics | `vnstat -h` |

## Diagnostic Workflow

```
1. Check connectivity
   ping destination

2. Check DNS resolution
   nslookup destination
   
3. Trace route
   traceroute destination
   
4. Check port
   telnet destination port
   
5. View socket details
   lsof -i | grep process
   
6. Check listening services
   ss -tlnp
```

## IPv4 Subnet Calculation

| CIDR | Netmask | Hosts |
|------|---------|-------|
| /24 | 255.255.255.0 | 256 (254 usable) |
| /25 | 255.255.255.128 | 128 (126 usable) |
| /26 | 255.255.255.192 | 64 (62 usable) |
| /27 | 255.255.255.224 | 32 (30 usable) |
| /28 | 255.255.255.240 | 16 (14 usable) |
| /30 | 255.255.255.252 | 4 (2 usable) |

## Network Classes (Legacy)

| Class | Range | Default Mask |
|-------|-------|--------------|
| A | 1.0.0.0 - 126.255.255.255 | /8 |
| B | 128.0.0.0 - 191.255.255.255 | /16 |
| C | 192.0.0.0 - 223.255.255.255 | /24 |
