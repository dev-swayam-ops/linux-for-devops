# System Services and Daemons

**Learn how to manage, monitor, and troubleshoot Linux services and background processes using systemd.**

## Why This Matters

Every Linux system runs services—programs that start at boot and run continuously in the background. Understanding services is essential for:

- **DevOps**: Deploy and manage applications reliably
- **Sysadmins**: Keep systems running 24/7
- **Troubleshooting**: Debug why services fail
- **Automation**: Create reproducible deployments
- **Monitoring**: Track service health

### Real-World Scenarios

**Scenario 1: Application Won't Start on Boot**
You deploy a web application but it doesn't start after server reboot. You need to create a systemd service file to ensure it starts automatically.

**Scenario 2: Service Keeps Crashing**
Your database service crashes sporadically. You need to understand dependency ordering, restart policies, and how to debug failures.

**Scenario 3: Port Conflicts**
Two services want to listen on port 8080. You need to understand socket activation and how to manage service dependencies.

**Scenario 4: Service Performance Issues**
A background process uses too many resources. You need to limit resource consumption and set priorities.

**Scenario 5: Audit Trail**
Your company needs to know which services are running, when they started, and who made changes. You need service monitoring and audit capabilities.

---

## Prerequisites

- **Module 01**: Linux Basics (file permissions, processes)
- **Module 02**: Advanced Commands (grep, awk, find)
- **Linux Distribution**: Ubuntu 20.04+ or Debian 10+ recommended
- **Root/Sudo Access**: Required for service management
- **Time**: 5-7 hours for complete module

---

## Learning Objectives

### Service Management Basics (Beginner)
1. Understand what daemons and services are
2. Recognize the difference between systemd and other init systems
3. Use basic systemd commands (start, stop, status)
4. Check service status and logs
5. Understand service enable/disable

### Service Configuration (Beginner to Intermediate)
6. Read and understand systemd service files
7. Identify key service file directives
8. Understand ExecStart, Type, Restart policies
9. Recognize dependency directives
10. Interpret service states (running, failed, inactive)

### Advanced Service Management (Intermediate)
11. Create custom systemd service files
12. Set resource limits on services
13. Configure socket activation
14. Implement service dependencies
15. Use service timers as alternatives to cron

### Troubleshooting and Monitoring (Intermediate)
16. Debug service startup failures
17. Monitor service resource usage
18. Analyze service logs with journalctl
19. Understand service security contexts
20. Create monitoring and alert systems

---

## Module Roadmap

```
README.md (this file)
├── 01-theory.md
│   ├── What is a daemon?
│   ├── History: init, upstart, systemd
│   ├── Systemd architecture
│   ├── Unit types and life cycle
│   ├── Service dependencies
│   └── Security contexts
│
├── 02-commands-cheatsheet.md
│   ├── systemctl (service control)
│   ├── systemd-analyze (performance)
│   ├── journalctl (logging)
│   ├── timedatectl, hostnamectl (system info)
│   └── Common patterns
│
├── 03-hands-on-labs.md
│   ├── Lab 1: Explore existing services
│   ├── Lab 2: Understand systemd units
│   ├── Lab 3: Create custom service
│   ├── Lab 4: Service dependencies
│   ├── Lab 5: Debug failed services
│   ├── Lab 6: Resource limits
│   ├── Lab 7: Socket activation
│   └── Lab 8: Service timers
│
└── scripts/
    ├── daemon-monitor.sh (real-time service monitoring)
    ├── service-status-reporter.sh (comprehensive reporting)
    └── README.md (script documentation)
```

---

## Quick Glossary

| Term | Definition |
|------|-----------|
| **Daemon** | Background process running without controlling terminal |
| **Service** | Daemon managed by systemd |
| **Unit** | Configuration file for systemd resource (service, socket, timer, etc.) |
| **Unit File** | Text file in /etc/systemd/system/ or /usr/lib/systemd/system/ |
| **systemd** | Modern Linux init system managing services, mounts, timers |
| **systemctl** | Command-line tool to manage systemd services |
| **journalctl** | Tool to query systemd logs |
| **PID** | Process ID (unique identifier for running process) |
| **ExecStart** | Command that systemd runs to start the service |
| **Type** | Service type (simple, forking, notify, idle, oneshot) |
| **Restart** | Policy for automatic service restart (on-failure, always, no) |
| **Dependency** | Requires, After, Wants (ordering and hard/soft dependencies) |
| **Target** | Grouping of services (multi-user.target, graphical.target) |
| **Socket** | Communication endpoint for inter-process communication |
| **Timer** | Systemd's replacement for cron jobs |
| **Enabled** | Service configured to start at boot |
| **Active** | Service currently running |
| **Failed** | Service attempted to start but encountered error |
| **Security Context** | User, capabilities, and isolation for service |
| **cgroup** | Control group limiting service resources |
| **Unit Dependency** | Before, After, Requires, Wants between units |

---

## Common Workflows

### Workflow 1: Start/Stop a Service

```bash
# Start a service immediately
sudo systemctl start nginx

# Stop a service
sudo systemctl stop nginx

# Restart (stop then start)
sudo systemctl restart nginx

# Check current status
sudo systemctl status nginx

# Check if enabled at boot
sudo systemctl is-enabled nginx
```

### Workflow 2: Enable Service at Boot

```bash
# Enable service to start automatically
sudo systemctl enable nginx

# Disable from auto-starting
sudo systemctl disable nginx

# Enable and start in one command
sudo systemctl enable --now nginx

# Check what's enabled
systemctl list-unit-files | grep enabled
```

