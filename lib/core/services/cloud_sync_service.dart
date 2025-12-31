import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../features/tasks/domain/models/task.dart';
import '../../features/activities/domain/models/activity_category.dart';
import '../../features/activities/domain/models/activity_session.dart';
import '../constants/app_constants.dart';

/// Sync status for UI
enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  offline,
}

/// Sync result wrapper
class SyncResult {
  final bool success;
  final String? error;
  final int itemsSynced;

  const SyncResult({
    required this.success,
    this.error,
    this.itemsSynced = 0,
  });

  factory SyncResult.success([int items = 0]) {
    return SyncResult(success: true, itemsSynced: items);
  }

  factory SyncResult.failure(String error) {
    return SyncResult(success: false, error: error);
  }
}

/// Service for syncing data to/from Firestore
class CloudSyncService {
  final FirebaseFirestore _firestore;
  
  // Stream controllers
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  CloudSyncService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================
  // USER DATA
  // ============================================

  /// Get user document reference
  DocumentReference _userDoc(String userId) {
    return _firestore.collection(AppConstants.usersCollection).doc(userId);
  }

  /// Get user's tasks collection
  CollectionReference _tasksCollection(String userId) {
    return _userDoc(userId).collection(AppConstants.tasksCollection);
  }

  /// Get user's categories collection
  CollectionReference _categoriesCollection(String userId) {
    return _userDoc(userId).collection('categories');
  }

  /// Get user's sessions collection
  CollectionReference _sessionsCollection(String userId) {
    return _userDoc(userId).collection(AppConstants.sessionsCollection);
  }

  /// Get user's statistics document
  DocumentReference _statisticsDoc(String userId) {
    return _userDoc(userId).collection(AppConstants.statisticsCollection).doc('stats');
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Create or update user profile
  Future<SyncResult> syncUserProfile({
    required String userId,
    required String? email,
    required String? displayName,
    String? photoUrl,
    bool isPremium = false,
    DateTime? premiumExpiresAt,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      await _userDoc(userId).set({
        'uid': userId,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isPremium': isPremium,
        'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
        'lastSyncAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _updateStatus(SyncStatus.synced);
      return SyncResult.success();
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Failed to sync profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('CloudSyncService: Error getting user profile - $e');
      return null;
    }
  }

  // ============================================
  // TASKS SYNC
  // ============================================

  /// Sync all tasks to Firestore
  Future<SyncResult> syncTasks({
    required String userId,
    required List<Task> tasks,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      final batch = _firestore.batch();
      final collection = _tasksCollection(userId);

      for (final task in tasks) {
        final docRef = collection.doc(task.id);
        batch.set(docRef, _taskToFirestore(task), SetOptions(merge: true));
      }

      await batch.commit();

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.synced);
      return SyncResult.success(tasks.length);
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Failed to sync tasks: $e');
    }
  }

  /// Get all tasks from Firestore
  Future<List<Task>> fetchTasks(String userId) async {
    try {
      final snapshot = await _tasksCollection(userId).get();
      return snapshot.docs
          .map((doc) => _taskFromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CloudSyncService: Error fetching tasks - $e');
      return [];
    }
  }

  /// Delete a task from Firestore
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
    } catch (e) {
      debugPrint('CloudSyncService: Error deleting task - $e');
    }
  }

  /// Listen to tasks changes (real-time)
  Stream<List<Task>> watchTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _taskFromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ============================================
  // CATEGORIES SYNC
  // ============================================

  /// Sync all categories to Firestore
  Future<SyncResult> syncCategories({
    required String userId,
    required List<ActivityCategory> categories,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      final batch = _firestore.batch();
      final collection = _categoriesCollection(userId);

      for (final category in categories) {
        final docRef = collection.doc(category.id);
        batch.set(docRef, _categoryToFirestore(category), SetOptions(merge: true));
      }

      await batch.commit();

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.synced);
      return SyncResult.success(categories.length);
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Failed to sync categories: $e');
    }
  }

