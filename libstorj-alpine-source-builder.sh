#!/bin/sh

set -euo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj-source"
readonly DEPS_PACKAGE=".libstorj-build-deps"
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
VERSION="tags/v1.0.3"
DEPS_INSTALL=0

install() {
  echo -e "\nInstalling..."

  deps_install
  source_dir_set
  download
  build
  installation_test

  echo -e "\nLibstorj has been successfully installed.\n"
}

clean() {
  source_dir_remove
  apk del "$DEPS_PACKAGE"
  exit 0
}

deps_install() {
  if [ "$DEPS_INSTALL" -eq 1 ]; then
    apk update
    apk add -u --no-cache --virtual "$DEPS_PACKAGE" $REQUIRED_DEPS
  else
    deps_check
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

deps_check() {
  local dep

  for dep in $REQUIRED_DEPS
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
      clean)            clean;;
      -deps_install)    DEPS_INSTALL=1;;
      --repository=*)   REPOSITORY="${i#*=}";;
      --version=*)      VERSION="${i#*=}";;
      --help)           usage;;
    esac
  done
}

usage() {
  cat <<'Usage'

usage: libstorj-alpine-source-builder.sh [OPTIONS]

  clean
      Runs installation clean function only.

  -deps_install
      Enables dependencies installation before building the library.

  --repository
      Github repository name. (Optional)

  --version
      Library version. (Optional)

  If clean option is not used, the tool will run the library install function.

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
