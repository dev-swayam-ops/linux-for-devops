#!/bin/bash
# Deployment Helper Script
# Purpose: Automate application deployment with validation and rollback
# Usage: ./deployment-helper.sh --action deploy --app myapp --version 1.0.0
# Features: Deploy, rollback, status checks, health monitoring

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Deployment settings
DEPLOY_APPS_DIR="${DEPLOY_APPS_DIR:-/opt/apps}"
DEPLOY_RELEASES_DIR="${DEPLOY_APPS_DIR}/releases"
DEPLOY_BACKUPS_DIR="${DEPLOY_APPS_DIR}/backups"
DEPLOY_LOGS_DIR="${DEPLOY_APPS_DIR}/logs"

# Variables
ACTION=""
APP_NAME=""
APP_VERSION=""
ENVIRONMENT="production"
DRY_RUN=false
VERBOSE=false

# Status tracking
DEPLOYMENT_ID=""
DEPLOYMENT_START_TIME=""
DEPLOYMENT_STATUS="pending"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# ============================================================================
# LOGGING
# ============================================================================

log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)
            echo -e "${RED}[ERROR]${NC} $msg" >&2
            ;;
        WARN)
            echo -e "${YELLOW}[!]${NC} $msg"
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓]${NC} $msg"
            ;;
        INFO)
            echo -e "${BLUE}[*]${NC} $msg"
            ;;
        DEBUG)
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${PURPLE}[DEBUG]${NC} $msg"
            fi
            ;;
    esac
    
    # Log to file (if log dir exists)
    if [[ -d "$DEPLOY_LOGS_DIR" ]]; then
        echo "[$timestamp] [$level] $msg" >> "$DEPLOY_LOGS_DIR/deployment.log"
    fi
}

error() {
    log ERROR "$@"
    exit 1
}

# ============================================================================
# HELP
# ============================================================================

show_help() {
    cat << EOF
${BLUE}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
Application deployment helper with rollback support

${BLUE}USAGE${NC}
    $SCRIPT_NAME --action ACTION --app APP [OPTIONS]

${BLUE}ACTIONS${NC}
    deploy               Deploy application
    rollback             Rollback to previous version
    status               Show deployment status
    list                 List available versions
    health               Check application health
    prepare              Prepare deployment (validation only)

${BLUE}OPTIONS${NC}
    --app APP            Application name (required)
    --version VERSION    Version to deploy (required for deploy)
    --env ENVIRONMENT    Environment (default: production)
    --dry-run            Show what would be done
    --verbose            Show detailed output
    --help               Show this help

${BLUE}EXAMPLES${NC}
    # Deploy new version
    $SCRIPT_NAME --action deploy --app myapp --version 1.0.0

    # Dry-run deployment
    $SCRIPT_NAME --action deploy --app myapp --version 1.0.0 --dry-run

    # Rollback to previous
    $SCRIPT_NAME --action rollback --app myapp

    # Check status
    $SCRIPT_NAME --action status --app myapp

    # Check health
    $SCRIPT_NAME --action health --app myapp

${BLUE}DEPLOYMENT STRUCTURE${NC}
    $DEPLOY_APPS_DIR/
    ├── releases/          (Deployed versions)
    ├── backups/           (Backup files)
    ├── logs/              (Deployment logs)
    └── <app>/            (Application-specific data)

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
            --action)
                ACTION="$2"
                shift 2
                ;;
            --app)
                APP_NAME="$2"
                shift 2
                ;;
            --version)
                APP_VERSION="$2"
                shift 2
                ;;
            --env)
                ENVIRONMENT="$2"
                shift 2
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
    if [[ -z "$ACTION" ]]; then
        error "No action specified (use --action)"
    fi
    
    if [[ -z "$APP_NAME" ]]; then
        error "No app specified (use --app)"
    fi
    
    # Create necessary directories
    mkdir -p "$DEPLOY_RELEASES_DIR" "$DEPLOY_BACKUPS_DIR" "$DEPLOY_LOGS_DIR"
    
    log DEBUG "Environment validated"
}

validate_version() {
    if [[ -z "$APP_VERSION" ]]; then
        error "No version specified (use --version)"
    fi
    
    if ! [[ "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Invalid version format: $APP_VERSION (expected: X.Y.Z)"
    fi
}

validate_action() {
    case "$ACTION" in
        deploy|rollback|status|list|health|prepare)
            return 0
            ;;
        *)
            error "Unknown action: $ACTION"
            ;;
    esac
}

# ============================================================================
# DEPLOYMENT FUNCTIONS
# ============================================================================

