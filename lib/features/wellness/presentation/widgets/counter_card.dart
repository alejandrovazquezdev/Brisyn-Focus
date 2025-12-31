import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../domain/models/custom_counter.dart';
import '../providers/wellness_providers.dart';

/// Card widget for displaying a custom counter
class CounterCard extends ConsumerWidget {
  final CustomCounter counter;
  final bool isDark;

  const CounterCard({
    super.key,
    required this.counter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentValue = ref.watch(counterCurrentValueProvider(counter));
    final progress = counter.targetCount > 0
        ? (currentValue / counter.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = currentValue >= counter.targetCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? counter.color.withOpacity(0.5)
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: counter.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              counter.icon,
              color: counter.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counter.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$currentValue / ${counter.targetCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: counter.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getTypeLabel(counter.type),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: counter.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation(counter.color),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Increment button
          Column(
            children: [
              IconButton.filled(
                onPressed: isComplete
                    ? null
                    : () {
                        ref
                            .read(customCountersProvider.notifier)
                            .incrementCounter(counter.id);
                      },
                style: IconButton.styleFrom(
                  backgroundColor: counter.color,
                  disabledBackgroundColor: counter.color.withOpacity(0.3),
                ),
                icon: Icon(
                  isComplete ? Icons.check : Icons.add,
                  color: Colors.white,
                ),
              ),
              if (isComplete)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Done!',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: counter.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(CounterType type) {
    switch (type) {
      case CounterType.daily:
        return 'Daily';
      case CounterType.weekly:
        return 'Weekly';
      case CounterType.cumulative:
        return 'Total';
    }
  }
}
