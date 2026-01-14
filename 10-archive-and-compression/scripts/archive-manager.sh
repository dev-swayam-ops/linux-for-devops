#!/bin/bash

################################################################################
# archive-manager.sh
# Purpose: Comprehensive archive creation, extraction, verification, and management
# Version: 1.0
# Usage: sudo ./archive-manager.sh [command] [options]
################################################################################

set -euo pipefail

# Configuration
SCRIPT_NAME="$(basename "$0")"
VERSION="1.0"
ARCHIVE_DIR="${ARCHIVE_DIR:-.}"
COMPRESSION_LEVEL=6
DEFAULT_COMPRESSION="gzip"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
LOG_FILE="/var/log/archive-manager.log"

################################################################################
# Utility Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
    
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
${BLUE}Archive Manager v${VERSION}${NC}

A comprehensive tool for creating, extracting, and managing archives with multiple compression formats.

${BLUE}USAGE:${NC}
    $SCRIPT_NAME [command] [options]

${BLUE}COMMANDS:${NC}
    create          Create archive from source directory
    extract         Extract archive to destination
    list            List contents of archive
    verify          Verify archive integrity
    compare         Compare two archives
    convert         Convert between compression formats
    info            Show archive information
    help            Display this help message
    version         Show version information

${BLUE}CREATE OPTIONS:${NC}
    -s, --source DIR         Source directory to archive
    -d, --dest FILE          Destination archive file
    -c, --compression TYPE   Compression format: gzip (default), bzip2, xz, zip
    -l, --level NUM          Compression level (1-9, default: 6)
    --exclude PATTERN        Exclude files matching pattern
    --exclude-from FILE      Read exclusions from file
    --verbose                Show progress

${BLUE}EXTRACT OPTIONS:${NC}
    -f, --file ARCHIVE       Archive file to extract
    -d, --dest DIR           Destination directory
    --verbose                Show progress
    --dry-run                Show what would be extracted

${BLUE}EXAMPLES:${NC}
    # Create gzip archive
    $SCRIPT_NAME create -s /home -d backup.tar.gz

    # Create with exclusions
    $SCRIPT_NAME create -s /data -d backup.tar.gz --exclude='*.log' --exclude='.git'

    # Extract archive
    $SCRIPT_NAME extract -f backup.tar.gz -d /restore

    # List contents
    $SCRIPT_NAME list -f backup.tar.gz

    # Verify integrity
    $SCRIPT_NAME verify -f backup.tar.gz

EOF
    exit 0
}

version() {
    echo "Archive Manager v$VERSION"
    echo "Copyright 2024"
    exit 0
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log ERROR "This script requires root privileges"
        exit 1
    fi
}

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log ERROR "Required command not found: $cmd"
        exit 1
    fi
}

get_compression_ext() {
    local compression="$1"
    case "$compression" in
        gzip)
            echo "gz"
            ;;
        bzip2)
            echo "bz2"
            ;;
        xz)
            echo "xz"
            ;;
        zip)
            echo "zip"
            ;;
        *)
            echo "gz"
            ;;
    esac
}

get_tar_option() {
    local compression="$1"
    case "$compression" in
        gzip)
            echo "z"
            ;;
        bzip2)
            echo "j"
            ;;
        xz)
            echo "J"
            ;;
        *)
            echo "z"
            ;;
    esac
}

################################################################################
# Create Archive
################################################################################

create_archive() {
    local source=""
    local dest=""
    local compression="$DEFAULT_COMPRESSION"
    local level=$COMPRESSION_LEVEL
    local exclude_patterns=()
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--source)
                source="$2"
                shift 2
                ;;
            -d|--dest)
                dest="$2"
                shift 2
                ;;
            -c|--compression)
                compression="$2"
                shift 2
                ;;
            -l|--level)
                level="$2"
                shift 2
                ;;
            --exclude)
                exclude_patterns+=("--exclude=$2")
                shift 2
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                log ERROR "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Validation
    if [[ -z "$source" ]] || [[ -z "$dest" ]]; then
        log ERROR "Source and destination required"
        exit 1
    fi
    
    if [[ ! -d "$source" ]]; then
        log ERROR "Source directory not found: $source"
        exit 1
    fi
    
    log INFO "Creating archive: $dest"
    log INFO "Source: $source"
    log INFO "Compression: $compression (level $level)"
    
    # Prepare tar options
    local tar_opts="-c"
    local tar_comp_opt=$(get_tar_option "$compression")
    
    if [[ -n "$tar_comp_opt" ]]; then
        tar_opts="${tar_opts}${tar_comp_opt}"
    fi
    
    tar_opts="$tar_opts f $dest"
    
    if [[ "$verbose" == true ]]; then
        tar_opts="${tar_opts}v"
    fi
    
    # Create archive with exclusions
    if [[ "${#exclude_patterns[@]}" -gt 0 ]]; then
        eval "tar $tar_opts ${exclude_patterns[@]} '$source'" || {
            log ERROR "Archive creation failed"
            exit 1
        }
    else
        tar $tar_opts "$source" || {
            log ERROR "Archive creation failed"
            exit 1
        }
    fi
    
    local size=$(du -h "$dest" | awk '{print $1}')
    local orig_size=$(du -sh "$source" | awk '{print $1}')
    
    log SUCCESS "Archive created: $dest ($size)"
    log INFO "Original size: $orig_size"
    
    # Create checksum
    sha256sum "$dest" > "$dest.sha256"
    log INFO "Checksum created: $dest.sha256"
}

