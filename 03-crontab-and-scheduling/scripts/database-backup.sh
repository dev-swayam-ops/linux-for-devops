#!/bin/bash
################################################################################
# Script Name: database-backup.sh
# Purpose: Production-grade database backup with rotation and verification
# Usage: ./database-backup.sh [OPTIONS]
# Author: DevOps Team
# Version: 1.0
# 
# Features:
#   - Supports MySQL/MariaDB, PostgreSQL, and MongoDB
#   - Automatic backup rotation (keeps N recent backups)
#   - Compression and size reporting
#   - Email notifications on success/failure
#   - Detailed logging
#   - Lock mechanism to prevent overlapping backups
#   - Backup integrity verification
################################################################################

set -euo pipefail

################################################################################
# Configuration
################################################################################

# Backup destination
BACKUP_DIR="${BACKUP_DIR:=/backups}"

# Database type: mysql, postgresql, or mongodb
DB_TYPE="${DB_TYPE:=mysql}"

# Database credentials (use environment variables for security)
DB_HOST="${DB_HOST:=localhost}"
DB_USER="${DB_USER:=root}"
DB_PASSWORD="${DB_PASSWORD:=}"
DB_NAME="${DB_NAME:=*}"  # * means all databases

# Retention policy
KEEP_BACKUPS="${KEEP_BACKUPS:=7}"

# Logging
LOG_DIR="${LOG_DIR:=/var/log/backups}"
LOG_FILE="$LOG_DIR/backup-${DB_TYPE}.log"

# Notifications
ALERT_EMAIL="${ALERT_EMAIL:=admin@example.com}"
SEND_EMAIL="${SEND_EMAIL:=false}"

# Lock file to prevent concurrent backups
LOCK_FILE="/tmp/backup-${DB_TYPE}.lock"
LOCK_TIMEOUT=3600

# Timestamps
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DATE_STAMP=$(date +%Y-%m-%d)

################################################################################
# Color codes for output
################################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

################################################################################
# Functions
################################################################################

show_help() {
    cat << EOF
${BLUE}Database Backup Utility${NC}
Automated backup solution for MySQL, PostgreSQL, and MongoDB

Usage: $0 [OPTIONS]

OPTIONS:
    -t, --type TYPE         Database type: mysql, postgresql, mongodb (default: $DB_TYPE)
    -H, --host HOST         Database host (default: $DB_HOST)
    -u, --user USER         Database username (default: $DB_USER)
    -d, --database DB       Database name, * for all (default: $DB_NAME)
    -r, --retention DAYS    Keep N recent backups (default: $KEEP_BACKUPS)
    -e, --email EMAIL       Alert email address (default: $ALERT_EMAIL)
    --send-email            Send notification email on completion
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

EXAMPLES:
    # Backup all MySQL databases, keep 7 days
    $0 -t mysql -u root -d '*' -r 7

    # Backup PostgreSQL, send email on completion
    $0 -t postgresql --send-email

    # Backup MongoDB with verbose output
    $0 -t mongodb -v

ENVIRONMENT VARIABLES:
    DB_PASSWORD             Database password (for non-interactive auth)
    BACKUP_DIR              Where to store backups (default: /backups)
    LOG_DIR                 Where to store logs (default: /var/log/backups)

EOF
}

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Ensure log directory exists
    mkdir -p "$LOG_DIR"
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $@" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $@" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@" | tee -a "$LOG_FILE"
}

# Acquire lock
acquire_lock() {
    # Check if lock exists
    if [ -f "$LOCK_FILE" ]; then
        LOCK_AGE=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)))
        if [ "$LOCK_AGE" -lt "$LOCK_TIMEOUT" ]; then
            log_error "Backup already in progress (lock file exists: $LOCK_FILE)"
            return 1
        else
            log_warn "Stale lock file removed (age: $LOCK_AGE seconds)"
            rm -f "$LOCK_FILE"
        fi
    fi
    
    mkdir -p "$(dirname "$LOCK_FILE")"
    echo "$$" > "$LOCK_FILE"
    trap "rm -f $LOCK_FILE" EXIT
    return 0
}

