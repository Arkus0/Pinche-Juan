import '../models/cooking_task.dart';
import '../models/cooking_timeline.dart';

/// Service for calculating optimal task scheduling
///
/// Schedules tasks backwards from a target serving time, respecting dependencies
/// and priorities to create an executable cooking timeline
class TimelineScheduler {
  /// Calculate start times for all tasks in a timeline
  ///
  /// Algorithm:
  /// 1. Start from targetServingTime
  /// 2. Sort tasks by priority and dependencies
  /// 3. For each task, calculate its start time by subtracting duration
  /// 4. Handle parallel tasks (tasks that can run simultaneously)
  /// 5. Apply buffer time for critical tasks
  ///
  /// Returns a new [CookingTimeline] with calculated times
  CookingTimeline scheduleTimeline(CookingTimeline timeline) {
    if (timeline.tasks.isEmpty) {
      return timeline;
    }

    // Step 1: Build dependency graph
    final taskMap = {for (var task in timeline.tasks) task.id: task};
    final scheduledTasks = <CookingTask>[];

    // Step 2: Separate tasks by dependency level
    final independentTasks = timeline.tasks
        .where((task) => task.dependencies.isEmpty)
        .toList();

    final dependentTasks = timeline.tasks
        .where((task) => task.dependencies.isNotEmpty)
        .toList();

    // Step 3: Schedule independent tasks backward from target time
    DateTime currentEndTime = timeline.targetServingTime;

    // Sort independent tasks by priority (critical first)
    independentTasks.sort((a, b) => _comparePriority(a.priority, b.priority));

    for (final task in independentTasks) {
      final scheduledTask = _scheduleTask(task, currentEndTime);
      scheduledTasks.add(scheduledTask);

      // Move the timeline backward for critical tasks (no parallelization)
      // For normal priority tasks, they can potentially run in parallel
      if (task.priority.isCritical) {
        currentEndTime = scheduledTask.calculatedStartTime!;
      }
    }

    // Step 4: Schedule dependent tasks
    for (final task in dependentTasks) {
      // Find the earliest start time based on dependencies
      DateTime? earliestStart;

      for (final depId in task.dependencies) {
        final depTask = scheduledTasks.firstWhere(
          (t) => t.id == depId,
          orElse: () => taskMap[depId]!,
        );

        if (depTask.calculatedEndTime != null) {
          if (earliestStart == null ||
              depTask.calculatedEndTime!.isAfter(earliestStart)) {
            earliestStart = depTask.calculatedEndTime;
          }
        }
      }

      final scheduledTask = _scheduleTask(
        task,
        earliestStart ?? currentEndTime,
      );
      scheduledTasks.add(scheduledTask);
    }

    // Step 5: Optimize for parallelization
    final optimizedTasks = _optimizeParallelTasks(scheduledTasks);

    return timeline.copyWith(
      tasks: optimizedTasks,
      updatedAt: DateTime.now(),
    );
  }

  /// Schedule a single task with calculated start/end times
  CookingTask _scheduleTask(CookingTask task, DateTime endTime) {
    final startTime = endTime.subtract(task.duration);

    return task.copyWith(
      calculatedStartTime: startTime,
      calculatedEndTime: endTime,
    );
  }

  /// Optimize task scheduling to allow parallel execution
  ///
  /// Tasks with normal/low priority that don't conflict can run simultaneously
  /// This creates a more realistic and efficient timeline
  List<CookingTask> _optimizeParallelTasks(List<CookingTask> tasks) {
    if (tasks.length <= 1) return tasks;

    final optimized = <CookingTask>[];
    final sorted = [...tasks]..sort((a, b) =>
        a.calculatedEndTime!.compareTo(b.calculatedEndTime!));

    for (final task in sorted) {
      if (task.priority.isCritical) {
        // Critical tasks maintain their position
        optimized.add(task);
        continue;
      }

      // Check if this task can start earlier by running parallel to others
      final earliestPossibleStart = _findEarliestParallelStart(
        task,
        optimized,
      );

      if (earliestPossibleStart != null &&
          earliestPossibleStart.isBefore(task.calculatedStartTime!)) {
        // Task can start earlier - reschedule it
        optimized.add(task.copyWith(
          calculatedStartTime: earliestPossibleStart,
          calculatedEndTime: earliestPossibleStart.add(task.duration),
        ));
      } else {
        optimized.add(task);
      }
    }

    return optimized;
  }

