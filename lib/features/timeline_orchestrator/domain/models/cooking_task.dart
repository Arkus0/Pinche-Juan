import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'cooking_task.freezed.dart';
part 'cooking_task.g.dart';

/// Represents a single cooking task in the timeline
///
/// Each task has a duration and can be scheduled backwards from a target time
@freezed
class CookingTask with _$CookingTask {
  const factory CookingTask({
    required String id,
    required String name,
    required Duration duration,
    DateTime? calculatedStartTime,
    DateTime? calculatedEndTime,
    @Default(0) int orderIndex,
    @Default(TaskStatus.pending) TaskStatus status,
    @Default(TaskPriority.normal) TaskPriority priority,
    String? notes,
    String? icon,
    @Default([]) List<String> dependencies,
  }) = _CookingTask;

  factory CookingTask.fromJson(Map<String, dynamic> json) =>
      _$CookingTaskFromJson(json);

  const CookingTask._();

  /// Create a new task with a generated ID
  factory CookingTask.create({
    required String name,
    required Duration duration,
    int orderIndex = 0,
    TaskPriority priority = TaskPriority.normal,
    String? notes,
    String? icon,
    List<String> dependencies = const [],
  }) {
    return CookingTask(
      id: const Uuid().v4(),
      name: name,
      duration: duration,
      orderIndex: orderIndex,
      priority: priority,
      notes: notes,
      icon: icon,
      dependencies: dependencies,
    );
  }

  /// Duration in minutes (for display)
  int get durationInMinutes => duration.inMinutes;

  /// Human-readable duration
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if this task is scheduled
  bool get isScheduled => calculatedStartTime != null && calculatedEndTime != null;

  /// Time remaining until start (if scheduled)
  Duration? get timeUntilStart {
    if (calculatedStartTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(calculatedStartTime!)) return Duration.zero;
    return calculatedStartTime!.difference(now);
  }

  /// Check if task should start now (within 1 minute window)
  bool get shouldStartNow {
    final remaining = timeUntilStart;
    if (remaining == null) return false;
    return remaining.inMinutes <= 1 && remaining.inMinutes >= 0;
  }

  /// Check if task is currently active
  bool get isActive {
    if (!isScheduled) return false;
    final now = DateTime.now();
    return now.isAfter(calculatedStartTime!) && now.isBefore(calculatedEndTime!);
  }
}

enum TaskStatus {
  pending,
  active,
  paused,
  completed,
  skipped;

  bool get isPending => this == TaskStatus.pending;
  bool get isActive => this == TaskStatus.active;
  bool get isCompleted => this == TaskStatus.completed;
}

enum TaskPriority {
  critical, // Must not be delayed (e.g., "Remove from oven")
  high,     // Important timing (e.g., "Rest meat")
  normal,   // Standard tasks
  low;      // Flexible timing (e.g., "Prep garnish")

  bool get isCritical => this == TaskPriority.critical;
}
