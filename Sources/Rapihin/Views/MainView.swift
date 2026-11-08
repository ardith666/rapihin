import SwiftUI
import AppKit
import Charts

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
                sidebarItem(title: l10n.localized("tab_about"), icon: "info.circle.fill", tag: 4)
                
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
                case 4:
                    AboutView()
                default:
                    dashboardContent
                }
            }
            .frame(minWidth: 560, minHeight: 520)
        }
    }
    
    // MARK: - Dashboard Content
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 18) {
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
                
                // Work Analytics & Stats
                workAnalyticsSection
            }
            .padding(22)
        }
    }
    
    // MARK: - Analytics Section
    private var workAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(l10n.localized("work_analytics"), systemImage: "chart.pie.fill")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
            }
            
            // KPI Stat Cards Row
            HStack(spacing: 12) {
                statCard(
                    title: l10n.localized("stat_total_organized"),
                    value: "\(engine.activeHistoryCount)",
                    icon: "doc.on.doc.fill",
                    color: .blue
                )
                
                statCard(
                    title: l10n.localized("stat_volume"),
                    value: engine.formattedTotalSize,
                    icon: "internaldrive.fill",
                    color: .purple
                )
                
                statCard(
                    title: l10n.localized("stat_time_saved"),
                    value: engine.estimatedTimeSavedString,
                    icon: "clock.badge.checkmark.fill",
                    color: .green
                )
            }
            
            // Category Distribution Chart & Legend Card
            let breakdown = engine.categoryBreakdown
            if !breakdown.isEmpty {
                HStack(spacing: 20) {
                    // Donut Chart
                    Chart(breakdown) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.62),
                            angularInset: 2.0
                        )
                        .cornerRadius(4)
                        .foregroundStyle(item.category.color)
                    }
                    .frame(width: 140, height: 140)
                    .chartLegend(.hidden)
                    
                    // Legend & Breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(breakdown) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.category.color)
                                    .frame(width: 8, height: 8)
                                
                                Text(item.category.title(for: l10n.language))
                                    .font(.system(size: 12, weight: .medium))
                                
                                Spacer()
                                
                                Text("\(item.count)")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(item.category.color.opacity(0.12))
                                    .foregroundColor(item.category.color)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            } else {
                // Empty state for chart
                HStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                    
                    Text(l10n.localized("no_data_chart"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                )
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(title)
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
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
