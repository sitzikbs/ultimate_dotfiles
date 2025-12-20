#!/bin/bash
#
# Automated test runner for dotfiles across multiple platforms
# This script builds Docker images and runs comprehensive tests

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
declare -a FAILED_TESTS

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

show_banner() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║           Dotfiles Test Suite                             ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

test_platform() {
    local platform=$1
    local dockerfile=$2
    local image_name="dotfiles-test-$platform"
    
    echo ""
    log_info "════════════════════════════════════════════════════════"
    log_info "Testing: $platform"
    log_info "════════════════════════════════════════════════════════"
    
    # Build image
    log_info "Building Docker image for $platform..."
    if docker build -f "$dockerfile" -t "$image_name" . > /dev/null 2>&1; then
        log_success "Image built successfully"
    else
        log_error "Failed to build image for $platform"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$platform: Image build failed")
        return 1
    fi
    
    # Run installation and tests
    log_info "Running installation and automated tests..."
    if docker run --rm -v "$(pwd):/dotfiles:ro" "$image_name" test; then
        log_success "$platform tests passed"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Prompt for visual confirmation
        echo ""
        log_info "Visual confirmation required for $platform"
        log_info "Starting interactive ZSH session..."
        log_info "Please verify:"
        echo "  1. Powerlevel10k prompt displays correctly"
        echo "  2. Colors are properly themed (Catppuccin)"
        echo "  3. Run 'tmux' and check the status bar theme"
        echo "  4. Try: ls, cat <file>, btop, lazygit"
        echo "  5. Type 'exit' when done"
        echo ""
        read -p "Press ENTER to start interactive session..."
        
        docker run -it --rm -v "$(pwd):/dotfiles:ro" "$image_name" zsh
        
        echo ""
        read -p "Did everything look correct? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_warning "Visual confirmation failed for $platform"
            FAILED_TESTS+=("$platform: Visual confirmation failed")
        else
            log_success "Visual confirmation passed for $platform"
        fi
    else
        log_error "$platform tests failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$platform: Automated tests failed")
        return 1
    fi
}

cleanup_images() {
    log_info "Cleaning up Docker images..."
    docker images --filter "reference=dotfiles-test-*" -q | xargs -r docker rmi -f > /dev/null 2>&1 || true
    log_success "Cleanup complete"
}

show_results() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║           Test Results                                    ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    log_success "Passed: $TESTS_PASSED"
    log_error "Failed: $TESTS_FAILED"
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo ""
        log_error "Failed tests:"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
    fi
    
    echo ""
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log_success "🎉 All tests passed!"
        return 0
    else
        log_error "❌ Some tests failed"
        return 1
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    show_banner
    
    # Parse arguments
    PLATFORMS=()
    CLEANUP=true
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --ubuntu|ubuntu)
                PLATFORMS+=("ubuntu")
                shift
                ;;
            --ubuntu-latest|ubuntu-latest)
                PLATFORMS+=("ubuntu-latest")
                shift
                ;;
            --debian|debian)
                PLATFORMS+=("debian")
                shift
                ;;
            --all|all)
                PLATFORMS=("ubuntu" "ubuntu-latest" "debian")
                shift
                ;;
            --no-cleanup)
                CLEANUP=false
                shift
                ;;
            -h|--help)
                cat << EOF
Dotfiles Test Suite

Usage: $0 [OPTIONS] [PLATFORMS]

Platforms:
    ubuntu          Test on Ubuntu 22.04 LTS
    ubuntu-latest   Test on Ubuntu 24.04 LTS
    debian          Test on Debian 12 (Bookworm)
    all             Test on all platforms (default)

Options:
    --no-cleanup    Don't remove Docker images after testing
    -h, --help      Show this help message

Examples:
    $0                      # Test all platforms
    $0 ubuntu               # Test only Ubuntu 22.04
    $0 ubuntu debian        # Test Ubuntu and Debian
    $0 --all --no-cleanup   # Test all, keep images

EOF
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Default to all platforms if none specified
    if [[ ${#PLATFORMS[@]} -eq 0 ]]; then
        PLATFORMS=("ubuntu" "ubuntu-latest" "debian")
    fi
    
    log_info "Testing platforms: ${PLATFORMS[*]}"
    echo ""
    
    # Run tests for each platform
    for platform in "${PLATFORMS[@]}"; do
        case $platform in
            ubuntu)
                test_platform "ubuntu" "test/Dockerfile.ubuntu"
                ;;
            ubuntu-latest)
                test_platform "ubuntu-latest" "test/Dockerfile.ubuntu-latest"
                ;;
            debian)
                test_platform "debian" "test/Dockerfile.debian"
                ;;
            *)
                log_error "Unknown platform: $platform"
                ;;
        esac
    done
    
    # Cleanup
    if [[ "$CLEANUP" == "true" ]]; then
        echo ""
        cleanup_images
    fi
    
    # Show final results
    show_results
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running"
    exit 1
fi

main "$@"

