#!/bin/bash
set -ex

GIT_BRANCH=$1

PROJECT=libdnf
XGETTEXT_PARAMS=(-F --from-code=UTF-8 --keyword=_ --keyword=M_ --keyword=P_:1,2 --keyword=MP_:1,2 --keyword=C_:1c,2 --keyword=MC_:1c,2 --keyword=CP_:1c,2,3 --keyword=MCP_:1c,2,3 -c)
FIND_PARAMS=(. -iname "*.[ch]" -o -iname "*.[ch]pp")


PROG_PATH=$(dirname $(readlink -f -- $0))
GIT_SOURCE_REPO="git@github.com:rpm-software-management/${PROJECT}.git"
POT_FILE="${PROJECT}.pot"

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

TMP_DIR=$(mktemp -d --tmpdir=$PROG_PATH tmp.${PROJECT}.XXXXXXXX)
if [[ ! -e "$TMP_DIR" ]]; then
    error "Could not create temp dir."
fi

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

pushd "$PROG_PATH"
    git clone --depth=1 -b ${GIT_BRANCH} ${GIT_SOURCE_REPO} ${TMP_DIR}
    pushd "${TMP_DIR}"
        find ${FIND_PARAMS[@]} | xargs xgettext ${XGETTEXT_PARAMS[@]} --output="${POT_FILE}"
    popd
    cp "${TMP_DIR}/${POT_FILE}" ../${GIT_BRANCH}
popd
