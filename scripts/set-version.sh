#!/usr/bin/env bash

set -euo pipefail

update_lua_globals_version() {
  local tmp
  tmp=$(mktemp)
  sed -e "s/VERSION = \".*\"/VERSION = \"$VERSION\"/" ./lua/kulala_cmp_graphql/globals/init.lua > "$tmp" && mv "$tmp" ./lua/kulala_cmp_graphql/globals/init.lua
}

update_lua_globals_version
