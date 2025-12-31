import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'custom_counter.g.dart';

/// A custom counter/habit that the user can track
@HiveType(typeId: 11)
class CustomCounter extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final int iconCodePoint;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final int targetCount;

  @HiveField(6)
  final CounterType type;

  @HiveField(7)
  final DateTime createdAt;

  CustomCounter({
    required this.id,
    required this.name,
    this.description,
    required this.iconCodePoint,
    required this.colorValue,
    required this.targetCount,
    required this.type,
    required this.createdAt,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  factory CustomCounter.create({
    required String name,
    String? description,
    required IconData icon,
    required Color color,
    required int targetCount,
    required CounterType type,
  }) {
    return CustomCounter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      targetCount: targetCount,
      type: type,
      createdAt: DateTime.now(),
    );
  }

  CustomCounter copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCodePoint,
    int? colorValue,
    int? targetCount,
    CounterType? type,
    DateTime? createdAt,
  }) {
    return CustomCounter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      targetCount: targetCount ?? this.targetCount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Type of counter
@HiveType(typeId: 12)
enum CounterType {
  @HiveField(0)
  daily, // Resets each day

  @HiveField(1)
  weekly, // Resets each week

  @HiveField(2)
  cumulative, // Never resets, keeps counting
}

/// A single entry/log for a counter
@HiveType(typeId: 13)
class CounterEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String counterId;

  @HiveField(2)
  final int count;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? note;

  CounterEntry({
    required this.id,
    required this.counterId,
    required this.count,
    required this.timestamp,
    this.note,
  });

  factory CounterEntry.create({
    required String counterId,
    required int count,
    String? note,
  }) {
    return CounterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      counterId: counterId,
      count: count,
      timestamp: DateTime.now(),
      note: note,
    );
  }
}
