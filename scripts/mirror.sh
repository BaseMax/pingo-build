#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 1 ] || { echo "usage: mirror.sh <target dir>" >&2; exit 2; }

root="$(cd "$(dirname "$0")/.." && pwd)"
target="$1"
ref="${MIRROR_REF:-HEAD}"

excluded=(
  ios/_legacy
  ios/Shared/Fonts
  scripts/typecheck
  scripts/build-landing.py
  landing
  site
  deploy
)

if [ -d "$target" ] && [ -n "$(ls -A "$target")" ]; then
  echo "mirror: $target exists and is not empty" >&2
  exit 1
fi

mkdir -p "$target"
target="$(cd "$target" && pwd)"

pathspec=(.)
for path in "${excluded[@]}"; do
  pathspec+=(":(exclude)$path")
done

git -C "$root" archive --format=tar "$ref" -- "${pathspec[@]}" | tar -x -C "$target"

(cd "$target" && find . -type f | sed 's#^\./##' | sort)
echo "mirror: $(find "$target" -type f | wc -l | tr -d ' ') files in $target, nothing was pushed"
