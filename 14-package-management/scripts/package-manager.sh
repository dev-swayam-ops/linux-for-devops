#!/bin/bash

################################################################################
# Package Manager Universal Wrapper
# 
# Purpose: Provide unified interface across apt, yum, and dnf
# Simplifies common operations with smart detection and cross-distro support
#
# Usage: ./package-manager.sh <command> <package> [options]
# Commands: search, info, install, remove, update, upgrade, list, check
#
# Author: Linux DevOps Learning Module 14
# License: MIT
################################################################################

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script variables
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="1.0.0"

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
        PKG_SYSTEM="debian"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_SYSTEM="rhel"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_SYSTEM="rhel"
    else
        echo -e "${RED}Error: No supported package manager found${NC}" >&2
        echo "Supported systems: Ubuntu/Debian (apt), RHEL/CentOS (yum/dnf)" >&2
        exit 1
    fi
}

# Print colored status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success") echo -e "${GREEN}✓${NC} $message" ;;
        "error")   echo -e "${RED}✗${NC} $message" ;;
        "info")    echo -e "${BLUE}ℹ${NC} $message" ;;
        "warn")    echo -e "${YELLOW}⚠${NC} $message" ;;
    esac
}

# Print usage information
print_usage() {
    cat << EOF
${BLUE}Package Manager Universal Wrapper v${SCRIPT_VERSION}${NC}

${GREEN}Usage:${NC}
  $SCRIPT_NAME <command> <package> [options]

${GREEN}Commands:${NC}
  search <name>           Search for packages matching name
  info <package>          Show detailed package information
  install <package>       Install a package (requires sudo)
  remove <package>        Remove an installed package (requires sudo)
  purge <package>         Completely remove package and config (requires sudo)
  update                  Update package list (requires sudo)
  upgrade                 Upgrade all packages (requires sudo)
  dist-upgrade            Full system upgrade (requires sudo)
  list                    List all installed packages
  list-upgradable         List packages with updates available
  autoremove              Remove unused dependencies (requires sudo)
  clean                   Clean package cache (requires sudo)
  check                   Check for broken packages
  versions <package>      Show all available versions
  depends <package>       Show package dependencies
  rdepends <package>      Show reverse dependencies
  status <package>        Show installation status
  help                    Show this help message
  version                 Show script version

${GREEN}Examples:${NC}
  # Search for curl
  $SCRIPT_NAME search curl

  # Get info about nginx
  $SCRIPT_NAME info nginx

  # Install Apache (requires sudo)
  $SCRIPT_NAME install apache2

  # Show dependencies for curl
  $SCRIPT_NAME depends curl

  # List available upgrades
  $SCRIPT_NAME list-upgradable

  # Remove package
  $SCRIPT_NAME remove curl

  # Update package cache
  sudo $SCRIPT_NAME update

  # Full upgrade
  sudo $SCRIPT_NAME upgrade

${GREEN}System Information:${NC}
  Detected package manager: $PKG_MANAGER
  System type: $PKG_SYSTEM
  Hostname: $(hostname)

${BLUE}Note:${NC} Most write operations require sudo. Try "sudo $SCRIPT_NAME <command>"
EOF
}

# Search for packages
cmd_search() {
    local search_term=$1
    print_status "info" "Searching for packages matching '$search_term'..."
    
    case $PKG_MANAGER in
        "apt")
            apt search "$search_term" 2>/dev/null | head -20
            ;;
        "yum"|"dnf")
            $PKG_MANAGER search "$search_term" | head -20
            ;;
    esac
}

# Show package information
cmd_info() {
    local package=$1
    print_status "info" "Showing information for package '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            apt show "$package"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER info "$package"
            ;;
    esac
}

# Install package
cmd_install() {
    local package=$1
    
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Install requires sudo. Run: sudo $SCRIPT_NAME install $package"
        exit 1
    fi
    
    print_status "info" "Installing package '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            apt install -y "$package"
            print_status "success" "Package '$package' installed successfully"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER install -y "$package"
            print_status "success" "Package '$package' installed successfully"
            ;;
    esac
}

