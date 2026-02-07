#!/usr/bin/env bash
#
# Functional test: Encode with passphrase → decode with passphrase → verify
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_encryption_roundtrip() {
    require_cmds qrencode zbarimg openssl || return 0

    local input="$TEST_TMPDIR/secret.txt"
    local encode_dir="$TEST_TMPDIR/encoded_enc"
    local decode_dir="$TEST_TMPDIR/decoded_enc"
    local passphrase="mysecretpass123"

    echo "This is secret data" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -p "$passphrase" -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode with passphrase should succeed" $?

    "$QRAR" decode -p "$passphrase" -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode with passphrase should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "secret.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match" 0 $?
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
