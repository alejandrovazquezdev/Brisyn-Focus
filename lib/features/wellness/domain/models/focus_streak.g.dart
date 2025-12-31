// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_streak.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusStreakAdapter extends TypeAdapter<FocusStreak> {
  @override
  final int typeId = 10;

  @override
  FocusStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusStreak(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      focusMinutes: fields[2] as int,
      sessionsCompleted: fields[3] as int,
      goalMet: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FocusStreak obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.focusMinutes)
      ..writeByte(3)
      ..write(obj.sessionsCompleted)
      ..writeByte(4)
      ..write(obj.goalMet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
