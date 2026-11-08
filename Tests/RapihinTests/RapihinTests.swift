import Testing
import Foundation
import SwiftUI
import AppKit
@testable import Rapihin

@Suite("Rapihin Core Test Suite")
struct RapihinTests {

    @Test("Test Localization Switching")
    @MainActor
    func testLocalization() {
        let l10n = LocalizationManager.shared
        
        l10n.language = .indonesian
        #expect(l10n.localized("app_name") == "Rapihin")
        #expect(l10n.localized("tab_dashboard") == "Beranda")
        #expect(l10n.localized("mode_auto") == "Otomatis (Real-time)")
        
        l10n.language = .english
        #expect(l10n.localized("tab_dashboard") == "Dashboard")
        #expect(l10n.localized("mode_auto") == "Automatic (Real-time)")
        
        // Reset to Indonesian
        l10n.language = .indonesian
    }

    @Test("Test AI Classifier for Code, Media, Archives, and Screenshots")
    func testClassificationExtensions() async {
        let classifier = AIClassifier.shared
        
        let codeURL = URL(fileURLWithPath: "/tmp/AppController.swift")
        let codeCat = await classifier.classify(url: codeURL)
        #expect(codeCat == .code)
        
        let pyURL = URL(fileURLWithPath: "/tmp/script.py")
        let pyCat = await classifier.classify(url: pyURL)
        #expect(pyCat == .code)
        
        let archiveURL = URL(fileURLWithPath: "/tmp/archive.zip")
        let archiveCat = await classifier.classify(url: archiveURL)
        #expect(archiveCat == .archives)
        
        let dmgURL = URL(fileURLWithPath: "/tmp/Installer.dmg")
        let dmgCat = await classifier.classify(url: dmgURL)
        #expect(dmgCat == .archives)
        
        let mediaURL = URL(fileURLWithPath: "/tmp/podcast.mp3")
        let mediaCat = await classifier.classify(url: mediaURL)
        #expect(mediaCat == .media)
        
        let screenshotURL = URL(fileURLWithPath: "/tmp/Screen Shot 2026-11-08 at 20.png")
        let screenshotCat = await classifier.classify(url: screenshotURL)
        #expect(screenshotCat == .screenshots)
    }

    @Test("Test Semantic Financial Keywords Detection")
    func testFinancialKeywordClassification() async {
        let classifier = AIClassifier.shared
        
        let invoiceURL = URL(fileURLWithPath: "/tmp/Invoice_Apple_Store_Nov2026.pdf")
        let invoiceCat = await classifier.classify(url: invoiceURL)
        #expect(invoiceCat == .finance)
        
        let transferURL = URL(fileURLWithPath: "/tmp/Bukti_Transfer_BCA_12345.png")
        let transferCat = await classifier.classify(url: transferURL)
        #expect(transferCat == .finance)
        
        let gajiURL = URL(fileURLWithPath: "/tmp/Slip_Gaji_Karyawan.txt")
        let gajiCat = await classifier.classify(url: gajiURL)
        #expect(gajiCat == .finance)
    }

    @Test("Test MonitoredFolder and Settings Serialization")
    func testSerialization() throws {
        let folder = MonitoredFolder(
            path: "/Users/test/Downloads",
            name: "Downloads",
            isAuto: true,
            hasPermission: true
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(folder)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MonitoredFolder.self, from: data)
        
        #expect(decoded.name == "Downloads")
        #expect(decoded.isAuto == true)
        #expect(decoded.hasPermission == true)
    }

    @Test("Test In-Place Organization & Category Only Default")
    @MainActor
    func testInPlaceDefaults() async {
        let engine = OrganizerEngine.shared
        #expect(engine.settings.subfolderStructure == .categoryOnly)
        
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Create sample file
        let sampleFile = tempDir.appendingPathComponent("Test_Invoice_Receipt.pdf")
        try? "Sample Invoice Content".write(to: sampleFile, atomically: true, encoding: .utf8)
        
        let success = await engine.organizeSingleFile(sampleFile, from: nil)
        #expect(success == true)
        
        // The file should stay inside tempDir in the Finance subfolder!
        let expectedSubfolder = tempDir.appendingPathComponent("Finance")
        let destinationFile = expectedSubfolder.appendingPathComponent("Test_Invoice_Receipt.pdf")
        #expect(FileManager.default.fileExists(atPath: destinationFile.path))
        
        // Test Batch Undo
        if let record = engine.history.first(where: { $0.newPath == destinationFile.path }) {
            engine.undoBatch(ids: [record.id])
            #expect(FileManager.default.fileExists(atPath: sampleFile.path))
            #expect(!FileManager.default.fileExists(atPath: destinationFile.path))
        }
        
        try? FileManager.default.removeItem(at: tempDir)
    }

    @Test("Generate Real Screenshots for Documentation")
    @MainActor
    func generateDocumentationScreenshots() {
        let assetsDir = "docs/screenshots"
        try? FileManager.default.createDirectory(atPath: assetsDir, withIntermediateDirectories: true, attributes: nil)
        
        func saveSnapshot<V: View>(_ view: V, size: CGSize, name: String) {
            let hosting = NSHostingView(rootView: view.frame(width: size.width, height: size.height))
            hosting.frame = CGRect(origin: .zero, size: size)
            hosting.layoutSubtreeIfNeeded()
            
            if let bitmapRep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) {
                hosting.cacheDisplay(in: hosting.bounds, to: bitmapRep)
                if let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                    let fileURL = URL(fileURLWithPath: "\(assetsDir)/\(name).png")
                    try? pngData.write(to: fileURL)
                }
            }
        }
        
        saveSnapshot(MainView(), size: CGSize(width: 820, height: 560), name: "dashboard")
        saveSnapshot(FolderManagementView(), size: CGSize(width: 700, height: 480), name: "folders")
        saveSnapshot(SettingsView(), size: CGSize(width: 580, height: 440), name: "settings")
        saveSnapshot(HistoryView(), size: CGSize(width: 700, height: 480), name: "history")
        saveSnapshot(MenuBarView(), size: CGSize(width: 260, height: 280), name: "menubar")
        saveSnapshot(AboutView(), size: CGSize(width: 580, height: 500), name: "about")
    }
}
