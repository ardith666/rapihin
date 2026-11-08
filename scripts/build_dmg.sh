#!/bin/bash
set -e

# Ensure clean build
./scripts/build_app.sh

DMG_NAME="Rapihin-1.0.0.dmg"
rm -f "$DMG_NAME"

echo "💿 Creating installer DMG..."
create-dmg \
  --volname "Rapihin Installer" \
  --volicon "assets/AppIcon.icns" \
  --background "assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 660 420 \
  --icon-size 100 \
  --icon "Rapihin.app" 175 220 \
  --app-drop-link 485 220 \
  --hide-extension "Rapihin.app" \
  --no-internet-enable \
  "$DMG_NAME" \
  "Rapihin.app" || true

if [ -f "$DMG_NAME" ]; then
  echo "✅ DMG created successfully: $DMG_NAME"
  ls -lh "$DMG_NAME"
else
  echo "⚠️ Fallback: creating compressed disk image via hdiutil..."
  hdiutil create -volname "Rapihin Installer" -srcfolder "Rapihin.app" -ov -format UDZO "$DMG_NAME"
  echo "✅ DMG created successfully via hdiutil: $DMG_NAME"
fi
