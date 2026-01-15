import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../timeline_orchestrator/domain/models/cooking_task.dart';

/// Critical alert banner for time-sensitive tasks
///
/// Displays prominently at the top of the screen with:
/// - Flashing animation
/// - Critical task names
/// - Immediate action required messaging
class CriticalAlertBanner extends StatefulWidget {
  const CriticalAlertBanner({
    super.key,
    required this.tasks,
  });

  final List<CookingTask> tasks;

  @override
  State<CriticalAlertBanner> createState() => _CriticalAlertBannerState();
}

class _CriticalAlertBannerState extends State<CriticalAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: CombatDimensions.spacingLarge,
          vertical: CombatDimensions.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: AppTheme.criticalAlert,
          boxShadow: [
            BoxShadow(
              color: AppTheme.criticalAlert.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Warning icon
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.black,
            ),

            const Gap(CombatDimensions.spacingMedium),

            // Alert content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'IMMEDIATE ACTION REQUIRED',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Gap(4),
                  Text(
                    widget.tasks.map((t) => t.name).join(' • '),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Pulsing indicator
            _buildPulsingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          widget.tasks.length.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
