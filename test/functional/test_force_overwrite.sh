#!/usr/bin/env bash
#
# Functional test: Decode with -f to existing directory
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_force_overwrite() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/overwrite.txt"
    local encode_dir="$TEST_TMPDIR/encoded_overwrite"
    local decode_dir="$TEST_TMPDIR/decoded_overwrite"

    echo "first version" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    # Encode and decode the first version
    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "first encode should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "first decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "overwrite.txt")
    assertNotNull "decoded file should exist after first decode" "$decoded_file"

    # Now encode a second version
    echo "second version" > "$input"
    rm -f "$encode_dir"/*.png
    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "second encode should succeed" $?

    # Decode with -f to the same directory (should not prompt)
    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "second decode with -f should succeed" $?

    # Re-find the file (path is the same)
    decoded_file=$(find_decoded "$decode_dir" "overwrite.txt")
    assertNotNull "decoded file should exist after second decode" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        local content
        content=$(cat "$decoded_file")
        assertEquals "second version" "$content"
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
