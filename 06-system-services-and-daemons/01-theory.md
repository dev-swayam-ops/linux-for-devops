# System Services and Daemons: Conceptual Foundations

Understanding services requires knowing how Linux manages long-running background processes.

---

## Section 1: What Is a Daemon?

### Definition

A **daemon** is a background process that:
- Runs without an associated terminal (detached from terminal)
- Starts automatically or manually
- Runs continuously or on schedule
- Provides services to other processes
- Often named with 'd' suffix (sshd, httpd, mysqld)

### Daemon vs Regular Process

```
Regular Process:
┌─────────────────────────────┐
│  Foreground Process         │
│  - Connected to terminal    │
│  - Receives input from user │
│  - User can stop with Ctrl+C│
│  - Dies when terminal closes│
└─────────────────────────────┘
        ↓
     Foreground output

Daemon Process:
┌─────────────────────────────┐
│  Background Service         │
│  - NO terminal connection   │
│  - No keyboard input        │
│  - Handles requests from    │
│    other programs           │
│  - Survives terminal closure│
└─────────────────────────────┘
        ↓
     Listening for requests
```

### Examples of Daemons

```
System Daemons:
├── sshd      → SSH server (remote login)
├── httpd     → Apache web server
├── mysqld    → MySQL database
├── systemd   → Init system, service manager
├── journald  → Logging service
├── udevd     → Device manager
└── cron      → Scheduled task execution

Application Daemons:
├── nginx     → Web server
├── postgres  → Database
├── docker    → Container runtime
├── kubernetes→ Orchestration
└── consul    → Service discovery
```

---

## Section 2: History of Linux Init Systems

### Evolution: From init to systemd

```
1990s: SysVinit (System V-style init)
├── Shell script-based
├── Sequential startup
├── Located in /etc/init.d/
└── Problem: Slow, sequential

       ↓

2006: Upstart (Ubuntu innovation)
├── Event-based startup
├── Parallel service starts
├── Configuration in /etc/init/
└── Problem: Complex, Ubuntu-specific

       ↓

2010: systemd (Lennart Poettering, Red Hat)
├── Modern, comprehensive system manager
├── Parallel service startup (fast)
├── Service dependencies and ordering
├── Centralized logging
├── Resource management (cgroups)
├── Socket activation (lazy loading)
└── Now standard on all major distributions
```

### Why systemd Won

```
systemd Advantages:
├── Speed: Parallel startup instead of sequential
├── Reliability: Dependency tracking and auto-restart
├── Flexibility: Socket activation, timers, mounts
├── Monitoring: Integrated logging and process tracking
├── Standard: Ubiquitous across distributions
└── Feature-rich: One tool manages all system resources

Before systemd:
- Services managed independently
- Complex shell scripts
- Manual dependency ordering
- Separate logging systems
- Resource limits hard to enforce

After systemd:
- Unified service management
- Simple declarative configuration
- Automatic dependency resolution
- Journald centralized logging
- cgroups for resource limits
```

---

## Section 3: Systemd Architecture

### High-Level Overview

```
System Boot:
1. BIOS/UEFI loads bootloader
2. Bootloader loads Linux kernel
3. Kernel initializes hardware
4. Kernel loads and executes systemd (PID 1)
5. systemd becomes "init" - parent of all processes

Systemd manages:
├── Services (long-running daemons)
├── Sockets (network listeners, IPC)
├── Timers (scheduled tasks)
├── Mounts (filesystem mounting)
├── Devices (hardware detection)
├── Targets (boot stages)
└── Slices (resource groups)
```

### Key Directories

```
/usr/lib/systemd/system/
├── Default unit files
├── Provided by packages
├── Should not be modified
└── Overridden by /etc/systemd/system/

/etc/systemd/system/
├── Local unit files
├── Administrator modifications
├── Custom services
└── Takes precedence over /usr/lib/systemd/system/

/run/systemd/system/
├── Runtime generated units
├── Temporary overrides
└── Cleared on reboot

/opt/*/systemd/system/ or /usr/local/lib/systemd/system/
├── Third-party application units
└── Non-package managed services
```

---

## Section 4: Service Unit Files

### Basic Structure

