#!/usr/bin/env bash
#
# Tests for parse_chunk()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_parse_encrypted_gzip_chunk() {
    local input="QRAR:V1:EG:1/5:abcd1234:9876543:SGVsbG8gV29ybGQ="
    local result
    result=$(parse_chunk "$input")

    local session seq total checksum enc_flag comp_flag data
    IFS='|' read -r session seq total checksum enc_flag comp_flag data <<< "$result"

    assertEquals "session" "abcd1234" "$session"
    assertEquals "seq" "1" "$seq"
    assertEquals "total" "5" "$total"
    assertEquals "checksum" "9876543" "$checksum"
    assertEquals "enc_flag" "E" "$enc_flag"
    assertEquals "comp_flag" "G" "$comp_flag"
    assertEquals "data" "SGVsbG8gV29ybGQ=" "$data"
}

test_parse_plain_xz_chunk() {
    local input="QRAR:V1:PX:3/10:beef0000:1234567:YmFzZTY0ZGF0YQ=="
    local result
    result=$(parse_chunk "$input")

    local session seq total checksum enc_flag comp_flag data
    IFS='|' read -r session seq total checksum enc_flag comp_flag data <<< "$result"

    assertEquals "session" "beef0000" "$session"
    assertEquals "seq" "3" "$seq"
    assertEquals "total" "10" "$total"
    assertEquals "checksum" "1234567" "$checksum"
    assertEquals "enc_flag" "P" "$enc_flag"
    assertEquals "comp_flag" "X" "$comp_flag"
    assertEquals "data" "YmFzZTY0ZGF0YQ==" "$data"
}

test_parse_plain_none_chunk() {
    local input="QRAR:V1:PN:1/1:aabb0011:5555555:dGVzdA=="
    local result
    result=$(parse_chunk "$input")

    local session seq total checksum enc_flag comp_flag data
    IFS='|' read -r session seq total checksum enc_flag comp_flag data <<< "$result"

    assertEquals "enc_flag" "P" "$enc_flag"
    assertEquals "comp_flag" "N" "$comp_flag"
    assertEquals "data" "dGVzdA==" "$data"
}

test_parse_multi_digit_seq_total() {
    local input="QRAR:V1:PG:99/100:deadbeef:7777777:abc123"
    local result
    result=$(parse_chunk "$input")

    local session seq total checksum enc_flag comp_flag data
    IFS='|' read -r session seq total checksum enc_flag comp_flag data <<< "$result"

    assertEquals "seq" "99" "$seq"
    assertEquals "total" "100" "$total"
}

test_parse_data_with_special_chars() {
    # base64 data can contain +, /, and =
    local input="QRAR:V1:PG:1/1:abcd0000:1111111:abc+def/ghi=="
    local result
    result=$(parse_chunk "$input")

    local session seq total checksum enc_flag comp_flag data
    IFS='|' read -r session seq total checksum enc_flag comp_flag data <<< "$result"

    assertEquals "data" "abc+def/ghi==" "$data"
}

test_parse_returns_seven_fields() {
    local input="QRAR:V1:EG:2/3:11223344:9999999:AAAA"
    local result
    result=$(parse_chunk "$input")

    # Count pipe-separated fields
    local field_count
    field_count=$(echo "$result" | awk -F'|' '{print NF}')
    assertEquals "field count" "7" "$field_count"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
