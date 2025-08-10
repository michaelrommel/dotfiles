#! /usr/bin/env bash

if [[ -d "${HOME}/software/tmux/bin" && ! ":${PATH}:" == *:${HOME}/software/tmux/bin:* ]]; then
	export PATH="${HOME}/software/tmux/bin:${PATH}"
fi
