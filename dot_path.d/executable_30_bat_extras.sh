#! /usr/bin/env bash

ARCH=$(uname -m)
OS=$(uname -s)

if [[ "${OS}" == "Darwin" ]]; then
	if [[ "${ARCH}" == "arm64" ]]; then
		# homebrew is installed in /opt/homebrew
		WHERE=${HOME}/.bat
	else
		# homebrew is installed under /usr/local
		WHERE=${HOME}/.bat
	fi
else
	WHERE=${HOME}/.bat
fi

# Setup bat-extras
# ----------------
if [[ ! ":${PATH}:" == *:${WHERE}/bin:* ]]; then
	export PATH="${WHERE}/bin${PATH:+:${PATH}}"
fi
