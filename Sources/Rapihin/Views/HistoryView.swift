import SwiftUI
import AppKit

public struct HistoryView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.localized("history_title"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(l10n.language == .indonesian ? "Setiap perpindahan file dapat dibatalkan (Undo) kapan saja." : "Every file movement can be undone at any time.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !engine.history.isEmpty {
                    Button(l10n.localized("clear_history"), action: engine.clearHistory)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
            
            Divider()
            
            // History List
            if engine.history.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text(l10n.localized("history_empty"))
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(engine.history) { item in
                            historyRow(for: item)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20)
    }
    
    private func historyRow(for item: OrganizedItem) -> some View {
        HStack(spacing: 14) {
            // Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.category.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(item.category.color)
            }
            
            // File Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(item.fileName)
                        .font(.system(size: 13, weight: .medium))
                        .strikethrough(item.wasUndone, color: .secondary)
                    
                    Text(item.category.title(for: l10n.language))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(item.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.category.color.opacity(0.12))
                        .cornerRadius(6)
                }
                
                HStack(spacing: 8) {
                    Text(item.formattedSize)
                    Text("•")
                    Text(item.timestamp, style: .relative)
                    if item.wasUndone {
                        Text("•")
                        Text(l10n.language == .indonesian ? "Sudah Dikembalikan" : "Restored")
                            .foregroundColor(.orange)
                    }
                }
                .font(.system(size: 10.5))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Open in Finder
            if !item.wasUndone {
                Button(action: {
                    let url = URL(fileURLWithPath: item.newPath)
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }) {
                    Image(systemName: "folder")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .help(l10n.localized("open_folder"))
                
                // Undo Button
                Button(action: {
                    engine.undo(item: item)
                }) {
                    Label(l10n.localized("undo_button"), systemImage: "arrow.uturn.backward")
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}
