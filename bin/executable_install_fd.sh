#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

if ! fd -V >/dev/null 2>&1; then
	latest=$(curl -sL https://api.github.com/repos/sharkdb/fd/releases | jq -r ".[0].tag_name") || exit 1

	if is_amzn; then
		echo "Installing fd locally from github"
		echo "Latest release seems to be: ${latest}"
		# provides faster find version
		cd "${HOME}" || exit
		mkdir -p "${HOME}/software/archives"
		cd "${HOME}/software/archives" || exit
		curl -OL https://github.com/sharkdp/fd/releases/download/${latest}/fd-${latest}-${ARCH}-unknown-linux-gnu.tar.gz
		cd "${HOME}/software" || exit
		tar xf archives/fd-${latest}-${ARCH}-unknown-linux-gnu.tar.gz
		cd "fd-${latest}-${ARCH}-unknown-linux-gnu" || exit
		cp fd "${HOME}/bin/fd"
		cp fd.1 "${HOME}/.local/share/man/man1/fd.1"
		cp autocomplete/_fd "${HOME}/.local/share/zsh/completions/_fd"
		chmod 755 "${HOME}/.local/share/zsh/completions/_fd"
		cp autocomplete/fd.bash "${HOME}/.local/share/bash-completion/completions/fd"
	else
		echo "Installing fd deb package from github"
		echo "Latest release seems to be: ${latest}"
		# provides faster find version, not available for Ubuntu 18.04
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
		curl -OL "https://github.com/sharkdp/fd/releases/download/${latest}/fd_${latest}_${arch}.deb"
		sudo dpkg -i "${HOME}/software/archives/fd_${latest}_${arch}.deb"
	fi
fi
