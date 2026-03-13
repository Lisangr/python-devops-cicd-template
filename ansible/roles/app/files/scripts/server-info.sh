#!/bin/bash

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

# Counters for health checks
TOTAL_CHECKS=0
SUCCESSFUL_CHECKS=0

# Logging functions
log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[INFO]${NC} $message"
    echo "[$timestamp] [INFO] $message" >> "$LOG_FILE"
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR]${NC} $message"
    echo "[$timestamp] [ERROR] $message" >> "$LOG_FILE"
}

log_warning() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARNING]${NC} $message"
    echo "[$timestamp] [WARNING] $message" >> "$LOG_FILE"
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Get system information
get_system_info() {
    echo -e "${BLUE}=== System Information ===${NC}"
    
    # CPU info
    local cpu_cores=$(nproc)
    echo "CPU Cores: $cpu_cores"
    
    # Memory info
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')
    echo "Load Average: $load_avg"
    
    # RAM info
    if command -v free &> /dev/null; then
        local ram_info=$(free -h | awk '/Mem:/ {printf "%.1fG / %.1fG (%.0f%%)", $3, $2, $3/$2*100}')
        echo "Memory Usage: $ram_info"
    fi
    
    # Disk info
    if command -v df &> /dev/null; then
        local disk_info=$(df -h / | awk 'NR==2 {printf "%s / %s (%.0f%%)", $3, $2, $3/$2*100}')
        echo "Disk Usage: $disk_info"
    fi
    
    echo ""
}

# Get Docker information
get_docker_info() {
    echo -e "${BLUE}=== Docker Information ===${NC}"
    
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        local docker_ps=$(docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}' 2>/dev/null || echo "Could not get container list")
        echo "Running Containers:"
        echo "$docker_ps"
    else
        log_warning "Docker is not running or not accessible"
    fi
    
    echo ""
}

# Check service health
check_service() {
    local url="$1"
    local start_time=$(date +%s%3N)
    
    log_info "Checking service: $url"
    
    if curl -s -f -m "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -q "200"; then
        local end_time=$(date +%s%3N)
        local response_time=$((end_time - start_time))
        log_info "✓ Service is healthy (Response time: ${response_time}ms)"
        ((SUCCESSFUL_CHECKS++))
    else
        local error_msg=$(curl -s -m "$TIMEOUT" "$url" 2>&1 | head -1 || echo "connection failed")
        log_error "✗ Service is unhealthy: $error_msg"
    fi
    
    ((TOTAL_CHECKS++))
}

# Check multiple services
check_services() {
    local service_urls="$1"
    
    echo -e "${BLUE}=== Service Health Checks ===${NC}"
    
    # Default services to check
    if [ -z "$service_urls" ]; then
        service_urls="http://localhost:5000/health"
    fi
    
    for url in $service_urls; do
        check_service "$url"
    done
    
    echo ""
    echo -e "${BLUE}=== Health Check Summary ===${NC}"
    echo "Total checks: $TOTAL_CHECKS"
    echo "Successful checks: $SUCCESSFUL_CHECKS"
    echo "Failed checks: $((TOTAL_CHECKS - SUCCESSFUL_CHECKS))"
    
    if [ $SUCCESSFUL_CHECKS -eq $TOTAL_CHECKS ]; then
        echo -e "${GREEN}All services are healthy!${NC}"
    else
        echo -e "${RED}Some services are unhealthy!${NC}"
    fi
}

# Main function
main() {
    echo -e "${BLUE}=== Server Diagnostics ===${NC}"
    echo "Script: $SCRIPT_NAME"
    echo "Timestamp: $(date)"
    echo ""
    
    # Initialize log file
    echo "=== Server Diagnostics Started at $(date) ===" > "$LOG_FILE"
    
    # Check dependencies
    check_dependencies
    
    # Get system information
    get_system_info
    
    # Get Docker information
    get_docker_info
    
    # Check services
    check_services "$@"
    
    echo -e "${BLUE}=== Diagnostics Complete ===${NC}"
    echo "Log file: $LOG_FILE"
}

# Run main function with all arguments
main "$@"
