#!/usr/bin/env bash
#
# Tests for detect_os() and detect_package_manager()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

test_detect_os_returns_non_empty() {
    local os
    os=$(detect_os)
    assertNotNull "os should not be empty" "$os"
}

test_detect_os_returns_macos_on_darwin() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        startSkipping
        return 0
    fi
    local os
    os=$(detect_os)
    assertEquals "macos" "$os"
}

test_detect_package_manager_returns_value_for_current_os() {
    local os pm
    os=$(detect_os)
    pm=$(detect_package_manager "$os")
    assertNotNull "pm should not be empty" "$pm"
}

test_detect_package_manager_returns_brew_on_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        startSkipping
        return 0
    fi
    if ! command -v brew &>/dev/null; then
        startSkipping
        return 0
    fi
    local pm
    pm=$(detect_package_manager "macos")
    assertEquals "brew" "$pm"
}

test_detect_package_manager_known_os_mappings() {
    assertEquals "apt" "$(detect_package_manager "debian")"
    assertEquals "pacman" "$(detect_package_manager "arch")"
    assertEquals "apk" "$(detect_package_manager "alpine")"
    assertEquals "zypper" "$(detect_package_manager "opensuse")"
    assertEquals "pkg" "$(detect_package_manager "freebsd")"
}

test_detect_package_manager_unknown_os_returns_none() {
    assertEquals "none" "$(detect_package_manager "unknown")"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
