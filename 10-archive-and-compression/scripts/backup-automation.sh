#!/bin/bash

################################################################################
# backup-automation.sh
# Purpose: Automated backup with compression, rotation, and verification
# Version: 1.0
# Usage: sudo ./backup-automation.sh [options]
################################################################################

set -euo pipefail

# Configuration
SCRIPT_NAME="$(basename "$0")"
VERSION="1.0"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
RETENTION_DAYS=30
LOG_FILE="/var/log/backup-automation.log"
BACKUP_SOURCES=()
EXCLUDE_PATTERNS=()
COMPRESSION="gzip"
EMAIL_ON_ERROR=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Utility Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        ERROR)
            echo -e "${RED}✗ ERROR${NC}: $message" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}✓ SUCCESS${NC}: $message"
            ;;
        WARNING)
            echo -e "${YELLOW}⚠ WARNING${NC}: $message"
            ;;
        INFO)
            echo -e "${BLUE}ℹ INFO${NC}: $message"
            ;;
    esac
}

usage() {
    cat << EOF
${BLUE}Backup Automation v${VERSION}${NC}

Automated backup solution with compression, rotation, and verification.

${BLUE}USAGE:${NC}
    $SCRIPT_NAME [options]

${BLUE}OPTIONS:${NC}
    -s, --source DIR         Directory to backup (can be multiple)
    -b, --backup-dir DIR     Backup destination (default: /backup)
    -c, --compression TYPE   Compression format: gzip (default), bzip2, xz
    -r, --retention DAYS     Keep backups for N days (default: 30)
    -e, --exclude PATTERN    Exclude files matching pattern
    --full                   Force full backup
    --incremental            Create incremental backup
    --verify                 Verify backups after creation
    --dry-run                Show what would be done
    --help                   Display this help message
    --version                Show version

${BLUE}EXAMPLES:${NC}
    # Backup /home daily
    $SCRIPT_NAME -s /home -b /backup

    # Backup multiple directories
    $SCRIPT_NAME -s /home -s /etc -b /backup

    # Backup with exclusions
    $SCRIPT_NAME -s /home -b /backup --exclude='*.log' --exclude='.cache'

    # Keep backups for 60 days
    $SCRIPT_NAME -s /data -b /backup --retention 60

EOF
    exit 0
}

version() {
    echo "Backup Automation v$VERSION"
    exit 0
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log ERROR "This script requires root privileges"
        exit 1
    fi
}

ensure_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        chmod 700 "$BACKUP_DIR"
        log INFO "Created backup directory: $BACKUP_DIR"
    fi
}

get_timestamp_file() {
    echo "$BACKUP_DIR/.last-backup-timestamp"
}

is_incremental() {
    local timestamp_file=$(get_timestamp_file)
    [[ -f "$timestamp_file" ]]
}

get_backup_type() {
    if is_incremental; then
        echo "incremental"
    else
        echo "full"
    fi
}

generate_backup_name() {
    local backup_type="$1"
    local date=$(date +%Y%m%d-%H%M%S)
    echo "${backup_type}-backup-${date}.tar.gz"
}

################################################################################
# Backup Creation
################################################################################

