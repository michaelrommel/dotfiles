#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

update_bob() {
	echo "Updating bob..."
	arch="$(get_arch)"
	if [[ "$OS" == "darwin" ]]; then
		OS="macos"
	fi
	mkdir -p "${HOME}/bin"
	latest=$(curl -s https://api.github.com/repositories/456199616/tags | jq -r ".[0].name")
	echo "Latest release seems to be: ${latest}"
	TMPDIR=$(mktemp -d /tmp/bob.XXXXXX) || exit 1
	if ! curl -sL "https://github.com/MordechaiHadad/bob/releases/download/${latest}/bob-${OS}-${arch}.zip" -o "${TMPDIR}/bob.zip"; then
		echo "Download failed. Aborting."
		exit 1
	fi
	cd "${TMPDIR}" || exit
	unzip bob.zip
	cd "bob-${OS}-${arch}" || exit
	cp bob "${HOME}/.cargo/bin/bob"
	chmod 755 "${HOME}/.cargo/bin/bob"
	rm -rf "${TMPDIR}"
	echo "done."
}

update_bob
