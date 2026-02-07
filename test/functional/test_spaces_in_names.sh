#!/usr/bin/env bash
#
# Functional test: Files and directories with spaces in names
#

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_file_with_spaces_in_name() {
    require_cmds qrencode zbarimg || return 0

    local input_dir="$TEST_TMPDIR/space_input"
    local encode_dir="$TEST_TMPDIR/encoded_spaces"
    local decode_dir="$TEST_TMPDIR/decoded_spaces"

    mkdir -p "$input_dir" "$encode_dir" "$decode_dir"
    echo "file with spaces test" > "$input_dir/my test file.txt"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input_dir/my test file.txt" 2>/dev/null
    assertTrue "encode file with spaces should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "my test file.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        local content
        content=$(cat "$decoded_file")
        assertEquals "file with spaces test" "$content"
    fi
}

test_directory_with_spaces() {
    require_cmds qrencode zbarimg || return 0

    local input_dir="$TEST_TMPDIR/my folder"
    local encode_dir="$TEST_TMPDIR/encoded_dir_spaces"
    local decode_dir="$TEST_TMPDIR/decoded_dir_spaces"

    mkdir -p "$input_dir" "$encode_dir" "$decode_dir"
    echo "inside spaced dir" > "$input_dir/readme.txt"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input_dir" 2>/dev/null
    assertTrue "encode directory with spaces should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "readme.txt")
    assertNotNull "decoded readme.txt should exist" "$decoded_file"
    if [[ -n "$decoded_file" ]]; then
        local content
        content=$(cat "$decoded_file")
        assertEquals "inside spaced dir" "$content"
    fi
}

test_output_dir_with_spaces() {
    require_cmds qrencode zbarimg || return 0

    local input="$TEST_TMPDIR/simple_for_spaces.txt"
    local encode_dir="$TEST_TMPDIR/encoded_simple_spaces"
    local decode_dir="$TEST_TMPDIR/my output dir"

    echo "output dir spaces test" > "$input"
    mkdir -p "$encode_dir" "$decode_dir"

    "$QRAR" encode -o "$encode_dir/qr.png" "$input" 2>/dev/null
    assertTrue "encode should succeed" $?

    "$QRAR" decode -f -o "$decode_dir" "$encode_dir"/*.png 2>/dev/null
    assertTrue "decode to dir with spaces should succeed" $?

    local decoded_file
    decoded_file=$(find_decoded "$decode_dir" "simple_for_spaces.txt")
    assertNotNull "decoded file should exist" "$decoded_file"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
