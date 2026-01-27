# Module 14: Package Management

## What You'll Learn

- Understand package managers (apt, yum, dnf)
- Install, update, and remove packages
- Manage package dependencies
- Search for packages
- Handle broken dependencies
- Understand package repositories
- Create package lists for automation

## Prerequisites

- Complete Module 1: Linux Basics Commands
- Comfortable with command-line
- Root/sudo access for system packages

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Package** | Compressed software bundle with metadata |
| **Manager** | Tool to install/manage packages (apt, yum) |
| **Dependency** | Required library/package for software |
| **Repository** | Online source for packages |
| **Version** | Software release number |
| **Update** | Get latest package versions |
| **Remove** | Uninstall package |
| **Hold** | Prevent package from updating |

## Hands-on Lab: Install and Manage Packages

### Lab Objective
Install packages, check dependencies, and update system.

### Commands

```bash
# Update package lists (don't upgrade yet)
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Full distribution upgrade
sudo apt full-upgrade

# Search for package
apt search nginx

# Show package info
apt show nginx

# Install package
sudo apt install curl

# Install multiple packages
sudo apt install git vim htop

# Remove package (keep config)
sudo apt remove nginx

# Remove package (delete config)
sudo apt purge nginx

# Check package dependencies
apt depends curl

# Reverse dependencies (what needs this)
apt rdepends gcc

# List installed packages
apt list --installed | head -20

# Upgrade single package
sudo apt install --only-upgrade curl

# Check available updates
apt list --upgradable

# Fix broken dependencies
sudo apt --fix-broken install

# AutoRemove unused packages
sudo apt autoremove
```

### Expected Output

```
# apt update output:
Hit:1 http://archive.ubuntu.com focal InRelease
Get:2 http://security.ubuntu.com focal-security InRelease

# apt list --upgradable output:
curl/focal-updates 7.68.0-1ubuntu1.10 amd64 [upgradable from: 7.68.0-1ubuntu1.9]
```

## Validation

Confirm successful completion:

- [ ] Updated package lists
- [ ] Installed a new package
- [ ] Checked package dependencies
- [ ] Upgraded packages
- [ ] Removed a package
- [ ] Verified installation

## Cleanup

```bash
# Remove unused packages
sudo apt autoremove

# Clean package cache
sudo apt clean
# or keep small cache
sudo apt autoclean
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Forget sudo for install | Use `sudo apt install` |
| Broken dependencies | Use `sudo apt --fix-broken install` |
| Package not found | Run `apt update` first |
| Can't remove package | Check dependencies with `apt depends` |
| Dependency conflicts | Use `apt policy` to check versions |

## Troubleshooting

**Q: Package says "not found" after apt update?**
A: The package doesn't exist. Search: `apt search partial-name`.

**Q: How do I see what a package contains?**
A: Use `apt show package` or `dpkg -L installed-package`.

**Q: How do I downgrade a package?**
A: Use `sudo apt install package=version`. Get version with `apt policy`.

**Q: Package manager locked (E: could not get lock)?**
A: Another process using it. Wait or kill: `sudo lsof /var/lib/apt/lists/lock`.

**Q: How do I add a repository?**
A: Use `sudo add-apt-repository ppa:repo/name` then `sudo apt update`.

## Next Steps

1. Complete all exercises in `exercises.md`
2. Master apt for Debian/Ubuntu systems
3. Learn yum/dnf for RedHat systems
4. Set up unattended upgrades
5. Create package deployment scripts
