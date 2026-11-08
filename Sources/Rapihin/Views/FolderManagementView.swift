import SwiftUI
import AppKit

public struct FolderManagementView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @State private var showingAddFolderPicker: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.localized("monitored_folders"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(l10n.language == .indonesian ? "Kelola izin folder dan tentukan mode otomatis atau manual untuk setiap lokasi." : "Manage folder permissions and configure real-time automatic or manual tidy modes.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: selectNewFolder) {
                    Label(l10n.localized("add_folder"), systemImage: "plus.circle.fill")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            
            Divider()
            
            // Folder List
            if engine.monitoredFolders.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(l10n.language == .indonesian ? "Belum ada folder yang dipantau" : "No folders monitored yet")
                        .font(.system(size: 14, weight: .medium))
                    Button(l10n.localized("add_folder"), action: selectNewFolder)
                        .buttonStyle(.bordered)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(engine.monitoredFolders) { folder in
                            folderRow(for: folder)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20)
    }
    
    private func folderRow(for folder: MonitoredFolder) -> some View {
        HStack(spacing: 16) {
            // Folder Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(folder.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    
                    // Permission Badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(folder.hasPermission ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        Text(folder.hasPermission ? l10n.localized("permission_granted") : l10n.localized("permission_needed"))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(folder.hasPermission ? .green : .orange)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background((folder.hasPermission ? Color.green : Color.orange).opacity(0.1))
                    .cornerRadius(6)
                }
                
                Text(folder.path)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // Auto vs Manual Toggle
            VStack(alignment: .trailing, spacing: 2) {
                Picker("", selection: Binding(
                    get: { folder.isAuto },
                    set: { _ in engine.toggleFolderMode(id: folder.id) }
                )) {
                    Text(l10n.localized("mode_auto")).tag(true)
                    Text(l10n.localized("mode_manual")).tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
                
                Text(folder.isAuto ? l10n.localized("mode_auto_desc") : l10n.localized("mode_manual_desc"))
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
            }
            
            // Open in Finder
            Button(action: {
                NSWorkspace.shared.open(URL(fileURLWithPath: folder.path))
            }) {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .help(l10n.localized("open_folder"))
            
            // Remove
            Button(action: {
                engine.removeFolder(id: folder.id)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
            .help(l10n.localized("remove_folder"))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private func selectNewFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = l10n.language == .indonesian ? "Pilih & Beri Izin" : "Choose & Grant Access"
        panel.message = l10n.language == .indonesian ? "Pilih folder yang ingin dipantau dan dirapikan oleh Rapihin" : "Select a folder for Rapihin to monitor and organize"
        
        if panel.runModal() == .OK, let url = panel.url {
            engine.addFolder(url: url, isAuto: false)
        }
    }
}