```ini
[Unit]
Description=My Web Application
Documentation=https://example.com/docs
After=network.target
Wants=ssl-cert-validation.service

[Service]
Type=simple
User=www-data
ExecStart=/opt/myapp/bin/start.sh
ExecStop=/opt/myapp/bin/stop.sh
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### Unit Section

```ini
[Unit]
Description=     Service human-readable name
Documentation=   URL pointing to documentation
Requires=        Hard dependency (start fails if dependency missing)
Wants=           Soft dependency (start continues if missing)
Before=          This unit must start before these
After=           This unit must start after these
Conflicts=       Cannot run simultaneously with these
ConditionPathExists= Only start if file/dir exists
ConditionUser=   Only start if run by specific user
ConditionVirtualization= Only start in/outside VM
```

### Service Section

```ini
[Service]
Type=             simple|forking|oneshot|notify|idle
User=             User to run service as
Group=            Group to run service as
ExecStart=        Command to start service
ExecStartPre=     Command to run before ExecStart
ExecStartPost=    Command to run after ExecStart
ExecStop=         Command to stop service
ExecStopPost=     Command to run after stop
ExecReload=       Command to reload configuration
Restart=          on-failure|always|no|on-success
RestartSec=       Seconds to wait before restart
StartLimitInterval= Time window for restart limit
StartLimitBurst=  Max restarts in interval
StandardOutput=   journal|syslog|kmsg|journal+console|null
StandardError=    journal|syslog|kmsg|journal+console|null
Environment=      Environment variables to set
EnvironmentFile=  File to source environment from
WorkingDirectory= Directory to chdir before exec
RuntimeDirectory= Create /run/service-name as runtime dir
StateDirectory=   Create /var/lib/service-name for state
CacheDirectory=   Create /var/cache/service-name
LogsDirectory=    Create /var/log/service-name
Umask=            File creation mask (0022 = default)
LimitNOFILE=      Max open files
LimitNPROC=       Max processes
MemoryLimit=      Maximum memory allowed
CPUQuota=         CPU usage limit
CPUWeight=        CPU scheduling priority
KillMode=         How to kill process
KillSignal=       Signal to send (SIGTERM, SIGKILL)
```

### Type Explained

```
Type=simple (default)
├── Process runs in foreground
├── systemd waits for ExecStart to complete
├── Process keeps running (normal daemon)
└── Example: nginx, apache2

Type=forking
├── Process forks itself
├── Parent exits after child forks
├── systemd detects fork completion
├── Legacy daemon behavior
└── Example: older PostgreSQL versions

Type=oneshot
├── Service runs once and exits
├── Used for startup scripts
├── systemd waits for completion
└── Example: fsck, network config script

Type=notify
├── Service sends readiness notification
├── systemd waits for READY=1 signal
├── Ensures dependencies start after readiness
└── Example: systemd itself, newer apps

Type=idle
├── Service starts after all queued jobs
├── Reduces noise from concurrent startup
└── Example: systemd-update-utmp
```

### Install Section

```ini
[Install]
WantedBy=multi-user.target
├── Soft dependency
├── When enabled, adds symlink
└── Service starts in multi-user mode

RequiredBy=multi-user.target
├── Hard dependency
├── Service required for target to start
└── Rarely used

WantedBy=graphical.target
├── For GUI services
├── Starts in graphical mode

Also used for socket/timer activation
```

---

## Section 5: Service Lifecycle and States

### State Diagram

```
                    ┌─────────────────┐
                    │    inactive     │ (not running)
                    └────────┬────────┘
                            │ start
                            ↓
                  ┌──────────────────────┐
                  │   activating        │ (starting up)
                  └──────────┬───────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ↓                 ↓                 ↓
    ┌──────────┐    ┌──────────────┐  ┌──────────┐
    │ failed   │    │ active       │  │reloading │
    │(crashed) │    │(running ok)  │  │(config)  │
    └────┬─────┘    └──────┬───────┘  └────┬─────┘
         │                 │                │
         │                 │                │
         └─────────────┬───┴────────────────┘
                       │ stop
                       ↓
              ┌──────────────────┐
              │ deactivating    │ (shutting down)
              └─────────┬────────┘
                        │
                        ↓
              ┌──────────────────┐
              │   inactive      │ (stopped)
              └──────────────────┘
