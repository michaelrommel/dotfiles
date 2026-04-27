#! /bin/bash
# shellcheck disable=SC2139

# global aliases and functions
alias sha="shasum -a 256"
alias ff="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

alias iftop='sudo LC_CTYPE=C iftop'
alias gll='git log --graph --pretty=oneline --abbrev-commit'
alias gst='git status'
alias gco='git commit'
alias lg='lazygit'
alias oc='opencode --port'
alias pis='OLLAMA_API_KEY=$(bw get password "ollama-api-key") pi -e ${HOME}/.config/pi/agent/git/github.com/mcollina/pi-ollama-web-search'

alias fd='fd -H'
alias rp='resticprofile'
alias grep='grep --colour=auto'

if [[ "${OSNAME}" == "Darwin" ]]; then
	LS='gls'
else
	LS='ls'
fi
if type l 2>/dev/null 1>&2; then
	unalias 'l'
fi
alias l="${LS} -lah --color --hyperlink=never"
alias ll="${LS} -lah --color --hyperlink=never"
alias lr="${LS} -lahtr --color --hyperlink=never"

if [[ "${OSNAME}" == "Darwin" ]]; then
	alias cat='gcat'
fi

logtail() {
	tail -f "$@" | bat --paging=never -l log
}

fcd() {
	NEWCWD=$(fd --type d --hidden --exclude .git --exclude node_modules --exclude .cache | fzf)
	# shellcheck disable=SC2181
	if [[ $? -eq 0 ]]; then
		cd "${NEWCWD}" || exit
	fi
}

dnotify() {
	local title=$1
	shift 1
	IFS=" "
	local body=$*
	if [[ -z "${TMUX}" ]]; then
		printf "\x1b]777;notify;%s;%s\x1b\\" "${title}" "${body}"
	else
		printf "\x1bPtmux;\x1b\x1b]777;notify;%s;%s\x1b\x1b\\" "${title}" "${body}"
	fi
}
if [[ "${OSNAME}" == "Linux" && "${OSRELEASE}" =~ "-microsoft-" ]]; then
	alias open="explorer.exe"
fi

# load company / work specific aliases
# shellcheck source=./.company_aliases.sh
[[ ! -s "${HOME}/.company_aliases.sh" ]] || \. "${HOME}/.company_aliases.sh"
