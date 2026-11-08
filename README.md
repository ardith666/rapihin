<div align="center">

<img src="assets/AppIcon_1024.png" width="128" height="128" alt="Rapihin App Icon" style="border-radius: 28px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);"/>

# ✨ Rapihin.app
### *Smart, Ultra-Lightweight & Local-First File Organizer for macOS*
**Perapih File Otomatis Cerdas Berbasis AI Bawaan macOS & Apple Intelligence**

[![macOS](https://img.shields.io/badge/macOS-14.0%2B-black?style=for-the-badge&logo=apple)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-6.0%2B-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-M1%2FM2%2FM3%2FM4-000000?style=for-the-badge&logo=apple)](https://apple.com)
[![Binary Size](https://img.shields.io/badge/Binary_Size-~1.4_MB-success?style=for-the-badge)](https://github.com/ardith666/rapihin)
[![Local First](https://img.shields.io/badge/Privacy-100%25_On--Device-blue?style=for-the-badge)](https://github.com/ardith666/rapihin)
[![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)](LICENSE)

<br/>

[🍺 Install via Homebrew](#-instalasi-via-homebrew-cask) • [🇮🇩 Bahasa Indonesia](#-fitur-utama--tentang-rapihin) • [🇬🇧 English](#-overview--features-english) • [🚀 Cara Pemakaian](#-panduan-penggunaan-cara-pemakaian)

---

</div>

## 🍺 Instalasi via Homebrew Cask

Instal Rapihin secara instan via Homebrew Tap:

```bash
# Tambahkan tap ardith666/rapihin
brew tap ardith666/rapihin

# Instal aplikasi
brew install --cask rapihin
```

Atau unduh berkas installer `Rapihin-1.0.0.dmg` langsung dari [Halaman Rilis GitHub](https://github.com/ardith666/rapihin/releases).

## 📸 Antarmuka Aplikasi (Screenshots)

<div align="center">

### 🖥️ Dashboard & Drop Zone
*Area rapih instan dengan estetika modern macOS, indikator berkas tertunda, dan integrasi AI native.*
![Rapihin Dashboard](docs/screenshots/dashboard.png)

<br/>

| 📁 Kelola Folder & Mode Otomatis | ⚙️ Pengaturan & Bahasa |
| :---: | :---: |
| ![Kelola Folder](docs/screenshots/folders.png) | ![Pengaturan](docs/screenshots/settings.png) |
| *Izin folder fleksibel, toggle Auto vs Manual* | *Autostart saat login, bilingual ID/EN, skema folder* |

<br/>

| 🕒 Riwayat & Pulihkan (Undo) | 💎 Menu Bar Drop-Zone |
| :---: | :---: |
| ![Riwayat](docs/screenshots/history.png) | ![Menu Bar](docs/screenshots/menubar.png) |
| *Pembatalan perpindahan berkas 1-klik* | *Akses cepat langsung dari status bar macOS* |

</div>

---

## 🇮🇩 Fitur Utama & Tentang Rapihin

**Rapihin** adalah aplikasi perapih file untuk macOS yang dirancang sangat ringan (*ultra-lightweight*), elegan dengan estetika modern macOS, dan menghargai privasi pengguna secara absolut (**100% local-first**).

Berbeda dari aplikasi AI lain yang mengharuskan Anda mengunduh model LLM eksternal sebesar 4GB–16GB (yang menguras memori dan baterai MacBook), **Rapihin memanfaatkan langsung kapabilitas AI bawaan sistem operasi macOS (Apple Intelligence, Vision OCR `VNRecognizeTextRequest`, NaturalLanguage semantic tokenizer, dan PDFKit)**.

### 🌟 Keunggulan Utama:
- 🪶 **Sangat Ringan (< 2 MB):** Ukuran aplikasi hanya ~1.4 MB, pemakaian RAM idle hanya ~40 MB. Bebas dari bengkak (*zero bloat*).
- 🧠 **AI Bawaan macOS (Zero LLM Download):** Memahami konteks invoice, kuitansi, bukti transfer, slip gaji, tangkapan layar, kode proyek, arsip, dan dokumen kerja secara instan tanpa internet dan tanpa unduh model tambahan.
- 📂 **Izin Folder & Mode Per-Folder (Auto vs Manual):**
  - **Mode Otomatis (Real-time):** Memantau folder (seperti `~/Downloads`) secara senyap. Setiap ada file baru masuk, otomatis dikategorikan. Dilengkapi proteksi jeda unduhan agar file tidak terpotong saat masih diunduh browser.
  - **Mode Manual (On-demand):** Folder dipantau jumlah berkasnya, namun hanya dipindahkan ketika Anda menekan tombol *"Rapikan Sekarang"*.
- ⏱️ **Pengurutan Fleksibel (Created At vs Name):**
  - Opsi susunan folder hierarkis: `{Kategori}/{Tahun}/{Bulan}` atau `{Tahun}/{Kategori}`.
  - Mempertahankan tanggal pembuatan asli (`Created At`) dan opsi otomatis menyematkan tanggal standar `YYYY-MM-DD` pada nama file.
- 🚀 **Autostart saat Login (Launch at Login):** Terintegrasi langsung dengan framework modern Apple `SMAppService.mainApp`. Dapat berjalan senyap di Menu Bar saat Mac menyala.
- 🌐 **Dua Bahasa (Bilingual UI):** Beralih dengan mudah antara **Bahasa Indonesia 🇮🇩** dan **English 🇬🇧** langsung dari menu pengaturan.
- 🛡️ **Anti-Hilang Data & 1-Click Undo:** Setiap aksi pemindahan berkas dicatat dalam jurnal riwayat lokal, memungkinkan Anda mengembalikan berkas ke posisi semula (*Command+Z / Tombol Undo*) jika salah taruh.

---

## 🇬🇧 Overview & Features (English)

**Rapihin** is an intelligent, privacy-first file organizer built natively in Swift for macOS. It cleans up cluttered folders like `Downloads` and `Desktop` by categorizing documents, receipts, screenshots, media, and code using **Apple's on-device Intelligence, Vision, and NaturalLanguage frameworks**.

- ⚡ **Zero External Models Needed:** No 8GB LLM downloads, no Ollama daemon running in the background. Runs entirely on Apple Silicon Neural Engine (ANE).
- 📦 **Compact & Native:** Compiled native binary size is just ~1.4 MB with a minimal ~40 MB idle RAM footprint.
- 🔄 **Real-Time Watcher or On-Demand:** Configure each folder as either *Auto* (instant sorting on arrival with download-completion guards) or *Manual* (tidy with one click).
- ↩️ **Reversible Moves (Instant Undo):** Complete safety history allows reverting any file movement back to its original path.
- 🇬🇧 🇮🇩 **Bilingual System:** Switch seamlessly between English and Bahasa Indonesia.

---

## 🚀 Panduan Penggunaan (Cara Pemakaian)

### 1. Menjalankan Aplikasi
Buka aplikasi `Rapihin.app`. Anda akan disambut oleh jendela utama dengan area Drop Zone yang elegan, serta ikon Menu Bar di bagian atas status bar Mac Anda.

### 2. Mengatur Folder Pantauan
1. Buka tab **Kelola Folder** (*Folders*).
2. Klik **Tambah Folder...** dan pilih folder yang ingin dirapikan (misal: `Downloads` atau `Desktop`).
3. Berikan izin akses via dialog native macOS.
4. Pilih mode untuk folder tersebut:
   - Pilih **Otomatis (Real-time)** jika Anda ingin file yang baru diunduh langsung dirapikan ke subfolder kategori.
   - Pilih **Manual** jika Anda ingin mengumpulkan berkas terlebih dahulu dan merapikannya secara berkala.

### 3. Merapikan dengan Drag & Drop
Cukup tarik (*drag*) satu atau beberapa berkas/folder langsung ke area **Drop Zone** di Beranda. AI bawaan Mac akan mengekstrak konten dan memindahkannya seketika ke folder tujuan.

### 4. Mengubah Format Pengurutan & Bahasa
1. Buka tab **Pengaturan** (*Settings*).
2. Pilih bahasa: **Bahasa Indonesia 🇮🇩** atau **English 🇬🇧**.
3. Atur struktur subfolder yang Anda inginkan (misal: `Kategori > Tahun > Bulan`).
4. Aktifkan **Mulai Otomatis saat Login** agar Rapihin selalu menjaga kebersihan Mac Anda sejak dinyalakan.

### 5. Membatalkan Pemindahan (Undo)
Jika ada berkas yang salah tempat atau ingin dikembalikan ke lokasi asalnya:
1. Buka tab **Riwayat & Pulihkan** (*History & Undo*).
2. Klik tombol **Kembalikan (Undo)** di sebelah berkas yang bersangkutan. Berkas akan kembali ke lokasi awalnya secara instan.

---

## 🛠️ Cara Instalasi & Kompilasi

### Prasyarat
- macOS 14.0 (Sonoma) atau lebih baru (macOS 15+ Sequoia / macOS 27 direkomendasikan).
- Apple Silicon Mac (M1/M2/M3/M4/M5) atau Mac berbasis Intel.
- Xcode 15+ atau Command Line Tools dengan Swift 6.0+.

### Kompilasi dari Source Code

```bash
# 1. Clone repositori
git clone https://github.com/ardith666/rapihin.git
cd rapihin

# 2. Jalankan test otomatis
swift test

# 3. Bangun bundel aplikasi Rapihin.app
./scripts/build_app.sh

# 4. Buka aplikasi
open Rapihin.app
```

Untuk memindahkan ke folder Applications Anda:
```bash
cp -R Rapihin.app /Applications/
```

---

## 🏗️ Struktur Arsitektur

```
Rapihin/
├── Package.swift               # Definisi Swift Package Manager (macOS target)
├── PRD.md                      # Product Requirements Document lengkap
├── scripts/
│   └── build_app.sh            # Skrip otomatisasi build & codesign bundel .app
├── docs/
│   └── screenshots/            # Tangkapan layar antarmuka aplikasi
└── Sources/Rapihin/
    ├── App/
    │   └── Rapihin.swift       # Entry point (@main) & MenuBarExtra
    ├── Models/
    │   ├── AppSettings.swift   # Pengaturan aplikasi & preferensi bahasa
    │   ├── FileCategory.swift  # Kategori cerdas (Finance, Docs, Code, dll)
    │   ├── MonitoredFolder.swift # Model folder & state izin keamanan
    │   └── OrganizedItem.swift # Model riwayat & data undo
    ├── Services/
    │   ├── AIClassifier.swift  # Ekstraksi Vision OCR, NaturalLanguage, & PDFKit
    │   ├── AutostartManager.swift # Integrasi SMAppService macOS
    │   ├── FolderWatcher.swift # DispatchSource kernel event watcher & debounce
    │   ├── LocalizationManager.swift # Manajemen terjemahan ID & EN
    │   └── OrganizerEngine.swift # Mesin pemindah file atomik & undo journal
    └── Views/
        ├── DropZoneView.swift  # Komponen drop-zone interaktif
        ├── FolderManagementView.swift # Pengelolaan izin & mode Auto/Manual
        ├── HistoryView.swift   # Tampilan log riwayat & pembatalan
        ├── MainView.swift      # Dasbor utama dengan gaya liquid glass
        ├── MenuBarView.swift   # Popover menu bar macOS
        └── SettingsView.swift  # Jendela preferensi sistemik tabbed
```

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah lisensi **MIT** - lihat berkas [LICENSE](LICENSE) untuk informasi lebih lanjut.

Dibuat dengan ❤️ untuk ekosistem macOS yang bersih, cepat, dan menghargai privasi.
