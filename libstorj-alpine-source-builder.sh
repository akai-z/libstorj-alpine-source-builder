#!/bin/sh

set -Eeuo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj"

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
