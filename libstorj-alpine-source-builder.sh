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

build() {
  ./autogen.sh
  ./configure
  make
  make install
}

source_dir_set() {
  dir_create "$SOURCE_DIR"
  cd "$SOURCE_DIR"
}

m4_dir_create() {
  dir_create "$M4_DIR"
}

dir_create() {
  local path="$1"

  if [ ! -d "$path" ]; then
    mkdir -p "$path"
  fi
}
