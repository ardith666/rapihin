import Foundation
import UniformTypeIdentifiers
import Vision
import PDFKit
import NaturalLanguage

public final class AIClassifier: @unchecked Sendable {
    public static let shared = AIClassifier()
    
    private init() {}
    
    // MARK: - Classify File
    public func classify(url: URL) async -> FileCategory {
        let fileName = url.lastPathComponent.lowercased()
        let pathExtension = url.pathExtension.lowercased()
        
        // 1. Direct Extension & UTType Checks (Ultra Fast)
        if isCodeFile(extension: pathExtension) {
            return .code
        }
        
        if isArchiveOrInstaller(extension: pathExtension) {
            return .archives
        }
        
        if isMediaFile(extension: pathExtension) {
            return .media
        }
        
        // 2. Screenshot Detection (Name + Image type)
        if isScreenshot(fileName: fileName, extension: pathExtension) {
            return .screenshots
        }
        
        // 3. Inspect Text & PDF Content (Deep AI Semantic Analysis)
        if pathExtension == "pdf" {
            let extractedText = extractText(fromPDF: url)
            if let semanticCat = analyzeSemanticText(extractedText, fileName: fileName) {
                return semanticCat
            }
            return .documents
        }
        
        // 4. Image OCR via Vision Framework (Receipts, Invoices, Slips)
        if isImageFile(extension: pathExtension) {
            let ocrText = await performOCR(on: url)
            if let semanticCat = analyzeSemanticText(ocrText, fileName: fileName) {
                return semanticCat
            }
            // If image is not a receipt/invoice/document, check if it looks like a screenshot
            if fileName.contains("screen") || fileName.contains("shot") || fileName.contains("tangkapan") {
                return .screenshots
            }
            return .media
        }
        
        // 5. Plain Text / Markdown / Office Documents
        if isTextDocument(extension: pathExtension) {
            let content = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
            let sample = String(content.prefix(2000))
            if let semanticCat = analyzeSemanticText(sample, fileName: fileName) {
                return semanticCat
            }
            return .documents
        }
        
        // 6. Name Heuristic Fallback
        if let semanticCat = analyzeSemanticText(fileName, fileName: fileName) {
            return semanticCat
        }
        
        return .other
    }
    
    // MARK: - Semantic Text Analysis
    private func analyzeSemanticText(_ text: String, fileName: String) -> FileCategory? {
        let normalized = (text + " " + fileName)
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .lowercased()
        
        // Financial & Invoice Keywords (Indonesian & English)
        let financeKeywords = [
            "invoice", "kwitansi", "receipt", "faktur", "bukti transfer", "bca", "mandiri", "bni", "bri",
            "pembayaran", "payment", "tagihan", "billing", "rekening", "statement", "tax", "pajak",
            "slip gaji", "payroll", "salary", "expense", "biaya", "total bayar", "subtotal", "transaksi",
            "order #", "pesanan #", "shopee", "tokopedia", "grab", "gojek"
        ]
        
        for kw in financeKeywords {
            if normalized.contains(kw) {
                return .finance
            }
        }
        
        // Documents & Work Keywords
        let docKeywords = [
            "perjanjian", "kontrak", "contract", "agreement", "proposal", "skripsi", "thesis",
            "surat", "letter", "curriculum vitae", "resume", "ktp", "paspor", "passport", "sertifikat",
            "certificate", "laporan", "report", "memo", "notula", "minutes", "nda", "policy"
        ]
        
        for kw in docKeywords {
            if normalized.contains(kw) {
                return .documents
            }
        }
        
        // Design & UI Keywords
        let designKeywords = [
            "wireframe", "mockup", "ui", "ux", "figma", "dribbble", "palette", "typography",
            "asset", "banner", "poster", "flyer", "logo", "icon"
        ]
        
        for kw in designKeywords {
            if normalized.contains(kw) {
                return .screenshots
            }
        }
        
        return nil
    }
    
    // MARK: - Native OCR via Vision
    private func performOCR(on url: URL) async -> String {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let image = NSImage(contentsOf: url),
                      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    continuation.resume(returning: "")
                    return
                }
                
                let request = VNRecognizeTextRequest { request, error in
                    guard error == nil,
                          let observations = request.results as? [VNRecognizedTextObservation] else {
                        continuation.resume(returning: "")
                        return
                    }
                    
                    let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                    continuation.resume(returning: recognizedStrings.joined(separator: " "))
                }
                
                request.recognitionLevel = .fast
                request.recognitionLanguages = ["id-ID", "en-US"]
                request.usesLanguageCorrection = true
                
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                try? handler.perform([request])
            }
        }
    }
    
    // MARK: - PDF Content Extractor
    private func extractText(fromPDF url: URL) -> String {
        guard let doc = PDFDocument(url: url) else { return "" }
        let pageCount = min(doc.pageCount, 3) // Inspect first 3 pages
        var extracted = ""
        for i in 0..<pageCount {
            if let page = doc.page(at: i), let pageText = page.string {
                extracted += pageText + " "
            }
        }
        return extracted
    }
    
    // MARK: - File Extension Matchers
    private func isCodeFile(extension ext: String) -> Bool {
        let codeExtensions = [
            "swift", "js", "ts", "jsx", "tsx", "py", "html", "css", "scss",
            "json", "yaml", "yml", "xml", "sh", "zsh", "bash", "c", "cpp", "h",
            "hpp", "rs", "go", "php", "java", "kt", "sql", "rb", "lua"
        ]
        return codeExtensions.contains(ext)
    }
    
    private func isArchiveOrInstaller(extension ext: String) -> Bool {
        let archiveExtensions = [
            "zip", "tar", "gz", "tgz", "rar", "7z", "dmg", "pkg", "iso", "appzip"
        ]
        return archiveExtensions.contains(ext)
    }
    
    private func isMediaFile(extension ext: String) -> Bool {
        let mediaExtensions = [
            "mp4", "mov", "mkv", "avi", "webm", "mp3", "wav", "m4a", "aac", "flac", "ogg"
        ]
        return mediaExtensions.contains(ext)
    }
    
    private func isImageFile(extension ext: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "webp", "heic", "tiff", "bmp", "gif"]
        return imageExtensions.contains(ext)
    }
    
    private func isScreenshot(fileName: String, extension ext: String) -> Bool {
        guard isImageFile(extension: ext) else { return false }
        let lower = fileName.lowercased()
        return lower.contains("screen shot") ||
               lower.contains("screenshot") ||
               lower.contains("tangkapan layar") ||
               lower.contains("captura de pantalla") ||
               lower.hasPrefix("cleanshot") ||
               lower.hasPrefix("shot_")
    }
    
    private func isTextDocument(extension ext: String) -> Bool {
        let docExtensions = ["txt", "md", "rtf", "doc", "docx", "pages", "xls", "xlsx", "csv", "ppt", "pptx", "key"]
        return docExtensions.contains(ext)
    }
}
