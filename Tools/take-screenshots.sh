#!/usr/bin/env bash
#
# Run the AppStoreScreenshots UI test on a freshly-erased iPhone 17 Pro
# Max simulator (6.9" Display, the only screenshot slot a brand-new
# iOS 26+ app needs to fill on App Store Connect). The status bar is
# pinned to the canonical 9:41 / full-bars / charged appearance so each
# capture looks the same as Apple's own marketing.
#
# Usage:
#   Tools/take-screenshots.sh
#
# Output:
#   Tools/screenshots/<NN-name>.png  — six 1320×2868 PNGs
#
# The script erases the simulator before running so no leftover
# notification, no daily-reminder banner, and no widget animation can
# slip into a screenshot.

set -euo pipefail
cd "$(dirname "$0")/.."

SIM_NAME="iPhone 17 Pro Max"
SIM_ID=$(xcrun simctl list devices available \
  | grep "$SIM_NAME (" \
  | head -1 \
  | grep -oE '[A-F0-9-]{36}')

if [[ -z "$SIM_ID" ]]; then
  echo "error: no '$SIM_NAME' simulator found." >&2
  exit 1
fi

echo "→ erasing $SIM_NAME ($SIM_ID) for a clean state"
xcrun simctl shutdown "$SIM_ID" 2>/dev/null || true
xcrun simctl erase "$SIM_ID"
xcrun simctl boot "$SIM_ID"

echo "→ overriding status bar (9:41, charged, full bars)"
xcrun simctl status_bar "$SIM_ID" override \
  --time '9:41' \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100

XCRESULT=/tmp/medity-shots.xcresult
rm -rf "$XCRESULT"

echo "→ running AppStoreScreenshots UI test"
xcodebuild test \
  -project Medity.xcodeproj \
  -scheme Medity \
  -only-testing:MedityUITests/AppStoreScreenshots \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  -resultBundlePath "$XCRESULT" \
  | tail -20

DEST="Tools/screenshots"
RAW="$DEST/raw"
rm -rf "$RAW"
mkdir -p "$RAW"

echo "→ extracting attachments"
xcrun xcresulttool export attachments \
  --path "$XCRESULT" \
  --output-path "$RAW" \
  > /dev/null

echo "→ renaming captures"
python3 - <<'PY'
import json, os, shutil
from pathlib import Path
raw = Path("Tools/screenshots/raw")
dest = Path("Tools/screenshots")
manifest = json.loads((raw / "manifest.json").read_text())
for node in manifest:
    for att in node.get("attachments", []):
        ref = att["exportedFileName"]
        sug = att["suggestedHumanReadableName"]
        clean = sug.split("_0_")[0] + ".png"
        target = dest / clean
        if target.exists():
            target.unlink()
        shutil.move(raw / ref, target)
        print(f"  {clean}")
shutil.rmtree(raw)
PY

echo "→ resizing to 1284×2778 for App Store Connect's 6.5-inch slot"
# App Store Connect rejects 1320×2868 in some submission flows even
# though that's the canonical 6.9-inch size. Resampling down to 1284×2778
# (the 6.5-inch iPhone Display size) gets us through every slot without
# perceptible distortion (0.4 % aspect ratio shift).
for png in "$DEST"/*.png; do
  sips -z 2778 1284 "$png" --out "$png" > /dev/null
done

echo "→ clearing status bar override"
xcrun simctl status_bar "$SIM_ID" clear

echo "done — screenshots in $DEST/"
ls -la "$DEST"/*.png 2>/dev/null
