#!/bin/bash
#
# Python Development Environment Setup
# This script installs Python development tools and packages

setup_python_environment() {
    echo "🐍 Setting up Python development environment..."
    echo ""
    echo "⚠️  WARNING: This will install Python packages and may conflict with existing environments!"
    echo "   Make sure this won't clash with your Docker container's Python setup."
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Python environment setup cancelled"
        return 0
    fi
    
    # Install Python and essential tools
    echo "📦 Installing Python and development tools..."
    local python_packages=(
        "python3"
        "python3-pip"
        "python3-venv"
        "python3-dev"
        "build-essential"
        "software-properties-common"
    )
    
    # Check which packages need to be installed
    local packages_to_install=()
    for package in "${python_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            packages_to_install+=("$package")
        fi
    done
    
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo "Installing: ${packages_to_install[*]}"
        sudo apt update -qq
        sudo apt install -y "${packages_to_install[@]}"
    else
        echo "✅ All Python packages already installed"
    fi
    
    # Install/upgrade pip tools
    echo "🔧 Setting up Python package managers..."
    python3 -m pip install --user --upgrade pip setuptools wheel
    
    # Install common development packages
    echo "📚 Installing common Python development packages..."
    local pip_packages=(
        "virtualenv"
        "virtualenvwrapper"
        "pipx"
        "poetry"
        "black"
        "flake8"
        "mypy"
        "pytest"
        "ipython"
        "jupyter"
        "requests"
        "python-dotenv"
    )
    
    # Read additional packages from config if available
    local python_config="$DOTFILES_DIR/config/python-packages.conf"
    if [[ -f "$python_config" ]]; then
        echo "📋 Loading additional packages from configuration..."
        while IFS= read -r package || [[ -n "$package" ]]; do
            # Skip empty lines and comments
            [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue
            pip_packages+=("$package")
        done < "$python_config"
    fi
    
    # Install pip packages
    for package in "${pip_packages[@]}"; do
        if ! python3 -m pip show "$package" &>/dev/null; then
            echo "Installing $package..."
            python3 -m pip install --user "$package"
        else
            echo "✅ $package already installed"
        fi
    done
    
    # Setup pipx path if not already in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "🔧 Adding ~/.local/bin to PATH for pipx..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
    
    # Install useful tools via pipx
    echo "🛠️  Installing development tools via pipx..."
    local pipx_tools=(
        "httpie"
        "rich-cli"
        "cookiecutter"
        "uv"
    )
    
    for tool in "${pipx_tools[@]}"; do
        if ! pipx list | grep -q "$tool"; then
            echo "Installing $tool via pipx..."
            python3 -m pipx install "$tool"
        else
            echo "✅ $tool already installed"
        fi
    done
    
    echo "✅ Python development environment setup complete!"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    setup_python_environment
fi
