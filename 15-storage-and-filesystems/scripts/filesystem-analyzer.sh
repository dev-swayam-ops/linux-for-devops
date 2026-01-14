#!/bin/bash

################################################################################
# Filesystem Analyzer
# Detailed analysis of filesystem structure, usage patterns, and health
#
# Usage: ./filesystem-analyzer.sh [FILESYSTEM] [--detailed] [--csv]
# Examples:
#   ./filesystem-analyzer.sh /                # Analyze root filesystem
#   ./filesystem-analyzer.sh / --detailed     # Full analysis with file breakdown
#   ./filesystem-analyzer.sh /home --csv      # CSV output for /home
################################################################################

set -euo pipefail

# Configuration
OUTPUT_FORMAT="text"  # text, csv, json
DETAILED_MODE=0       # Show file-level breakdown
TARGET_FS="/"         # Target filesystem to analyze

# Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

################################################################################
# Utility Functions
################################################################################

print_header() {
    echo -e "${BOLD}${BLUE}=== $1 ===${NC}"
}

print_info() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

human_readable() {
    local bytes=$1
    if (( bytes >= 1073741824 )); then
        echo "$(( bytes / 1073741824 ))GB"
    elif (( bytes >= 1048576 )); then
        echo "$(( bytes / 1048576 ))MB"
    elif (( bytes >= 1024 )); then
        echo "$(( bytes / 1024 ))KB"
    else
        echo "${bytes}B"
    fi
}

################################################################################
# Filesystem Analysis
################################################################################

analyze_filesystem_info() {
    local fs="$1"
    print_header "Filesystem Information"
    
    local device=$(df "$fs" | awk 'NR==2 {print $1}')
    local type=$(df -T "$fs" | awk 'NR==2 {print $2}')
    local size=$(df "$fs" | awk 'NR==2 {print $2}')
    local used=$(df "$fs" | awk 'NR==2 {print $3}')
    local avail=$(df "$fs" | awk 'NR==2 {print $4}')
    
    echo "Mount Point:    $fs"
    echo "Device:         $device"
    echo "Filesystem:     $type"
    echo "Total Size:     $(human_readable $((size * 1024)))"
    echo "Used:           $(human_readable $((used * 1024)))"
    echo "Available:      $(human_readable $((avail * 1024)))"
    
    # Show mount options
    local mount_opts=$(mount | grep " on $fs " | awk -F'(' '{print $2}' | sed 's/)$//')
    echo "Mount Options:  $mount_opts"
    
    # Check filesystem type specific info
    case "$type" in
        ext4)
            echo -e "\n${BOLD}Ext4 Specifics:${NC}"
            tune2fs -l "$device" 2>/dev/null | grep -E "Filesystem state|Mount count|Last mount time|Last checked" | sed 's/^/  /'
            ;;
        xfs)
            echo -e "\n${BOLD}XFS Specifics:${NC}"
            xfs_info "$fs" 2>/dev/null | head -5 | sed 's/^/  /'
            ;;
        btrfs)
            echo -e "\n${BOLD}Btrfs Specifics:${NC}"
            btrfs filesystem show "$fs" 2>/dev/null | sed 's/^/  /'
            ;;
    esac
    echo ""
}

