#!/usr/bin/env bash
#
# Tests for generate_session_id()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_session_id_is_8_characters() {
    local id
    id=$(generate_session_id)
    assertEquals "length" 8 "${#id}"
}

test_session_id_is_valid_hex() {
    local id
    id=$(generate_session_id)
    assertTrue "should be hex: $id" "echo '$id' | grep -qE '^[0-9a-f]{8}$'"
}

test_two_session_ids_differ() {
    local id1 id2
    id1=$(generate_session_id)
    id2=$(generate_session_id)
    assertNotEquals "$id1" "$id2"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
