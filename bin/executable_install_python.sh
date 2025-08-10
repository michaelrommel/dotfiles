#! /usr/bin/env bash

source "${HOME}/.path.d/50_mise.bash"
eval "$(${MISE} hook-env)"

echo "Installing python"
${MISE} install python@latest
${MISE} use -g python@latest
eval "$(${MISE} hook-env)"

if ! python3 -c 'import pip;' >/dev/null 2>&1; then
	echo "Installing pip"
	python3 -mensurepip
fi

python3 -mpip install --upgrade pip

if ! pipx --version >/dev/null 2>&1; then
	echo "Installing pipx"
	python3 -mpip install --user pipx
fi
