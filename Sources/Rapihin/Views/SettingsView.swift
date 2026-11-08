import SwiftUI
import AppKit

public struct SettingsView: View {
    @ObservedObject var engine = OrganizerEngine.shared
    @ObservedObject var l10n = LocalizationManager.shared
    @ObservedObject var autostart = AutostartManager.shared
    
    public init() {}
    
    public var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label(l10n.localized("settings_general"), systemImage: "gearshape")
                }
            
            sortingTab
                .tabItem {
                    Label(l10n.localized("settings_sorting"), systemImage: "arrow.up.arrow.down.square")
                }
            
            categoriesTab
                .tabItem {
                    Label(l10n.localized("settings_categories"), systemImage: "sparkles")
                }
        }
        .frame(width: 580, height: 440)
        .padding(16)
    }
    
    // MARK: - General Tab
    private var generalTab: some View {
        Form {
            Section {
                // Language
                Picker(l10n.localized("settings_language"), selection: $l10n.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: l10n.language) { _, newLang in
                    engine.settings.language = newLang
                    engine.saveSettings()
                }
            } header: {
                Text(l10n.language == .indonesian ? "Bahasa & Tampilan" : "Language & Appearance")
            }
            
            Section {
                // Autostart at Login
                Toggle(isOn: Binding(
                    get: { autostart.isEnabled },
                    set: { autostart.setEnabled($0) }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.localized("settings_autostart"))
                        Text(l10n.localized("settings_autostart_desc"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Start Minimized
                Toggle(isOn: $engine.settings.startMinimized) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.localized("settings_start_minimized"))
                        Text(l10n.localized("settings_start_minimized_desc"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: engine.settings.startMinimized) { _, _ in
                    engine.saveSettings()
                }
            } header: {
                Text(l10n.language == .indonesian ? "Mulai Otomatis (Startup)" : "Startup Options")
            }
            
            Section {
                Toggle(l10n.localized("settings_sounds"), isOn: $engine.settings.playSounds)
                    .onChange(of: engine.settings.playSounds) { _, _ in engine.saveSettings() }
                Toggle(l10n.localized("settings_haptics"), isOn: $engine.settings.hapticFeedback)
                    .onChange(of: engine.settings.hapticFeedback) { _, _ in engine.saveSettings() }
            } header: {
                Text(l10n.language == .indonesian ? "Umpan Balik" : "Feedback")
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Sorting & Structure Tab
    private var sortingTab: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.localized("default_target"))
                        Text(engine.settings.destinationBaseFolder)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Button(l10n.localized("change_target"), action: chooseTargetDirectory)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                
                Picker(l10n.localized("subfolder_structure"), selection: $engine.settings.subfolderStructure) {
                    ForEach(SubfolderStructure.allCases) { item in
                        Text(item.label(for: l10n.language)).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: engine.settings.subfolderStructure) { _, _ in engine.saveSettings() }
                
                Picker(l10n.localized("sort_strategy"), selection: $engine.settings.sortStrategy) {
                    ForEach(SortStrategy.allCases) { item in
                        Text(item.label(for: l10n.language)).tag(item)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: engine.settings.sortStrategy) { _, _ in engine.saveSettings() }
            } header: {
                Text(l10n.language == .indonesian ? "Lokasi & Hierarki" : "Location & Hierarchy")
            }
            
            Section {
                Toggle(l10n.localized("prefix_date"), isOn: $engine.settings.prefixDateToName)
                    .onChange(of: engine.settings.prefixDateToName) { _, _ in engine.saveSettings() }
                
                Toggle(l10n.localized("clean_file_names"), isOn: $engine.settings.cleanFileNames)
                    .onChange(of: engine.settings.cleanFileNames) { _, _ in engine.saveSettings() }
            } header: {
                Text(l10n.language == .indonesian ? "Format Penamaan File" : "File Name Formatting")
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Categories & AI Tab
    private var categoriesTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Status Card
            HStack(spacing: 12) {
                Image(systemName: "apple.terminal.on.rectangle")
                    .font(.system(size: 26))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.localized("local_ai_status"))
                        .font(.system(size: 13, weight: .semibold))
                    Text(l10n.localized("no_download_needed"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))
            )
            
            Text(l10n.localized("categories_desc"))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(FileCategory.allCases) { category in
                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16))
                                .foregroundColor(category.color)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.title(for: l10n.language))
                                    .font(.system(size: 13, weight: .medium))
                                Text("Folder: \(category.folderName)")
                                    .font(.system(size: 10.5))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        )
                    }
                }
            }
        }
        .padding(16)
    }
    
    private func chooseTargetDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = l10n.language == .indonesian ? "Pilih Target" : "Select Target"
        
        if panel.runModal() == .OK, let url = panel.url {
            engine.settings.destinationBaseFolder = url.path
            engine.saveSettings()
        }
    }
}
