#! /usr/bin/env zsh
if carapace --version >/dev/null 2>&1; then
	export CARAPACE_BRIDGES='zsh,bash'
	export CARAPACE_EXCLUDES='kill'
	export CARAPACE_MATCH=1
	autoload -Uz compinit && compinit
	source <(carapace _carapace)
fi
