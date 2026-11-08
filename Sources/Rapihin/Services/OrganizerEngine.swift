import Foundation
import SwiftUI
import AppKit

@MainActor
public final class OrganizerEngine: ObservableObject {
    public static let shared = OrganizerEngine()
    
    @Published public var settings: AppSettings = AppSettings()
    @Published public var monitoredFolders: [MonitoredFolder] = []
    @Published public var history: [OrganizedItem] = []
    @Published public var isProcessing: Bool = false
    @Published public var pendingFilesCount: Int = 0
    @Published public var lastNotificationMessage: String?
    
    private let classifier = AIClassifier.shared
    private let watcher = FolderWatcher.shared
    private let historyKey = "rapihin_history_v1"
    private let foldersKey = "rapihin_folders_v1"
    private let settingsKey = "rapihin_settings_v1"
    
    private init() {
        loadSettings()
        loadMonitoredFolders()
        loadHistory()
        setupWatcher()
        recalculatePendingFiles()
    }
    
    // MARK: - Setup & Persistence
    private func setupWatcher() {
        watcher.onFileDetected = { [weak self] fileURL, folder in
            Task { @MainActor in
                await self?.organizeSingleFile(fileURL, from: folder)
            }
        }
        watcher.startWatching(folders: monitoredFolders)
    }
    
