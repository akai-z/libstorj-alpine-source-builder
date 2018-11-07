#!/bin/sh

set -Eeuo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"
readonly M4_DIR="build-aux/m4"

REPOSITORY="storj/libstorj"

clean() {
  cd ..
  rm -rf "$SOURCE_DIR"
  apk del .build-deps
}

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

download() {
  curl "$SOURCE_URL" \
    | grep "tarball_url" \
    | cut -d '"' -f 4 \
    | xargs curl -L \
    | tar -zx --strip 1
}

build() {
  dir_create "$M4_DIR"
  ./autogen.sh
  ./configure
  make
  make install
}

test() {
  ./test/tests
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
