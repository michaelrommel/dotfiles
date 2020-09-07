#! /bin/bash

echo "Installing apt packages"
sudo apt update
sudo apt install -y build-essential autoconf automake pkg-config \
    libevent-dev libncurses5-dev bison byacc curl tmux git vim \
    neofetch zsh golang ncurses-bin socat apt-file \
    sysstat net-tools dnsutils shellcheck || exit

echo "Installing zsh with theme p10k / bash fallback aliases"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

cd "${HOME}" || exit
# need -f to overwrite the installed .zshrc file
ln -sf .dotfiles/.zshrc .
ln -s .dotfiles/.p10k.zsh .
ln -s .dotfiles/.initialization.sh .
ln -s .dotfiles/.initialization.sh .bash_aliases

echo "Installing scripts into ~/bin"
mkdir -p "${HOME}/bin"; cd "${HOME}/bin" || exit
ln -s ../.dotfiles/bin/ansi-vte52.sh .
ln -s ../.dotfiles/bin/set_gruvbox_colors.sh .
ln -s ../.dotfiles/bin/terminal.sh .
ln -s ../.dotfiles/bin/truecolortest.sh .

echo "Creating current terminfo files"
/usr/bin/tic -xe mintty,tmux-256color "${HOME}/.dotfiles/terminfo/terminfo.src"

echo "Configuring ssh"
mkdir -p "${HOME}/.ssh"; cd "${HOME}/.ssh" || exit
ln -sf ../.dotfiles/.ssh/config .

echo "compiling and installing a current tmux version"
mkdir -p "${HOME}/software"; cd "${HOME}/software" || exit
git clone https://github.com/tmux/tmux.git
cd "${HOME}/software/tmux" || exit
git checkout 3.1b
sh autogen.sh
./configure && make
sudo make install

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
cd "${HOME}" || exit

echo "Installing Node Version Manager (nvm) and node"
/bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 'lts/*' --latest-npm

echo "Installing yarn"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn

echo "Installing vim configurations"
cd "${HOME}" || exit
mkdir -p "${HOME}/.vim/plugins";
ln -sf .dotfiles/.vimrc .
curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
cd "${HOME}/.vim" || exit
ln -sf ../.dotfiles/.vim/coc-settings .
vim -es -u "${HOME}/.vimrc" -i NONE -c "PlugInstall" -c "qa"

echo "Updating neovim"
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt install neovim

echo "Installing neovim configurations"
curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
mkdir -p "${HOME}/.config/nvim"; cd "${HOME}/.config/nvim" || exit
ln -sf ../../.dotfiles/.vim/coc-settings.json .
ln -sf ../../.dotfiles/.vimrc init.vim
nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE -c "PlugInstall" -c "qa"

cd "${HOME}" || exit
exec /usr/bin/zsh

