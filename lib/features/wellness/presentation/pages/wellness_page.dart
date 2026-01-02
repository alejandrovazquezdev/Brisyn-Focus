import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../domain/models/personal_goal.dart';
import '../providers/wellness_providers.dart';
import '../widgets/streak_calendar.dart';
import '../widgets/counter_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_counter_sheet.dart';
import '../widgets/add_goal_sheet.dart';

/// Main wellness page with streaks, counters, and goals
class WellnessPage extends ConsumerStatefulWidget {
  const WellnessPage({super.key});

  @override
  ConsumerState<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends ConsumerState<WellnessPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize the wellness repository
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wellnessInitializedProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wellness',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Streaks'),
            Tab(text: 'Counters'),
            Tab(text: 'Goals'),
          ],
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StreaksTab(isDark: isDark),
          _CountersTab(isDark: isDark),
          _GoalsTab(isDark: isDark),
        ],
      ),
    );
  }
}

// =============================================================================
// STREAKS TAB
// =============================================================================

class _StreaksTab extends ConsumerWidget {
  final bool isDark;

  const _StreaksTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentStreak = ref.watch(currentStreakProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current streak display
          _StreakHeader(currentStreak: currentStreak, isDark: isDark),
          const SizedBox(height: 24),

          // Calendar
          Text(
            'Focus Calendar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const StreakCalendar(),

          const SizedBox(height: 24),

          // Tips
          _WellnessTip(isDark: isDark),
        ],
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  final int currentStreak;
  final bool isDark;

  const _StreakHeader({required this.currentStreak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak Day${currentStreak != 1 ? 's' : ''}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentStreak > 0
                      ? 'Keep up the great work! 🔥'
                      : 'Start your streak today!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessTip extends StatelessWidget {
  final bool isDark;

  const _WellnessTip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Tip',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consistency beats intensity. Focus for just 25 minutes a day to build a lasting habit.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COUNTERS TAB
// =============================================================================

class _CountersTab extends ConsumerWidget {
  final bool isDark;

  const _CountersTab({required this.isDark});

  void _showAddCounterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCounterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final counters = ref.watch(customCountersProvider);

    return counters.isEmpty
        ? _EmptyCountersState(
            isDark: isDark,
            onAddTap: () => _showAddCounterSheet(context),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Counters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddCounterSheet(context),
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add Counter',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Counter cards
              ...counters.map((counter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CounterCard(
                      counter: counter,
                      isDark: isDark,
                      onDelete: () {
                        ref.read(customCountersProvider.notifier).deleteCounter(counter.id);
                      },
                    ),
                  )),
            ],
          );
  }
}

class _EmptyCountersState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddTap;

  const _EmptyCountersState({
    required this.isDark,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_chart,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Track What Matters',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create custom counters to track habits,\ndrink water, exercises, or anything you want!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: const Text('Create Counter'),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// GOALS TAB
// =============================================================================

class _GoalsTab extends ConsumerWidget {
  final bool isDark;

  const _GoalsTab({required this.isDark});

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goals = ref.watch(personalGoalsProvider);
    final completedToday = ref.watch(todayGoalsCompletedProvider);

    return goals.isEmpty
        ? _EmptyGoalsState(
            isDark: isDark,
            onAddTap: () => _showAddGoalSheet(context),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header with progress
              _GoalsHeader(
                totalGoals: goals.where((g) => g.type == GoalType.daily).length,
                completedToday: completedToday,
                isDark: isDark,
                onAddTap: () => _showAddGoalSheet(context),
              ),
              const SizedBox(height: 16),

              // Daily goals section
              if (goals.any((g) => g.type == GoalType.daily)) ...[
                Text(
                  'Daily Goals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...goals
                    .where((g) => g.type == GoalType.daily)
                    .map((goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GoalCard(
                            goal: goal,
                            isDark: isDark,
                            onDelete: () {
                              ref.read(personalGoalsProvider.notifier).deleteGoal(goal.id);
                            },
                          ),
                        )),
                const SizedBox(height: 16),
              ],

              // Other goals section
              if (goals.any((g) => g.type != GoalType.daily)) ...[
                Text(
                  'Other Goals',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...goals
                    .where((g) => g.type != GoalType.daily)
                    .map((goal) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GoalCard(
                            goal: goal,
                            isDark: isDark,
                            onDelete: () {
                              ref.read(personalGoalsProvider.notifier).deleteGoal(goal.id);
                            },
                          ),
                        )),
              ],
            ],
          );
  }
}

class _GoalsHeader extends StatelessWidget {
  final int totalGoals;
  final int completedToday;
  final bool isDark;
  final VoidCallback onAddTap;

  const _GoalsHeader({
    required this.totalGoals,
    required this.completedToday,
    required this.isDark,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalGoals > 0 ? completedToday / totalGoals : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedToday of $totalGoals completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Goal',
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGoalsState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAddTap;

  const _EmptyGoalsState({
    required this.isDark,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Set Your Goals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create personal goals like being grateful,\nstaying healthy, or building new habits.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddTap,
              icon: const Icon(Icons.add),
              label: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}
