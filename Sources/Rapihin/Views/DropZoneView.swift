import SwiftUI
import UniformTypeIdentifiers

public struct DropZoneView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @State private var isTargeted: Bool = false
    @State private var isAnimating: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: isTargeted ? [.blue, .purple] : [Color.white.opacity(0.18), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isTargeted ? 2.5 : 1
                        )
                )
                .shadow(color: isTargeted ? .blue.opacity(0.25) : .black.opacity(0.04), radius: 12, x: 0, y: 6)
            
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isTargeted ? [.blue.opacity(0.3), .purple.opacity(0.2)] : [.blue.opacity(0.12), .blue.opacity(0.04)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: isTargeted ? "arrow.down.circle.fill" : "sparkles")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isTargeted ? 1.15 : 1.0)
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isTargeted)
                }
                
                VStack(spacing: 4) {
                    Text(l10n.localized("drop_title"))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    
                    Text(l10n.localized("drop_subtitle"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 32)
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url = url else { return }
                Task { @MainActor in
                    var isDir: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
                        if isDir.boolValue {
                            let folder = MonitoredFolder(path: url.path, name: url.lastPathComponent)
                            _ = await engine.organizeFilesInFolder(folder)
                        } else {
                            await engine.organizeSingleFile(url, from: nil)
                        }
                    }
                }
            }
        }
    }
}
