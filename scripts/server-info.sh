#!/bin/sh

# Server Diagnostics Script
# Collects system information and checks service availability

# Configuration
LOG_FILE="server_diag.log"
SCRIPT_NAME=$(basename "$0")
TIMEOUT=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
EXIT_CODE=0
TOTAL_CHECKS=0
SUCCESSFUL_CHECKS=0

# Logging function
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "$message"
    echo "$timestamp - $message" >> "$LOG_FILE"
}

# Error logging
log_error() {
    local message="$1"
    log "${RED}[ERROR]${NC} $message"
}

# Success logging
log_success() {
    local message="$1"
    log "${GREEN}[SUCCESS]${NC} $message"
}

# Warning logging
log_warning() {
    local message="$1"
    log "${YELLOW}[WARNING]${NC} $message"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker is not installed"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_error "Please install missing dependencies and try again"
        exit 1
    fi
}

# Get system information
get_system_info() {
    log "${BLUE}=== Server Diagnostics ===${NC}"
    log "Date:     $(date '+%Y-%m-%d %H:%M:%S')"
    log "Hostname: $(hostname)"
    log "OS:       $(lsb_release -d 2>/dev/null | cut -f2 || uname -s)"
    log "Kernel:   $(uname -r)"
    log "Uptime:   $(uptime -p 2>/dev/null || uptime)"
}

# Get resource information
get_resource_info() {
    log "\n${BLUE}=== Resources ===${NC}"
    
    # CPU information
    local cpu_cores=$(nproc)
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')
    log "CPU:      $cpu_cores cores, load average:$load_avg"
    
    # RAM information
    if command -v free &> /dev/null; then
        local ram_info=$(free -h | awk '/Mem:/ {printf "%.1fG / %.1fG (%.0f%%)", $3, $2, $3/$2*100}')
        log "RAM:      $ram_info"
    else
        log_warning "Could not get RAM information"
    fi
    
    # Disk information
    if command -v df &> /dev/null; then
        local disk_info=$(df -h / | awk 'NR==2 {printf "%s / %s (%.0f%%)", $3, $2, $3/$2*100}')
        log "Disk /:   $disk_info"
    else
        log_warning "Could not get disk information"
    fi
}

# Get Docker information
get_docker_info() {
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        log "\n${BLUE}=== Docker ===${NC}"
        local docker_ps=$(docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || echo "Could not get container list")
        log "$docker_ps"
    else
        log_warning "Docker is not available"
    fi
}

# Check service availability
check_service_health() {
    local url="$1"
    local start_time=$(date +%s%3N)
    
    if curl -s -f -m "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -q "^[23]"; then
        local end_time=$(date +%s%3N)
        local response_time=$((end_time - start_time))
        local http_code=$(curl -s -f -m "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
        
        log_success "[OK]   $url ($http_code, ${response_time}ms)"
        ((SUCCESSFUL_CHECKS++))
    else
        local error_msg=$(curl -s -m "$TIMEOUT" "$url" 2>&1 | head -1 || echo "connection failed")
        log_error "[FAIL] $url ($error_msg)"
        EXIT_CODE=1
    fi
    ((TOTAL_CHECKS++))
}

# Check all services
check_services() {
    if [ $# -eq 0 ]; then
        log_warning "No service URLs provided. Only system information will be displayed."
        return
    fi
    
    log "\n${BLUE}=== Service Health Checks ===${NC}"
    
    for url in "$@"; do
        check_service_health "$url"
    done
    
    log "\nResult: $SUCCESSFUL_CHECKS/$TOTAL_CHECKS services healthy"
}

# Show help
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [URL...]

Server diagnostics script that collects system information and checks service availability.

OPTIONS:
    --help              Show this help message and exit
    --timeout SECONDS   Set timeout for HTTP checks (default: $TIMEOUT)
    --log-file FILE     Set custom log file (default: $LOG_FILE)

EXAMPLES:
    $SCRIPT_NAME http://localhost:5000/health http://localhost:8080/health
    $SCRIPT_NAME --help
    $SCRIPT_NAME
    $SCRIPT_NAME --timeout 5 http://example.com/health

DESCRIPTION:
    This script collects comprehensive system information including:
    - System details (hostname, OS, kernel, uptime)
    - Resource usage (CPU, RAM, disk)
    - Docker container status (if available)
    - Service health checks for provided URLs
    
    All results are logged to $LOG_FILE with timestamps.
    The script exits with code 1 if any service check fails.

EOF
}

# Parse command line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            --log-file)
                LOG_FILE="$2"
                shift 2
                ;;
            http*://*)
                # URL argument, will be processed later
                shift
                ;;
            *)
                log_error "Unknown argument: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    # Store original arguments for service checks
    service_urls=""
    
    # Extract URLs from arguments
    for arg in "$@"; do
        case "$arg" in
            http*://*)
                service_urls="$service_urls $arg"
                ;;
        esac
    done
    
    # Parse other arguments
    parse_arguments "$@"
    
    # Check dependencies
    check_dependencies
    
    # Collect system information
    get_system_info
    get_resource_info
    get_docker_info
    
    # Check services
    check_services $service_urls
    
    # Exit with appropriate code
    exit $EXIT_CODE
}

# Run main function with all arguments
main "$@"