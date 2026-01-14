#!/bin/bash

################################################################################
# config-backup.sh
#
# Purpose: Create automated backups of system configuration files
#
# Usage:
#   ./config-backup.sh backup [<target_dir>] [--compress] [--exclude <pattern>]
#   ./config-backup.sh restore <backup_file> [--verify-only]
#   ./config-backup.sh list [<backup_dir>]
#   ./config-backup.sh cleanup <backup_dir> [--keep <n>]
#   ./config-backup.sh verify <backup_file>
#
################################################################################

set -euo pipefail

# Configuration
SCRIPT_VERSION="1.0"
SCRIPT_NAME=$(basename "$0")
DEFAULT_BACKUP_DIR="/backup/configs"
LOG_FILE="/var/log/config-backup.log"

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
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE" 2>/dev/null || true
    exit 1
}

# Print success message
success() {
    printf "${GREEN}✓ SUCCESS${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Print info message
info() {
    printf "${BLUE}ℹ INFO${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Print warning message
warning() {
    printf "${YELLOW}⚠ WARNING${NC}: %s\n" "$@"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $*" >> "$LOG_FILE" 2>/dev/null || true
}

# Check if running as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Print usage help
print_help() {
    cat << 'EOF'
Config Backup Tool - Automated configuration file backup and restoration

USAGE:
  config-backup backup [options]
  config-backup restore <backup_file> [--verify-only]
  config-backup list [<backup_dir>]
  config-backup cleanup <backup_dir> [--keep <n>]
  config-backup verify <backup_file>
  config-backup help
  config-backup version

COMMANDS:
  backup              Create backup of /etc directory
  restore             Restore configuration from backup
  list                List available backups
  cleanup             Remove old backups, keep recent N
  verify              Verify backup integrity
  help                Show this help text
  version             Show version

BACKUP OPTIONS:
  --compress          Use gzip compression (default)
  --no-compress       Don't compress backup
  --exclude <pattern> Exclude paths matching pattern
  --target <dir>      Backup destination (default: /backup/configs)

RESTORE OPTIONS:
  --verify-only       Don't restore, just verify contents
  --dry-run          Show what would be restored
  --force            Skip confirmation prompt

CLEANUP OPTIONS:
  --keep <n>          Keep last N backups (default: 7)
  --delete-all        Remove all backups (use with caution!)

EXAMPLES:
  # Create backup of /etc with compression
  config-backup backup --compress

  # Create backup excluding sensitive files
  config-backup backup --exclude "ssl/private" --exclude "shadow"

  # List available backups
  config-backup list

  # Restore from backup with verification
  config-backup restore /backup/configs/etc-20240115-100000.tar.gz

  # Keep only last 3 backups
  config-backup cleanup /backup/configs --keep 3
EOF
}

################################################################################
# Backup Functions
################################################################################

# Create configuration backup
backup_config() {
    local target_dir="${1:-.}"
    local compress=true
    local exclude_patterns=()

    require_root

    info "Starting configuration backup"

    # Parse options
    while [[ $# -gt 1 ]]; do
        shift
        case "$1" in
            --compress)
                compress=true
                ;;
            --no-compress)
                compress=false
                ;;
            --exclude)
                shift
                exclude_patterns+=("$1")
                ;;
            --target)
                shift
                target_dir="$1"
                ;;
            *)
                warning "Unknown option: $1"
                ;;
        esac
    done

    # Create backup directory
    mkdir -p "$target_dir"
    [[ ! -w "$target_dir" ]] && error "Cannot write to $target_dir"

    # Create backup filename with timestamp
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file
    if [[ "$compress" == "true" ]]; then
        backup_file="$target_dir/etc-$timestamp.tar.gz"
    else
        backup_file="$target_dir/etc-$timestamp.tar"
    fi

    # Build tar command
    local tar_cmd="tar"
    if [[ "$compress" == "true" ]]; then
        tar_cmd="$tar_cmd czf"
    else
        tar_cmd="$tar_cmd cf"
    fi

    # Add exclusions
    local tar_excludes=""
    for pattern in "${exclude_patterns[@]}"; do
        tar_excludes="$tar_excludes --exclude=/etc/$pattern"
    done

    # Default exclusions (sensitive files)
    local default_excludes="--exclude=/etc/ssl/private --exclude=/etc/shadow --exclude=/etc/shadow- --exclude=/etc/shadow.* --exclude=/etc/gshadow --exclude=/etc/gshadow-"

    info "Backup source: /etc"
    info "Backup file: $backup_file"
    info "Compression: $compress"
    [[ -n "${exclude_patterns[*]}" ]] && info "Excluded: ${exclude_patterns[*]}"

    # Create backup
    if eval "tar $tar_excludes $default_excludes $tar_cmd $backup_file /etc" 2>&1 | grep -v "Removing leading '/' from member names" || true; then
        if [[ -f "$backup_file" ]]; then
            local size=$(du -h "$backup_file" | cut -f1)
            success "Backup created: $backup_file ($size)"

            # Create checksum file
            sha256sum "$backup_file" > "$backup_file.sha256"
            info "Checksum saved: $backup_file.sha256"

            # Create metadata file
            cat > "$backup_file.meta" << METADATA
