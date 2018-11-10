#!/bin/sh

set -Eeuo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"
readonly M4_DIR="build-aux/m4"
readonly REQUIRED_DEPS="
  autoconf
  automake
  curl
  curl-dev
  g++
  json-c-dev
  libmicrohttpd-dev
  libtool
  libuv-dev
  make
  nettle-dev
"

REPOSITORY="storj/libstorj"
VERSION=""

install() {
  echo -e "\nInstalling..."

  deps_install
  download
  source_dir_set
  build
  installation_test

  echo -e "\nLibstorj has been successfully installed.\n"
}

clean() {
  source_dir_remove
  apk del .build-deps
}

deps_install() {
  apk update
  apk add -u --no-cache --virtual .build-deps $REQUIRED_DEPS
}

download() {
  curl "$(source_url)" \
    | grep "tarball_url" \
    | cut -d '"' -f 4 \
    | xargs curl -L \
    | tar -zx --strip 1
}

source_url() {
  echo "$(printf "$SOURCE_URL" "$REPOSITORY" "$VERSION")"
}

build() {
  dir_create "$M4_DIR"
  ./autogen.sh
  ./configure
  make
  make install
}

installation_test() {
  ./test/tests
}

source_dir_set() {
  dir_create "$SOURCE_DIR"
  cd "$SOURCE_DIR"
}

dir_create() {
  local path="$1"

  if [ ! -d "$path" ]; then
    mkdir -p "$path"
  fi
}

source_dir_remove() {
  local path="$(pwd)/${SOURCE_DIR}"

  if [ -d "$path" ]; then
    rm -rf "$path"
  fi
}

deps_check() {
  local dep

  for dep in $REQUIRED_DEPS
  do
    apk info -eq "$dep" \
      || error "$(printf "Package \"%s\" was not found." "$dep")"
  done
}

error() {
  echo -e >&2 "\n$1\n"
  exit 1
}