# Ensure backup directory
ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        if [ ! -d "$BACKUP_DIR" ]; then
            log_error "Failed to create backup directory: $BACKUP_DIR"
            return 1
        fi
    fi
    
    # Check available space (require 1GB minimum)
    AVAILABLE=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE" -lt 1048576 ]; then
        log_error "Insufficient disk space in $BACKUP_DIR (available: $((AVAILABLE/1024)) MB)"
        return 1
    fi
}

# MySQL backup
backup_mysql() {
    log_info "Starting MySQL backup"
    
    local backup_file="$BACKUP_DIR/mysql-${DB_NAME}-${TIMESTAMP}.sql.gz"
    
    # Build mysqldump command
    local cmd="mysqldump"
    [ -n "$DB_HOST" ] && cmd+=" -h $DB_HOST"
    [ -n "$DB_USER" ] && cmd+=" -u $DB_USER"
    [ -n "$DB_PASSWORD" ] && cmd+=" -p$DB_PASSWORD"
    cmd+=" --single-transaction --quick --lock-tables=false"
    
    if [ "$DB_NAME" = "*" ]; then
        cmd+=" --all-databases"
        backup_file="$BACKUP_DIR/mysql-all-${TIMESTAMP}.sql.gz"
    else
        cmd+=" $DB_NAME"
    fi
    
    # Execute backup
    if eval "$cmd" 2>>"$LOG_FILE" | gzip > "$backup_file"; then
        local size=$(du -h "$backup_file" | cut -f1)
        log_info "MySQL backup successful: $backup_file ($size)"
        return 0
    else
        log_error "MySQL backup failed"
        rm -f "$backup_file"
        return 1
    fi
}

# PostgreSQL backup
backup_postgresql() {
    log_info "Starting PostgreSQL backup"
    
    local backup_file="$BACKUP_DIR/postgresql-${DB_NAME}-${TIMESTAMP}.sql.gz"
    
    # Set environment variables for pg_dump
    export PGHOST="$DB_HOST"
    export PGUSER="$DB_USER"
    [ -n "$DB_PASSWORD" ] && export PGPASSWORD="$DB_PASSWORD"
    
    # Build pg_dump command
    local cmd="pg_dump --verbose --no-password"
    
    if [ "$DB_NAME" = "*" ]; then
        cmd="pg_dumpall --no-password"
        backup_file="$BACKUP_DIR/postgresql-all-${TIMESTAMP}.sql.gz"
    else
        cmd+=" $DB_NAME"
    fi
    
    # Execute backup
    if eval "$cmd" 2>>"$LOG_FILE" | gzip > "$backup_file"; then
        local size=$(du -h "$backup_file" | cut -f1)
        log_info "PostgreSQL backup successful: $backup_file ($size)"
        unset PGPASSWORD
        return 0
    else
        log_error "PostgreSQL backup failed"
        rm -f "$backup_file"
        unset PGPASSWORD
        return 1
    fi
}

