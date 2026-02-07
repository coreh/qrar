#!/usr/bin/env bash
#
# Tests for is_video_file() and is_pdf_file()
#

# Load test helper
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$TEST_DIR/test_helper.sh"

# --- is_video_file tests ---

test_is_video_file_recognizes_mp4() {
    is_video_file "video.mp4"
    assertEquals 0 $?
}

test_is_video_file_recognizes_mov() {
    is_video_file "video.mov"
    assertEquals 0 $?
}

test_is_video_file_recognizes_avi() {
    is_video_file "video.avi"
    assertEquals 0 $?
}

test_is_video_file_recognizes_mkv() {
    is_video_file "video.mkv"
    assertEquals 0 $?
}

test_is_video_file_recognizes_webm() {
    is_video_file "video.webm"
    assertEquals 0 $?
}

test_is_video_file_recognizes_m4v() {
    is_video_file "video.m4v"
    assertEquals 0 $?
}

test_is_video_file_recognizes_flv() {
    is_video_file "video.flv"
    assertEquals 0 $?
}

test_is_video_file_recognizes_wmv() {
    is_video_file "video.wmv"
    assertEquals 0 $?
}

test_is_video_file_recognizes_3gp() {
    is_video_file "video.3gp"
    assertEquals 0 $?
}

test_is_video_file_recognizes_gif() {
    is_video_file "animation.gif"
    assertEquals 0 $?
}

test_is_video_file_rejects_png() {
    is_video_file "image.png"
    assertNotEquals 0 $?
}

test_is_video_file_rejects_jpg() {
    is_video_file "photo.jpg"
    assertNotEquals 0 $?
}

test_is_video_file_rejects_pdf() {
    is_video_file "document.pdf"
    assertNotEquals 0 $?
}

test_is_video_file_rejects_tar() {
    is_video_file "archive.tar"
    assertNotEquals 0 $?
}

test_is_video_file_rejects_txt() {
    is_video_file "readme.txt"
    assertNotEquals 0 $?
}

test_is_video_file_with_path() {
    is_video_file "/path/to/some/video.mp4"
    assertEquals 0 $?
}

test_is_video_file_uppercase_extension() {
    is_video_file "video.MP4"
    assertEquals 0 $?
}

test_is_video_file_mixed_case_extension() {
    is_video_file "video.Mp4"
    assertEquals 0 $?
}

# --- is_pdf_file tests ---

test_is_pdf_file_recognizes_pdf() {
    is_pdf_file "document.pdf"
    assertEquals 0 $?
}

test_is_pdf_file_rejects_png() {
    is_pdf_file "image.png"
    assertNotEquals 0 $?
}

test_is_pdf_file_rejects_mp4() {
    is_pdf_file "video.mp4"
    assertNotEquals 0 $?
}

test_is_pdf_file_rejects_txt() {
    is_pdf_file "readme.txt"
    assertNotEquals 0 $?
}

test_is_pdf_file_with_path() {
    is_pdf_file "/some/path/document.pdf"
    assertEquals 0 $?
}

test_is_pdf_file_uppercase_extension() {
    is_pdf_file "document.PDF"
    assertEquals 0 $?
}

test_is_pdf_file_mixed_case_extension() {
    is_pdf_file "document.Pdf"
    assertEquals 0 $?
}

# shellcheck disable=SC1090
source "$SHUNIT2"
