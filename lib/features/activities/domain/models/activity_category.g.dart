// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityCategoryAdapter extends TypeAdapter<ActivityCategory> {
  @override
  final int typeId = 2;

  @override
  ActivityCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as ActivityIcon,
      colorHex: fields[3] as String,
      weeklyGoal: fields[4] as int,
      sortOrder: fields[5] as int,
      isDefault: fields[6] as bool,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityCategory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.weeklyGoal)
      ..writeByte(5)
      ..write(obj.sortOrder)
      ..writeByte(6)
      ..write(obj.isDefault)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityIconAdapter extends TypeAdapter<ActivityIcon> {
  @override
  final int typeId = 3;

  @override
  ActivityIcon read(BinaryReader reader) {
    final index = reader.readByte();
    return ActivityIcon.values[index];
  }

  @override
  void write(BinaryWriter writer, ActivityIcon obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityIconAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
