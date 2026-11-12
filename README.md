# 🚀 Personal Dotfiles

A modern, fully-automated dotfiles repository for setting up a complete development environment on Linux and macOS. One command to rule them all!

## 🎯 Quick Start

### Set Up Your Development Environment

```bash
# Clone the repository
git clone https://github.com/sitzikbs/dotfiles.git ~/.dotfiles

# Run the installer
cd ~/.dotfiles
./install.sh

# Log out and log back in to activate ZSH
```

That's it! Your development environment is ready.

> **Note**: The installer automatically backs up any conflicting files to `~/.dotfiles-backup` with timestamps before making changes.

### Initialize a New Project

After setting up your dotfiles, use this command to initialize any new project with your VSCode settings and GitHub Copilot configuration:

```bash
# For an existing project (just copy configs)
cd /path/to/your/existing-project
init-project

# For a fresh project (git init + uv setup + configs)
init-project --fresh ~/my-new-project

# Or force overwrite existing files
init-project -f
```

**Fresh Project** (`--fresh`):
- Creates the directory if it doesn't exist
- Runs `git init` and creates `.gitignore`
- Sets up `uv` for Python package management
- Creates `pyproject.toml` and virtual environment
- Creates basic `README.md`
- Copies `.vscode/` and `.github/` configurations

**Existing Project** (default):
- Only copies `.vscode/` and `.github/` configurations

This will copy:
- `.vscode/settings.json` - VSCode workspace settings (Ruff formatter, lint on save, Python config)
- `.vscode/extensions.json` - Recommended extensions (Python, GitHub Copilot, Docker, etc.)
- `.github/copilot-instructions.md` - GitHub Copilot coding guidelines and best practices
- `cursor/instructions.md` - Cursor AI instructions (if using Cursor editor)

> **Tip**: Run `init-project --fresh` for new Python projects to get a complete setup with git, uv, and consistent development environment in one command.

## ✨ Features

- **🐚 ZSH Environment** - Oh My Zsh + Powerlevel10k theme with autosuggestions and syntax highlighting
- **🎨 Catppuccin Mocha Theme** - Consistent, beautiful colors across all tools
- **🛠️ Modern CLI Tools** - eza, bat, zoxide, fzf, fd, ripgrep, lazygit, lazydocker, and more
- **🖥️ Tmux Configuration** - TPM with Catppuccin theme, rounded corners, mouse support, and clickable tabs
- **📦 Stow-Managed Dotfiles** - Organized, version-controlled, and easily extendable
- **🔧 Git Configuration** - Sensible defaults, beautiful diffs, and useful aliases
- **🌳 Ranger File Manager** - Vi bindings, previews, and optimized layout
- **💻 VSCode Integration** - Pre-configured settings with Ruff, format on save, and recommended extensions
- **🤖 AI Coding Assistants** - GitHub Copilot and Cursor instructions for consistent code quality
- **🔐 Environment Variables Template** - Pre-configured `.env` template for AWS, GitHub, HuggingFace, OpenAI, and more
- **🧪 Comprehensive Testing** - Docker-based tests for Ubuntu (22.04, 24.04) and Debian 12
- **100% Non-Interactive** - Perfect for automation and remote setups
- **🌍 Cross-Platform** - Full support for macOS, Linux (Ubuntu/Debian), and WSL

## 📁 Repository Structure

```
dotfiles/
├── install.sh              # Main installation script
├── config.sh               # Configuration options
├── env.common              # Common environment variables (AWS, GitHub, HuggingFace, OpenAI)
├── env.example             # Comprehensive environment variables template (30+ services)
├── scripts/
│   ├── setup/              # Modular setup scripts
│   │   ├── base.sh         # System requirements and base setup
│   │   ├── packages.sh     # CLI tools installation
│   │   ├── zsh.sh          # ZSH and Oh My Zsh setup
│   │   ├── tmux.sh         # Tmux configuration
│   │   └── themes.sh       # Theme installation
│   ├── utils/
│   │   └── helpers.sh      # Shared utility functions
│   └── setup_python_env.sh # Optional Python development tools
├── stow/                   # Dotfiles managed by GNU Stow
│   ├── zsh/
│   │   ├── .zshrc          # ZSH configuration
│   │   └── .p10k.zsh       # Powerlevel10k theme config
│   ├── tmux/
│   │   └── .tmux.conf       # Tmux configuration (TPM + Catppuccin)
│   ├── git/
│   │   ├── .gitconfig       # Git configuration
│   │   └── .gitignore_global # Global gitignore
│   ├── ranger/
│   │   └── .config/ranger/rc.conf # Ranger configuration
│   └── vscode/
│       └── .vscode/         # VSCode settings and extensions
├── .github/
│   └── copilot-instructions.md # GitHub Copilot guidelines
├── cursor/
│   └── instructions.md     # Cursor AI instructions
└── test/                   # Docker testing infrastructure
    ├── Dockerfile.ubuntu
    ├── test.sh
    └── README.md
```

