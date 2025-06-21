# ─── Helper Function ──────────────────────────────────────────────────────────
__is_tty() {
    [[ "$TERM" == "linux" ]] && echo "$1" || echo "$2"
}

# ─── Terminal Environment Detection ────────────────────────────────────────────
export IN_TTY=$(__is_tty true false)

# ─── Oh-My-Zsh and Theme Setup ────────────────────────────────────────────────
ZSH=/usr/share/oh-my-zsh

if [[ "$IN_TTY" == true ]]; then
    ZSH_THEME="robbyrussell"
else
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi

plugins=(git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

[[ "$IN_TTY" == false && -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ─── PATH and Environment Setup ───────────────────────────────────────────────
source /etc/profile
export EZA_ICONS=$(__is_tty never auto)

# ─── Command Not Found Handler ────────────────────────────────────────────────
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# ─── AUR Helper Detection ─────────────────────────────────────────────────────
if pacman -Qi yay &>/dev/null; then
    aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
    aurhelper="paru"
fi

# ─── Package Installer Function ───────────────────────────────────────────────
function in() {
    local -a arch=() aur=()
    for pkg in "$@"; do
        pacman -Si "$pkg" &>/dev/null && arch+=("$pkg") || aur+=("$pkg")
    done
    [[ ${#arch} -gt 0 ]] && sudo pacman -S "${arch[@]}"
    [[ ${#aur} -gt 0 ]] && [[ -n $aurhelper ]] && $aurhelper -S "${aur[@]}"
}

# ─── Aliases ──────────────────────────────────────────────────────────────────
alias c='clear'
alias l="eza -lh --icons=$EZA_ICONS"
alias ls="eza -1 --icons=$EZA_ICONS"
alias ll="eza -lha --icons=$EZA_ICONS --sort=name --group-directories-first"
alias ld="eza -lhD --icons=$EZA_ICONS"
alias lt="eza --icons=$EZA_ICONS --tree"

alias un="$aurhelper -Rns"
alias up="$aurhelper -Syu"
alias pl="$aurhelper -Qs"
alias pa="$aurhelper -Ss"
alias pc="$aurhelper -Sc"
alias po="$aurhelper -Qtdq | $aurhelper -Rns -"

alias vc='code .'
alias mkdir='mkdir -p'

# Directory Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# ─── Conda & Bun ──────────────────────────────────────────────────────────────
[[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && source /opt/miniconda3/etc/profile.d/conda.sh
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# ─── Post-Startup ─────────────────────────────────────────────────────────────
[[ "$IN_TTY" == false ]] && command -v fastfetch &>/dev/null && fastfetch
