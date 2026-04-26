import 'package:flutter/material.dart';
import '../models/mata_kuliah_model.dart';
import '../services/hive_service.dart';

class MataKuliahProvider extends ChangeNotifier {
  List<MataKuliah> _daftarMataKuliah = [];

  // Palet warna default untuk mata kuliah baru
  static const List<int> warnaDefault = [
    0xFF6750A4, 0xFF1565C0, 0xFF2E7D32, 0xFFC62828,
    0xFFE65100, 0xFF00838F, 0xFF6A1B9A, 0xFF4A148C,
  ];

  MataKuliahProvider() {
    _muat();
  }

  List<MataKuliah> get daftarMataKuliah => _daftarMataKuliah;
  List<String> get namaMataKuliah => _daftarMataKuliah.map((m) => m.nama).toList();

  int getWarna(String nama) {
    final mk = _daftarMataKuliah.firstWhere(
      (m) => m.nama == nama,
      orElse: () => MataKuliah(id: 0, nama: '', warna: 0xFF9E9E9E),
    );
    return mk.warna;
  }

  void _muat() {
    _daftarMataKuliah = HiveService.getMataKuliahBox().values.toList();
    notifyListeners();
  }

  void reload() => _muat();

  Future<void> tambahMataKuliah(String nama) async {
    // Cek apakah nama sudah ada
    if (_daftarMataKuliah.any((m) => m.nama.toLowerCase() == nama.toLowerCase())) {
      return;
    }
    final box = HiveService.getMataKuliahBox();
    final id = await HiveService.allocateMataKuliahId();
    final warna = warnaDefault[_daftarMataKuliah.length % warnaDefault.length];
    final mk = MataKuliah(id: id, nama: nama, warna: warna);
    await box.put(id, mk);
    _muat();
  }

  Future<void> hapusMataKuliah(MataKuliah mk) async {
    await mk.delete();
    _muat();
  }
}
