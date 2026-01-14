#!/bin/bash
# Simple Backup Script
# Purpose: Automated backup with validation, rotation, and logging
# Usage: ./simple-backup.sh --source /path/to/backup [--dest /path/to/store] [--retention 7]
# Features: Error handling, validation, rotation, logging, dry-run mode

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directories
BACKUP_SOURCE=""
BACKUP_DEST="${SCRIPT_DIR}/../backups"
LOG_DIR="${SCRIPT_DIR}/../logs"
TEMP_DIR="/tmp/backup-$$"

# Backup settings
RETENTION_DAYS=7
COMPRESS=true
DRY_RUN=false
VERBOSE=false

# Logging
LOG_FILE=""
BACKUP_MANIFEST=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

# Log with timestamp
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓]${NC} $message"
            ;;
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Error and exit
error() {
    log ERROR "$@"
    cleanup
    exit 1
}

# Info message
info() {
    if [[ "$VERBOSE" == true ]]; then
        log INFO "$@"
    else
        echo -e "${BLUE}[INFO]${NC} $@"
    fi
}

# Success message
success() {
    log SUCCESS "$@"
}

# Warning message
warn() {
    log WARN "$@"
}

# ============================================================================
# HELP AND USAGE
# ============================================================================

show_help() {
    cat << EOF
${BLUE}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
Automated backup script with rotation and logging

${BLUE}USAGE${NC}
    $SCRIPT_NAME --source SOURCE [OPTIONS]

${BLUE}REQUIRED${NC}
    --source SOURCE          Directory to backup

${BLUE}OPTIONS${NC}
    --dest DEST              Backup destination (default: ../backups)
    --retention DAYS         Keep backups for N days (default: 7)
    --no-compress            Don't compress backup (store uncompressed)
    --dry-run                Show what would be backed up
    --verbose                Show detailed output
    --help                   Show this help message

${BLUE}EXAMPLES${NC}
    # Basic backup
    $SCRIPT_NAME --source /home/user

    # Backup with 14-day retention
    $SCRIPT_NAME --source /var/www --retention 14

    # Dry run to test
    $SCRIPT_NAME --source /data --dry-run

    # Custom destination
    $SCRIPT_NAME --source /config --dest /mnt/backup

${BLUE}FEATURES${NC}
    • Automated backup with compression
    • Automatic cleanup of old backups
    • Comprehensive error handling
    • Backup validation and checksums
    • Detailed logging
    • Dry-run mode for testing
    • Backup manifest with file listing

EOF
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source)
                BACKUP_SOURCE="$2"
                shift 2
                ;;
            --dest)
                BACKUP_DEST="$2"
                shift 2
                ;;
            --retention)
                RETENTION_DAYS="$2"
                shift 2
                ;;
            --no-compress)
                COMPRESS=false
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# ============================================================================
# VALIDATION
# ============================================================================

validate_environment() {
    # Check source
    if [[ -z "$BACKUP_SOURCE" ]]; then
        error "No source directory specified (use --source)"
    fi
    
    if [[ ! -d "$BACKUP_SOURCE" ]]; then
        error "Source directory not found: $BACKUP_SOURCE"
    fi
    
    if [[ ! -r "$BACKUP_SOURCE" ]]; then
        error "Source directory not readable: $BACKUP_SOURCE"
    fi
    
    # Validate retention
    if ! [[ "$RETENTION_DAYS" =~ ^[0-9]+$ ]]; then
        error "Invalid retention days: $RETENTION_DAYS"
    fi
    
    # Get absolute paths
    BACKUP_SOURCE="$(cd "$BACKUP_SOURCE" && pwd)"
    BACKUP_DEST="$(mkdir -p "$BACKUP_DEST" && cd "$BACKUP_DEST" && pwd)"
    LOG_DIR="$(mkdir -p "$LOG_DIR" && cd "$LOG_DIR" && pwd)"
}

validate_dependencies() {
    local required_cmds=("tar" "find" "du")
    
    if [[ "$COMPRESS" == true ]]; then
        required_cmds+=("gzip")
    fi
    
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Required command not found: $cmd"
        fi
    done
}

# ============================================================================
# BACKUP OPERATIONS
# ============================================================================

initialize_backup() {
    LOG_FILE="$LOG_DIR/backup-$(date +%Y%m%d).log"
    
    info "=========================================="
    info "Backup Process Started"
    info "=========================================="
    info "Source:      $BACKUP_SOURCE"
    info "Destination: $BACKUP_DEST"
    info "Retention:   $RETENTION_DAYS days"
    info "Compression: $COMPRESS"
    info "Dry-run:     $DRY_RUN"
    info "=========================================="
}

