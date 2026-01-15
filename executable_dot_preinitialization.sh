#! /bin/bash

export DEBUG=false

source "${HOME}/.minimalrc"

GPG_TTY=$(tty)
export GPG_TTY
export EDITOR=vim
export VISUAL=vim
export MOSH_ESCAPE_KEY='~'

[[ -x "/usr/bin/uname" ]] && UNAME="/usr/bin/uname"
[[ -x "/bin/uname" ]] && UNAME="/bin/uname"

OSNAME=$("${UNAME}" -s)
OSRELEASE=$("${UNAME}" -r)
export OSNAME OSRELEASE

WEZTERM_HOSTNAME=$(hostname)
export WEZTERM_HOSTNAME

# LC_ALL would override all settings, do not set that
# LC_LANG is setting the default. It is set in /etc/default/locale
if [[ "${OSNAME}" != "Darwin" ]]; then
	export LC_COLLATE="C.UTF-8"
fi

if TMUX_VERS_BIN=$(tmux 2>/dev/null -V); then
	# get the correct tmux version, even if no server is running yet
	if TMUX_VERS_SERVER=$(tmux 2>/dev/null display-message -p "#{version}"); then
		# we got the server version, use this
		# shellcheck disable=SC2001
		TMUX_VERSION=$(echo "${TMUX_VERS_SERVER}" | sed -e 's/[^0-9.]*\([0-9.]*\)/\1/g')
	else
		# use the client version
		# shellcheck disable=SC2001
		TMUX_VERSION=$(echo "${TMUX_VERS_BIN}" | sed -e 's/[^0-9.]*\([0-9.]*\)/\1/g')
	fi
	export TMUX_VERSION
fi

# load authentication tokens
# shellcheck source=/home/rommel/.gh_credentials.sh
[[ -s "${HOME}/.gh_credentials.sh" ]] && source "${HOME}/.gh_credentials.sh"

# check for mintty to override TERM variable
# TERMINAL=$("${HOME}/bin/terminal.sh" -n)
# [[ "${TERMINAL}" == "mintty" ]] && export TERM=mintty
# [[ "${TERMINAL}" == "kitty" ]] && export TERM=kitty
# [[ "${TERMINAL}" == "linux" ]] && "${HOME}/bin/set_gruvbox_colors.sh"
# unset TERMINAL

# adjust gruvbos colors for 256 color terminals
# shellcheck source=/home/rommel/bin/set_gruvbox_colors.sh
[[ -s "${HOME}/bin/set_gruvbox_colors.sh" ]] && "${HOME}/bin/set_gruvbox_colors.sh"

# additional manual pages
export MANPATH="${HOME}/.local/share/man:${MANPATH}"
# color for less and man
export MANPAGER='less -r -s -M +Gg'
# shellcheck source=./bin/less_colors.sh
[[ -f "$HOME/bin/.less_colors.sh" ]] && source "$HOME/bin/less_colors".sh
# shellcheck source=./bin/dir_colors.sh
[[ -f "$HOME/bin/dir_colors.sh" ]] && source "$HOME/bin/dir_colors.sh"
# take over oh-my-zsh ls colors
# shellcheck source=./bin/ls_colors.sh
[[ -f "${HOME}/bin/ls_colors.sh" ]] && source "${HOME}/bin/ls_colors.sh"

echo -n " • mosh"
FATHER=$(ps -p $PPID -o comm=)
if [ "${FATHER}" = "mosh-server" ]; then
	echo -n " (true)"
	unset SSH_AUTH_SOCK
	unset SSH_CLIENT
	unset SSH_CONNECTION
	# leave TTY set, powerlevel10k uses it to determine context
	#unset SSH_TTY
	unset FATHER
fi

