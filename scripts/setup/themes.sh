#!/bin/bash
#
# Theme setup script
# Installs Catppuccin themes for bat and other tools

set -euo pipefail

# Source utilities and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/helpers.sh"
source "$SCRIPT_DIR/../../config.sh"

install_bat_theme() {
    if ! command_exists bat && ! command_exists batcat; then
        log_debug "bat not installed, skipping theme installation"
        return 0
    fi
    
    log_info "Installing Catppuccin theme for bat..."
    
    # Determine bat config directory
    local bat_dir
    if is_linux; then
        bat_dir="$HOME/.config/bat"
    elif is_macos; then
        bat_dir="$HOME/.config/bat"
    fi
    
    mkdir -p "$bat_dir/themes"
    
    # Download Catppuccin themes
    local theme_url="https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme"
    
    if [[ ! -f "$bat_dir/themes/Catppuccin-mocha.tmTheme" ]]; then
        log_info "Downloading Catppuccin Mocha theme..."
        if wget -q -O "$bat_dir/themes/Catppuccin-mocha.tmTheme" "$theme_url"; then
            # Rebuild bat cache
            if command_exists bat; then
                bat cache --build > /dev/null 2>&1 || log_warning "Failed to rebuild bat cache, but theme is installed"
            elif command_exists batcat; then
                batcat cache --build > /dev/null 2>&1 || log_warning "Failed to rebuild bat cache, but theme is installed"
            fi
            
            log_success "Catppuccin theme installed for bat"
        else
            log_warning "Failed to download Catppuccin theme for bat (network issue?), skipping..."
        fi
    else
        log_debug "Catppuccin theme already installed"
    fi
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║         Theme Setup                    ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    install_bat_theme
    
    log_success "Theme setup complete!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
