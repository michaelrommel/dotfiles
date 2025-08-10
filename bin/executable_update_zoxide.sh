#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

update_zoxide() {
	echo "Updating zoxide..."
	platform="$(get_alt_platform)"
	arch="$(get_arch)"
	mkdir -p "${HOME}/bin"
	latest=$(curl -s https://api.github.com/repositories/245166720/tags | jq -r ".[0].name")
	echo "Latest release seems to be: ${latest}"
	TMPDIR=$(mktemp -d /tmp/zoxide.XXXXXX) || exit 1
	if ! curl -sL "https://github.com/ajeetdsouza/zoxide/releases/download/${latest}/zoxide-${latest#v}-${arch}-${platform}.tar.gz" -o "${TMPDIR}/zoxide.tar.gz"; then
		echo "Download failed. Aborting."
		exit 1
	fi
	cd "${TMPDIR}" || exit
	tar xf zoxide.tar.gz
	cp zoxide "${HOME}/.cargo/bin/zoxide"
	chmod 755 "${HOME}/.cargo/bin/zoxide"
	rm -rf "${TMPDIR}"
	echo "done."
}

update_zoxide
