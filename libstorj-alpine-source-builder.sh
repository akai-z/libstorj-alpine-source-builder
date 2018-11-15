#!/bin/sh

set -euo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"
readonly BUILD_DEPS_PKG=".libstorj-build-deps"
readonly M4_DIR="build-aux/m4"
readonly BUILD_DEPS="
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
readonly RUN_DEPS="
  json-c
  libcurl
  libuv
  nettle
"

REPOSITORY="storj/libstorj"
VERSION="tags/v1.0.3"
BUILD_DEPS_INSTALL=0

install() {
  echo -e "\nInstalling..."

  build_deps_install
  source_dir_set
  download
  build
  installation_test

  echo -e "\nLibstorj has been successfully installed.\n"
}

clean() {
  source_dir_remove
  apk del "$BUILD_DEPS_PKG"
  exit 0
}

run_deps_install() {
  apk update
  apk add -u --no-cache $RUN_DEPS
  exit 0
}

build_deps_install() {
  if [ "$BUILD_DEPS_INSTALL" -eq 1 ]; then
    apk update
    apk add -u --no-cache --virtual "$BUILD_DEPS_PKG" $BUILD_DEPS
  else
    build_deps_check
  fi
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
  TMPDIR="/tmp/" ./test/tests
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

build_deps_check() {
  local dep

  for dep in $BUILD_DEPS
  do
    apk info -eq "$dep" \
      || error "$(printf "Package \"%s\" was not found." "$dep")"
  done
}

read_args() {
  local i

  for i in "$@"
  do
    case $i in
      clean)                 clean;;
      run_deps_install)      run_deps_install;;
      -build_deps_install)   BUILD_DEPS_INSTALL=1;;
      --repository=*)        REPOSITORY="${i#*=}";;
      --version=*)           VERSION="${i#*=}";;
      --help)                usage;;
    esac
  done
}

usage() {
  cat <<'Usage'

usage: libstorj-alpine-source-builder.sh [OPTIONS]

  clean
      Removes source files and build dependencies.
      (If used, the library source build function will be ignored.)

  -build_deps_install
      Enables dependencies installation before building the library.

  --repository
      Github repository name. (Optional)

  --version
      Library version. (Optional)

Usage

  exit 0
}

error() {
  echo -e >&2 "\n$1\n"
  exit 1
}

main() {
  read_args "$@"
  install
}

main "$@"
