#!/bin/bash
#
# Docker container entrypoint for testing dotfiles installation
# This script copies mounted dotfiles and runs the installation

set -euo pipefail

# Check if dotfiles are mounted
if [[ ! -d "/dotfiles" ]]; then
    echo "ERROR: Dotfiles directory not mounted at /dotfiles"
    echo "Run with: docker run -v \$(pwd):/dotfiles:ro ..."
    exit 1
fi

# Copy dotfiles to home directory
echo "Copying dotfiles from /dotfiles to ~/.dotfiles..."
rsync -a --exclude='.git' /dotfiles/ "$HOME/.dotfiles/"

cd "$HOME/.dotfiles"

# Ensure all scripts are executable
chmod +x test/*.sh scripts/*.sh scripts/setup/*.sh scripts/utils/*.sh 2>/dev/null || true

# Determine what to do based on command
CMD="${1:-test}"

case "$CMD" in
    test)
        echo "Running installation..."
        ./install.sh
        echo ""
        echo "Running test suite..."
        ./test/test.sh
        ;;
    install)
        echo "Running installation only..."
        ./install.sh
        ;;
    zsh)
        echo "Installation complete, starting ZSH..."
        ./install.sh
        exec zsh -l
        ;;
    bash)
        echo "Starting bash for debugging..."
        exec bash
        ;;
    *)
        # Execute custom command
        echo "Running custom command: $*"
        ./install.sh
        exec "$@"
        ;;
esac

