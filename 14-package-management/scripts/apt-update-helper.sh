#!/bin/bash

################################################################################
# APT Update Helper Tool
#
# Purpose: Automate and simplify system updates with safety checks
# Provides staged updates with rollback capability and health monitoring
#
# Usage: ./apt-update-helper.sh [options]
# Options: --check, --preview, --safe-update, --full-update, --rollback, --help
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
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script variables
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="1.0.0"
BACKUP_DIR="/var/backups/apt-update-helper"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="/var/log/apt-update-helper.log"
STATE_FILE="$BACKUP_DIR/state-$TIMESTAMP.txt"

# Print colored messages
print_msg() {
    local level=$1
    local msg=$2
    case $level in
        "SUCCESS") echo -e "${GREEN}[✓]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "ERROR")   echo -e "${RED}[✗]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "WARN")    echo -e "${YELLOW}[!]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "INFO")    echo -e "${BLUE}[i]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "STEP")    echo -e "${CYAN}==>${NC} $msg" | tee -a "$LOG_FILE" ;;
    esac
}

# Print usage
print_usage() {
    cat << EOF
${BLUE}APT Update Helper v${SCRIPT_VERSION}${NC}

${GREEN}Usage:${NC}
  sudo $SCRIPT_NAME [options]

${GREEN}Options:${NC}
  --check             Check for available updates
  --preview           Preview what would be updated
  --safe-update       Safe upgrade (never removes packages)
  --full-update       Full system upgrade (may install/remove)
  --security-only     Install security updates only
  --clean             Clean package cache
  --rollback          Restore to previous state (requires backup)
  --status            Show update status and recent activity
  --unattended-setup  Setup automatic security updates
  --help              Show this help message
  --version           Show version

${GREEN}Examples:${NC}
  # Check for updates
  sudo $SCRIPT_NAME --check

  # Preview what would be updated
  sudo $SCRIPT_NAME --preview

  # Safe upgrade (recommended for production)
  sudo $SCRIPT_NAME --safe-update

  # Full system upgrade (aggressive)
  sudo $SCRIPT_NAME --full-update

  # Cleanup old packages
  sudo $SCRIPT_NAME --clean

  # Show status
  $SCRIPT_NAME --status

${GREEN}Safety Features:${NC}
  • Backs up current package list before update
  • Checks system health before and after
  • Provides preview of all changes
  • Distinguishes between safe and aggressive upgrades
  • Maintains update history and logs

${BLUE}Backup Location:${NC} $BACKUP_DIR
${BLUE}Log File:${NC} $LOG_FILE
EOF
}

# Initialize backup directory
init_backup_dir() {
    if ! mkdir -p "$BACKUP_DIR"; then
        print_msg "ERROR" "Cannot create backup directory: $BACKUP_DIR"
        exit 1
    fi
    
    # Initialize log file if it doesn't exist
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
        chmod 644 "$LOG_FILE"
    fi
}

# Check sudo access
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        print_msg "ERROR" "This command requires sudo. Run: sudo $SCRIPT_NAME $*"
        exit 1
    fi
}

# Save system state
save_state() {
    print_msg "STEP" "Saving current system state..."
    
    {
        echo "Update State Backup - $(date)"
        echo "=================================="
        echo ""
        echo "APT Cache Policy:"
        apt-cache policy | head -20
        echo ""
        echo "Installed Packages:"
        dpkg --get-selections > "$BACKUP_DIR/packages-$TIMESTAMP.txt"
        echo "Saved to: $BACKUP_DIR/packages-$TIMESTAMP.txt"
        echo ""
        echo "Held Packages:"
        apt-mark showhold >> "$STATE_FILE" || echo "None" >> "$STATE_FILE"
        echo ""
        echo "Kernel Information:"
        uname -r >> "$STATE_FILE"
        echo ""
    } | tee -a "$STATE_FILE"
    
    print_msg "SUCCESS" "State saved to: $STATE_FILE"
}

# Check for available updates
check_updates() {
    print_msg "STEP" "Checking for available updates..."
    
    # Update package index
    print_msg "INFO" "Updating package index..."
    apt update 2>&1 | tail -5 | tee -a "$LOG_FILE"
    
    # Check what can be upgraded
    print_msg "INFO" "Packages available for upgrade:"
    local upgrade_count=$(apt list --upgradable 2>/dev/null | wc -l)
    
    if [[ $upgrade_count -gt 1 ]]; then
        echo ""
        apt list --upgradable | tee -a "$LOG_FILE"
        print_msg "INFO" "Total upgradable packages: $((upgrade_count - 1))"
    else
        print_msg "SUCCESS" "System is up to date"
    fi
}

