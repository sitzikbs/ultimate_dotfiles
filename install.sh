#!/bin/bash
#
# Dotfiles Installation Script
# One-command setup for a complete development environment
#
# This script:
# - Validates system requirements
# - Installs modern CLI tools
# - Sets up ZSH with Oh My Zsh and Powerlevel10k
# - Configures Tmux with Oh My Tmux
# - Manages dotfiles with GNU Stow
# - Applies Catppuccin theme across tools
#
# Usage: ./install.sh

set -euo pipefail

# =============================================================================
# INITIALIZATION
# =============================================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.sh"

# Load utilities
source "$SCRIPT_DIR/scripts/utils/helpers.sh"

# =============================================================================
# BANNER
# =============================================================================

show_banner() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║           🚀 Dotfiles Installation Script 🚀               ║"
    echo "║                                                            ║"
    echo "║  Setting up your development environment with:            ║"
    echo "║  • ZSH + Oh My Zsh + Powerlevel10k                         ║"
    echo "║  • Tmux + TPM + Catppuccin theme                           ║"
    echo "║  • Modern CLI tools (eza, bat, fzf, zoxide, etc.)          ║"
    echo "║  • Catppuccin Mocha theme                                  ║"
    echo "║  • Managed with GNU Stow                                   ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

main() {
    show_banner
    
    log_info "Starting dotfiles installation..."
    log_info "Installation directory: $SCRIPT_DIR"
    log_info "Target directory: $DOTFILES_TARGET_DIR"
    echo ""
    
    # Step 1: Check requirements and setup base system
    log_info "Step 1/7: Checking system requirements..."
    source "$SCRIPT_DIR/scripts/setup/base.sh"
    check_requirements || {
        log_error "System requirements check failed"
        exit 1
    }
    install_base_dependencies
    
    # Step 2: Setup dotfiles directory
    log_info "Step 2/7: Setting up dotfiles directory..."
    setup_dotfiles_directory "$SCRIPT_DIR" "$DOTFILES_TARGET_DIR"
    
    # Change to target directory for remaining operations
    cd "$DOTFILES_TARGET_DIR"
    
    # Step 3: Install CLI tools
    log_info "Step 3/7: Installing CLI tools..."
    source "$DOTFILES_TARGET_DIR/scripts/setup/packages.sh"
    install_cli_tools
    
    # Step 4: Setup ZSH
    log_info "Step 4/7: Setting up ZSH..."
    source "$DOTFILES_TARGET_DIR/scripts/setup/zsh.sh"
    main
    
    # Step 5: Stow dotfiles (must be done before tmux setup so .tmux.conf exists)
    log_info "Step 5/7: Stowing dotfiles..."
    stow_dotfiles
    
    # Step 6: Setup Tmux (after stowing so .tmux.conf exists)
    log_info "Step 6/7: Setting up Tmux..."
    source "$DOTFILES_TARGET_DIR/scripts/setup/tmux.sh"
    main
    
    # Step 7: Install themes
    log_info "Step 7/7: Installing themes..."
    source "$DOTFILES_TARGET_DIR/scripts/setup/themes.sh"
    main
    
    # Show completion message
    show_completion
}

# =============================================================================
# STOW MANAGEMENT
# =============================================================================

stow_dotfiles() {
    local stow_dir="$DOTFILES_TARGET_DIR/stow"
    
    if [[ ! -d "$stow_dir" ]]; then
        log_error "Stow directory not found: $stow_dir"
        return 1
    fi
    
    log_info "Stowing dotfiles packages..."
    
    for package in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$stow_dir/$package" ]]; then
            stow_package "$package" "$stow_dir"
        else
            log_warning "Package not found: $package"
        fi
    done
    
    log_success "All dotfiles stowed!"
}

# =============================================================================
# COMPLETION
# =============================================================================

show_completion() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              ✅ Installation Complete! ✅                  ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📋 What was installed:"
    echo "   • ZSH with Oh My Zsh and Powerlevel10k theme"
    echo "   • Tmux with TPM and Catppuccin theme"
    echo "   • Modern CLI tools: eza, bat, fzf, zoxide, fd, and more"
    echo "   • Catppuccin Mocha theme for consistent colors"
    echo "   • Git, Ranger, and other tool configurations"
    echo ""
    echo "🔧 Next steps:"
    echo "   1. Log out and log back in (or restart your session)"
    echo "   2. ZSH will be your default shell"
    echo "   3. Edit ~/.gitconfig to set your name and email"
    echo "   4. Run 'p10k configure' to customize your prompt (optional)"
    echo ""
    echo "📚 Optional:"
    echo "   • Set up environment variables: cp ~/.dotfiles/env.common ~/.env && chmod 600 ~/.env"
    echo "   • Install Python dev tools: ./scripts/setup_python_env.sh"
    echo "   • Customize config.sh to enable/disable features"
    echo "   • Add your own dotfiles to stow/ directory"
    echo ""
    echo "🎨 Theme customization:"
    echo "   • Tmux: Edit ~/.tmux.conf"
    echo "   • ZSH: Edit ~/.zshrc and ~/.p10k.zsh"
    echo "   • Git: Edit ~/.gitconfig"
    echo ""
    echo "⚡ Important:"
    echo "   • If tmux plugins didn't load automatically, press prefix + I (Ctrl+b then Shift+I) inside tmux"
    echo ""
    echo "🧪 Testing:"
    echo "   • Docker test: docker build -f test/Dockerfile.ubuntu -t dotfiles-test ."
    echo "   • Run tests: docker run -it --rm dotfiles-test"
    echo ""
    echo "Happy coding! 🎉"
    echo ""
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Trap errors and show helpful message
trap 'log_error "Installation failed at line $LINENO. Please check the error above."' ERR

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
