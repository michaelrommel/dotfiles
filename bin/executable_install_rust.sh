#! /usr/bin/env bash

source "${HOME}/.path.d/50_mise.bash"
eval "$(${MISE} hook-env)"

echo "Installing rust"
${MISE} install rust@latest
${MISE} use -g rust@latest
eval "$(${MISE} hook-env)"
rustup component add rust-analyzer
# install shell completions
mkdir -p "${HOME}/.rust/shell"
rustup completions bash >"${HOME}/.local/share/bash-completion/completions/rustup"
rustup completions bash cargo >"${HOME}/.local/share/bash-completion/completions/cargo"
rustup completions zsh >"${HOME}/.local/share/zsh/completions/_rustup"
rustup completions zsh cargo >"${HOME}/.local/share/zsh/completions/_cargo"
chmod 755 "${HOME}/.local/share/zsh/completions/*"
