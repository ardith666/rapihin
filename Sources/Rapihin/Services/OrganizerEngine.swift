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
            if UserDefaults.standard.object(forKey: "rapihin_migrated_category_only_v2") == nil {
                self.settings.subfolderStructure = .categoryOnly
                UserDefaults.standard.set(true, forKey: "rapihin_migrated_category_only_v2")
                saveSettings()
            }
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
        let categoryNames = Set(FileCategory.allCases.map { $0.folderName })
        
        for folder in monitoredFolders {
            let url = URL(fileURLWithPath: folder.path)
            if let contents = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
                for item in contents {
                    var isDir: ObjCBool = false
                    if fm.fileExists(atPath: item.path, isDirectory: &isDir) {
                        let name = item.lastPathComponent
                        if isDir.boolValue {
                            if !categoryNames.contains(name) {
                                total += 1
                            }
                        } else {
                            let ext = item.pathExtension.lowercased()
                            if ext != "crdownload" && ext != "download" && ext != "part" {
                                total += 1
                            }
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
                let name = fileURL.lastPathComponent
                if FileCategory.allCases.contains(where: { $0.folderName == name }) {
                    continue
                }
                let success = await organizeFolderAsUnit(fileURL, in: folder)
                if success {
                    count += 1
                }
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
    public func organizeFolderAsUnit(_ folderURL: URL, in monitoredFolder: MonitoredFolder) async -> Bool {
        let fm = FileManager.default
        let folderName = folderURL.lastPathComponent
        
        // Guard: Don't organize category folders
        if FileCategory.allCases.contains(where: { $0.folderName == folderName }) {
            return false
        }
        
        // Determine dominant category of the folder
        let category = await determineDominantCategory(for: folderURL)
        
        // Destination directory inside the same monitored folder
        let destinationDir = calculateDestinationDirectory(base: monitoredFolder.path, category: category, fileURL: folderURL)
        
        // Guard against moving into itself
        if destinationDir.path == folderURL.deletingLastPathComponent().path {
            return false
        }
        
        try? fm.createDirectory(at: destinationDir, withIntermediateDirectories: true)
        
        let finalDestinationURL = getUniqueDestinationURL(in: destinationDir, preferredName: folderName)
        if folderURL.path == finalDestinationURL.path {
            return false
        }
        
        do {
            try fm.moveItem(at: folderURL, to: finalDestinationURL)
            let record = OrganizedItem(
                originalPath: folderURL.path,
                newPath: finalDestinationURL.path,
                fileName: "📁 \(folderName)",
                category: category,
                timestamp: Date(),
                fileSize: 0
            )
            history.insert(record, at: 0)
            saveHistory()
            return true
        } catch {
            print("[OrganizerEngine] Failed to move unified folder: \(error)")
            return false
        }
    }
    
    private func determineDominantCategory(for folderURL: URL) async -> FileCategory {
        let fm = FileManager.default
        let folderName = folderURL.lastPathComponent.lowercased()
        
        // Name-based hints
        if folderName.contains("code") || folderName.contains("project") || folderName.contains("app") || folderName.contains("web") || folderName.contains("git") {
            return .code
        }
        if folderName.contains("invoice") || folderName.contains("keuangan") || folderName.contains("tagihan") || folderName.contains("slip") || folderName.contains("tax") {
            return .finance
        }
        if folderName.contains("photo") || folderName.contains("foto") || folderName.contains("video") || folderName.contains("music") || folderName.contains("lagu") {
            return .media
        }
        
        // Sample files inside
        guard let items = try? fm.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return .other
        }
        
        var categoryCounts: [FileCategory: Int] = [:]
        for item in items.prefix(15) {
            let cat = await classifier.classify(url: item)
            categoryCounts[cat, default: 0] += 1
        }
        
        return categoryCounts.max(by: { $0.value < $1.value })?.key ?? .documents
    }
    
    @discardableResult
    public func organizeSingleFile(_ sourceURL: URL, from folder: MonitoredFolder?) async -> Bool {
        let fm = FileManager.default
        guard fm.fileExists(atPath: sourceURL.path) else { return false }
        
        // 1. Resolve base directory: ALWAYS stay in the SAME parent folder!
        let baseDir = folder?.path ?? sourceURL.deletingLastPathComponent().path
        
        // If file is already inside one of the category subfolders, don't move it again
        let parentDirName = sourceURL.deletingLastPathComponent().lastPathComponent
        if FileCategory.allCases.contains(where: { $0.folderName == parentDirName }) {
            return false
        }
        
        // 2. AI Categorize
        let category = await classifier.classify(url: sourceURL)
        
        // 3. Resolve destination path based on settings (stays inside baseDir)
        let destinationDir = calculateDestinationDirectory(base: baseDir, category: category, fileURL: sourceURL)
        
        // Guard against moving to the same directory
        if destinationDir.path == sourceURL.deletingLastPathComponent().path {
            return false
        }
        
        // Ensure destination directory exists directly inside the current folder
        try? fm.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
        
        // 4. Resolve formatted file name
        let targetFileName = formatFileName(for: sourceURL)
        let finalDestinationURL = getUniqueDestinationURL(in: destinationDir, preferredName: targetFileName)
        
        if sourceURL.path == finalDestinationURL.path {
            return false
        }
        
        // 5. Atomic Move
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
    
    public func undoBatch(ids: Set<UUID>) {
        for id in ids {
            if let item = history.first(where: { $0.id == id && !$0.wasUndone }) {
                undo(item: item)
            }
        }
    }
    
    public func undoAll() {
        let activeItems = history.filter { !$0.wasUndone }
        for item in activeItems {
            undo(item: item)
        }
    }
    
    // MARK: - Work Analytics & Stats
    public var activeHistoryCount: Int {
        history.filter { !$0.wasUndone }.count
    }
    
    public var totalOrganizedBytes: Int64 {
        history.filter { !$0.wasUndone }.reduce(0) { $0 + $1.fileSize }
    }
    
    public var formattedTotalSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalOrganizedBytes)
    }
    
    public var estimatedTimeSavedString: String {
        let totalSeconds = activeHistoryCount * 15 // ~15 seconds manual sorting saved per file
        if totalSeconds < 60 {
            return "\(totalSeconds) dtk"
        } else {
            let minutes = totalSeconds / 60
            return "\(minutes) mnt"
        }
    }
    
    public var categoryBreakdown: [CategoryCount] {
        var dict: [FileCategory: Int] = [:]
        for item in history where !item.wasUndone {
            dict[item.category, default: 0] += 1
        }
        return FileCategory.allCases.compactMap { cat in
            let count = dict[cat, default: 0]
            return count > 0 ? CategoryCount(category: cat, count: count) : nil
        }
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

public struct CategoryCount: Identifiable, Sendable {
    public var id: String { category.rawValue }
    public let category: FileCategory
    public let count: Int
    
    public init(category: FileCategory, count: Int) {
        self.category = category
        self.count = count
    }
}