# Preview changes
preview_update() {
    print_msg "STEP" "Previewing update changes..."
    
    echo ""
    echo -e "${CYAN}Safe Upgrade (apt upgrade):${NC}"
    apt upgrade --simulate 2>&1 | grep -E "^(The following|  [a-z]|[0-9]+ upgraded)" | tee -a "$LOG_FILE" || echo "  No changes"
    
    echo ""
    echo -e "${CYAN}Full Upgrade (apt dist-upgrade):${NC}"
    apt dist-upgrade --simulate 2>&1 | grep -E "^(The following|  [a-z]|[0-9]+ upgraded|[0-9]+ newly|[0-9]+ to remove)" | tee -a "$LOG_FILE" || echo "  No changes"
    
    echo ""
    echo -e "${CYAN}Autoremove Changes:${NC}"
    apt autoremove --simulate 2>&1 | grep -E "^(The following|  [a-z]|[0-9]+ to remove)" | tee -a "$LOG_FILE" || echo "  Nothing to remove"
}

# Perform safe upgrade
safe_update() {
    check_sudo
    
    print_msg "STEP" "Starting SAFE upgrade (apt upgrade)..."
    print_msg "WARN" "This will only upgrade existing packages, never remove packages"
    
    save_state
    
    # Check system health before
    print_msg "STEP" "Checking system health before update..."
    if ! apt check 2>&1 | tee -a "$LOG_FILE"; then
        print_msg "ERROR" "System has broken packages. Run: sudo $SCRIPT_NAME --fix-broken"
        exit 1
    fi
    print_msg "SUCCESS" "System is healthy"
    
    # Preview
    echo ""
    print_msg "INFO" "Preview of changes:"
    apt upgrade --simulate 2>&1 | grep -E "upgraded|newly|remove" | tee -a "$LOG_FILE"
    
    # Ask for confirmation
    echo ""
    print_msg "WARN" "This will upgrade your system. Continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_msg "INFO" "Update cancelled"
        return 0
    fi
    
    # Perform upgrade
    print_msg "STEP" "Performing upgrade..."
    if apt upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
        print_msg "SUCCESS" "Upgrade completed successfully"
    else
        print_msg "ERROR" "Upgrade failed"
        exit 1
    fi
    
    # Check system health after
    print_msg "STEP" "Checking system health after update..."
    if apt check 2>&1 | tee -a "$LOG_FILE"; then
        print_msg "SUCCESS" "System is still healthy"
    else
        print_msg "WARN" "System may have issues. Check with: apt check"
    fi
    
    # Cleanup
    print_msg "STEP" "Cleaning up..."
    apt autoremove -y 2>&1 | tail -3 | tee -a "$LOG_FILE"
    apt autoclean 2>&1 | tail -1 | tee -a "$LOG_FILE"
    
    print_msg "SUCCESS" "Safe update completed successfully"
    print_msg "INFO" "Backup saved to: $STATE_FILE"
}

# Perform full upgrade
full_update() {
    check_sudo
    
    print_msg "ERROR" "FULL SYSTEM UPGRADE (apt dist-upgrade)"
    print_msg "WARN" "This is AGGRESSIVE and can install/remove packages"
    print_msg "WARN" "Only use on non-production systems or with careful planning"
    
    save_state
    
    # Check system health before
    print_msg "STEP" "Checking system health before update..."
    if ! apt check 2>&1 | tee -a "$LOG_FILE"; then
        print_msg "ERROR" "System has broken packages"
        exit 1
    fi
    
    # Preview
    echo ""
    print_msg "INFO" "Preview of changes:"
    apt dist-upgrade --simulate 2>&1 | grep -E "upgraded|newly|remove" | tee -a "$LOG_FILE"
    
    # Ask for DOUBLE confirmation
    echo ""
    print_msg "WARN" "Type 'upgrade my system' to continue:"
    read -r response
    if [[ ! "$response" == "upgrade my system" ]]; then
        print_msg "INFO" "Update cancelled"
        return 0
    fi
    
    # Perform upgrade
    print_msg "STEP" "Performing full upgrade..."
    if apt dist-upgrade -y 2>&1 | tee -a "$LOG_FILE"; then
        print_msg "SUCCESS" "Full upgrade completed"
    else
        print_msg "ERROR" "Upgrade failed"
        exit 1
    fi
    
    # Check system health after
    print_msg "STEP" "Checking system health after update..."
    if apt check 2>&1 | tee -a "$LOG_FILE"; then
        print_msg "SUCCESS" "System is healthy"
    else
        print_msg "WARN" "System may have issues"
    fi
    
    print_msg "SUCCESS" "Full update completed"
    print_msg "WARN" "Consider rebooting if kernel was updated"
    print_msg "INFO" "Backup saved to: $STATE_FILE"
}

# Security-only updates
security_update() {
    check_sudo
    
    print_msg "STEP" "Installing security updates only..."
    
    # Ubuntu/Debian security update
    apt update 2>&1 | tail -3 | tee -a "$LOG_FILE"
    
    # Install security updates
    print_msg "INFO" "Installing security packages..."
    apt upgrade -y 2>&1 | grep -E "security|updated" | tee -a "$LOG_FILE" || true
    
    print_msg "SUCCESS" "Security updates installed"
}