create_backup() {
    local backup_timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_name="backup-$(basename "$BACKUP_SOURCE")-$backup_timestamp"
    local backup_dir="$BACKUP_DEST/$backup_name"
    local backup_file=""
    local source_name=$(basename "$BACKUP_SOURCE")
    
    if [[ "$COMPRESS" == true ]]; then
        backup_file="$backup_dir/data.tar.gz"
    else
        backup_file="$backup_dir/data.tar"
    fi
    
    BACKUP_MANIFEST="$backup_dir/manifest.txt"
    
    # Dry-run mode
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would create: $backup_name"
        
        local file_count=$(find "$BACKUP_SOURCE" -type f | wc -l)
        local total_size=$(du -sh "$BACKUP_SOURCE" | cut -f1)
        
        info "[DRY-RUN] Files: $file_count"
        info "[DRY-RUN] Size: $total_size"
        return 0
    fi
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    info "Creating backup: $backup_name"
    
    # Create tar backup with progress (if available)
    if tar -czf "$backup_file" -C "$BACKUP_DEST/.." "$source_name" 2>/dev/null; then
        local backup_size=$(du -h "$backup_file" | cut -f1)
        success "Backup created: $backup_size"
        
        # Create manifest
        create_manifest "$backup_dir" "$backup_file"
        
        # Verify backup
        verify_backup "$backup_file"
        
        return 0
    else
        error "Failed to create backup"
    fi
}

create_manifest() {
    local backup_dir="$1"
    local backup_file="$2"
    
    {
        echo "Backup Manifest"
        echo "================"
        echo ""
        echo "Backup Name:  $(basename "$backup_dir")"
        echo "Created:      $(date)"
        echo "Source:       $BACKUP_SOURCE"
        echo ""
        echo "Archive Information:"
        echo "  File:       $(basename "$backup_file")"
        echo "  Size:       $(du -h "$backup_file" | cut -f1)"
        echo "  MD5:        $(md5sum "$backup_file" | cut -d' ' -f1)"
        echo ""
        echo "Source Statistics:"
        echo "  Files:      $(find "$BACKUP_SOURCE" -type f | wc -l)"
        echo "  Directories: $(find "$BACKUP_SOURCE" -type d | wc -l)"
        echo "  Total Size: $(du -sh "$BACKUP_SOURCE" | cut -f1)"
        echo ""
        echo "File Listing (first 100):"
        echo "=========================="
        find "$BACKUP_SOURCE" -type f | head -100 | sort
    } > "$BACKUP_MANIFEST"
    
    info "Manifest created: $(basename "$BACKUP_MANIFEST")"
}

verify_backup() {
    local backup_file="$1"
    
    if [[ ! -f "$backup_file" ]]; then
        error "Backup file not found: $backup_file"
    fi
    
    info "Verifying backup integrity..."
    
    # Try to list archive contents (checks if valid)
    if tar -tzf "$backup_file" > /dev/null 2>&1; then
        success "Backup verified: Archive is valid"
        return 0
    else
        error "Backup verification failed: Archive may be corrupted"
    fi
}

# ============================================================================
# RETENTION MANAGEMENT
# ============================================================================

cleanup_old_backups() {
    local cutoff_time=$(date -d "$RETENTION_DAYS days ago" +%s 2>/dev/null || date -v-${RETENTION_DAYS}d +%s)
    
    if [[ ! -d "$BACKUP_DEST" ]]; then
        return 0
    fi
    
    info "Cleaning up backups older than $RETENTION_DAYS days"
    
    local removed_count=0
    local removed_size=0
    
    for backup_dir in "$BACKUP_DEST"/backup-*; do
        if [[ ! -d "$backup_dir" ]]; then
            continue
        fi
        
        # Get directory modification time
        local dir_time=$(stat -c %Y "$backup_dir" 2>/dev/null || stat -f %m "$backup_dir" 2>/dev/null)
        
        if (( dir_time < cutoff_time )); then
            local dir_size=$(du -sh "$backup_dir" | cut -f1)
            
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] Would remove: $(basename "$backup_dir") ($dir_size)"
            else
                info "Removing old backup: $(basename "$backup_dir") ($dir_size)"
                rm -rf "$backup_dir"
                (( removed_count++ )) || true
            fi
        fi
    done
    
    if [[ $removed_count -gt 0 ]]; then
        success "Removed $removed_count old backup(s)"
    fi
}

# ============================================================================
# REPORTING
# ============================================================================

show_backup_status() {
    if [[ ! -d "$BACKUP_DEST" ]]; then
        info "No backups found"
        return 0
    fi
    
    info "=========================================="
    info "Backup Status Report"
    info "=========================================="
    
    local total_size=$(du -sh "$BACKUP_DEST" 2>/dev/null | cut -f1 || echo "0")
    local backup_count=$(find "$BACKUP_DEST" -maxdepth 1 -type d -name "backup-*" | wc -l)
    
    info "Total backups: $backup_count"
    info "Total storage: $total_size"
    info ""
    info "Recent backups:"
    
    find "$BACKUP_DEST" -maxdepth 1 -type d -name "backup-*" -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | \
        head -5 | \
        while read -r timestamp path; do
            local size=$(du -sh "$path" | cut -f1)
            local name=$(basename "$path")
            info "  • $name ($size)"
        done
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Trap signals
trap cleanup EXIT
trap 'error "Script interrupted"' INT TERM

# ============================================================================
# MAIN
# ============================================================================

main() {
    parse_arguments "$@"
    validate_environment
    validate_dependencies
    initialize_backup
    
    create_backup
    cleanup_old_backups
    show_backup_status
    
    info "=========================================="
    success "Backup process completed successfully"
    info "=========================================="
}

main "$@"
