#!/usr/bin/env bash
#
# Functional test: Round-trips with different error correction levels
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

_roundtrip_with_level() {
    local level="$1"
    local input="$TEST_TMPDIR/ec_${level}.txt"
    local encode_dir="$TEST_TMPDIR/encoded_${level}"
    local decode_dir="$TEST_TMPDIR/decoded_${level}"

    echo "Error correction level $level test" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -l "$level" -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode with -l $level should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode with -l $level should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "ec_${level}.txt")
    assertNotNull "decoded file should exist ($level)" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match ($level)" 0 $?
    fi
}

test_error_correction_L() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_level "L"
}

test_error_correction_M() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_level "M"
}

test_error_correction_Q() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_level "Q"
}

test_error_correction_H() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_level "H"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
