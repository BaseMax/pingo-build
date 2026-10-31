#!/usr/bin/env bash
set -euo pipefail

[ $# -eq 2 ] || { echo "usage: make-ipa.sh <products dir> <output ipa>" >&2; exit 2; }

root="$(cd "$(dirname "$0")/.." && pwd)"
. "$root/scripts/ipa-common.sh"

products="$1"
ipa="$(absolute "$2")"
work="$(dirname "$ipa")/ipa-work"
app="$work/Payload/$app_dir"
widget="$app/$widget_rel"

[ -d "$products/$app_dir" ] || { echo "make-ipa: $products/$app_dir not found" >&2; exit 1; }

stage() {
  clear_dir "$work"
  mkdir -p "$work/Payload" "$work/ent"
  cp -R "$products/$app_dir" "$work/Payload/"
  find "$work/Payload" \( -name '*.dSYM' -o -name '*.swiftmodule' -o -name '*.swiftdoc' -o -name '*.swiftinterface' -o -name '.DS_Store' \) -prune -exec rm -r {} +
  [ -d "$widget" ] || { echo "make-ipa: widget extension missing at $widget" >&2; exit 1; }
}

render_entitlements() {
  local group
  group="$(plist_value "$app/Info.plist" PingoGroup)"
  sed "s/\$(PINGO_GROUP)/$group/g" "$root/ios/Config/$1.entitlements" > "$work/ent/$1.entitlements"
}

sign() {
  codesign --force --sign - --generate-entitlement-der --entitlements "$work/ent/$2.entitlements" "$1"
}

package() {
  rm -f "$ipa"
  (cd "$work" && zip -qryX "$ipa" Payload)
}

stage
render_entitlements App
render_entitlements Widgets
sign "$widget" Widgets
sign "$app" App
package
clear_dir "$work"
rmdir "$work"
echo "make-ipa: $ipa"
