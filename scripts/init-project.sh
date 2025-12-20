#!/bin/bash
#
# Initialize Project with Dotfiles Configurations
# Copies .github and .vscode configurations to a new or existing project
# For fresh projects: initializes git and sets up uv for Python
#
# Usage:
#   ./init-project.sh [project-directory]
#   ./init-project.sh --fresh                    # Fresh project in current dir
#   ./init-project.sh --fresh ~/my-new-project   # Fresh project in specific dir
#   ./init-project.sh ~/existing-project         # Existing project

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
TEMPLATES_DIR="$DOTFILES_DIR/stow/vscode"
GITHUB_DIR="$DOTFILES_DIR/.github"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# =============================================================================
# FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    cat << EOF
Initialize Project with Dotfiles Configurations

Usage:
    $(basename "$0") [OPTIONS] [PROJECT_DIR]

Arguments:
    PROJECT_DIR     Directory to initialize (default: current directory)

Options:
    -h, --help      Show this help message
    --fresh         Initialize a fresh project (git init + uv setup)
    --existing      Initialize existing project (default, just copy configs)
    -f, --force     Overwrite existing files without prompting
    -n, --no-backup Skip backup of existing files

Project Types:
    Fresh Project (--fresh):
        - Runs git init
        - Sets up uv for Python package management
        - Copies .vscode and .github configurations
    
    Existing Project (default):
        - Copies .vscode and .github configurations only

What gets copied:
    .vscode/settings.json       VSCode workspace settings
    .vscode/extensions.json     Recommended VSCode extensions
    .github/copilot-instructions.md  GitHub Copilot instructions

Examples:
    $(basename "$0")                        # Existing project, current dir
    $(basename "$0") --fresh                # Fresh project, current dir
    $(basename "$0") --fresh ~/my-project   # Fresh project, specific dir
    $(basename "$0") ~/existing-project     # Existing project, specific dir
    $(basename "$0") -f --fresh .           # Force fresh project in current dir

EOF
}

backup_file() {
    local file="$1"
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -e "$file" ]]; then
        if [[ "$NO_BACKUP" == "false" ]]; then
            cp "$file" "$backup"
            log_info "Backed up $file to $backup"
        fi
    fi
}

copy_file() {
    local src="$1"
    local dest="$2"
    local file_type="$3"
    
    if [[ ! -f "$src" ]]; then
        log_warning "$file_type not found at $src, skipping"
        return
    fi
    
    # Create destination directory if needed
    mkdir -p "$(dirname "$dest")"
    
    # Check if file exists
    if [[ -f "$dest" ]]; then
        if [[ "$FORCE" == "true" ]]; then
            backup_file "$dest"
            cp "$src" "$dest"
            log_success "Overwrote $dest"
        else
            log_warning "$dest already exists"
            read -p "Overwrite? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                backup_file "$dest"
                cp "$src" "$dest"
                log_success "Overwrote $dest"
            else
                log_info "Skipped $dest"
            fi
        fi
    else
        cp "$src" "$dest"
        log_success "Created $dest"
    fi
}

init_git() {
    local project_dir="$1"
    
    if [[ -d "$project_dir/.git" ]]; then
        log_info "Git repository already initialized"
        return
    fi
    
    log_info "Initializing git repository..."
    cd "$project_dir"
    git init
    log_success "Git repository initialized"
    
    # Create a basic .gitignore if it doesn't exist
    if [[ ! -f "$project_dir/.gitignore" ]]; then
        log_info "Creating basic .gitignore..."
        cat > "$project_dir/.gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
.pytest_cache/
.coverage
htmlcov/
.tox/
.venv/
venv/
ENV/
env/

# IDE
.vscode/.history
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# uv
.uv/
uv.lock
EOF
        log_success "Created .gitignore"
    fi
}

