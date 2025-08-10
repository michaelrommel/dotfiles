#! /usr/bin/env zsh

ARCH=$(uname -m)
OS=$(uname -s)
FD=$(which fd)

if [[ "${OS}" == "Darwin" ]]; then
	if [[ "${ARCH}" == "arm64" ]]; then
		# homebrew is installed in /opt/homebrew
		WHERE=/opt/homebrew/opt/fzf
	else
		# homebrew is installed under /usr/local
		WHERE=/usr/local/opt/fzf
	fi
else
	WHERE=${HOME}/.fzf
fi

# Setup fzf
# ---------
if [[ ! ":${PATH}:" == *:${WHERE}/bin:* ]]; then
	export PATH="${WHERE}/bin:${PATH}"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && [[ -d "${WHERE}/" ]] && source "${WHERE}/shell/completion.zsh" 2>/dev/null

# Key bindings
# ------------
[[ -d "${WHERE}" ]] && source "${WHERE}/shell/key-bindings.zsh"

if [[ -x "${FD}" ]]; then
	export FZF_DEFAULT_COMMAND='fd --type file'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
