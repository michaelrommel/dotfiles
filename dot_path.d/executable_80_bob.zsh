#! /usr/bin/env zsh

if [[ -d "${HOME}/.local/share/bob/nvim-bin" && ! ":${PATH}:" == *:${HOME}/.local/share/bob/nvim-bin:* ]]; then
	# path has not yet been added
	export PATH="${HOME}/.local/share/bob/nvim-bin:${PATH}"
fi
