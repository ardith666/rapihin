import SwiftUI
import AppKit

@main
struct RapihinApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var engine = OrganizerEngine.shared
    @StateObject private var l10n = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(engine)
                .environmentObject(l10n)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 820, height: 560)
        
        MenuBarExtra("Rapihin", systemImage: "sparkles") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
                .environmentObject(engine)
                .environmentObject(l10n)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        
        // If start minimized is set, order out windows initially
        if OrganizerEngine.shared.settings.startMinimized {
            for window in NSApp.windows {
                window.orderOut(nil)
            }
        }
    }
}
