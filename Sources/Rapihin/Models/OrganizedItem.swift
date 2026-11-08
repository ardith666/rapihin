import Foundation

public struct OrganizedItem: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var originalPath: String
    public var newPath: String
    public var fileName: String
    public var category: FileCategory
    public var timestamp: Date
    public var fileSize: Int64
    public var wasUndone: Bool
    
    public init(
        id: UUID = UUID(),
        originalPath: String,
        newPath: String,
        fileName: String,
        category: FileCategory,
        timestamp: Date = Date(),
        fileSize: Int64 = 0,
        wasUndone: Bool = false
    ) {
        self.id = id
        self.originalPath = originalPath
        self.newPath = newPath
        self.fileName = fileName
        self.category = category
        self.timestamp = timestamp
        self.fileSize = fileSize
        self.wasUndone = wasUndone
    }
    
    public var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
}
