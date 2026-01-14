#!/bin/bash

################################################################################
# Dependency Resolver Tool
#
# Purpose: Analyze, detect, and fix broken package dependencies
# Identifies missing dependencies, conflicts, and suggests solutions
#
# Usage: ./dependency-resolver.sh [options]
# Options: --check, --fix, --analyze <package>, --report, --help
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
LOG_FILE="/tmp/dependency-resolver-$(date +%Y%m%d-%H%M%S).log"
TEMP_DIR="/tmp/dep-resolver-$$"

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
        exit 1
    fi
}

# Print colored messages
print_msg() {
    local level=$1
    local msg=$2
    case $level in
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "ERROR")   echo -e "${RED}[ERROR]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "WARN")    echo -e "${YELLOW}[WARN]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "INFO")    echo -e "${BLUE}[INFO]${NC} $msg" | tee -a "$LOG_FILE" ;;
        "DEBUG")   echo -e "${CYAN}[DEBUG]${NC} $msg" | tee -a "$LOG_FILE" ;;
    esac
}

# Print usage
print_usage() {
    cat << EOF
${BLUE}Dependency Resolver Tool v${SCRIPT_VERSION}${NC}

${GREEN}Usage:${NC}
  sudo $SCRIPT_NAME [options]

${GREEN}Options:${NC}
  --check                 Check for broken packages and dependencies
  --analyze <package>     Analyze dependencies for specific package
  --fix                   Attempt to fix broken dependencies (requires sudo)
  --fix-broken            Same as --fix (legacy)
  --autoremove            Remove unused dependencies (requires sudo)
  --report                Generate detailed dependency report
  --verify <package>      Verify all dependencies of package are satisfied
  --conflicts             Find package conflicts
  --show-orphans          Show packages with no dependents
  --help                  Show this help message
  --version               Show version

${GREEN}Examples:${NC}
  # Check for broken packages
  sudo $SCRIPT_NAME --check

  # Analyze curl dependencies
  $SCRIPT_NAME --analyze curl

  # Fix broken state
  sudo $SCRIPT_NAME --fix

  # Generate report
  $SCRIPT_NAME --report

  # Find conflicts
  $SCRIPT_NAME --conflicts

${GREEN}Exit Codes:${NC}
  0   Success - no issues
  1   Error occurred
  2   Broken packages found
  3   Sudo required

${BLUE}Log file:${NC} $LOG_FILE
EOF
}

# Check for broken packages (APT)
check_broken_apt() {
    print_msg "INFO" "Checking for broken packages..."
    
    # Check overall status
    local result=$(apt check 2>&1 || true)
    
    if echo "$result" | grep -q "broken packages"; then
        print_msg "ERROR" "Broken packages detected!"
        echo "$result" | tee -a "$LOG_FILE"
        return 2
    else
        print_msg "SUCCESS" "No broken packages found"
        return 0
    fi
}

# Check for broken packages (YUM/DNF)
check_broken_yum() {
    print_msg "INFO" "Checking for broken packages..."
    
    # YUM/DNF check
    local result=$($PKG_MANAGER check 2>&1 || true)
    
    if echo "$result" | grep -q -E "Error|Problem"; then
        print_msg "ERROR" "Issues detected!"
        echo "$result" | tee -a "$LOG_FILE"
        return 2
    else
        print_msg "SUCCESS" "No issues found"
        return 0
    fi
}

# Analyze package dependencies
analyze_package_apt() {
    local package=$1
    print_msg "INFO" "Analyzing dependencies for '$package'..."
    
    # Check if package is installed
    if ! dpkg -s "$package" &>/dev/null 2>&1; then
        print_msg "WARN" "Package '$package' is not installed"
    fi
    
    # Show what it depends on
    echo -e "\n${CYAN}Direct Dependencies:${NC}"
    apt-cache depends "$package" 2>/dev/null || true
    
    # Show what depends on it
    echo -e "\n${CYAN}Reverse Dependencies:${NC}"
    apt-cache rdepends "$package" 2>/dev/null | head -20 || true
    
    # Show version info
    echo -e "\n${CYAN}Version Information:${NC}"
    apt-cache policy "$package" 2>/dev/null | head -10 || true
}

# Analyze package dependencies (YUM/DNF)
analyze_package_yum() {
    local package=$1
    print_msg "INFO" "Analyzing dependencies for '$package'..."
    
    # Check if package is installed
    if ! rpm -q "$package" &>/dev/null 2>&1; then
        print_msg "WARN" "Package '$package' is not installed"
    fi
    
    # Show what it depends on
    echo -e "\n${CYAN}Direct Dependencies:${NC}"
    $PKG_MANAGER deplist "$package" 2>/dev/null | head -30 || true
    
    # Show version info
    echo -e "\n${CYAN}Version Information:${NC}"
    $PKG_MANAGER info "$package" 2>/dev/null | grep -E "Version|Release" || true
}

