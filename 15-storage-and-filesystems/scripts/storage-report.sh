#!/bin/bash

################################################################################
# Storage Report Generator
# Generate comprehensive storage utilization reports
#
# Usage: ./storage-report.sh [--format TEXT|HTML|JSON] [--output FILE]
# Examples:
#   ./storage-report.sh                          # Text to stdout
#   ./storage-report.sh --format HTML --output report.html  # HTML file
#   ./storage-report.sh --format JSON > storage.json         # JSON
################################################################################

set -euo pipefail

# Configuration
REPORT_FORMAT="text"  # text, html, json
OUTPUT_FILE=""        # Empty = stdout
INCLUDE_TRENDS=1      # Include trend analysis
HISTORICAL_DATA="/var/log/storage-history.txt"
SNAPSHOT_FILE="/tmp/storage-snapshot-$(date +%s).txt"

################################################################################
# Data Collection
################################################################################

collect_storage_data() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    {
        echo "### STORAGE SNAPSHOT - $timestamp ###"
        echo ""
        echo "=== DISK USAGE ==="
        df -h | tail -n +2
        echo ""
        echo "=== INODE USAGE ==="
        df -i | tail -n +2
        echo ""
        echo "=== MOUNTED FILESYSTEMS ==="
        mount | grep -E "^/dev" | awk '{print $1, $3, $5}'
        echo ""
        echo "=== PARTITION TYPES ==="
        lsblk -o NAME,SIZE,TYPE,FSTYPE
        echo ""
    } | tee "$SNAPSHOT_FILE"
}