## 🛠️ What Gets Installed

### Shell & Terminal
- **ZSH** - Modern shell with extensive plugin ecosystem
- **Oh My Zsh** - ZSH configuration framework
- **Powerlevel10k** - Fast, customizable prompt theme
- **Tmux** - Terminal multiplexer for managing sessions
- **TPM** - Tmux Plugin Manager for theme and plugins

### Editor & Development
- **VSCode Settings** - Optimized for Python development with Ruff
- **Recommended Extensions** - Python, Copilot, Docker, and more
- **AI Assistant Instructions** - Coding guidelines for GitHub Copilot and Cursor

### Modern CLI Tools
| Tool | Description | Replaces |
|------|-------------|----------|
| **eza** | Modern ls with colors and git integration | ls |
| **bat** | Cat with syntax highlighting | cat |
| **zoxide** | Smarter cd that learns your habits | cd |
| **fzf** | Fuzzy finder for files and command history | - |
| **fd** | Fast and user-friendly find alternative | find |
| **ripgrep** | Extremely fast grep alternative | grep |
| **lazygit** | Terminal UI for git | - |
| **lazydocker** | Terminal UI for docker | - |
| **btop** | Beautiful resource monitor | top/htop |
| **ranger** | Console file manager with VI bindings | - |
| **rclone** | Cloud storage sync and mount | - |
| **neofetch** | System information display | - |
| **ncdu** | Disk usage analyzer with ncurses interface | du |
| **uv** | Blazing fast Python package manager | pip |
| **herdr** | Terminal multiplexer for AI coding agents (+ Claude Code hook) | - |

### Configurations
- **Git** - Aliases, better diffs, sensible defaults
- **Ranger** - VI bindings, column ratios, file previews
- **Bat** - Catppuccin Mocha syntax highlighting theme
- **FZF** - Catppuccin colors, smart file previews
- **Tmux** - TPM + Catppuccin theme with rounded corners, mouse support, clickable tabs

## ⚙️ Customization

### Configuration File

Edit `config.sh` to enable/disable features:

```bash
# Disable specific tools
INSTALL_RANGER=false
INSTALL_LAZYDOCKER=false

# Skip fonts installation
INSTALL_FONTS=false

# Change theme
THEME="catppuccin-mocha"  # or catppuccin-macchiato, etc.

# Customize stow packages
STOW_PACKAGES=(
    "zsh"
    "tmux"
    "git"
    "ranger"
    "vscode"  # Add or remove as needed
)
```

### Dotfile Customization

All dotfiles are in `stow/` and symlinked to your home directory:

```bash
# Edit ZSH config
vim ~/.dotfiles/stow/zsh/.zshrc

# Edit Tmux config
vim ~/.dotfiles/stow/tmux/.tmux.conf

# Edit Git config
vim ~/.dotfiles/stow/git/.gitconfig
```

Changes are **immediately reflected** because of symbolic links!

### Adding Your Own Dotfiles

1. Create a new directory in `stow/`:
   ```bash
   mkdir -p ~/.dotfiles/stow/vim/.vim
   ```

2. Add your dotfiles mirroring your home directory structure:
   ```bash
   cp ~/.vimrc ~/.dotfiles/stow/vim/.vimrc
   ```

3. Add the package to `config.sh`:
   ```bash
   STOW_PACKAGES=(
       "zsh"
       "tmux"
       "git"
       "ranger"
       "vscode"
       "vim"    # Your new package
   )
   ```

4. Re-run the installer or manually stow:
   ```bash
   cd ~/.dotfiles
   stow -d stow -t ~ vim
   ```

