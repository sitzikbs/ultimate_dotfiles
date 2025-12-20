#!/bin/bash
#
# Base system setup and requirements checking
# This script validates system requirements and sets up the base environment

set -euo pipefail

# Source utilities (use local variable to avoid overwriting caller's SCRIPT_DIR)
_BASE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_BASE_SCRIPT_DIR/../utils/helpers.sh"

check_requirements() {
    log_info "Checking system requirements..."
    
    local requirements_met=true
    
    # Detect OS
    local os_type=$(detect_os)
    case "$os_type" in
        linux)
            log_success "Linux detected"
            export OS_TYPE="linux"
            ;;
        macos)
            log_success "macOS detected"
            export OS_TYPE="macos"
            ;;
        *)
            log_error "Unsupported OS. This setup requires Linux or macOS."
            return 1
            ;;
    esac
    
    # Check essential commands
    local required_commands=("curl" "git" "wget" "grep" "sed")
    for cmd in "${required_commands[@]}"; do
        if command_exists "$cmd"; then
            log_success "$cmd is available"
        else
            log_error "$cmd is required but not found"
            requirements_met=false
        fi
    done
    
    # Check package manager
    if is_linux; then
        if command_exists apt; then
            log_success "apt package manager detected"
        else
            log_error "apt package manager not found (Ubuntu/Debian required)"
            requirements_met=false
        fi
    elif is_macos; then
        if ! command_exists brew; then
            log_warning "Homebrew not found - will be installed automatically"
            install_homebrew
        else
            log_success "Homebrew detected"
        fi
    fi
    
    # Check disk space (at least 500MB free)
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [[ $available_space -gt 500000 ]]; then
        log_success "Sufficient disk space available"
    else
        log_warning "Low disk space: $(($available_space/1024))MB available"
    fi
    
    # Check internet connectivity
    if check_internet; then
        log_success "Internet connection verified"
    else
        log_warning "Internet connection may be limited"
    fi
    
    if [[ "$requirements_met" == "true" ]]; then
        log_success "All requirements met!"
        return 0
    else
        log_error "Some requirements are missing"
        return 1
    fi
}

install_homebrew() {
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

install_base_dependencies() {
    log_info "Installing base dependencies..."
    
    if is_linux; then
        sudo apt-get update -qq
        sudo apt-get install -y \
            build-essential \
            software-properties-common \
            stow \
            dos2unix \
            unzip
    elif is_macos; then
        brew install stow
    fi
    
    log_success "Base dependencies installed"
}

setup_dotfiles_directory() {
    local source_dir="$1"
    local target_dir="$2"
    
    log_info "Setting up dotfiles directory at $target_dir..."
    
    # Expand ~ to $HOME and remove trailing slashes for consistent comparison
    source_dir="${source_dir/#\~/$HOME}"
    target_dir="${target_dir/#\~/$HOME}"
    source_dir="${source_dir%/}"
    target_dir="${target_dir%/}"
    
    # If source and target are the same, skip syncing
    if [[ "$source_dir" == "$target_dir" ]]; then
        log_info "Dotfiles already at target location ($target_dir), skipping sync"
        return 0
    fi
    
    # Verify source directory exists
    if [[ ! -d "$source_dir" ]]; then
        log_error "Source directory not found: $source_dir"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    ensure_dir "$target_dir"
    
    # Copy dotfiles to target location
    log_info "Syncing dotfiles from $source_dir to $target_dir..."
    rsync -a --delete "$source_dir/" "$target_dir/" \
        --exclude '.git' \
        --exclude '.gitignore' \
        --exclude 'test/'
    
    log_success "Dotfiles synced to $target_dir"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  Dotfiles Base Setup & Requirements   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    check_requirements || exit 1
    install_base_dependencies
    
    log_success "Base setup complete!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
