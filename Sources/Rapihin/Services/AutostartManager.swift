import Foundation
import ServiceManagement

@MainActor
public final class AutostartManager: ObservableObject {
    public static let shared = AutostartManager()
    
    @Published public private(set) var isEnabled: Bool = false
    
    private init() {
        checkStatus()
    }
    
    public func checkStatus() {
        let status = SMAppService.mainApp.status
        isEnabled = (status == .enabled)
    }
    
    public func setEnabled(_ enable: Bool) {
        do {
            if enable {
                if SMAppService.mainApp.status == .enabled {
                    isEnabled = true
                    return
                }
                try SMAppService.mainApp.register()
                isEnabled = true
            } else {
                try SMAppService.mainApp.unregister()
                isEnabled = false
            }
        } catch {
            print("[AutostartManager] Failed to toggle autostart: \(error.localizedDescription)")
            checkStatus()
        }
    }
}
