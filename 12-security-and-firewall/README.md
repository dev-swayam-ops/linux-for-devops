# 12. Linux Security & Firewall

## Overview

Linux security is a **multi-layered approach** protecting systems from unauthorized access, data breaches, and malicious activities. Understanding security fundamentals is critical for:

- **System hardening** - Reducing attack surface and vulnerabilities
- **Access control** - Managing who can do what on your system
- **Network protection** - Controlling inbound/outbound traffic
- **Compliance** - Meeting regulatory and organizational standards
- **Incident response** - Identifying and responding to security events
- **Production deployments** - Protecting sensitive data and services

In real-world DevOps scenarios, you'll encounter:
- Systems compromised due to weak passwords or open ports
- Data exfiltration through unfiltered network access
- Privilege escalation vulnerabilities
- Misconfigured firewalls causing operational issues
- Security audits and compliance requirements
- Performance impact of security measures

Security is not optional—it's a fundamental responsibility for every systems administrator and DevOps engineer.

## Prerequisites

Before starting this module, you should understand:

- **Basic Linux commands**: File operations, navigation, text processing
- **User and permissions**: Read [08-user-and-permission-management](../08-user-and-permission-management/)
- **Process management**: Read [07-process-management](../07-process-management/)
- **System services**: Read [06-system-services-and-daemons](../06-system-services-and-daemons/)
- **Network basics**: IP addresses, ports, protocols (TCP/UDP)
- **Command line**: Comfortable with Linux terminal and elevated privileges (sudo)

## Learning Objectives

After completing this module, you will be able to:

- ✓ Understand Linux security architecture and threat models
- ✓ Implement file permissions and Access Control Lists (ACLs)
- ✓ Configure user and group-based access control
- ✓ Manage sudo privileges and authentication
- ✓ Understand and use SELinux for mandatory access control
- ✓ Work with AppArmor confinement
- ✓ Configure firewalls using iptables/nftables
- ✓ Understand UFW (Uncomplicated Firewall) on Ubuntu
- ✓ Implement firewall rules for common services
- ✓ Analyze and troubleshoot firewall issues
- ✓ Apply security best practices for hardening systems
- ✓ Understand certificate-based authentication (SSH keys)
- ✓ Monitor for security issues and unauthorized access

## Module Roadmap

1. **[01-theory.md](01-theory.md)** - Comprehensive security concepts
   - Security layers and defense-in-depth
   - User authentication and authorization
   - File permissions (DAC)
   - SELinux and AppArmor (MAC)
   - Firewall fundamentals
   - Network security concepts
   - Cryptography basics

2. **[02-commands-cheatsheet.md](02-commands-cheatsheet.md)** - Quick reference
   - Permission and ownership commands
   - User and group management
   - SELinux tools
   - AppArmor tools
   - Firewall commands (iptables, ufw, firewall-cmd)
   - SSH and key management
   - Security audit commands

3. **[03-hands-on-labs.md](03-hands-on-labs.md)** - Practical exercises
   - Lab 1: Audit file permissions
   - Lab 2: Configure user permissions with ACLs
   - Lab 3: Set up sudo for team members
   - Lab 4: Implement SELinux policies
   - Lab 5: Configure AppArmor profiles
   - Lab 6: Create basic firewall rules
   - Lab 7: Firewall for web server
   - Lab 8: SSH key-based authentication
   - Lab 9: Monitor security events
   - Lab 10: Security hardening checklist

4. **[scripts/](scripts/)** - Practical security tools
   - `firewall-rule-manager.sh` - Manage firewall rules safely
   - `security-auditor.sh` - Audit system security posture
   - `selinux-policy-helper.sh` - Simplify SELinux management

## Quick Glossary

| Term | Definition |
|------|-----------|
| **DAC** | Discretionary Access Control; user can grant permissions (traditional Unix) |
| **MAC** | Mandatory Access Control; security policy enforced by system (SELinux, AppArmor) |
| **ACL** | Access Control List; extends file permissions beyond user/group/other |
| **SELinux** | Security Enhanced Linux; Red Hat mandatory access control system |
| **AppArmor** | Ubuntu/Debian mandatory access control using profiles |
| **Firewall** | System software controlling network traffic (inbound/outbound) |
| **iptables** | Legacy Linux firewall tool (Netfilter framework) |
| **nftables** | Modern replacement for iptables with better performance |
| **UFW** | Uncomplicated Firewall; simplified firewall interface for Ubuntu |
| **sudo** | Execute command as another user (usually root) with logging |
| **SSH Key** | Asymmetric cryptography for secure authentication (no password needed) |
| **Certificate** | Digital credential verifying identity (used in TLS/SSL) |
| **Threat model** | Analysis of potential attackers and attack vectors |

## Time Estimate

- Reading theory: 45-60 minutes
- Hands-on labs: 120-150 minutes
- Total time to complete: 3-3.5 hours

## Recommended Environment

- **VM or test system** (do not experiment on production servers)
- **Linux distribution**: Ubuntu 20.04 LTS+ (primary) or CentOS 8+ (equivalent)
- **Disk space**: Minimum 15 GB
- **Memory**: 2 GB minimum, 4 GB recommended
- **Network**: Internet connection for updates and research

## Safety Notes

⚠️ **Critical Security Warnings:**

- **Test on VMs only** - Wrong firewall rules can lock you out
- **Keep recovery access** - Have a bootable USB or another admin account
- **Document changes** - Keep notes of what you modify
- **Backup configurations** - Copy firewall and security configs before changes
- **Don't disable security blindly** - Understand why you're making changes
- **Principle of least privilege** - Grant minimum permissions needed

## Success Criteria

You'll know you've mastered this module when you can:

- View and understand file permissions on any file
- Implement complex permission scenarios with ACLs
- Create firewall rules from security requirements
- Explain why a firewall rule is needed
- Troubleshoot permission and firewall issues
- Harden a Linux system following best practices
- Understand the trade-offs between security and usability
- Explain security concepts to non-technical stakeholders

## Key Security Principles

1. **Defense in Depth** - Multiple security layers, not single point
2. **Principle of Least Privilege** - Give minimum permissions needed
3. **Fail Secure** - Default to deny, explicitly allow what's needed
4. **Separation of Duty** - Critical functions split among multiple people
5. **Layered Security** - OS security + application security + network security
6. **Monitoring & Logging** - Detect and respond to incidents

## Important Disclaimers

- This module covers **defensive security** for system hardening, not offensive penetration testing
- Linux security is a specialized field with advanced certifications (CISSP, CEH, OSCP)
- Real-world security requires continuous learning and updates
- No single configuration is "perfectly secure"—security is about risk management
- Always balance security with usability and operational needs

## Next Steps

1. Set up a test VM (VirtualBox, KVM, or cloud)
2. Read theory section for conceptual understanding
3. Execute hands-on labs on your test VM
4. Use scripts to automate security tasks
5. Apply hardening principles to your own systems
6. Continue learning about advanced security topics