analyze_disk_space() {
    local fs="$1"
    print_header "Disk Space Analysis"
    
    echo "Top 15 Directories by Size:"
    echo "─────────────────────────────────────────────────────"
    
    du -hs "$fs"/* 2>/dev/null | sort -rh | head -15 | nl | \
        awk '{printf "%2d. %-40s %8s\n", $1, $2, $3}'
    
    echo ""
}

analyze_file_breakdown() {
    local fs="$1"
    print_header "File Type Analysis"
    
    echo "File Type Distribution:"
    echo "─────────────────────────────────────────────────────"
    
    find "$fs" -type f 2>/dev/null | \
    awk -F. '{if(NF>1) print $NF; else print "noext"}' | \
    sort | uniq -c | sort -rn | head -20 | \
    awk '{
        total += $1
        ext = $2
        for(i=3; i<=NF; i++) ext = ext " " $i
        printf "  %-15s %6d files\n", ext, $1
    }
    END {
        if(total > 0) printf "\n  Total files:    %6d\n", total
    }'
    
    echo ""
}

analyze_inode_usage() {
    local fs="$1"
    print_header "Inode Analysis"
    
    local device=$(df "$fs" | awk 'NR==2 {print $1}')
    local inodes_total=$(df -i "$fs" | awk 'NR==2 {print $2}')
    local inodes_used=$(df -i "$fs" | awk 'NR==2 {print $3}')
    local inodes_avail=$(df -i "$fs" | awk 'NR==2 {print $4}')
    local inodes_pct=$(df -i "$fs" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    echo "Inode Statistics:"
    echo "  Total Inodes:     $inodes_total"
    echo "  Used Inodes:      $inodes_used"
    echo "  Available:        $inodes_avail"
    echo "  Usage:            ${inodes_pct}%"
    
    # Show progress bar
    local bar_length=30
    local filled=$(( (inodes_pct * bar_length) / 100 ))
    local empty=$(( bar_length - filled ))
    printf "  Progress:         ["
    printf "%-${filled}s" "=" | tr ' ' '='
    printf "%-${empty}s" " "
    echo "]"
    
    if (( inodes_pct >= 85 )); then
        print_warning "High inode usage detected!"
    fi
    
    # Find directories with most files
    if (( DETAILED_MODE == 1 )); then
        echo ""
        echo "Directories with Most Files:"
        find "$fs" -type d 2>/dev/null -print0 | xargs -0 -I {} sh -c 'echo "$(find {} -maxdepth 1 -type f 2>/dev/null | wc -l) {}"' 2>/dev/null | \
            sort -rn | head -10 | \
            awk '{printf "  %-60s %6d files\n", $2, $1}'
    fi
    
    echo ""
}

analyze_permissions() {
    local fs="$1"
    print_header "Permission Analysis"
    
    echo "SUID/SGID Files (potential security issue):"
    echo "─────────────────────────────────────────────────────"
    find "$fs" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | head -20 | \
        sed 's/^/  /'
    
    if (( $(find "$fs" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | wc -l) > 20 )); then
        echo "  ... and more"
    fi
    
    echo ""
    echo "World-Writable Directories (check for security):"
    echo "─────────────────────────────────────────────────────"
    find "$fs" -type d -perm -002 2>/dev/null | head -20 | \
        sed 's/^/  /'
    
    echo ""
}

analyze_symlinks_hardlinks() {
    local fs="$1"
    print_header "Link Analysis"
    
    local symlink_count=$(find "$fs" -type l 2>/dev/null | wc -l)
    local hardlink_count=$(find "$fs" -type f 2>/dev/null -links +1 | wc -l)
    
    echo "Symbolic Links:   $symlink_count"
    echo "Hard Links (2+):  $hardlink_count"
    
    if (( symlink_count > 100 )); then
        echo ""
        echo "Top 10 Symlinked Locations:"
        find "$fs" -type l 2>/dev/null -exec dirname {} \; | sort | uniq -c | sort -rn | head -10 | \
            awk '{printf "  %6d links in %s\n", $1, substr($0, 8)}'
    fi
    
    echo ""
}

analyze_filesystem_health() {
    local fs="$1"
    local device=$(df "$fs" | awk 'NR==2 {print $1}')
    
    print_header "Filesystem Health"
    
    case "$device" in
        /dev/*)
            # Get filesystem type
            local fstype=$(df -T "$fs" | awk 'NR==2 {print $2}')
            
            case "$fstype" in
                ext4)
                    echo "Running ext4 checks..."
                    sudo tune2fs -l "$device" 2>/dev/null | grep -E "Filesystem state|errors|Last checked" | sed 's/^/  /'
                    
                    if command -v e4defrag &>/dev/null; then
                        local fragmentation=$(sudo e4defrag -c "$fs" 2>/dev/null | tail -1)
                        echo "  $fragmentation"
                    fi
                    ;;
                xfs)
                    echo "Running XFS checks..."
                    xfs_info "$fs" 2>/dev/null | sed 's/^/  /'
                    ;;
                *)
                    echo "Filesystem type: $fstype (specific checks not available)"
                    ;;
            esac
            ;;
        *)
            echo "Virtual filesystem: $device (no health checks available)"
            ;;
    esac
    
    echo ""
}

analyze_empty_files() {
    local fs="$1"
    print_header "Empty Files and Directories"
    
    local empty_files=$(find "$fs" -type f -size 0 2>/dev/null | wc -l)
    local empty_dirs=$(find "$fs" -type d -empty 2>/dev/null | wc -l)
    
    echo "Empty Files:        $empty_files"
    echo "Empty Directories:  $empty_dirs"
    
    if (( empty_files > 100 )); then
        print_warning "Found $empty_files empty files - consider cleanup"
    fi
    
    if (( DETAILED_MODE == 1 )) && (( empty_files > 0 )); then
        echo ""
        echo "Sample Empty Files:"
        find "$fs" -type f -size 0 2>/dev/null | head -20 | sed 's/^/  /'
    fi
    
    echo ""
}

################################################################################
# Output Formats
################################################################################

output_csv() {
    local fs="$1"
    
    echo "Category,Item,Value"
    
    local device=$(df "$fs" | awk 'NR==2 {print $1}')
    local type=$(df -T "$fs" | awk 'NR==2 {print $2}')
    local used=$(df "$fs" | awk 'NR==2 {print $3 * 1024}')
    local avail=$(df "$fs" | awk 'NR==2 {print $4 * 1024}')
    local inodes_used=$(df -i "$fs" | awk 'NR==2 {print $3}')
    local inodes_avail=$(df -i "$fs" | awk 'NR==2 {print $4}')
    
    echo "Filesystem,Device,$device"
    echo "Filesystem,Type,$type"
    echo "Usage,Used (bytes),$used"
    echo "Usage,Available (bytes),$avail"
    echo "Inodes,Used,$inodes_used"
    echo "Inodes,Available,$inodes_avail"
    
    find "$fs" -type f 2>/dev/null | \
    awk -F. '{if(NF>1) print $NF; else print "noext"}' | \
    sort | uniq -c | sort -rn | head -20 | \
    awk '{print "FileTypes," $2 "," $1}'
}

################################################################################
# Help Function
################################################################################

show_help() {
    cat << EOF
Filesystem Analyzer - Detailed filesystem analysis and reporting

Usage: $(basename "$0") [OPTIONS] [FILESYSTEM]

Arguments:
  FILESYSTEM        Target filesystem to analyze (default: /)

Options:
  --detailed        Show detailed file breakdown
  --csv             Output in CSV format
  --help            Show this help message

Examples:
  $(basename "$0")                    # Analyze root filesystem
  $(basename "$0") /home              # Analyze /home
  $(basename "$0") /home --detailed   # Detailed analysis
  $(basename "$0") / --csv            # CSV output

Output Sections:
  - Filesystem Information (device, type, mount options)
  - Disk Space (top directories)
  - File Type Breakdown (extensions)
  - Inode Analysis (current usage)
  - Permission Analysis (SUID, world-writable)
  - Link Analysis (symlinks, hardlinks)
  - Filesystem Health (fsck info, fragmentation)
  - Empty Files (unused space cleanup opportunities)

Requirements:
  - Read access to target filesystem
  - Basic utilities: df, du, find, tune2fs

EOF
}

################################################################################
# Main
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --detailed)
                DETAILED_MODE=1
                shift
                ;;
            --csv)
                OUTPUT_FORMAT="csv"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            /*)
                TARGET_FS="$1"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate filesystem exists
    if ! [[ -d "$TARGET_FS" ]]; then
        print_error "Filesystem not found: $TARGET_FS"
        exit 1
    fi
    
    # Output analysis
    case "$OUTPUT_FORMAT" in
        csv)
            output_csv "$TARGET_FS"
            ;;
        *)
            echo ""
            echo -e "${BOLD}FILESYSTEM ANALYSIS REPORT${NC}"
            echo "Target: $TARGET_FS | Generated: $(date '+%Y-%m-%d %H:%M:%S')"
            echo ""
            
            analyze_filesystem_info "$TARGET_FS"
            analyze_disk_space "$TARGET_FS"
            
            if (( DETAILED_MODE == 1 )); then
                analyze_file_breakdown "$TARGET_FS"
            fi
            
            analyze_inode_usage "$TARGET_FS"
            analyze_permissions "$TARGET_FS"
            analyze_symlinks_hardlinks "$TARGET_FS"
            analyze_empty_files "$TARGET_FS"
            analyze_filesystem_health "$TARGET_FS"
            
            echo -e "${BOLD}Analysis Complete${NC}"
            echo ""
            ;;
    esac
}

# Run if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
