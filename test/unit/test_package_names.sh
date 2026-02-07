#!/usr/bin/env bash
#
# Tests for pkg_name_for_pm(), get_install_commands(), build_uninstall_cmd()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

# --- pkg_name_for_pm tests ---

test_pkg_name_brew_passthrough() {
    assertEquals "qrencode" "$(pkg_name_for_pm brew qrencode)"
    assertEquals "zbar" "$(pkg_name_for_pm brew zbar)"
    assertEquals "imagemagick" "$(pkg_name_for_pm brew imagemagick)"
}

test_pkg_name_apt_maps_zbar() {
    assertEquals "zbar-tools" "$(pkg_name_for_pm apt zbar)"
}

test_pkg_name_apt_passthrough_others() {
    assertEquals "qrencode" "$(pkg_name_for_pm apt qrencode)"
}

test_pkg_name_apk_maps_qrencode() {
    assertEquals "libqrencode-tools" "$(pkg_name_for_pm apk qrencode)"
}

test_pkg_name_dnf_maps_imagemagick() {
    assertEquals "ImageMagick" "$(pkg_name_for_pm dnf imagemagick)"
}

test_pkg_name_yum_maps_imagemagick() {
    assertEquals "ImageMagick" "$(pkg_name_for_pm yum imagemagick)"
}

test_pkg_name_zypper_maps_imagemagick() {
    assertEquals "ImageMagick" "$(pkg_name_for_pm zypper imagemagick)"
}

test_pkg_name_pacman_passthrough() {
    assertEquals "qrencode" "$(pkg_name_for_pm pacman qrencode)"
    assertEquals "imagemagick" "$(pkg_name_for_pm pacman imagemagick)"
}

test_pkg_name_pkg_maps_qrencode() {
    assertEquals "libqrencode" "$(pkg_name_for_pm pkg qrencode)"
}

test_pkg_name_pkg_maps_imagemagick() {
    assertEquals "ImageMagick7" "$(pkg_name_for_pm pkg imagemagick)"
}

test_pkg_name_pkg_maps_ghostscript() {
    assertEquals "ghostscript10" "$(pkg_name_for_pm pkg ghostscript)"
}

# --- get_install_commands tests ---

test_get_install_commands_brew_non_empty() {
    local result
    result=$(get_install_commands brew)
    assertNotNull "brew install commands should not be empty" "$result"
}

test_get_install_commands_apt_non_empty() {
    local result
    result=$(get_install_commands apt)
    assertNotNull "apt install commands should not be empty" "$result"
}

test_get_install_commands_dnf_non_empty() {
    local result
    result=$(get_install_commands dnf)
    assertNotNull "dnf install commands should not be empty" "$result"
}

test_get_install_commands_pacman_non_empty() {
    local result
    result=$(get_install_commands pacman)
    assertNotNull "pacman install commands should not be empty" "$result"
}

test_get_install_commands_apk_non_empty() {
    local result
    result=$(get_install_commands apk)
    assertNotNull "apk install commands should not be empty" "$result"
}

test_get_install_commands_zypper_non_empty() {
    local result
    result=$(get_install_commands zypper)
    assertNotNull "zypper install commands should not be empty" "$result"
}

test_get_install_commands_pkg_non_empty() {
    local result
    result=$(get_install_commands pkg)
    assertNotNull "pkg install commands should not be empty" "$result"
}

test_get_install_commands_unknown_pm_returns_pipe() {
    local result
    result=$(get_install_commands unknown_pm)
    assertEquals "|" "$result"
}

# --- build_uninstall_cmd tests ---

test_build_uninstall_cmd_brew() {
    local result
    result=$(build_uninstall_cmd brew mypkg)
    assertEquals "brew uninstall mypkg" "$result"
}

test_build_uninstall_cmd_apt() {
    local result
    result=$(build_uninstall_cmd apt mypkg)
    assertEquals "sudo apt remove -y mypkg" "$result"
}

test_build_uninstall_cmd_dnf() {
    local result
    result=$(build_uninstall_cmd dnf mypkg)
    assertEquals "sudo dnf remove -y mypkg" "$result"
}

test_build_uninstall_cmd_yum() {
    local result
    result=$(build_uninstall_cmd yum mypkg)
    assertEquals "sudo yum remove -y mypkg" "$result"
}

test_build_uninstall_cmd_pacman() {
    local result
    result=$(build_uninstall_cmd pacman mypkg)
    assertEquals "sudo pacman -R --noconfirm mypkg" "$result"
}

test_build_uninstall_cmd_apk() {
    local result
    result=$(build_uninstall_cmd apk mypkg)
    assertEquals "sudo apk del mypkg" "$result"
}

test_build_uninstall_cmd_zypper() {
    local result
    result=$(build_uninstall_cmd zypper mypkg)
    assertEquals "sudo zypper remove -y mypkg" "$result"
}

test_build_uninstall_cmd_pkg() {
    local result
    result=$(build_uninstall_cmd pkg mypkg)
    assertEquals "sudo pkg delete -y mypkg" "$result"
}

# shellcheck disable=SC1090
source "$SHUNIT2"
