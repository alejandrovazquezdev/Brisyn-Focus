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
      linkedGoalId: fields[8] as String?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityCategory obj) {
    writer
      ..writeByte(9)
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
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.linkedGoalId);
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
  final int typeId = 18;

  @override
  ActivityIcon read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityIcon.workout;
      case 1:
        return ActivityIcon.cardio;
      case 2:
        return ActivityIcon.study;
      case 3:
        return ActivityIcon.reading;
      case 4:
        return ActivityIcon.coding;
      case 5:
        return ActivityIcon.music;
      case 6:
        return ActivityIcon.gaming;
      case 7:
        return ActivityIcon.meditation;
      case 8:
        return ActivityIcon.journal;
      case 9:
        return ActivityIcon.language;
      case 10:
        return ActivityIcon.art;
      case 11:
        return ActivityIcon.cooking;
      case 12:
        return ActivityIcon.research;
      case 13:
        return ActivityIcon.writing;
      case 14:
        return ActivityIcon.plants;
      case 15:
        return ActivityIcon.medicine;
      case 16:
        return ActivityIcon.work;
      case 17:
        return ActivityIcon.meeting;
      case 18:
        return ActivityIcon.email;
      case 19:
        return ActivityIcon.call;
      case 20:
        return ActivityIcon.shopping;
      case 21:
        return ActivityIcon.cleaning;
      case 22:
        return ActivityIcon.travel;
      case 23:
        return ActivityIcon.social;
      case 24:
        return ActivityIcon.family;
      case 25:
        return ActivityIcon.health;
      case 26:
        return ActivityIcon.finance;
      case 27:
        return ActivityIcon.learning;
      case 28:
        return ActivityIcon.project;
      case 29:
        return ActivityIcon.hobby;
      case 30:
        return ActivityIcon.custom;
      default:
        return ActivityIcon.workout;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityIcon obj) {
    switch (obj) {
      case ActivityIcon.workout:
        writer.writeByte(0);
        break;
      case ActivityIcon.cardio:
        writer.writeByte(1);
        break;
      case ActivityIcon.study:
        writer.writeByte(2);
        break;
      case ActivityIcon.reading:
        writer.writeByte(3);
        break;
      case ActivityIcon.coding:
        writer.writeByte(4);
        break;
      case ActivityIcon.music:
        writer.writeByte(5);
        break;
      case ActivityIcon.gaming:
        writer.writeByte(6);
        break;
      case ActivityIcon.meditation:
        writer.writeByte(7);
        break;
      case ActivityIcon.journal:
        writer.writeByte(8);
        break;
      case ActivityIcon.language:
        writer.writeByte(9);
        break;
      case ActivityIcon.art:
        writer.writeByte(10);
        break;
      case ActivityIcon.cooking:
        writer.writeByte(11);
        break;
      case ActivityIcon.research:
        writer.writeByte(12);
        break;
      case ActivityIcon.writing:
        writer.writeByte(13);
        break;
      case ActivityIcon.plants:
        writer.writeByte(14);
        break;
      case ActivityIcon.medicine:
        writer.writeByte(15);
        break;
      case ActivityIcon.work:
        writer.writeByte(16);
        break;
      case ActivityIcon.meeting:
        writer.writeByte(17);
        break;
      case ActivityIcon.email:
        writer.writeByte(18);
        break;
      case ActivityIcon.call:
        writer.writeByte(19);
        break;
      case ActivityIcon.shopping:
        writer.writeByte(20);
        break;
      case ActivityIcon.cleaning:
        writer.writeByte(21);
        break;
      case ActivityIcon.travel:
        writer.writeByte(22);
        break;
      case ActivityIcon.social:
        writer.writeByte(23);
        break;
      case ActivityIcon.family:
        writer.writeByte(24);
        break;
      case ActivityIcon.health:
        writer.writeByte(25);
        break;
      case ActivityIcon.finance:
        writer.writeByte(26);
        break;
      case ActivityIcon.learning:
        writer.writeByte(27);
        break;
      case ActivityIcon.project:
        writer.writeByte(28);
        break;
      case ActivityIcon.hobby:
        writer.writeByte(29);
        break;
      case ActivityIcon.custom:
        writer.writeByte(30);
        break;
    }
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