```

### State Explanations

```
inactive
├── Service not running
├── Properly stopped
└── No errors

active (running)
├── Service running normally
├── Available to serve requests
└── No issues detected

activating
├── Service starting
├── Transitioning to active
├── Startup scripts executing

deactivating
├── Service shutting down
├── Stop scripts executing
├── Transitioning to inactive

failed
├── Service encountered error
├── Startup failed or crash detected
├── Automatic restart may occur

reloading
├── Service reloading configuration
├── Connection/data may be preserved
├── Temporary state during reload

dead
├── Service not installed/found
├── Unit file missing or broken
└── Check systemd configuration
```

---

## Section 6: Service Dependencies

### Hard vs Soft Dependencies

```
Requires (Hard):
├── Dependent service MUST start
├── If required service fails to start
│   → Dependent service fails
├── Creates strict ordering
└── Example: Database must start before app

    app.service:
    [Unit]
    Requires=database.service
    
    If database.service fails:
    → app.service fails

Wants (Soft):
├── Optional dependency
├── If wanted service fails
│   → Dependent service continues anyway
├── Graceful degradation
└── Example: App continues without optional cache

    app.service:
    [Unit]
    Wants=redis-cache.service
    
    If redis-cache fails:
    → app.service continues
```

### Ordering Directives

```
After (ordering control):
├── Specifies startup order
├── "This unit starts AFTER these"
├── Dependency not required, just ordered
└── Usually paired with Wants/Requires

    web.service:
    [Unit]
    After=network.target

Before (ordering control):
├── Specifies startup order
├── "This unit starts BEFORE these"
├── Dependency not required, just ordered
└── Rarely used

    ssl-config.service:
    [Unit]
    Before=web.service
```

### Dependency Examples

```
Web Application Stack Startup Order:

1. Boot starts
2. network.target activates
   └─ kernel network initialization
3. database.service starts
   └─ Wait for port 5432 to listen
4. app.service starts (After=database.service)
   └─ Waits for database connection
5. nginx.service starts (After=app.service)
   └─ Proxies requests to app

Declaration in app.service:
[Unit]
Wants=database.service
After=database.service network.target
```

### Target Units

```
Targets = Boot stages/run levels

multi-user.target
├── System fully booted
├── All services running
├── No graphics (server mode)
└── /etc/systemd/system/multi-user.target.wants/
    contains links to services to start

graphical.target
├── GUI available
├── Includes multi-user.target
├── X11/Wayland started
└── Used by desktop systems

Emergency target / Rescue target
├── Minimal environment
├── Root filesystem read-write
├── Rescue shell available
├── Used for maintenance
```

---

## Section 7: Process Management and Cgroups

### Process Hierarchy

```
systemd (PID 1)
├── Init process
├── Parent of all services
└── Cannot be killed

  ├─ sshd (PID 100)
  │  └─ bash (PID 150) [SSH session]
  │     └─ curl (PID 152) [User command]
  │
  ├─ nginx (PID 200) [Master process]
  │  ├─ nginx (PID 201) [Worker process 1]
  │  ├─ nginx (PID 202) [Worker process 2]
  │  └─ nginx (PID 203) [Worker process 3]
  │
  └─ mysql (PID 300) [Main process]
     ├─ mysql (PID 301) [Connection handler]
     ├─ mysql (PID 302) [Connection handler]
     └─ mysql (PID 303) [IO handler]
```

### Cgroups (Control Groups)

```
cgroups: Kernel feature to limit/prioritize resources

Per-service cgroup:
/sys/fs/cgroup/system.slice/nginx.service/

Can limit:
├── Memory: MemoryLimit=512M
├── CPU: CPUQuota=50%
├── Processes: TasksMax=500
├── I/O: IOWeight=100
└── Device access: DeviceAllow=/dev/mem

Example in service file:
[Service]
MemoryLimit=512M
CPUQuota=75%
TasksMax=1000
```

### Process Termination

```
Kill Sequence:

