#! /bin/bash

# This script shall mimick the standard ssh-agent behaviour as closely
# as possible
#
# SSH_AUTH_SOCK=/tmp/ssh-lem86N2yUsYX/agent.31993; export SSH_AUTH_SOCK;
# SSH_AGENT_PID=31994; export SSH_AGENT_PID;
# echo Agent pid 31994;

# create a ssh directory for storing the socket
mkdir -p "/tmp/ssh-$$"
export SSH_AUTH_SOCK=/tmp/ssh-$$/agent.$$
rm -f $SSH_AUTH_SOCK

# note that you have to redirect the standard output of 
# the spawned command, otherwise calling this script in a subshell
# will hang the calling process
setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,umask=007,fork \
    EXEC:"/mnt/c/ProgramFiles/npiperelay/npiperelay.exe -ei -s \
    -v //./pipe/openssh-ssh-agent",nofork >/dev/null 2>&1 &
SSH_AGENT_PID=$!

echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}; export SSH_AUTH_SOCK;"
echo "SSH_AGENT_PID=${SSH_AGENT_PID}; export SSH_AGENT_PID;"
echo "echo Agent pid ${SSH_AGENT_PID};"

