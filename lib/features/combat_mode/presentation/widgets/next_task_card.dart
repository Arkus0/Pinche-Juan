import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../timeline_orchestrator/domain/models/cooking_task.dart';

/// Preview card for the next upcoming task
///
/// Shows countdown until task should start and task details
class NextTaskCard extends StatefulWidget {
  const NextTaskCard({
    super.key,
    required this.task,
  });

  final CookingTask task;

  @override
  State<NextTaskCard> createState() => _NextTaskCardState();
}

class _NextTaskCardState extends State<NextTaskCard> {
  Timer? _timer;
  Duration? _timeUntilStart;

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
    _updateTimeUntilStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateTimeUntilStart();
        });
      }
    });
  }

  void _updateTimeUntilStart() {
    _timeUntilStart = widget.task.timeUntilStart;
  }

  @override
  Widget build(BuildContext context) {
    final shouldStartSoon =
        _timeUntilStart != null && _timeUntilStart!.inMinutes <= 5;

    return Card(
      color: shouldStartSoon
          ? AppTheme.warningAlert.withOpacity(0.2)
          : AppTheme.surfaceDarker,
      child: Padding(
        padding: const EdgeInsets.all(CombatDimensions.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Task icon (if available)
            if (widget.task.icon != null)
              Text(
                widget.task.icon!,
                style: const TextStyle(fontSize: 60),
              )
            else
              Icon(
                Icons.schedule,
                size: 60,
                color: AppTheme.neonBlue,
              ),

            const Gap(CombatDimensions.spacingMedium),

            // Task name
            Text(
              widget.task.name.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const Gap(CombatDimensions.spacingMedium),

            // Time until start
            if (_timeUntilStart != null) ...[
              Text(
                'STARTS IN',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Gap(8),
              Text(
                _formatTimeUntilStart(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: shouldStartSoon
                          ? AppTheme.warningAlert
                          : AppTheme.neonBlue,
                      fontSize: 56,
                      shadows: shouldStartSoon
                          ? [
                              Shadow(
                                color: AppTheme.warningAlert,
                                blurRadius: 20,
                              ),
                            ]
                          : null,
                    ),
              ),
            ],

            const Gap(CombatDimensions.spacingMedium),

            // Task duration
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
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
                'Duration: ${widget.task.durationFormatted}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.neonBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Priority indicator
            if (widget.task.priority.isCritical) ...[
              const Gap(CombatDimensions.spacingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.neonRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.neonRed,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning,
                      color: AppTheme.neonRed,
                      size: 20,
                    ),
                    const Gap(8),
                    Text(
                      'CRITICAL TIMING',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.neonRed,
                          ),
                    ),
                  ],
                ),
              ),
            ],

            // Task notes
            if (widget.task.notes != null && widget.task.notes!.isNotEmpty) ...[
              const Gap(CombatDimensions.spacingMedium),
              Text(
                widget.task.notes!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeUntilStart() {
    if (_timeUntilStart == null) return '--:--';

    final minutes = _timeUntilStart!.inMinutes;
    final seconds = _timeUntilStart!.inSeconds % 60;

    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
