#!/usr/bin/env bash
#
# Functional test: Encode → MP4 → decode → verify
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_roundtrip_mp4() {
    require_cmds qrencode zbarimg ffmpeg || return 0

    local input="$TEST_TMPDIR/video_test.txt"
    local mp4_file="$TEST_TMPDIR/output.mp4"
    local decode_dir="$TEST_TMPDIR/decoded_video"

    echo "MP4 round-trip test data" > "$input"
    mkdir -p "$decode_dir"

    "$QRAR" encode -V -o "$mp4_file" "$input" 2>/dev/null
    assertTrue "encode to MP4 should succeed" $?
    assertTrue "MP4 file should exist" "[ -f '$mp4_file' ]"

    "$QRAR" decode -f -o "$decode_dir" "$mp4_file" 2>/dev/null
    assertTrue "decode from MP4 should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "video_test.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        diff -q "$input" "$decoded_file" >/dev/null 2>&1
        assertEquals "content should match" 0 $?
    fi
}

# shellcheck disable=SC1090
source "$SHUNIT2"
