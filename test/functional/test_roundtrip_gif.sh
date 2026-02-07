#!/usr/bin/env bash
#
# Functional test: Encode → GIF → decode → verify
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_roundtrip_gif() {
    require_cmds qrencode zbarimg ffmpeg || return 0

    local input="$TEST_TMPDIR/gif_test.txt"
    local gif_file="$TEST_TMPDIR/output.gif"
    local decode_dir="$TEST_TMPDIR/decoded_gif"

    echo "GIF round-trip test data" > "$input"
    mkdir -p "$decode_dir"

    "$QRAR" encode -G -o "$gif_file" "$input" 2>/dev/null
    assertTrue "encode to GIF should succeed" $?
    assertTrue "GIF file should exist" "[ -f '$gif_file' ]"

    "$QRAR" decode -f -o "$decode_dir" "$gif_file" 2>/dev/null
    assertTrue "decode from GIF should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "gif_test.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match" 0 $?
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
