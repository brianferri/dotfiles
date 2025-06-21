# ─── Load OS-Specific Zsh Config ──────────────────────────────────────────────
zsh_os=$(uname -s)
os_config="$HOME/.zshcfg/${zsh_os}.zsh"

case "$zsh_os" in
Linux | Darwin)
    if [[ -f "$os_config" && -O "$os_config" && ! -L "$os_config" ]]; then
        source "$os_config"
    else
        echo "Warning: Skipping $os_config (missing, unsafe, or symlinked)"
    fi
    ;;
*)
    echo "Warning: Unsupported OS '$zsh_os', no config loaded"
    ;;
esac

