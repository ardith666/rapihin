#!/bin/bash
set -e

SOURCE_IMG="assets/AppIcon_1024.png"
ICONSET="assets/AppIcon.iconset"
OUTPUT_ICNS="assets/AppIcon.icns"

if [ ! -f "$SOURCE_IMG" ]; then
    echo "❌ Source image $SOURCE_IMG not found!"
    exit 1
fi

echo "🎨 Creating iconset from $SOURCE_IMG..."
rm -rf "$ICONSET" "$OUTPUT_ICNS"
mkdir -p "$ICONSET"

# Generate standard Apple icon dimensions
sips -z 16 16     "$SOURCE_IMG" --out "$ICONSET/icon_16x16.png" > /dev/null
sips -z 32 32     "$SOURCE_IMG" --out "$ICONSET/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "$SOURCE_IMG" --out "$ICONSET/icon_32x32.png" > /dev/null
sips -z 64 64     "$SOURCE_IMG" --out "$ICONSET/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "$SOURCE_IMG" --out "$ICONSET/icon_128x128.png" > /dev/null
sips -z 256 256   "$SOURCE_IMG" --out "$ICONSET/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "$SOURCE_IMG" --out "$ICONSET/icon_256x256.png" > /dev/null
sips -z 512 512   "$SOURCE_IMG" --out "$ICONSET/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "$SOURCE_IMG" --out "$ICONSET/icon_512x512.png" > /dev/null
sips -z 1024 1024 "$SOURCE_IMG" --out "$ICONSET/icon_512x512@2x.png" > /dev/null

echo "🔨 Generating $OUTPUT_ICNS via iconutil..."
iconutil -c icns "$ICONSET" -o "$OUTPUT_ICNS"
rm -rf "$ICONSET"

echo "✅ AppIcon.icns successfully created!"
ls -lh "$OUTPUT_ICNS"
