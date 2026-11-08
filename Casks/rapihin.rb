cask "rapihin" do
  version "1.0.0"
  sha256 "1c75d0cfea25d84a1102a8a2d8fb5cb4294643a9958fba5fb263f58872c9cbea"

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
