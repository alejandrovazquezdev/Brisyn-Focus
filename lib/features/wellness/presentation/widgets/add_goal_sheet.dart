import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/colors.dart';
import '../../../activities/domain/models/activity_category.dart';
import '../../../activities/presentation/providers/activities_providers.dart';
import '../../domain/models/personal_goal.dart';
import '../providers/wellness_providers.dart';

/// Bottom sheet for adding a new personal goal
class AddGoalSheet extends ConsumerStatefulWidget {
  const AddGoalSheet({super.key});

  @override
  ConsumerState<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<AddGoalSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  IconData _selectedIcon = Icons.flag;
  Color _selectedColor = Colors.green;
  GoalType _selectedType = GoalType.daily;
  bool _showPresets = true;
  bool _createLinkedCategory = false;

  final List<IconData> _availableIcons = [
    Icons.flag,
    Icons.favorite,
    Icons.self_improvement,
    Icons.spa,
    Icons.directions_run,
    Icons.water_drop,
    Icons.restaurant,
    Icons.menu_book,
    Icons.bedtime,
    Icons.people,
    Icons.lightbulb,
    Icons.star,
    Icons.emoji_emotions,
    Icons.music_note,
    Icons.brush,
    Icons.code,
  ];

  final List<Color> _availableColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _titleController.text = preset['title'] as String;
      _descriptionController.text = preset['description'] as String? ?? '';
      _selectedIcon = preset['icon'] as IconData;
      _selectedColor = preset['color'] as Color;
      _selectedType = preset['type'] as GoalType;
      _showPresets = false;
    });
  }

  void _save() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // Add the goal and get it back
    final newGoal = await ref.read(personalGoalsProvider.notifier).addGoal(
          title: title,
          description: _descriptionController.text.trim(),
          type: _selectedType,
          icon: _selectedIcon,
          color: _selectedColor,
        );

    // If user wants to create a linked category (only for milestone goals)
    if (_createLinkedCategory && _selectedType == GoalType.milestone) {
      // Create a new category with same name
      final category = await ref.read(activitiesProvider.notifier).addCategory(
        name: title,
        icon: ActivityIcon.hobby,
        colorHex: _selectedColor.value.toRadixString(16).substring(2),
        weeklyGoal: 3,
      );
      
      // Link the category to the goal
      final updatedCategory = category.copyWith(linkedGoalId: newGoal.id);
      ref.read(activitiesProvider.notifier).updateCategory(updatedCategory);
    }

    Navigator.of(context).pop();
  }

  Widget _buildLinkCategorySection(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Also create Category',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Switch(
          value: _createLinkedCategory,
          onChanged: (value) => setState(() => _createLinkedCategory = value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Goal',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_showPresets)
                  TextButton(
                    onPressed: () => setState(() => _showPresets = true),
                    child: const Text('Show Presets'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Presets section
            if (_showPresets) ...[
              Text(
                'Quick Start',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: PresetGoals.all.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final preset = PresetGoals.all[index];
                    return _PresetCard(
                      preset: preset,
                      onTap: () => _selectPreset(preset),
                      isDark: isDark,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or create custom',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Be grateful today',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description field (optional)
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g., Take a moment to appreciate something',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Type selector
            Text(
              'Goal Type',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GoalType.values.map((type) {
                final isSelected = type == _selectedType;
                return ChoiceChip(
                  label: Text(_getTypeLabel(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Link to Category (only for milestone goals)
            if (_selectedType == GoalType.milestone)
              _buildLinkCategorySection(theme, isDark),
            
            if (_selectedType == GoalType.milestone)
              const SizedBox(height: 16),

            // Icon selector
            Text(
              'Icon',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withOpacity(0.2)
                          : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: _selectedColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? _selectedColor : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Color selector
            Text(
              'Color',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 3,
                            )
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Create Goal'),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return 'Daily';
      case GoalType.milestone:
        return 'Milestone';
      case GoalType.habit:
        return 'Habit';
      case GoalType.reflection:
        return 'Reflection';
    }
  }
}

class _PresetCard extends StatelessWidget {
  final Map<String, dynamic> preset;
  final VoidCallback onTap;
  final bool isDark;

  const _PresetCard({
    required this.preset,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = preset['color'] as Color;
    final icon = preset['icon'] as IconData;

    return Material(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                preset['title'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