1. systemctl stop service
2. systemd sends KillSignal (SIGTERM by default)
3. Process handles signal, performs cleanup
4. Wait TimeoutStopSec seconds
5. If still running, send KillMode (SIGKILL)

Configuration:
[Service]
KillMode=process (stop only main)
         | mixed (main + children)
         | none (systemd doesn't kill)
KillSignal=SIGTERM (signal to send)
TimeoutStopSec=30s (grace period)
```

---

## Section 8: Logging with Journalctl

### Systemd Journal

```
journalctl logs:
├── Centralized logging from all services
├── Stored in /var/log/journal/
├── Binary format (structured, indexed)
├── Searchable by field
├── Persistent (survives reboot)
└── Replaces scattered syslog files

Query services:
$ sudo journalctl -u nginx
    [Shows all nginx logs]

$ sudo journalctl -u nginx -n 50
    [Last 50 lines]

$ sudo journalctl -u nginx -f
    [Follow in real-time]

$ sudo journalctl -u nginx --since "1 hour ago"
    [Last hour of logs]

$ sudo journalctl -u nginx -p err
    [Error level only]

$ sudo journalctl --no-pager
    [No pagination]
```

### Log Priority Levels

```
emerg   (0)  Emergency system is unusable
alert   (1)  Action must be taken immediately
crit    (2)  Critical condition
err     (3)  Error condition
warning (4)  Warning condition
notice  (5)  Normal but significant
info    (6)  Informational
debug   (7)  Debug-level messages

Usage:
$ sudo journalctl -p err          # Error and above
$ sudo journalctl -p info..err    # Info through error (inclusive range)
$ sudo journalctl -u nginx -p crit
```

---

## Section 9: Socket Activation

### Lazy Loading Pattern

```
Without socket activation:
Boot → nginx starts immediately
       ├─ Uses memory even if no requests
       └─ Wastes resources

With socket activation:
Boot → Socket listening, nginx not yet started
       ↓
First request arrives → Systemd starts nginx
       ↓
Connection routed to nginx
       ↓
Subsequent requests go to running nginx

Benefits:
├── Faster boot
├── Resources used only when needed
├── Multiple services on same port (carefully)
└── Automatic restart after crash
```

### Socket Unit Files

```
/etc/systemd/system/myapp.socket

[Unit]
Description=My App Socket
Before=myapp.service

[Socket]
ListenStream=8080
Accept=yes

[Install]
WantedBy=sockets.target
```

---

## Section 10: Timers (Systemd Cron Alternative)

### Timer Units

```
systemd timer advantages over cron:
├── Integration with service lifecycle
├── Per-user timers in user units
├── Better logging/monitoring
├── Resource isolation
└── No need for separate cron daemon

Timer unit:
/etc/systemd/system/backup.timer

[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target

Associated service:
/etc/systemd/system/backup.service

[Unit]
Description=Backup Script
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

---

## Section 11: Troubleshooting Framework

### Diagnostic Decision Tree

```
Service not starting?
│
├─ Check status:
│  $ systemctl status myapp
│  └─ Read error message carefully
│
├─ Check logs:
│  $ sudo journalctl -u myapp -n 50
│  └─ Look for error details
│
├─ Verify configuration:
│  $ systemctl cat myapp
│  └─ Check syntax with systemd-analyze verify
│
├─ Check dependencies:
│  $ systemctl list-dependencies myapp
│  └─ Verify required services running
│
├─ Check permissions:
│  $ ls -l /etc/systemd/system/myapp.service
│  └─ Correct ownership and readable
│
└─ Test ExecStart command:
   $ sudo -u appuser /path/to/command
   └─ Run as service user manually

Service crashes frequently?
│
├─ Check logs for patterns
├─ Review Restart= policy
├─ Check resource limits
└─ Monitor dependencies
```

---

## Summary

**Key Concepts**:
1. Daemons are background processes managed by systemd
2. Service files declare how to start/stop daemons
3. Dependencies ensure correct startup order
4. Systemd provides monitoring, logging, and resource management
5. Socket activation and timers extend functionality
6. Comprehensive logging via journalctl aids troubleshooting

---

*System Services and Daemons: Conceptual Foundations*  
*Understanding systemd and service management for reliable systems*
