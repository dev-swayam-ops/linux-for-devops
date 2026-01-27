# Package Management: Exercises

Complete these exercises to master package management.

## Exercise 1: Update Package Lists

**Tasks:**
1. Update local package list
2. Check for available upgrades
3. Show upgradable packages
4. Understand apt cache
5. Verify repository connectivity

**Hint:** Use `sudo apt update`, `apt list --upgradable`.

---

## Exercise 2: Search for Packages

**Tasks:**
1. Search for package by name
2. Show package information
3. Check available versions
4. View package description
5. Find related packages

**Hint:** Use `apt search`, `apt show`, `apt policy`.

---

## Exercise 3: Install Packages

**Tasks:**
1. Install single package
2. Install multiple packages
3. Verify installation
4. Check installed version
5. Show installed files

**Hint:** Use `sudo apt install`, `dpkg -l`, `dpkg -L`.

---

## Exercise 4: Understand Dependencies

**Tasks:**
1. Show package dependencies
2. Check reverse dependencies
3. Install package with dependencies
4. Understand dependency chain
5. Handle dependency conflicts

**Hint:** Use `apt depends`, `apt rdepends`, `apt policy`.

---

## Exercise 5: Upgrade Packages

**Tasks:**
1. Upgrade all packages
2. Upgrade specific package
3. Check before upgrading
4. Understand upgrade types
5. Verify after upgrade

**Hint:** Use `apt upgrade`, `apt full-upgrade`, `--simulate`.

---

## Exercise 6: Remove Packages

**Tasks:**
1. Remove package (keep config)
2. Remove package (delete config)
3. Check package still installed
4. Remove unused dependencies
5. Clean package cache

**Hint:** Use `apt remove`, `apt purge`, `apt autoremove`, `apt clean`.

---

## Exercise 7: List and Query Packages

**Tasks:**
1. List all installed packages
2. Find installed package details
3. Count total packages
4. Show package file locations
5. Check package size

**Hint:** Use `apt list --installed`, `dpkg -l`, `dpkg -S`, `dpkg -L`.

---

## Exercise 8: Handle Package Issues

**Tasks:**
1. Fix broken dependencies
2. Handle locked package manager
3. Manage version conflicts
4. Hold package version
5. Unhold package

**Hint:** Use `apt --fix-broken install`, `apt-mark hold`, `apt policy`.

---

## Exercise 9: Add and Manage Repositories

**Tasks:**
1. View current repositories
2. Add new repository (PPA)
3. Remove repository
4. Update after adding repo
5. Search in specific repo

**Hint:** Use `add-apt-repository`, `cat /etc/apt/sources.list`.

---

## Exercise 10: Create Package Management Plan

Create automated package management workflow.

**Tasks:**
1. Document package list
2. Create install script
3. Set up auto-upgrades
4. Plan dependency management
5. Test deployment

**Hint:** Save package list, use `apt install`, `unattended-upgrades`.
