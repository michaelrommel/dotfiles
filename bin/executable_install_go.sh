#! /usr/bin/env bash

SW=$(readlink -f "${HOME}/software")
if [[ -z "$SW" ]]; then
	os="$(get_os)"
	if [[ "${os}" == "macos" ]]; then
		mkdir ~/Software
	else
		mkdir ~/software
	fi
fi

GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH
export PATH="${GOPATH}/bin:${PATH}"

source "${HOME}/.path.d/50_mise.bash"
eval "$(${MISE} hook-env)"
${MISE} install go@latest
${MISE} use -g go@latest
${MISE} reshim
eval "$(${MISE} hook-env)"
type go
