#!/usr/bin/env bash

source "${HOME}/bin/helper.sh"

get_target() {
	arch="$1"
	platform="$2"
	target="$arch-$platform"

	if [ "${target}" = "arm-unknown-linux-musl" ]; then
		target="${target}eabihf"
	fi

	printf '%s' "${target}"
}

update_starship() {
	echo "Updating starship..."
	platform="$(get_alt_platform)"
	arch="$(get_arch)"
	TARGET="$(get_target "${arch}" "${platform}")"
	mkdir -p "${HOME}/bin"
	TMPDIR=$(mktemp -d /tmp/starship.XXXXXX) || exit 1
	if ! curl -sL "https://github.com/starship/starship/releases//latest/download/starship-${TARGET}.tar.gz" -o "${TMPDIR}/starship.tar.gz"; then
		echo "Download failed. Aborting."
		exit 1
	fi
	cd "${TMPDIR}" || exit
	tar xf starship.tar.gz
	# we drop starship into cargo, since it can be installed
	# from there as well
	cp starship "${HOME}/.cargo/bin/starship"
	chmod 755 "${HOME}/.cargo/bin/starship"
	rm -rf "${TMPDIR}"
	echo "done."
}

update_starship
