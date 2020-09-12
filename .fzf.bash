#! /bin/bash

# Setup fzf
# ---------
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && [[ -d "${HOME}/.fzf/" ]] && source "${HOME}/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
[[ -d "${HOME}/.fzf/" ]] && source "${HOME}/.fzf/shell/key-bindings.bash"

[[ -x "/usr/bin/fd" ]] && export FZF_DEFAULT_COMMAND='fd --type file'
