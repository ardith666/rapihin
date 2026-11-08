import SwiftUI
import AppKit

public struct MenuBarView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 22, height: 22)
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(l10n.localized("app_name"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                
                Spacer()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                Text(l10n.localized("permission_granted"))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 2)
            
            Divider()
            
            // Status & Quick Action
            VStack(alignment: .leading, spacing: 6) {
                if engine.pendingFilesCount > 0 {
                    Text(String(format: l10n.localized("pending_files_count"), engine.pendingFilesCount))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.orange)
                } else {
                    Text(l10n.localized("no_pending_files"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    Task {
                        await engine.tidyAllNow()
                    }
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text(l10n.localized("quick_tidy_button"))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(engine.isProcessing)
            }
            
            Divider()
            
            // App Actions
            Button(action: {
                NSApp.activate(ignoringOtherApps: true)
                for window in NSApp.windows {
                    window.makeKeyAndOrderFront(nil)
                }
            }) {
                Label(l10n.localized("menubar_open"), systemImage: "macwindow")
            }
            .buttonStyle(.plain)
            
            if let firstFolder = engine.monitoredFolders.first {
                Button(action: {
                    NSWorkspace.shared.open(firstFolder.url)
                }) {
                    Label(firstFolder.name, systemImage: "folder")
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Label(l10n.localized("menubar_quit"), systemImage: "power")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 250)
    }
}