initialize_deployment() {
    DEPLOYMENT_ID="${APP_NAME}-${ENVIRONMENT}-$(date +%s)"
    DEPLOYMENT_START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    
    log INFO "=========================================="
    log INFO "Deployment Started"
    log INFO "=========================================="
    log INFO "ID:           $DEPLOYMENT_ID"
    log INFO "App:          $APP_NAME"
    log INFO "Version:      ${APP_VERSION:-unknown}"
    log INFO "Environment:  $ENVIRONMENT"
    log INFO "Time:         $DEPLOYMENT_START_TIME"
}

prepare_deployment() {
    log INFO "Preparing deployment..."
    
    # Check prerequisites
    if [[ ! -d "$DEPLOY_RELEASES_DIR/$APP_NAME" ]]; then
        log WARN "App directory not found, creating: $DEPLOY_RELEASES_DIR/$APP_NAME"
        mkdir -p "$DEPLOY_RELEASES_DIR/$APP_NAME"
    fi
    
    # Validate release exists
    local app_release="$DEPLOY_RELEASES_DIR/$APP_NAME/$APP_VERSION"
    if [[ ! -d "$app_release" ]]; then
        log WARN "Release not found: $APP_VERSION"
        log WARN "Would need to fetch/build this version"
    fi
    
    # Check health of current version
    check_current_health
    
    log SUCCESS "Deployment preparation complete"
}

deploy_version() {
    validate_version
    
    local app_release="$DEPLOY_RELEASES_DIR/$APP_NAME/$APP_VERSION"
    local app_link="$DEPLOY_APPS_DIR/$APP_NAME/current"
    local app_backup="$DEPLOY_BACKUPS_DIR/${APP_NAME}-pre-deploy-$(date +%Y%m%d-%H%M%S)"
    
    log INFO "Deploying version: $APP_VERSION"
    
    # Check if version exists
    if [[ ! -d "$app_release" ]]; then
        log WARN "Release directory not found: $app_release"
        
        if [[ "$DRY_RUN" == true ]]; then
            log INFO "[DRY-RUN] Would create release directory"
            return 0
        fi
        
        log INFO "Creating release directory"
        mkdir -p "$app_release"
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY-RUN] Would backup current version"
        if [[ -L "$app_link" ]]; then
            log INFO "[DRY-RUN] Current version: $(readlink "$app_link")"
        fi
        log INFO "[DRY-RUN] Would update symlink to: $app_release"
        log INFO "[DRY-RUN] Would run pre-deployment hooks"
        log INFO "[DRY-RUN] Would verify deployment"
        return 0
    fi
    
    # Backup current version
    if [[ -L "$app_link" ]]; then
        local current_version=$(readlink "$app_link")
        log INFO "Backing up current version: $current_version"
        cp -al "$current_version" "$app_backup"
    fi
    
    # Create symlink to new version
    log INFO "Updating symlink"
    mkdir -p "$(dirname "$app_link")"
    ln -sfn "$app_release" "$app_link"
    
    # Run deployment hooks
    run_deployment_hooks "pre-deploy"
    
    # Verify deployment
    if verify_deployment; then
        log SUCCESS "Deployment successful"
        run_deployment_hooks "post-deploy"
        DEPLOYMENT_STATUS="completed"
    else
        log ERROR "Deployment verification failed"
        rollback_deployment "$app_backup"
        DEPLOYMENT_STATUS="failed"
        return 1
    fi
}

