import SwiftUI
import AppKit

public struct AboutView: View {
    @ObservedObject var updater = UpdateManager.shared
    @ObservedObject var l10n = LocalizationManager.shared
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with App Icon & Version
                VStack(spacing: 10) {
                    if let appIcon = NSImage(named: "AppIcon") {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    } else {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 72, height: 72)
                            Image(systemName: "sparkles")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    VStack(spacing: 3) {
                        Text(l10n.localized("app_name"))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        
                        Text("Versi \(updater.currentVersion) (Build \(updater.currentBuild))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(l10n.localized("app_tagline"))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                }
                .padding(.top, 10)
                
                // Update Check Box
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(l10n.language == .indonesian ? "Status Pembaruan Aplikasi" : "Application Update Status")
                                .font(.system(size: 13, weight: .semibold))
                            
                            if let msg = updater.statusMessage {
                                Text(msg)
                                    .font(.system(size: 11))
                                    .foregroundColor(updater.isUpdateAvailable ? .blue : .secondary)
                            } else if let last = updater.lastChecked {
                                Text("\(l10n.language == .indonesian ? "Terakhir diperiksa:" : "Last checked:") \(last.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            } else {
                                Text(l10n.language == .indonesian ? "Otomatis memeriksa rilis terbaru dari GitHub." : "Automatically checks for releases from GitHub.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if updater.isUpdateAvailable {
                            Button(action: updater.openDownloadPage) {
                                Label(l10n.language == .indonesian ? "Unduh v\(updater.latestVersion)" : "Download v\(updater.latestVersion)", systemImage: "arrow.down.circle.fill")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button(action: {
                                Task {
                                    await updater.checkForUpdates()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    if updater.isChecking {
                                        ProgressView()
                                            .controlSize(.small)
                                    } else {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                    }
                                    Text(l10n.language == .indonesian ? "Periksa Pembaruan" : "Check for Updates")
                                        .font(.system(size: 12))
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(updater.isChecking)
                        }
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                
                // Changelog Section
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label(l10n.language == .indonesian ? "Catatan Rilis (Changelog)" : "Release Notes (Changelog)", systemImage: "list.bullet.rectangle.portrait.fill")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    
                    ForEach(updater.changelogHistory) { release in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(release.version)
                                    .font(.system(size: 13, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                                
                                Text("• \(release.date)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(release.highlights, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(.blue)
                                        Text(item)
                                            .font(.system(size: 11.5))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.leading, 4)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
                        )
                    }
                }
                
                // Footer & Links
                VStack(spacing: 6) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 16) {
                        Button("GitHub Repository") {
                            NSWorkspace.shared.open(URL(string: "https://github.com/ardith666/rapihin")!)
                        }
                        .buttonStyle(.link)
                        .font(.system(size: 11))
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Button(l10n.language == .indonesian ? "Halaman Rilis" : "Releases") {
                            NSWorkspace.shared.open(URL(string: "https://github.com/ardith666/rapihin/releases")!)
                        }
                        .buttonStyle(.link)
                        .font(.system(size: 11))
                    }
                    
                    Text("© 2026 ardith666. Dilisensikan di bawah MIT License.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
            }
            .padding(20)
        }
    }
}
