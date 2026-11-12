#!/bin/bash
#
# Dotfiles Configuration
# This file contains all configuration options for the dotfiles installation
# Modify these settings to customize what gets installed

# =============================================================================
# GENERAL SETTINGS
# =============================================================================

# Enable debug mode for verbose logging
DEBUG=${DEBUG:-false}

# Dotfiles installation directory (where files will be copied/linked from)
DOTFILES_TARGET_DIR="$HOME/.dotfiles"

# =============================================================================
# SHELL CONFIGURATION
# =============================================================================

# Install and configure ZSH
INSTALL_ZSH=true

# Install Oh My Zsh
INSTALL_OH_MY_ZSH=true

# Install ZSH plugins (autosuggestions, syntax-highlighting, etc.)
INSTALL_ZSH_PLUGINS=true

# Install Powerlevel10k theme
INSTALL_P10K=true

# Set ZSH as default shell
SET_ZSH_DEFAULT=true

# =============================================================================
# TERMINAL MULTIPLEXER
# =============================================================================

# Install Tmux
INSTALL_TMUX=true

# Install TPM (Tmux Plugin Manager) for plugin support
INSTALL_TPM=true

# =============================================================================
# MODERN CLI TOOLS
# =============================================================================

# eza - modern ls replacement with git integration
INSTALL_EZA=true

# bat - cat clone with syntax highlighting
INSTALL_BAT=true

# zoxide - smarter cd command
INSTALL_ZOXIDE=true

# fzf - fuzzy finder
INSTALL_FZF=true

# rclone - cloud storage CLI
INSTALL_RCLONE=true

# fd - modern find alternative
INSTALL_FD=true

# btop - resource monitor
INSTALL_BTOP=true

# ranger - console file manager
INSTALL_RANGER=true

# axel - download accelerator
INSTALL_AXEL=true

# neofetch - system info display
INSTALL_NEOFETCH=true

# ffmpeg - multimedia processing
INSTALL_FFMPEG=true

# tldr - simplified man pages
INSTALL_TLDR=true

# ncdu - disk usage analyzer
INSTALL_NCDU=true

# uv - fast Python package manager
INSTALL_UV=true

# lazygit - terminal UI for git
INSTALL_LAZYGIT=true

# lazydocker - terminal UI for docker
INSTALL_LAZYDOCKER=true

# ripgrep - fast grep alternative
INSTALL_RIPGREP=true

# herdr - terminal multiplexer for AI coding agents (https://herdr.dev)
INSTALL_HERDR=true

# Install/refresh herdr's Claude Code hook (only if ~/.claude exists)
HERDR_CLAUDE_INTEGRATION=true

# 1Password desktop app + CLI (op), from 1Password's official repo
INSTALL_1PASSWORD=true

# =============================================================================
# FONTS
# =============================================================================

# Install Nerd Fonts (required for proper theme display)
INSTALL_FONTS=true

# Font to install (MesloLGS NF is recommended for Powerlevel10k)
FONT_NAME="MesloLGS NF"

# =============================================================================
# STOW PACKAGES
# =============================================================================

# Dotfiles to manage with GNU Stow
# Add or remove packages as needed
STOW_PACKAGES=(
    "zsh"
    "tmux"
    "git"
    "ranger"
    "vscode"
)

# =============================================================================
# THEME SETTINGS
# =============================================================================

# Color theme for compatible tools (bat, fzf, tmux)
# Options: catppuccin-mocha, catppuccin-macchiato, catppuccin-frappe, catppuccin-latte
THEME="catppuccin-mocha"

# =============================================================================
# OPTIONAL COMPONENTS
# =============================================================================

# Install Python development environment (separate script)
INSTALL_PYTHON_ENV=false
