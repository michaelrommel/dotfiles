#! /usr/bin/env bash

if carapace --version >/dev/null 2>&1; then
	export CARAPACE_BRIDGES='zsh,bash'
	export CARAPACE_EXCLUDES='kill'
	# shellcheck disable=SC1090
	source <(carapace _carapace)
fi
