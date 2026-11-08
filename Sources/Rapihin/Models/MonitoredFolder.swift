import Foundation

public struct MonitoredFolder: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var path: String
    public var name: String
    public var isAuto: Bool               // true = auto tidy real-time, false = manual on-demand
    public var hasPermission: Bool        // Security scoped permission granted
    public var bookmarkData: Data?        // Persisted security-scoped bookmark
    public var customTargetPath: String?  // Optional custom target folder override
    public var lastOrganized: Date?
    
    public init(
        id: UUID = UUID(),
        path: String,
        name: String? = nil,
        isAuto: Bool = false,
        hasPermission: Bool = true,
        bookmarkData: Data? = nil,
        customTargetPath: String? = nil,
        lastOrganized: Date? = nil
    ) {
        self.id = id
        self.path = path
        self.name = name ?? (path as NSString).lastPathComponent
        self.isAuto = isAuto
        self.hasPermission = hasPermission
        self.bookmarkData = bookmarkData
        self.customTargetPath = customTargetPath
        self.lastOrganized = lastOrganized
    }
    
    public var url: URL {
        URL(fileURLWithPath: path)
    }
}
