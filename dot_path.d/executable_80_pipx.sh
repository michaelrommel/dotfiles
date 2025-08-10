#! /usr/bin/env zsh

if [[ -d "${HOME}/.local/bin" && ! ":${PATH}:" == *:${HOME}/.local/bin:* ]]; then
	# path has not yet been added
	export PATH="${HOME}/.local/bin:${PATH}"
fi
