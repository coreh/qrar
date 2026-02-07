#!/usr/bin/env bash
#
# Functional test: Encode → PNG files → decode → verify
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_roundtrip_small_file_png() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/small.txt"
    local encode_dir="$TEST_TMPDIR/encoded_small"
    local decode_dir="$TEST_TMPDIR/decoded_small"

    echo "Hello, world!" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode should succeed" $?

    # Find encoded PNG files
    local png_count
    png_count=$(find "$encode_dir" -name '*.png' | wc -l | tr -d ' ')
    assertTrue "should produce at least one PNG" "[ $png_count -ge 1 ]"

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "small.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match" 0 $?
    fi
}

test_roundtrip_larger_file_png() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/larger.txt"
    local encode_dir="$TEST_TMPDIR/encoded_larger"
    local decode_dir="$TEST_TMPDIR/decoded_larger"

    # Generate a file that spans multiple QR codes (~2KB of text)
    for i in $(seq 1 100); do
        echo "Line $i: This is test data for round-trip testing of qrar encoding and decoding."
    done > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode should succeed" $?

    # Should produce multiple PNGs
    local png_count
    png_count=$(find "$encode_dir" -name '*.png' | wc -l | tr -d ' ')
    assertTrue "should produce multiple PNGs" "[ $png_count -gt 1 ]"

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "larger.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match" 0 $?
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