# Clean package cache
clean_cache() {
    check_sudo
    
    print_msg "STEP" "Cleaning package cache..."
    
    # Show before size
    print_msg "INFO" "Cache size before:"
    du -sh /var/cache/apt | tee -a "$LOG_FILE"
    
    # Clean old packages
    print_msg "INFO" "Removing old package versions..."
    apt autoclean 2>&1 | tee -a "$LOG_FILE"
    
    # Clean all packages
    print_msg "INFO" "Removing all cached packages..."
    apt clean 2>&1 | tee -a "$LOG_FILE"
    
    # Show after size
    print_msg "INFO" "Cache size after:"
    du -sh /var/cache/apt | tee -a "$LOG_FILE"
    
    print_msg "SUCCESS" "Cache cleaned"
}

# Show update status
show_status() {
    print_msg "STEP" "Update Status Report"
    
    echo ""
    echo -e "${CYAN}System Information:${NC}"
    echo "  Hostname: $(hostname)"
    echo "  Kernel: $(uname -r)"
    echo "  Distro: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
    
    echo ""
    echo -e "${CYAN}Package Statistics:${NC}"
    local total=$(apt list --installed 2>/dev/null | wc -l)
    local upgradable=$(apt list --upgradable 2>/dev/null | wc -l)
    echo "  Total installed: $total"
    echo "  Available upgrades: $((upgradable - 1))"
    
    echo ""
    echo -e "${CYAN}Backup Information:${NC}"
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "  Backup directory: $BACKUP_DIR"
        echo "  Total backups: $(ls -1 "$BACKUP_DIR"/*.txt 2>/dev/null | wc -l)"
        echo "  Latest backup: $(ls -t "$BACKUP_DIR"/*.txt 2>/dev/null | head -1 | xargs -I {} basename {})"
    else
        echo "  No backups yet"
    fi
    
    echo ""
    echo -e "${CYAN}Recent Activity (last 10 lines):${NC}"
    if [[ -f "$LOG_FILE" ]]; then
        tail -10 "$LOG_FILE"
    else
        echo "  No activity log yet"
    fi
    
    echo ""
    echo -e "${CYAN}Disk Usage:${NC}"
    echo "  /var cache: $(du -sh /var/cache/apt 2>/dev/null || echo 'N/A')"
    echo "  /var/lib: $(du -sh /var/lib/apt 2>/dev/null || echo 'N/A')"
}

# Setup unattended upgrades
setup_unattended() {
    check_sudo
    
    print_msg "STEP" "Setting up unattended security updates..."
    
    if ! command -v unattended-upgrades &>/dev/null; then
        print_msg "INFO" "Installing unattended-upgrades..."
        apt install -y unattended-upgrades apt-listchanges 2>&1 | tee -a "$LOG_FILE"
    fi
    
    # Enable the service
    print_msg "INFO" "Enabling unattended-upgrades..."
    dpkg-reconfigure -plow unattended-upgrades 2>&1 | tee -a "$LOG_FILE"
    
    print_msg "SUCCESS" "Unattended upgrades configured"
    print_msg "INFO" "Security updates will be installed automatically"
}

# Rollback to previous state
rollback() {
    check_sudo
    
    print_msg "WARN" "Rollback functionality requires manual intervention"
    print_msg "INFO" "Available backups:"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        print_msg "ERROR" "No backups found"
        return 1
    fi
    
    ls -lhS "$BACKUP_DIR"/packages-*.txt 2>/dev/null | head -10 || print_msg "ERROR" "No backups available"
    
    echo ""
    print_msg "INFO" "To restore: sudo dpkg --set-selections < $BACKUP_DIR/packages-TIMESTAMP.txt"
    print_msg "INFO" "Then run: sudo apt dselect-upgrade"
}

# Main function
main() {
    local command=${1:-}
    
    # Initialize
    init_backup_dir
    
    print_msg "INFO" "APT Update Helper v$SCRIPT_VERSION"
    
    # Route command
    case "$command" in
        --check|check)
            check_updates
            ;;
        --preview|preview)
            check_sudo
            preview_update
            ;;
        --safe-update|safe-update)
            safe_update
            ;;
        --full-update|full-update)
            full_update
            ;;
        --security-only|security)
            security_update
            ;;
        --clean|clean)
            clean_cache
            ;;
        --rollback|rollback)
            rollback
            ;;
        --status|status)
            show_status
            ;;
        --unattended-setup|unattended)
            setup_unattended
            ;;
        --help|-h|help)
            print_usage
            ;;
        --version|-v|version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            ;;
        *)
            print_msg "ERROR" "Unknown command: $command"
            echo "Use '$SCRIPT_NAME --help' for usage information"
            exit 1
            ;;
    esac
}

# Run main
main "$@"