################################################################################
# Extract Archive
################################################################################

extract_archive() {
    local archive=""
    local dest="."
    local verbose=false
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)
                archive="$2"
                shift 2
                ;;
            -d|--dest)
                dest="$2"
                shift 2
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                log ERROR "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Validation
    if [[ -z "$archive" ]]; then
        log ERROR "Archive file required"
        exit 1
    fi
    
    if [[ ! -f "$archive" ]]; then
        log ERROR "Archive not found: $archive"
        exit 1
    fi
    
    # Verify first
    log INFO "Verifying archive..."
    tar -tzf "$archive" > /dev/null 2>&1 || {
        log ERROR "Archive verification failed"
        exit 1
    }
    
    if [[ "$dry_run" == true ]]; then
        log INFO "Dry-run mode: Would extract to $dest"
        tar -tzf "$archive" | head -10
        return 0
    fi
    
    # Create destination if needed
    mkdir -p "$dest"
    
    log INFO "Extracting archive: $archive"
    log INFO "Destination: $dest"
    
    # Extract
    local tar_opts="x"
    if [[ "$verbose" == true ]]; then
        tar_opts="${tar_opts}v"
    fi
    tar_opts="${tar_opts}f $archive -C $dest"
    
    tar $tar_opts || {
        log ERROR "Extraction failed"
        exit 1
    }
    
    log SUCCESS "Archive extracted successfully"
}

################################################################################
# List Archive Contents
################################################################################

list_archive() {
    local archive=""
    local verbose=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)
                archive="$2"
                shift 2
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                log ERROR "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$archive" ]]; then
        log ERROR "Archive file required"
        exit 1
    fi
    
    if [[ ! -f "$archive" ]]; then
        log ERROR "Archive not found: $archive"
        exit 1
    fi
    
    if [[ "$verbose" == true ]]; then
        tar -tzvf "$archive"
    else
        tar -tzf "$archive"
    fi
}

################################################################################
# Verify Archive
################################################################################

verify_archive() {
    local archive=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)
                archive="$2"
                shift 2
                ;;
            *)
                log ERROR "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$archive" ]]; then
        log ERROR "Archive file required"
        exit 1
    fi
    
    if [[ ! -f "$archive" ]]; then
        log ERROR "Archive not found: $archive"
        exit 1
    fi
    
    log INFO "Verifying archive: $archive"
    
    # Test tar integrity
    if tar -tzf "$archive" > /dev/null 2>&1; then
        log SUCCESS "Archive integrity verified"
    else
        log ERROR "Archive verification failed"
        exit 1
    fi
    
    # Check checksum if exists
    if [[ -f "$archive.sha256" ]]; then
        log INFO "Verifying checksum..."
        if sha256sum -c "$archive.sha256" > /dev/null 2>&1; then
            log SUCCESS "Checksum verified"
        else
            log ERROR "Checksum verification failed"
            exit 1
        fi
    fi
}

################################################################################
# Compare Archives
################################################################################

compare_archives() {
    local archive1=""
    local archive2=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)
                archive1="$2"
                shift 2
                ;;
            -g|--with)
                archive2="$2"
                shift 2
                ;;
            *)
                log ERROR "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$archive1" ]] || [[ -z "$archive2" ]]; then
        log ERROR "Two archive files required"
        exit 1
    fi
    
    log INFO "Comparing archives..."
    
    # Extract and compare
    mkdir -p /tmp/compare-1 /tmp/compare-2
    
    tar -xzf "$archive1" -C /tmp/compare-1
    tar -xzf "$archive2" -C /tmp/compare-2
    
    diff -r /tmp/compare-1 /tmp/compare-2 || true
    
    rm -rf /tmp/compare-1 /tmp/compare-2
}

################################################################################
# Show Archive Info
################################################################################

show_info() {
    local archive=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--file)
                archive="$2"
                shift 2
                ;;
            *)
                log ERROR "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    if [[ -z "$archive" ]]; then
        log ERROR "Archive file required"
        exit 1
    fi
    
    if [[ ! -f "$archive" ]]; then
        log ERROR "Archive not found: $archive"
        exit 1
    fi
    
    echo ""
    echo "Archive Information"
    echo "===================="
    echo "File: $archive"
    echo "Size: $(du -h "$archive" | awk '{print $1}')"
    echo "Created: $(date -r "$archive" '+%Y-%m-%d %H:%M:%S')"
    echo "Files: $(tar -tzf "$archive" | wc -l)"
    echo "Directories: $(tar -tzf "$archive" | grep '/$' | wc -l)"
    echo ""
    
    if [[ -f "$archive.sha256" ]]; then
        echo "Checksum: $(cat "$archive.sha256" | awk '{print $1}')"
    fi
    echo ""
}

################################################################################
# Main
################################################################################

main() {
    if [[ $# -eq 0 ]]; then
        usage
    fi
    
    local command="$1"
    shift || true
    
    case "$command" in
        create)
            create_archive "$@"
            ;;
        extract)
            extract_archive "$@"
            ;;
        list)
            list_archive "$@"
            ;;
        verify)
            verify_archive "$@"
            ;;
        compare)
            compare_archives "$@"
            ;;
        info)
            show_info "$@"
            ;;
        help|-h|--help)
            usage
            ;;
        version|--version)
            version
            ;;
        *)
            log ERROR "Unknown command: $command"
            usage
            ;;
    esac
}

main "$@"
