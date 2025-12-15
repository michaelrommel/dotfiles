#! /bin/bash

NVAN=miro
cd "${HOME}" || exit
rm -rf ".cache/${NVAN}"
rm -rf ".config/${NVAN}"
rm -rf ".local/share/${NVAN}"
rm -rf ".local/state/${NVAN}"
