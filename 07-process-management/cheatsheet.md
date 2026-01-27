# Process Management: Cheatsheet

## Process Listing and Discovery

| Command | Purpose | Example |
|---------|---------|---------|
| `ps aux` | List all processes | `ps aux` |
| `ps -ef` | Full format listing | `ps -ef` |
| `ps -o column1,column2` | Custom columns | `ps -o pid,user,cmd` |
| `ps --sort=column` | Sort output | `ps aux --sort=-%cpu` |
| `pgrep pattern` | Find by name | `pgrep python` |
| `pgrep -a pattern` | Show full command | `pgrep -a python` |
| `pidof processname` | Get PID | `pidof sshd` |

## Process Information

| Command | Purpose | Example |
|---------|---------|---------|
| `ps -o pid,ppid,cmd` | Parent-child info | `ps -o pid,ppid,cmd -p 1234` |
| `pstree -p` | Process tree | `pstree -p` |
| `pstree -p PID` | Subtree for PID | `pstree -p 889` |
| `ps -p PID` | Specific process | `ps aux -p 1234` |

## Process Control and Signals

| Command | Purpose | Example |
|---------|---------|---------|
| `kill PID` | Send SIGTERM | `kill 1234` |
| `kill -9 PID` | Send SIGKILL (force) | `kill -9 1234` |
| `kill -15 PID` | Send SIGTERM | `kill -15 1234` |
| `killall name` | Kill by name | `killall sleep` |
| `killall -9 name` | Force kill by name | `killall -9 nginx` |
| `fg %job` | Foreground job | `fg %1` |
| `bg %job` | Background job | `bg %1` |
| `jobs` | List jobs | `jobs` |
| `wait PID` | Wait for process | `wait 1234` |

## Process Priority

| Command | Purpose | Example |
|---------|---------|---------|
| `nice -n value command` | Start with priority | `nice -n 10 ./script.sh` |
| `renice -n value -p PID` | Change priority | `renice -n 5 -p 1234` |
| `ps -o pid,nice,cmd` | Show nice values | `ps aux -o pid,nice,cmd` |

## Process Monitoring

| Command | Purpose | Example |
|---------|---------|---------|
| `top` | Interactive monitor | `top` |
| `top -b -n 1` | Batch mode | `top -b -n 1` |
| `top -p PID` | Monitor specific | `top -p 1234` |
| `watch command` | Repeat command | `watch -n 1 'ps aux'` |
| `ps aux --sort=-%cpu` | Sort by CPU | `ps aux --sort=-%cpu` |
| `ps aux --sort=-%mem` | Sort by memory | `ps aux --sort=-%mem` |

## System Load

| Command | Purpose | Example |
|---------|---------|---------|
| `uptime` | Load average | `uptime` |
| `cat /proc/loadavg` | Detailed load | `cat /proc/loadavg` |
| `w` | Users and load | `w` |

## Process Limits

| Command | Purpose | Example |
|---------|---------|---------|
| `ulimit -a` | Show all limits | `ulimit -a` |
| `ulimit -n` | Max files | `ulimit -n` |
| `ulimit -u` | Max processes | `ulimit -u` |
| `ulimit -v` | Max memory | `ulimit -v` |
| `ulimit -n 2048` | Set limit | `ulimit -n 2048` |

## File Descriptors

| Command | Purpose | Example |
|---------|---------|---------|
| `lsof -p PID` | Open files for PID | `lsof -p 1234` |
| `lsof -i` | Network files | `lsof -i :8080` |
| `lsof -u user` | User's files | `lsof -u username` |
| `fuser file` | Find process using file | `fuser /var/log/syslog` |

## Process Signals

| Signal | Number | Meaning |
|--------|--------|---------|
| SIGHUP | 1 | Hangup (reload) |
| SIGINT | 2 | Interrupt (Ctrl+C) |
| SIGQUIT | 3 | Quit |
| SIGKILL | 9 | Kill (can't be caught) |
| SIGTERM | 15 | Terminate (default) |
| SIGSTOP | 19 | Stop (can't be caught) |
| SIGCONT | 18 | Continue |

## Process States

| State | Meaning |
|-------|---------|
| R | Running |
| S | Sleeping (interruptible) |
| D | Disk sleep (uninterruptible) |
| Z | Zombie |
| T | Stopped |
| W | Paging |

## Background and Foreground

| Command | Action |
|---------|--------|
| `command &` | Run in background |
| `Ctrl+Z` | Suspend (SIGSTOP) |
| `bg` | Resume in background |
| `fg` | Resume in foreground |
| `jobs` | List background jobs |
| `disown %job` | Remove from job list |

## Nice Value Reference

| Nice | Priority |
|------|----------|
| -20 | Highest |
| -10 | High |
| 0 | Normal |
| 10 | Low |
| 19 | Lowest |

## Process Tree Example

```
systemd(1)
├─systemd-journal(123)
├─sshd(456)
│ └─sshd(789)
│   └─bash(1000)
│     └─ps(1234)
└─nginx(567)
  ├─nginx(568)
  └─nginx(569)
```

## Common ps Options

| Option | Meaning |
|--------|---------|
| `-a` | All processes (except leaders) |
| `-u` | By user format |
| `-x` | Include background processes |
| `-e` | All processes |
| `-f` | Full format |
| `-l` | Long format |
| `-o` | Custom columns |
| `--sort` | Sort by column |
