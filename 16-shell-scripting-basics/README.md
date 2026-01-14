# Shell Scripting Basics

Master bash scripting for Linux automation and system administration.

---

## Overview

Shell scripting is the foundation of Linux automation. From simple one-liners to complex deployment scripts, bash skills are essential for every Linux user and system administrator.

### Why Shell Scripting Matters

**In Real-World Scenarios:**
- **System Administration:** Automate user creation, log rotation, backups
- **DevOps & Deployment:** Infrastructure automation, CI/CD pipelines, application deployment
- **System Monitoring:** Collect metrics, generate alerts, send notifications
- **Data Processing:** Parse logs, transform files, automate workflows
- **Cronjobs:** Scheduled tasks, maintenance, health checks
- **Productivity:** Eliminate repetitive manual tasks, improve efficiency

**Career Value:**
- Required skill for SysAdmin and DevOps roles
- Foundation for advanced automation frameworks
- Enables writing custom tools for your environment
- Demonstrates technical depth in interviews

---

## Prerequisites

Before starting this module, you should be comfortable with:
- **Module 01 - Linux Basics:** Commands, directory structure, file permissions
- **Module 02 - Advanced Commands:** Pipes, redirection, grep, sed, awk
- **Basic Terminal Usage:** File editing, command execution, navigation

**Required:**
- Text editor (nano, vim, or VS Code with Remote SSH)
- Ubuntu/Debian or CentOS system
- Terminal access with user permissions (sudo may be needed)
- 1-2 hours of practice time

---

## Learning Objectives

After completing this module, you will be able to:

1. **Understand Shell Fundamentals**
   - Explain what a shell is and different shell types
   - Write and execute basic bash scripts
   - Understand script structure and best practices

2. **Master Variables and Data Types**
   - Declare and use variables correctly
   - Understand variable scope and special variables
   - Work with arrays and associative arrays

3. **Control Program Flow**
   - Use if/elif/else conditionals
   - Implement case statements
   - Apply logical operators correctly

4. **Implement Loops and Iteration**
   - Write for, while, and until loops
   - Use loop control (break, continue)
   - Iterate over arrays and file contents

5. **Write Modular Code with Functions**
   - Define and call functions
   - Pass parameters and return values
   - Understand function scope and local variables

6. **Handle Input and Output**
   - Read user input interactively
   - Redirect and pipe data
   - Format output with echo and printf

7. **Implement Error Handling**
   - Check and respond to exit codes
   - Use trap for cleanup
   - Implement proper error messages

8. **Apply Real-World Patterns**
   - Parse log files and system data
   - Validate user input
   - Write maintainable production scripts

9. **Debug and Test Scripts**
   - Use bash debugging techniques
   - Test edge cases
   - Apply security best practices

10. **Automate System Tasks**
    - Write backup scripts
    - Create deployment helpers
    - Build monitoring tools

---

## Module Roadmap

| # | File | Topic | Time |
|---|------|-------|------|
| 1 | [README.md](README.md) | Overview & glossary | 5 min |
| 2 | [01-theory.md](01-theory.md) | Shell fundamentals, variables, control flow | 90 min |
| 3 | [02-commands-cheatsheet.md](02-commands-cheatsheet.md) | Quick command reference | 30 min |
| 4 | [03-hands-on-labs.md](03-hands-on-labs.md) | 10 complete hands-on labs | 330 min |
| 5 | [scripts/](scripts/) | 3+ production scripts | 45 min |

**Total Time Investment:** ~500 minutes (~8.3 hours)

**Recommended Path:**
1. Read README (this file) - understand context
2. Study 01-theory.md - build conceptual foundation
3. Reference 02-commands-cheatsheet.md - look up syntax
4. Complete labs 1-3 - basic scripts
5. Complete labs 4-6 - intermediate skills
6. Complete labs 7-10 - advanced patterns and real-world applications
7. Study and adapt scripts/ examples
8. Create your own utility script

