# ─── Conda Initialization ─────────────────────────────────────────────────────
# Managed by 'conda init'
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        source "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup

# ─── pyenv Setup ──────────────────────────────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ─── Oh-My-Zsh and Theme Setup ────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

plugins=(git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

source ~/.p10k.zsh

# ─── Docker CLI Completions ──────────────────────────────────────────────────
fpath=(/Users/brianferri/.docker/completions $fpath)
autoload -Uz compinit && compinit

# ─── Aliases ─────────────────────────────────────────────────────────────────
alias obs='open -a "/Applications/OBS.app" --args $@'
alias c='clear'
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias vc='code'

# ─── Languages & Tools ───────────────────────────────────────────────────────
# LM Studio
export PATH="$PATH:$HOME/.cache/lm-studio/bin"

# Node / NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# Perl
export PATH="$HOME/perl5/bin${PATH:+:${PATH}}"
export PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_MB_OPT="--install_base \"$HOME/perl5\""
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"

# Java
DEFAULT_JAVA_VERSION=21
export JAVA_HOME=$(/usr/libexec/java_home -v $DEFAULT_JAVA_VERSION)

# PHP / Composer
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"

# Rust
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# ─── Post-Startup ─────────────────────────────────────────────────────────────
command -v fastfetch &>/dev/null && fastfetch

# if [[ -z "${ISTERM}" && $- == *i* && $- != *c* ]]; then
#     is --shell zsh
# fi
