import Foundation

public final class FolderWatcher: @unchecked Sendable {
    public static let shared = FolderWatcher()
    
    private var sources: [String: DispatchSourceFileSystemObject] = [:]
    private var debounceTimers: [String: Timer] = [:]
    private let queue = DispatchQueue(label: "com.rapihin.folderwatcher", qos: .utility)
    
    public var onFileDetected: ((URL, MonitoredFolder) -> Void)?
    
    private init() {}
    
    public func startWatching(folders: [MonitoredFolder]) {
        stopWatching()
        for folder in folders where folder.isAuto {
            watch(folder: folder)
        }
    }
    
    public func stopWatching() {
        queue.sync {
            for (_, source) in sources {
                source.cancel()
            }
            sources.removeAll()
            
            for (_, timer) in debounceTimers {
                timer.invalidate()
            }
            debounceTimers.removeAll()
        }
    }
    
    private func watch(folder: MonitoredFolder) {
        let path = folder.path
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            print("[FolderWatcher] Could not open file descriptor for path: \(path)")
            return
        }
        
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .extend, .attrib, .link],
            queue: queue
        )
        
        source.setEventHandler { [weak self] in
            self?.handleFolderEvent(folder: folder)
        }
        
        source.setCancelHandler {
            close(fileDescriptor)
        }
        
        sources[path] = source
        source.resume()
        print("[FolderWatcher] Started auto-watching: \(folder.name)")
    }
    
    private func handleFolderEvent(folder: MonitoredFolder) {
        let folderPath = folder.path
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Invalidate prior debounce timer for this folder
            self.debounceTimers[folderPath]?.invalidate()
            
            // Wait 2.5 seconds for file writes/downloads to stabilize
            self.debounceTimers[folderPath] = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
                self?.scanAndDispatchNewFiles(in: folder)
            }
        }
    }
    
    private func scanAndDispatchNewFiles(in folder: MonitoredFolder) {
        let fm = FileManager.default
        let folderURL = URL(fileURLWithPath: folder.path)
        
        guard let contents = try? fm.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return }
        
        let now = Date()
        
        for fileURL in contents {
            let ext = fileURL.pathExtension.lowercased()
            
            // Guard: Ignore partial in-progress downloads
            if ext == "crdownload" || ext == "download" || ext == "part" || ext == "tmp" {
                continue
            }
            
            // Guard: Ignore folders, only organize regular files directly inside this folder
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: fileURL.path, isDirectory: &isDir), isDir.boolValue {
                continue
            }
            
            // Check file modification time (only process files modified in the last 15 seconds)
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
               let modDate = resourceValues.contentModificationDate {
                if now.timeIntervalSince(modDate) < 15.0 {
                    self.onFileDetected?(fileURL, folder)
                }
            }
        }
    }
}
