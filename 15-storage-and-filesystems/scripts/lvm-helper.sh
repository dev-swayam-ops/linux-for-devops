#!/bin/bash

################################################################################
# LVM Helper Script
# Simplified interface for common LVM operations
#
# Usage: ./lvm-helper.sh [COMMAND] [ARGUMENTS]
# Commands:
#   create-pv       Create physical volume
#   create-vg       Create volume group
#   create-lv       Create logical volume
#   extend-lv       Extend logical volume
#   extend-fs       Extend filesystem to use new LV space
#   remove-lv       Remove logical volume
#   show-status     Show LVM status
#   backup-config   Backup LVM configuration
#   help            Show help
################################################################################

set -euo pipefail

# Configuration
DRY_RUN=0
FORCE=0
BACKUP_DIR="/var/backups/lvm"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Utility Functions
################################################################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root${NC}" >&2
        exit 1
    fi
}

check_lvm() {
    if ! command -v lvm &>/dev/null; then
        echo -e "${RED}Error: LVM is not installed${NC}" >&2
        exit 1
    fi
}

info() {
    echo -e "${GREEN}ℹ${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1" >&2
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

confirm() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$(echo -e ${YELLOW}$prompt${NC}) (yes/no): " response
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

################################################################################
# Physical Volume Operations
################################################################################

cmd_create_pv() {
    local device="$1"
    
    if [[ -z "$device" ]]; then
        error "Usage: lvm-helper.sh create-pv <device>"
        echo "Example: lvm-helper.sh create-pv /dev/sdb"
        exit 1
    fi
    
    if [[ ! -b "$device" ]]; then
        error "Device not found: $device"
        exit 1
    fi
    
    echo "Creating physical volume on $device"
    info "This will initialize the device for LVM"
    
    if confirm "Continue?"; then
        if (( DRY_RUN == 1 )); then
            echo "[DRY-RUN] pvcreate $device"
        else
            if sudo pvcreate "$device"; then
                info "Physical volume created successfully"
                sudo pvdisplay "$device"
            else
                error "Failed to create physical volume"
                exit 1
            fi
        fi
    else
        echo "Cancelled."
    fi
}

################################################################################
# Volume Group Operations
################################################################################

cmd_create_vg() {
    local vg_name="$1"
    local pv_device="$2"
    
    if [[ -z "$vg_name" || -z "$pv_device" ]]; then
        error "Usage: lvm-helper.sh create-vg <vg-name> <pv-device>"
        echo "Example: lvm-helper.sh create-vg vg0 /dev/sdb"
        exit 1
    fi
    
    echo "Creating volume group '$vg_name' from $pv_device"
    
    if confirm "Continue?"; then
        if (( DRY_RUN == 1 )); then
            echo "[DRY-RUN] vgcreate $vg_name $pv_device"
        else
            if sudo vgcreate "$vg_name" "$pv_device"; then
                info "Volume group created successfully"
                sudo vgdisplay "$vg_name"
            else
                error "Failed to create volume group"
                exit 1
            fi
        fi
    else
        echo "Cancelled."
    fi
}

cmd_show_vg() {
    echo "Volume Groups:"
    sudo vgs
    echo ""
    echo "Detailed information:"
    sudo vgdisplay
}

################################################################################
# Logical Volume Operations
################################################################################

cmd_create_lv() {
    local vg_name="$1"
    local lv_name="$2"
    local size="$3"
    
    if [[ -z "$vg_name" || -z "$lv_name" || -z "$size" ]]; then
        error "Usage: lvm-helper.sh create-lv <vg-name> <lv-name> <size>"
        echo "Example: lvm-helper.sh create-lv vg0 lv_data 10G"
        echo "Size formats: 10G, 512M, 1024 (sectors)"
        exit 1
    fi
    
    # Verify VG exists
    if ! sudo vgdisplay "$vg_name" &>/dev/null; then
        error "Volume group not found: $vg_name"
        exit 1
    fi
    
    echo "Creating logical volume:"
    echo "  Volume Group:   $vg_name"
    echo "  Logical Volume: $lv_name"
    echo "  Size:          $size"
    
    if confirm "Continue?"; then
        if (( DRY_RUN == 1 )); then
            echo "[DRY-RUN] lvcreate -L $size -n $lv_name $vg_name"
        else
            if sudo lvcreate -L "$size" -n "$lv_name" "$vg_name"; then
                info "Logical volume created"
                info "Next: Create filesystem with:"
                echo "  sudo mkfs.ext4 /dev/$vg_name/$lv_name"
            else
                error "Failed to create logical volume"
                exit 1
            fi
        fi
    else
        echo "Cancelled."
    fi
}

cmd_extend_lv() {
    local lv_path="$1"
    local additional_size="$2"
    
    if [[ -z "$lv_path" || -z "$additional_size" ]]; then
        error "Usage: lvm-helper.sh extend-lv <lv-path> <additional-size>"
        echo "Example: lvm-helper.sh extend-lv /dev/vg0/lv_data 5G"
        exit 1
    fi
    
    # Verify LV exists
    if ! sudo lvdisplay "$lv_path" &>/dev/null 2>&1; then
        error "Logical volume not found: $lv_path"
        exit 1
    fi
    
    local current_size=$(sudo lvdisplay "$lv_path" | grep "LV Size" | awk '{print $3, $4}')
    
    echo "Extending logical volume:"
    echo "  Path:              $lv_path"
    echo "  Current Size:      $current_size"
    echo "  Additional:        $additional_size"
    
    if confirm "Continue?"; then
        if (( DRY_RUN == 1 )); then
            echo "[DRY-RUN] lvextend -L +$additional_size $lv_path"
        else
            if sudo lvextend -L "+$additional_size" "$lv_path"; then
                info "Logical volume extended"
                info "Next: Extend filesystem with:"
                echo "  sudo resize2fs $lv_path  # for ext4"
                echo "  sudo xfs_growfs <mount-point>  # for xfs"
                sudo lvdisplay "$lv_path" | grep "LV Size"
            else
                error "Failed to extend logical volume"
                exit 1
            fi
        fi
    else
        echo "Cancelled."
    fi
}

cmd_extend_fs() {
    local lv_path="$1"
    local mount_point="${2:-.}"
    
    if [[ -z "$lv_path" ]]; then
        error "Usage: lvm-helper.sh extend-fs <lv-path> [mount-point]"
        echo "Example: lvm-helper.sh extend-fs /dev/vg0/lv_data /home"
        exit 1
    fi
    
    # Detect filesystem type
    local fs_type=$(sudo blkid "$lv_path" | grep -oP 'TYPE="\K[^"]+' || echo "unknown")
    
    echo "Extending filesystem:"
    echo "  Logical Volume:  $lv_path"
    echo "  Filesystem Type: $fs_type"
    echo "  Mount Point:     $mount_point"
    
    if confirm "Continue?"; then
        if (( DRY_RUN == 1 )); then
            case "$fs_type" in
                ext4|ext3|ext2)
                    echo "[DRY-RUN] resize2fs $lv_path"
                    ;;
                xfs)
                    echo "[DRY-RUN] xfs_growfs $mount_point"
                    ;;
                *)
                    echo "[DRY-RUN] Unknown filesystem type: $fs_type"
                    ;;
            esac
        else
            case "$fs_type" in
                ext4|ext3|ext2)
                    if sudo resize2fs "$lv_path"; then
                        info "Filesystem extended"
                    else
                        error "Failed to extend filesystem"
                        exit 1
                    fi
                    ;;
                xfs)
                    if sudo xfs_growfs "$mount_point"; then
                        info "Filesystem extended"
                    else
                        error "Failed to extend filesystem"
                        exit 1
                    fi
                    ;;
                *)
                    error "Unsupported filesystem type: $fs_type"
                    exit 1
                    ;;
            esac
        fi
    else
        echo "Cancelled."
    fi
}

