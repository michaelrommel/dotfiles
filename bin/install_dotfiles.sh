#! /bin/bash

echo "Installing apt packages"
sudo apt install curl tmux git vim neovim neofetch zsh golang socat apt-file sysstat net-tools bind9-dnsutils

echo "Installing zsh with theme p10k / bash fallback aliases"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

cd "${HOME}" || exit
ln -s .dotfiles/.zshrc .
ln -s .dotfiles/.p10k.zsh .
ln -s .dotfiles/.initialization.sh .
ln -s .dotfiles/.initialization.sh .bash_aliases

echo "Installing scripts into ~/bin"
mkdir -p "${HOME}/bin"; cd "${HOME}/bin" || exit
ln -s ../.dotfiles/bin/ansi-vte52.sh .
ln -s ../.dotfiles/bin/set_gruvbox_colors.sh .
ln -s ../.dotfiles/bin/terminal.sh .
ln -s ../.dotfiles/bin/truecolortest.sh .

echo "Configuring tmux plugins"
mkdir -p "${HOME}/.tmux/plugins"; cd "${HOME}/.tmux" || exit
git clone --depth=1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
cd plugins || exit
ln -s ../../.dotfiles/.tmux/plugins/tmux-network-bandwidth .
ln -s ../../.dotfiles/.tmux/plugins/tmux-plugin-cpu .
"${HOME}/.tmux/plugins/tpm/bin/install_plugins"
cd "${HOME}" || exit

echo "Installing Node Version Manager (nvm) and node"
/bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"
nvm install --lts=Erbium --latest-npm

echo "Installing vim configurations"
cd "${HOME}" || exit
mkdir -p "${HOME}/.vim/plugins";
ln -s .dotfiles/.vimrc .
curl -fLo "${HOME}/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
cd "${HOME}/.vim" || exit
ln -s ../.dotfiles/.vim/coc-settings .

echo "Installing neovim configurations"
curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
mkdir -p "${HOME}/.config/nvim"; cd "${HOME}/.config/nvim" || exit
ln -s ../../.dotfiles/.vim/coc-settings.json .
ln -s ../../.dotfiles/.vimrc init.vim

echo "REMEMBER: You must still run ':PlugInstall' within vim and nvim"

