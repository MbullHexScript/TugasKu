import 'package:flutter/material.dart';
import '../models/mata_kuliah_model.dart';
import '../services/hive_service.dart';

class MataKuliahProvider extends ChangeNotifier {
  List<MataKuliah> _daftarMataKuliah = [];

  // Palet warna default untuk mata kuliah baru
  static const List<int> warnaDefault = [
    0xFF004445, // Deep Teal
    0xFF006C4B, // Emerald
    0xFF1F6869, // Surface Tint Teal
    0xFF0D5D5E, // Teal Container
    0xFF0F766E, // Teal
    0xFF0E7490, // Blue-teal
    0xFF1D4ED8, // Indigo-blue (accent)
    0xFFEA580C, // Amber (accent)
  ];

  MataKuliahProvider() {
    _muat();
  }

  List<MataKuliah> get daftarMataKuliah => _daftarMataKuliah;
  List<String> get namaMataKuliah =>
      _daftarMataKuliah.map((m) => m.nama).toList();

  /// Semester aktif user dari profil
  int get semesterAktif => HiveService.getProfileSemester();

  /// Matkul "semester ini": semester == 0 atau semester == semesterAktif
  List<MataKuliah> get mataKuliahSemesterIni => _daftarMataKuliah
      .where((m) => m.semester == 0 || m.semester == semesterAktif)
      .toList();

  /// Matkul lintas semester (bukan semester aktif dan bukan 0)
  List<MataKuliah> get mataKuliahLintasSemester => _daftarMataKuliah
      .where((m) => m.semester != 0 && m.semester != semesterAktif)
      .toList()
    ..sort((a, b) => b.semester.compareTo(a.semester));

  int getWarna(String nama) {
    final mk = _daftarMataKuliah.firstWhere(
      (m) => m.nama == nama,
      orElse: () => MataKuliah(id: 0, nama: '', warna: 0xFF9E9E9E),
    );
    return mk.warna;
  }

  /// Mendapatkan semester matkul berdasarkan nama
  int getSemester(String nama) {
    final mk = _daftarMataKuliah.firstWhere(
      (m) => m.nama == nama,
      orElse: () => MataKuliah(id: 0, nama: '', warna: 0xFF9E9E9E),
    );
    return mk.semester;
  }

  /// Cek apakah matkul adalah lintas semester
  bool isLintasSemester(String nama) {
    final mk = _daftarMataKuliah.firstWhere(
      (m) => m.nama == nama,
      orElse: () => MataKuliah(id: 0, nama: '', warna: 0xFF9E9E9E),
    );
    return mk.semester != 0 && mk.semester != semesterAktif;
  }

  void _muat() {
    _daftarMataKuliah = HiveService.getMataKuliahBox().values.toList();
    notifyListeners();
  }

  void reload() => _muat();

  Future<void> tambahMataKuliah(String nama, {int semester = 0}) async {
    // Cek apakah nama sudah ada
    if (_daftarMataKuliah
        .any((m) => m.nama.toLowerCase() == nama.toLowerCase())) {
      return;
    }
    final box = HiveService.getMataKuliahBox();
    final id = await HiveService.allocateMataKuliahId();
    final warna = warnaDefault[_daftarMataKuliah.length % warnaDefault.length];
    final mk = MataKuliah(id: id, nama: nama, warna: warna, semester: semester);
    await box.put(id, mk);
    _muat();
  }

  Future<void> hapusMataKuliah(MataKuliah mk) async {
    await mk.delete();
    _muat();
  }
}
