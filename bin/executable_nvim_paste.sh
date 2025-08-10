#! /bin/bash

# Check for win32yank.exe executable
if command -v /mnt/c/ProgramFiles/Win32Yank/win32yank.exe >/dev/null 2>/dev/null; then
	# The --lf option pastes data unix style. Which is what I almost always want.
	/mnt/c/ProgramFiles/Win32Yank/win32yank.exe -o --lf
else
	# Else rely on PowerShell being installed and available.
	#powershell.exe Get-Clipboard | tr -d '\r' | sed -z '$ s/\n$//'
	# shellcheck disable=SC2016
	powershell.exe -c '[Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'
fi
