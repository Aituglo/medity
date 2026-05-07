#!/usr/bin/env bash
#
# Pull every screenshot attachment out of an Xcode UI-test result bundle
# and copy them, named, into the destination folder.
#
# Usage:
#   Tools/extract-screenshots.sh /tmp/medity-shots.xcresult Tools/screenshots
#
# Requires `xcrun xcresulttool` (ships with Xcode) and `jq`.

set -euo pipefail

XCRESULT="${1:-/tmp/medity-shots.xcresult}"
DEST="${2:-Tools/screenshots}"

if [[ ! -d "$XCRESULT" ]]; then
  echo "error: xcresult bundle not found at $XCRESULT" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required" >&2
  exit 1
fi

mkdir -p "$DEST"

# Walk the result bundle JSON for every attachment whose UTI is image/png
# and whose name was set by the UI test (XCTAttachment.name).
xcrun xcresulttool get --legacy --format json --path "$XCRESULT" \
  | jq -r '
    .. | objects
       | select(.attachments?._values?)
       | .attachments._values[]
       | select(.uniformTypeIdentifier?._value == "public.png")
       | "\(.name._value)\t\(.payloadRef.id._value)"
  ' \
  | while IFS=$'\t' read -r name ref; do
      out="$DEST/$name.png"
      xcrun xcresulttool get --legacy --path "$XCRESULT" --id "$ref" > "$out"
      echo "→ $out"
    done

echo "done — $(ls "$DEST" | wc -l | tr -d ' ') screenshots in $DEST"