create_backup() {
    local backup_type="${1:-auto}"
    local force_full="${2:-false}"
    
    ensure_backup_dir
    
    # Determine backup type
    if [[ "$backup_type" == "auto" ]]; then
        if [[ "$force_full" == "true" ]] || ! is_incremental; then
            backup_type="full"
        else
            backup_type="incremental"
        fi
    fi
    
    log INFO "Starting $backup_type backup"
    log INFO "Sources: ${BACKUP_SOURCES[@]}"
    
    # Generate backup filename
    local backup_name=$(generate_backup_name "$backup_type")
    local backup_file="$BACKUP_DIR/$backup_name"
    local temp_file="${backup_file}.tmp"
    
    # Build tar command
    local tar_opts="-czf"
    local tar_file="$temp_file"
    
    # Add exclusions
    local exclude_opts=()
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_opts+=("--exclude=$pattern")
    done
    
    # Build tar command
    local tar_cmd="tar $tar_opts $tar_file"
    
    # Add incremental marker if incremental
    if [[ "$backup_type" == "incremental" ]]; then
        local timestamp_file=$(get_timestamp_file)
        tar_cmd="$tar_cmd --newer-mtime-than=$timestamp_file"
    fi
    
    # Add exclusions and sources
    for pattern in "${exclude_opts[@]}"; do
        tar_cmd="$tar_cmd $pattern"
    done
    
    for source in "${BACKUP_SOURCES[@]}"; do
        tar_cmd="$tar_cmd $source"
    done
    
    # Execute backup
    log INFO "Creating backup: $backup_file"
    
    if eval "$tar_cmd" 2>/dev/null; then
        log SUCCESS "Backup created successfully"
    else
        log ERROR "Backup creation failed"
        rm -f "$temp_file"
        return 1
    fi
    
    # Move temp file to final location
    mv "$temp_file" "$backup_file"
    
    # Create checksum
    log INFO "Creating checksum..."
    cd "$BACKUP_DIR"
    sha256sum "$backup_name" > "$backup_name.sha256"
    cd - > /dev/null
    
    # Update timestamp file
    touch "$(get_timestamp_file)"
    
    # Get backup statistics
    local size=$(du -h "$backup_file" | awk '{print $1}')
    log SUCCESS "Backup completed: $backup_file ($size)"
    
    # Verify backup
    verify_backup "$backup_file"
    
    # Report statistics
    report_backup_stats
}

################################################################################
# Verification
################################################################################

verify_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        log ERROR "Backup file not found: $backup_file"
        return 1
    fi
    
    log INFO "Verifying backup: $(basename "$backup_file")"
    
    # Test tar integrity
    if tar -tzf "$backup_file" > /dev/null 2>&1; then
        log SUCCESS "Backup integrity verified"
    else
        log ERROR "Backup verification failed"
        return 1
    fi
    
    # Verify checksum
    local checksum_file="${backup_file}.sha256"
    if [[ -f "$checksum_file" ]]; then
        cd "$BACKUP_DIR"
        if sha256sum -c "$(basename "$checksum_file")" > /dev/null 2>&1; then
            log SUCCESS "Checksum verified"
        else
            log ERROR "Checksum verification failed"
            cd - > /dev/null
            return 1
        fi
        cd - > /dev/null
    fi
    
    return 0
}

verify_all_backups() {
    log INFO "Verifying all backups..."
    
    local failed=0
    for backup in "$BACKUP_DIR"/full-backup-*.tar.gz "$BACKUP_DIR"/incremental-backup-*.tar.gz; do
        [[ -f "$backup" ]] || continue
        
        if ! verify_backup "$backup"; then
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        log SUCCESS "All backups verified successfully"
        return 0
    else
        log ERROR "$failed backup(s) failed verification"
        return 1
    fi
}

################################################################################
# Retention and Cleanup
################################################################################

cleanup_old_backups() {
    log INFO "Cleaning up backups older than $RETENTION_DAYS days"
    
    local count=0
    while IFS= read -r file; do
        log WARNING "Removing old backup: $(basename "$file")"
        rm -f "$file" "${file}.sha256" "${file}.meta"
        ((count++))
    done < <(find "$BACKUP_DIR" -name "*-backup-*.tar.gz" -mtime +$RETENTION_DAYS)
    
    if [[ $count -gt 0 ]]; then
        log INFO "Removed $count old backup(s)"
    fi
}

