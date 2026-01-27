# Module 17: Troubleshooting and Scenarios

## What You'll Learn

- Systematic troubleshooting methodology
- Analyze system logs and errors
- Diagnose common issues
- Performance monitoring and analysis
- Network connectivity debugging
- Service failure resolution
- Root cause analysis techniques

## Prerequisites

- Complete Module 1-16: All previous modules
- Understanding of Linux fundamentals
- Practical shell experience
- System administration basics

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Logs** | System records of events |
| **Exit Code** | Command success (0) or failure (non-zero) |
| **Strace** | System call tracing tool |
| **RCA** | Root Cause Analysis |
| **Symptoms** | What users observe |
| **Root Cause** | Why problem occurs |
| **Remediation** | Fix for issue |
| **Prevention** | Stop recurrence |

## Troubleshooting Methodology

### The 5-Step Approach

1. **Gather Information**
   ```bash
   uname -a              # System info
   journalctl -xe        # Recent errors
   ps aux | grep service # Process status
   netstat -an | grep :80 # Port listening
   ```

2. **Reproduce Issue**
   ```bash
   # Try to cause the problem
   # Note exact steps
   # Record error messages
   # Check timing patterns
   ```

3. **Isolate Problem**
   ```bash
   # Is it application or system?
   # Is it network or local?
   # Is it permission or configuration?
   ```

4. **Implement Fix**
   ```bash
   # Start with safest changes
   # Test before production
   # Document changes
   ```

5. **Verify Resolution**
   ```bash
   # Confirm fix works
   # Monitor for recurrence
   # Note for future reference
   ```

## Hands-on Lab: Troubleshoot Service Failure

### Scenario
Web service stopped responding. Diagnose and fix.

### Investigation

```bash
# Check service status
sudo systemctl status nginx
# Output: inactive (dead)

# Check logs
sudo journalctl -u nginx -n 50
# Look for error messages

# Check configuration
sudo nginx -t
# Output: configuration test failed

# View specific config
sudo cat /etc/nginx/nginx.conf | head -20

# Check port availability
sudo netstat -tlnp | grep :80
# Should show nginx listening

# Check file permissions
ls -la /etc/nginx/conf.d/
# Should be readable

# Restart service
sudo systemctl start nginx
sudo systemctl status nginx

# Verify connectivity
curl http://localhost
# Should respond
```

### Expected Output

```
● nginx.service - A high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service)
   Active: active (running) since Mon 2025-01-27 14:30:00
   
tcp  0  0 0.0.0.0:80  0.0.0.0:*  LISTEN  1234/nginx
tcp  0  0 0.0.0.0:443 0.0.0.0:*  LISTEN  1234/nginx
```

## Validation

Confirm troubleshooting skills:

- [ ] Identified service issue
- [ ] Checked logs successfully
- [ ] Found root cause
- [ ] Applied fix correctly
- [ ] Verified resolution
- [ ] Documented findings

## Cleanup

```bash
# Restore original state
sudo systemctl stop nginx
# Or revert configuration changes
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Guessing without data | Always check logs first |
| Changing too much | Change one thing at a time |
| Forgetting permissions | Use `sudo` or check ownership |
| Not checking logs | `journalctl`, `tail -f` |
| Restarting without diagnosis | Understand problem first |

## Troubleshooting

**Q: Service won't start?**
A: Check config: `sudo nginx -t`. Check logs: `journalctl -xe`. Check permissions.

**Q: Port already in use?**
A: Find process: `lsof -i :8080`. Kill if needed: `kill -9 PID`.

**Q: Performance degraded?**
A: Check CPU: `top`. Check memory: `free -h`. Check disk: `df -h`. Check I/O: `iostat`.

**Q: Can't connect to service?**
A: Ping server. Check port listening. Check firewall. Test connection locally first.

**Q: Application crashing?**
A: Check logs. Check core dumps. Use strace. Check dependencies.

## Next Steps

1. Practice each troubleshooting scenario
2. Build monitoring dashboards
3. Create runbooks for common issues
4. Document incidents
5. Share knowledge with team
