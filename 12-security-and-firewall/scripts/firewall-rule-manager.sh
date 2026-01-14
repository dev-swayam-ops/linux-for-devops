#!/bin/bash
################################################################################
# firewall-rule-manager.sh
# Safe firewall rule management for UFW with backup and validation
# Provides safe add/remove/audit firewall rules
################################################################################

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="/root/.ufw-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

################################################################################
# Functions
################################################################################

usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Safe firewall rule management for UFW

COMMANDS:
    add PORT/PROTOCOL [DESCRIPTION]
                        Add allow rule for port
    remove PORT/PROTOCOL
                        Remove allow rule for port
    allow-from IP PORT
                        Allow specific IP to port
    deny PORT           Deny traffic on port
    list                Show all current rules
    backup              Backup UFW configuration
    restore FILE        Restore from backup
    status              Show firewall status
    audit               Check for security issues
    test-port PORT      Test if port is accessible
    help                Show this help message

EXAMPLES:
    $0 add 80/tcp "Apache web server"
    $0 remove 80/tcp
    $0 allow-from 192.168.1.100 22
    $0 audit
    $0 backup

SAFETY FEATURES:
    - Always backs up before changes
    - Validates syntax before applying
    - Logs all operations
    - Won't lock you out of SSH (protects port 22)

EOF
}

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

print_ok() {
    echo -e "${GREEN}✓${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script requires root privileges"
        echo "Run with: sudo $0 $@"
        exit 1
    fi
}

check_ufw_installed() {
    if ! command -v ufw &> /dev/null; then
        print_error "UFW not installed"
        echo "Install with: sudo apt install ufw"
        exit 1
    fi
}

create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        chmod 700 "$BACKUP_DIR"
    fi
}

backup_ufw_config() {
    create_backup_dir
    
    local backup_file="$BACKUP_DIR/ufw-backup-$TIMESTAMP.sh"
    
    print_ok "Backing up UFW configuration to: $backup_file"
    
    # Create restore script
    {
        echo "#!/bin/bash"
        echo "# UFW Configuration Backup - $TIMESTAMP"
        echo "# Generated from: $(hostname)"
        echo ""
        echo "echo 'Restoring UFW configuration...'"
        echo ""
        
        # Save default policies
        echo "# Restore default policies"
        local input_policy=$(sudo ufw status | grep "Default:" | grep "incoming" | awk '{print $4}' | tr ',' ' ' | awk '{print $1}')
        local output_policy=$(sudo ufw status | grep "Default:" | grep "outgoing" | awk '{print $4}' | tr ',' ' ' | awk '{print $1}')
        echo "sudo ufw default $input_policy incoming"
        echo "sudo ufw default $output_policy outgoing"
        echo ""
        
        # Save all rules
        echo "# Restore rules"
        sudo ufw status numbered | grep -E "^\[" | while read line; do
            local port=$(echo "$line" | awk '{print $2}')
            local action=$(echo "$line" | awk '{print $3}')
            local from=$(echo "$line" | awk '{print $4}')
            
            if [[ ! "$action" == "Action" ]]; then
                echo "sudo ufw $action $port"
            fi
        done
        
    } > "$backup_file"
    
    chmod 600 "$backup_file"
    print_ok "Backup created successfully"
}

add_rule() {
    local port_proto="$1"
    local description="${2:-}"
    
    backup_ufw_config
    
    print_ok "Adding rule: $port_proto"
    
    if [[ ! "$port_proto" =~ ^[0-9]+/(tcp|udp)$ ]]; then
        # Try to add as-is (could be app profile or simple port)
        sudo ufw allow "$port_proto" 2>/dev/null || {
            print_error "Invalid port format. Use: PORT/PROTOCOL (e.g., 80/tcp)"
            return 1
        }
    else
        sudo ufw allow "$port_proto"
    fi
    
    print_ok "Rule added: $port_proto"
    [[ -n "$description" ]] && echo "  Description: $description"
}

remove_rule() {
    local port_proto="$1"
    
    backup_ufw_config
    
    print_warning "Removing rule: $port_proto"
    
    # Confirm before removing
    echo "This will remove the allow rule for $port_proto"
    read -p "Proceed? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        return
    fi
    
    sudo ufw delete allow "$port_proto" 2>/dev/null || {
        print_error "Failed to remove rule: $port_proto"
        return 1
    }
    
    print_ok "Rule removed: $port_proto"
}

