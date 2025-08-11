#! /usr/bin/env bash

ARCH=$(uname -m)
OS=$(uname -s)

# Setup bat-extras
# ----------------
if [[ ! ":${PATH}:" == *:${HOME}/software/bat/bin:* ]]; then
	export PATH="${HOME}/software/bat/bin${PATH:+:${PATH}}"
fi
