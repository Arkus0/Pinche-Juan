import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../timeline_orchestrator/domain/models/cooking_task.dart';
import '../providers/combat_mode_provider.dart';
import '../widgets/active_timer_card.dart';
import '../widgets/next_task_card.dart';
import '../widgets/critical_alert_banner.dart';

/// Combat Mode Dashboard
///
/// The primary interface for active cooking sessions.
/// Designed for maximum visibility and ease of use during cooking.
///
/// Features:
/// - Always-on display (wakelock)
/// - Large, knuckle-tap friendly buttons
/// - High contrast neon-on-dark color scheme
/// - Critical alerts prominently displayed
/// - Active timer(s) at-a-glance
/// - Next task preview
class CombatModeDashboard extends ConsumerStatefulWidget {
  const CombatModeDashboard({super.key});

  @override
  ConsumerState<CombatModeDashboard> createState() =>
      _CombatModeDashboardState;
}

class _CombatModeDashboardState extends ConsumerState<CombatModeDashboard> {
  @override
  void initState() {
    super.initState();
    // Lock to landscape orientation for better visibility
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore orientation settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Show status bar again
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final combatState = ref.watch(combatModeProvider);
    final criticalTasks = ref.watch(criticalTasksProvider);
    final nextTask = ref.watch(nextTaskProvider);

    return Theme(
      data: AppTheme.combatModeTheme,
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: combatState.activeTimeline == null
              ? _buildInactiveState()
              : _buildActiveState(
                  combatState.currentTasks,
                  criticalTasks,
                  nextTask,
                ),
        ),
      ),
    );
  }

  /// Inactive state - No active cooking session
  Widget _buildInactiveState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off,
            size: 120,
            color: AppTheme.neonGreen.withOpacity(0.3),
          ),
          const Gap(CombatDimensions.spacingLarge),
          Text(
            'NO ACTIVE SESSION',
            style: AppTheme.combatModeTheme.textTheme.displayMedium,
          ),
          const Gap(CombatDimensions.spacingMedium),
          Text(
            'Start a timeline to enter Combat Mode',
            style: AppTheme.combatModeTheme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Active state - Cooking session in progress
  Widget _buildActiveState(
    List<CookingTask> activeTasks,
    List<CookingTask> criticalTasks,
    CookingTask? nextTask,
  ) {
    return Column(
      children: [
        // Critical alerts banner (if any)
        if (criticalTasks.isNotEmpty)
          CriticalAlertBanner(tasks: criticalTasks),

        // Main content area
        Expanded(
          child: Row(
            children: [
              // Left side - Active timers
              Expanded(
                flex: 3,
                child: _buildActiveTimersSection(activeTasks),
              ),

              // Vertical divider
              Container(
                width: 2,
                color: AppTheme.neonGreen.withOpacity(0.3),
              ),

              // Right side - Next task + controls
              Expanded(
                flex: 2,
                child: _buildNextTaskSection(nextTask),
              ),
            ],
          ),
        ),

        // Bottom control bar
        _buildControlBar(),
      ],
    );
  }

  /// Active timers section
  Widget _buildActiveTimersSection(List<CookingTask> activeTasks) {
    if (activeTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.neonGreen,
            ),
            const Gap(CombatDimensions.spacingMedium),
            Text(
              'NO ACTIVE TASKS',
              style: AppTheme.combatModeTheme.textTheme.headlineLarge,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(CombatDimensions.spacingLarge),
      itemCount: activeTasks.length,
      separatorBuilder: (_, __) => const Gap(CombatDimensions.spacingMedium),
      itemBuilder: (context, index) {
        final task = activeTasks[index];
        return ActiveTimerCard(
          task: task,
          onComplete: () => _completeTask(task.id),
        );
      },
    );
  }

  /// Next task section
  Widget _buildNextTaskSection(CookingTask? nextTask) {
    return Padding(
      padding: const EdgeInsets.all(CombatDimensions.spacingLarge),
      child: Column(
        children: [
          // "NEXT UP" header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CombatDimensions.spacingMedium,
              vertical: CombatDimensions.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.neonBlue,
                width: 2,
              ),
            ),
            child: Text(
              'NEXT UP',
              style: AppTheme.combatModeTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.neonBlue,
              ),
            ),
          ),

          const Gap(CombatDimensions.spacingMedium),

          // Next task card
          Expanded(
            child: nextTask != null
                ? NextTaskCard(task: nextTask)
                : _buildNoNextTaskState(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoNextTaskState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.celebration,
            size: 60,
            color: AppTheme.neonYellow,
          ),
          const Gap(CombatDimensions.spacingMedium),
          Text(
            'ALL TASKS\nCOMPLETE',
            textAlign: TextAlign.center,
            style: AppTheme.combatModeTheme.textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  /// Bottom control bar with emergency actions
  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(CombatDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        border: Border(
          top: BorderSide(
            color: AppTheme.neonGreen.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.pause_circle,
            label: 'PAUSE',
            color: AppTheme.neonYellow,
            onPressed: _pauseSession,
          ),
          _buildControlButton(
            icon: Icons.skip_next,
            label: 'SKIP',
            color: AppTheme.neonOrange,
            onPressed: _skipCurrentTask,
          ),
          _buildControlButton(
            icon: Icons.stop_circle,
            label: 'END',
            color: AppTheme.neonRed,
            onPressed: _endSession,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        minimumSize: const Size(150, CombatDimensions.minTapTarget),
      ),
      onPressed: () {
        _hapticFeedback();
        onPressed();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const Gap(4),
          Text(label),
        ],
      ),
    );
  }

  // Action handlers

  void _completeTask(String taskId) {
    _hapticFeedback();
    ref.read(combatModeProvider.notifier).completeTask(taskId);

    // Show completion feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task completed!'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pauseSession() {
    // TODO: Implement pause functionality
    _showNotImplemented('Pause');
  }

  void _skipCurrentTask() {
    // TODO: Implement skip functionality
    _showNotImplemented('Skip');
  }

  Future<void> _endSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'Are you sure you want to end the cooking session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.neonRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('END'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(combatModeProvider.notifier).deactivate();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
        backgroundColor: AppTheme.neonOrange,
      ),
    );
  }

  /// Haptic feedback for button presses
  Future<void> _hapticFeedback() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }
}
