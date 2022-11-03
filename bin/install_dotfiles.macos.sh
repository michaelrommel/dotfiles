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
ln -sf .dotfiles/.less_colors.sh .
ln -sf .dotfiles/.dir_colors.sh .
ln -sf .dotfiles/.gitignore .
ln -sf .dotfiles/.preinitialization.sh .
ln -sf .dotfiles/.postinitialization.sh .
ln -sf .dotfiles/.preinitialization.sh .bash_aliases
touch .hushlogin

echo "Installing scripts into ~/bin"
mkdir -p "${HOME}/bin"; cd "${HOME}/bin" || exit
ln -sf ../.dotfiles/bin/ansi-vte52.sh .
ln -sf ../.dotfiles/bin/set_gruvbox_colors.sh .
ln -sf ../.dotfiles/bin/terminal.sh .
ln -sf ../.dotfiles/bin/truecolortest.sh .
ln -sf ../.dotfiles/bin/terminal-colors.py .
ln -sf ../.dotfiles/bin/emoji.js .
ln -sf ../.dotfiles/bin/remove_stale_agents.sh .
ln -sf ../.dotfiles/bin/vff.sh .

echo "Configuring fzf"
/opt/homebrew/opt/fzf/install --no-update-rc --key-bindings --completion --no-fish

echo "Creating current terminfo files"
# sudo /usr/bin/tic -xe mintty,tmux-256color "${HOME}/.dotfiles/terminfo/terminfo.src"
sudo /usr/bin/tic -xe tmux-256color "${HOME}/.dotfiles/terminfo/terminfo.src"

echo "Configuring ssh"
mkdir -p "${HOME}/.ssh"; cd "${HOME}/.ssh" || exit
ln -sf ../.dotfiles/.ssh/config .

echo "Configuring tmux plugins"
cd "${HOME}" || exit
ln -sf .dotfiles/.tmux.conf .
mkdir -p "${HOME}/.tmux/plugins"; cd "${HOME}/.tmux" || exit
git clone --depth=1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
cd plugins || exit
ln -s ../../.dotfiles/.tmux/plugins/tmux-network-bandwidth .
ln -s ../../.dotfiles/.tmux/plugins/tmux-plugin-cpu .
"${HOME}/.tmux/plugins/tpm/bin/install_plugins"
cd tmux-gruvbox || exit
ln -sf ../../../.dotfiles/.tmux/plugins/tmux-gruvbox/tmux-gruvbox-dark.conf .

echo "Installing the fast Node Manager (fnm) and node"
cd "${HOME}" || exit
brew install fnm
ln -sf .dotfiles/.fnm.sh .
source .fnm.sh
fnm install 'v18'
fnm default 'v18'

echo "Configuring git"
cd "${HOME}" || exit
ln -sf .dotfiles/.git_template .
ln -sf .dotfiles/.gitconfig .

echo "Preparing coc"
cd "${HOME}" || exit
mkdir -p "${HOME}/.config/coc/extensions"
cd "${HOME}/.config/coc/extensions" || exit
ln -sf ../../../.dotfiles/.config/coc/extensions/package.json .
npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --omit=dev
# if [[ -d "./node_modules/coc-svelte" ]]; then
#   cd "./node_modules/coc-svelte"
#   npm install --save-dev typescript
# fi

echo "Installing vim configurations"
cd "${HOME}" || exit
mkdir -p "${HOME}/.vim/plugins";
ln -sf .dotfiles/.vimrc .
curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
cd "${HOME}/.vim" || exit
ln -sf ../.dotfiles/.vim/coc-settings.json .
vim -es -u "${HOME}/.vimrc" -i NONE -c "PlugInstall" -c "qa"

# echo "Installing neovim configurations"
# curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
#     "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
# mkdir -p "${HOME}/.config/nvim"; cd "${HOME}/.config/nvim" || exit
# ln -sf ../../.dotfiles/.vim/coc-settings.json .
# ln -sf ../../.dotfiles/.vimrc init.vim
# nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE -c "PlugInstall" -c "qa"

echo "Configuring kitty"
cd "${HOME}" || exit
mkdir -p "${HOME}/.config"
cd "${HOME}/.config" || exit
ln -sf ../.dotfiles/.config/kitty .

cd "${HOME}" || exit
exec /bin/zsh

