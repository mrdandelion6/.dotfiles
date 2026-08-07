#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 <local-file-path> <shelved-cl>" >&2
    echo "Example: $0 path/to/some_file.cpp 10XXXXXXX" >&2
}

if [[ $# -ne 2 ]]; then
    usage
    exit 2
fi

local_file=$1
cl=$2

if [[ ! -f "$local_file" ]]; then
    echo "error: local file does not exist: $local_file" >&2
    exit 1
fi

depot_path=$(p4 -ztag where "$local_file" | awk '$2 == "depotFile" { print substr($0, index($0, $3)); exit }')

if [[ -z "$depot_path" ]]; then
    echo "error: could not resolve depot path for: $local_file" >&2
    exit 1
fi

tmp_file=$(mktemp "/tmp/p4_shelf_diff.XXXXXX")
trap 'rm -f "$tmp_file"' EXIT

p4 print -q "${depot_path}@=${cl}" > "$tmp_file"

diff -u "$tmp_file" "$local_file"
