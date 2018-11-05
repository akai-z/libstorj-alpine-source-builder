#!/bin/sh

set -Eeuo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"

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
