# TugasKu

Aplikasi manajemen tugas akademik untuk mahasiswa — kelola deadline, pantau progres, dan tetap fokus.

---

## Daftar Isi

- [Persyaratan](#persyaratan)
- [Clone Project](#clone-project)
- [Cara Menjalankan Project](#cara-menjalankan-project)
- [Build & Install APK ke Android via USB](#build--install-apk-ke-android-via-usb)

---

## Persyaratan

Pastikan semua tools berikut sudah terinstall sebelum memulai:

| Tool | Versi Minimum | Link |
|------|--------------|------|
| Flutter SDK | 3.38.4 | [flutter.dev](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.10.3 | Sudah termasuk dalam Flutter |
| Android Studio / VS Code | Terbaru | [developer.android.com](https://developer.android.com/studio) |
| Java JDK | 17 | [adoptium.net](https://adoptium.net/) |
| Git | Terbaru | [git-scm.com](https://git-scm.com/) |

Verifikasi instalasi Flutter kamu:

```bash
flutter doctor
```

Pastikan tidak ada tanda ✗ pada output, terutama untuk Android toolchain.

---

## Clone Project

**1. Clone repository dari GitHub:**

```bash
git clone https://github.com/MbullHexScript/TugasKu.git
```

**2. Masuk ke direktori project:**

```bash
cd TugasKu
```

**3. Install semua dependencies:**

```bash
flutter pub get
```

**4. Generate file Hive adapter** (wajib setelah clone pertama kali):

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Cara Menjalankan Project

### Di Emulator / Device yang Sudah Terhubung

**1. Cek device yang tersedia:**

```bash
flutter devices
```

**2. Jalankan aplikasi:**

```bash
flutter run
```

Atau jalankan di device tertentu dengan flag `-d`:

```bash
# Contoh: jalankan di emulator
flutter run -d emulator-5554

# Contoh: jalankan di device fisik
flutter run -d <device-id>
```

**3. Mode debug dengan hot reload:**

Setelah aplikasi berjalan, tekan:
- `r` — Hot reload
- `R` — Hot restart
- `q` — Keluar

### Menjalankan di Android Fisik (USB)

Aktifkan **Developer Options** dan **USB Debugging** di HP kamu (lihat panduan lengkap di bagian berikut), lalu:

```bash
flutter run
```

---

## Build & Install APK ke Android via USB

### Langkah 1 — Aktifkan Developer Options di HP Android

1. Buka **Pengaturan** → **Tentang Ponsel**
2. Cari **Nomor Build** (Build Number)
3. **Ketuk 7 kali** hingga muncul notifikasi _"Anda sekarang adalah developer"_
4. Kembali ke **Pengaturan** → **Opsi Pengembang** (Developer Options)
5. Aktifkan toggle **USB Debugging**

> Lokasi menu dapat berbeda tergantung merek HP (Samsung, Xiaomi, OPPO, dll). Cari "Developer Options" di kolom pencarian Pengaturan jika tidak ditemukan.

---

### Langkah 2 — Hubungkan HP ke Komputer

1. Sambungkan HP ke komputer via kabel USB
2. Di HP akan muncul popup **"Izinkan USB Debugging?"** — pilih **Izinkan / OK**
3. Verifikasi device sudah terdeteksi:

```bash
adb devices
```

Output yang diharapkan:

```
List of devices attached
XXXXXXXXXXXXXXXX    device
```

Jika status `unauthorized`, cabut dan sambungkan ulang, lalu izinkan ulang di HP.

---

### Langkah 3 — Build APK

**Build APK mode release (ukuran lebih kecil, performa lebih baik):**

```bash
flutter build apk --release
```

APK akan tersimpan di:

```
build/app/outputs/flutter-apk/app-release.apk
```

**Opsional — Build APK per arsitektur CPU (ukuran lebih kecil lagi):**

```bash
flutter build apk --split-per-abi
```

Akan menghasilkan tiga APK:
- `app-armeabi-v7a-release.apk` — untuk HP Android lama (32-bit)
- `app-arm64-v8a-release.apk` — untuk HP Android modern (64-bit) ✅ pilih ini
- `app-x86_64-release.apk` — untuk emulator

---

### Langkah 4 — Install APK ke HP via USB

**Cara 1 — Install langsung lewat Flutter:**

```bash
flutter install
```

**Cara 2 — Install manual lewat ADB:**

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Jika update dari versi sebelumnya dan terjadi error, tambahkan flag `-r` (replace):

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

**Cara 3 — Salin APK ke HP lalu install manual:**

```bash
# Salin APK ke storage HP
adb push build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/tugasku.apk
```

Kemudian buka file manager di HP → Download → ketuk `tugasku.apk` → Install.

> Jika muncul peringatan _"Instal dari sumber tidak dikenal"_, izinkan sekali di pengaturan.

---

### Troubleshooting Umum

| Masalah | Solusi |
|---------|--------|
| `flutter doctor` merah di Android toolchain | Jalankan `flutter doctor --android-licenses` dan setujui semua |
| Device tidak terdeteksi `adb devices` | Ganti kabel USB, coba port lain, atau install driver ADB |
| Error `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Uninstall dulu app lama: `adb uninstall com.example.tugasku` |
| Build gagal karena Gradle | Jalankan `cd android && ./gradlew clean` lalu build ulang |
| Hive adapter tidak ditemukan | Jalankan ulang `dart run build_runner build --delete-conflicting-outputs` |

---

## Struktur Project

```
tugasku/
├── lib/
│   ├── main.dart              # Entry point aplikasi
│   ├── models/                # Model data (Task, MataKuliah)
│   ├── providers/             # State management (Provider)
│   ├── screens/               # Halaman-halaman UI
│   ├── services/              # Hive & Notification service
│   └── widgets/               # Widget reusable
├── android/                   # Konfigurasi Android native
├── assets/images/             # Aset gambar
├── pubspec.yaml               # Dependencies Flutter
└── README.md
```

---

Dibuat dengan ♥ untuk mahasiswa Indonesia 🇮🇩
