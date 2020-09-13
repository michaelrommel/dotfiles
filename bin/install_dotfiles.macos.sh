#! /bin/bash

echo "Installing brew packages"
brew install autoconf automake pkg-config \
    curl tmux vim neovim fzf ripgrep bat fd \
    mosh keychain neofetch zsh ncurses \
    unzip sysstat shellcheck yarn || exit

echo "Installing bat-extras from github"
cd "${HOME}" || exit
git clone --depth 1 https://github.com/eth-p/bat-extras.git "${HOME}/.bat"

echo "Installing zsh with theme p10k / bash fallback aliases"
cd "${HOME}" || exit
sh -c "$(curl -fsSL \
  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) \
  --unattended"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

cd "${HOME}" || exit
# need -f to overwrite the installed .zshrc file
ln -sf .dotfiles/.zshrc .
ln -sf .dotfiles/.fzf.bash .
ln -sf .dotfiles/.fzf.zsh .
ln -sf .dotfiles/.p10k.zsh .
ln -sf .dotfiles/.less_colors.sh .
ln -sf .dotfiles/.dir_colors.sh .
ln -sf .dotfiles/.initialization.sh .
ln -sf .dotfiles/.initialization.sh .bash_aliases
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

echo "Creating current terminfo files"
sudo /usr/bin/tic -xe mintty,tmux-256color "${HOME}/.dotfiles/terminfo/terminfo.src"

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
curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | bash -s -- --skip-shell
ln -sf .dotfiles/.fnm.sh .
source .fnm.sh
fnm install 'lts/*'
fnm default latest-erbium

echo "Configuring git"
cd "${HOME}" || exit
ln -sf .dotfiles/.git_template .
ln -sf .dotfiles/.gitconfig .

echo "Preparing coc"
cd "${HOME}" || exit
mkdir -p "${HOME}/.config/coc/extensions"
cd "${HOME}/.config/coc/extensions" || exit
ln -sf ../../../.dotfiles/.config/coc/extensions/package.json .
npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod 
if [[ -d "./node_modules/coc-svelte" ]]; then
  cd "./node_modules/coc-svelte"
  npm install --save-dev typescript
fi

echo "Installing vim configurations"
cd "${HOME}" || exit
mkdir -p "${HOME}/.vim/plugins";
ln -sf .dotfiles/.vimrc .
curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
cd "${HOME}/.vim" || exit
ln -sf ../.dotfiles/.vim/coc-settings.json .
vim -es -u "${HOME}/.vimrc" -i NONE -c "PlugInstall" -c "qa"

echo "Installing neovim configurations"
curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
mkdir -p "${HOME}/.config/nvim"; cd "${HOME}/.config/nvim" || exit
ln -sf ../../.dotfiles/.vim/coc-settings.json .
ln -sf ../../.dotfiles/.vimrc init.vim
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE -c "PlugInstall" -c "qa"

cd "${HOME}" || exit
exec /usr/bin/zsh

