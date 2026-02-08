#!/usr/bin/env bash
#
# Functional test: Pipe data via stdin → encode → decode → verify
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_stdin_text_pipe() {
    require_cmds qrencode zbarimg || return 0

    local encode_dir="$TEST_TMPDIR/encoded_stdin"
    local decode_dir="$TEST_TMPDIR/decoded_stdin"

    mkdir -p "$encode_dir" "$decode_dir"

    echo "hello from stdin" | "$QRAR" encode -o "$encode_dir/qr.png" 2>/dev/null
    assertTrue "encode from stdin should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "stdin")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        local content
        content=$(cat "$decoded_file")
        assertEquals "hello from stdin" "$content"
    fi
}

test_stdin_binary_pipe() {
    require_cmds qrencode zbarimg || return 0

    local encode_dir="$TEST_TMPDIR/encoded_stdin_bin"
    local decode_dir="$TEST_TMPDIR/decoded_stdin_bin"
    local original="$TEST_TMPDIR/original_bin"

    mkdir -p "$encode_dir" "$decode_dir"

    # Generate small binary data
    printf '\x00\x01\x02\x03\x04\x05\xff\xfe\xfd' > "$original"

    "$QRAR" encode -o "$encode_dir/qr.png" < "$original" 2>/dev/null
    assertTrue "encode binary from stdin should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "stdin")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$original" "$decoded_file" >/dev/null 2>&1
        assertEquals "binary content should match" 0 $?
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
