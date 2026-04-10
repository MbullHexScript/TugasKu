import 'package:hive/hive.dart';
part 'mata_kuliah_model.g.dart';

// Model untuk menyimpan daftar mata kuliah
@HiveType(typeId: 1)
class MataKuliah extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String nama;

  // Kode warna dalam format int (Color.value)
  @HiveField(2)
  int warna;

  MataKuliah({required this.id, required this.nama, required this.warna});
}
