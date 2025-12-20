#!/bin/bash
#
# Tmux setup script
# Installs and configures Tmux with TPM (Tmux Plugin Manager)

set -euo pipefail

# Source utilities and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/helpers.sh"
source "$SCRIPT_DIR/../../config.sh"

install_tpm() {
    if [[ "$INSTALL_TPM" != "true" ]]; then
        log_info "TPM installation disabled in config"
        return 0
    fi
    
    local plugins_dir="$HOME/.tmux/plugins"
    local tpm_dir="$plugins_dir/tpm"
    
    log_info "Installing TPM (Tmux Plugin Manager)..."
    
    # Create plugins directory
    mkdir -p "$plugins_dir"
    
    # Clone or update TPM
    if [[ -d "$tpm_dir" ]] && [[ -d "$tpm_dir/.git" ]]; then
        log_debug "TPM already installed, updating..."
        cd "$tpm_dir"
        git pull --quiet
    else
        rm -rf "$tpm_dir"
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi
    
    log_success "TPM installed"
}

install_tmux_plugins() {
    if [[ ! -f "$HOME/.tmux.conf" ]]; then
        log_warning ".tmux.conf not found, plugins will install on first tmux launch"
        return 0
    fi
    
    log_info "Installing tmux plugins directly..."
    
    local plugins_dir="$HOME/.tmux/plugins"
    mkdir -p "$plugins_dir"
    
    # Define plugins to install (matching .tmux.conf)
    # Note: Using parallel arrays for Bash 3.2 compatibility (macOS default)
    local plugin_names=(
        "tmux-sensible"
        "catppuccin"
        "tmux-cpu"
        "tmux-resurrect"
        "tmux-continuum"
        "tmux-yank"
    )
    
    local plugin_urls=(
        "https://github.com/tmux-plugins/tmux-sensible"
        "https://github.com/catppuccin/tmux"
        "https://github.com/tmux-plugins/tmux-cpu"
        "https://github.com/tmux-plugins/tmux-resurrect"
        "https://github.com/tmux-plugins/tmux-continuum"
        "https://github.com/tmux-plugins/tmux-yank"
    )
    
    # Install each plugin
    for i in "${!plugin_names[@]}"; do
        local plugin_name="${plugin_names[$i]}"
        local plugin_url="${plugin_urls[$i]}"
        local plugin_dir="$plugins_dir/$plugin_name"
        
        if [[ -d "$plugin_dir" ]] && [[ -d "$plugin_dir/.git" ]]; then
            log_debug "$plugin_name already installed"
        else
            log_info "Installing $plugin_name..."
            rm -rf "$plugin_dir"
            if git clone --depth=1 "$plugin_url" "$plugin_dir" >/dev/null 2>&1; then
                # Make plugin scripts executable
                find "$plugin_dir" -name "*.tmux" -exec chmod +x {} \; 2>/dev/null || true
                find "$plugin_dir" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
                log_success "$plugin_name installed"
            else
                log_warning "Failed to install $plugin_name"
            fi
        fi
    done
    
    # Verify Catppuccin is installed (our main theme)
    if [[ -d "$plugins_dir/catppuccin" ]]; then
        log_success "All tmux plugins installed successfully!"
    else
        log_warning "Catppuccin theme installation may have failed"
    fi
    
    # Trigger TPM installation script to ensure everything is registered
    if [[ -x "$plugins_dir/tpm/bin/install_plugins" ]]; then
        log_info "Triggering TPM auto-install..."
        "$plugins_dir/tpm/bin/install_plugins" >/dev/null 2>&1 || true
    fi
}



# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║         Tmux Setup                     ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    install_tpm
    install_tmux_plugins
    
    log_info "Plugins are installed. TPM will load them automatically when tmux starts."
    log_success "Tmux setup complete!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
