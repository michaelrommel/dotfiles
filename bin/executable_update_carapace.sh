#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

update_carapace() {
	echo "Updating carapace..."
	arch="$(get_arch)"
	if [[ "$arch" == "x86_64" ]]; then
		arch="amd64"
	fi
	mkdir -p "${HOME}/bin"
	latest=$(curl -s https://api.github.com/repositories/257400448/tags | jq -r ".[0].name")
	echo "Latest release seems to be: ${latest}"
	TMPDIR=$(mktemp -d /tmp/carapace.XXXXXX) || exit 1
	if ! curl -sL "https://github.com/carapace-sh/carapace-bin/releases/download/${latest}/carapace-bin_${latest#v}_${OS}_${arch}.tar.gz" -o "${TMPDIR}/carapace.tar.gz"; then
		echo "Download failed. Aborting."
		exit 1
	fi
	cd "${TMPDIR}" || exit
	tar xf carapace.tar.gz
	cp carapace "${HOME}/bin/carapace"
	chmod 755 "${HOME}/bin/carapace"
	rm -rf "${TMPDIR}"
	echo "done."
}

update_carapace