cmd_remove_lv() {
    local lv_path="$1"
    
    if [[ -z "$lv_path" ]]; then
        error "Usage: lvm-helper.sh remove-lv <lv-path>"
        echo "Example: lvm-helper.sh remove-lv /dev/vg0/lv_data"
        exit 1
    fi
    
    warn "This will DELETE the logical volume and all data"
    warn "Logical Volume: $lv_path"
    
    if confirm "Are you absolutely sure?"; then
        if (( DRY_RUN == 1 )); then
            echo "[DRY-RUN] lvremove -f $lv_path"
        else
            if sudo lvremove -f "$lv_path"; then
                info "Logical volume removed"
            else
                error "Failed to remove logical volume"
                exit 1
            fi
        fi
    else
        echo "Cancelled."
    fi
}

################################################################################
# Status and Monitoring
################################################################################

cmd_show_status() {
    echo -e "${BLUE}=== LVM STATUS ===${NC}\n"
    
    echo "Physical Volumes:"
    sudo pvs
    echo ""
    
    echo "Volume Groups:"
    sudo vgs
    echo ""
    
    echo "Logical Volumes:"
    sudo lvs
    echo ""
    
    echo "Detailed Information:"
    echo "PV Details:"
    sudo pvdisplay | head -20
    echo ""
    echo "VG Details:"
    sudo vgdisplay | head -20
    echo ""
    echo "LV Details:"
    sudo lvdisplay | head -20
}