### AI Coding Assistant Configuration

The repository includes comprehensive coding guidelines for AI assistants:

- **`.github/copilot-instructions.md`** - GitHub Copilot instructions
  - Python best practices with type hints
  - Ruff formatting and linting standards
  - Error handling patterns
  - Documentation guidelines
  
- **`cursor/instructions.md`** - Cursor AI instructions
  - Modern Python patterns (dataclasses, pathlib, f-strings)
  - Testing best practices
  - Common code patterns and examples

These files are automatically copied to new projects via `init-project` command.

### Environment Variables Management

The repository includes a comprehensive environment variables template (`env.example`) with placeholders for:

**Cloud & Infrastructure:**
- AWS (Access Key, Secret Key, Region, Profile)
- Google Cloud / Gemini
- Azure / OpenAI Azure
- Docker Hub

**AI & ML Services:**
- OpenAI (GPT-4, ChatGPT)
- Anthropic (Claude)
- Hugging Face (Models, Datasets)
- Weights & Biases
- Replicate, Cohere

**Development:**
- GitHub (Personal Access Tokens)
- PyPI (Package publishing)
- Kaggle
- Database connections (PostgreSQL, MongoDB, Redis)

**Setup:**

Choose between the minimal or comprehensive template:

```bash
# Option 1: Common credentials only (recommended to start)
cp ~/.dotfiles/env.common ~/.env

# Option 2: All available options
cp ~/.dotfiles/env.example ~/.env

# Secure the file (important!)
chmod 600 ~/.env

# Edit and add your credentials
vim ~/.env
```

The `.env` file is automatically loaded by `.zshrc` on shell startup, making all your API keys and credentials available in your terminal sessions. The file is excluded from git via `.gitignore` to prevent accidental commits of sensitive data.

## 🧪 Testing

Test your dotfiles across multiple platforms before applying to your system:

### Debug Tools

If experiencing issues (like escape sequences in tmux):

```bash
# Debug tmux escape sequences
./debug-tmux.sh

# Compare terminal environments
./compare-env.sh > terminal-env.txt
```

### Automated Test Suite

Run comprehensive tests on all platforms:

```bash
# Test all platforms (Ubuntu 22.04, 24.04, and Debian 12)
./test/run-tests.sh

# Test specific platform
./test/run-tests.sh ubuntu
./test/run-tests.sh ubuntu-latest
./test/run-tests.sh debian
```

The test suite will:
1. Build fresh Docker containers
2. Install dotfiles automatically
3. Run validation tests
4. Prompt for visual confirmation (themes, colors, UI)

### Manual Testing

```bash
# Build and run with mounted volume (fast iteration)
docker build -f test/Dockerfile.ubuntu -t dotfiles-test-ubuntu .
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu

# Interactive ZSH session
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu zsh
```

### What Gets Tested

- ✅ All CLI tools install correctly
- ✅ Configuration files are symlinked
- ✅ ZSH with Powerlevel10k works
- ✅ Tmux with Catppuccin theme displays properly
- ✅ Colors and icons render correctly
- ✅ Modern tools (bat, eza, btop) work as expected

See `test/README.md` for detailed testing documentation.

## 🔧 Post-Installation

### Required
1. **Log out and log back in** - Activates ZSH as default shell
2. **Set Git user info** - Edit `~/.gitconfig`:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

### Optional
- **Set up environment variables**: 
  ```bash
  # Use env.common for just AWS/GitHub/HuggingFace/OpenAI/Claude
  cp ~/.dotfiles/env.common ~/.env
  chmod 600 ~/.env
  vim ~/.env  # Add your API keys and credentials
  ```
- **Customize Powerlevel10k**: Run `p10k configure`
- **Install Python tools**: Run `./scripts/setup_python_env.sh`
- **Install Tmux plugins**: Run `tmux` and press `Ctrl+b` then `I` (capital i) to install plugins

## 📚 Key Bindings

### Tmux
- `Ctrl+b |` - Split pane vertically
- `Ctrl+b -` - Split pane horizontally
- `Alt+Arrow` - Navigate between panes
- `Mouse click` - Click window tabs to switch (mouse support enabled!)
- `Ctrl+b r` - Reload configuration
- `Ctrl+b I` - Install/update plugins (capital I)

