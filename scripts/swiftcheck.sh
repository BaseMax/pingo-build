#!/usr/bin/env bash
set -uo pipefail

mode="${1:-all}"
filter="${2:-.}"
root="$(cd "$(dirname "$0")/.." && pwd)"

remote='
mkdir -p /src && tar x -C /src && cd /src/ios
status=0

parse() {
  echo "== parse"
  count=0
  for f in $(find . -name "*.swift" -not -path "./_legacy/*" -not -path "./.build/*" | sort | grep -E "${FILTER:-.}"); do
    count=$((count + 1))
    out="$(swiftc -parse -swift-version 5 "$f" 2>&1)"
    if [ -n "$out" ]; then echo "--- $f"; echo "$out" | head -8; status=1; fi
  done
  echo "parsed $count files"
}

typecheck() {
  echo "== typecheck logic"
  out="$(swiftc -typecheck -swift-version 5 Shared/Logic/*.swift 2>&1)"
  if [ -n "$out" ]; then echo "$out" | head -60; status=1; else echo "logic typechecks"; fi
}

tests() {
  echo "== tests"
  if ls Tests/PingoLogicTests/*.swift >/dev/null 2>&1; then
    out="$(swift test 2>&1)"; code=$?
    echo "$out" | tail -40
    [ $code -ne 0 ] && status=1
  else
    echo "no tests yet"
  fi
}

case "$0" in
  parse) parse ;;
  typecheck) typecheck ;;
  test) tests ;;
  *) parse; typecheck; tests ;;
esac
exit $status
'

tar c -C "$root" --exclude=_legacy --exclude=.build --exclude=.DS_Store ios | docker run --rm -i --cpus 3 --memory 6g -e FILTER="$filter" swift:6.1 bash -c "$remote" "$mode"
