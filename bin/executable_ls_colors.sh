#! /bin/bash

function test-ls-args {
	local cmd="$1" # ls, gls, colorls, ...
	shift
	local args="${*}"
	command "$cmd" "$args" /dev/null &>/dev/null
}

# Find the option for using colors in ls, depending on the version
case "$OSTYPE" in
netbsd*)
	# On NetBSD, test if `gls` (GNU ls) is installed (this one supports colors);
	# otherwise, leave ls as is, because NetBSD's ls doesn't support -G
	test-ls-args gls --color && alias ls='gls --color=tty'
	;;
openbsd*)
	# On OpenBSD, `gls` (ls from GNU coreutils) and `colorls` (ls from base,
	# with color and multibyte support) are available from ports.
	# `colorls` will be installed on purpose and can't be pulled in by installing
	# coreutils (which might be installed for ), so prefer it to `gls`.
	test-ls-args gls --color && alias ls='gls --color=tty'
	test-ls-args colorls -G && alias ls='colorls -G'
	;;
darwin* | freebsd*)
	# This alias works by default just using $LSCOLORS
	test-ls-args ls -G && alias ls='ls -G'
	# test for gnu ls
	test-ls-args gls --color && alias ls='gls --color=tty'
	;;
*)
	if test-ls-args ls --color; then
		alias ls='ls --color=tty'
	elif test-ls-args ls -G; then
		alias ls='ls -G'
	fi
	;;
esac

unset -f test-ls-args
