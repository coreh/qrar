#!/usr/bin/env bash
#
# Tests for get_chunk_limit()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_level_L_returns_300() {
    assertEquals 300 "$(get_chunk_limit L)"
}

test_level_M_returns_230() {
    assertEquals 230 "$(get_chunk_limit M)"
}

test_level_Q_returns_170() {
    assertEquals 170 "$(get_chunk_limit Q)"
}

test_level_H_returns_130() {
    assertEquals 130 "$(get_chunk_limit H)"
}

test_unknown_level_returns_default_230() {
    assertEquals 230 "$(get_chunk_limit X)"
}

test_empty_level_returns_default_230() {
    assertEquals 230 "$(get_chunk_limit "")"
}

test_lowercase_level_returns_default() {
    # The function only handles uppercase; lowercase falls through to default
    assertEquals 230 "$(get_chunk_limit l)"
    assertEquals 230 "$(get_chunk_limit m)"
    assertEquals 230 "$(get_chunk_limit q)"
    assertEquals 230 "$(get_chunk_limit h)"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