### Workflow 3: Debug Service Failure

```bash
# Check service status with error details
sudo systemctl status nginx

# View recent logs
sudo journalctl -u nginx -n 50  # Last 50 lines

# Follow logs in real-time
sudo journalctl -u nginx -f

# Check service configuration
systemctl cat nginx

# Verify service file syntax
systemd-analyze verify /etc/systemd/system/myapp.service
```

### Workflow 4: Create Custom Service

```bash
# Create service file
sudo nano /etc/systemd/system/myapp.service

# Add content (see 03-hands-on-labs.md Lab 3)

# Reload systemd configuration
sudo systemctl daemon-reload

# Start and enable
sudo systemctl enable --now myapp
```

### Workflow 5: Monitor Service Health

```bash
# Check service status
sudo systemctl status myapp

# View resource usage
ps aux | grep myapp
top -p $(pgrep -f myapp)

# Check logs for errors
sudo journalctl -u myapp --since "1 hour ago"
```

---

## Module Features

### Practical Content
- ✅ Real-world service management examples
- ✅ Common troubleshooting scenarios
- ✅ Best practices from production systems
- ✅ Security-aware recommendations

### Comprehensive Labs
- ✅ 8 hands-on labs covering all topics
- ✅ Safe test environments (custom services)
- ✅ Complete setup and cleanup procedures
- ✅ Verification checklists for each lab

### Production Scripts
- ✅ daemon-monitor.sh: Real-time service monitoring
- ✅ service-status-reporter.sh: Comprehensive status reporting
- ✅ Both production-quality with error handling

### Tooling
- ✅ 20+ essential systemd commands
- ✅ 50+ real command examples
- ✅ Quick reference patterns
- ✅ Troubleshooting decision trees

---

## Getting Started

### Prerequisites Check

```bash
# Verify systemd is installed
systemctl --version

# Check current systemd version
systemd --version

# View available services
systemctl list-unit-files --type=service

# Check system-wide service status
systemctl status
```

### Recommended Learning Path

1. **Start with Theory** (40 minutes)
   - Understand daemon concepts
   - Learn systemd architecture
   - Read about unit types

2. **Commands and Tools** (30 minutes)
   - Learn essential systemctl commands
   - Practice with existing services
   - Get comfortable with journalctl

3. **Hands-On Labs** (3-4 hours)
   - Lab 1-2: Explore existing services
   - Lab 3: Create custom service
   - Lab 4-8: Advanced topics

4. **Production Scripts** (30 minutes)
   - Review monitoring scripts
   - Adapt for your environment
   - Deploy in test system

---

## Success Criteria

By completing this module, you'll be able to:

- ✅ Explain what services and daemons are
- ✅ List and manage services with systemctl
- ✅ Create custom systemd service files
- ✅ Debug failed services effectively
- ✅ Monitor service health and performance
- ✅ Implement service dependencies
- ✅ Use timers as cron alternatives
- ✅ Deploy automated monitoring solutions

---

## Module Statistics

| Metric | Value |
|--------|-------|
| Total Content | 6,000+ lines |
| Theory Sections | 10+ |
| Commands Documented | 20+ |
| Hands-On Labs | 8 |
| Scripts | 2 production tools |
| Estimated Time | 5-7 hours |
| Difficulty | Beginner to Intermediate |

---

## Important Notes

### Safety

- Services run with elevated privileges by default
- Creating/modifying services requires sudo
- All labs use test services (safe)
- No production system changes required
- Always test in non-critical environment first

### Distribution Notes

- Primary focus: **Ubuntu 20.04+**, **Debian 10+**
- RHEL/CentOS equivalents noted where relevant
- systemd is standard on all modern distributions
- Examples use apt/systemctl (same everywhere)

### Best Practices Emphasized

- Always test service files before deployment
- Use descriptive service names
- Document service purpose in comments
- Set appropriate restart policies
- Monitor service resource usage
- Keep logs for audit trails
- Use security contexts and limits

---

## Troubleshooting This Module

**Command not found?**
- Verify systemd installed: `systemctl --version`
- All commands standard on modern Linux
- Run labs on Ubuntu 20.04+ or Debian 10+ for best results

**Permission denied?**
- Most systemctl operations need sudo
- Use `sudo systemctl` for administrative commands
- Some read-only commands work without sudo

**Service won't start?**
- Check logs: `sudo journalctl -u servicename -n 50`
- Verify configuration: `systemd-analyze verify unit-file`
- Run through Lab 5 (Debug Services) for detailed steps

---

## Next Steps After This Module

- **Module 07**: Process Management (advanced process control)
- **Module 13**: Logging and Monitoring (centralized logging)
- **Module 17**: Troubleshooting and Scenarios (complex problems)
- **Module 14**: Package Management (installing services)

---

## Quick Reference Commands

```bash
# Most Common Commands
systemctl status nginx                    # Check status
sudo systemctl start nginx                # Start service
sudo systemctl stop nginx                 # Stop service
sudo systemctl restart nginx              # Restart service
sudo systemctl enable nginx               # Enable at boot
sudo systemctl disable nginx              # Disable at boot
sudo journalctl -u nginx -n 50 -f        # View logs
systemctl list-units --type=service       # List all services
systemctl cat nginx                       # Show configuration
sudo systemctl daemon-reload              # Reload configs
```

---

*System Services and Daemons: Comprehensive Learning Module*  
*Master service management for reliable Linux deployments*
