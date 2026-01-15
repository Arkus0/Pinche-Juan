import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../timeline_orchestrator/domain/models/cooking_task.dart';

/// Display card for an active cooking task with live countdown
///
/// Shows:
/// - Task name prominently
/// - Large countdown timer
/// - Progress indicator
/// - Complete button
class ActiveTimerCard extends StatefulWidget {
  const ActiveTimerCard({
    super.key,
    required this.task,
    required this.onComplete,
  });

  final CookingTask task;
  final VoidCallback onComplete;

  @override
  State<ActiveTimerCard> createState() => _ActiveTimerCardState();
}

class _ActiveTimerCardState extends State<ActiveTimerCard> {
  Timer? _timer;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateRemaining();
        });
      }
    });
  }

  void _updateRemaining() {
    if (widget.task.calculatedEndTime == null) {
      _remaining = Duration.zero;
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(widget.task.calculatedEndTime!)) {
      _remaining = Duration.zero;
    } else {
      _remaining = widget.task.calculatedEndTime!.difference(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final isOvertime = _remaining == Duration.zero;

    return Card(
      color: isOvertime ? AppTheme.neonRed.withOpacity(0.2) : null,
      child: Padding(
        padding: const EdgeInsets.all(CombatDimensions.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task name
            Text(
              widget.task.name.toUpperCase(),
              style: Theme.of(context).textTheme.headlineLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Gap(CombatDimensions.spacingMedium),

            // Timer display
            Row(
              children: [
                // Large countdown
                Expanded(
                  child: _buildTimerDisplay(isOvertime),
                ),

                // Complete button
                const Gap(CombatDimensions.spacingMedium),
                _buildCompleteButton(),
              ],
            ),

            const Gap(CombatDimensions.spacingMedium),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.surfaceDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOvertime ? AppTheme.neonRed : AppTheme.neonGreen,
              ),
              borderRadius: BorderRadius.circular(6),
            ),

            // Task notes (if any)
            if (widget.task.notes != null && widget.task.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  top: CombatDimensions.spacingSmall,
                ),
                child: Text(
                  widget.task.notes!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.neonBlue,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(bool isOvertime) {
    final minutes = _remaining?.inMinutes ?? 0;
    final seconds = (_remaining?.inSeconds ?? 0) % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: isOvertime ? AppTheme.neonRed : AppTheme.neonGreen,
                shadows: [
                  Shadow(
                    color: isOvertime ? AppTheme.neonRed : AppTheme.neonGreen,
                    blurRadius: 30,
                  ),
                ],
              ),
        ),
        if (isOvertime)
          Text(
            'OVERTIME!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neonRed,
                ),
          ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.black,
        minimumSize: const Size(
          CombatDimensions.minTapTarget * 2,
          CombatDimensions.minTapTarget * 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: widget.onComplete,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 48),
          const Gap(8),
          Text(
            'COMPLETE',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    if (widget.task.calculatedStartTime == null ||
        widget.task.calculatedEndTime == null) {
      return 0.0;
    }

    final total = widget.task.duration.inSeconds;
    final elapsed = total - (_remaining?.inSeconds ?? 0);

    return (elapsed / total).clamp(0.0, 1.0);
  }
}
