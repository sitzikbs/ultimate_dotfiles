# Testing Dotfiles

This directory contains comprehensive Docker-based tests for the dotfiles installation across multiple Linux distributions.

## Quick Start

Run the automated test suite for all platforms:

```bash
./test/run-tests.sh
```

This will:
1. Build Docker images for Ubuntu 22.04, Ubuntu 24.04, and Debian 12
2. Run automated installation and validation tests
3. Prompt for visual confirmation of themes and UI elements
4. Clean up Docker images after testing

## Test Individual Platforms

```bash
# Test only Ubuntu 22.04
./test/run-tests.sh ubuntu

# Test Ubuntu 24.04
./test/run-tests.sh ubuntu-latest

# Test Debian 12
./test/run-tests.sh debian

# Test specific platforms
./test/run-tests.sh ubuntu debian

# Keep Docker images after testing (for debugging)
./test/run-tests.sh --no-cleanup
```

## Manual Testing

### Build and Run Tests

```bash
# Ubuntu 22.04
docker build -f test/Dockerfile.ubuntu -t dotfiles-test-ubuntu .
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu

# Ubuntu 24.04
docker build -f test/Dockerfile.ubuntu-latest -t dotfiles-test-ubuntu-latest .
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu-latest

# Debian 12
docker build -f test/Dockerfile.debian -t dotfiles-test-debian .
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-debian
```

### Interactive Testing

Launch an interactive ZSH session after installation:

```bash
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu zsh
```

Inside the container, you can:
- Test the Powerlevel10k prompt
- Run `tmux` to check the Catppuccin theme
- Try modern CLI tools: `ls`, `cat`, `btop`, `lazygit`
- Verify colors and icons are displaying correctly

### Run Only Installation (No Tests)

```bash
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu install
```

### Debug Mode

Start a bash shell without running installation:

```bash
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu bash
```

## What Gets Tested

### Automated Tests (`test/test.sh`)

- ✅ All CLI tools are installed
- ✅ Configuration files are in place
- ✅ Stow symlinks are created correctly
- ✅ ZSH is the default shell
- ✅ Tmux and themes are configured
- ✅ Oh My Zsh and plugins are installed
- ✅ Catppuccin themes are loaded

### Visual Confirmation (Interactive)

The test suite will prompt you to verify:

1. **Powerlevel10k Prompt**: Check icons and colors
2. **Catppuccin Theme**: Verify consistent colors
3. **Tmux Status Bar**: Check rounded corners, icons, and colors
4. **Modern CLI Tools**: Test `eza`, `bat`, `btop`
5. **Git UI**: Verify `lazygit` theme

## Test Architecture

### Mounted Volume Approach

Tests use mounted volumes instead of copying files into the image. This provides:

- **Fast Iteration**: No rebuild needed when changing dotfiles
- **Consistency**: Same files as on your machine
- **Efficiency**: Smaller Docker images

### Test Platforms

| Platform | Version | Dockerfile |
|----------|---------|------------|
| Ubuntu LTS | 22.04 | `test/Dockerfile.ubuntu` |
| Ubuntu Latest | 24.04 | `test/Dockerfile.ubuntu-latest` |
| Debian | 12 (Bookworm) | `test/Dockerfile.debian` |

### Entry Point

`test/entrypoint.sh` handles:
- Copying mounted dotfiles to `~/.dotfiles`
- Running installation
- Executing tests
- Launching interactive shells

## Troubleshooting

### Docker not found

```bash
# Install Docker
# macOS: brew install --cask docker
# Ubuntu: sudo apt install docker.io
```

### Permission denied

```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Log out and back in
```

### Tests failing

1. Check the installation logs in the container
2. Run with `--no-cleanup` to keep images for debugging
3. Launch an interactive session to investigate

```bash
./test/run-tests.sh ubuntu --no-cleanup
docker run -it --rm -v "$(pwd):/dotfiles:ro" dotfiles-test-ubuntu zsh
```

### Visual tests look wrong

- Check terminal emulator font (should be MesloLGS NF)
- Verify terminal supports 256 colors
- On macOS: Use iTerm2 or Alacritty for best results

## Continuous Integration

To run tests in CI/CD:

```bash
# Non-interactive mode (skip visual confirmation)
./test/run-tests.sh --all --no-cleanup
```

For GitHub Actions, use the provided workflow (if available) or create your own:

```yaml
name: Test Dotfiles
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: ./test/run-tests.sh --all
```

## Development Workflow

1. Make changes to dotfiles or scripts
2. Run quick test: `./test/run-tests.sh ubuntu`
3. If tests pass, test all platforms: `./test/run-tests.sh --all`
4. Commit changes once all tests pass

## Notes

- Tests run as non-root user `testuser` (mimics real-world usage)
- Sudo is available without password (for package installation)
- Network access is available during tests
- `.dockerignore` prevents copying unnecessary files
