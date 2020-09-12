# #! /usr/bin/zsh

# Setup fzf
# ---------
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && [[ -d "${HOME}/.fzf/" ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
[[ -d "${HOME}/.fzf/" ]] && source "${HOME}/.fzf/shell/key-bindings.zsh"

if [[ -x "/usr/bin/fd" ]]; then
  export FZF_DEFAULT_COMMAND='fd --type file --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

