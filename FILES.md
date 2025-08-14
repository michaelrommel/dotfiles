# Files under `chezmoi`'s control

## Role: none

```text
.bash_aliases
.config/zsh/.zprofile
.config/zsh/.zshenv
.config/zsh/.zshrc
.config/zsh/zsh-autosuggestions
.inputrc
.minimalrc
.path.d/10_rust.bash
.path.d/10_rust.zsh
.path.d/40_go.sh
.path.d/50_mise.bash
.path.d/50_mise.zsh
.path.d/80_pipx.sh
.path.d/99_default.sh
.postinitialization.sh
.zshenv
bin/helper.sh
bin/install_go.sh
bin/install_node.sh
bin/install_python.sh
bin/install_rust.sh
bin/update_mise.sh
```

## Role: core

```text
.config/.terminfo_src/mintty.terminfo
.config/.terminfo_src/tmux.terminfo
.config/.terminfo_src/wezterm.terminfo
.config/.terminfo_src/xterm-ghostty.terminfo
.config/.terminfo_src/xterm-kitty.terminfo
.config/ghostty/config
.config/kanata/com.michaelrommel.kanata.plist
.config/kanata/com.michaelrommel.karabiner-vhiddaemon.plist
.config/kanata/com.michaelrommel.karabiner-vhidmanager.plist
.config/kanata/kanata.kbd
.config/starship.toml
.config/wezterm/wezterm.lua
.config/yazi/flavors/gruvbox-dark.yazi
.config/yazi/flavors/gruvbox-dark.yazi/LICENSE
.config/yazi/flavors/gruvbox-dark.yazi/LICENSE-tmtheme
.config/yazi/flavors/gruvbox-dark.yazi/README.md
.config/yazi/flavors/gruvbox-dark.yazi/flavor.toml
.config/yazi/flavors/gruvbox-dark.yazi/preview.png
.config/yazi/flavors/gruvbox-dark.yazi/tmtheme.xml
.config/yazi/init.lua
.config/yazi/keymap.toml
.config/yazi/package.toml
.config/yazi/plugins/hexyl.yazi
.config/yazi/plugins/hexyl.yazi/LICENSE
.config/yazi/plugins/hexyl.yazi/README.md
.config/yazi/plugins/hexyl.yazi/main.lua
.config/yazi/plugins/svg-preview.yazi
.config/yazi/plugins/svg-preview.yazi/LICENSE
.config/yazi/plugins/svg-preview.yazi/README.md
.config/yazi/plugins/svg-preview.yazi/main.lua
.config/yazi/plugins/toggle-pane.yazi
.config/yazi/plugins/toggle-pane.yazi/LICENSE
.config/yazi/plugins/toggle-pane.yazi/README.md
.config/yazi/plugins/toggle-pane.yazi/main.lua
.config/yazi/plugins/zoom.yazi
.config/yazi/plugins/zoom.yazi/LICENSE
.config/yazi/plugins/zoom.yazi/README.md
.config/yazi/plugins/zoom.yazi/main.lua
.config/yazi/theme.toml
.config/yazi/yazi.toml
.git_template/HEAD
.git_template/hooks/ctags
.git_template/hooks/post-checkout
.git_template/hooks/post-commit
.git_template/hooks/post-merge
.git_template/hooks/post-rewrite
.git_template/info/exclude
.gitconfig
.path.d/25_fzf.bash
.path.d/25_fzf.zsh
.path.d/80_carapace.bash
.path.d/80_carapace.zsh
.path.d/80_yazi.sh
.path.d/80_zoxide.bash
.path.d/80_zoxide.zsh
.preinitialization.sh
.ssh/config
bin/check_raid.sh
bin/clean_dotfiles.sh
bin/convert_cast.sh
bin/dir_colors.sh
bin/emoji.js
bin/less_colors.sh
bin/ls_colors.sh
bin/magick
bin/rm_stale_agents.sh
bin/set_gruvbox_colors.sh
bin/terminal-24bit-test.sh
bin/terminal-256color-test.py
bin/terminal-ansi-vte52-test.sh
bin/terminal-truecolor-test.sh
bin/terminal.sh
bin/update_carapace.sh
bin/update_starship.sh
bin/update_yazi.sh
bin/update_zoxide.sh
bin/vff.sh
bin/wsl2-relay-agent.sh
```

## Role: tmux

