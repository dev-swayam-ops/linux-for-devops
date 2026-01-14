#!/bin/bash

################################################################################
# user-manager.sh
# 
# Purpose: Automate user and group management operations
# 
# Usage: 
#   ./user-manager.sh create-user <username> [<home_dir>] [<shell>]
#   ./user-manager.sh delete-user <username>
#   ./user-manager.sh create-group <groupname>
#   ./user-manager.sh delete-group <groupname>
#   ./user-manager.sh add-to-group <username> <groupname>
#   ./user-manager.sh remove-from-group <username> <groupname>
#   ./user-manager.sh list-users [<pattern>]
#   ./user-manager.sh list-groups [<pattern>]
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_VERSION="1.0"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="${LOG_FILE:-/var/log/user-manager.log}"
DEFAULT_SHELL="/bin/bash"
DEFAULT_HOME_BASE="/home"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Utility Functions
################################################################################

# Print error message
error() {
    printf "${RED}✗ ERROR${NC}: %s\n" "$@" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE"
}

# Print success message
success() {
    printf "${GREEN}✓ SUCCESS${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*" >> "$LOG_FILE"
}

# Print info message
info() {
    printf "${BLUE}ℹ INFO${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" >> "$LOG_FILE"
}

# Print warning message
warning() {
    printf "${YELLOW}⚠ WARNING${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*" >> "$LOG_FILE"
}

# Check if running as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Print usage help
print_help() {
    cat << 'EOF'
User and Group Manager - Automate user and group operations

USAGE:
  user-manager create-user <username> [options]
  user-manager delete-user <username> [--remove-home]
  user-manager create-group <groupname>
  user-manager delete-group <groupname> [--force]
  user-manager add-to-group <username> <groupname>
  user-manager remove-from-group <username> <groupname>
  user-manager list-users [<pattern>]
  user-manager list-groups [<pattern>]
  user-manager help
  user-manager version

CREATE-USER OPTIONS:
  --home <path>              Custom home directory (default: /home/<username>)
  --shell <path>             Shell path (default: /bin/bash)
  --uid <uid>                Specific UID (optional)
  --gid <gid>                Specific GID (optional)
  --groups <group1,group2>   Secondary groups
  --comment <text>           Full name / comment
  --disabled                 Create disabled account (no shell)

DELETE-USER OPTIONS:
  --remove-home              Remove home directory and mail spool
  --force                    Force deletion even if files exist

EXAMPLES:
  # Create user with defaults
  user-manager create-user alice

  # Create user with specific shell and groups
  user-manager create-user bob --shell /bin/zsh --groups developers,sudo

  # Add user to group
  user-manager add-to-group alice developers

  # List users matching pattern
  user-manager list-users dev

  # Delete user and remove home
  user-manager delete-user alice --remove-home
EOF
}

################################################################################
# User Management Functions
################################################################################

# Create a user account
create_user() {
    local username="$1"
    local home_dir="${HOME_DIR:-$DEFAULT_HOME_BASE/$username}"
    local shell="${SHELL:-$DEFAULT_SHELL}"
    local uid="${UID_OPT:-}"
    local gid="${GID_OPT:-}"
    local groups="${GROUPS_OPT:-}"
    local comment="${COMMENT_OPT:-}"
    local disabled="${DISABLED_OPT:-false}"

    # Validate username
    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
        error "Invalid username: $username"
        return 1
    fi

    # Check if user exists
    if id "$username" &>/dev/null; then
        warning "User $username already exists"
        return 1
    fi

    info "Creating user: $username"

    # Build useradd command
    local useradd_cmd="useradd -m -s"

    if [[ "$disabled" == "true" ]]; then
        useradd_cmd="$useradd_cmd /usr/sbin/nologin"
    else
        useradd_cmd="$useradd_cmd $shell"
    fi

    useradd_cmd="$useradd_cmd -d $home_dir"

    [[ -n "$uid" ]] && useradd_cmd="$useradd_cmd -u $uid"
    [[ -n "$gid" ]] && useradd_cmd="$useradd_cmd -g $gid"
    [[ -n "$comment" ]] && useradd_cmd="$useradd_cmd -c \"$comment\""

    # Create user
    if eval "$useradd_cmd $username"; then
        success "User $username created"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] User created: $username (home: $home_dir)" >> "$LOG_FILE"

        # Add to secondary groups if specified
        if [[ -n "$groups" ]]; then
            IFS=',' read -ra GROUP_ARRAY <<< "$groups"
            for group in "${GROUP_ARRAY[@]}"; do
                group=$(echo "$group" | xargs)  # Trim whitespace
                if usermod -a -G "$group" "$username" 2>/dev/null; then
                    info "Added $username to group: $group"
                else
                    warning "Failed to add $username to group: $group"
                fi
            done
        fi

        return 0
    else
        error "Failed to create user: $username"
        return 1
    fi
}

