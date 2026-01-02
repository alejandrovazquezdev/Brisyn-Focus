// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      priority: fields[4] as TaskPriority,
      createdAt: fields[5] as DateTime?,
      dueDate: fields[6] as DateTime?,
      estimatedPomodoros: fields[7] as int,
      completedPomodoros: fields[8] as int,
      projectId: fields[9] as String?,
      tags: (fields[10] as List?)?.cast<String>(),
      sortOrder: fields[11] as int,
      status: fields[12] as TaskStatus,
      parentTaskId: fields[13] as String?,
      recurrenceType: fields[14] as RecurrenceType,
      lastRecurrenceDate: fields[15] as DateTime?,
      recurringSourceId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.estimatedPomodoros)
      ..writeByte(8)
      ..write(obj.completedPomodoros)
      ..writeByte(9)
      ..write(obj.projectId)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.sortOrder)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.parentTaskId)
      ..writeByte(14)
      ..write(obj.recurrenceType)
      ..writeByte(15)
      ..write(obj.lastRecurrenceDate)
      ..writeByte(16)
      ..write(obj.recurringSourceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 1;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      default:
        return TaskPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.low:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 16;

  @override
  TaskStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskStatus.todo;
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    switch (obj) {
      case TaskStatus.todo:
        writer.writeByte(0);
        break;
      case TaskStatus.inProgress:
        writer.writeByte(1);
        break;
      case TaskStatus.done:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 17;

  @override
  RecurrenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceType.none;
      case 1:
        return RecurrenceType.daily;
      case 2:
        return RecurrenceType.weekly;
      case 3:
        return RecurrenceType.monthly;
      default:
        return RecurrenceType.none;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    switch (obj) {
      case RecurrenceType.none:
        writer.writeByte(0);
        break;
      case RecurrenceType.daily:
        writer.writeByte(1);
        break;
      case RecurrenceType.weekly:
        writer.writeByte(2);
        break;
      case RecurrenceType.monthly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