```text
.config/tmux/tmux.conf
.local/share/tmux/plugins/tmux-gruvbox
.local/share/tmux/plugins/tmux-gruvbox/gruvbox-tpm.tmux
.local/share/tmux/plugins/tmux-gruvbox/tmux-gruvbox-dark.conf
.local/share/tmux/plugins/tmux-gruvbox/tmux-gruvbox-light.conf
.local/share/tmux/plugins/tmux-network-bandwidth
.local/share/tmux/plugins/tmux-network-bandwidth/README.md
.local/share/tmux/plugins/tmux-network-bandwidth/scripts
.local/share/tmux/plugins/tmux-network-bandwidth/scripts/helpers.sh
.local/share/tmux/plugins/tmux-network-bandwidth/scripts/network-bandwidth.sh
.local/share/tmux/plugins/tmux-network-bandwidth/tmux-network-bandwidth.tmux
.local/share/tmux/plugins/tmux-plugin-cpu
.local/share/tmux/plugins/tmux-plugin-cpu/README.md
.local/share/tmux/plugins/tmux-plugin-cpu/cpu.tmux
.local/share/tmux/plugins/tmux-plugin-cpu/scripts
.local/share/tmux/plugins/tmux-plugin-cpu/scripts/cpu.sh
.local/share/tmux/plugins/tmux-plugin-cpu/scripts/helpers.sh
.local/share/tmux/plugins/tpm
.path.d/60_tmux.sh
bin/tmx
bin/tmux_paste.sh
```


## Role: tools

```text
.config/bat/themes/gruvbox-dark-medium.tmTheme
.config/fd/ignore
.path.d/30_bat.sh
.path.d/30_bat_extras.sh
bin/shellcheck
```


## Role: languages

```text
.path.d/90_toolchains.sh
```


## Role: neovim

Files managed in both variants:

```text
bin/vim
bin/vimdiff
bin/shellcheck
```


### Variant: minimal

```text
config/minimal/init.lua
config/nvim/init.lua
```


### Variant: full

```text
.config/bob/config.toml
.config/dictionaries/words_alpha.txt
.config/harper-ls/dictionary.txt
.config/harper-ls/stats.txt
.config/miro/after/queries
.config/miro/after/queries/javascript
.config/miro/after/queries/javascript/highlights.scm
.config/miro/init.lua
.config/miro/lazy-lock.json
.config/miro/lua/configs
.config/miro/lua/configs/conf_dap_js.lua
.config/miro/lua/configs/conf_dap_rust.lua
.config/miro/lua/configs/conf_lazy.lua
.config/miro/lua/configs/conf_lsp.lua
.config/miro/lua/configs/conf_telescope.lua
.config/miro/lua/configs/conf_toggleterm.lua
.config/miro/lua/configs/tailwind.css-data.json
.config/miro/lua/core/init.lua
.config/miro/lua/core/mappings.lua
.config/miro/lua/core/theme.lua
.config/miro/lua/core/utils.lua
.config/miro/lua/custom
.config/miro/lua/plugins/Comment.lua
.config/miro/lua/plugins/actions-preview.lua
.config/miro/lua/plugins/blink-cmp.lua
.config/miro/lua/plugins/browse.lua
.config/miro/lua/plugins/catpuccin.lua
.config/miro/lua/plugins/conform.lua
.config/miro/lua/plugins/crates.lua
.config/miro/lua/plugins/flash.lua
.config/miro/lua/plugins/gitsigns.lua
.config/miro/lua/plugins/gp.lua
.config/miro/lua/plugins/gruvbox.lua
.config/miro/lua/plugins/indent-blankline.lua
.config/miro/lua/plugins/lualine.lua
.config/miro/lua/plugins/markdown-preview.lua
.config/miro/lua/plugins/mason-tool-installer.lua
.config/miro/lua/plugins/neoclip.lua
.config/miro/lua/plugins/nvim-autopairs.lua
.config/miro/lua/plugins/nvim-dap-python.lua
.config/miro/lua/plugins/nvim-dap-ui.lua
.config/miro/lua/plugins/nvim-dap.lua
.config/miro/lua/plugins/nvim-lspconfig.lua
.config/miro/lua/plugins/nvim-silicon.lua
.config/miro/lua/plugins/nvim-surround.lua
.config/miro/lua/plugins/nvim-tabline.lua
.config/miro/lua/plugins/nvim-treesitter-textobjects.lua
.config/miro/lua/plugins/nvim-treesitter.lua
.config/miro/lua/plugins/nvim-web-devicons.lua
.config/miro/lua/plugins/oil.nvim.lua
.config/miro/lua/plugins/showkeys.lua
.config/miro/lua/plugins/smartyank.lua
.config/miro/lua/plugins/telescope-fzf-native.lua
.config/miro/lua/plugins/telescope.lua
.config/miro/lua/plugins/todo-comments.lua
.config/miro/lua/plugins/toggleterm.lua
.config/miro/lua/plugins/which-key.lua
.config/silicon/syntaxes/.touched
.config/silicon/syntaxes/text.sublime-syntax
.config/silicon/themes/gruvbox-dark-medium.tmTheme
.local/share/examples/nodejs/HappyBirthday.mjs
.local/share/examples/nodejs/README.md
.local/share/examples/nodejs/eslint.config.mjs
.local/share/examples/nodejs/package.json
.local/share/examples/python/test.py
.local/share/examples/rust/Cargo.toml
.local/share/examples/rust/src
.local/share/examples/rust/src/main.rs
bin/nvim_paste.sh
bin/reset_nvim.sh
bin/update_bob.sh
```

