# PRD — TugasKu v1.3.0

> **Versi:** 1.3.0
> **Tanggal:** Mei 2026
> **Status:** Draft
> **Platform:** Android (Flutter)

---

## Daftar Isi

- [Overview](#overview)
- [Fitur 1 — Sistem Notifikasi Cerdas](#fitur-1--sistem-notifikasi-cerdas)
- [Fitur 2 — Pusat Notifikasi Dalam-App](#fitur-2--pusat-notifikasi-dalam-app)
- [Fitur 3 — Mata Kuliah Lintas Semester](#fitur-3--mata-kuliah-lintas-semester)
- [Urutan Implementasi](#urutan-implementasi)
- [Daftar File yang Dimodifikasi](#daftar-file-yang-dimodifikasi)

---

## Overview

Update v1.3.0 berfokus pada tiga area utama:

1. **Sistem notifikasi yang lebih cerdas dan fleksibel** — user bisa memilih mode default atau mengatur sendiri jam pengiriman notifikasi per tugas.
2. **Pusat notifikasi dalam-app** — icon notifikasi di HOME bisa dibuka dan menampilkan riwayat notifikasi yang pernah dikirim.
3. **Manajemen mata kuliah lintas semester** — mahasiswa bisa menambahkan mata kuliah dari semester lain yang belum diselesaikan.

---

## Fitur 1 — Sistem Notifikasi Cerdas

### Latar Belakang

Saat ini notifikasi dikirim pada jadwal tetap (H-2 pukul 08.00, H-1 pukul 08.00, H pukul 07.00) tanpa bisa dikustomisasi. Ini tidak fleksibel — mahasiswa dengan deadline tengah malam tidak akan mendapat notifikasi yang berguna di pagi hari.

### Tujuan

- Memberikan notifikasi yang relevan sesuai waktu deadline aktual.
- Memberikan opsi kustomisasi waktu notifikasi per tugas tanpa mempersulit alur tambah tugas.

---

### 1.1 Mode Default

Jika user tidak mengubah pengaturan, aturan notifikasi adalah:

| Kapan | Jam Pengiriman | Pesan |
|-------|---------------|-------|
| H-2 sebelum deadline | 08.00 pagi | `"[Nama Tugas] — 2 hari lagi! Jangan sampai telat."` |
| H deadline | 2 jam sebelum jam deadline | `"[Nama Tugas] — HARI INI deadline! Kumpulkan sekarang."` |

**Edge cases mode default:**

- Jika 2 jam sebelum deadline sudah lewat saat tugas ditambahkan (contoh: deadline jam 07.00, saat ini sudah jam 06.30) → notifikasi H di-skip, tidak dikirim.
- Jika `deadline - 2 jam` menghasilkan waktu di hari sebelumnya (contoh: deadline jam 01.00 dini hari) → gunakan `H deadline pukul 00.01` sebagai fallback.
- H-1 dihapus dari sistem lama — disederhanakan menjadi hanya H-2 dan H.

---

### 1.2 Mode Custom

User bisa menonaktifkan mode default dan mengatur sendiri jam notifikasi untuk **hari H deadline**.

**Aturan mode custom:**

- H-2 **tetap menggunakan aturan default** (pukul 08.00 pagi), tidak bisa dikustomisasi.
- Hanya jam notifikasi di **hari H deadline** yang bisa diatur.
- Jam yang diatur berlaku untuk tugas tersebut saja (per-task setting, bukan global).

**Contoh kasus:**

> Tugas dikumpulkan hari ini, deadline pukul 00.00 WIB. User ingin diingatkan pukul 22.00. Maka user matikan toggle default, pilih jam 22.00 — notif akan dikirim tepat pukul 22.00.

---

### 1.3 Perubahan Model Data

Tambah 3 field baru di `task_model.dart` (backward compatible):

```dart
@HiveField(11)
bool useCustomNotif; // default: false

@HiveField(12)
int? customNotifHour; // nullable, 0-23

@HiveField(13)
int? customNotifMinute; // nullable, 0-59
```

Update `task_model.g.dart` secara manual (sesuai konvensi project ini yang sudah manually maintained).

Di constructor `Task`, tambahkan:
```dart
this.useCustomNotif = false,
this.customNotifHour,
this.customNotifMinute,
```

Di `TaskAdapter.read()`, tambahkan backward-compatible defaults:
```dart
useCustomNotif: fields[11] as bool? ?? false,
customNotifHour: fields[12] as int?,
customNotifMinute: fields[13] as int?,
```

---

### 1.4 Logika Kalkulasi Jadwal Notifikasi

```
fungsi hitungJadwalNotif(Task task) → List<DateTime>:
  jadwal = []
  now = DateTime.now()

  // H-2: selalu default, tidak bisa dikustomisasi
  h2 = DateTime(deadline.year, deadline.month, deadline.day - 2, 8, 0)
  if h2.isAfter(now):
    jadwal.add(h2)

  // H (hari deadline)
  if task.useCustomNotif && customNotifHour != null:
    notifH = DateTime(deadline.year, deadline.month, deadline.day,
                      customNotifHour!, customNotifMinute ?? 0)
  else:
    notifH = deadline.subtract(Duration(hours: 2))
    // Fallback: jika hasil pengurangan bukan di hari yang sama
    if notifH.day != deadline.day:
      notifH = DateTime(deadline.year, deadline.month, deadline.day, 0, 1)

  if notifH.isAfter(now):
    jadwal.add(notifH)

  return jadwal
```

---

### 1.5 UI di TaskFormScreen

Tambahkan card baru setelah card **Deadline**, sebelum card **Status**:

```
┌─────────────────────────────────────────────┐
│  🔔  PENGINGAT                               │
│                                             │
│  Gunakan pengaturan default    [ Toggle ON ]│
│                                             │
│  ┌ Info (muncul jika toggle ON) ──────────┐ │
│  │ H-2: notif pukul 08.00 pagi            │ │
│  │ H  : notif 2 jam sebelum deadline      │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ── Jika toggle OFF ──                      │
│                                             │
│  Kirim notif di hari deadline pada pukul:   │
│  ┌────────────┐                             │
│  │  22 : 00   │  [Pilih Waktu]              │
│  └────────────┘                             │
│                                             │
│  ⓘ Notif H-2 tetap dikirim pukul 08.00.    │
└─────────────────────────────────────────────┘
```

**Detail implementasi UI:**

- Toggle menggunakan `Switch` widget, default `true`.
- Saat toggle `false`, tampilkan row waktu dengan `GestureDetector` yang membuka `showTimePicker`.
- Gunakan `AnimatedCrossFade` atau `AnimatedSize` untuk transisi smooth saat toggle berubah.
- Format tampilan waktu: `HH:MM WIB`.

---

### 1.6 Perubahan notification_service.dart

- Hapus logika H-1 yang ada saat ini.
- Refactor `jadwalkanNotifikasiTugas` agar memanggil `hitungJadwalNotif` untuk mendapatkan daftar jadwal, lalu loop dan panggil `_jadwalkan` untuk masing-masing.
- ID notifikasi tetap menggunakan pola `task.id * 10 + index` (1 untuk H-2, 3 untuk H — skip 2 yang tadinya untuk H-1).

---

## Fitur 2 — Pusat Notifikasi Dalam-App

### Latar Belakang

Icon notifikasi di semua halaman saat ini tidak berfungsi. User perlu bisa melihat riwayat notifikasi. Selain itu, icon notifikasi hanya relevan di halaman HOME — di halaman lain sebaiknya dihilangkan agar UI lebih bersih.

### Tujuan

- Icon notifikasi di HOME bisa dibuka dan menampilkan riwayat notifikasi.
- Badge merah muncul jika ada notifikasi yang belum dibaca.
- Hapus icon notifikasi dari Calendar, Stats, dan Settings.

---

### 2.1 Perubahan Icon Notifikasi

| Halaman | Sebelum | Sesudah |
|---------|---------|---------|
| HOME (`_DashboardTab`) | Ada, tidak berfungsi | Ada, berfungsi (tap → buka sheet) |
| Calendar | Ada | **Dihapus** |
| Statistics | Ada | **Dihapus** |
| Settings | Ada | **Dihapus** |

---

### 2.2 Model Data Log Notifikasi

Buat file baru `lib/models/notification_log_model.dart`:

```dart
@HiveType(typeId: 2)
class NotificationLog extends HiveObject {
  @HiveField(0) int id;
  @HiveField(1) String judul;
  @HiveField(2) String pesan;
  @HiveField(3) DateTime waktu;       // waktu notif dijadwalkan dikirim
  @HiveField(4) bool sudahDibaca;
  @HiveField(5) int? taskId;          // nullable, referensi ke Task
  @HiveField(6) String? namaTugas;    // snapshot nama tugas saat log dibuat
}
```

Generate `notification_log_model.g.dart` dengan `build_runner`, atau buat manual sesuai konvensi project.

**Batas penyimpanan:** maksimal 50 log terbaru. Saat menambah log baru, hapus yang paling lama jika sudah melebihi 50.

---

### 2.3 Perubahan HiveService

Tambahkan di `hive_service.dart`:

```dart
static const String _notifLogBoxName = 'notification_logs';

// Di init():
await Hive.openBox<NotificationLog>(_notifLogBoxName);

// Method baru:
static Box<NotificationLog> getNotifLogBox() =>
    Hive.box<NotificationLog>(_notifLogBoxName);

static Future<void> simpanLogNotifikasi({
  required String judul,
  required String pesan,
  required DateTime waktu,
  int? taskId,
  String? namaTugas,
}) async {
  final box = getNotifLogBox();
  // Auto-prune: hapus yang lama jika sudah >= 50
  if (box.length >= 50) {
    final oldest = box.values
        .toList()
        ..sort((a, b) => a.waktu.compareTo(b.waktu));
    await oldest.first.delete();
  }
  final id = DateTime.now().millisecondsSinceEpoch;
  await box.put(id, NotificationLog(
    id: id,
    judul: judul,
    pesan: pesan,
    waktu: waktu,
    sudahDibaca: false,
    taskId: taskId,
    namaTugas: namaTugas,
  ));
}

static int getJumlahNotifBelumDibaca() {
  final now = DateTime.now();
  return getNotifLogBox().values
      .where((log) => !log.sudahDibaca && log.waktu.isBefore(now))
      .length;
}

static Future<void> tandaiSemuaNotifDibaca() async {
  for (final log in getNotifLogBox().values) {
    if (!log.sudahDibaca) {
      log.sudahDibaca = true;
      await log.save();
    }
  }
}

// Di resetAllData(), tambahkan:
await getNotifLogBox().clear();
```

---

### 2.4 Perubahan notification_service.dart

Setelah memanggil `_jadwalkan` berhasil, simpan log:

```dart
// Setelah _jadwalkan berhasil:
await HiveService.simpanLogNotifikasi(
  judul: judul,
  pesan: pesan,
  waktu: waktu,
  taskId: task.id,
  namaTugas: task.namaTugas,
);
```

---

### 2.5 Badge Merah di HOME

Di `_DashboardTab`, ganti widget icon notifikasi yang ada menjadi:

```dart
ValueListenableBuilder<Box<NotificationLog>>(
  valueListenable: HiveService.getNotifLogBox().listenable(),
  builder: (context, box, _) {
    final now = DateTime.now();
    final adaBelumDibaca = box.values.any(
      (log) => !log.sudahDibaca && log.waktu.isBefore(now),
    );
    return GestureDetector(
      onTap: () => _bukaNotificationCenter(context),
      child: Stack(
        children: [
          Icon(Icons.notifications_outlined, color: cs.primary, size: 26),
          if (adaBelumDibaca)
            Positioned(
              top: 0, right: 0,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  },
)
```

---

### 2.6 UI Notification Center Sheet

Buat file baru `lib/screens/notification_center_sheet.dart`:

```
┌─────────────────────────────────────────────┐
│  ──────  (handle)                           │
│                                             │
│  Notifikasi            [Tandai semua dibaca]│
│  ─────────────────────────────────────────  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │ 🔴  Laporan Analisis                 │  │
│  │     DEADLINE HARI INI!               │  │
│  │     Segera kumpulkan.                │  │
│  │     Hari ini, 21.59          ──────  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │     Makalah Fisika                   │  │
│  │     Deadline besok! Jangan telat.    │  │
│  │     Kemarin, 08.00           ──────  │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  [Jika kosong: ilustrasi + teks            │
│   "Belum ada notifikasi"]                  │
└─────────────────────────────────────────────┘
```

**Detail implementasi:**

- Tampilkan **hanya log yang `waktu <= now`** (yang sudah "terkirim" secara logis).
- Urutkan dari terbaru ke terlama.
- Item belum dibaca: background `cs.primary.withOpacity(0.07)` + dot merah di sisi kiri.
- Item sudah dibaca: background normal, tidak ada dot.
- Tap item: `Navigator.push` ke `TaskDetailScreen` jika `taskId != null`, lalu tandai log sebagai dibaca.
- Tombol "Tandai semua dibaca": panggil `HiveService.tandaiSemuaNotifDibaca()`.
- Format waktu relatif: "Hari ini, HH:mm" / "Kemarin, HH:mm" / "DD MMM, HH:mm".

---

## Fitur 3 — Mata Kuliah Lintas Semester

### Latar Belakang

Mahasiswa bisa mengambil ulang atau menyelesaikan mata kuliah dari semester sebelumnya (contoh: mahasiswa semester 4 masih punya tugas dari mata kuliah semester 3). Model saat ini tidak menyimpan informasi semester pada `MataKuliah`.

### Tujuan

- User bisa menandai mata kuliah sebagai milik semester tertentu.
- Tampilan dikelompokkan berdasarkan semester untuk kemudahan navigasi.
- Tidak merusak data yang sudah ada (backward compatible).

---

### 3.1 Pendekatan: Semester Label Opsional

Pendekatan **"Semester Label" opsional** dipilih karena:
- Tidak breaking change untuk data lama (nilai `0` = tidak ditentukan).
- Implementasi sederhana, tidak perlu struktur data baru yang kompleks.
- Sesuai dengan kebutuhan nyata: mayoritas matkul adalah "semester ini", lintas semester adalah kasus khusus.

---

### 3.2 Perubahan Model MataKuliah

Tambah field baru di `mata_kuliah_model.dart`:

```dart
@HiveField(3)
int semester; // 0 = tidak ditentukan / semester aktif, 1-8 = semester spesifik
```

Update constructor:
```dart
MataKuliah({
  required this.id,
  required this.nama,
  required this.warna,
  this.semester = 0, // default: tidak ditentukan
});
```

Update `MataKuliahAdapter` di `mata_kuliah_model.g.dart`:
```dart
// Di read():
semester: fields[3] as int? ?? 0, // backward compatible

// Di write():
writer..writeByte(4) // totalFields naik dari 3 ke 4
  ..writeByte(3)
  ..write(obj.semester)
```

---

### 3.3 Perubahan MataKuliahProvider

Tambah helper methods di `mata_kuliah_provider.dart`:

```dart
// Semester aktif user (dari profile)
int get semesterAktif => HiveService.getProfileSemester();

// Matkul "semester ini": semester == 0 atau semester == semesterAktif
List<MataKuliah> get mataKuliahSemesterIni => _daftarMataKuliah
    .where((m) => m.semester == 0 || m.semester == semesterAktif)
    .toList();

// Matkul lintas semester
List<MataKuliah> get mataKuliahLintasSemester => _daftarMataKuliah
    .where((m) => m.semester != 0 && m.semester != semesterAktif)
    .toList()
  ..sort((a, b) => b.semester.compareTo(a.semester)); // terbaru dulu

// Update signature tambahMataKuliah
Future<void> tambahMataKuliah(String nama, {int semester = 0}) async {
  // ... (existing logic)
  final mk = MataKuliah(id: id, nama: nama, warna: warna, semester: semester);
  // ...
}
```

---

### 3.4 Perubahan UI di Settings — Dialog Tambah Mata Kuliah

Perluas dialog `_dialogTambahMK` di `settings_screen.dart`:

```
┌──────────────────────────────────────────┐
│  Tambah Mata Kuliah                      │
│  ──────────────────────────────────────  │
│                                          │
│  Nama Mata Kuliah                        │
│  [________________________________]      │
│                                          │
│  Semester                                │
│  ┌──────────────────────────────────┐    │
│  │ ● Semester ini (Sem 4)           │    │
│  │ ○ Semester lain:  [ 3 ▼ ]       │    │
│  └──────────────────────────────────┘    │
│                                          │
│              [Batal]    [Tambah]         │
└──────────────────────────────────────────┘
```

**Detail implementasi:**

- Radio button: "Semester ini" (default) vs "Semester lain".
- Jika "Semester lain" dipilih, tampilkan `DropdownButton` dengan pilihan 1–8, pre-filtered minus semester aktif user.
- Gunakan `StatefulBuilder` di dalam `showDialog` untuk state radio button.

---

### 3.5 Perubahan UI di Settings — List Mata Kuliah

Di `settings_screen.dart`, kelompokkan tampilan list mata kuliah:

```
SEMESTER INI
  ┌─────────────────────────────────────┐
  │ ● Pemrograman Mobile    3 tugas  🗑 │
  └─────────────────────────────────────┘
  ┌─────────────────────────────────────┐
  │ ● Basis Data Lanjut     1 tugas  🗑 │
  └─────────────────────────────────────┘

SEMESTER LAIN
  ┌─────────────────────────────────────┐
  │ ● Matematika Diskrit               │
  │   Semester 3 • 2 tugas          🗑 │
  └─────────────────────────────────────┘
```

Jika tidak ada matkul lintas semester, section "SEMESTER LAIN" tidak ditampilkan.

---

### 3.6 Perubahan UI di TaskFormScreen — Dropdown Mata Kuliah

Kelompokkan dropdown mata kuliah menggunakan header non-selectable:

```dart
// Contoh struktur items:
[
  // Header (disabled)
  DropdownMenuItem(
    enabled: false,
    child: Text('── Semester Ini ──', style: headerStyle),
  ),
  // Items semester ini
  ...mkProv.mataKuliahSemesterIni.map((mk) =>
    DropdownMenuItem(value: mk.nama, child: Text(mk.nama))
  ),
  // Header lintas semester (hanya jika ada)
  if (mkProv.mataKuliahLintasSemester.isNotEmpty)
    DropdownMenuItem(
      enabled: false,
      child: Text('── Semester Lain ──', style: headerStyle),
    ),
  // Items lintas semester dengan label "(Sem X)"
  ...mkProv.mataKuliahLintasSemester.map((mk) =>
    DropdownMenuItem(
      value: mk.nama,
      child: Text('${mk.nama} (Sem ${mk.semester})'),
    )
  ),
]
```

> **Catatan:** Nilai `DropdownMenuItem.value` tetap menggunakan `mk.nama` (bukan ditambah "(Sem X)") agar tidak merusak data `task.mataKuliah` yang sudah ada.

---

### 3.7 Perubahan UI di Statistics

Di `_DistributionDonut` dan chip label, tambahkan suffix "(Sem X)" jika mata kuliah bersangkutan adalah lintas semester:

```dart
// Di _DistChip dan label donut:
final mk = mkProv.daftarMataKuliah
    .firstWhere((m) => m.nama == entry.key, orElse: () => ...);
final label = (mk.semester != 0 && mk.semester != mkProv.semesterAktif)
    ? '${mk.nama} (Sem ${mk.semester})'
    : mk.nama;
```

---

## Urutan Implementasi

Karena banyak file yang saling terkait, disarankan mengikuti urutan ini untuk meminimalkan konflik:

```
Step 1 ──► Fitur 3 (Lintas Semester)
           └── Perubahan model Hive saja, tidak ada dependensi ke fitur lain
           └── File: mata_kuliah_model, provider, settings_screen, task_form_screen, statistics_screen

Step 2 ──► Fitur 1 (Notifikasi Custom)
           └── Tambah fields ke Task model + update notification service
           └── File: task_model, notification_service, task_form_screen, task_provider

Step 3 ──► Fitur 2 (Notification Center)
           └── Model baru + UI baru, bergantung pada notif service Step 2
           └── File: notification_log_model (baru), notification_center_sheet (baru),
                     hive_service, notification_service, home_screen,
                     calendar_screen, statistics_screen, settings_screen
```

**Tips saat menggunakan Claude untuk implementasi:**

- Berikan hanya file yang relevan per fitur — jangan paste semua file sekaligus.
- Untuk Fitur 1: berikan `task_model.dart`, `task_form_screen.dart`, `notification_service.dart`.
- Untuk Fitur 2: berikan `hive_service.dart`, `notification_service.dart` (hasil Step 2), `home_screen.dart`.
- Untuk Fitur 3: berikan `mata_kuliah_model.dart`, `mata_kuliah_provider.dart`, `settings_screen.dart`, `task_form_screen.dart`.

---

## Daftar File yang Dimodifikasi

### File yang Diubah

| File | Fitur | Jenis Perubahan |
|------|-------|-----------------|
| `lib/models/task_model.dart` | 1 | Tambah field HiveField 11, 12, 13 |
| `lib/models/task_model.g.dart` | 1 | Update adapter (manually maintained) |
| `lib/models/mata_kuliah_model.dart` | 3 | Tambah field HiveField 3 (semester) |
| `lib/models/mata_kuliah_model.g.dart` | 3 | Update adapter |
| `lib/providers/task_provider.dart` | 1 | Update `tambahTugas`, `editTugas` |
| `lib/providers/mata_kuliah_provider.dart` | 3 | Tambah getters & update `tambahMataKuliah` |
| `lib/services/hive_service.dart` | 2 | Tambah box & methods log notifikasi |
| `lib/services/notification_service.dart` | 1, 2 | Refactor jadwal + simpan log |
| `lib/screens/home_screen.dart` | 2 | Update icon notif → buka sheet |
| `lib/screens/calendar_screen.dart` | 2 | Hapus icon notifikasi |
| `lib/screens/statistics_screen.dart` | 2, 3 | Hapus icon notif + update label matkul |
| `lib/screens/settings_screen.dart` | 2, 3 | Hapus icon notif + update dialog & list matkul |
| `lib/screens/task_form_screen.dart` | 1, 3 | Tambah card pengingat + update dropdown matkul |

### File Baru

| File | Fitur | Keterangan |
|------|-------|------------|
| `lib/models/notification_log_model.dart` | 2 | Model Hive untuk log notifikasi |
| `lib/models/notification_log_model.g.dart` | 2 | Generated adapter |
| `lib/screens/notification_center_sheet.dart` | 2 | Bottom sheet pusat notifikasi |

---

*Dokumen ini dibuat sebagai panduan pengembangan TugasKu v1.3.0. Setiap perubahan model Hive yang melibatkan penambahan field harus memperhatikan backward compatibility dengan data yang sudah tersimpan di device user.*
