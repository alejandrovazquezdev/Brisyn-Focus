// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalGoalAdapter extends TypeAdapter<PersonalGoal> {
  @override
  final int typeId = 14;

  @override
  PersonalGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalGoal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as GoalType,
      iconCodePoint: fields[4] as int,
      colorValue: fields[5] as int,
      createdAt: fields[6] as DateTime,
      targetDate: fields[7] as DateTime?,
      targetValue: fields[8] as int?,
      currentValue: fields[9] as int,
      isCompleted: fields[10] as bool,
      dailyCompletions: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PersonalGoal obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.iconCodePoint)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.targetDate)
      ..writeByte(8)
      ..write(obj.targetValue)
      ..writeByte(9)
      ..write(obj.currentValue)
      ..writeByte(10)
      ..write(obj.isCompleted)
      ..writeByte(11)
      ..write(obj.dailyCompletions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 15;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.daily;
      case 1:
        return GoalType.milestone;
      case 2:
        return GoalType.habit;
      case 3:
        return GoalType.reflection;
      default:
        return GoalType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.daily:
        writer.writeByte(0);
        break;
      case GoalType.milestone:
        writer.writeByte(1);
        break;
      case GoalType.habit:
        writer.writeByte(2);
        break;
      case GoalType.reflection:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
