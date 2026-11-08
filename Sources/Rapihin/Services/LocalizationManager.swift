import Foundation
import SwiftUI
import Combine

@MainActor
public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    @Published public var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "app_language"),
           let lang = AppLanguage(rawValue: saved) {
            self.language = lang
        } else {
            // Default to Indonesian as requested by user
            self.language = .indonesian
        }
    }
    
    public func localized(_ key: String) -> String {
        switch language {
        case .indonesian:
            return indonesianTranslations[key] ?? key
        case .english:
            return englishTranslations[key] ?? key
        }
    }
    
    // MARK: - Indonesian Dictionary
    private let indonesianTranslations: [String: String] = [
        // App Core
        "app_name": "Rapihin",
        "app_tagline": "Perapih File Otomatis & Cerdas Berbasis AI macOS",
        
        // Navigation & Tabs
        "tab_dashboard": "Beranda",
        "tab_folders": "Kelola Folder",
        "tab_history": "Riwayat & Pulihkan",
        "tab_settings": "Pengaturan",
        "tab_about": "Tentang",
        
        // Dashboard / Drop Zone
        "drop_title": "Tarik File atau Folder ke Sini",
        "drop_subtitle": "AI bawaan Mac akan menganalisis konten dan merapikannya seketika",
        "quick_tidy_button": "Rapikan Sekarang",
        "pending_files_count": "%d file menunggu dirapikan",
        "no_pending_files": "Semua folder terpantau sudah rapi ✨",
        "auto_watching_active": "Pemantau Otomatis Aktif",
        "manual_mode_hint": "Mode Manual: Tekan 'Rapikan Sekarang' saat siap",
        "target_directory": "Target Folder Rapi",
        "open_folder": "Buka di Finder",
        
        // Folder Management
        "monitored_folders": "Daftar Folder Terpantau",
        "add_folder": "Tambah Folder...",
        "permission_granted": "Diizinkan",
        "permission_needed": "Butuh Izin",
        "grant_permission": "Beri Izin Akses",
        "mode_auto": "Otomatis (Real-time)",
        "mode_manual": "Manual (Klik)",
        "mode_auto_desc": "Setiap ada file baru masuk langsung dirapikan",
        "mode_manual_desc": "File hanya dirapikan saat Anda mengklik tombol",
        "remove_folder": "Hapus dari Pantauan",
        "folder_path": "Lokasi",
        "last_organized": "Terakhir Dirapikan",
        "never": "Belum Pernah",
        
        // Settings - General & Autostart
        "settings_general": "Umum & Mulai Otomatis",
        "settings_language": "Bahasa Aplikasi",
        "settings_autostart": "Mulai Otomatis saat Login (Launch at Login)",
        "settings_autostart_desc": "Aplikasi akan otomatis berjalan di latar belakang saat Mac menyala",
        "settings_start_minimized": "Mulai Senyap di Menu Bar",
        "settings_start_minimized_desc": "Sembunyikan jendela utama saat Mac login, hanya tampil di menu bar",
        "settings_sounds": "Efek Suara Selesai",
        "settings_haptics": "Umpan Balik Haptic Trackpad",
        
        // Settings - Sorting & Structure
        "settings_sorting": "Struktur & Pengurutan",
        "subfolder_structure": "Skema Subfolder",
        "sort_strategy": "Urutkan File Berdasarkan",
        "prefix_date": "Sematkan Tanggal di Nama File (YYYY-MM-DD)",
        "clean_file_names": "Bersihkan Nama File Otomatis (Hapus copy, (1), spasi berlebih)",
        "default_target": "Folder Induk Tujuan",
        "change_target": "Ubah...",
        
        // Settings - Categories & AI
        "settings_categories": "Kategori & AI",
        "categories_desc": "Pilih kategori yang ingin diaktifkan untuk pengelompokan otomatis",
        "local_ai_status": "Status AI Bawaan macOS: 100% On-Device (Apple Intelligence & Vision)",
        "no_download_needed": "Tanpa download model terpisah, hemat RAM & baterai.",
        
        // History & Undo
        "history_title": "Riwayat Perapihan",
        "history_empty": "Belum ada riwayat file yang dirapikan",
        "undo_button": "Kembalikan",
        "undo_success": "File berhasil dikembalikan ke lokasi semula",
        "clear_history": "Bersihkan Riwayat",
        "select_all": "Pilih Semua",
        "deselect_all": "Batal Pilih",
        "restore_selected": "Kembalikan Terpilih",
        "restore_all": "Kembalikan Semua",
        "total_organized": "Total File Dirapikan",
        "total_size": "Total Kapasitas",
        "in_place_info": "Berkas dirapikan langsung di foldernya masing-masing",
        
        // Work Analytics
        "work_analytics": "Analisis Hasil Kerja",
        "stat_total_organized": "Total Berkas",
        "stat_volume": "Kapasitas Tertata",
        "stat_time_saved": "Waktu Dihemat",
        "category_distribution": "Distribusi Kategori",
        "no_data_chart": "Belum ada data analisis. Rapikan berkas untuk melihat grafik.",
        
        // Menu Bar
        "menubar_open": "Buka Rapihin",
        "menubar_tidy_all": "Rapikan Semua Folder Sekarang",
        "menubar_quit": "Keluar dari Rapihin",
        
        // Alerts & Confirmation
        "folder_already_added": "Folder ini sudah ada dalam daftar pantauan.",
        "success_title": "Selesai Dirapikan",
        "success_body": "%d file berhasil dikelompokkan dengan rapi."
    ]
    
    // MARK: - English Dictionary
    private let englishTranslations: [String: String] = [
        // App Core
        "app_name": "Rapihin",
        "app_tagline": "Smart & Lightweight macOS AI File Organizer",
        
        // Navigation & Tabs
        "tab_dashboard": "Dashboard",
        "tab_folders": "Folders",
        "tab_history": "History & Undo",
        "tab_settings": "Settings",
        "tab_about": "About",
        
        // Dashboard / Drop Zone
        "drop_title": "Drop Files or Folders Here",
        "drop_subtitle": "Mac built-in AI will analyze content and organize them instantly",
        "quick_tidy_button": "Tidy Up Now",
        "pending_files_count": "%d files pending organization",
        "no_pending_files": "All monitored folders are tidy ✨",
        "auto_watching_active": "Real-Time Auto Watching Active",
        "manual_mode_hint": "Manual Mode: Click 'Tidy Up Now' when ready",
        "target_directory": "Target Directory",
        "open_folder": "Show in Finder",
        
        // Folder Management
        "monitored_folders": "Monitored Folders",
        "add_folder": "Add Folder...",
        "permission_granted": "Granted",
        "permission_needed": "Needs Permission",
        "grant_permission": "Grant Access",
        "mode_auto": "Automatic (Real-time)",
        "mode_manual": "Manual (On-demand)",
        "mode_auto_desc": "Immediately organizes newly arrived files",
        "mode_manual_desc": "Only organizes files when you click the button",
        "remove_folder": "Remove",
        "folder_path": "Path",
        "last_organized": "Last Organized",
        "never": "Never",
        
        // Settings - General & Autostart
        "settings_general": "General & Autostart",
        "settings_language": "App Language",
        "settings_autostart": "Launch at Login",
        "settings_autostart_desc": "Automatically run in the background when your Mac starts up",
        "settings_start_minimized": "Start Minimized in Menu Bar",
        "settings_start_minimized_desc": "Keep main window hidden at startup, running only in the menu bar",
        "settings_sounds": "Completion Sound Effects",
        "settings_haptics": "Trackpad Haptic Feedback",
        
        // Settings - Sorting & Structure
        "settings_sorting": "Structure & Sorting",
        "subfolder_structure": "Subfolder Scheme",
        "sort_strategy": "Sort Files By",
        "prefix_date": "Prefix Date to File Name (YYYY-MM-DD)",
        "clean_file_names": "Clean File Names Automatically (Strip (1), copy, extra spaces)",
        "default_target": "Main Destination Directory",
        "change_target": "Change...",
        
        // Settings - Categories & AI
        "settings_categories": "Categories & AI",
        "categories_desc": "Enable or disable categories used during smart classification",
        "local_ai_status": "macOS Native AI Status: 100% On-Device (Apple Intelligence & Vision)",
        "no_download_needed": "Zero external model download required, ultra-low RAM and battery impact.",
        
        // History & Undo
        "history_title": "Organization History",
        "history_empty": "No files have been organized yet",
        "undo_button": "Restore",
        "undo_success": "File successfully restored to original location",
        "clear_history": "Clear History",
        "select_all": "Select All",
        "deselect_all": "Deselect All",
        "restore_selected": "Restore Selected",
        "restore_all": "Restore All",
        "total_organized": "Total Files Organized",
        "total_size": "Total Volume",
        "in_place_info": "Files are organized directly in-place inside their respective folders",
        
        // Work Analytics
        "work_analytics": "Work Performance & Analytics",
        "stat_total_organized": "Total Files",
        "stat_volume": "Volume Sorted",
        "stat_time_saved": "Time Saved",
        "category_distribution": "Category Distribution",
        "no_data_chart": "No analytics yet. Organize files to view chart.",
        
        // Menu Bar
        "menubar_open": "Open Rapihin",
        "menubar_tidy_all": "Tidy All Folders Now",
        "menubar_quit": "Quit Rapihin",
        
        // Alerts & Confirmation
        "folder_already_added": "This folder is already in your monitored list.",
        "success_title": "Organization Complete",
        "success_body": "%d files have been organized neatly."
    ]
}

@MainActor
public func loc(_ key: String) -> String {
    LocalizationManager.shared.localized(key)
}
