part of 'mata_kuliah_model.dart';

class MataKuliahAdapter extends TypeAdapter<MataKuliah> {
  @override
  final int typeId = 1;

  @override
  MataKuliah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MataKuliah(
      id: fields[0] as int,
      nama: fields[1] as String,
      warna: fields[2] as int,
      semester: fields[3] as int? ?? 0, // backward compatible
    );
  }

  @override
  void write(BinaryWriter writer, MataKuliah obj) {
    writer
      ..writeByte(4) // total fields naik dari 3 ke 4
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.warna)
      ..writeByte(3)
      ..write(obj.semester);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MataKuliahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