list_backups() {
    log INFO "Available backups:"
    echo ""
    
    if ls "$BACKUP_DIR"/*-backup-*.tar.gz 1> /dev/null 2>&1; then
        ls -lh "$BACKUP_DIR"/*-backup-*.tar.gz | \
            awk '{print $5, $6, $7, $8, $9}' | \
            awk '{printf "%-8s %s %s %s\n", $1, $2" "$3, $4, $5}'
    else
        echo "No backups found"
    fi
    echo ""
}

################################################################################
# Reporting
################################################################################

report_backup_stats() {
    log INFO "Backup statistics:"
    
    echo ""
    echo "Total backup storage:"
    du -sh "$BACKUP_DIR"
    
    echo ""
    echo "Backup breakdown:"
    find "$BACKUP_DIR" -name "*-backup-*.tar.gz" -exec du -h {} \; | \
        awk '{sum += $1} END {print "  Total backups: " sum}' 2>/dev/null || true
    
    echo ""
    echo "Recent backups:"
    ls -lht "$BACKUP_DIR"/*-backup-*.tar.gz 2>/dev/null | head -3 | \
        awk '{print "  " $9, "(" $5 ")"}'
    
    echo ""
}

create_report() {
    local report_file="$BACKUP_DIR/backup-report-$(date +%Y%m%d).txt"
    
    {
        echo "Backup Report"
        echo "=============="
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Backup directory: $BACKUP_DIR"
        echo ""
        
        echo "Configuration:"
        echo "  Retention: $RETENTION_DAYS days"
        echo "  Compression: $COMPRESSION"
        echo "  Sources: ${BACKUP_SOURCES[@]}"
        echo ""
        
        echo "Backup Statistics:"
        du -sh "$BACKUP_DIR" | awk '{print "  Total storage: " $1}'
        echo "  Backup count: $(find "$BACKUP_DIR" -name "*-backup-*.tar.gz" | wc -l)"
        echo ""
        
        echo "Recent Backups:"
        ls -lht "$BACKUP_DIR"/*-backup-*.tar.gz 2>/dev/null | head -5 | \
            awk '{print "  " $9, "(" $5 ")"}'
        
    } > "$report_file"
    
    log INFO "Report created: $report_file"
}

################################################################################
# Main Execution
################################################################################

main() {
    local backup_type="auto"
    local force_full=false
    local do_verify=false
    local do_cleanup=true
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--source)
                BACKUP_SOURCES+=("$2")
                shift 2
                ;;
            -b|--backup-dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            -r|--retention)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            -e|--exclude)
                EXCLUDE_PATTERNS+=("$2")
                shift 2
                ;;
            --full)
                force_full=true
                shift
                ;;
            --incremental)
                backup_type="incremental"
                shift
                ;;
            --verify)
                do_verify=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --help|-h)
                usage
                ;;
            --version)
                version
                ;;
            *)
                log ERROR "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    # Validation
    check_root
    
    if [[ ${#BACKUP_SOURCES[@]} -eq 0 ]]; then
        log ERROR "At least one source directory required"
        usage
    fi
    
    # Verify sources exist
    for source in "${BACKUP_SOURCES[@]}"; do
        if [[ ! -d "$source" ]]; then
            log ERROR "Source directory not found: $source"
            exit 1
        fi
    done
    
    if [[ "$dry_run" == true ]]; then
        log INFO "DRY RUN MODE"
        log INFO "Would backup: ${BACKUP_SOURCES[@]}"
        log INFO "To: $BACKUP_DIR"
        return 0
    fi
    
    # Main backup process
    log INFO "=== Starting Backup Process ==="
    
    create_backup "$backup_type" "$force_full" || {
        log ERROR "Backup process failed"
        exit 1
    }
    
    if [[ "$do_verify" == true ]]; then
        verify_all_backups || {
            log ERROR "Verification failed"
            exit 1
        }
    fi
    
    if [[ "$do_cleanup" == true ]]; then
        cleanup_old_backups
    fi
    
    create_report
    
    list_backups
    
    log INFO "=== Backup Process Complete ==="
}

main "$@"
