// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually maintained to include fields 8-10 (catatan, subtasks, subtasksDone)

part of 'task_model.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as int,
      namaTugas: fields[1] as String,
      mataKuliah: fields[2] as String,
      prioritas: fields[3] as String,
      deadline: fields[4] as DateTime,
      isSelesai: fields[5] as bool,
      status: fields[6] as String,
      createdAt: fields[7] as DateTime,
      // Backward-compatible defaults for new fields
      catatan: fields[8] as String? ?? '',
      subtasks: (fields[9] as List?)?.cast<String>() ?? [],
      subtasksDone: (fields[10] as List?)?.cast<bool>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaTugas)
      ..writeByte(2)
      ..write(obj.mataKuliah)
      ..writeByte(3)
      ..write(obj.prioritas)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.isSelesai)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.catatan)
      ..writeByte(9)
      ..write(obj.subtasks)
      ..writeByte(10)
      ..write(obj.subtasksDone);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
