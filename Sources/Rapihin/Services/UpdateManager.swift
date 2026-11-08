import Foundation
import AppKit

@MainActor
public final class UpdateManager: ObservableObject {
    public static let shared = UpdateManager()
    
    public let currentVersion: String = "1.0.0"
    public let currentBuild: String = "1"
    
    @Published public var isChecking: Bool = false
    @Published public var isUpdateAvailable: Bool = false
    @Published public var latestVersion: String = "1.0.0"
    @Published public var releaseNotes: String = ""
    @Published public var releaseURL: URL? = URL(string: "https://github.com/ardith666/rapihin/releases/latest")
    @Published public var lastChecked: Date?
    @Published public var statusMessage: String?
    
    private let repoAPI = "https://api.github.com/repos/ardith666/rapihin/releases/latest"
    
    public struct ChangelogEntry: Identifiable, Sendable {
        public var id: String { version }
        public let version: String
        public let date: String
        public let highlights: [String]
    }
    
    public let changelogHistory: [ChangelogEntry] = [
        ChangelogEntry(
            version: "v1.0.0",
            date: "November 2026",
            highlights: [
                "Perapihan berkas langsung di folder asalnya (In-Place) tanpa dipindah keluar.",
                "Default skema subfolder: Kategori Saja (Finance, Documents, Screenshots, Code, Media, Archives).",
                "Integrasi AI bawaan macOS & Apple Intelligence (Vision OCR, NaturalLanguage, PDFKit) tanpa download LLM terpisah.",
                "Dukungan mode per-folder: Otomatis (Real-time) dengan proteksi jeda unduhan atau Manual (On-demand).",
                "Dasbor analitik hasil kerja: Donut chart distribusi kategori, total kapasitas, dan estimasi waktu dihemat.",
                "Fitur Riwayat canggih: Pilih satu per satu, Pilih Semua, dan Kembalikan (Undo) berkas ke lokasi asal.",
                "Autostart saat login via SMAppService resmi macOS.",
                "Dukungan dwibahasa penuh: Bahasa Indonesia & English.",
                "Paket instalasi DMG interaktif dan distribusi via Homebrew Tap."
            ]
        )
    ]
    
    private init() {}
    
    public func checkForUpdates() async {
        isChecking = true
        statusMessage = nil
        
        defer {
            isChecking = false
            lastChecked = Date()
        }
        
        guard let url = URL(string: repoAPI) else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("RapihinApp/\(currentVersion)", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                statusMessage = "Tidak dapat memeriksa rilis terbaru saat ini."
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let tagName = json["tag_name"] as? String {
                let cleanTag = tagName.replacingOccurrences(of: "v", with: "").trimmingCharacters(in: .whitespaces)
                self.latestVersion = cleanTag
                
                if let htmlURLStr = json["html_url"] as? String, let u = URL(string: htmlURLStr) {
                    self.releaseURL = u
                }
                
                if let body = json["body"] as? String {
                    self.releaseNotes = body
                }
                
                if isVersionNewer(cleanTag, than: currentVersion) {
                    self.isUpdateAvailable = true
                    self.statusMessage = "Versi \(tagName) tersedia untuk diunduh!"
                } else {
                    self.isUpdateAvailable = false
                    self.statusMessage = "Rapihin sudah menggunakan versi terbaru (\(currentVersion))."
                }
            }
        } catch {
            statusMessage = "Gagal terhubung ke server pembaruan."
        }
    }
    
    public func openDownloadPage() {
        if let url = releaseURL {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func isVersionNewer(_ remote: String, than current: String) -> Bool {
        let remoteParts = remote.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(remoteParts.count, currentParts.count) {
            let r = i < remoteParts.count ? remoteParts[i] : 0
            let c = i < currentParts.count ? currentParts[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }
}
