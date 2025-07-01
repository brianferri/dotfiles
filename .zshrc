# ─── Load OS-Specific Zsh Config ──────────────────────────────────────────────
export zsh_os=$(uname -s)
export OS_ICON_CONTENT=''

case "$zsh_os" in
    Linux)
        OS_ICON_CONTENT=''
        ;;
    Darwin)
        OS_ICON_CONTENT=''
        ;;
    *)
        echo "Warning: Unsupported OS '$zsh_os', no config loaded"
        return
        ;;
esac

os_config="$HOME/.zshcfg/${zsh_os}.zsh"
if [[ -f "$os_config" && -O "$os_config" && ! -L "$os_config" ]]; then
    source "$os_config"
else
    echo "Warning: Skipping $os_config (missing, unsafe, or symlinked)"
fi