# Remove package
cmd_remove() {
    local package=$1
    
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Remove requires sudo. Run: sudo $SCRIPT_NAME remove $package"
        exit 1
    fi
    
    print_status "warn" "Removing package '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            apt remove -y "$package"
            print_status "success" "Package '$package' removed"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER remove -y "$package"
            print_status "success" "Package '$package' removed"
            ;;
    esac
}

# Purge package
cmd_purge() {
    local package=$1
    
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Purge requires sudo. Run: sudo $SCRIPT_NAME purge $package"
        exit 1
    fi
    
    print_status "warn" "Purging package '$package' (including config)..."
    
    case $PKG_MANAGER in
        "apt")
            apt purge -y "$package"
            print_status "success" "Package '$package' purged"
            ;;
        "yum"|"dnf")
            # yum/dnf don't have purge, just remove
            $PKG_MANAGER remove -y "$package"
            print_status "success" "Package '$package' removed"
            ;;
    esac
}

# Update package list
cmd_update() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Update requires sudo. Run: sudo $SCRIPT_NAME update"
        exit 1
    fi
    
    print_status "info" "Updating package list..."
    
    case $PKG_MANAGER in
        "apt")
            apt update
            print_status "success" "Package list updated"
            ;;
        "yum"|"dnf")
            # yum/dnf auto-update cache, just check
            print_status "success" "Package cache will update automatically"
            ;;
    esac
}

# Upgrade packages
cmd_upgrade() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Upgrade requires sudo. Run: sudo $SCRIPT_NAME upgrade"
        exit 1
    fi
    
    print_status "info" "Upgrading packages..."
    
    case $PKG_MANAGER in
        "apt")
            apt update && apt upgrade -y
            print_status "success" "Packages upgraded"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER update -y
            print_status "success" "Packages upgraded"
            ;;
    esac
}

# Full system upgrade
cmd_dist_upgrade() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Dist-upgrade requires sudo. Run: sudo $SCRIPT_NAME dist-upgrade"
        exit 1
    fi
    
    print_status "warn" "Performing full system upgrade (aggressive, may remove packages)..."
    
    case $PKG_MANAGER in
        "apt")
            apt update && apt dist-upgrade -y
            print_status "success" "Full system upgrade completed"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER upgrade -y
            print_status "success" "Full system upgrade completed"
            ;;
    esac
}

# List installed packages
cmd_list() {
    print_status "info" "Listing installed packages..."
    
    case $PKG_MANAGER in
        "apt")
            apt list --installed | wc -l
            print_status "success" "Use 'apt list --installed' to see all"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER list installed | wc -l
            print_status "success" "Use '$PKG_MANAGER list installed' to see all"
            ;;
    esac
}

# List upgradable packages
cmd_list_upgradable() {
    print_status "info" "Listing upgradable packages..."
    
    case $PKG_MANAGER in
        "apt")
            apt list --upgradable
            ;;
        "yum"|"dnf")
            $PKG_MANAGER check-update
            ;;
    esac
}

# Autoremove unused packages
cmd_autoremove() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Autoremove requires sudo. Run: sudo $SCRIPT_NAME autoremove"
        exit 1
    fi
    
    print_status "info" "Removing unused dependencies..."
    
    case $PKG_MANAGER in
        "apt")
            apt autoremove -y
            print_status "success" "Cleanup completed"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER autoremove -y
            print_status "success" "Cleanup completed"
            ;;
    esac
}

# Clean cache
cmd_clean() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "Clean requires sudo. Run: sudo $SCRIPT_NAME clean"
        exit 1
    fi
    
    print_status "info" "Cleaning package cache..."
    
    case $PKG_MANAGER in
        "apt")
            apt clean
            apt autoclean
            print_status "success" "Cache cleaned"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER clean all
            print_status "success" "Cache cleaned"
            ;;
    esac
}

