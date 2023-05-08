#! /bin/bash

NVAN=miro
cd "${HOME}" || exit
rm -rf ".cache/${NVAN}"
rm -rf ".config/${NVAN}"
rm -rf ".local/share/${NVAN}"
rm -rf ".local/state/${NVAN}"

mkdir -p ".config/${NVAN}"
cd ".config/${NVAN}" || exit
ln -sf ../../.dotfiles/.config/${NVAN}/init.lua .
ln -sf ../../.dotfiles/.config/${NVAN}/lua/ .
ln -sf ../../.dotfiles/.config/${NVAN}/after/ .