get_top_directories() {
    local fs="${1:-.}"
    du -hs "$fs"/* 2>/dev/null | sort -rh | head -10
}

get_filesystem_types() {
    df -T | grep -E "^/dev" | awk '{print $2}' | sort | uniq -c
}

get_disk_io_stats() {
    if command -v iostat &>/dev/null; then
        iostat -x 1 2 | tail -n +4
    else
        echo "iostat not available"
    fi
}

################################################################################
# TEXT FORMAT
################################################################################

generate_text_report() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                        STORAGE UTILIZATION REPORT                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF
    
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Hostname:  $(hostname)"
    echo ""
    
    # Disk Usage Summary
    echo "┌─ DISK SPACE SUMMARY ─────────────────────────────────────────────┐"
    echo "│"
    df -h | awk 'NR==1 {next} NR>1 {
        device=$1; size=$2; used=$3; avail=$4; pct=$5
        pct_num=substr(pct,1,length(pct)-1)
        printf "│ %-20s %8s used / %8s total (%3s)  ", device, used, size, pct
        
        # Simple bar chart
        bar_len=15
        filled=int((pct_num/100)*bar_len)
        for(i=0; i<filled; i++) printf "█"
        for(i=filled; i<bar_len; i++) printf "░"
        printf "\n"
    }'
    echo "│"
    echo "└──────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Inode Usage
    echo "┌─ INODE USAGE ────────────────────────────────────────────────────┐"
    echo "│"
    df -i | awk 'NR==1 {next} NR>1 {
        device=$1; total=$2; used=$3; avail=$4; pct=$5
        printf "│ %-20s %8s / %8s inodes (%3s)\n", device, used, total, pct
    }'
    echo "│"
    echo "└──────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Top Directories
    echo "┌─ LARGEST DIRECTORIES ────────────────────────────────────────────┐"
    for mount_point in $(mount | grep -E '^/dev' | awk '{print $3}'); do
        if [[ -r "$mount_point" ]]; then
            echo "│"
            echo "│ On $mount_point:"
            du -hs "$mount_point"/* 2>/dev/null | sort -rh | head -5 | \
                awk '{printf "│   %-50s %8s\n", $2, $1}'
        fi
    done
    echo "│"
    echo "└──────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Filesystem Types
    echo "┌─ FILESYSTEM TYPE DISTRIBUTION ───────────────────────────────────┐"
    echo "│"
    df -T | grep -E "^/dev" | awk '{print $2}' | sort | uniq -c | \
        awk '{printf "│ %-30s %3d filesystems\n", $2, $1}'
    echo "│"
    echo "└──────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Block Device Summary
    echo "┌─ BLOCK DEVICES ──────────────────────────────────────────────────┐"
    echo "│"
    lsblk -o NAME,SIZE,TYPE,FSTYPE 2>/dev/null | awk 'NR>1 {
        printf "│ %-20s %-10s %-8s %s\n", $1, $2, $3, $4
    }'
    echo "│"
    echo "└──────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Recommendations
    echo "┌─ RECOMMENDATIONS ────────────────────────────────────────────────┐"
    echo "│"
    
    local high_usage=0
    local high_inodes=0
    
    df -h | awk 'NR>1 {
        pct=substr($5,1,length($5)-1)
        if(pct >= 80) print $1
    }' | while read dev; do
        echo "│ ⚠ High disk usage on $dev (consider cleanup)"
        high_usage=1
    done
    
    df -i | awk 'NR>1 {
        pct=substr($5,1,length($5)-1)
        if(pct >= 80) print $1
    }' | while read dev; do
        echo "│ ⚠ High inode usage on $dev (many small files)"
        high_inodes=1
    done
    
    if (( high_usage == 0 && high_inodes == 0 )); then
        echo "│ ✓ All filesystems operating normally"
    fi
    
    echo "│"
    echo "└──────────────────────────────────────────────────────────────────┘"
}

################################################################################
# HTML FORMAT
################################################################################

generate_html_report() {
    cat << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Storage Utilization Report</title>
    <style>
        * { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 3px solid #0066cc; padding-bottom: 10px; }
        h2 { color: #0066cc; margin-top: 30px; margin-bottom: 15px; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th { background: #0066cc; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background: #f9f9f9; }
        .bar-container { width: 150px; height: 20px; background: #eee; border-radius: 3px; overflow: hidden; display: inline-block; vertical-align: middle; }
        .bar-fill { height: 100%; background: linear-gradient(90deg, #4caf50, #ff9800, #f44336); }
        .warning { color: #f44336; font-weight: bold; }
        .success { color: #4caf50; font-weight: bold; }
        .meta { color: #666; font-size: 0.9em; margin-bottom: 20px; }
        .directory-list { list-style: none; padding: 0; }
        .directory-list li { padding: 8px; border-left: 3px solid #0066cc; margin-bottom: 5px; background: #f9f9f9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Storage Utilization Report</h1>
        <div class="meta">
            <p><strong>Generated:</strong> <span id="timestamp"></span></p>
            <p><strong>Hostname:</strong> <span id="hostname"></span></p>
        </div>

        <h2>Disk Space Usage</h2>
        <table>
            <thead>
                <tr>
                    <th>Device</th>
                    <th>Total</th>
                    <th>Used</th>
                    <th>Available</th>
                    <th>Usage</th>
                    <th>Progress</th>
                </tr>
            </thead>
            <tbody id="disk-usage">
                <!-- Will be populated by script -->
            </tbody>
        </table>

        <h2>Inode Usage</h2>
        <table>
            <thead>
                <tr>
                    <th>Device</th>
                    <th>Total</th>
                    <th>Used</th>
                    <th>Available</th>
                    <th>Usage %</th>
                </tr>
            </thead>
            <tbody id="inode-usage">
                <!-- Will be populated by script -->
            </tbody>
        </table>

        <h2>Filesystem Types</h2>
        <table>
            <thead>
                <tr>
                    <th>Filesystem Type</th>
                    <th>Count</th>
                </tr>
            </thead>
            <tbody id="fs-types">
                <!-- Will be populated by script -->
            </tbody>
        </table>

        <h2>Largest Directories</h2>
        <div id="large-dirs">
            <!-- Will be populated by script -->
        </div>

        <h2>Recommendations</h2>
        <div id="recommendations">
            <!-- Will be populated by script -->
        </div>
    </div>

    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        document.getElementById('hostname').textContent = 'Loading...';
    </script>
</body>
</html>
EOF
}

################################################################################
# JSON FORMAT
################################################################################

generate_json_report() {
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    
    {
        echo "{"
        echo "  \"timestamp\": \"$timestamp\","
        echo "  \"hostname\": \"$(hostname)\","
        echo "  \"disk_usage\": ["
        
        df -h | awk 'NR>1 {
            device=$1; size=$2; used=$3; avail=$4; pct=$5
            gsub(/%/, "", pct)
            printf "    {\"device\": \"%s\", \"size\": \"%s\", \"used\": \"%s\", \"available\": \"%s\", \"usage_percent\": %d}\n", device, size, used, avail, pct
        }' | sed '$ s/,$//'
        
        echo "  ],"
        echo "  \"inode_usage\": ["
        
        df -i | awk 'NR>1 {
            device=$1; total=$2; used=$3; avail=$4; pct=$5
            gsub(/%/, "", pct)
            printf "    {\"device\": \"%s\", \"total\": %d, \"used\": %d, \"available\": %d, \"usage_percent\": %d}\n", device, total, used, avail, pct
        }' | sed '$ s/,$//'
        
        echo "  ],"
        echo "  \"filesystems\": ["
        
        df -T | grep -E "^/dev" | awk '{
            device=$1; type=$2; mount=$7
            printf "    {\"device\": \"%s\", \"type\": \"%s\", \"mount_point\": \"%s\"}\n", device, type, mount
        }' | sed '$ s/,$//'
        
        echo "  ]"
        echo "}"
        
    }
}

################################################################################
# Main
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --format)
                REPORT_FORMAT="${2,,}"  # Convert to lowercase
                shift 2
                ;;
            --output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Generate report
    local report=""
    case "$REPORT_FORMAT" in
        html)
            report=$(generate_html_report)
            ;;
        json)
            report=$(generate_json_report)
            ;;
        *)
            report=$(generate_text_report)
            ;;
    esac
    
    # Output report
    if [[ -n "$OUTPUT_FILE" ]]; then
        echo "$report" > "$OUTPUT_FILE"
        echo "Report saved to: $OUTPUT_FILE"
    else
        echo "$report"
    fi
    
    # Save to history if text format
    if [[ "$REPORT_FORMAT" == "text" && -w "$(dirname "$HISTORICAL_DATA")" ]]; then
        echo "$report" >> "$HISTORICAL_DATA"
    fi
}

show_help() {
    cat << EOF
Storage Report Generator - Create comprehensive storage reports

Usage: $(basename "$0") [OPTIONS]

Options:
  --format FORMAT     Output format: TEXT (default), HTML, or JSON
  --output FILE       Save to file (default: stdout)
  --help              Show this help message

Examples:
  $(basename "$0")                                    # Text to stdout
  $(basename "$0") --format HTML --output report.html # Save as HTML
  $(basename "$0") --format JSON > storage.json       # JSON output

Output Formats:
  TEXT  - Human-readable formatted output with progress bars
  HTML  - Interactive web page (good for sharing)
  JSON  - Machine-readable format (for parsing/integration)

Features:
  - Disk space usage summary
  - Inode utilization tracking
  - Filesystem type distribution
  - Top directories identification
  - Health recommendations
  - Timestamp and hostname tracking

Files Created:
  Snapshots:  /tmp/storage-snapshot-*.txt
  History:    /var/log/storage-history.txt (if writable)

EOF
}

# Run main function
main "$@"
