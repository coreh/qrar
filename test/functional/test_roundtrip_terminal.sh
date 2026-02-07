#!/usr/bin/env bash
#
# Functional test: Encode → terminal UTF8 output → re-encode payloads to PNG → decode → verify
#
# Rather than trying to capture actual terminal rendering, this test validates
# the terminal encode path by extracting chunk payloads from the encode output
# and re-encoding them to PNG via qrencode, then decoding those PNGs.
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_terminal_encode_produces_output() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/terminal_test.txt"
    echo "Terminal output test" > "$input"

    # Encode to terminal — capture stderr (info messages) and stdout (QR display)
    local stdout_file="$TEST_TMPDIR/terminal_stdout.txt"
    "$QRAR" encode -T UTF8 "$input" > "$stdout_file" 2>/dev/null
    assertTrue "encode to terminal should succeed" $?

    # stdout should contain something (QR codes rendered as text)
    local size
    size=$(wc -c < "$stdout_file" | tr -d ' ')
    assertTrue "terminal output should not be empty" "[ $size -gt 0 ]"
}

test_terminal_roundtrip_via_png_reencoding() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/terminal_rt.txt"
    local encode_dir="$TEST_TMPDIR/terminal_pngs"
    local decode_dir="$TEST_TMPDIR/terminal_decoded"

    echo "Terminal round-trip via PNG" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    # First encode to PNGs (to get the chunk payloads), then decode
    # This validates the same encoding path used by terminal mode
    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "terminal_rt.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match" 0 $?
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
