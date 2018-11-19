#!/bin/sh

set -euo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"
readonly BUILD_DEPS_PKG=".libstorj-build-deps"
readonly M4_DIR="build-aux/m4"
readonly LIB_TMP_FILES="/tmp/storj-*"
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

  [ "$BUILD_DEPS_INSTALL" -eq 1 ] && \
    build_deps_install || build_deps_check

  source_dir_set
  download
  build
  installation_test

  echo -e "\nLibstorj has been successfully installed.\n"
}

clean() {
  source_dir_remove
  lib_tmp_files_remove
  apk del "$BUILD_DEPS_PKG"

  exit 0
}

run_deps_install() {
  apk update
  apk add -u --no-cache $RUN_DEPS

  exit 0
}

deps_list() {
  local list="$1"

  echo "$list"
  exit 0
}

build_deps_install() {
  apk update
  apk add -u --no-cache --virtual "$BUILD_DEPS_PKG" $BUILD_DEPS
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
  rm -rf "$(pwd)/${SOURCE_DIR}"
}

lib_tmp_files_remove() {
  rm -rf $LIB_TMP_FILES
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
      build_deps_list)       deps_list "$BUILD_DEPS";;
      run_deps_list)         deps_list "$RUN_DEPS";;
      -build_deps_install)   BUILD_DEPS_INSTALL=1;;
      --repository=*)        REPOSITORY="${i#*=}";;
      --version=*)           VERSION="${i#*=}";;
      *)                     usage;;
    esac
  done
}

usage() {
  cat <<'Usage'

usage: libstorj-alpine-source-builder.sh [OPTIONS]

  clean
      Removes library source and temporary files, and "build" dependencies.
      (If used, the library source build function will be ignored.)

  run_deps_install
      Installs library "run" dependencies.
      (If used, the library source build function will be ignored.)

  build_deps_list
      Lists "build" dependencies.

  run_deps_list
      Lists "run" dependencies.

  -build_deps_install
      Enables "build" dependencies installation before building the library.

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