---

## Quick Glossary

**Shell Concepts:**
- **Shell:** Command interpreter that executes commands (bash, sh, zsh, fish)
- **Bash:** GNU Bourne Again Shell, most common on Linux
- **Shebang:** `#!/bin/bash` - tells system which interpreter to use
- **Script:** Text file with executable shell commands
- **Execution:** Running a script directly or with `bash script.sh`

**Variables and Data:**
- **Variable:** Named container for storing values
- **Parameter:** Variable passed to a script or function
- **Expansion:** Replacing $variable with its value
- **Quoting:** Single (literal), double (expansion), backticks (command execution)
- **Array:** Ordered list of values: `array=(val1 val2 val3)`

**Control Flow:**
- **Conditional:** if/elif/else - execute code based on condition
- **Case Statement:** Switch-like structure for multiple options
- **Loop:** Repeat code block (for, while, until)
- **Break/Continue:** Exit or skip loop iteration

**Functions:**
- **Function:** Reusable block of code with parameters
- **Parameter:** Positional argument ($1, $2, etc.)
- **Return Value:** Exit code (0=success, non-zero=error)
- **Local Variable:** Scope limited to function

**Input/Output:**
- **STDIN (0):** Standard input (keyboard)
- **STDOUT (1):** Standard output (terminal)
- **STDERR (2):** Standard error output (error messages)
- **Redirection:** Send output to file (>, >>, <)
- **Pipe:** Connect command output to another command (|)

**Error Handling:**
- **Exit Code:** Integer 0-255 indicating command success/failure
- **Trap:** Execute code on signal or condition
- **Set -e:** Exit on first error
- **Set -u:** Exit on undefined variable

**Best Practices:**
- **Comments:** # Explain what code does
- **Naming:** Use descriptive variable and function names
- **Quoting:** Quote variables to handle spaces: "$var"
- **Testing:** Test with different inputs and edge cases
- **Documentation:** Comment complex sections

---

## Time Breakdown

| Activity | Time | Notes |
|----------|------|-------|
| Theory Review | 90 min | Foundational concepts, read carefully |
| Commands Cheatsheet | 30 min | Quick reference while doing labs |
| Hands-On Labs | 330 min | 10 labs, 30-60 min each |
| Scripts Study | 45 min | Read and understand provided scripts |
| **Total** | **~8 hours** | Spread over multiple sessions |

---

## Lab Environment Setup

### Recommended Environment
- **OS:** Ubuntu 20.04+ or CentOS 8+
- **Approach:** Local VM or cloud instance
- **Storage:** 5GB+ free space
- **User:** Regular user with sudo access

### Create Lab Directory
```bash
# Create workspace
mkdir -p ~/shell-labs
cd ~/shell-labs

# Create subdirectories for different labs
mkdir -p basic variables control loops functions
```

### Test Your Setup
```bash
# Check bash version
bash --version

# Create simple test script
cat > test.sh << 'EOF'
#!/bin/bash
echo "Shell scripting setup is ready!"
EOF

chmod +x test.sh
./test.sh
```

**Expected Output:**
```
Shell scripting setup is ready!
```

---

## Lab Safety and Best Practices

### Before Running Any Script

1. **Read the script completely** - Understand what it does
2. **Test in non-production** - Use test VMs, not live systems
3. **Review permissions** - Be careful with sudo/root scripts
4. **Backup important data** - Before running system scripts
5. **Test with dry-run** - Many scripts have --dry-run options

### Safe Scripting Habits

```bash
# Always start scripts with:
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Test syntax before running
bash -n script.sh  # -n = syntax check only

# Run with bash prefix first (safe, no execute needed)
bash script.sh

# Only use ./script.sh after verifying
chmod +x script.sh
./script.sh
```

### Common Mistakes to Avoid