# Fix broken packages
fix_broken() {
    if [[ $EUID -ne 0 ]]; then
        print_msg "ERROR" "Fixing broken packages requires sudo"
        return 3
    fi
    
    print_msg "WARN" "Attempting to fix broken dependencies..."
    
    case $PKG_MANAGER in
        "apt")
            # Step 1: Try basic fix
            print_msg "INFO" "Step 1: Trying basic fix..."
            if apt --fix-broken install -y 2>&1 | tee -a "$LOG_FILE"; then
                print_msg "SUCCESS" "Basic fix completed"
            else
                print_msg "WARN" "Basic fix attempted but may not be complete"
            fi
            
            # Step 2: Configure any broken packages
            print_msg "INFO" "Step 2: Configuring incomplete packages..."
            if dpkg --configure -a 2>&1 | tee -a "$LOG_FILE"; then
                print_msg "SUCCESS" "Configuration completed"
            fi
            
            # Step 3: Try again
            print_msg "INFO" "Step 3: Running apt check..."
            if apt check 2>&1 | tee -a "$LOG_FILE"; then
                print_msg "SUCCESS" "System is now healthy"
                return 0
            else
                print_msg "ERROR" "System still has issues, trying aggressive fix..."
                apt install -f -y 2>&1 | tee -a "$LOG_FILE"
            fi
            ;;
            
        "yum"|"dnf")
            # Step 1: Try clean first
            print_msg "INFO" "Step 1: Cleaning cache..."
            $PKG_MANAGER clean all 2>&1 | tee -a "$LOG_FILE"
            
            # Step 2: Check for issues
            print_msg "INFO" "Step 2: Checking for issues..."
            if $PKG_MANAGER check 2>&1 | tee -a "$LOG_FILE"; then
                print_msg "SUCCESS" "System is healthy"
                return 0
            else
                print_msg "WARN" "Issues found, attempting fix..."
                $PKG_MANAGER check --repair 2>&1 | tee -a "$LOG_FILE" || true
            fi
            ;;
    esac
}

# Find package conflicts
find_conflicts() {
    print_msg "INFO" "Analyzing for package conflicts..."
    
    case $PKG_MANAGER in
        "apt")
            # Look for version conflicts
            echo -e "\n${CYAN}Checking for version conflicts:${NC}"
            apt check 2>&1 | grep -i conflict || print_msg "SUCCESS" "No conflicts detected"
            
            # Check for held packages that might cause conflicts
            echo -e "\n${CYAN}Held packages (may cause conflicts):${NC}"
            apt-mark showhold || print_msg "INFO" "No held packages"
            ;;
            
        "yum"|"dnf")
            echo -e "\n${CYAN}Checking for conflicting packages:${NC}"
            # YUM/DNF deplist can show conflicts
            for pkg in $($PKG_MANAGER list installed | awk '{print $1}' | head -50); do
                $PKG_MANAGER deplist "$pkg" 2>/dev/null | grep -i conflict || true
            done | sort -u || print_msg "SUCCESS" "No conflicts detected"
            ;;
    esac
}

# Generate detailed report
generate_report() {
    print_msg "INFO" "Generating dependency report..."
    
    local report_file="/tmp/dependency-report-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "======================================"
        echo "Dependency Report - $(date)"
        echo "======================================"
        echo ""
        
        echo "System Information:"
        echo "  Hostname: $(hostname)"
        echo "  Distro: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
        echo "  Package Manager: $PKG_MANAGER"
        echo ""
        
        echo "Package Statistics:"
        if [[ $PKG_MANAGER == "apt" ]]; then
            local total=$(apt list --installed 2>/dev/null | wc -l)
            local upgradable=$(apt list --upgradable 2>/dev/null | wc -l)
            echo "  Total installed: $total"
            echo "  Upgradable: $upgradable"
            echo "  Held packages:"
            apt-mark showhold 2>/dev/null || echo "    None"
        else
            local total=$($PKG_MANAGER list installed 2>/dev/null | wc -l)
            echo "  Total installed: $total"
        fi
        echo ""
        
        echo "System Health:"
        case $PKG_MANAGER in
            "apt")
                apt check 2>&1 | head -10
                ;;
            "yum"|"dnf")
                $PKG_MANAGER check 2>&1 | head -10
                ;;
        esac
        echo ""
        
        echo "Disk Usage (Cache):"
        if [[ $PKG_MANAGER == "apt" ]]; then
            du -sh /var/cache/apt 2>/dev/null || echo "  N/A"
        else
            du -sh /var/cache/yum 2>/dev/null || echo "  N/A"
        fi
        echo ""
        
        echo "Recent Operations Log:"
        if [[ $PKG_MANAGER == "apt" ]]; then
            tail -10 /var/log/apt/history.log 2>/dev/null || echo "  No history"
        else
            tail -10 /var/log/yum.log 2>/dev/null || echo "  No history"
        fi
        
    } | tee "$report_file"
    
    print_msg "SUCCESS" "Report generated: $report_file"
}

