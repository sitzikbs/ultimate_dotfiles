# -----------------------------------------------------------------------------
# 1. ENVIRONMENT AND PATH
# -----------------------------------------------------------------------------
# This section should come first, so the shell knows where to find commands.

# Enable colors
autoload -U colors && colors

# Force color support
export CLICOLOR=1
export TERM=xterm-256color

# Set up your PATH


# Add other custom paths if needed.
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Set your preferred editor
export EDITOR='nano'


# -----------------------------------------------------------------------------
# 2. OH MY ZSH CONFIGURATION
# -----------------------------------------------------------------------------
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the theme. For Powerlevel10k, this is the correct way.
# Oh My Zsh will automatically source p10k.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Define which plugins you want Oh My Zsh to load.
# List them separated by spaces inside the parentheses.
# We've added the plugins you were using from Zinit here.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  command-not-found
)

# -----------------------------------------------------------------------------
# 3. POWERLEVEL10K CONFIGURATION
# -----------------------------------------------------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# Oh My Zsh loads P10k automatically, but if you want to be sure your local
# config is loaded, keeping this is safe.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# -----------------------------------------------------------------------------
# 4. SHELL HISTORY
# -----------------------------------------------------------------------------
# These are good settings and can stay as they are.
HIST_SIZE=5000
SAVEHIST=$HIST_SIZE
HISTFILE="$HOME/.zsh_history"
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups
setopt share_history       # Reads and writes to the history file.


# -----------------------------------------------------------------------------
# 5. ALIASES and SHELL INTEGRATIONS
# -----------------------------------------------------------------------------

# Extra completions (herdr, etc.). Must be in fpath before OMZ runs compinit.
fpath=("$HOME/.local/share/zsh/completions" $fpath)

# This line loads the Oh My Zsh framework. It MUST come AFTER the
# ZSH_THEME and plugins variables have been set.
source "$ZSH/oh-my-zsh.sh"

# Zoxide (smarter cd command). This should be loaded after OMZ.
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Modern ls with eza
if command -v eza &> /dev/null; then
    alias ls="eza --color=always --icons=always --long --git --no-filesize --no-time --no-user --no-permissions"
    alias la="eza --color=always --icons=always --long --git --all"
    alias ll="eza --color=always --icons=always --long --git"
    alias lt="eza --color=always --icons=always --tree --level=2"
fi

# Bat with color
if command -v bat &> /dev/null; then
    alias cat="bat --style=auto"
elif command -v batcat &> /dev/null; then
    alias bat="batcat"
    alias cat="batcat --style=auto"
fi

setopt inc_append_history  # Saves every command before it is executed.

# -----------------------------------------------------------------------------
# 6. FZF (Fuzzy Finder) Configuration - Catppuccin Mocha Theme
# -----------------------------------------------------------------------------
# Source fzf key bindings and completion
if command -v fzf &> /dev/null; then
    # Try different possible locations for fzf shell integrations
    if [ -f ~/.fzf.zsh ]; then
        source ~/.fzf.zsh
    elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
        source /usr/share/doc/fzf/examples/completion.zsh
    elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
        source /usr/share/fzf/key-bindings.zsh
        source /usr/share/fzf/completion.zsh
    elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
        # macOS with Apple Silicon
        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
        source /opt/homebrew/opt/fzf/shell/completion.zsh
    elif [ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]; then
        # macOS with Intel
        source /usr/local/opt/fzf/shell/key-bindings.zsh
        source /usr/local/opt/fzf/shell/completion.zsh
    fi
fi

# Use fd instead of find for better performance
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
    
    _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
    }
    
    _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
    }
fi

# Catppuccin Mocha theme for FZF
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Preview configuration
if command -v bat &> /dev/null; then
    bat_cmd="bat"
elif command -v batcat &> /dev/null; then
    bat_cmd="batcat"
else
    bat_cmd="cat"
fi

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else $bat_cmd -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
_fzf_comprun() {
    local command=$1
    shift
    
    case "$command" in
        cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
        export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
        ssh)          fzf --preview 'dig {}'                   "$@" ;;
        *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
}

# -----------------------------------------------------------------------------
# 7. BAT (Better cat) Configuration - Catppuccin Mocha Theme
# -----------------------------------------------------------------------------
export BAT_THEME="Catppuccin-mocha"

# -----------------------------------------------------------------------------
# 8. ADDITIONAL ALIASES
# -----------------------------------------------------------------------------
alias c='clear'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Project initialization
alias init-project='~/.dotfiles/scripts/init-project.sh'

# Git aliases (if not using oh-my-zsh git plugin shortcuts)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# -----------------------------------------------------------------------------
# 9. EXTERNAL INTEGRATIONS
# -----------------------------------------------------------------------------

# VSCode shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)" 2>/dev/null

# 1Password: CLI completion + SSH agent (enable in 1Password > Settings > Developer)
if command -v op &> /dev/null; then
    eval "$(op completion zsh)"; compdef _op op
fi
for _op_sock in "$HOME/.1password/agent.sock" \
                "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"; do
    if [[ -S "$_op_sock" ]]; then export SSH_AUTH_SOCK="$_op_sock"; break; fi
done
unset _op_sock

# Envman (if installed)
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# Dotfiles init-project command
if [[ -x "$HOME/.dotfiles/scripts/init-project.sh" ]]; then
    alias init-project="$HOME/.dotfiles/scripts/init-project.sh"
fi

# -----------------------------------------------------------------------------
# Load Environment Variables
# -----------------------------------------------------------------------------
# Load personal environment variables from ~/.env (credentials, API keys, etc.)
# Copy from ~/.dotfiles/.env.example and customize
if [[ -f "$HOME/.env" ]]; then
    source "$HOME/.env"
fi
