#!/usr/bin/env bats
# local-path.sh — local_path turns a file:// URL into the plain path.

setup() { . "$BATS_TEST_DIRNAME/local-path.sh"; }

@test "a plain path is printed unchanged" {
  [ "$(local_path story/01.txt)" = "story/01.txt" ]
  [ "$(local_path "/a/100% done/b.txt")" = "/a/100% done/b.txt" ]
}

@test "file:// is dropped, with or without a host" {
  [ "$(local_path file:///a/b.txt)" = "/a/b.txt" ]
  [ "$(local_path file://localhost/a/b.txt)" = "/a/b.txt" ]
}

@test "%XX is decoded, multibyte included, and a stray % is kept" {
  [ "$(local_path "file:///a/%E7%AC%AC%201%E7%AB%A0/b.txt")" = "/a/第 1章/b.txt" ]
  [ "$(local_path "file:///a/100%/b%zz.txt")" = "/a/100%/b%zz.txt" ]
}
