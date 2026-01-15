#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

if ! rg -V >/dev/null 2>&1; then
	latest=$(curl -sL https://api.github.com/repos/BurntSushi/ripgrep/releases | jq -r ".[0].tag_name") || exit 1

	if is_amzn; then
		echo "Installing ripgrep locally from github"
		echo "Latest release seems to be: ${latest}"
		# provides faster grep
		cd "${HOME}" || exit
		mkdir -p "${HOME}/software/archives"
		cd "${HOME}/software/archives" || exit
		arch="$(get_arch)"
		if [ "$arch" = x86_64 ]; then
			libc="musl"
		elif [ "$arch" = aarch64 ]; then
			libc="gnu"
		else
			echo "unsupported architecture: $arch"
			exit 1
		fi
		curl -sOL https://github.com/BurntSushi/ripgrep/releases/download/${latest}/ripgrep-${latest}-${ARCH}-unknown-linux-${libc}.tar.gz
		cd "${HOME}/software" || exit
		tar xf archives/ripgrep-${latest}-${ARCH}-unknown-linux-${libc}.tar.gz
		cd "ripgrep-${latest}-${ARCH}-unknown-linux-${libc}" || exit
		cp rg "${HOME}/bin/rg"
		cp doc/rg.1 "${HOME}/.local/share/man/man1/rg.1"
		cp complete/_rg "${HOME}/.local/share/zsh/completions/_rg"
		chmod 755 "${HOME}/.local/share/zsh/completions/_rg"
		cp complete/rg.bash "${HOME}/.local/share/bash-completion/completions/rg"
	else
		echo "Installing ripgrep deb package from github"
		echo "Latest release seems to be: ${latest}"
		# provides faster grep
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
		curl -sOL "https://github.com/BurntSushi/ripgrep/releases/download/${latest}/ripgrep_${latest}_${arch}.deb"
		sudo dpkg -i "${HOME}/software/archives/ripgrep_${latest}_${arch}.deb"
	fi
fi
