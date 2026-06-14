// Manually maintained adapter for NotificationLog

part of 'notification_log_model.dart';

class NotificationLogAdapter extends TypeAdapter<NotificationLog> {
  @override
  final int typeId = 2;

  @override
  NotificationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationLog(
      id: fields[0] as int,
      judul: fields[1] as String,
      pesan: fields[2] as String,
      waktu: fields[3] as DateTime,
      sudahDibaca: fields[4] as bool? ?? false,
      taskId: fields[5] as int?,
      namaTugas: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.pesan)
      ..writeByte(3)
      ..write(obj.waktu)
      ..writeByte(4)
      ..write(obj.sudahDibaca)
      ..writeByte(5)
      ..write(obj.taskId)
      ..writeByte(6)
      ..write(obj.namaTugas);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