echo -n " • ssh-agent"
[[ ${DEBUG} == true ]] && echo -e -n "\nChecking for ssh keys"
ssh-add -l >/dev/null 2>&1
RC=$?
if [[ $RC == 1 || $RC == 2 ]]; then
	# there are no keys available or no agent running
	[[ ${DEBUG} == true ]] && echo " (none)"
	if [ "$(basename "${SHELL}")" = "zsh" ]; then
		# suppress error messages, when a glob pattern returns no matches
		setopt +o nomatch
	fi
	[[ ${DEBUG} == false ]] && FLAG="--quiet"
	KVER=$(keychain --nocolor --version 2>&1 | grep -E "\* keychain" | sed -E 's/.* ([0-9]+)\..*/\1/')
	if [[ ${KVER} -gt 2 ]]; then
		FLAG="${FLAG} --ssh-allow-forwarded"
	else
		FLAG="${FLAG}"
	fi
	if [[ "${OSNAME}" == "Darwin" ]]; then
		# on macOS: keychain has support to get the passphrase from the OS Keyring
		# before you can use the keychain, you must add it once to it
		# ssh-add --apple-use-keychain ~/.ssh/id_ecdsa
		# shellcheck disable=SC2086,SC2068
		eval "$(keychain ${FLAG} --eval)"
		ssh-add -q --apple-load-keychain ~/.ssh/id_ecdsa
	elif [[ "${OSNAME}" == "Linux" ]]; then
		if [[ "${OSRELEASE}" =~ "-microsoft-" ]]; then
			# we are on WSL2
			# There is obviously no AUTH_SOCK available. Now keychain has its own
			# way of remembering an previously started agent in its .keychain
			# directory. It will therefore only start a wsl-relay once per
			# session.
			# Unfortunately keychain does not understand that the Windows OpenSSH
			# Agent already provides the identities and always thinks, if it started
			# the agent, it should ask to add keys, so we have to branch here and
			# not ask for identies to add.
			# Agent needs to be named "ssh-agent" because keychain refuses
			# to start anything other than ssh-agent and gpg-agent. :-(
			[[ ${DEBUG} == true ]] && echo "Launching ssh-agent relay"
			unset IDENTITIES
		else
			# per default add identities on other Linux systems
			declare -a IDENTITIES=(id_ed25519 id_ecdsa id_rsa)
		fi
		# inherit identities or start new ssh-agent
		# shellcheck disable=SC2086,SC2068
		eval "$(keychain ${FLAG} --eval --ignore-missing \
			${IDENTITIES[@]})"
	else
		echo "Unknown Operating System: ${OSNAME}"
	fi
else
	[[ ${DEBUG} == true ]] && echo " (found)"
fi

umask 022
set -o vi

# reset initialization lines (formatting and clear line, cursor to 1st col
echo -n -e '\e[1G\e[2K\e[0m'

# show MOTD once per day
if [[ "${OSNAME}" == "Darwin" ]]; then
	LEAVEDATE=$(date -j -f "%Y-%m-%d %H:%M:%S" "2026-09-11 00:00:00" +%s)
	BEGINOFDAY=$(date -j -v0H -v0M -v0S +%s)
	NOW=$(date -j +%s)
else
	LEAVEDATE=$(date -d "2026-09-11" +"%s")
	BEGINOFDAYSTRING=$(date +"%Y-%m-%d 00:00:00")
	BEGINOFDAY=$(date -d "${BEGINOFDAYSTRING}" +"%s")
	NOW=$(date +"%s")
fi
[[ -f ${HOME}/.motd_shown ]] && MOTDSHOWN=$(<"${HOME}/.motd_shown")
MOTDSHOWN=${MOTDSHOWN:-0}
DIFF=$((NOW - MOTDSHOWN))
if [[ ${DIFF} -gt 86400 ]]; then
	# calculat
	echo "${BEGINOFDAY}" >"${HOME}/.motd_shown"
	# Count down the days of working for others
	WEEKSLEFT=$(((LEAVEDATE - NOW) / (7 * 24 * 3600)))
	echo -e "Weeks to work: \e[94m${WEEKSLEFT}\e[0m"
fi