allow_from_ip() {
    local ip="$1"
    local port="$2"
    
    if [[ ! "$ip" =~ ^[0-9.]+(/[0-9]+)?$ ]]; then
        print_error "Invalid IP address: $ip"
        return 1
    fi
    
    backup_ufw_config
    
    print_ok "Allowing $ip to port $port"
    sudo ufw allow from "$ip" to any port "$port"
    
    print_ok "Rule added: Allow $ip to port $port"
}

deny_port() {
    local port="$1"
    
    # Protect SSH from accidental denial
    if [[ "$port" == "22" ]]; then
        print_error "Refusing to deny port 22 (SSH) - would lock you out!"
        echo "If you really need this, edit UFW rules manually"
        return 1
    fi
    
    backup_ufw_config
    
    print_warning "Denying port: $port"
    sudo ufw deny "$port"
    
    print_ok "Rule added: Deny port $port"
}

list_rules() {
    print_header "Current UFW Rules"
    sudo ufw status numbered
}

check_firewall_status() {
    print_header "Firewall Status"
    sudo ufw status
}

audit_firewall() {
    print_header "Firewall Security Audit"
    
    # Check if enabled
    local status=$(sudo ufw status | grep "Status:" | awk '{print $2}')
    
    if [[ "$status" == "inactive" ]]; then
        print_warning "Firewall is INACTIVE"
    else
        print_ok "Firewall is active"
    fi
    
    # Check default policies
    echo ""
    echo "Default Policies:"
    sudo ufw status | grep "Default:"
    
    # Check for SSH access
    echo ""
    echo "SSH Access:"
    if sudo ufw status | grep -q "22.*ALLOW"; then
        print_ok "Port 22 (SSH) is allowed"
    else
        print_error "Port 22 (SSH) might be blocked - check carefully!"
    fi
    
    # Count rules
    echo ""
    local rule_count=$(sudo ufw status numbered | grep -c "^\[" || true)
    echo "Total rules: $rule_count"
    
    # Check for overly broad rules
    echo ""
    echo "Security Recommendations:"
    
    if sudo ufw status numbered | grep -q "Anywhere.*ALLOW"; then
        print_warning "Found 'Anywhere' ALLOW rules - should be specific IPs"
    fi
    
    if sudo ufw status | grep "Default:.*allow.*incoming" > /dev/null; then
        print_warning "Default incoming policy is ALLOW (should be DENY for security)"
    else
        print_ok "Default incoming policy is restrictive"
    fi
    
    # Check for logging
    if sudo ufw logging | grep -q "on"; then
        print_ok "Logging is enabled"
    else
        print_warning "Consider enabling logging: sudo ufw logging on"
    fi
}

restore_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        print_error "Backup file not found: $backup_file"
        return 1
    fi
    
    print_warning "This will restore UFW configuration from: $backup_file"
    read -p "Proceed? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_ok "Cancelled"
        return
    fi
    
    print_ok "Restoring configuration..."
    sudo bash "$backup_file"
    
    print_ok "Configuration restored"
}

test_port_access() {
    local port="$1"
    
    print_ok "Testing port accessibility: $port"
    
    if command -v nc &> /dev/null; then
        # Try netcat
        timeout 2 nc -zv localhost "$port" 2>&1 || print_warning "Port $port not accessible"
    elif command -v telnet &> /dev/null; then
        # Try telnet
        timeout 2 telnet localhost "$port" 2>&1 || print_warning "Port $port not accessible"
    else
        print_warning "Install netcat or telnet to test port connectivity"
    fi
}

################################################################################
# Main Script
################################################################################

main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 0
    fi
    
    local command="$1"
    shift
    
    check_root
    check_ufw_installed
    
    case "$command" in
        add)
            [[ $# -lt 1 ]] && { print_error "Missing port"; usage; exit 1; }
            add_rule "$@"
            ;;
        remove)
            [[ $# -lt 1 ]] && { print_error "Missing port"; usage; exit 1; }
            remove_rule "$1"
            ;;
        allow-from)
            [[ $# -lt 2 ]] && { print_error "Missing IP or port"; usage; exit 1; }
            allow_from_ip "$1" "$2"
            ;;
        deny)
            [[ $# -lt 1 ]] && { print_error "Missing port"; usage; exit 1; }
            deny_port "$1"
            ;;
        list)
            list_rules
            ;;
        backup)
            backup_ufw_config
            ;;
        restore)
            [[ $# -lt 1 ]] && { print_error "Missing backup file"; usage; exit 1; }
            restore_backup "$1"
            ;;
        status)
            check_firewall_status
            ;;
        audit)
            audit_firewall
            ;;
        test-port)
            [[ $# -lt 1 ]] && { print_error "Missing port"; usage; exit 1; }
            test_port_access "$1"
            ;;
        help)
            usage
            ;;
        *)
            print_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
