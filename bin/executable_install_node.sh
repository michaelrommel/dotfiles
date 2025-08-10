#! /usr/bin/env bash

source "${HOME}/.path.d/50_mise.bash"
eval "$(${MISE} hook-env)"

echo "Installing node"
${MISE} install node@latest
${MISE} use -g node@latest
eval "$(${MISE} hook-env)"

if ! yarn --version >/dev/null 2>&1; then
	echo "Installing yarn"
	cd "${HOME}" || exit
	npm install --global yarn
fi

if ! pnpm--version >/dev/null 2>&1; then
	echo "Installing pnpm"
	cd "${HOME}" || exit
	npm install --global pnpm
fi
