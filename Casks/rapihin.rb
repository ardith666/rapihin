cask "rapihin" do
  version "1.0.0"
  sha256 "89e22c29f224fc2a444a8fef0c5b36c81915d0ba40028a59816a2e88bd091227"

  url "https://github.com/ardith666/rapihin/releases/download/v#{version}/Rapihin-#{version}.dmg"
  name "Rapihin"
  desc "Smart, ultra-lightweight and local-first macOS file organizer powered by on-device Apple Intelligence"
  homepage "https://github.com/ardith666/rapihin"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "Rapihin.app"

  zap trash: [
    "~/Library/Application Support/Rapihin",
    "~/Library/Preferences/com.rapihin.mac.plist",
    "~/Library/Saved Application State/com.rapihin.mac.savedState",
  ]
end
