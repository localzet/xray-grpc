#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
proto_root="${project_root}/src"
output_root="${PHP_OUT_DIR:-${project_root}/php/src}"
compiler="${PROTOC:-protoc}"
command -v "$compiler" >/dev/null 2>&1 || { echo 'protoc is required; see README.md' >&2; exit 69; }
[[ "$("$compiler" --version)" == 'libprotoc 25.8' ]] || { echo 'Expected protoc 25.8' >&2; exit 65; }
mapfile -d '' -t protos < <(find "$proto_root" -type f -name '*.proto' -print0 | sort -z)
[[ "${#protos[@]}" -gt 0 ]] || { echo 'No protobuf sources found' >&2; exit 66; }

if [[ "${1:-}" == '--check' ]]; then
  descriptor="$(mktemp)"
  trap 'rm -f "$descriptor"' EXIT
  "$compiler" --proto_path="$proto_root" --include_imports --descriptor_set_out="$descriptor" "${protos[@]}"
  echo 'Protobuf syntax and imports checked'
  exit 0
fi

mkdir -p "$output_root"
arguments=(--proto_path="$proto_root" --php_out="$output_root")
if [[ "${1:-}" != '--php-only' ]]; then
  plugin="${GRPC_PHP_PLUGIN:-}"
  [[ -n "$plugin" && -x "$plugin" ]] || { echo 'Set GRPC_PHP_PLUGIN to an explicitly selected executable; see README.md' >&2; exit 69; }
  arguments+=(--grpc_out="$output_root" "--plugin=protoc-gen-grpc=$plugin")
fi
"$compiler" "${arguments[@]}" "${protos[@]}"
echo "PHP sources generated with protoc 25.8 in $output_root"