  /// Find the earliest time a task can start while running parallel
  DateTime? _findEarliestParallelStart(
    CookingTask task,
    List<CookingTask> scheduledTasks,
  ) {
    if (scheduledTasks.isEmpty) return null;

    // A task can run parallel if it doesn't overlap with more than 2 other tasks
    // (assuming cook can manage 2-3 simultaneous tasks)
    const maxParallelTasks = 2;

    DateTime? earliestStart;

    for (final other in scheduledTasks) {
      if (other.priority.isCritical) continue;

      // Check how many tasks are running at other's start time
      final overlappingCount = scheduledTasks.where((t) {
        if (t.calculatedStartTime == null || t.calculatedEndTime == null) {
          return false;
        }
        return _tasksOverlap(
          t.calculatedStartTime!,
          t.calculatedEndTime!,
          other.calculatedStartTime!,
          other.calculatedEndTime!,
        );
      }).length;

      if (overlappingCount < maxParallelTasks) {
        final potentialStart = other.calculatedStartTime!;
        if (earliestStart == null || potentialStart.isBefore(earliestStart)) {
          earliestStart = potentialStart;
        }
      }
    }

    return earliestStart;
  }

  /// Check if two time ranges overlap
  bool _tasksOverlap(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  /// Compare task priorities for sorting
  int _comparePriority(TaskPriority a, TaskPriority b) {
    const priorityOrder = {
      TaskPriority.critical: 0,
      TaskPriority.high: 1,
      TaskPriority.normal: 2,
      TaskPriority.low: 3,
    };

    return priorityOrder[a]!.compareTo(priorityOrder[b]!);
  }

  /// Calculate buffer time recommendations
  ///
  /// Suggests adding buffer time before critical tasks to account for delays
  Duration calculateBufferTime(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return const Duration(minutes: 5);
      case TaskPriority.high:
        return const Duration(minutes: 3);
      case TaskPriority.normal:
      case TaskPriority.low:
        return Duration.zero;
    }
  }

  /// Validate timeline feasibility
  ///
  /// Checks if the timeline is realistic and can be executed
  TimelineValidation validateTimeline(CookingTimeline timeline) {
    final issues = <String>[];
    final warnings = <String>[];

    // Check if first task starts in the past
    final firstStart = timeline.firstTaskStartTime;
    if (firstStart != null && firstStart.isBefore(DateTime.now())) {
      issues.add(
        'Timeline starts in the past (${_formatTime(firstStart)}). '
        'Adjust target time or reduce task durations.',
      );
    }

    // Check for unrealistic parallel task count
    final maxSimultaneousTasks = _getMaxSimultaneousTasks(timeline);
    if (maxSimultaneousTasks > 3) {
      warnings.add(
        'Up to $maxSimultaneousTasks tasks running simultaneously. '
        'This may be challenging to execute.',
      );
    }

    // Check for very long gaps between tasks
    final gaps = _findLargeGaps(timeline);
    if (gaps.isNotEmpty) {
      for (final gap in gaps) {
        warnings.add(
          'Large gap (${gap.inMinutes} minutes) in timeline. '
          'Consider optimizing task scheduling.',
        );
      }
    }

    return TimelineValidation(
      isValid: issues.isEmpty,
      issues: issues,
      warnings: warnings,
    );
  }

  /// Get maximum number of tasks running at the same time
  int _getMaxSimultaneousTasks(CookingTimeline timeline) {
    if (timeline.tasks.isEmpty) return 0;

    final events = <_TimelineEvent>[];

    for (final task in timeline.tasks) {
      if (task.calculatedStartTime == null || task.calculatedEndTime == null) {
        continue;
      }
      events.add(_TimelineEvent(task.calculatedStartTime!, isStart: true));
      events.add(_TimelineEvent(task.calculatedEndTime!, isStart: false));
    }

    events.sort((a, b) => a.time.compareTo(b.time));

    var maxConcurrent = 0;
    var currentConcurrent = 0;

    for (final event in events) {
      if (event.isStart) {
        currentConcurrent++;
        if (currentConcurrent > maxConcurrent) {
          maxConcurrent = currentConcurrent;
        }
      } else {
        currentConcurrent--;
      }
    }

    return maxConcurrent;
  }

  /// Find large gaps between tasks
  List<Duration> _findLargeGaps(CookingTimeline timeline) {
    final gaps = <Duration>[];
    final sorted = timeline.tasksByStartTime;

    for (var i = 0; i < sorted.length - 1; i++) {
      final current = sorted[i];
      final next = sorted[i + 1];

      if (current.calculatedEndTime != null &&
          next.calculatedStartTime != null) {
        final gap = next.calculatedStartTime!
            .difference(current.calculatedEndTime!);

        // Consider gaps over 15 minutes as "large"
        if (gap.inMinutes > 15) {
          gaps.add(gap);
        }
      }
    }

    return gaps;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

/// Helper class for timeline event processing
class _TimelineEvent {
  _TimelineEvent(this.time, {required this.isStart});

  final DateTime time;
  final bool isStart;
}

/// Result of timeline validation
class TimelineValidation {
  const TimelineValidation({
    required this.isValid,
    required this.issues,
    required this.warnings,
  });

  final bool isValid;
  final List<String> issues;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => issues.isNotEmpty;
}
