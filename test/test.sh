#!/bin/bash
#
# Test script for dotfiles installation
# Validates that all expected tools and configurations are present

set -u

echo "╔════════════════════════════════════════╗"
echo "║  Dotfiles Installation Test Suite     ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

# Test function
test_command() {
    local cmd=$1
    local name=${2:-$cmd}
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name is installed"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} $name is NOT installed"
        ((TESTS_FAILED++))
    fi
}

# Test file exists
test_file() {
    local file=$1
    local name=${2:-$file}
    
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        echo -e "${GREEN}✓${NC} $name exists"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name does NOT exist"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test directory exists
test_dir() {
    local dir=$1
    local name=${2:-$dir}
    
    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $name exists"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $name does NOT exist"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test optional command (warn if missing)
test_optional_command() {
    local cmd=$1
    local name=${2:-$cmd}
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name is installed"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $name is NOT installed (optional)"
        ((WARNINGS++))
        return 1
    fi
}

echo "📦 Testing installed packages..."
test_command zsh "ZSH"
test_command git "Git"
test_command tmux "Tmux"
test_command fzf "FZF"
# bat is installed as batcat on Ubuntu/Debian
if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
    echo -e "${GREEN}✓${NC} Bat is installed"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Bat is NOT installed"
    ((TESTS_FAILED++))
fi
test_command zoxide "Zoxide"
test_command eza "Eza"
test_command rclone "Rclone"
test_command btop "Btop"
test_command ranger "Ranger"
test_command neofetch "Neofetch"
test_command lazygit "Lazygit"
test_command lazydocker "Lazydocker"

echo ""
echo "📂 Testing configuration files..."
test_file "$HOME/.zshrc" ".zshrc"
test_file "$HOME/.p10k.zsh" ".p10k.zsh"
test_file "$HOME/.tmux.conf" ".tmux.conf"
test_file "$HOME/.gitconfig" ".gitconfig"
test_dir "$HOME/.oh-my-zsh" "Oh My Zsh"
test_dir "$HOME/.tmux/plugins/tpm" "TPM (Tmux Plugin Manager)"

echo ""
echo "🔗 Testing stow symlinks..."
if [[ -L "$HOME/.zshrc" ]]; then
    echo -e "${GREEN}✓${NC} .zshrc is a symlink"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} .zshrc is NOT a symlink"
    ((TESTS_FAILED++))
fi

if [[ -L "$HOME/.p10k.zsh" ]]; then
    echo -e "${GREEN}✓${NC} .p10k.zsh is a symlink"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} .p10k.zsh is NOT a symlink"
    ((TESTS_FAILED++))
fi

if [[ -L "$HOME/.tmux.conf" ]]; then
    echo -e "${GREEN}✓${NC} .tmux.conf is a symlink"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} .tmux.conf is NOT a symlink"
    if [[ -f "$HOME/.tmux.conf" ]]; then
        echo "  ⚠️  File exists but is not a symlink"
    fi
    ((TESTS_FAILED++))
fi

echo ""
echo "🎨 Testing tmux plugins..."
# Check if catppuccin theme is installed
if [[ -d "$HOME/.tmux/plugins/catppuccin" ]]; then
    echo -e "${GREEN}✓${NC} Catppuccin tmux theme is installed"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} Catppuccin tmux theme is NOT installed"
    echo "  ℹ️  Plugins may install on first tmux launch"
    ((TESTS_FAILED++))
fi

echo ""
echo "🐚 Testing shell configuration..."
if [[ "$SHELL" == *"zsh"* ]] || [[ -n "$ZSH_VERSION" ]]; then
    echo -e "${GREEN}✓${NC} ZSH is the current shell"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} ZSH is NOT the current shell"
    ((TESTS_FAILED++))
fi

# Test init-project script
if [[ -x "$HOME/.dotfiles/scripts/init-project.sh" ]]; then
    echo -e "${GREEN}✓${NC} init-project script is executable"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠${NC} init-project script not found or not executable"
    ((WARNINGS++))
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║         Test Results Summary           ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ Passed:  $TESTS_PASSED${NC}"
echo -e "${RED}✗ Failed:  $TESTS_FAILED${NC}"
echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      🎉 All Tests Passed! 🎉          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}Note: Some optional packages were not installed${NC}"
        echo -e "${YELLOW}This is normal and doesn't affect core functionality${NC}"
    fi
    
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║      ❌ Some Tests Failed ❌          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please review the errors above and check installation logs"
    exit 1
fi
