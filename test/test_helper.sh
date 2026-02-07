#!/usr/bin/env bash
#
# Shared test helper for qrar tests.
# Sources qrar (making all functions available) and provides
# common setup/teardown and tool-checking helpers.
#

# Resolve paths
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$TEST_DIR/.." && pwd)"
QRAR="$PROJECT_DIR/qrar"
SHUNIT2="$TEST_DIR/lib/shunit2"

# Source the qrar script (source guard prevents main from running)
# shellcheck disable=SC1090
source "$QRAR"

# Temp directory for test artifacts
TEST_TMPDIR=""

oneTimeSetUp() {
    TEST_TMPDIR=$(mktemp -d "${TMPDIR:-/tmp}/qrar-test.XXXXXX")
}

oneTimeTearDown() {
    if [[ -n "$TEST_TMPDIR" && -d "$TEST_TMPDIR" ]]; then
        rm -rf "$TEST_TMPDIR"
    fi
}

# Check if a command is available; call startSkipping if not.
# Usage: require_cmd qrencode || return 0
require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        startSkipping
        return 1
    fi
    return 0
}

# Check multiple commands at once
# Usage: require_cmds qrencode zbarimg || return 0
require_cmds() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            startSkipping
            return 1
        fi
    done
    return 0
}

# Find a decoded file by name inside a decode directory.
# tar preserves the full path, so the file may be nested deep.
# Usage: find_decoded <decode_dir> <filename>
find_decoded() {
    local decode_dir="$1"
    local filename="$2"
    find "$decode_dir" -name "$filename" -type f 2>/dev/null | head -1
}
