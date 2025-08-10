#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

update_yazi() {
	echo "Updating yazi..."
	platform="$(get_alt_platform)"
	arch="$(get_arch)"
	mkdir -p "${HOME}/bin"
	mkdir -p "${HOME}/.config/completions/yazi"
	latest=$(curl -s https://api.github.com/repositories/663900193/tags | jq -r ".[0].name")
	echo "Latest release seems to be: ${latest}"
	TMPDIR=$(mktemp -d /tmp/yazi.XXXXXX) || exit 1
	if ! curl -sL "https://github.com/sxyazi/yazi/releases/download/${latest}/yazi-${arch}-${platform}.zip" -o "${TMPDIR}/yazi.zip"; then
		echo "Download failed. Aborting."
		exit 1
	fi
	cd "${TMPDIR}" || exit
	unzip yazi.zip
	cd "yazi-${arch}-${platform}" || exit
	# we drop yazi into cargo, since it can be installed
	# from there as well
	cp yazi "${HOME}/.cargo/bin/yazi"
	cp ya "${HOME}/.cargo/bin/ya"
	chmod 755 "${HOME}/.cargo/bin/yazi"
	chmod 755 "${HOME}/.cargo/bin/ya"
	cp completions/{ya,yazi}.bash "${HOME}/.config/completions/yazi/"
	rm -rf "${TMPDIR}"
	echo "done."
}

update_yazi
