# Theory: Linux Security & Firewall

## Table of Contents

1. [Security Layers & Architecture](#security-layers--architecture)
2. [Authentication & Authorization](#authentication--authorization)
3. [Discretionary Access Control (DAC)](#discretionary-access-control-dac)
4. [Mandatory Access Control (MAC)](#mandatory-access-control-mac)
5. [Firewall Fundamentals](#firewall-fundamentals)
6. [Network Security](#network-security)
7. [SSH & Key-Based Authentication](#ssh--key-based-authentication)
8. [Cryptography Basics](#cryptography-basics)
9. [Security Best Practices](#security-best-practices)

---

## Security Layers & Architecture

### Defense-in-Depth Model

Linux security uses multiple overlapping layers. Compromise of one layer doesn't mean total system breach:

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: BIOS/Firmware Security                           │
│  (Secure Boot, Boot password, firmware updates)            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: OS-Level Access Control                          │
│  (User accounts, permissions, SELinux/AppArmor)            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Network Firewall                                 │
│  (iptables, UFW, firewall-cmd)                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: Service Configuration                            │
│  (SSH hardening, minimal services, strong protocols)       │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 5: Application Security                             │
│  (Input validation, secure coding, patching)               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 6: Monitoring & Incident Response                   │
│  (Logging, auditing, threat detection, response)           │
└─────────────────────────────────────────────────────────────┘
```

Each layer is independent and provides its own protection:

- **BIOS Security** - Prevent unauthorized boot changes
- **OS Access Control** - Prevent unauthorized file/process access
- **Firewall** - Prevent unauthorized network access
- **Service Configuration** - Minimize attack surface
- **Application** - Prevent exploitation of services
- **Monitoring** - Detect and respond to attacks

**Attack Scenario:**
Attacker gains low-privilege user account → Firewall blocks network → OS permissions prevent file access → Monitoring detects activity → Incident response contains it

### Threat Model

Before implementing security, consider:

**Types of Attackers:**
1. **Unauthenticated external** - No user account on system
2. **Authenticated local** - Has user account (employee, contractor)
3. **Compromised service** - Malware in running application
4. **Insider threat** - Disgruntled employee with legitimate access

**Attack Vectors:**
- Network access (SSH brute force, unpatched services)
- Physical access (USB, console, stolen device)
- Social engineering (phishing, pretexting)
- Supply chain (compromised package, malicious code)
- Misconfigurations (weak passwords, excessive permissions)

**Impact Categories:**
- **Confidentiality** - Data exposure
- **Integrity** - Data corruption
- **Availability** - Service disruption (DoS)

Security controls should address your specific threat model, not generic threats.

---

## Authentication & Authorization

### Authentication (Proving Identity)

**"Who are you?"** → Prove you are who you claim

Methods:
1. **Password** - What you know (most common, often weak)
2. **SSH Key** - What you have (cryptographic proof)
3. **Biometric** - What you are (fingerprint, face)
4. **MFA** - Multiple factors combined (strongest)

### Authorization (Granting Access)

**"What can you do?"** → Based on authenticated identity

In Linux:
- User ID (UID) maps to permissions
- Group membership extends access
- File ownership and permissions enforce rules
- sudo allows privilege escalation

### Combined: AuthN + AuthZ

```
AuthN              AuthZ
┌──────┐          ┌────────────┐
│ User │ ────────>│ Determine  │
│Login │          │permissions │
└──────┘          └────────────┘
        Verify      Check what
       identity     user can do
```

Example:
1. User alice logs in with password (AuthN) ✓
2. System identifies alice is UID 1001
3. System checks file ownership and group membership (AuthZ)
4. alice can read/write files where alice is owner or in group
5. alice cannot read files with 700 permissions owned by bob

---

## Discretionary Access Control (DAC)

### Traditional Unix Permissions

Every file/directory has:
- **Owner (user)**
- **Group**
- **Permissions** - Read (r), Write (w), Execute (x)

```
-rw-r--r-- 1 alice webadmins 1234 Jan 15 10:30 index.html
│ │││ │││ │ │   │         │
│ │││ │││ │ │   │         └─ File name
│ │││ │││ │ │   └──────────── Group: webadmins
│ │││ │││ │ └───────────────── Owner: alice
│ │││ │││ └─────────────────── Hard links
│ │││ └────────────────────── Other permissions (r--)
│ ││└─────────────────────── Group permissions (r--)
│ │└──────────────────────── User/owner permissions (rw-)
│ └────────────────────────── File type: - = regular file
└──────────────────────────── Directory: d, Link: l, etc.
```

**Permission Breakdown:**

| Notation | Binary | Meaning |
|----------|--------|---------|
| r (read) | 4 | View file contents, list directory |
| w (write) | 2 | Modify file, delete from directory |
| x (execute) | 1 | Run file as program, enter directory |

**For Files:**
- **read (r)** - View contents with `cat`, `less`
- **write (w)** - Modify with editors, remove with `rm`
- **execute (x)** - Run as script or binary

**For Directories:**
- **read (r)** - List contents with `ls`
- **write (w)** - Create/delete files in directory
- **execute (x)** - Enter directory with `cd`, access files

### Permission Combinations

```
755 → rwxr-xr-x  Owner: rwx, Group: r-x, Other: r-x  (typical for programs)
644 → rw-r--r--  Owner: rw-, Group: r--, Other: r--  (typical for files)
700 → rwx------  Owner: rwx, Group: ---, Other: ---  (private)
600 → rw-------  Owner: rw-, Group: ---, Other: ---  (very private)
```

### umask (Default Permissions)

When you create a file, Linux applies umask to restrict permissions:

```
Default for files: 666
Default for dirs:  777

With umask 022:
Files: 666 - 022 = 644 (rw-r--r--)
Dirs:  777 - 022 = 755 (rwxr-xr-x)

With umask 077 (more restrictive):
Files: 666 - 077 = 600 (rw-------)
Dirs:  777 - 077 = 700 (rwx------)
```

### Special Permissions

**SUID (Set User ID)** - File executes as owner, not executor

```
-rwsr-xr-x  (4755)
    ↑
    SUID bit
```

Example: `passwd` has SUID as root
- Normal user can run it
- But it executes as root (required to modify /etc/shadow)
- User cannot directly edit /etc/shadow, but passwd can

**SGID (Set Group ID)** - File executes as group

```
-rwxr-sr-x  (2755)
       ↑
       SGID bit
```

**Sticky Bit** - Only owner can delete files in directory

```
drwxrwxrwt  (1777)
        ↑
        Sticky bit
```

Example: `/tmp` has sticky bit
- Anyone can create files
- Only owner can delete their own files
- Owner cannot delete others' files

### Permission Inheritance

When ACLs (Access Control Lists) extend permissions:

```
File: document.txt
Owner: alice, Group: sales
Base permissions: rw-r-----  (640)

ACL entries:
user bob: r--    (Read-only for Bob)
group marketing: r--  (Read-only for marketing group)
```

Now:
- alice (owner) → rw-
- bob (ACL entry) → r--
- marketing group (ACL) → r--
- everyone else → no access

---

## Mandatory Access Control (MAC)

### SELinux (Red Hat/CentOS)

Mandatory Access Control using security contexts and policies.

**Three modes:**
- **Enforcing** - Denies unauthorized access
- **Permissive** - Logs unauthorized access but allows it
- **Disabled** - No SELinux enforcement

**Security Context:**
```
user:role:type:level
unconfined_u:object_r:user_home_t:s0 /home/alice
│           │          │              │
└─ SE User  └─ Role    └─ Type        └─ Level
```

**Types (restrict what files can be accessed):**
- `user_home_t` - User home directory files
- `ssh_home_t` - SSH config files
- `admin_home_t` - Admin home directory
- `var_log_t` - Log files
- `httpd_sys_content_t` - Web server content

Example: `httpd_t` (Apache web server) can:
- Read: `httpd_sys_content_t`, `httpd_config_t`
- Write: `httpd_var_lib_t` (for caching)
- Cannot: Write logs, access user files, listen on port 22

This prevents compromised Apache from accessing system files or SSH.

### AppArmor (Ubuntu/Debian)

Mandatory Access Control using profiles and file paths.

**Modes:**
- **Enforce** - Denies unauthorized access
- **Complain** - Logs unauthorized access but allows it
- **Unconfined** - No restrictions

**Profile Example:**
```
/usr/bin/my-app {
  /etc/my-app/* r,              # Can read config
  /var/log/my-app.log w,        # Can write to log
  /home/*/uploads/ rw,          # Can read/write uploads
  /root/ x,                     # Can exec files in /root/
  deny /etc/shadow r,           # Explicitly denied
}
```

Rules use file paths instead of types:
- `r` - Read
- `w` - Write
- `x` - Execute
- `l` - Link
- `k` - Lock
- `deny` - Explicitly deny access

---

## Firewall Fundamentals

### What is a Firewall?

A firewall is software that:
1. Inspects network packets
2. Makes decisions based on configured rules
3. Allows or blocks traffic

**Firewall rules are checked sequentially until match:**

```
Packet arrives
   │
   ▼
Check Rule 1 → Match? Yes/No
   │
   ├─ Yes: Apply action (ACCEPT/DROP/REJECT), stop checking
   │
   └─ No: Continue to Rule 2
   │
   ▼
Check Rule 2 → Match? Yes/No
   │
   └─ No: Continue...
   │
   ▼
No rules matched → Apply default policy (usually DROP/REJECT)
```

### Connection Tracking

Firewalls track connections (stateful):

```
Client                   Server
   │                        │
   ├─ SYN (start connection) ──────>
   │                        │
   │<─────── SYN-ACK ───────
   │ (Firewall now knows this is part of connection)
   │
   ├─ ACK ───────────────>
   │                        │
   │ Connection established │
   │ (Firewall allows packets both ways for this connection)
   │
   ├─ DATA ──────────────>
   │<────── DATA ───────────
   │
   └─ Timeout or FIN (connection closed)
     (Firewall stops tracking)
```

This allows responses without explicit rules:
- Rule: Allow incoming SSH (port 22)
- Client connects to port 22
- Server's reply is automatically allowed (same connection)
- Attacker can't just send data on port 22 without establishing connection

### Firewall Chains

iptables uses three main chains:

```
Incoming packet
   │
   ├─ From local machine? → OUTPUT chain → Send out
   │
   ├─ For local machine? → INPUT chain → Local process
   │
   └─ For another machine? → FORWARD chain → Route to other interface
```

**Example:**
- User runs `curl google.com` → OUTPUT chain (allow outbound)
- Google's response → INPUT chain (allow established connection)
- Packet forwarding through router → FORWARD chain

### Tables

Tables organize rules by function:

**filter (default):**
- INPUT - Incoming packets to local machine
- OUTPUT - Outgoing packets from local machine
- FORWARD - Packets being routed through

**nat:**
- Network Address Translation
- PREROUTING - Modify destination before routing
- POSTROUTING - Modify source before sending

**mangle:**
- Modify packet properties (QoS, marking)

**Raw:**
- Connection tracking exceptions

### Common Firewall Patterns

**Whitelist (Recommended):**
```
Default: DROP all
Allow: SSH (port 22)
Allow: HTTP (port 80)
Allow: HTTPS (port 443)
Everything else: Blocked
```

**Blacklist (Less Secure):**
```
Default: ACCEPT all
Deny: Port 666
Deny: Port 1234
Everything else: Allowed
```

Whitelist is more secure (fail-safe):
- If you forget a rule, access is denied (safer)
- Blacklist requires knowing all bad ports (impossible)

---

## Network Security

### Network Segmentation

Divide network into zones with different trust levels:

```
┌─────────────────────────────────────────────────────┐
│ Untrusted (Internet)                               │
└────────┬────────────────────────────────────────────┘
         │
         │ Firewall (strict rules)
         │
┌────────▼──────────────────────────────────────────┐
│ DMZ (Demilitarized Zone)                          │
│ - Web server, mail server (publicly accessible)   │
│ - Heavily restricted communication to internal    │
└────────┬──────────────────────────────────────────┘
         │
         │ Firewall (strict rules)
         │
┌────────▼──────────────────────────────────────────┐
│ Internal (Trusted)                                │
│ - Database servers, file servers, admin access   │
│ - More relaxed internal communication             │
└────────────────────────────────────────────────────┘
```

Principle: Service in DMZ compromised → Can't access internal systems

### Connection States

Firewalls track connection states:

| State | Meaning |
|-------|---------|
| NEW | New connection attempt |
| ESTABLISHED | Confirmed bidirectional connection |
| RELATED | Related to ESTABLISHED (e.g., FTP data) |
| INVALID | Doesn't match any connection |

Rules can match on state:
```
Allow: state ESTABLISHED,RELATED  # Responses to our connections
Allow: state NEW port 22          # New SSH connections
Deny: state NEW (default)         # Reject other new connections
```

---

## SSH & Key-Based Authentication

### SSH Security

SSH (Secure Shell) uses encryption for:
- **Authentication** - Prove identity (password or key)
- **Encryption** - Protect data in transit
- **Integrity** - Detect tampering

### SSH Keys vs Passwords

**Passwords:**
```
Pros:
- Simple to understand
- No key management needed

Cons:
- Subject to brute force attacks
- Users choose weak passwords
- Passwords transmitted (if not SSH)
- No audit trail of who logged in
```

**SSH Keys (Public-Private):**
```
Pros:
- Cryptographically secure
- Resistant to brute force
- No password needed
- Better audit logging
- Can restrict per key

Cons:
- Key management required
- Private key loss = access lost
- More complex setup
```

### How SSH Keys Work

```
1. Generate key pair:
   ssh-keygen generates:
   - Public key: Can be shared, installed on servers
   - Private key: Never shared, kept secure locally

2. Public key on server:
   Server stores your public key in ~/.ssh/authorized_keys

3. Client authentication:
   Client                        Server
   │                            │
   ├─ "I'm alice"              │
   │                            ├─ Check authorized_keys
   │<─── "Here's a challenge" ──┤
   │  (random number)           │
   │                            │
   ├─ Sign challenge with private key
   │  (only your private key can produce this signature)
   │                            │
   ├─ Send signature ──────────>│
   │                            ├─ Verify with public key
   │<─── "Access granted" ──────┤
   │                            │
```

Only someone with the matching private key can prove their identity.

---

## Cryptography Basics

### Symmetric Encryption

Same key for encryption and decryption:

```
Plaintext ──[Encrypt with key K]──> Ciphertext
Ciphertext ──[Decrypt with key K]──> Plaintext
```

Example: AES, DES
- Fast
- Both parties need secret key (how do you share securely?)

### Asymmetric Encryption

Different keys for encryption/decryption:

```
Plaintext ──[Encrypt with public key]──> Ciphertext
Ciphertext ──[Decrypt with private key]──> Plaintext
```

Example: RSA, ECDSA
- Slower but enables secure key exchange
- Public key can be shared (encrypted with it)
- Only private key can decrypt

### Digital Signatures

Prove message integrity and origin:

```
Message ──[Sign with private key]──> Signature

Recipient:
Signature ──[Verify with public key]──> ✓ Valid (from key owner)
                                      ✗ Invalid (tampered)
```

### Hash Functions

One-way conversion of data to fixed-size fingerprint:

```
Data ──[Hash function]──> Hash (e.g., SHA256)

Properties:
- Deterministic (same input = same output)
- One-way (cannot reverse)
- Collision-resistant (unlikely two different inputs have same hash)
- Avalanche effect (tiny input change = completely different hash)
```

Used for:
- Checksums (verify files not corrupted)
- Passwords (verify correct without storing password)
- Digital signatures (sign hash instead of entire message)

### TLS/SSL (HTTPS)

Uses both symmetric and asymmetric:

```
1. Handshake (asymmetric):
   Client                    Server
   │                        │
   ├─ "Hi, I'm client"     │
   │                        │
   │<─ "Hi, I'm server"    ┤
   │<─ [Server certificate]│
   │<─ [Server public key]─┤
   │                        │
   ├─ Verify certificate   │
   ├─ Generate session key │
   ├─ Encrypt with server's│
   │  public key           │
   ├─ [Encrypted session key]──>
   │                        ├─ Decrypt with private key
   │<───── "Ready" ─────────┤

2. Data transfer (symmetric):
   All data encrypted/decrypted with shared session key (fast)
```

---

## Security Best Practices

### The Principle of Least Privilege

Grant minimum permissions needed:

**Bad:**
```
chmod 777 /var/www         # Everyone can delete entire website
sudo su -                  # Unlogged privilege escalation
```

**Good:**
```
chown www-data:www-data /var/www
chmod 755 /var/www        # Owner full, group/other read+execute only
sudo -l                   # Log which commands user ran
```

### Defense in Depth

No single control is perfect:

1. **Network**: Firewall blocks attackers
2. **Host OS**: Permissions prevent unauthorized access
3. **Service**: Hardened configuration, minimal exposure
4. **Application**: Input validation, error handling
5. **Data**: Encryption at rest and in transit

If firewall is bypassed → OS permissions still protect
If OS is compromised → Service isolation helps
If service is compromised → Monitoring detects it

### Separation of Concerns

Divide responsibilities:

```
Web Server (alice user, limited):
- Can read web files
- Can write logs
- Cannot access database

Database (bob user, limited):
- Can access database files
- Cannot access web files
- Cannot modify logs

Compromise of web server → Cannot access database
Compromise of database → Cannot modify website
```

### Monitoring & Logging

You can't secure what you don't monitor:

**What to log:**
- Failed login attempts
- Privilege escalation (sudo)
- Permission changes
- System configuration changes
- Firewall rule changes
- Network connections (unusual ports)

**Regular review:**
- Check logs weekly/daily
- Set up alerts for suspicious activity
- Investigate anomalies

---

## Summary

Linux security is a **comprehensive, multi-layered approach**:

1. **Authentication** - Prove who you are
2. **Authorization** - Define what you can do
3. **Access Control** - DAC (traditional) or MAC (mandatory)
4. **Firewall** - Control network access
5. **Cryptography** - Protect data and identity
6. **Monitoring** - Detect and respond

Security is not something you configure once—it's a continuous process of:
- Assessing threats
- Implementing controls
- Monitoring effectiveness
- Updating as threats evolve
- Training users
- Responding to incidents

The goal is not "perfect security" but **acceptable risk** given your threat model and resources.
