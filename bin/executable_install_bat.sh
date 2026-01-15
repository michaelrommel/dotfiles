#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

if ! bat -V >/dev/null 2>&1; then
	latest=$(curl -sL https://api.github.com/repos/sharkdp/bat/releases | jq -r ".[0].tag_name") || exit 1

	if is_amzn; then
		echo "Installing bat locally from github"
		echo "Latest release seems to be: ${latest}"
		cd "${HOME}" || exit
		mkdir -p "${HOME}/software/archives"
		cd "${HOME}/software/archives" || exit
		curl -sOL https://github.com/sharkdp/bat/releases/download/${latest}/bat-${latest}-${ARCH}-unknown-linux-gnu.tar.gz
		cd "${HOME}/software" || exit
		tar xf archives/bat-${latest}-${ARCH}-unknown-linux-gnu.tar.gz
		cd "bat-${latest}-${ARCH}-unknown-linux-gnu" || exit
		cp bat "${HOME}/bin/bat"
		cp bat.1 "${HOME}/.local/share/man/man1/bat.1"
		cp autocomplete/bat.zsh "${HOME}/.local/share/zsh/completions/_bat"
		chmod 755 "${HOME}/.local/share/zsh/completions/_bat"
		cp autocomplete/bat.bash "${HOME}/.local/share/bash-completion/completions/bat"
	else
		echo "Installing bat deb package from github"
		echo "Latest release seems to be: ${latest}"
		cd "${HOME}" || exit
		mkdir -p "${HOME}/software/archives"
		cd "${HOME}/software/archives" || exit
		arch="$(get_arch)"
		if [ "$arch" = x86_64 ]; then
			arch="amd64"
		elif [ "$arch" = aarch64 ]; then
			arch="arm64"
		else
			echo "unsupported architecture: $arch"
			exit 1
		fi
		curl -sOL "https://github.com/sharkdp/bat/releases/download/${latest}/bat_${latest}_${arch}.deb"
		sudo dpkg -i "${HOME}/software/archives/bat_${latest}_${arch}.deb"
	fi
fi
