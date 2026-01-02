import 'package:hive/hive.dart';

part 'activity_category.g.dart';

/// Available icons for activities
@HiveType(typeId: 18)
enum ActivityIcon {
  @HiveField(0)
  workout,
  @HiveField(1)
  cardio,
  @HiveField(2)
  study,
  @HiveField(3)
  reading,
  @HiveField(4)
  coding,
  @HiveField(5)
  music,
  @HiveField(6)
  gaming,
  @HiveField(7)
  meditation,
  @HiveField(8)
  journal,
  @HiveField(9)
  language,
  @HiveField(10)
  art,
  @HiveField(11)
  cooking,
  @HiveField(12)
  research,
  @HiveField(13)
  writing,
  @HiveField(14)
  plants,
  @HiveField(15)
  medicine,
  @HiveField(16)
  work,
  @HiveField(17)
  meeting,
  @HiveField(18)
  email,
  @HiveField(19)
  call,
  @HiveField(20)
  shopping,
  @HiveField(21)
  cleaning,
  @HiveField(22)
  travel,
  @HiveField(23)
  social,
  @HiveField(24)
  family,
  @HiveField(25)
  health,
  @HiveField(26)
  finance,
  @HiveField(27)
  learning,
  @HiveField(28)
  project,
  @HiveField(29)
  hobby,
  @HiveField(30)
  custom,
}

/// Map icons to SVG asset names
String getIconAsset(ActivityIcon icon) {
  switch (icon) {
    case ActivityIcon.workout:
      return 'assets/icons/zap.svg';
    case ActivityIcon.cardio:
      return 'assets/icons/flame.svg';
    case ActivityIcon.study:
      return 'assets/icons/bookmark.svg';
    case ActivityIcon.reading:
      return 'assets/icons/layers.svg';
    case ActivityIcon.coding:
      return 'assets/icons/monitor.svg';
    case ActivityIcon.music:
      return 'assets/icons/music.svg';
    case ActivityIcon.gaming:
      return 'assets/icons/target.svg';
    case ActivityIcon.meditation:
      return 'assets/icons/moon.svg';
    case ActivityIcon.journal:
      return 'assets/icons/edit.svg';
    case ActivityIcon.language:
      return 'assets/icons/globe.svg';
    case ActivityIcon.art:
      return 'assets/icons/star.svg';
    case ActivityIcon.cooking:
      return 'assets/icons/flame.svg';
    case ActivityIcon.research:
      return 'assets/icons/search.svg';
    case ActivityIcon.writing:
      return 'assets/icons/edit.svg';
    case ActivityIcon.plants:
      return 'assets/icons/sun.svg';
    case ActivityIcon.medicine:
      return 'assets/icons/shield.svg';
    case ActivityIcon.work:
      return 'assets/icons/inbox.svg';
    case ActivityIcon.meeting:
      return 'assets/icons/profile.svg';
    case ActivityIcon.email:
      return 'assets/icons/email.svg';
    case ActivityIcon.call:
      return 'assets/icons/smartphone.svg';
    case ActivityIcon.shopping:
      return 'assets/icons/badge.svg';
    case ActivityIcon.cleaning:
      return 'assets/icons/home.svg';
    case ActivityIcon.travel:
      return 'assets/icons/external-link.svg';
    case ActivityIcon.social:
      return 'assets/icons/share.svg';
    case ActivityIcon.family:
      return 'assets/icons/profile.svg';
    case ActivityIcon.health:
      return 'assets/icons/shield.svg';
    case ActivityIcon.finance:
      return 'assets/icons/statistics.svg';
    case ActivityIcon.learning:
      return 'assets/icons/layers.svg';
    case ActivityIcon.project:
      return 'assets/icons/grid.svg';
    case ActivityIcon.hobby:
      return 'assets/icons/star.svg';
    case ActivityIcon.custom:
      return 'assets/icons/plus.svg';
  }
}

/// Activity category model
@HiveType(typeId: 2)
class ActivityCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  ActivityIcon icon;

  @HiveField(3)
  String colorHex;

  @HiveField(4)
  int weeklyGoal; // Target sessions per week

  @HiveField(5)
  int sortOrder;

  @HiveField(6)
  bool isDefault;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? linkedGoalId; // Optional link to a PersonalGoal

  ActivityCategory({
    required this.id,
    required this.name,
    this.icon = ActivityIcon.custom,
    this.colorHex = 'FF6B6B',
    this.weeklyGoal = 7,
    this.sortOrder = 0,
    this.isDefault = false,
    this.linkedGoalId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ActivityCategory copyWith({
    String? id,
    String? name,
    ActivityIcon? icon,
    String? colorHex,
    int? weeklyGoal,
    int? sortOrder,
    bool? isDefault,
    DateTime? createdAt,
    String? linkedGoalId,
  }) {
    return ActivityCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      linkedGoalId: linkedGoalId ?? this.linkedGoalId,
    );
  }

  /// Get color from hex
  int get colorValue => int.parse('FF$colorHex', radix: 16);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Default activity categories
List<ActivityCategory> getDefaultCategories() {
  return [
    ActivityCategory(
      id: 'workout',
      name: 'Workout',
      icon: ActivityIcon.workout,
      colorHex: '4ECDC4',
      weeklyGoal: 6,
      sortOrder: 0,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'cardio',
      name: 'Cardio',
      icon: ActivityIcon.cardio,
      colorHex: 'FF6B6B',
      weeklyGoal: 4,
      sortOrder: 1,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'study',
      name: 'Study',
      icon: ActivityIcon.study,
      colorHex: '45B7D1',
      weeklyGoal: 6,
      sortOrder: 2,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'reading',
      name: 'Reading',
      icon: ActivityIcon.reading,
      colorHex: '96CEB4',
      weeklyGoal: 6,
      sortOrder: 3,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'coding',
      name: 'Coding',
      icon: ActivityIcon.coding,
      colorHex: 'DDA0DD',
      weeklyGoal: 6,
      sortOrder: 4,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'music',
      name: 'Music',
      icon: ActivityIcon.music,
      colorHex: 'FFD93D',
      weeklyGoal: 6,
      sortOrder: 5,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'meditation',
      name: 'Meditation',
      icon: ActivityIcon.meditation,
      colorHex: 'C9B1FF',
      weeklyGoal: 7,
      sortOrder: 6,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'journal',
      name: 'Journal',
      icon: ActivityIcon.journal,
      colorHex: 'F8B500',
      weeklyGoal: 7,
      sortOrder: 7,
      isDefault: true,
    ),
    ActivityCategory(
      id: 'language',
      name: 'Language',
      icon: ActivityIcon.language,
      colorHex: '00D4AA',
      weeklyGoal: 6,
      sortOrder: 8,
      isDefault: true,
    ),
  ];
}
