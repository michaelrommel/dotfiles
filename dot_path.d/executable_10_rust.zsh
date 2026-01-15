#! /usr/bin/env zsh

# mise and rustup would automatically set the path for us, but
# in a minimal install, where we just have some binaries there
# the env file is missing and the path not added

if [[ -d "${HOME}/.cargo/bin" ]]; then
	# rustup shell setup
	# affix colons on either side of $PATH to simplify matching
	case ":${PATH}:" in
	*:"$HOME/.cargo/bin":*) ;;
	*)
		# Prepending path in case a system-installed rustc needs to be overridden
		export PATH="$HOME/.cargo/bin:$PATH"
		;;
	esac
fi

# Auto-completion
# ---------------
# manual sourcing should no longer be necessary since this dir should be automatically searched
# if [[ $- == *i* && -d "${HOME}/.local/share/zsh/completions/" ]]; then
# 	fpath=(${HOME}/.local/share/zsh/completions/ $fpath)
# fi
