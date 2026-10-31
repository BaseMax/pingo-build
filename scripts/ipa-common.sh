app_dir="Pingo.app"
widget_rel="PlugIns/PingoWidgets.appex"
plistbuddy="${PLISTBUDDY:-/usr/libexec/PlistBuddy}"

plist_value() {
  "$plistbuddy" -c "Print :$2" "$1"
}

absolute() {
  mkdir -p "$(dirname "$1")"
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

clear_dir() {
  [ -d "$1" ] && find "$1" -mindepth 1 -depth \( -type f -o -type l \) -delete && find "$1" -mindepth 1 -depth -type d -empty -delete
  return 0
}