################################################################################
# Backup and Recovery
################################################################################

cmd_backup_config() {
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/lvm-config-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "LVM Configuration Backup - $(date)"
        echo ""
        echo "=== Physical Volumes ==="
        sudo pvdisplay
        echo ""
        echo "=== Volume Groups ==="
        sudo vgdisplay
        echo ""
        echo "=== Logical Volumes ==="
        sudo lvdisplay
        echo ""
        echo "=== Mounted Filesystems ==="
        mount | grep -E "^/dev"
        echo ""
        echo "=== /etc/fstab ==="
        cat /etc/fstab
    } | tee "$backup_file"
    
    info "Configuration backed up to: $backup_file"
}

################################################################################
# Help
################################################################################

show_help() {
    cat << 'EOF'
LVM Helper - Simplified LVM Management

Usage: lvm-helper.sh [COMMAND] [ARGUMENTS] [OPTIONS]

Physical Volume Commands:
  create-pv <device>
    Create physical volume on device
    Example: lvm-helper.sh create-pv /dev/sdb

Volume Group Commands:
  create-vg <vg-name> <pv-device>
    Create volume group from physical volume
    Example: lvm-helper.sh create-vg vg0 /dev/sdb
  
  show-vg
    List all volume groups with details

Logical Volume Commands:
  create-lv <vg-name> <lv-name> <size>
    Create logical volume in volume group
    Example: lvm-helper.sh create-lv vg0 lv_data 10G
  
  extend-lv <lv-path> <additional-size>
    Extend logical volume
    Example: lvm-helper.sh extend-lv /dev/vg0/lv_data 5G
  
  extend-fs <lv-path> [mount-point]
    Resize filesystem to use additional LV space
    Example: lvm-helper.sh extend-fs /dev/vg0/lv_data /home
  
  remove-lv <lv-path>
    Remove logical volume (destructive!)
    Example: lvm-helper.sh remove-lv /dev/vg0/lv_data

Status Commands:
  show-status
    Display detailed LVM status
  
  backup-config
    Backup current LVM configuration

Options:
  --dry-run       Show what would be done without making changes
  --force         Skip confirmations (dangerous!)
  --help          Show this help message

Common Workflows:

1. Create new storage from disk:
   lvm-helper.sh create-pv /dev/sdb
   lvm-helper.sh create-vg vg0 /dev/sdb
   lvm-helper.sh create-lv vg0 lv_data 20G
   sudo mkfs.ext4 /dev/vg0/lv_data

2. Expand existing logical volume:
   lvm-helper.sh extend-lv /dev/vg0/lv_data 5G
   lvm-helper.sh extend-fs /dev/vg0/lv_data /data

3. Check status:
   lvm-helper.sh show-status

Requirements:
  - Root access
  - LVM tools installed (lvm2 package)
  - sudo configured (for non-interactive runs)

EOF
}

################################################################################
# Main
################################################################################

main() {
    check_root
    check_lvm
    
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        create-pv)
            cmd_create_pv "$@"
            ;;
        create-vg)
            cmd_create_vg "$@"
            ;;
        create-lv)
            cmd_create_lv "$@"
            ;;
        extend-lv)
            cmd_extend_lv "$@"
            ;;
        extend-fs)
            cmd_extend_fs "$@"
            ;;
        remove-lv)
            cmd_remove_lv "$@"
            ;;
        show-vg)
            cmd_show_vg
            ;;
        show-status)
            cmd_show_status
            ;;
        backup-config)
            cmd_backup_config
            ;;
        --dry-run)
            DRY_RUN=1
            main "$@"
            ;;
        --force)
            FORCE=1
            main "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $command"
            echo "Run 'lvm-helper.sh help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
