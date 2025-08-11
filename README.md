# github.com/michaelrommel/dotfiles

Michael Rommel's dotfiles managed with `chezmoi`.

Install them with:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply michaelrommel
```

## Roles and neovim variations


### Role: none selected at all

You get a super small installation that only adds a small shell
configuration, some aliases and a few scripts, that would allow 
to install a package manager and programming languages.


### Role: core

You get:
- a proper zsh configuration
- starship prompt
- config files for many utilities
- fzf fuzzy finder/selector
- carapace zshell completor
- yazi file manager
- zoxide cd tool
- proxy ssh-agent to Windows ssh-agent
- the mise version manager


### Role: tmux

You get a locally compiled tmux with the latest features 
including sixel fixes and utf8 processing. This will install
a heap of dependencies for compilation and the go language.

It has a sane default configuration using Ctrl-A because 
I do want Ctrl-B to be available for sending `breaks` to 
microcontrollers.


### Role: tools

More tools:
- rg ripgrep the fastest grepper in the universe
- fd fast file finder
- bat cat version with syntax highlighting
- shellcheck
- shfmt shell script formatter


### Role: languages

Programming languages
- Rust
- Python
- node.js
- Go


### Role: neovim

There are two variations: minimal and full

**Minimal**: uses mise to install the nightly version and uses its internal package manager and installs only very few modules, like: treesitter, lsp-config, mason and oil as well as a contrast color theme.

**Full**: compiles bob as the neovim version, installs nightly and a full configuration with around 40 modules for code formatting, auto brackets, jumping etc. as well as debugger support via nvim-dap.



