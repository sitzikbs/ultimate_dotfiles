#!/bin/bash
#
# Shared utility functions for dotfiles installation scripts

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

log_debug() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "\033[0;35m[DEBUG]\033[0m $1"
    fi
}

# =============================================================================
# SYSTEM DETECTION
# =============================================================================

detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

is_linux() {
    [[ "$(detect_os)" == "linux" ]]
}

is_macos() {
    [[ "$(detect_os)" == "macos" ]]
}

# =============================================================================
# PACKAGE MANAGEMENT
# =============================================================================

command_exists() {
    command -v "$1" &> /dev/null
}

install_package() {
    local package=$1
    local name=${2:-$package}
    
    if command_exists "$package"; then
        log_debug "$name is already installed"
        return 0
    fi
    
    log_info "Installing $name..."
    
    if is_linux; then
        sudo apt-get install -y "$package" &> /dev/null || {
            log_error "Failed to install $name"
            return 1
        }
    elif is_macos; then
        brew install "$package" &> /dev/null || {
            log_error "Failed to install $name"
            return 1
        }
    fi
    
    log_success "$name installed"
}

# =============================================================================
# FILE OPERATIONS
# =============================================================================

backup_file() {
    local file=$1
    local backup_dir="${2:-$HOME/.dotfiles-backup}"
    
    if [[ -e "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$backup_dir"
        local backup_name="$(basename "$file").backup.$(date +%Y%m%d%H%M%S)"
        log_warning "Backing up $file to $backup_dir/$backup_name"
        mv "$file" "$backup_dir/$backup_name"
    fi
}

ensure_dir() {
    local dir=$1
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_debug "Created directory: $dir"
    fi
}

# =============================================================================
# GITHUB UTILITIES
# =============================================================================

get_latest_release() {
    local repo=$1
    curl -s "https://api.github.com/repos/$repo/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/' | \
        sed 's/v//'
}

download_and_extract() {
    local url=$1
    local dest=$2
    
    log_info "Downloading from $url..."
    curl -sL "$url" | tar xz -C "$dest"
}

# =============================================================================
# STOW UTILITIES
# =============================================================================

stow_package() {
    local package=$1
    local stow_dir=$2
    local target_dir=${3:-$HOME}
    
    log_info "Stowing $package..."
    
    # Backup any conflicting files
    while IFS= read -r -d '' file; do
        local rel_file="${file#$stow_dir/$package}"
        local target="$target_dir$rel_file"
        if [[ -e "$target" ]] || [[ -L "$target" ]]; then
            backup_file "$target"
        fi
    done < <(find "$stow_dir/$package" -type f -print0 2>/dev/null)
    
    # Stow the package
    cd "$stow_dir/.." || return 1
    stow -d stow -t "$target_dir" "$package" 2>/dev/null || {
        log_error "Failed to stow $package"
        return 1
    }
    
    log_success "$package stowed successfully"
}

# =============================================================================
# VALIDATION
# =============================================================================

require_command() {
    local cmd=$1
    local name=${2:-$cmd}
    
    if ! command_exists "$cmd"; then
        log_error "$name is required but not installed"
        return 1
    fi
}

check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_error "No internet connection detected"
        return 1
    fi
}
