# .files

Welcome to my personal dotfiles repository! This collection powers my development environments across macOS and Linux, designed to keep shared and system-specific configurations cleanly separated.

## Cross-Platform Syncing

To keep my setups in sync across macOS and Linux, the repository is organized with:

* **Shared Configurations**
  Common settings like Kitty terminal themes, Fastfetch configs, and various app configurations live inside the `.config/` directory and root-level files like `.condarc` and `.p10k.zsh`. These are used regardless of the OS.

* **System-Specific Configurations**
  OS-dependent Zsh settings live in `.zshcfg/`, with separate files for macOS (`Darwin.zsh`) and Linux (`Linux.zsh`). This lets me tailor shell behavior per platform without splitting the whole repo.

Some Linux-specific configs (like `Kvantum`, `Waybar`) are included in `.config/` but kept non-intrusive so they don’t affect macOS.

If you want to explore my larger or more specialized setups like Neovim or Hyprland, check out my dedicated repos:

* [config.nvim](https://github.com/brianferri/config.nvim)
* [config.hypr](https://github.com/brianferri/config.hypr)

