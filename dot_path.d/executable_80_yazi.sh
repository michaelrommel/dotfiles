#! /usr/bin/env bash

function y() {
	local tmp cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd" || exit
	fi
	rm -f -- "$tmp"
}

# Auto-completion
# ---------------
if [[ $- == *i* && -d "${HOME}/.yazi" ]]; then
	source "${HOME}/.config/completions/yazi/yazi.bash" 2>/dev/null
	source "${HOME}/.config/completions/yazi/ya.bash" 2>/dev/null
fi
