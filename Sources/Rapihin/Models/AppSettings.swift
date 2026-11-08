import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case indonesian = "id"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .indonesian:
            return "Bahasa Indonesia 🇮🇩"
        case .english:
            return "English 🇬🇧"
        }
    }
}

public enum SubfolderStructure: String, CaseIterable, Identifiable, Codable, Sendable {
    case categoryDate = "categoryDate"        // Documents/2026/11
    case dateCategory = "dateCategory"        // 2026/11/Documents
    case categoryOnly = "categoryOnly"        // Documents
    case categoryYear = "categoryYear"        // Documents/2026
    
    public var id: String { rawValue }
    
    public func label(for language: AppLanguage) -> String {
        switch self {
        case .categoryDate:
            return language == .indonesian ? "Kategori > Tahun > Bulan" : "Category > Year > Month"
        case .dateCategory:
            return language == .indonesian ? "Tahun > Bulan > Kategori" : "Year > Month > Category"
        case .categoryOnly:
            return language == .indonesian ? "Kategori Saja" : "Category Only"
        case .categoryYear:
            return language == .indonesian ? "Kategori > Tahun" : "Category > Year"
        }
    }
}

public enum SortStrategy: String, CaseIterable, Identifiable, Codable, Sendable {
    case createdAt = "createdAt"
    case name = "name"
    case size = "size"
    
    public var id: String { rawValue }
    
    public func label(for language: AppLanguage) -> String {
        switch self {
        case .createdAt:
            return language == .indonesian ? "Waktu Dibuat (Created At)" : "Creation Date (Created At)"
        case .name:
            return language == .indonesian ? "Nama File (Alfabetis)" : "File Name (Alphabetical)"
        case .size:
            return language == .indonesian ? "Ukuran File" : "File Size"
        }
    }
}

public struct AppSettings: Codable, Equatable, Sendable {
    public var language: AppLanguage = .indonesian
    public var launchAtLogin: Bool = false
    public var startMinimized: Bool = false
    public var destinationBaseFolder: String = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Documents")
        .appendingPathComponent("Rapihin").path
    public var subfolderStructure: SubfolderStructure = .categoryDate
    public var sortStrategy: SortStrategy = .createdAt
    public var prefixDateToName: Bool = false
    public var cleanFileNames: Bool = true
    public var playSounds: Bool = true
    public var hapticFeedback: Bool = true
    public var showInDock: Bool = true
    
    public init() {}
}
