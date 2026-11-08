import SwiftUI
import AppKit

public struct HistoryView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @State private var selectedItemIDs: Set<UUID> = []
    
    public init() {}
    
    private var activeItems: [OrganizedItem] {
        engine.history.filter { !$0.wasUndone }
    }
    
    private var areAllSelected: Bool {
        !activeItems.isEmpty && selectedItemIDs.count >= activeItems.count
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(l10n.localized("history_title"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(l10n.language == .indonesian ? "Setiap perpindahan file dapat dipilih dan dikembalikan ke lokasi asal kapan saja." : "Select and restore files back to their original locations at any time.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !engine.history.isEmpty {
                    Button(action: engine.clearHistory) {
                        Label(l10n.localized("clear_history"), systemImage: "trash")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // Action & Selection Toolbar
            if !activeItems.isEmpty {
                HStack(spacing: 10) {
                    // Select All / Deselect All
                    Button(action: toggleSelectAll) {
                        HStack(spacing: 6) {
                            Image(systemName: areAllSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(areAllSelected ? .blue : .secondary)
                            Text(areAllSelected ? l10n.localized("deselect_all") : l10n.localized("select_all"))
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    // Restore Selected
                    if !selectedItemIDs.isEmpty {
                        Button(action: restoreSelected) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                Text("\(l10n.localized("restore_selected")) (\(selectedItemIDs.count))")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    
                    Spacer()
                    
                    // Restore All
                    Button(action: restoreAll) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text(l10n.localized("restore_all"))
                                .font(.system(size: 12))
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(.horizontal, 2)
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
        let isSelected = selectedItemIDs.contains(item.id)
        
        return HStack(spacing: 12) {
            // Selection Checkbox (only for active items)
            if !item.wasUndone {
                Button(action: { toggleSelection(for: item.id) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .blue : .secondary.opacity(0.6))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.4))
                    .frame(width: 16)
            }
            
            // Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.category.color.opacity(item.wasUndone ? 0.05 : 0.12))
                    .frame(width: 38, height: 38)
                
                Image(systemName: item.category.icon)
                    .font(.system(size: 17))
                    .foregroundColor(item.wasUndone ? .secondary : item.category.color)
            }
            
            // File Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(item.fileName)
                        .font(.system(size: 13, weight: .medium))
                        .strikethrough(item.wasUndone, color: .secondary)
                        .foregroundColor(item.wasUndone ? .secondary : .primary)
                    
                    Text(item.category.title(for: l10n.language))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(item.wasUndone ? .secondary : item.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((item.wasUndone ? Color.secondary : item.category.color).opacity(0.12))
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
            
            // Open in Finder & Single Restore
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
                
                Button(action: {
                    selectedItemIDs.remove(item.id)
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
                .fill(isSelected ? Color.blue.opacity(0.08) : Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Actions
    private func toggleSelection(for id: UUID) {
        if selectedItemIDs.contains(id) {
            selectedItemIDs.remove(id)
        } else {
            selectedItemIDs.insert(id)
        }
    }
    
    private func toggleSelectAll() {
        if areAllSelected {
            selectedItemIDs.removeAll()
        } else {
            selectedItemIDs = Set(activeItems.map { $0.id })
        }
    }
    
    private func restoreSelected() {
        engine.undoBatch(ids: selectedItemIDs)
        selectedItemIDs.removeAll()
    }
    
    private func restoreAll() {
        engine.undoAll()
        selectedItemIDs.removeAll()
    }
}