Backup Timestamp: $timestamp
Backup File: $backup_file
Compression: $compress
Source: /etc
Size: $size
Created by: $SCRIPT_NAME v$SCRIPT_VERSION
Created at: $(date)
Hostname: $(hostname)
Kernel: $(uname -r)
METADATA
            info "Metadata saved: $backup_file.meta"

            return 0
        else
            error "Backup file not created"
        fi
    else
        error "Failed to create backup"
    fi
}

################################################################################
# Restore Functions
################################################################################

# Restore configuration from backup
restore_config() {
    local backup_file="$1"
    local verify_only=false
    local dry_run=false
    local force=false

    require_root

    # Verify backup file exists
    [[ ! -f "$backup_file" ]] && error "Backup file not found: $backup_file"

    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verify-only)
                verify_only=true
                ;;
            --dry-run)
                dry_run=true
                ;;
            --force)
                force=true
                ;;
            *)
                warning "Unknown option: $1"
                ;;
        esac
        shift || true
    done

    info "Preparing to restore from: $backup_file"

    # Verify checksum if available
    if [[ -f "$backup_file.sha256" ]]; then
        info "Verifying backup integrity..."
        if sha256sum -c "$backup_file.sha256" --quiet; then
            success "Backup integrity verified"
        else
            error "Backup checksum failed - file may be corrupted"
        fi
    else
        warning "No checksum file found - skipping integrity check"
    fi

    # Show backup contents
    info "Backup contents:"
    if [[ "$backup_file" == *.tar.gz ]]; then
        tar tzf "$backup_file" | head -20
    else
        tar tf "$backup_file" | head -20
    fi

    # Verify only mode
    if [[ "$verify_only" == "true" ]]; then
        info "Backup verification complete (restore not performed)"
        return 0
    fi

    # Dry-run mode
    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN: Would restore from $backup_file"
        warning "No files will be changed"
        return 0
    fi

    # Confirm restore
    if [[ "$force" != "true" ]]; then
        warning "This will OVERWRITE /etc configuration"
        read -p "Are you sure? Type 'yes' to continue: " -r
        [[ ! "$REPLY" =~ ^[Yy][Ee][Ss]$ ]] && error "Restore cancelled"
    fi

    # Create safety backup before restore
    local safety_backup="/backup/configs/etc-safety-$(date +%Y%m%d-%H%M%S).tar.gz"
    mkdir -p /backup/configs
    info "Creating safety backup: $safety_backup"
    tar czf "$safety_backup" \
        --exclude="/etc/ssl/private" \
        /etc || warning "Safety backup failed"

    # Restore backup
    info "Restoring configuration..."
    if [[ "$backup_file" == *.tar.gz ]]; then
        tar xzf "$backup_file" -C / || error "Restore failed"
    else
        tar xf "$backup_file" -C / || error "Restore failed"
    fi

    success "Configuration restored from: $backup_file"
    info "Safety backup saved at: $safety_backup"
    warning "You may need to restart services for changes to take effect"
}

################################################################################
# Backup Management Functions
################################################################################

