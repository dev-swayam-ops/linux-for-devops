#!/bin/bash

################################################################################
# file-organizer.sh - Organize Files by Type into Subdirectories
################################################################################
#
# PURPOSE:
#   Automatically organize files in a directory by type (extension).
#   Creates subdirectories for different file types and moves files accordingly.
#
# USAGE:
#   ./file-organizer.sh              # Organize current directory
#   ./file-organizer.sh /path/to/dir # Organize specific directory
#   ./file-organizer.sh -h           # Show help
#
# EXAMPLES:
#   ./file-organizer.sh ~/Downloads  # Organize Downloads folder
#   ./file-organizer.sh .            # Organize current directory
#
# FILE CATEGORIES:
#   Documents:  *.pdf, *.doc, *.txt, *.docx, etc
#   Images:     *.jpg, *.png, *.gif, *.bmp, etc
#   Videos:     *.mp4, *.avi, *.mkv, etc
#   Audio:      *.mp3, *.flac, *.wav, etc
#   Archives:   *.zip, *.tar, *.rar, *.7z, etc
#   Other:      Everything else
#

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# File categories
declare -A CATEGORIES=(
    ["Documents"]="pdf doc docx txt xls xlsx ppt pptx odt ods csv"
    ["Images"]="jpg jpeg png gif bmp svg webp tiff ico"
    ["Videos"]="mp4 avi mkv mov flv wmv m4v"
    ["Audio"]="mp3 flac wav aac ogg wma"
    ["Archives"]="zip rar 7z tar gz bz2 xz"
)

TARGET_DIR="."
DRY_RUN=0
VERBOSE=0

################################################################################
# FUNCTIONS
################################################################################

show_help() {
    cat << EOF
${BLUE}${SCRIPT_NAME}${NC} - Organize Files by Type

${GREEN}USAGE:${NC}
    ${SCRIPT_NAME} [OPTIONS] [DIRECTORY]

${GREEN}OPTIONS:${NC}
    -d, --dir DIRECTORY    Target directory (default: current)
    --dry-run              Show what would be done, don't move files
    -v, --verbose          Show details for each file
    -h, --help             Show this help
    --version              Show version

${GREEN}EXAMPLES:${NC}
    # Organize current directory
    ${SCRIPT_NAME}

    # Organize specific folder
    ${SCRIPT_NAME} ~/Downloads

    # Preview what would be done
    ${SCRIPT_NAME} --dry-run ~/Downloads

${GREEN}CATEGORIES CREATED:${NC}
    Documents, Images, Videos, Audio, Archives, Other

${GREEN}SAFETY:${NC}
    • Use --dry-run to preview before running
    • Existing files with same name are skipped
    • Existing directories are used (not overwritten)

EOF
}

show_version() {
    echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
}

get_file_category() {
    local filename=$1
    local extension="${filename##*.}"
    
    # If no extension, go to Other
    if [ "$extension" = "$filename" ]; then
        echo "Other"
        return
    fi
    
    extension="${extension,,}"  # Convert to lowercase
    
    # Check each category
    for category in "${!CATEGORIES[@]}"; do
        for ext in ${CATEGORIES[$category]}; do
            if [ "$ext" = "$extension" ]; then
                echo "$category"
                return
            fi
        done
    done
    
    # If no match, return Other
    echo "Other"
}

organize_directory() {
    local dir="$1"
    local files_moved=0
    local files_skipped=0
    
    if [ ! -d "$dir" ]; then
        echo -e "${RED}Error: Directory not found: $dir${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Organizing: $dir${NC}\n"
    
    # Find all files (not directories) in the target directory (not subdirs)
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            local filename=$(basename "$file")
            local category=$(get_file_category "$filename")
            local category_dir="$dir/$category"
            
            if [ "$DRY_RUN" -eq 1 ]; then
                echo -e "${YELLOW}[DRY RUN]${NC} Would move: $filename → $category/"
                ((files_moved++))
            else
                # Create category directory if it doesn't exist
                if [ ! -d "$category_dir" ]; then
                    mkdir -p "$category_dir"
                    if [ "$VERBOSE" -eq 1 ]; then
                        echo -e "${GREEN}+${NC} Created directory: $category/"
                    fi
                fi
                
                # Move file to category directory
                if mv "$file" "$category_dir/$filename" 2>/dev/null; then
                    if [ "$VERBOSE" -eq 1 ]; then
                        echo -e "${GREEN}✓${NC} Moved: $filename → $category/"
                    fi
                    ((files_moved++))
                else
                    echo -e "${RED}✗${NC} Failed to move: $filename"
                    ((files_skipped++))
                fi
            fi
        fi
    done < <(find "$dir" -maxdepth 1 -type f -print0)
    
    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo -e "  Files moved: ${GREEN}$files_moved${NC}"
    if [ "$files_skipped" -gt 0 ]; then
        echo -e "  Files skipped: ${RED}$files_skipped${NC}"
    fi
}

################################################################################
# MAIN SCRIPT
################################################################################

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            TARGET_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --version)
            show_version
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Run the organization
organize_directory "$TARGET_DIR"

exit 0