# Verify package dependencies
verify_package() {
    local package=$1
    print_msg "INFO" "Verifying dependencies for '$package'..."
    
    case $PKG_MANAGER in
        "apt")
            if ! dpkg -s "$package" &>/dev/null 2>&1; then
                print_msg "ERROR" "Package '$package' is not installed"
                return 1
            fi
            
            # Check if all dependencies are satisfied
            if apt-cache depends "$package" 2>/dev/null | grep -q "Depends:"; then
                print_msg "SUCCESS" "Package '$package' has satisfied dependencies"
                return 0
            fi
            ;;
            
        "yum"|"dnf")
            if ! rpm -q "$package" &>/dev/null; then
                print_msg "ERROR" "Package '$package' is not installed"
                return 1
            fi
            
            $PKG_MANAGER deplist "$package" 2>/dev/null | grep -q "provider" && \
                print_msg "SUCCESS" "All dependencies satisfied" || \
                print_msg "WARN" "Some dependencies may be missing"
            ;;
    esac
}

# Show orphaned packages (no dependents)
show_orphans() {
    print_msg "INFO" "Searching for orphaned packages..."
    
    case $PKG_MANAGER in
        "apt")
            # Automatically installed packages with no dependents
            echo -e "\n${CYAN}Auto-installed packages that could be removed:${NC}"
            apt-cache showauto 2>/dev/null | while read pkg; do
                # Check if nothing depends on it
                if ! apt-cache rdepends "$pkg" 2>/dev/null | grep -q -v "$pkg"; then
                    echo "  $pkg"
                fi
            done
            
            # Or just show what autoremove would remove
            echo -e "\n${CYAN}Packages autoremove would remove:${NC}"
            apt autoremove --simulate 2>/dev/null | grep "REMOVE" | head -20 || \
                print_msg "SUCCESS" "No orphaned packages found"
            ;;
            
        "yum"|"dnf")
            # YUM/DNF equivalent
            echo -e "\n${CYAN}Unused dependency packages:${NC}"
            $PKG_MANAGER autoremove --simulate 2>/dev/null | head -20 || \
                print_msg "SUCCESS" "No orphaned packages found"
            ;;
    esac
}

# Cleanup on exit
cleanup() {
    print_msg "DEBUG" "Cleaning up temporary files..."
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Main function
main() {
    local command=${1:-}
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    print_msg "INFO" "Starting Dependency Resolver"
    print_msg "DEBUG" "Package manager: $PKG_MANAGER ($PKG_SYSTEM)"
    print_msg "DEBUG" "Log file: $LOG_FILE"
    
    # Route command
    case "$command" in
        --check|check)
            case $PKG_MANAGER in
                "apt") check_broken_apt ;;
                "yum"|"dnf") check_broken_yum ;;
            esac
            ;;
        --analyze|analyze)
            [[ -z "${2:-}" ]] && { print_msg "ERROR" "analyze requires package name"; exit 1; }
            case $PKG_MANAGER in
                "apt") analyze_package_apt "$2" ;;
                "yum"|"dnf") analyze_package_yum "$2" ;;
            esac
            ;;
        --fix|--fix-broken|fix)
            fix_broken
            ;;
        --autoremove|autoremove)
            if [[ $EUID -ne 0 ]]; then
                print_msg "ERROR" "autoremove requires sudo"
                exit 3
            fi
            print_msg "WARN" "Removing unused dependencies..."
            case $PKG_MANAGER in
                "apt") apt autoremove -y | tee -a "$LOG_FILE" ;;
                "yum"|"dnf") $PKG_MANAGER autoremove -y | tee -a "$LOG_FILE" ;;
            esac
            ;;
        --report|report)
            generate_report
            ;;
        --verify|verify)
            [[ -z "${2:-}" ]] && { print_msg "ERROR" "verify requires package name"; exit 1; }
            verify_package "$2"
            ;;
        --conflicts|conflicts)
            find_conflicts
            ;;
        --show-orphans|orphans)
            show_orphans
            ;;
        --help|-h|help)
            print_usage
            ;;
        --version|-v|version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            echo "Detected: $PKG_MANAGER ($PKG_SYSTEM)"
            ;;
        *)
            print_msg "ERROR" "Unknown command: $command"
            echo "Use '$SCRIPT_NAME --help' for usage information"
            exit 1
            ;;
    esac
}

# Detect package manager and run
detect_package_manager
main "$@"