# List available backups
list_backups() {
    local backup_dir="${1:-$DEFAULT_BACKUP_DIR}"

    if [[ ! -d "$backup_dir" ]]; then
        error "Backup directory not found: $backup_dir"
    fi

    info "Available backups in: $backup_dir"

    if [[ -z "$(ls "$backup_dir"/etc-*.tar* 2>/dev/null)" ]]; then
        warning "No backups found"
        return 1
    fi

    # List backups with size and date
    echo ""
    echo "Backup File | Size | Date | Checksum Status"
    echo "------------|------|------|----------------"
    
    for backup in "$backup_dir"/etc-*.tar*; do
        [[ ! -f "$backup" ]] && continue
        
        local size=$(du -h "$backup" | cut -f1)
        local date=$(stat -c %y "$backup" | cut -d' ' -f1-2)
        
        if [[ -f "$backup.sha256" ]]; then
            local checksum="✓ Valid"
        else
            local checksum="? No checksum"
        fi
        
        printf "%-50s | %6s | %s | %s\n" \
            "$(basename $backup)" \
            "$size" \
            "$date" \
            "$checksum"
    done
    
    echo ""
    info "Total backups: $(ls "$backup_dir"/etc-*.tar* 2>/dev/null | wc -l)"
}

# Verify backup integrity
verify_backup() {
    local backup_file="$1"

    [[ ! -f "$backup_file" ]] && error "Backup file not found: $backup_file"

    info "Verifying backup: $backup_file"

    # Show file info
    echo "File size: $(du -h "$backup_file" | cut -f1)"
    echo "Modified: $(stat -c %y "$backup_file")"

    # Verify checksum
    if [[ -f "$backup_file.sha256" ]]; then
        info "Verifying checksum..."
        if sha256sum -c "$backup_file.sha256"; then
            success "Checksum valid - backup is intact"
        else
            error "Checksum failed - backup may be corrupted"
        fi
    else
        warning "No checksum file - cannot verify integrity"
    fi

    # List backup contents
    info "Backup contents preview:"
    if [[ "$backup_file" == *.tar.gz ]]; then
        tar tzf "$backup_file" | head -15
    else
        tar tf "$backup_file" | head -15
    fi
}

# Cleanup old backups
cleanup_backups() {
    local backup_dir="$1"
    local keep=7
    local delete_all=false

    require_root

    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --keep)
                shift
                keep="$1"
                ;;
            --delete-all)
                delete_all=true
                ;;
            *)
                warning "Unknown option: $1"
                ;;
        esac
        shift || true
    done

    [[ ! -d "$backup_dir" ]] && error "Backup directory not found: $backup_dir"

    info "Cleaning up backups in: $backup_dir"

    # Count backups
    local backup_count=$(ls "$backup_dir"/etc-*.tar* 2>/dev/null | wc -l)
    info "Found $backup_count backups"

    if [[ "$delete_all" == "true" ]]; then
        warning "DELETE_ALL requested - removing all backups"
        read -p "Type 'DELETE_ALL' to confirm: " -r
        if [[ "$REPLY" == "DELETE_ALL" ]]; then
            rm -f "$backup_dir"/etc-*.tar*
            rm -f "$backup_dir"/etc-*.sha256
            rm -f "$backup_dir"/etc-*.meta
            success "All backups deleted"
        else
            error "Cancelled"
        fi
    else
        info "Keeping latest $keep backups"

        # Get list of backups sorted by date (oldest first)
        local files_to_delete=$(ls -t "$backup_dir"/etc-*.tar* 2>/dev/null | tail -n +$((keep + 1)))

        if [[ -n "$files_to_delete" ]]; then
            echo "Files to delete:"
            echo "$files_to_delete"

            read -p "Continue? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "$files_to_delete" | while read -r file; do
                    rm -f "$file" "$file.sha256" "$file.meta"
                    info "Deleted: $(basename $file)"
                done
                success "Cleanup complete"
            else
                error "Cleanup cancelled"
            fi
        else
            info "Less than $keep backups exist - no cleanup needed"
        fi
    fi
}

################################################################################
# Main Function
################################################################################

main() {
    local command="${1:-help}"

    case "$command" in
        backup)
            shift || true
            backup_config /backup/configs "$@"
            ;;
        restore)
            shift || true
            [[ $# -lt 1 ]] && error "Backup file required"
            restore_config "$@"
            ;;
        list)
            shift || true
            list_backups "${1:-$DEFAULT_BACKUP_DIR}"
            ;;
        cleanup)
            shift || true
            [[ $# -lt 1 ]] && error "Backup directory required"
            cleanup_backups "$@"
            ;;
        verify)
            shift || true
            [[ $# -lt 1 ]] && error "Backup file required"
            verify_backup "$1"
            ;;
        version)
            echo "$SCRIPT_NAME version $SCRIPT_VERSION"
            ;;
        help|--help|-h)
            print_help
            ;;
        *)
            error "Unknown command: $command"
            ;;
    esac
}

main "$@"
