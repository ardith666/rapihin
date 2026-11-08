import SwiftUI
import AppKit

public struct MainView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar Navigation
            VStack(alignment: .leading, spacing: 6) {
                // App Branding Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(l10n.localized("app_name"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Text("macOS Native AI")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                
                Divider()
                    .padding(.bottom, 6)
                
                // Nav Items
                sidebarItem(title: l10n.localized("tab_dashboard"), icon: "square.grid.2x2.fill", tag: 0)
                sidebarItem(title: l10n.localized("tab_folders"), icon: "folder.fill.badge.gearshape", tag: 1, badge: "\(engine.monitoredFolders.count)")
                sidebarItem(title: l10n.localized("tab_history"), icon: "clock.arrow.circlepath", tag: 2, badge: engine.history.isEmpty ? nil : "\(engine.history.count)")
                sidebarItem(title: l10n.localized("tab_settings"), icon: "gearshape.fill", tag: 3)
                
                Spacer()
                
                // Status Pill at Bottom of Sidebar
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text(l10n.localized("auto_watching_active"))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.08))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }
            .frame(minWidth: 200, idealWidth: 220)
            .background(.ultraThinMaterial)
        } detail: {
            // Main Content Area
            Group {
                switch selectedTab {
                case 0:
                    dashboardContent
                case 1:
                    FolderManagementView()
                case 2:
                    HistoryView()
                case 3:
                    SettingsView()
                default:
                    dashboardContent
                }
            }
            .frame(minWidth: 540, minHeight: 460)
        }
    }
    
    // MARK: - Dashboard Content
    private var dashboardContent: some View {
        VStack(spacing: 20) {
            // Top Status Bar
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(l10n.localized("app_tagline"))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    if engine.pendingFilesCount > 0 {
                        Text(String(format: l10n.localized("pending_files_count"), engine.pendingFilesCount))
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    } else {
                        Text(l10n.localized("no_pending_files"))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await engine.tidyAllNow()
                    }
                }) {
                    HStack(spacing: 6) {
                        if engine.isProcessing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(l10n.localized("quick_tidy_button"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .disabled(engine.isProcessing)
                .controlSize(.regular)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            
            // Drop Zone
            DropZoneView()
            
            // Quick Info & Target Bar
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "folder.badge.gearshape")
                        .foregroundColor(.blue)
                    Text("\(l10n.localized("target_directory")): \(engine.settings.destinationBaseFolder)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                Button(action: {
                    let url = URL(fileURLWithPath: (engine.settings.destinationBaseFolder as NSString).expandingTildeInPath)
                    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                    NSWorkspace.shared.open(url)
                }) {
                    Label(l10n.localized("open_folder"), systemImage: "arrow.up.forward.app")
                        .font(.system(size: 11))
                }
                .buttonStyle(.link)
            }
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(22)
    }
    
    private func sidebarItem(title: String, icon: String, tag: Int, badge: String? = nil) -> some View {
        Button(action: { selectedTab = tag }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(selectedTab == tag ? .blue : .secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13, weight: selectedTab == tag ? .semibold : .regular))
                    .foregroundColor(selectedTab == tag ? .primary : .secondary)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(selectedTab == tag ? Color.blue.opacity(0.15) : Color.secondary.opacity(0.15))
                        .foregroundColor(selectedTab == tag ? .blue : .secondary)
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == tag ? Color.blue.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }
}
