import 'package:freezed_annotation/freezed_annotation.dart';
import 'cooking_task.dart';

part 'cooking_timeline.freezed.dart';
part 'cooking_timeline.g.dart';

/// A complete cooking timeline with multiple tasks scheduled backwards from a target time
@freezed
class CookingTimeline with _$CookingTimeline {
  const factory CookingTimeline({
    required String id,
    required String name,
    required DateTime targetServingTime,
    @Default([]) List<CookingTask> tasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CookingTimeline;

  factory CookingTimeline.fromJson(Map<String, dynamic> json) =>
      _$CookingTimelineFromJson(json);

  const CookingTimeline._();

  /// Get the earliest start time across all tasks
  DateTime? get firstTaskStartTime {
    if (tasks.isEmpty) return null;
    final scheduledTasks = tasks
        .where((task) => task.calculatedStartTime != null)
        .toList();
    if (scheduledTasks.isEmpty) return null;

    scheduledTasks.sort((a, b) =>
        a.calculatedStartTime!.compareTo(b.calculatedStartTime!));
    return scheduledTasks.first.calculatedStartTime;
  }

  /// Total duration of all tasks if done sequentially
  Duration get totalSequentialDuration {
    return tasks.fold(
      Duration.zero,
      (total, task) => total + task.duration,
    );
  }

  /// Get tasks sorted by start time
  List<CookingTask> get tasksByStartTime {
    final scheduled = tasks
        .where((task) => task.calculatedStartTime != null)
        .toList();
    scheduled.sort((a, b) =>
        a.calculatedStartTime!.compareTo(b.calculatedStartTime!));
    return scheduled;
  }

  /// Get currently active tasks
  List<CookingTask> get activeTasks {
    return tasks.where((task) => task.isActive).toList();
  }

  /// Get next task to start
  CookingTask? get nextTask {
    final pending = tasks
        .where((task) =>
            task.status.isPending &&
            task.calculatedStartTime != null &&
            task.calculatedStartTime!.isAfter(DateTime.now()))
        .toList();

    if (pending.isEmpty) return null;

    pending.sort((a, b) =>
        a.calculatedStartTime!.compareTo(b.calculatedStartTime!));
    return pending.first;
  }

  /// Check if timeline has started
  bool get hasStarted {
    final first = firstTaskStartTime;
    if (first == null) return false;
    return DateTime.now().isAfter(first);
  }

  /// Time until the timeline starts
  Duration? get timeUntilStart {
    final first = firstTaskStartTime;
    if (first == null) return null;
    final now = DateTime.now();
    if (now.isAfter(first)) return Duration.zero;
    return first.difference(now);
  }

  /// Completion percentage
  double get completionPercentage {
    if (tasks.isEmpty) return 0.0;
    final completed = tasks.where((task) => task.status.isCompleted).length;
    return completed / tasks.length;
  }
}
