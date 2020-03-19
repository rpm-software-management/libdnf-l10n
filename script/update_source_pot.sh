#!/bin/bash
set -e

PROG_PATH=$(dirname $(readlink -f -- $0))

XGETTEXT_PARAMS=(-F --from-code=UTF-8 --keyword=_ --keyword=M_ --keyword=P_:1,2 --keyword=MP_:1,2 --keyword=C_:1c,2 --keyword=MC_:1c,2 --keyword=CP_:1c,2,3 --keyword=MCP_:1c,2,3 -c)
FIND_PARAMS=(. -iname "*.[ch]" -o -iname "*.[ch]pp")
GIT_SOURCE_REPO="git@github.com:rpm-software-management/libdnf.git"
POT_FILE="libdnf.pot"

error() {
    printf >&2 "Error: %s\n" "$*"
    exit 1
}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

TMP_DIR=$(mktemp -d --tmpdir=$PROG_PATH tmp.libdnf.l10n.XXXXXXXX)
if [[ ! -e "$TMP_DIR" ]]; then
    error "Could not create temp dir."
fi

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

pushd "$PROG_PATH"
    GIT_BRANCH=$(git symbolic-ref --short -q HEAD)
    if [[ ! "$GIT_BRANCH" ]]; then
        error "Could not detect git branch."
    fi
    git clone --depth=1 -b ${GIT_BRANCH} ${GIT_SOURCE_REPO} ${TMP_DIR}
    pushd "${TMP_DIR}"
        find ${FIND_PARAMS[@]} | xargs xgettext ${XGETTEXT_PARAMS[@]} --output="${POT_FILE}"
    popd
    cp "${TMP_DIR}/${POT_FILE}" ..
popd
