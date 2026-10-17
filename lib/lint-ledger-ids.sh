#!/usr/bin/env bash

set -euo pipefail

spec_file="SPEC.md"

if [[ ! -f "$spec_file" ]]; then
  printf 'ledger-ids: missing %s\n' "$spec_file" >&2
  exit 1
fi

ids=$(
  awk -F'|' '
    $0 ~ /^\| `?[[:space:]]*[x ]+[[:space:]]*`?[[:space:]]*\|[[:space:]]*T[0-9]+[[:space:]]*\|/ {
      id = $3
      gsub(/[[:space:]`]/, "", id)
      print id
    }
  ' "$spec_file"
)

if [[ -z "$ids" ]]; then
  printf 'ledger-ids: no task IDs found in %s\n' "$spec_file" >&2
  exit 1
fi

duplicate_ids=$(printf '%s\n' "$ids" | sort | uniq -d)
if [[ -n "$duplicate_ids" ]]; then
  printf 'ledger-ids: duplicate task IDs in %s: %s\n' "$spec_file" "$duplicate_ids" >&2
  exit 1
fi