rollback_deployment() {
    log INFO "Rolling back deployment..."
    
    local app_link="$DEPLOY_APPS_DIR/$APP_NAME/current"
    
    if [[ $# -gt 0 ]]; then
        local backup_path="$1"
        if [[ ! -d "$backup_path" ]]; then
            error "Backup not found: $backup_path"
        fi
        
        log INFO "Rolling back to: $(basename "$backup_path")"
        
        if [[ "$DRY_RUN" == true ]]; then
            log INFO "[DRY-RUN] Would restore: $backup_path"
            return 0
        fi
        
        ln -sfn "$backup_path" "$app_link"
        log SUCCESS "Rollback completed"
    else
        log INFO "Finding previous version..."
        
        local versions=$(ls -1d "$DEPLOY_RELEASES_DIR/$APP_NAME"/* 2>/dev/null | sort -r)
        local prev_version=$(echo "$versions" | head -2 | tail -1)
        
        if [[ -z "$prev_version" ]]; then
            error "No previous version available"
        fi
        
        log INFO "Rolling back to: $(basename "$prev_version")"
        
        if [[ "$DRY_RUN" == false ]]; then
            ln -sfn "$prev_version" "$app_link"
            log SUCCESS "Rollback completed"
        fi
    fi
}

# ============================================================================
# VERIFICATION & HEALTH
# ============================================================================

verify_deployment() {
    log INFO "Verifying deployment..."
    
    local app_link="$DEPLOY_APPS_DIR/$APP_NAME/current"
    
    if [[ ! -L "$app_link" ]]; then
        log ERROR "Application symlink not found"
        return 1
    fi
    
    local target=$(readlink "$app_link")
    if [[ "$target" != *"$APP_VERSION"* ]] && [[ -n "$APP_VERSION" ]]; then
        log ERROR "Symlink not pointing to correct version"
        return 1
    fi
    
    log SUCCESS "Verification passed"
    return 0
}

check_current_health() {
    log INFO "Checking current version health..."
    
    # Simulated health check
    if [[ -f "/tmp/${APP_NAME}.health" ]]; then
        local health=$(cat "/tmp/${APP_NAME}.health")
        if [[ "$health" != "healthy" ]]; then
            log WARN "Current version health: $health"
        else
            log SUCCESS "Current version healthy"
        fi
    else
        log WARN "No health status available"
    fi
}

check_app_health() {
    log INFO "Checking application health..."
    
    # Simulated health check - would normally check service status, ports, etc.
    if systemctl is-active --quiet "$APP_NAME" 2>/dev/null; then
        log SUCCESS "Application is running"
        
        # Check if listening
        if command -v ss &>/dev/null; then
            local listening=$(ss -tln | grep -c ":.*LISTEN" || echo "0")
            log INFO "Active listening ports: $listening"
        fi
    else
        log WARN "Application may not be running"
    fi
}

# ============================================================================
# DEPLOYMENT HOOKS
# ============================================================================

run_deployment_hooks() {
    local hook_type="$1"
    local hook_dir="$DEPLOY_APPS_DIR/$APP_NAME/hooks"
    
    if [[ ! -d "$hook_dir" ]]; then
        return 0
    fi
    
    local hook_file="$hook_dir/$hook_type.sh"
    if [[ ! -f "$hook_file" ]]; then
        return 0
    fi
    
    log INFO "Running $hook_type hooks..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY-RUN] Would execute: $hook_file"
    else
        if bash "$hook_file"; then
            log SUCCESS "Hook completed: $hook_type"
        else
            log WARN "Hook failed: $hook_type"
        fi
    fi
}

# ============================================================================
# STATUS & LISTING
# ============================================================================

show_status() {
    log INFO "=========================================="
    log INFO "Deployment Status"
    log INFO "=========================================="
    
    local app_link="$DEPLOY_APPS_DIR/$APP_NAME/current"
    
    if [[ -L "$app_link" ]]; then
        local current=$(readlink "$app_link")
        local current_version=$(basename "$current")
        log INFO "Current version: $current_version"
    else
        log INFO "Current version: (none deployed)"
    fi
    
    log INFO ""
    log INFO "Available versions:"
    ls -1d "$DEPLOY_RELEASES_DIR/$APP_NAME"/* 2>/dev/null | while read -r version_dir; do
        local version=$(basename "$version_dir")
        local size=$(du -sh "$version_dir" | cut -f1)
        log INFO "  • $version ($size)"
    done || log INFO "  (none)"
}

list_versions() {
    log INFO "Available versions for $APP_NAME:"
    log INFO ""
    
    if [[ ! -d "$DEPLOY_RELEASES_DIR/$APP_NAME" ]]; then
        log INFO "No versions found"
        return 0
    fi
    
    ls -1hd "$DEPLOY_RELEASES_DIR/$APP_NAME"/* 2>/dev/null | while read -r version_dir; do
        local version=$(basename "$version_dir")
        local size=$(du -sh "$version_dir" | cut -f1)
        local mtime=$(stat -c %y "$version_dir" 2>/dev/null || stat -f "%Sm" "$version_dir" 2>/dev/null)
        
        printf "  %-15s %8s  %s\n" "$version" "$size" "$mtime"
    done || log INFO "  (no versions)"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    parse_arguments "$@"
    validate_environment
    validate_action
    initialize_deployment
    
    case "$ACTION" in
        deploy)
            prepare_deployment
            deploy_version
            ;;
        rollback)
            rollback_deployment
            ;;
        status)
            show_status
            ;;
        list)
            list_versions
            ;;
        health)
            check_app_health
            ;;
        prepare)
            prepare_deployment
            ;;
    esac
    
    log INFO "=========================================="
    log SUCCESS "Action completed: $ACTION"
    log INFO "=========================================="
}

main "$@"