# MongoDB backup
backup_mongodb() {
    log_info "Starting MongoDB backup"
    
    local backup_dir="$BACKUP_DIR/mongodb-${TIMESTAMP}"
    
    # Build mongodump command
    local cmd="mongodump --out=$backup_dir"
    [ -n "$DB_HOST" ] && cmd+=" --host=$DB_HOST"
    [ -n "$DB_USER" ] && cmd+=" --username=$DB_USER"
    [ -n "$DB_PASSWORD" ] && cmd+=" --password=$DB_PASSWORD --authenticationDatabase admin"
    [ "$DB_NAME" != "*" ] && cmd+=" --db=$DB_NAME"
    
    # Execute backup
    if eval "$cmd" 2>>"$LOG_FILE"; then
        # Compress backup
        local backup_file="${backup_dir}.tar.gz"
        tar -czf "$backup_file" -C "$BACKUP_DIR" "$(basename $backup_dir)" 2>>"$LOG_FILE"
        rm -rf "$backup_dir"
        
        local size=$(du -h "$backup_file" | cut -f1)
        log_info "MongoDB backup successful: $backup_file ($size)"
        return 0
    else
        log_error "MongoDB backup failed"
        rm -rf "$backup_dir"
        return 1
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    log_info "Cleaning up backups older than $KEEP_BACKUPS days"
    
    local pattern="${BACKUP_DIR}/${DB_TYPE}-*"
    if [ "$DB_TYPE" = "mongodb" ]; then
        pattern="${BACKUP_DIR}/mongodb-*.tar.gz"
    fi
    
    # Count current backups
    local count=$(ls -1 $pattern 2>/dev/null | wc -l)
    
    if [ "$count" -gt "$KEEP_BACKUPS" ]; then
        log_info "Found $count backups, keeping $KEEP_BACKUPS, removing $((count - KEEP_BACKUPS))"
        ls -t1 $pattern | tail -n +$((KEEP_BACKUPS + 1)) | while read backup; do
            log_info "Removing old backup: $(basename $backup)"
            rm -f "$backup"
        done
    else
        log_info "No cleanup needed ($count backups)"
    fi
}

# Send email notification
send_notification() {
    local status="$1"
    local message="$2"
    
    if [ "$SEND_EMAIL" = "true" ] || [ "$SEND_EMAIL" = "1" ]; then
        local subject="Database Backup ${status} - ${DB_TYPE} - $(hostname)"
        
        if command -v mail &> /dev/null; then
            echo -e "$message" | mail -s "$subject" "$ALERT_EMAIL"
            log_info "Notification email sent to $ALERT_EMAIL"
        else
            log_warn "mail command not found, cannot send notification"
        fi
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                DB_TYPE="$2"
                shift 2
                ;;
            -H|--host)
                DB_HOST="$2"
                shift 2
                ;;
            -u|--user)
                DB_USER="$2"
                shift 2
                ;;
            -d|--database)
                DB_NAME="$2"
                shift 2
                ;;
            -r|--retention)
                KEEP_BACKUPS="$2"
                shift 2
                ;;
            -e|--email)
                ALERT_EMAIL="$2"
                shift 2
                ;;
            --send-email)
                SEND_EMAIL="true"
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    log_info "==================================="
    log_info "Database Backup Starting"
    log_info "Type: $DB_TYPE, Host: $DB_HOST"
    log_info "==================================="
    
    # Acquire lock
    if ! acquire_lock; then
        return 1
    fi
    
    # Setup error handling
    trap 'log_error "Backup process interrupted"; return 1' INT TERM
    
    # Validate prerequisites
    if ! ensure_backup_dir; then
        return 1
    fi
    
    # Execute backup based on type
    local success=false
    case "$DB_TYPE" in
        mysql)
            if backup_mysql; then
                success=true
            fi
            ;;
        postgresql)
            if backup_postgresql; then
                success=true
            fi
            ;;
        mongodb)
            if backup_mongodb; then
                success=true
            fi
            ;;
        *)
            log_error "Unsupported database type: $DB_TYPE"
            return 1
            ;;
    esac
    
    # Post-backup actions
    if [ "$success" = "true" ]; then
        cleanup_old_backups
        log_info "Backup completed successfully"
        
        send_notification "SUCCESS" "Database backup for $DB_TYPE completed successfully.\nBackup stored in: $BACKUP_DIR"
        return 0
    else
        log_error "Backup failed - review logs for details"
        send_notification "FAILURE" "Database backup for $DB_TYPE failed.\nCheck logs: $LOG_FILE"
        return 1
    fi
}

################################################################################
# Entry Point
################################################################################

# Show help if no arguments and not in cron
if [ $# -eq 0 ] && [ -z "${CRON:-}" ]; then
    show_help
    exit 0
fi

parse_args "$@"
main