# Check system health
cmd_check() {
    print_status "info" "Checking package system health..."
    
    case $PKG_MANAGER in
        "apt")
            apt check
            print_status "success" "System check complete"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER check
            print_status "success" "System check complete"
            ;;
    esac
}

# Show all versions
cmd_versions() {
    local package=$1
    print_status "info" "Showing available versions for '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            apt-cache policy "$package"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER info "$package" | grep Version
            ;;
    esac
}

# Show dependencies
cmd_depends() {
    local package=$1
    print_status "info" "Showing dependencies for '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            apt-cache depends "$package"
            ;;
        "yum"|"dnf")
            $PKG_MANAGER deplist "$package"
            ;;
    esac
}

# Show reverse dependencies
cmd_rdepends() {
    local package=$1
    print_status "info" "Showing reverse dependencies for '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            apt-cache rdepends "$package" | head -20
            ;;
        "yum"|"dnf")
            print_status "warn" "Reverse dependencies not directly available on $PKG_MANAGER"
            print_status "info" "Try: repoquery --whatrequires $package"
            ;;
    esac
}

# Show package status
cmd_status() {
    local package=$1
    print_status "info" "Showing status for '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            if dpkg -s "$package" &>/dev/null; then
                dpkg -s "$package" | grep Status
                print_status "success" "Package is installed"
            else
                print_status "warn" "Package is not installed"
            fi
            ;;
        "yum"|"dnf")
            if rpm -q "$package" &>/dev/null; then
                rpm -q "$package"
                print_status "success" "Package is installed"
            else
                print_status "warn" "Package is not installed"
            fi
            ;;
    esac
}

# Main entry point
main() {
    local command=${1:-}
    
    # Detect package manager first
    detect_package_manager
    
    # Handle empty command
    if [[ -z "$command" ]]; then
        print_usage
        exit 0
    fi
    
    # Route command
    case "$command" in
        search)
            [[ -z "${2:-}" ]] && { print_status "error" "search requires package name"; exit 1; }
            cmd_search "$2"
            ;;
        info)
            [[ -z "${2:-}" ]] && { print_status "error" "info requires package name"; exit 1; }
            cmd_info "$2"
            ;;
        install)
            [[ -z "${2:-}" ]] && { print_status "error" "install requires package name"; exit 1; }
            cmd_install "$2"
            ;;
        remove)
            [[ -z "${2:-}" ]] && { print_status "error" "remove requires package name"; exit 1; }
            cmd_remove "$2"
            ;;
        purge)
            [[ -z "${2:-}" ]] && { print_status "error" "purge requires package name"; exit 1; }
            cmd_purge "$2"
            ;;
        update)
            cmd_update
            ;;
        upgrade)
            cmd_upgrade
            ;;
        dist-upgrade)
            cmd_dist_upgrade
            ;;
        list)
            cmd_list
            ;;
        list-upgradable)
            cmd_list_upgradable
            ;;
        autoremove)
            cmd_autoremove
            ;;
        clean)
            cmd_clean
            ;;
        check)
            cmd_check
            ;;
        versions)
            [[ -z "${2:-}" ]] && { print_status "error" "versions requires package name"; exit 1; }
            cmd_versions "$2"
            ;;
        depends)
            [[ -z "${2:-}" ]] && { print_status "error" "depends requires package name"; exit 1; }
            cmd_depends "$2"
            ;;
        rdepends)
            [[ -z "${2:-}" ]] && { print_status "error" "rdepends requires package name"; exit 1; }
            cmd_rdepends "$2"
            ;;
        status)
            [[ -z "${2:-}" ]] && { print_status "error" "status requires package name"; exit 1; }
            cmd_status "$2"
            ;;
        help|-h|--help)
            print_usage
            ;;
        version|-v|--version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            echo "Detected: $PKG_MANAGER ($PKG_SYSTEM)"
            ;;
        *)
            print_status "error" "Unknown command: $command"
            echo "Use '$SCRIPT_NAME help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
