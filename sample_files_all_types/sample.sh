#!/bin/bash

# PRD Management System - Shell Script Utilities
# Version: 1.2.0 | Last Updated: July 25, 2025
# This script provides command-line utilities for PRD management on Unix/Linux systems

set -e  # Exit on any error
set -u  # Exit on undefined variables

# Configuration
PRD_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_CONFIG="${PRD_HOME}/config/prd.conf"
PRD_LOG="${PRD_HOME}/logs/prd.log"
API_BASE_URL="https://api.prd-management.com/v1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "${PRD_LOG}"
}

# Error handling
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    log "ERROR: $1"
    exit 1
}

# Success message
success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
    log "SUCCESS: $1"
}

# Info message
info() {
    echo -e "${BLUE}INFO: $1${NC}"
    log "INFO: $1"
}

# Warning message
warn() {
    echo -e "${YELLOW}WARNING: $1${NC}"
    log "WARNING: $1"
}

# Load configuration
load_config() {
    if [[ ! -f "$PRD_CONFIG" ]]; then
        error_exit "Configuration file not found: $PRD_CONFIG"
    fi
    
    source "$PRD_CONFIG"
    
    # Validate required variables
    [[ -z "${API_KEY:-}" ]] && error_exit "API_KEY not set in configuration"
    [[ -z "${DEFAULT_AUTHOR:-}" ]] && error_exit "DEFAULT_AUTHOR not set in configuration"
}

# Display help
show_help() {
    cat << EOF
PRD Management System - Command Line Interface

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    list            List all PRDs
    create          Create a new PRD
    update          Update PRD status
    delete          Delete a PRD
    export          Export PRD data
    import          Import PRD data
    report          Generate reports
    health          System health check
    setup           Initial system setup
    help            Show this help message

Options:
    -h, --help      Show help
    -v, --verbose   Verbose output
    -q, --quiet     Quiet mode
    -c, --config    Specify config file

Examples:
    $0 list
    $0 create --title "New Feature" --category "feature"
    $0 update --id "PRD-123" --status "approved"
    $0 export --format json --output prds.json
    $0 report --type weekly --team "engineering"

For more information, visit: https://docs.prd-management.com
EOF
}

# List PRDs
list_prds() {
    info "Fetching PRD list from server..."
    
    local response
    response=$(curl -s -H "Authorization: Bearer ${API_KEY}" \
                   -H "Content-Type: application/json" \
                   "${API_BASE_URL}/prds" || error_exit "Failed to fetch PRDs")
    
    echo "$response" | jq -r '.data[] | "\(.id)\t\(.title)\t\(.status)\t\(.priority)"' | \
    column -t -s $'\t' -N "ID,Title,Status,Priority"
    
    success "PRD list retrieved successfully"
}

# Create new PRD
create_prd() {
    local title="$1"
    local category="$2"
    local description="$3"
    
    info "Creating new PRD: $title"
    
    local payload
    payload=$(jq -n \
        --arg title "$title" \
        --arg category "$category" \
        --arg description "$description" \
        --arg author "$DEFAULT_AUTHOR" \
        '{
            title: $title,
            category: $category,
            description: $description,
            author: $author,
            status: "draft",
            priority: "medium"
        }')
    
    local response
    response=$(curl -s -X POST \
                   -H "Authorization: Bearer ${API_KEY}" \
                   -H "Content-Type: application/json" \
                   -d "$payload" \
                   "${API_BASE_URL}/prds" || error_exit "Failed to create PRD")
    
    local prd_id
    prd_id=$(echo "$response" | jq -r '.data.id')
    
    success "PRD created successfully with ID: $prd_id"
}

# Update PRD status
update_prd_status() {
    local prd_id="$1"
    local new_status="$2"
    
    info "Updating PRD $prd_id status to: $new_status"
    
    local payload
    payload=$(jq -n --arg status "$new_status" '{status: $status}')
    
    curl -s -X PATCH \
         -H "Authorization: Bearer ${API_KEY}" \
         -H "Content-Type: application/json" \
         -d "$payload" \
         "${API_BASE_URL}/prds/${prd_id}" > /dev/null || error_exit "Failed to update PRD status"
    
    success "PRD status updated successfully"
}

# Generate reports
generate_report() {
    local report_type="${1:-weekly}"
    local team="${2:-all}"
    
    info "Generating $report_type report for team: $team"
    
    local response
    response=$(curl -s -H "Authorization: Bearer ${API_KEY}" \
                   "${API_BASE_URL}/reports/${report_type}?team=${team}" || error_exit "Failed to generate report")
    
    local filename="prd_${report_type}_report_$(date +%Y%m%d).json"
    echo "$response" > "$filename"
    
    success "Report generated: $filename"
}

# System health check
health_check() {
    info "Performing system health check..."
    
    # Check server connectivity
    if curl -s --head "${API_BASE_URL}/health" > /dev/null; then
        success "Server connectivity: OK"
    else
        error_exit "Server connectivity: FAILED"
    fi
    
    # Check API authentication
    if curl -s -H "Authorization: Bearer ${API_KEY}" "${API_BASE_URL}/auth/verify" > /dev/null; then
        success "API authentication: OK"
    else
        error_exit "API authentication: FAILED"
    fi
    
    # Check required tools
    for tool in jq curl column; do
        if command -v "$tool" > /dev/null; then
            success "$tool: Available"
        else
            warn "$tool: Not found (some features may not work)"
        fi
    done
    
    success "Health check completed"
}

# Main script logic
main() {
    # Create logs directory if it doesn't exist
    mkdir -p "$(dirname "$PRD_LOG")"
    
    # Load configuration
    load_config
    
    # Parse command line arguments
    case "${1:-help}" in
        list)
            list_prds
            ;;
        create)
            [[ $# -lt 4 ]] && error_exit "Usage: $0 create <title> <category> <description>"
            create_prd "$2" "$3" "$4"
            ;;
        update)
            [[ $# -lt 3 ]] && error_exit "Usage: $0 update <prd_id> <status>"
            update_prd_status "$2" "$3"
            ;;
        report)
            generate_report "${2:-weekly}" "${3:-all}"
            ;;
        health)
            health_check
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error_exit "Unknown command: $1. Use '$0 help' for usage information."
            ;;
    esac
}

# Run main function with all arguments
main "$@"