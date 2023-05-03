#! /bin/bash

echo "Installing brew packages"
brew install autoconf automake pkg-config \
	tmux vim fzf ripgrep bat fd \
	jq mosh keychain neofetch ncurses yarn \
	coreutils shellcheck imagemagick \
	eth-p/software/bat-extras || exit
# from older versions
# brew install curl git zsh unzip neovim
# brew cask install kitty

# echo "Installing bat-extras from github"
# cd "${HOME}" || exit
# git clone --depth 1 https://github.com/eth-p/bat-extras.git "${HOME}/.bat"

echo "Installing zsh with theme p10k / bash fallback aliases"
cd "${HOME}" || exit
sh -c "$(curl -fsSL \
	https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) \
  --unattended"
echo "Installing powerlevel10k for zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
	"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
# echo "Installing git-completion for zsh"
# git clone https://github.com/bobthecow/git-flow-completion \
#     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/git-flow-completion"

cd "${HOME}" || exit
# need -f to overwrite the installed .zshrc file
ln -sf .dotfiles/.zshrc .
ln -sf .dotfiles/.p10k.zsh .
ln -sf .dotfiles/.fzf.bash .
ln -sf .dotfiles/.fzf.zsh .
ln -sf .dotfiles/.less_colors.sh .
ln -sf .dotfiles/.dir_colors.sh .
ln -sf .dotfiles/.gitignore .
ln -sf .dotfiles/.preinitialization.sh .
ln -sf .dotfiles/.postinitialization.sh .
ln -sf .dotfiles/.preinitialization.sh .bash_aliases
touch .hushlogin

echo "Installing scripts into ~/bin"
mkdir -p "${HOME}/bin"
cd "${HOME}/bin" || exit
ln -sf ../.dotfiles/bin/ansi-vte52.sh .
ln -sf ../.dotfiles/bin/set_gruvbox_colors.sh .
ln -sf ../.dotfiles/bin/terminal.sh .
ln -sf ../.dotfiles/bin/truecolortest.sh .
ln -sf ../.dotfiles/bin/terminal-colors.py .
ln -sf ../.dotfiles/bin/emoji.js .
ln -sf ../.dotfiles/bin/remove_stale_agents.sh .
ln -sf ../.dotfiles/bin/vff.sh .
ln -sf ../.dotfiles/bin/reset_nvim.sh .

echo "Configuring fzf"
/opt/homebrew/opt/fzf/install --no-update-rc --key-bindings --completion --no-fish

echo "Creating current terminfo files"
# sudo /usr/bin/tic -xe mintty,tmux-256color "${HOME}/.dotfiles/terminfo/terminfo.src"
sudo /usr/bin/tic -x "${HOME}/.dotfiles/terminfo/tmux.terminfo"
sudo /usr/bin/tic -x "${HOME}/.dotfiles/terminfo/xterm-kitty.terminfo"

echo "Configuring ssh"
mkdir -p "${HOME}/.ssh"
cd "${HOME}/.ssh" || exit
ln -sf ../.dotfiles/.ssh/config .

echo "Configuring tmux plugins"
mkdir -p "${HOME}/.config/tmux"
cd "${HOME}/.config/tmux" || exit
ln -sf ../../.dotfiles/.config/tmux/tmux.conf .
mkdir -p "${HOME}/.local/share/tmux/plugins"
cd "${HOME}/.local/share/tmux/plugins" || exit
git clone --depth=1 https://github.com/tmux-plugins/tpm "${HOME}/.local/share/tmux/plugins/tpm"
for p in tmux-network-bandwidth tmux-gruvbox tmux-plugin-cpu; do
	ln -s ../../../../.dotfiles/.local/share/tmux/plugins/$p .
done
"${HOME}/.tmux/plugins/tpm/bin/install_plugins"

echo "Installing the fast Node Manager (fnm) and node"
cd "${HOME}" || exit
brew install fnm
ln -sf .dotfiles/.fnm.sh .
source .fnm.sh
fnm install 'lts/*'
fnm default lts-latest

echo "Configuring git"
cd "${HOME}" || exit
ln -sf .dotfiles/.git_template .
ln -sf .dotfiles/.gitconfig .

echo "Preparing coc"
cd "${HOME}" || exit
mkdir -p "${HOME}/.config/coc/extensions"
cd "${HOME}/.config/coc/extensions" || exit
for p in coc-css coc-diagnostic coc-eslint coc-json coc-snippets coc-svelte coc-tailwindcss coc-tsserver; do
	npm install --install-strategy=shallow --ignore-scripts --no-bin-links --no-package-lock --omit=dev $p
done
# if [[ -d "./node_modules/coc-svelte" ]]; then
#   cd "./node_modules/coc-svelte"
#   npm install --save-dev typescript
# fi

echo "Installing vim configurations"
cd "${HOME}" || exit
mkdir -p "${HOME}/.vim/plugins"
ln -sf .dotfiles/.vimrc .
curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
	"https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
cd "${HOME}/.vim" || exit
ln -sf ../.dotfiles/.vim/coc-settings.json .
vim -es -u "${HOME}/.vimrc" -i NONE -c "PlugInstall" -c "qa"

echo "Installing rust"
# curl https://sh.rustup.rs -sSf | sh -s -- -y
brew install rust
export PATH="${HOME}/.cargo/bin:${PATH}"

echo "Installing tree-sitter cli"
cargo install tree-sitter-cli

echo "Installing neovim configurations"
mkdir -p "${HOME}/.config/miro"
cd "${HOME}/.config/miro" || exit
ln -sf ../../.dotfiles/.config/miro/init.lua .
ln -sf ../../.dotfiles/.config/miro/lua/ .
ln -sf ../../.dotfiles/.config/miro/after/ .

echo "Installing asciidoctor extensions"
# cargo install --version 0.4.2 svgbob_cli
if [[ "${http_proxy}" != "" ]]; then
	OPTS=" --http-proxy ${http_proxy}"
fi
# for specific version use: sudo gem install --version 2.0.4 asciidoctor-diagram
sudo gem install "${OPTS}" asciidoctor-diagram
sudo gem install "${OPTS}" asciidoctor-pdf

echo "Configuring kitty"
cd "${HOME}" || exit
mkdir -p "${HOME}/.config"
cd "${HOME}/.config" || exit
ln -sf ../.dotfiles/.config/kitty .

cd "${HOME}" || exit
