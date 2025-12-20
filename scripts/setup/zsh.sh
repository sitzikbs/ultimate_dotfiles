#!/bin/bash
#
# ZSH setup script
# Installs and configures ZSH, Oh My Zsh, Powerlevel10k, and plugins

set -euo pipefail

# Source utilities and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/helpers.sh"
source "$SCRIPT_DIR/../../config.sh"

install_zsh() {
    if [[ "$INSTALL_ZSH" != "true" ]]; then
        log_info "ZSH installation disabled in config"
        return 0
    fi
    
    log_info "Installing ZSH..."
    
    if is_linux; then
        sudo apt-get update -qq
        sudo apt-get install -y zsh
    elif is_macos; then
        # ZSH comes pre-installed on modern macOS
        if ! command_exists zsh; then
            brew install zsh
        fi
    fi
    
    log_success "ZSH installed"
}

install_oh_my_zsh() {
    if [[ "$INSTALL_OH_MY_ZSH" != "true" ]]; then
        log_info "Oh My Zsh installation disabled in config"
        return 0
    fi
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_debug "Oh My Zsh already installed"
        return 0
    fi
    
    log_info "Installing Oh My Zsh..."
    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    log_success "Oh My Zsh installed"
}

install_powerlevel10k() {
    if [[ "$INSTALL_P10K" != "true" ]]; then
        log_info "Powerlevel10k installation disabled in config"
        return 0
    fi
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$p10k_dir" ]]; then
        log_debug "Powerlevel10k already installed"
        return 0
    fi
    
    log_info "Installing Powerlevel10k theme..."
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    
    log_success "Powerlevel10k installed"
}

install_zsh_plugins() {
    if [[ "$INSTALL_ZSH_PLUGINS" != "true" ]]; then
        log_info "ZSH plugins installation disabled in config"
        return 0
    fi
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Install zsh-autosuggestions
    if [[ ! -d "$custom_dir/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
            "$custom_dir/plugins/zsh-autosuggestions"
    fi
    
    # Install zsh-syntax-highlighting
    if [[ ! -d "$custom_dir/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$custom_dir/plugins/zsh-syntax-highlighting"
    fi
    
    log_success "ZSH plugins installed"
}

install_fonts() {
    if [[ "$INSTALL_FONTS" != "true" ]]; then
        log_info "Font installation disabled in config"
        return 0
    fi
    
    log_info "Installing Nerd Fonts..."
    
    local font_dir
    if is_linux; then
        font_dir="$HOME/.local/share/fonts"
    elif is_macos; then
        font_dir="$HOME/Library/Fonts"
    fi
    
    mkdir -p "$font_dir"
    
    # MesloLGS NF fonts for Powerlevel10k
    local fonts=(
        "MesloLGS%20NF%20Regular.ttf"
        "MesloLGS%20NF%20Bold.ttf"
        "MesloLGS%20NF%20Italic.ttf"
        "MesloLGS%20NF%20Bold%20Italic.ttf"
    )
    
    for font in "${fonts[@]}"; do
        local_name=$(echo "$font" | sed 's/%20/ /g')
        if [[ ! -f "$font_dir/$local_name" ]]; then
            log_info "Downloading $local_name..."
            wget -q -P "$font_dir" "https://github.com/romkatv/powerlevel10k-media/raw/master/$font"
        fi
    done
    
    # Refresh font cache
    if is_linux && command_exists fc-cache; then
        fc-cache -f -v > /dev/null 2>&1
    fi
    
    log_success "Fonts installed"
}

set_default_shell() {
    if [[ "$SET_ZSH_DEFAULT" != "true" ]]; then
        log_info "Setting ZSH as default shell disabled in config"
        return 0
    fi
    
    # Get current user (USER variable might not be set in all environments)
    local current_user="${USER:-$(whoami)}"
    local current_shell=$(getent passwd "$current_user" | cut -d: -f7)
    local zsh_path=$(which zsh)
    
    if [[ "$current_shell" == "$zsh_path" ]]; then
        log_success "ZSH is already the default shell"
        return 0
    fi
    
    log_info "Setting ZSH as default shell..."
    
    if sudo chsh -s "$zsh_path" "$current_user" 2>/dev/null; then
        log_success "Default shell changed to ZSH (logout/login to activate)"
    else
        log_warning "Could not change default shell automatically"
        log_info "To change manually, run: sudo chsh -s $zsh_path"
    fi
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║         ZSH Setup                      ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    install_fonts
    set_default_shell
    
    log_success "ZSH setup complete!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