### ZSH
- `Ctrl+r` - Fuzzy search command history
- `Ctrl+t` - Fuzzy search files
- `Alt+c` - Fuzzy search directories
- `z <partial>` - Jump to frequently used directory

## 🐛 Troubleshooting

### ZSH not default after installation
```bash
sudo chsh -s $(which zsh)
# Then log out and log back in
```

### FZF not working
Make sure ZSH is active (requires logout/login). FZF keybindings only load in ZSH.

### Bat theme not applied
```bash
bat cache --build
# Or if using batcat (Ubuntu):
batcat cache --build
```

### Bat/Btop installation issues
The installer automatically handles common issues:
- On Ubuntu, `bat` is installed as `batcat` with automatic aliasing
- If `btop` fails, it tries PPA or snap installation
- Manual fallback instructions are provided if automatic installation fails

### Stow conflicts
```bash
# Backup conflicting files (automated in install script)
# Or manually remove:
rm ~/.zshrc
cd ~/.dotfiles
stow -d stow -t ~ zsh
```

### Tmux in VSCode/Cursor Terminal

**Escape sequences on tmux startup (FIXED):**

The dotfiles include a fix for escape sequences (OSC 10/11) that appear when starting tmux in VSCode/Cursor.

**The Fix:**
- `escape-time` is set to `50ms` (instead of 0ms).
- This overrides `tmux-sensible` defaults.
- This gives the terminal enough time to process initialization sequences without leaking them to the shell.

**If you still see escape sequences:**
Ensure your `.tmux.conf` symlink points to the correct file and that the `escape-time` setting is not being overwritten by plugins.

**Trade-off:** None. 50ms is imperceptible for typing latency.

### WSL-Specific Issues

**Fonts not displaying correctly:**
- Install MesloLGS NF fonts on Windows (not in WSL)
- Configure Windows Terminal to use the font
- Right-click title bar → Settings → Profiles → Defaults → Appearance → Font face

**Colors look wrong:**
- Use Windows Terminal (recommended) or a terminal that supports 256 colors
- Avoid the legacy Windows Console

### macOS-Specific Issues

**Homebrew not found:**
The installer automatically installs Homebrew if missing. If issues persist:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**init-project command not found:**
Make sure you've logged out and back in after installation to reload your PATH.

## 🔄 Updating

```bash
cd ~/.dotfiles
git pull
./install.sh  # Re-run installer (safe and idempotent)
```

## 🎨 Theme Customization

All tools use **Catppuccin Mocha** by default. To customize:

### Tmux
Edit Catppuccin settings in `~/.tmux.conf`:
```bash
# Change flavor: latte, frappe, macchiato, mocha
set -g @catppuccin_flavour 'mocha'

# Customize status bar modules
set -g @catppuccin_status_modules_right "directory user host session date_time"
```

### Bat
```bash
# List available themes
bat --list-themes

# Set in ~/.zshrc
export BAT_THEME="YourTheme"
```

### FZF
Edit FZF_DEFAULT_OPTS in `~/.zshrc`

## 📝 Requirements

### Minimal Requirements
- **Ubuntu/Debian**: git, curl, wget, sudo
- **macOS**: git, curl (Homebrew auto-installed if missing)
- **WSL**: Same as Ubuntu (ensure WSL 2 for best performance)
- **Disk space**: ~500MB
- **Internet**: Required for package downloads

### Supported Platforms
- ✅ Ubuntu 22.04 LTS (Jammy)
- ✅ Ubuntu 24.04 LTS (Noble)
- ✅ Debian 12 (Bookworm)
- ✅ macOS 12+ (Monterey and later)
- ✅ WSL 2 (Windows Subsystem for Linux)

### Recommended
- Terminal with 256-color support
- Nerd Font compatible terminal (for icons)
- Docker (for testing before installation)

## 🤝 Contributing

This is a personal dotfiles repo, but feel free to:
- Fork for your own use
- Open issues for bugs
- Suggest improvements

## 📄 License

MIT License - Use freely!

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- All the amazing CLI tool developers!

---

💡 **Pro Tip**: All dotfiles use symbolic links, so changes to files in `~/.dotfiles/stow/` are instantly reflected in your environment. Commit and push to keep your setup in sync across machines!
