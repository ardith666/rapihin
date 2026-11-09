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

public enum AutoOrganizeDelay: Int, CaseIterable, Identifiable, Codable, Sendable {
    case instant = 0
    case seconds10 = 10
    case seconds30 = 30
    case minute1 = 60
    case minutes5 = 300
    case minutes10 = 600       // Default 10 menit sesuai permintaan
    case minutes30 = 1800
    case hour1 = 3600
    
    public var id: Int { rawValue }
    public var seconds: TimeInterval { TimeInterval(rawValue) }
    
    public func label(for language: AppLanguage) -> String {
        switch self {
        case .instant:
            return language == .indonesian ? "Langsung (Tanpa Jeda)" : "Immediate (No Delay)"
        case .seconds10:
            return language == .indonesian ? "10 Detik" : "10 Seconds"
        case .seconds30:
            return language == .indonesian ? "30 Detik" : "30 Seconds"
        case .minute1:
            return language == .indonesian ? "1 Menit" : "1 Minute"
        case .minutes5:
            return language == .indonesian ? "5 Menit" : "5 Minutes"
        case .minutes10:
            return language == .indonesian ? "10 Menit (Bawaan)" : "10 Minutes (Default)"
        case .minutes30:
            return language == .indonesian ? "30 Menit" : "30 Minutes"
        case .hour1:
            return language == .indonesian ? "1 Jam" : "1 Hour"
        }
    }
}

public struct AppSettings: Codable, Equatable, Sendable {
    public var language: AppLanguage = .indonesian
    public var launchAtLogin: Bool = false
    public var startMinimized: Bool = false
    public var destinationBaseFolder: String = ""
    public var subfolderStructure: SubfolderStructure = .categoryOnly
    public var sortStrategy: SortStrategy = .createdAt
    public var autoOrganizeDelay: AutoOrganizeDelay = .minutes10
    public var prefixDateToName: Bool = false
    public var cleanFileNames: Bool = true
    public var playSounds: Bool = true
    public var hapticFeedback: Bool = true
    public var showInDock: Bool = true
    
    public init() {}
}