    public func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    public func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = decoded
        }
    }
    
    public func saveMonitoredFolders() {
        if let encoded = try? JSONEncoder().encode(monitoredFolders) {
            UserDefaults.standard.set(encoded, forKey: foldersKey)
        }
        watcher.startWatching(folders: monitoredFolders)
        recalculatePendingFiles()
    }
    
    public func loadMonitoredFolders() {
        if let data = UserDefaults.standard.data(forKey: foldersKey),
           let decoded = try? JSONDecoder().decode([MonitoredFolder].self, from: data) {
            self.monitoredFolders = decoded
        } else {
            // Default: Add user's Downloads and Desktop folders with manual mode initially
            let fm = FileManager.default
            let home = fm.homeDirectoryForCurrentUser
            let downloads = home.appendingPathComponent("Downloads")
            let desktop = home.appendingPathComponent("Desktop")
            
            var defaults: [MonitoredFolder] = []
            if fm.fileExists(atPath: downloads.path) {
                defaults.append(MonitoredFolder(path: downloads.path, name: "Downloads", isAuto: true, hasPermission: true))
            }
            if fm.fileExists(atPath: desktop.path) {
                defaults.append(MonitoredFolder(path: desktop.path, name: "Desktop", isAuto: false, hasPermission: true))
            }
            self.monitoredFolders = defaults
            saveMonitoredFolders()
        }
    }
    
    public func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    public func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([OrganizedItem].self, from: data) {
            self.history = decoded
        }
    }
    
    // MARK: - Folder Management
    public func addFolder(url: URL, isAuto: Bool = false) {
        let path = url.path
        guard !monitoredFolders.contains(where: { $0.path == path }) else { return }
        
        // Create security-scoped bookmark
        let bookmark = try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        
        let folder = MonitoredFolder(
            path: path,
            name: url.lastPathComponent,
            isAuto: isAuto,
            hasPermission: true,
            bookmarkData: bookmark
        )
        monitoredFolders.append(folder)
        saveMonitoredFolders()
    }
    
    public func removeFolder(id: UUID) {
        monitoredFolders.removeAll { $0.id == id }
        saveMonitoredFolders()
    }
    
    public func toggleFolderMode(id: UUID) {
        if let index = monitoredFolders.firstIndex(where: { $0.id == id }) {
            monitoredFolders[index].isAuto.toggle()
            saveMonitoredFolders()
        }
    }
    
    // MARK: - Pending Files Calculation
    public func recalculatePendingFiles() {
        let fm = FileManager.default
        var total = 0
        
        for folder in monitoredFolders {
            let url = URL(fileURLWithPath: folder.path)
            if let contents = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
                for item in contents {
                    var isDir: ObjCBool = false
                    if fm.fileExists(atPath: item.path, isDirectory: &isDir), !isDir.boolValue {
                        let ext = item.pathExtension.lowercased()
                        if ext != "crdownload" && ext != "download" && ext != "part" {
                            total += 1
                        }
                    }
                }
            }
        }
        self.pendingFilesCount = total
    }
    
    // MARK: - Organization Engine
    public func tidyAllNow() async {
        isProcessing = true
        defer {
            isProcessing = false
            recalculatePendingFiles()
        }
        
        var totalMoved = 0
        for i in 0..<monitoredFolders.count {
            let folder = monitoredFolders[i]
            let moved = await organizeFilesInFolder(folder)
            totalMoved += moved
            monitoredFolders[i].lastOrganized = Date()
        }
        
        saveMonitoredFolders()
        saveHistory()
        
        if totalMoved > 0 {
            playFeedback()
            lastNotificationMessage = String(format: loc("success_body"), totalMoved)
        }
    }
    
    public func organizeFilesInFolder(_ folder: MonitoredFolder) async -> Int {
        let fm = FileManager.default
        let folderURL = URL(fileURLWithPath: folder.path)
        
        guard let files = try? fm.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.creationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }
        
        var count = 0
        for fileURL in files {
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: fileURL.path, isDirectory: &isDir), isDir.boolValue {
                continue
            }
            
            let ext = fileURL.pathExtension.lowercased()
            if ext == "crdownload" || ext == "download" || ext == "part" || ext == "tmp" {
                continue
            }
            
            let success = await organizeSingleFile(fileURL, from: folder)
            if success {
                count += 1
            }
        }
        return count
    }
    
    @discardableResult
    public func organizeSingleFile(_ sourceURL: URL, from folder: MonitoredFolder?) async -> Bool {
        let fm = FileManager.default
        guard fm.fileExists(atPath: sourceURL.path) else { return false }
        
        // 1. AI Categorize
        let category = await classifier.classify(url: sourceURL)
        
        // 2. Resolve destination path based on settings
        let baseDir = folder?.customTargetPath ?? settings.destinationBaseFolder
        let destinationDir = calculateDestinationDirectory(base: baseDir, category: category, fileURL: sourceURL)
        
        // Ensure destination directory exists
        try? fm.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
        
        // 3. Resolve formatted file name
        let targetFileName = formatFileName(for: sourceURL)
        let finalDestinationURL = getUniqueDestinationURL(in: destinationDir, preferredName: targetFileName)
        
        // 4. Atomic Move
        do {
            let fileSize = (try? fm.attributesOfItem(atPath: sourceURL.path)[.size] as? Int64) ?? 0
            try fm.moveItem(at: sourceURL, to: finalDestinationURL)
            
            let record = OrganizedItem(
                originalPath: sourceURL.path,
                newPath: finalDestinationURL.path,
                fileName: finalDestinationURL.lastPathComponent,
                category: category,
                timestamp: Date(),
                fileSize: fileSize
            )
            history.insert(record, at: 0)
            saveHistory()
            return true
        } catch {
            print("[OrganizerEngine] Failed to move file \(sourceURL.lastPathComponent): \(error)")
            return false
        }
    }
    
    // MARK: - Undo Support
    public func undo(item: OrganizedItem) {
        let fm = FileManager.default
        let currentURL = URL(fileURLWithPath: item.newPath)
        let originalURL = URL(fileURLWithPath: item.originalPath)
        
        guard fm.fileExists(atPath: currentURL.path) else { return }
        
        // Ensure parent of original exists
        try? fm.createDirectory(at: originalURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        do {
            try fm.moveItem(at: currentURL, to: originalURL)
            if let index = history.firstIndex(where: { $0.id == item.id }) {
                history[index].wasUndone = true
                saveHistory()
            }
            recalculatePendingFiles()
            playFeedback()
        } catch {
            print("[OrganizerEngine] Undo failed: \(error)")
        }
    }
    
    public func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    // MARK: - Helpers
    private func calculateDestinationDirectory(base: String, category: FileCategory, fileURL: URL) -> URL {
        let baseURL = URL(fileURLWithPath: (base as NSString).expandingTildeInPath)
        let date = (try? fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
        
        let calendar = Calendar.current
        let year = String(calendar.component(.year, from: date))
        let month = String(format: "%02d", calendar.component(.month, from: date))
        
        switch settings.subfolderStructure {
        case .categoryDate:
            return baseURL.appendingPathComponent(category.folderName)
                .appendingPathComponent(year)
                .appendingPathComponent(month)
        case .dateCategory:
            return baseURL.appendingPathComponent(year)
                .appendingPathComponent(month)
                .appendingPathComponent(category.folderName)
        case .categoryYear:
            return baseURL.appendingPathComponent(category.folderName)
                .appendingPathComponent(year)
        case .categoryOnly:
            return baseURL.appendingPathComponent(category.folderName)
        }
    }
    
    private func formatFileName(for url: URL) -> String {
        var baseName = (url.lastPathComponent as NSString).deletingPathExtension
        let ext = url.pathExtension
        
        if settings.cleanFileNames {
            baseName = baseName.replacingOccurrences(of: " (1)", with: "")
            baseName = baseName.replacingOccurrences(of: " (2)", with: "")
            baseName = baseName.replacingOccurrences(of: " copy", with: "")
            baseName = baseName.replacingOccurrences(of: " salinan", with: "")
            baseName = baseName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if settings.prefixDateToName {
            let date = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let dateStr = df.string(from: date)
            if !baseName.hasPrefix(dateStr) {
                baseName = "\(dateStr)_\(baseName)"
            }
        }
        
        return ext.isEmpty ? baseName : "\(baseName).\(ext)"
    }
    
    private func getUniqueDestinationURL(in directory: URL, preferredName: String) -> URL {
        let fm = FileManager.default
        var targetURL = directory.appendingPathComponent(preferredName)
        
        if !fm.fileExists(atPath: targetURL.path) {
            return targetURL
        }
        
        let base = (preferredName as NSString).deletingPathExtension
        let ext = (preferredName as NSString).pathExtension
        var counter = 1
        
        while fm.fileExists(atPath: targetURL.path) {
            let newName = ext.isEmpty ? "\(base) (\(counter))" : "\(base) (\(counter)).\(ext)"
            targetURL = directory.appendingPathComponent(newName)
            counter += 1
        }
        return targetURL
    }
    
    private func playFeedback() {
        if settings.playSounds {
            NSSound(named: "Glass")?.play()
        }
        if settings.hapticFeedback {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        }
    }
}