- ❌ Running unverified scripts with sudo
- ❌ Using rm -rf without careful path validation
- ❌ Assuming user input is safe (always validate)
- ❌ Not quoting variables (breaks with spaces)
- ❌ Using outdated syntax ([[ ]] better than [ ])
- ✓ Always quote variables: "$var"
- ✓ Validate input before use
- ✓ Use functions for repeated code
- ✓ Add error handling and logging
- ✓ Test thoroughly before production

---

## Recommended Tools and References

### Essential Tools
- **nano** or **vim:** Text editors
- **VS Code:** IDE with Remote SSH support
- **shellcheck:** Validate shell scripts
- **shfmt:** Format bash scripts
- **tmux or screen:** Terminal multiplexer

### Installation
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y shellcheck shfmt vim nano tmux

# CentOS/RHEL
sudo yum install -y epel-release
sudo yum install -y ShellCheck
```

### Online Resources
- **bash Manual:** https://www.gnu.org/software/bash/manual/
- **ShellCheck:** https://www.shellcheck.net/
- **Google Shell Style Guide:** Highly recommended
- **Defensive BASH Programming:** https://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/

---

## Success Criteria

You'll know you've mastered shell scripting basics when you can:

- [ ] Write a 50+ line script with functions and error handling
- [ ] Use variables, arrays, and loops confidently
- [ ] Handle user input with validation
- [ ] Understand and use exit codes correctly
- [ ] Debug scripts using bash -x and echo statements
- [ ] Apply best practices (quoting, error handling, documentation)
- [ ] Read and understand other developers' scripts
- [ ] Adapt existing scripts for your needs
- [ ] Test scripts with edge cases
- [ ] Explain your script logic to others

---

## Quick Start Path (3 Hours Minimum)

If you're short on time, follow this minimal path:

1. **Theory (30 min):** Read sections 1-6 of 01-theory.md
2. **Labs (150 min):**
   - Lab 1: Basic script structure (30 min)
   - Lab 2: Variables (30 min)
   - Lab 3: Control flow (30 min)
   - Lab 4: Loops (30 min)
3. **Practice (30 min):** Write a simple backup script

This gives you core scripting knowledge applicable to most common tasks.

---

## Module Files

- **[01-theory.md](01-theory.md)** - Conceptual foundation and examples
- **[02-commands-cheatsheet.md](02-commands-cheatsheet.md)** - Quick command reference
- **[03-hands-on-labs.md](03-hands-on-labs.md)** - Practical exercises
- **[scripts/](scripts/)** - Production-ready script examples

---

## Navigation

**← Previous Module:** [Module 15 - Storage and Filesystems](../15-storage-and-filesystems/README.md)

**Next Module:** [Module 17 - Troubleshooting and Scenarios](../17-troubleshooting-and-scenarios/README.md)

---

## How to Use This Module

1. **Linear Learning:** Follow order (README → theory → commands → labs → scripts)
2. **Reference Mode:** Skip to specific topics as needed
3. **Practical Focus:** Labs first, then theory for deep understanding
4. **Adaptation:** Modify examples for your environment

**Tips:**
- Keep 02-commands-cheatsheet.md open while doing labs
- Copy scripts as templates for your own tools
- Don't memorize - understand the patterns
- Practice regularly - scripting improves with repetition

---

## Need Help?

### Debugging Your Scripts
```bash
# View what the script does (dry-run)
bash -x script.sh

# Check syntax errors
bash -n script.sh

# Add debug output
bash -x script.sh 2>&1 | less
```

### Common Error Solutions
- **"Permission denied"** → `chmod +x script.sh`
- **"command not found"** → Check PATH or use absolute path
- **Variable empty** → Check quoting: "$var" not $var
- **Unexpected characters** → Check line endings: `dos2unix file`

---

## Congratulations!

You're about to master one of the most valuable skills in Linux. Let's begin! 🚀

**Start with [01-theory.md](01-theory.md) →**
