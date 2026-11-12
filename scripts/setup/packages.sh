#!/bin/bash
#
# Package installation script
# Installs CLI tools based on configuration

set -euo pipefail

# Source utilities and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/helpers.sh"
source "$SCRIPT_DIR/../../config.sh"

install_cli_tools() {
    log_info "Installing CLI tools..."
    
    if is_linux; then
        sudo apt-get update -qq
        
        # Build list of packages to install
        local packages=()
        
        [[ "$INSTALL_ZOXIDE" == "true" ]] && packages+=("zoxide")
        [[ "$INSTALL_FZF" == "true" ]] && packages+=("fzf")
        [[ "$INSTALL_RCLONE" == "true" ]] && packages+=("rclone")
        [[ "$INSTALL_TMUX" == "true" ]] && packages+=("tmux")
        [[ "$INSTALL_RANGER" == "true" ]] && packages+=("ranger")
        [[ "$INSTALL_AXEL" == "true" ]] && packages+=("axel")
        [[ "$INSTALL_NEOFETCH" == "true" ]] && packages+=("neofetch")
        [[ "$INSTALL_FFMPEG" == "true" ]] && packages+=("ffmpeg")
        [[ "$INSTALL_TLDR" == "true" ]] && packages+=("tldr")
        [[ "$INSTALL_NCDU" == "true" ]] && packages+=("ncdu")
        [[ "$INSTALL_RIPGREP" == "true" ]] && packages+=("ripgrep")
        
        # Install packages
        if [[ ${#packages[@]} -gt 0 ]]; then
            sudo apt-get install -y "${packages[@]}"
            log_success "Installed ${#packages[@]} packages via apt"
        fi
        
        # Install bat (special handling for Ubuntu)
        if [[ "$INSTALL_BAT" == "true" ]]; then
            install_bat_linux
        fi
        
        # Install btop (with fallback to PPA if needed)
        if [[ "$INSTALL_BTOP" == "true" ]]; then
            install_btop_linux
        fi
        
        # Install fd-find with symlink
        if [[ "$INSTALL_FD" == "true" ]]; then
            sudo apt-get install -y fd-find
            mkdir -p ~/.local/bin
            ln -sf "$(which fdfind)" ~/.local/bin/fd
            log_success "fd installed and symlinked"
        fi
        
        # Install eza (requires custom repository)
        if [[ "$INSTALL_EZA" == "true" ]]; then
            install_eza_linux
        fi
        
        # Install uv via official Astral installation script
        if [[ "$INSTALL_UV" == "true" ]]; then
            if ! command_exists uv; then
                log_info "Installing uv..."
                curl -LsSf https://astral.sh/uv/install.sh | sh
                log_success "uv installed"
            fi
        fi
        
    elif is_macos; then
        local packages=()
        
        [[ "$INSTALL_BAT" == "true" ]] && packages+=("bat")
        [[ "$INSTALL_ZOXIDE" == "true" ]] && packages+=("zoxide")
        [[ "$INSTALL_FZF" == "true" ]] && packages+=("fzf")
        [[ "$INSTALL_RCLONE" == "true" ]] && packages+=("rclone")
        [[ "$INSTALL_FD" == "true" ]] && packages+=("fd")
        [[ "$INSTALL_TMUX" == "true" ]] && packages+=("tmux")
        [[ "$INSTALL_RANGER" == "true" ]] && packages+=("ranger")
        [[ "$INSTALL_NEOFETCH" == "true" ]] && packages+=("neofetch")
        [[ "$INSTALL_FFMPEG" == "true" ]] && packages+=("ffmpeg")
        [[ "$INSTALL_TLDR" == "true" ]] && packages+=("tldr")
        [[ "$INSTALL_NCDU" == "true" ]] && packages+=("ncdu")
        [[ "$INSTALL_RIPGREP" == "true" ]] && packages+=("ripgrep")
        [[ "$INSTALL_BTOP" == "true" ]] && packages+=("btop")
        [[ "$INSTALL_EZA" == "true" ]] && packages+=("eza")
        [[ "$INSTALL_UV" == "true" ]] && packages+=("uv")
        [[ "$INSTALL_LAZYGIT" == "true" ]] && packages+=("lazygit")
        [[ "$INSTALL_LAZYDOCKER" == "true" ]] && packages+=("lazydocker")
        
        if [[ ${#packages[@]} -gt 0 ]]; then
            brew install "${packages[@]}"
            log_success "Installed ${#packages[@]} packages via Homebrew"
        fi
    fi
    
    # Install lazygit (Linux only, macOS uses Homebrew above)
    if [[ "$INSTALL_LAZYGIT" == "true" ]] && is_linux; then
        install_lazygit
    fi
    
    # Install lazydocker (Linux only, macOS uses Homebrew above)
    if [[ "$INSTALL_LAZYDOCKER" == "true" ]] && is_linux; then
        install_lazydocker
    fi

    # Install herdr (Linux and macOS, official installer -> ~/.local/bin)
    if [[ "${INSTALL_HERDR:-false}" == "true" ]]; then
        install_herdr
    fi
}

install_herdr() {
    local herdr_bin
    herdr_bin="$(command -v herdr 2>/dev/null || echo "$HOME/.local/bin/herdr")"

    if [[ -x "$herdr_bin" ]]; then
        log_debug "herdr already installed"
    else
        log_info "Installing herdr..."
        # Official installer: downloads the release binary, verifies SHA-256,
        # installs to ~/.local/bin. No sudo needed.
        if ! curl -fsSL https://herdr.dev/install.sh | sh; then
            log_warning "Could not install herdr. Install manually: https://herdr.dev/docs/install/"
            return 0
        fi
        herdr_bin="$HOME/.local/bin/herdr"
        log_success "herdr installed"
    fi

    # zsh completions (picked up via fpath in .zshrc)
    local comp_dir="$HOME/.local/share/zsh/completions"
    mkdir -p "$comp_dir"
    if "$herdr_bin" completion zsh > "$comp_dir/_herdr" 2>/dev/null; then
        log_success "herdr zsh completions installed"
    else
        rm -f "$comp_dir/_herdr"
        log_warning "Could not generate herdr completions"
    fi

    # Claude Code integration hook (agent state + session restore)
    if [[ "${HERDR_CLAUDE_INTEGRATION:-false}" == "true" ]] && [[ -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ]]; then
        if "$herdr_bin" integration install claude > /dev/null 2>&1; then
            log_success "herdr Claude Code integration installed"
        else
            log_warning "Could not install herdr Claude Code integration"
        fi
    fi
}

install_bat_linux() {
    if command_exists bat || command_exists batcat; then
        log_debug "bat already installed"
        return 0
    fi
    
    log_info "Installing bat..."
    
    if sudo apt-get install -y bat 2>/dev/null; then
        log_success "bat installed via apt"
    else
        # Try batcat (common on Ubuntu/Debian)
        if sudo apt-get install -y batcat 2>/dev/null; then
            # Create symlink for bat command
            mkdir -p ~/.local/bin
            ln -sf "$(which batcat)" ~/.local/bin/bat 2>/dev/null || true
            log_success "batcat installed and symlinked to bat"
        else
            log_warning "Failed to install bat via apt, trying manual installation..."
            install_bat_manual
        fi
    fi
}

install_bat_manual() {
    local version=$(get_latest_release "sharkdp/bat" 2>/dev/null || echo "0.24.0")
    local arch="x86_64"
    local url="https://github.com/sharkdp/bat/releases/download/v${version}/bat-v${version}-${arch}-unknown-linux-musl.tar.gz"
    
    local temp_dir=$(mktemp -d)
    if curl -sL "$url" | tar xz -C "$temp_dir" 2>/dev/null; then
        sudo cp "$temp_dir"/bat-*/bat /usr/local/bin/
        sudo chmod +x /usr/local/bin/bat
        rm -rf "$temp_dir"
        log_success "bat installed manually"
    else
        rm -rf "$temp_dir"
        log_warning "Could not install bat. You may install it manually later."
    fi
}

install_btop_linux() {
    if command_exists btop; then
        log_debug "btop already installed"
        return 0
    fi
    
    log_info "Installing btop..."
    
    # Try regular apt install first
    if sudo apt-get install -y btop 2>/dev/null; then
        log_success "btop installed via apt"
        return 0
    fi
    
    # If that fails, try adding PPA (for older Ubuntu versions)
    log_info "Trying btop from PPA..."
    if sudo add-apt-repository ppa:bashtop-monitor/bashtop -y 2>/dev/null && \
       sudo apt-get update -qq 2>/dev/null && \
       sudo apt-get install -y btop 2>/dev/null; then
        log_success "btop installed via PPA"
        return 0
    fi
    
    # Last resort: install from snap if available
    if command_exists snap; then
        log_info "Trying btop from snap..."
        if sudo snap install btop 2>/dev/null; then
            log_success "btop installed via snap"
            return 0
        fi
    fi
    
    log_warning "Could not install btop. You may install it manually later."
    log_info "Manual install: https://github.com/aristocratos/btop#installation"
}

install_eza_linux() {
    if command_exists eza; then
        log_debug "eza already installed"
        return 0
    fi
    
    log_info "Installing eza..."
    
    sudo apt-get install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
        sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg --yes
    
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
        sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq
    sudo apt-get install -y eza
    
    log_success "eza installed"
}

install_lazygit() {
    if command_exists lazygit; then
        log_debug "lazygit already installed"
        return 0
    fi
    
    log_info "Installing lazygit..."
    
    local version=$(get_latest_release "jesseduffield/lazygit")
    local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
    
    curl -sL "$url" | tar xz -C /tmp
    sudo mv /tmp/lazygit /usr/local/bin/
    
    log_success "lazygit installed"
}

install_lazydocker() {
    if command_exists lazydocker; then
        log_debug "lazydocker already installed"
        return 0
    fi
    
    log_info "Installing lazydocker..."
    
    local version=$(get_latest_release "jesseduffield/lazydocker")
    local url="https://github.com/jesseduffield/lazydocker/releases/download/v${version}/lazydocker_${version}_Linux_x86_64.tar.gz"
    
    curl -sL "$url" | tar xz -C /tmp
    sudo mv /tmp/lazydocker /usr/local/bin/
    
    log_success "lazydocker installed"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║     CLI Tools Installation             ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    install_cli_tools
    
    log_success "All CLI tools installed!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
