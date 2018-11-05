#!/bin/sh

set -Eeuo pipefail

readonly SOURCE_URL="https://api.github.com/repos/%s/releases/%s"
readonly SOURCE_DIR="libstorj"

REPOSITORY="storj/libstorj"
