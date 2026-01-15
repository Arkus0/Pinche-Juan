import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../timeline_orchestrator/domain/models/cooking_task.dart';
import '../../../timeline_orchestrator/domain/models/cooking_timeline.dart';

part 'combat_mode_provider.g.dart';

/// Provider for Combat Mode state
///
/// Manages screen wake lock, active timers, and cooking session state
@riverpod
class CombatMode extends _$CombatMode {
  @override
  CombatModeState build() {
    // Enable wakelock when combat mode is active
    _enableWakeLock();

    return const CombatModeState(
      isActive: false,
      activeTimeline: null,
      currentTasks: [],
    );
  }

  /// Activate Combat Mode with a timeline
  Future<void> activate(CookingTimeline timeline) async {
    await _enableWakeLock();
    state = state.copyWith(
      isActive: true,
      activeTimeline: timeline,
      currentTasks: timeline.activeTasks,
    );
  }

  /// Deactivate Combat Mode
  Future<void> deactivate() async {
    await _disableWakeLock();
    state = const CombatModeState(
      isActive: false,
      activeTimeline: null,
      currentTasks: [],
    );
  }

  /// Update active tasks (called by timer provider)
  void updateActiveTasks(List<CookingTask> tasks) {
    state = state.copyWith(currentTasks: tasks);
  }

  /// Mark a task as completed
  void completeTask(String taskId) {
    if (state.activeTimeline == null) return;

    final updatedTasks = state.activeTimeline!.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(status: TaskStatus.completed);
      }
      return task;
    }).toList();

    final updatedTimeline = state.activeTimeline!.copyWith(
      tasks: updatedTasks,
    );

    state = state.copyWith(
      activeTimeline: updatedTimeline,
      currentTasks: updatedTimeline.activeTasks,
    );
  }

  /// Enable screen wakelock
  Future<void> _enableWakeLock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      // Handle wakelock error gracefully
      print('Failed to enable wakelock: $e');
    }
  }

  /// Disable screen wakelock
  Future<void> _disableWakeLock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      print('Failed to disable wakelock: $e');
    }
  }
}

/// Combat Mode state
class CombatModeState {
  const CombatModeState({
    required this.isActive,
    required this.activeTimeline,
    required this.currentTasks,
  });

  final bool isActive;
  final CookingTimeline? activeTimeline;
  final List<CookingTask> currentTasks;

  CombatModeState copyWith({
    bool? isActive,
    CookingTimeline? activeTimeline,
    List<CookingTask>? currentTasks,
  }) {
    return CombatModeState(
      isActive: isActive ?? this.isActive,
      activeTimeline: activeTimeline ?? this.activeTimeline,
      currentTasks: currentTasks ?? this.currentTasks,
    );
  }
}

/// Provider for next task to start
@riverpod
CookingTask? nextTask(NextTaskRef ref) {
  final combatState = ref.watch(combatModeProvider);
  return combatState.activeTimeline?.nextTask;
}

/// Provider for critical tasks (need immediate attention)
@riverpod
List<CookingTask> criticalTasks(CriticalTasksRef ref) {
  final combatState = ref.watch(combatModeProvider);
  if (combatState.activeTimeline == null) return [];

  return combatState.activeTimeline!.tasks
      .where((task) =>
          task.priority.isCritical &&
          (task.isActive || task.shouldStartNow))
      .toList();
}
