#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/rules/ClashVerge"
DST_DIR="${ROOT_DIR}/rules/ShadowRocket"

mkdir -p "${DST_DIR}"

shopt -s nullglob
RULE_FILES=("${SRC_DIR}"/*.yaml)

for src in "${RULE_FILES[@]}"; do
  name="$(basename "${src}" .yaml)"
  dst="${DST_DIR}/${name}.list"

  sed -n '/^payload:/,$p' "${src}" \
    | sed '1d' \
    | sed -E 's/^[[:space:]]*-[[:space:]]*//' \
    | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' \
    | sed '/^$/d' \
    | sed '/^#/d' \
    | sed -E 's/^([A-Z-]+),[[:space:]]+/\1,/' \
    | awk '!seen[$0]++ { print }' > "${dst}"
done

echo "Updated ${DST_DIR}/*.list"
