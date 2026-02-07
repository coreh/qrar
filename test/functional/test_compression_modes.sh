#!/usr/bin/env bash
#
# Functional test: Round-trips with different compression modes
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

_roundtrip_with_compression() {
    local comp="$1"
    local input="$TEST_TMPDIR/comp_${comp}.txt"
    local encode_dir="$TEST_TMPDIR/encoded_${comp}"
    local decode_dir="$TEST_TMPDIR/decoded_${comp}"

    echo "Compression test with mode: $comp" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -c "$comp" -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode with -c $comp should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode with -c $comp should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "comp_${comp}.txt")
    assertNotNull "decoded file should exist ($comp)" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match ($comp)" 0 $?
    fi
}

test_compression_gz() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_compression "gz"
}

test_compression_xz() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_compression "xz"
}

test_compression_none() {
    require_cmds qrencode zbarimg || return 0
    _roundtrip_with_compression "none"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
