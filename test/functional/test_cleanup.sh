#!/usr/bin/env bash
#
# Functional test: Verify qrar cleans up temp files after encode/decode
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

_count_tmp_dirs() {
    find "${TMPDIR:-/tmp}" -maxdepth 1 -name 'tmp.*' -type d 2>/dev/null | wc -l | tr -d ' '
}

test_encode_cleans_up_temp_files() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/cleanup_enc.txt"
    local encode_dir="$TEST_TMPDIR/encoded_cleanup"
    echo "cleanup test" > "$input"
    mkdir -p "$encode_dir"

    local before after
    before=$(_count_tmp_dirs)

    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode should succeed" $?

    after=$(_count_tmp_dirs)
    assertEquals "no new temp dirs should remain after encode" "$before" "$after"
}

test_decode_cleans_up_temp_files() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/cleanup_dec.txt"
    local encode_dir="$TEST_TMPDIR/encoded_cleanup2"
    local decode_dir="$TEST_TMPDIR/decoded_cleanup2"
    echo "cleanup decode test" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null

    local before after
    before=$(_count_tmp_dirs)

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    after=$(_count_tmp_dirs)
    assertEquals "no new temp dirs should remain after decode" "$before" "$after"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
