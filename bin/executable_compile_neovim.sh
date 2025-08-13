#! /usr/bin/env bash

echo "Compiling and installing neovim (./software/neovim*)"
cd "${HOME}" || exit
mkdir -p "${HOME}/software/"
cd "${HOME}/software/" || exit
git clone --filter=tree:0 https://github.com/neovim/neovim neovim_src
cd neovim_src || exit
#git checkout stable
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${HOME}/software/neovim"
make install