  /// Get all categories from Firestore
  Future<List<ActivityCategory>> fetchCategories(String userId) async {
    try {
      final snapshot = await _categoriesCollection(userId).get();
      return snapshot.docs
          .map((doc) => _categoryFromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CloudSyncService: Error fetching categories - $e');
      return [];
    }
  }

  /// Delete a category from Firestore
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _categoriesCollection(userId).doc(categoryId).delete();
    } catch (e) {
      debugPrint('CloudSyncService: Error deleting category - $e');
    }
  }

  // ============================================
  // SESSIONS SYNC
  // ============================================

  /// Sync all sessions to Firestore
  Future<SyncResult> syncSessions({
    required String userId,
    required List<ActivitySession> sessions,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      // Sync in batches of 500 (Firestore limit)
      const batchSize = 500;
      int synced = 0;

      for (var i = 0; i < sessions.length; i += batchSize) {
        final batch = _firestore.batch();
        final collection = _sessionsCollection(userId);
        final end = (i + batchSize < sessions.length) ? i + batchSize : sessions.length;
        final batchSessions = sessions.sublist(i, end);

        for (final session in batchSessions) {
          final docRef = collection.doc(session.id);
          batch.set(docRef, _sessionToFirestore(session), SetOptions(merge: true));
        }

        await batch.commit();
        synced += batchSessions.length;
      }

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.synced);
      return SyncResult.success(synced);
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Failed to sync sessions: $e');
    }
  }

  /// Get sessions from Firestore (with optional date range)
  Future<List<ActivitySession>> fetchSessions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _sessionsCollection(userId);

      if (startDate != null) {
        query = query.where('startTime', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.where('startTime', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _sessionFromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CloudSyncService: Error fetching sessions - $e');
      return [];
    }
  }

  // ============================================
  // STATISTICS SYNC
  // ============================================

  /// Sync user statistics
  Future<SyncResult> syncStatistics({
    required String userId,
    required int totalFocusMinutes,
    required int totalSessions,
    required int currentStreak,
    required int longestStreak,
    required int totalXp,
    required int currentLevel,
    required List<String> achievements,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      await _statisticsDoc(userId).set({
        'totalFocusMinutes': totalFocusMinutes,
        'totalSessions': totalSessions,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalXp': totalXp,
        'currentLevel': currentLevel,
        'achievements': achievements,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.synced);
      return SyncResult.success();
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Failed to sync statistics: $e');
    }
  }

  /// Get statistics from Firestore
  Future<Map<String, dynamic>?> fetchStatistics(String userId) async {
    try {
      final doc = await _statisticsDoc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('CloudSyncService: Error fetching statistics - $e');
      return null;
    }
  }

  // ============================================
  // FULL SYNC
  // ============================================

  /// Perform full sync of all data
  Future<SyncResult> fullSync({
    required String userId,
    required List<Task> tasks,
    required List<ActivityCategory> categories,
    required List<ActivitySession> sessions,
    required Map<String, dynamic> statistics,
    String? email,
    String? displayName,
    bool isPremium = false,
  }) async {
    try {
      _updateStatus(SyncStatus.syncing);

      // Sync profile
      await syncUserProfile(
        userId: userId,
        email: email,
        displayName: displayName,
        isPremium: isPremium,
      );

      // Sync data concurrently
      final results = await Future.wait([
        syncTasks(userId: userId, tasks: tasks),
        syncCategories(userId: userId, categories: categories),
        syncSessions(userId: userId, sessions: sessions),
        syncStatistics(
          userId: userId,
          totalFocusMinutes: statistics['totalFocusMinutes'] ?? 0,
          totalSessions: statistics['totalSessions'] ?? 0,
          currentStreak: statistics['currentStreak'] ?? 0,
          longestStreak: statistics['longestStreak'] ?? 0,
          totalXp: statistics['totalXp'] ?? 0,
          currentLevel: statistics['currentLevel'] ?? 1,
          achievements: List<String>.from(statistics['achievements'] ?? []),
        ),
      ]);

      final totalSynced = results.fold<int>(0, (sum, r) => sum + r.itemsSynced);
      final hasError = results.any((r) => !r.success);

      if (hasError) {
        _updateStatus(SyncStatus.error);
        return SyncResult.failure('Some data failed to sync');
      }

      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.synced);
      return SyncResult.success(totalSynced);
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return SyncResult.failure('Full sync failed: $e');
    }
  }

  /// Download all data from Firestore
  Future<Map<String, dynamic>> downloadAllData(String userId) async {
    try {
      _updateStatus(SyncStatus.syncing);

      final results = await Future.wait([
        fetchTasks(userId),
        fetchCategories(userId),
        fetchSessions(userId),
        fetchStatistics(userId),
        getUserProfile(userId),
      ]);

      _updateStatus(SyncStatus.synced);

      return {
        'tasks': results[0],
        'categories': results[1],
        'sessions': results[2],
        'statistics': results[3],
        'profile': results[4],
      };
    } catch (e) {
      _updateStatus(SyncStatus.error);
      return {};
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// Convert Task to Firestore document
  Map<String, dynamic> _taskToFirestore(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'isCompleted': task.isCompleted,
      'priority': task.priority.index,
      'createdAt': task.createdAt.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'estimatedPomodoros': task.estimatedPomodoros,
      'completedPomodoros': task.completedPomodoros,
      'projectId': task.projectId,
      'tags': task.tags,
      'sortOrder': task.sortOrder,
    };
  }

  /// Convert Firestore document to Task
  Task _taskFromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[data['priority'] as int? ?? 1],
      createdAt: DateTime.parse(data['createdAt'] as String),
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate'] as String) : null,
      estimatedPomodoros: data['estimatedPomodoros'] as int? ?? 1,
      completedPomodoros: data['completedPomodoros'] as int? ?? 0,
      projectId: data['projectId'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      sortOrder: data['sortOrder'] as int? ?? 0,
    );
  }

  /// Convert ActivityCategory to Firestore document
  Map<String, dynamic> _categoryToFirestore(ActivityCategory category) {
    return {
      'id': category.id,
      'name': category.name,
      'icon': category.icon.index,
      'colorHex': category.colorHex,
      'weeklyGoal': category.weeklyGoal,
      'sortOrder': category.sortOrder,
      'isDefault': category.isDefault,
      'createdAt': category.createdAt.toIso8601String(),
    };
  }

  /// Convert Firestore document to ActivityCategory
  ActivityCategory _categoryFromFirestore(Map<String, dynamic> data) {
    return ActivityCategory(
      id: data['id'] as String,
      name: data['name'] as String,
      icon: ActivityIcon.values[data['icon'] as int? ?? 0],
      colorHex: data['colorHex'] as String? ?? 'FF6B6B',
      weeklyGoal: data['weeklyGoal'] as int? ?? 7,
      sortOrder: data['sortOrder'] as int? ?? 0,
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }

  /// Convert ActivitySession to Firestore document
  Map<String, dynamic> _sessionToFirestore(ActivitySession session) {
    return {
      'id': session.id,
      'categoryId': session.categoryId,
      'startTime': session.startTime.toIso8601String(),
      'durationMinutes': session.durationMinutes,
      'taskId': session.taskId,
      'notes': session.notes,
      'pomodorosCompleted': session.pomodorosCompleted,
    };
  }

  /// Convert Firestore document to ActivitySession
  ActivitySession _sessionFromFirestore(Map<String, dynamic> data) {
    return ActivitySession(
      id: data['id'] as String,
      categoryId: data['categoryId'] as String,
      startTime: DateTime.parse(data['startTime'] as String),
      durationMinutes: data['durationMinutes'] as int,
      taskId: data['taskId'] as String?,
      notes: data['notes'] as String?,
      pomodorosCompleted: data['pomodorosCompleted'] as int? ?? 1,
    );
  }

  /// Dispose resources
  void dispose() {
    _syncStatusController.close();
  }
}
