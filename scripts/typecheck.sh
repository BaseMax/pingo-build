#!/usr/bin/env bash
set -uo pipefail

mode="${1:-all}"
filter="${2:-.}"
root="$(cd "$(dirname "$0")/.." && pwd)"
tc="$root/scripts/typecheck"
build="${TC_BUILD:-${TMPDIR:-/tmp}/pingo-typecheck-build}"
image="${PINGO_SWIFT_IMAGE:-swift:6.2}"
limits="--rm -i --cpus 2 --memory 3g"
order="$(python3 "$tc/gen.py" order)"
digest="$(find "$tc/stubs" -name '*.swift' | sort | xargs cat | sha1sum | cut -c1-12)-$(echo "$image" | tr ':/' '__')"
modules="$build/$digest"
mkdir -p "$build"

stub_script='
mkdir -p /w/out && tar x -C /w && cd /w
for module in $ORDER; do
  files="$(ls stubs/$module/*.swift 2>/dev/null)"
  [ -z "$files" ] && continue
  swiftc -emit-module -parse-as-library -swift-version 5 -module-name $module -I out -o out/$module.swiftmodule \
    -Xfrontend -experimental-skip-non-inlinable-function-bodies-without-types $files 2>&1 \
    | grep -E "^[^ ]+:[0-9]+:[0-9]+: (error|warning):" | sed "s#^#[$module] #" >&2
  [ -f out/$module.swiftmodule ] || echo "[$module] module not produced" >&2
done
tar c -C /w/out .
'

check_script='
mkdir -p /w && tar x -C /w && cd /w
status=0
for target in $TARGETS; do
  if [ "$target" = app ]; then
    files="$(find ios/Shared ios/App -name "*.swift" | sort)"; name=Pingo
  else
    files="$(find ios/Shared ios/Widgets -name "*.swift" | sort)"; name=PingoWidgets
  fi
  swiftc -typecheck -wmo -parse-as-library -swift-version 5 -module-name $name -I modules $files 2>&1 \
    | grep -E "^[^ ]+:[0-9]+:[0-9]+: (error|warning):" | sed "s#^/w/##; s#^#$target #"
done
'

build_modules() {
  local staging="$modules.partial"
  rm -f "$staging.tar" "$staging.log"
  tar c -C "$tc" stubs | docker run $limits -e ORDER="$order" "$image" bash -c "$stub_script" > "$staging.tar" 2> "$staging.log"
  if [ -s "$staging.log" ]; then
    sed 's#^\[\([A-Za-z]*\)\] #\1 stub: #' "$staging.log" | sort -u | head -80
    echo "stub modules have diagnostics, see $staging.log" >&2
  fi
  if grep -q "error:\|not produced" "$staging.log"; then return 1; fi
  mkdir -p "$modules" && tar x -C "$modules" -f "$staging.tar"
}

if [ "$mode" = stubs ]; then
  rm -f "$modules"/*.swiftmodule
  build_modules
  exit $?
fi

[ -f "$modules/Darwin.swiftmodule" ] || build_modules || exit 2

case "$mode" in
  app) targets="app" ;;
  widgets) targets="widgets" ;;
  *) targets="app widgets" ;;
esac

raw="$(tar c -C "$root" --exclude=_legacy --exclude=Tests --exclude=.build --exclude=.DS_Store ios \
  -C "$build" --transform "s,^$digest/,modules/," "$digest" \
  | docker run $limits -e TARGETS="$targets" "$image" bash -c "$check_script")"

printf '%s\n' "$raw" | sed 's#^[a-z]* ##' | sort -t: -k1,1 -k2,2n -k3,3n | uniq > "$build/last.txt"
errors="$(grep -c ': error: ' "$build/last.txt")"
warnings="$(grep -c ': warning: ' "$build/last.txt")"
{ grep ': error: ' "$build/last.txt"; grep ': warning: ' "$build/last.txt"; } | grep -E "$filter" || true
echo "errors: $errors warnings: $warnings"
[ "$errors" -eq 0 ]
