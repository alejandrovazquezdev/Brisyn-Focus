// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_counter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomCounterAdapter extends TypeAdapter<CustomCounter> {
  @override
  final int typeId = 11;

  @override
  CustomCounter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomCounter(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      iconCodePoint: fields[3] as int,
      colorValue: fields[4] as int,
      targetCount: fields[5] as int,
      type: fields[6] as CounterType,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomCounter obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconCodePoint)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.targetCount)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCounterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CounterEntryAdapter extends TypeAdapter<CounterEntry> {
  @override
  final int typeId = 13;

  @override
  CounterEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CounterEntry(
      id: fields[0] as String,
      counterId: fields[1] as String,
      count: fields[2] as int,
      timestamp: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CounterEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.counterId)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CounterTypeAdapter extends TypeAdapter<CounterType> {
  @override
  final int typeId = 12;

  @override
  CounterType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CounterType.daily;
      case 1:
        return CounterType.weekly;
      case 2:
        return CounterType.cumulative;
      default:
        return CounterType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, CounterType obj) {
    switch (obj) {
      case CounterType.daily:
        writer.writeByte(0);
        break;
      case CounterType.weekly:
        writer.writeByte(1);
        break;
      case CounterType.cumulative:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
