import Foundation
import SwiftUI

public enum FileCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case finance = "finance"
    case documents = "documents"
    case screenshots = "screenshots"
    case code = "code"
    case media = "media"
    case archives = "archives"
    case other = "other"
    
    public var id: String { rawValue }
    
    public func title(for language: AppLanguage) -> String {
        switch self {
        case .finance:
            return language == .indonesian ? "Keuangan & Tagihan" : "Finance & Invoices"
        case .documents:
            return language == .indonesian ? "Dokumen & Kerja" : "Documents & Work"
        case .screenshots:
            return language == .indonesian ? "Tangkapan Layar & Desain" : "Screenshots & Design"
        case .code:
            return language == .indonesian ? "Kode & Proyek" : "Code & Development"
        case .media:
            return language == .indonesian ? "Media & Hiburan" : "Media & Entertainment"
        case .archives:
            return language == .indonesian ? "Arsip & Installer" : "Archives & Installers"
        case .other:
            return language == .indonesian ? "Lain-lain" : "Miscellaneous"
        }
    }
    
    public var folderName: String {
        switch self {
        case .finance: return "Finance"
        case .documents: return "Documents"
        case .screenshots: return "Screenshots"
        case .code: return "Code"
        case .media: return "Media"
        case .archives: return "Archives"
        case .other: return "Miscellaneous"
        }
    }
    
    public var icon: String {
        switch self {
        case .finance: return "banknote.fill"
        case .documents: return "doc.text.fill"
        case .screenshots: return "camera.metering.spot"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .media: return "play.square.stack.fill"
        case .archives: return "shippingbox.fill"
        case .other: return "folder.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .finance: return .green
        case .documents: return .blue
        case .screenshots: return .purple
        case .code: return .orange
        case .media: return .pink
        case .archives: return .yellow
        case .other: return .gray
        }
    }
}
