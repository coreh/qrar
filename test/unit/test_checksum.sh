#!/usr/bin/env bash
#
# Tests for calc_checksum()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_known_input_produces_consistent_checksum() {
    local checksum1 checksum2
    checksum1=$(echo "hello world" | calc_checksum)
    checksum2=$(echo "hello world" | calc_checksum)
    assertEquals "$checksum1" "$checksum2"
}

test_different_inputs_produce_different_checksums() {
    local checksum1 checksum2
    checksum1=$(echo "hello" | calc_checksum)
    checksum2=$(echo "world" | calc_checksum)
    assertNotEquals "$checksum1" "$checksum2"
}

test_empty_input_produces_valid_checksum() {
    local checksum
    checksum=$(echo -n "" | calc_checksum)
    assertNotNull "checksum should not be empty" "$checksum"
    # Should be a numeric value
    assertTrue "checksum should be numeric" "echo '$checksum' | grep -qE '^[0-9]+$'"
}

test_binary_data_produces_valid_checksum() {
    local checksum
    checksum=$(printf '\x00\x01\x02\xff\xfe\xfd' | calc_checksum)
    assertNotNull "checksum should not be empty" "$checksum"
    assertTrue "checksum should be numeric" "echo '$checksum' | grep -qE '^[0-9]+$'"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