# Delete a user account
delete_user() {
    local username="$1"
    local remove_home="${REMOVE_HOME:-false}"
    local force="${FORCE:-false}"

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        error "User $username does not exist"
        return 1
    fi

    # Get home directory before deletion
    local home_dir
    home_dir=$(eval "echo ~$username" 2>/dev/null || echo "/home/$username")

    info "Deleting user: $username"

    # Check for running processes
    if pgrep -u "$username" > /dev/null; then
        warning "User $username has running processes"
        if [[ "$force" != "true" ]]; then
            error "Use --force to proceed with deletion"
            return 1
        fi
        pkill -9 -u "$username" 2>/dev/null || true
        warning "Killed all processes for $username"
    fi

    # Delete user
    local userdel_cmd="userdel"
    [[ "$remove_home" == "true" ]] && userdel_cmd="$userdel_cmd -r"

    if $userdel_cmd "$username"; then
        success "User $username deleted"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] User deleted: $username" >> "$LOG_FILE"
        
        if [[ "$remove_home" == "true" ]] && [[ -d "$home_dir" ]]; then
            info "Home directory removed: $home_dir"
        fi
        return 0
    else
        error "Failed to delete user: $username"
        return 1
    fi
}

################################################################################
# Group Management Functions
################################################################################

# Create a group
create_group() {
    local groupname="$1"
    local gid="${GID_OPT:-}"

    # Validate group name
    if [[ ! "$groupname" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
        error "Invalid group name: $groupname"
        return 1
    fi

    # Check if group exists
    if getent group "$groupname" &>/dev/null; then
        warning "Group $groupname already exists"
        return 1
    fi

    info "Creating group: $groupname"

    local groupadd_cmd="groupadd"
    [[ -n "$gid" ]] && groupadd_cmd="$groupadd_cmd -g $gid"

    if $groupadd_cmd "$groupname"; then
        success "Group $groupname created"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Group created: $groupname" >> "$LOG_FILE"
        return 0
    else
        error "Failed to create group: $groupname"
        return 1
    fi
}

# Delete a group
delete_group() {
    local groupname="$1"
    local force="${FORCE:-false}"

    # Check if group exists
    if ! getent group "$groupname" &>/dev/null; then
        error "Group $groupname does not exist"
        return 1
    fi

    info "Deleting group: $groupname"

    # Check if group is in use
    if getent group "$groupname" | grep -q ":"; then
        local member_count
        member_count=$(getent group "$groupname" | cut -d: -f4 | tr ',' '\n' | wc -l)
        
        if [[ $member_count -gt 0 ]]; then
            warning "Group $groupname has members"
            if [[ "$force" != "true" ]]; then
                error "Use --force to proceed with deletion"
                return 1
            fi
        fi
    fi

    if groupdel "$groupname"; then
        success "Group $groupname deleted"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Group deleted: $groupname" >> "$LOG_FILE"
        return 0
    else
        error "Failed to delete group: $groupname"
        return 1
    fi
}

# Add user to group
add_to_group() {
    local username="$1"
    local groupname="$2"

    # Validate inputs
    if ! id "$username" &>/dev/null; then
        error "User $username does not exist"
        return 1
    fi

    if ! getent group "$groupname" &>/dev/null; then
        error "Group $groupname does not exist"
        return 1
    fi

    info "Adding user $username to group $groupname"

    if usermod -a -G "$groupname" "$username"; then
        success "User $username added to group $groupname"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Added $username to $groupname" >> "$LOG_FILE"
        return 0
    else
        error "Failed to add $username to group $groupname"
        return 1
    fi
}

# Remove user from group
remove_from_group() {
    local username="$1"
    local groupname="$2"

    # Validate inputs
    if ! id "$username" &>/dev/null; then
        error "User $username does not exist"
        return 1
    fi

    if ! getent group "$groupname" &>/dev/null; then
        error "Group $groupname does not exist"
        return 1
    fi

    info "Removing user $username from group $groupname"

    # Get current groups
    local current_groups
    current_groups=$(id -G "$username")
    local group_gid
    group_gid=$(getent group "$groupname" | cut -d: -f3)

    # Check if user is member
    if [[ ! " $current_groups " =~ " $group_gid " ]]; then
        warning "User $username is not a member of $groupname"
        return 1
    fi

    # Get other groups
    local other_groups=""
    local gids=($current_groups)
    for gid in "${gids[@]}"; do
        if [[ $gid != "$group_gid" ]]; then
            other_groups="$other_groups $gid"
        fi
    done

    if [[ -z "$other_groups" ]]; then
        error "Cannot remove user from only primary group"
        return 1
    fi

    # Use usermod to set groups (removes the specified group)
    local group_list=""
    for gid in $other_groups; do
        group_list="$group_list,$(getent group | awk -F: -v gid="$gid" '$3==gid {print $1}')"
    done
    group_list="${group_list:1}"  # Remove leading comma

    # For simplicity, we can also use the gid directly
    if usermod -G "$group_list" "$username" 2>/dev/null || true; then
        success "User $username removed from group $groupname"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Removed $username from $groupname" >> "$LOG_FILE"
        return 0
    else
        error "Failed to remove $username from group $groupname"
        return 1
    fi
}

################################################################################
# List Functions
################################################################################

# List users
list_users() {
    local pattern="${1:-}"
    
    info "Listing users"
    
    if [[ -z "$pattern" ]]; then
        getent passwd | cut -d: -f1,3,6 | column -t -s:
    else
        getent passwd | grep "$pattern" | cut -d: -f1,3,6 | column -t -s:
    fi
}

# List groups
list_groups() {
    local pattern="${1:-}"
    
    info "Listing groups"
    
    if [[ -z "$pattern" ]]; then
        getent group | cut -d: -f1,3,4 | column -t -s:
    else
        getent group | grep "$pattern" | cut -d: -f1,3,4 | column -t -s:
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    require_root

    local command="${1:-help}"

    case "$command" in
        create-user)
            shift
            if [[ $# -lt 1 ]]; then
                error "Username required"
                print_help
                exit 1
            fi
            
            local username="$1"
            shift
            
            # Parse options
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --home)
                        HOME_DIR="$2"
                        shift 2
                        ;;
                    --shell)
                        SHELL="$2"
                        shift 2
                        ;;
                    --uid)
                        UID_OPT="$2"
                        shift 2
                        ;;
                    --gid)
                        GID_OPT="$2"
                        shift 2
                        ;;
                    --groups)
                        GROUPS_OPT="$2"
                        shift 2
                        ;;
                    --comment)
                        COMMENT_OPT="$2"
                        shift 2
                        ;;
                    --disabled)
                        DISABLED_OPT="true"
                        shift
                        ;;
                    *)
                        error "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            create_user "$username"
            ;;
        delete-user)
            shift
            if [[ $# -lt 1 ]]; then
                error "Username required"
                exit 1
            fi
            
            local username="$1"
            shift
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --remove-home)
                        REMOVE_HOME="true"
                        shift
                        ;;
                    --force)
                        FORCE="true"
                        shift
                        ;;
                    *)
                        error "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            delete_user "$username"
            ;;
        create-group)
            shift
            if [[ $# -lt 1 ]]; then
                error "Group name required"
                exit 1
            fi
            create_group "$1"
            ;;
        delete-group)
            shift
            if [[ $# -lt 1 ]]; then
                error "Group name required"
                exit 1
            fi
            
            while [[ $# -gt 0 ]]; do
                case "$1" in
                    --force)
                        FORCE="true"
                        shift
                        ;;
                    *)
                        error "Unknown option: $1"
                        exit 1
                        ;;
                esac
            done
            
            delete_group "$1"
            ;;
        add-to-group)
            shift
            if [[ $# -lt 2 ]]; then
                error "Username and group name required"
                exit 1
            fi
            add_to_group "$1" "$2"
            ;;
        remove-from-group)
            shift
            if [[ $# -lt 2 ]]; then
                error "Username and group name required"
                exit 1
            fi
            remove_from_group "$1" "$2"
            ;;
        list-users)
            shift
            list_users "${1:-}"
            ;;
        list-groups)
            shift
            list_groups "${1:-}"
            ;;
        version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            ;;
        help|--help|-h)
            print_help
            ;;
        *)
            error "Unknown command: $command"
            print_help
            exit 1
            ;;
    esac
}

main "$@"
