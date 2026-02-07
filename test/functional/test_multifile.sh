#!/usr/bin/env bash
#
# Functional test: Encode directory with multiple files → decode → verify all
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_multifile_roundtrip() {
    require_cmds qrencode zbarimg || return 0

    local input_dir="$TEST_TMPDIR/multifiles"
    local encode_dir="$TEST_TMPDIR/encoded_multi"
    local decode_dir="$TEST_TMPDIR/decoded_multi"

    mkdir -p "$input_dir" "$encode_dir" "$decode_dir"

    # Create 3 files of different types
    echo "This is a text file" > "$input_dir/readme.txt"
    echo '{"key": "value"}' > "$input_dir/data.json"
    printf '#!/bin/bash\necho hello\n' > "$input_dir/script.sh"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input_dir" 2>/dev/null
    assertTrue "encode directory should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    # Verify all three files exist and match
    for fname in readme.txt data.json script.sh; do
        local decoded_file
        decoded_file=$(find_decoded "$decode_dir" "$fname")
        assertNotNull "$fname should exist" "$decoded_file"
        if [[ -n "$decoded_file" ]]; then
            diff -q "$input_dir/$fname" "$decoded_file" >/dev/null 2>&1
            assertEquals "$fname content should match" 0 $?
        fi
    done
}

# shellcheck disable=SC1090
source "$SHUNIT2"
