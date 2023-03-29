#! /bin/bash

echo "Installing apt packages"
sudo apt-get -y  update
sudo apt-get -y install build-essential autoconf automake pkg-config \
    libevent-dev libncurses5-dev bison byacc curl tmux git vim \
    mosh keychain neofetch zsh ncurses-bin gdebi-core apt-file \
    unzip sysstat net-tools dnsutils shellcheck asciidoctor \
    python3-pip universal-ctags software-properties-common \
    bc dh-autoreconf libcurl4-gnutls-dev libexpat1-dev \
    gawk gettext libz-dev libssl-dev install-info  || exit

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

OSRELEASE=$( "${UNAME}" -r )
if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then
  # on WSL2 install golang to be able to compile npiperelay
  sudo apt-get -y install golang socat
fi

echo "Installing ripgrep from github"
cd "${HOME}" || exit
mkdir -p "${HOME}/software/archives"; cd "${HOME}/software/archives" || exit
curl -OL https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
sudo dpkg -i "${HOME}/software/archives/ripgrep_12.1.1_amd64.deb"

echo "Installing fd from github"
# provides faster find version, not available for Ubuntu 18.04
cd "${HOME}" || exit
mkdir -p "${HOME}/software/archives"; cd "${HOME}/software/archives" || exit
curl -OL https://github.com/sharkdp/fd/releases/download/v8.1.1/fd_8.1.1_amd64.deb
sudo dpkg -i "${HOME}/software/archives/fd_8.1.1_amd64.deb"

echo "Installing bat from github"
# provides syntax highlighting pager
cd "${HOME}" || exit
mkdir -p "${HOME}/software/archives"; cd "${HOME}/software/archives" || exit
curl -OL https://github.com/sharkdp/bat/releases/download/v0.17.1/bat_0.17.1_amd64.deb
sudo dpkg -i "${HOME}/software/archives/bat_0.17.1_amd64.deb"

echo "Installing bat-extras from github"
cd "${HOME}" || exit
git clone --depth 1 https://github.com/eth-p/bat-extras.git "${HOME}/.bat"

echo "Installing fzf from github"
# needs to come before zsh, as we are sourceing completion & keybindings there
cd "${HOME}" || exit
git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
"${HOME}/.fzf/install" --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish

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
ln -sf .dotfiles/.fzf.bash .
ln -sf .dotfiles/.fzf.zsh .
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
if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then
  # on WSL2 install a shell script with npiperelay as ssh-agent
  ln -sf ../.dotfiles/bin/wsl2-relay-agent.sh ssh-agent
  # install the wsltty configuration
  cp ../.dotfiles/.wsltty/.wsltty.conf "/mnt/c/Users/rommminw/AppData/Roaming/wsltty/config"
  cp ../.dotfiles/.wsltty/gruvbox_dark.minttyrc "/mnt/c/Users/rommminw/AppData/Roaming/wsltty/config/themes"
  cd /mnt/c/Users/rommminw/AppData/Roaming/wsltty/ || exit
  mkdir -p emojis/.git/info; cd emojis || exit
  git init
  git remote add origin https://github.com/iamcal/emoji-data.git
  git config core.sparsecheckout true
  echo img-apple-64 >>.git/info/sparse-checkout
  git pull --depth=1 origin master
  mv img-apple-64 apple
fi

echo "Creating current terminfo files"
cd "${HOME}" || exit
sudo /usr/bin/tic -xe mintty,tmux-256color "${HOME}/.dotfiles/terminfo/terminfo.src"

echo "Configuring ssh"
cd "${HOME}" || exit
mkdir -p "${HOME}/.ssh"; cd "${HOME}/.ssh" || exit
ln -sf ../.dotfiles/.ssh/config .

GIT_VERSION=$(git --version |sed -e 's/git version \([0-9]*\.[0-9]*\)\..*/\1/')
if (( $(echo "${GIT_VERSION} < 2.26" | bc -l) )); then
  # echo "Building git"
  # cd "${HOME}" || exit
  # mkdir -p "${HOME}/software"; cd "${HOME}/software" || exit
  # git clone git://git.kernel.org/pub/scm/git/git.git
  # sudo apt remove -y git
  # cd git || exit
  # make configure
  # ./configure --prefix=/usr
  # make all info
  # sudo make install install-info
  source /etc/os-release
  if [[ ${VERSION_CODENAME} == "buster" ]]; then
    echo "Adding buster backports"
    echo "deb http://deb.debian.org/debian buster-backports main" \
      | sudo tee /etc/apt/sources.list.d/buster-backports.list
    sudo apt update
    sudo apt install -y -t buster-backports git
  fi
fi

# TMUX_VERSION=$(tmux -V)
# if [[ "${TMUX_VERSION}" != "tmux 3.1b" ]]; then
#   echo "Building tmux"
#   mkdir -p "${HOME}/software"; cd "${HOME}/software" || exit
#   git clone https://github.com/tmux/tmux.git
#   cd "${HOME}/software/tmux" || exit
#   git checkout 3.1b
#   sh autogen.sh
#   ./configure && make
#   sudo make install
# fi

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

# echo "Installing Node Version Manager (nvm) and node"
# cd "${HOME}" || exit
# /bin/bash -c "$(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh)"
# export NVM_DIR="$HOME/.nvm"
# # shellcheck source=/dev/null
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# nvm install 'lts/*' --latest-npm

echo "Installing the fast Node Manager (fnm) and node"
cd "${HOME}" || exit
curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | bash -s -- --skip-shell
ln -sf .dotfiles/.fnm.sh .
source .fnm.sh
fnm install 'lts/*'
fnm default lts-latest

echo "Installing yarn"
cd "${HOME}" || exit
npm install --global yarn
# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# sudo apt update && sudo apt install -y yarn

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
#   cd "./node_modules/coc-svelte" || exit
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

# echo "Updating neovim"
# sudo add-apt-repository -y ppa:neovim-ppa/stable
# sudo apt install -y neovim
#
# echo "Installing neovim configurations"
# curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
#     "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
# mkdir -p "${HOME}/.config/nvim"; cd "${HOME}/.config/nvim" || exit
# ln -sf ../../.dotfiles/.vim/coc-settings.json .
# ln -sf ../../.dotfiles/.vimrc init.vim
# nvim -es -u "${HOME}/.config/nvim/init.vim" -i NONE -c "PlugInstall" -c "qa"

echo "Installing asciidoctor extensions"
# for specific version use: sudo gem install --version 2.0.4 asciidoctor-diagram
if [[ "${http_proxy}" != "" ]]; then
  OPTS=" --http-proxy ${http_proxy}"
fi
sudo gem install ${OPTS} asciidoctor-diagram
sudo gem install ${OPTS} asciidoctor-pdf
curl https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="${HOME}/.cargo/bin:${PATH}"
# cargo install --version 0.4.2 svgbob_cli

cd "${HOME}" || exit
sudo chsh -s /usr/bin/zsh $(whoami)
exec /usr/bin/zsh

