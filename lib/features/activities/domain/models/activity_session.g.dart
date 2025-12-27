// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivitySessionAdapter extends TypeAdapter<ActivitySession> {
  @override
  final int typeId = 4;

  @override
  ActivitySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivitySession(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      startTime: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      taskId: fields[4] as String?,
      notes: fields[5] as String?,
      pomodorosCompleted: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ActivitySession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.taskId)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.pomodorosCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivitySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
