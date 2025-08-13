#! /usr/bin/env bash

cd "${HOME}" || exit
mkdir -p "${HOME}/software"
cd "${HOME}/software" || exit
git clone git://git.kernel.org/pub/scm/git/git.git git_src
cd git_src || exit
make configure
./configure --prefix="${HOME}/software/git"
make all info
sudo make install install-info
