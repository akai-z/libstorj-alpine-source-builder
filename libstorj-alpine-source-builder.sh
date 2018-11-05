#!/bin/sh

set -Eeuo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"
readonly M4_DIR="build-aux/m4"

REPOSITORY="storj/libstorj"

deps_install() {
  apk update
  apk add -u --no-cache --virtual .build-deps \
    autoconf \
    automake \
    curl \
    curl-dev \
    g++ \
    json-c-dev \
    libmicrohttpd-dev \
    libtool \
    libuv-dev \
    make \
    nettle-dev
}

source_dir_set() {
  source_dir_create
  cd "$SOURCE_DIR"
}

source_dir_create() {
  if [ ! -d "$SOURCE_DIR" ]; then
    mkdir "$SOURCE_DIR"
  fi
}

m4_dir_create() {
  if [ ! -d "$M4_DIR" ]; then
    mkdir -p "$M4_DIR"
  fi
}

dir_create() {
  local path="$1"

  if [ ! -d "$path" ]; then
    mkdir -p "$path"
  fi
}