setup_uv() {
    local project_dir="$1"
    
    if ! command -v uv &> /dev/null; then
        log_warning "uv is not installed, skipping Python setup"
        log_info "Install uv by running: curl -LsSf https://astral.sh/uv/install.sh | sh"
        return
    fi
    
    log_info "Setting up uv for Python project..."
    cd "$project_dir"
    
    # Check if pyproject.toml already exists
    if [[ -f "$project_dir/pyproject.toml" ]]; then
        log_info "pyproject.toml already exists, skipping uv init"
        return
    fi
    
    # Initialize uv project
    uv init --no-workspace
    log_success "Initialized uv project"
    
    log_info "Creating Python virtual environment with uv..."
    uv venv
    log_success "Virtual environment created at .venv/"
    
    # Create a basic README if it doesn't exist
    if [[ ! -f "$project_dir/README.md" ]]; then
        local project_name=$(basename "$project_dir")
        cat > "$project_dir/README.md" << EOF
# $project_name

## Setup

\`\`\`bash
# Activate virtual environment
source .venv/bin/activate  # On Unix/macOS
# or
.venv\\Scripts\\activate  # On Windows

# Install dependencies
uv pip install -r requirements.txt

# Or sync with pyproject.toml
uv sync
\`\`\`

## Development

\`\`\`bash
# Add a new package
uv add <package-name>

# Add a dev dependency
uv add --dev <package-name>

# Run your code
uv run python your_script.py
\`\`\`
EOF
        log_success "Created README.md"
    fi
}

copy_configs() {
    local project_dir="$1"
    
    # Copy VSCode configuration
    log_info "Copying VSCode configuration..."
    copy_file \
        "$TEMPLATES_DIR/.vscode/settings.json" \
        "$project_dir/.vscode/settings.json" \
        "VSCode settings"
    
    copy_file \
        "$TEMPLATES_DIR/.vscode/extensions.json" \
        "$project_dir/.vscode/extensions.json" \
        "VSCode extensions"
    
    # Copy GitHub Copilot instructions
    log_info "Copying GitHub Copilot instructions..."
    copy_file \
        "$GITHUB_DIR/copilot-instructions.md" \
        "$project_dir/.github/copilot-instructions.md" \
        "Copilot instructions"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    # Parse arguments
    FORCE=false
    NO_BACKUP=false
    FRESH_PROJECT=false
    PROJECT_DIR="."
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --fresh)
                FRESH_PROJECT=true
                shift
                ;;
            --existing)
                FRESH_PROJECT=false
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -n|--no-backup)
                NO_BACKUP=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                PROJECT_DIR="$1"
                shift
                ;;
        esac
    done
    
    # Create directory if it doesn't exist (for fresh projects)
    if [[ "$FRESH_PROJECT" == "true" ]] && [[ ! -d "$PROJECT_DIR" ]]; then
        log_info "Creating directory: $PROJECT_DIR"
        mkdir -p "$PROJECT_DIR"
    fi
    
    # Resolve project directory
    PROJECT_DIR="$(cd "$PROJECT_DIR" 2>/dev/null && pwd)" || {
        log_error "Directory does not exist: $PROJECT_DIR"
        exit 1
    }
    
    echo ""
    if [[ "$FRESH_PROJECT" == "true" ]]; then
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║         Fresh Project Initializer                         ║"
        echo "╚════════════════════════════════════════════════════════════╝"
    else
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║         Project Configuration Initializer                 ║"
        echo "╚════════════════════════════════════════════════════════════╝"
    fi
    echo ""
    log_info "Target directory: $PROJECT_DIR"
    log_info "Project type: $(if [[ "$FRESH_PROJECT" == "true" ]]; then echo "Fresh"; else echo "Existing"; fi)"
    log_info "Dotfiles directory: $DOTFILES_DIR"
    echo ""
    
    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_error "Dotfiles directory not found: $DOTFILES_DIR"
        log_info "Set DOTFILES_DIR environment variable or install dotfiles first"
        exit 1
    fi
    
    # Fresh project setup
    if [[ "$FRESH_PROJECT" == "true" ]]; then
        init_git "$PROJECT_DIR"
        setup_uv "$PROJECT_DIR"
    fi
    
    # Copy configurations (both fresh and existing)
    copy_configs "$PROJECT_DIR"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                   ✅ Complete!                             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "Project initialized successfully!"
    echo ""
    
    if [[ "$FRESH_PROJECT" == "true" ]]; then
        log_info "Fresh project setup complete! Next steps:"
        echo "  1. cd $PROJECT_DIR"
        echo "  2. Activate virtual environment: source .venv/bin/activate"
        echo "  3. Add dependencies: uv add <package-name>"
        echo "  4. Open in VSCode: code ."
        echo "  5. Make your first commit: git add . && git commit -m 'Initial commit'"
    else
        log_info "Configuration copied! Next steps:"
        echo "  1. Review .vscode/settings.json and customize as needed"
        echo "  2. Review .github/copilot-instructions.md for your project"
        echo "  3. Open project in VSCode - it will prompt to install extensions"
        echo "  4. Commit the configuration files to version control"
    fi
    echo ""
}

# =============================================================================
# EXECUTION
# =============================================================================

main "$@"
