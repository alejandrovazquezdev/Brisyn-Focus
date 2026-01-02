import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/colors.dart';
import '../../domain/models/activity_category.dart';
import '../../../wellness/domain/models/personal_goal.dart';
import '../../../wellness/presentation/providers/wellness_providers.dart';
import '../providers/activities_providers.dart';

/// Parse color hex string (6 chars like 'FF6B6B') to Color
Color _parseColor(String hex) {
  return Color(int.parse('FF$hex', radix: 16));
}

class CategoryPickerSheet extends ConsumerStatefulWidget {
  final ActivityCategory? editCategory;

  const CategoryPickerSheet({
    super.key,
    this.editCategory,
  });

  @override
  ConsumerState<CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  late TextEditingController _nameController;
  late ActivityIcon _selectedIcon;
  late String _selectedColor;
  late int _weeklyGoal;
  bool _createLinkedGoal = false;

  // Colors stored as 6-char hex (without 0xFF prefix, matching the model format)
  final List<String> _colorOptions = [
    'FF6B6B', // Red
    'FF8E53', // Orange
    'FFD93D', // Yellow
    '4ECDC4', // Teal
    '45B7D1', // Blue
    '6C5CE7', // Purple
    'A29BFE', // Lavender
    'E84393', // Pink
    '00B894', // Green
    '636E72', // Gray
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.editCategory;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _selectedIcon = edit?.icon ?? ActivityIcon.hobby;
    _selectedColor = edit?.colorHex ?? _colorOptions[0];
    _weeklyGoal = edit?.weeklyGoal ?? 3;
    // If editing and has linked goal, keep it linked
    _createLinkedGoal = edit?.linkedGoalId != null && edit!.linkedGoalId!.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (widget.editCategory != null) {
      // Editing existing category - keep existing linkedGoalId
      final category = ActivityCategory(
        id: widget.editCategory!.id,
        name: name,
        icon: _selectedIcon,
        colorHex: _selectedColor,
        weeklyGoal: _weeklyGoal,
        sortOrder: widget.editCategory!.sortOrder,
        linkedGoalId: widget.editCategory!.linkedGoalId,
      );
      ref.read(activitiesProvider.notifier).updateCategory(category);
      Navigator.of(context).pop(category);
    } else {
      // Creating new category
      final category = await ref.read(activitiesProvider.notifier).addCategory(
        name: name,
        icon: _selectedIcon,
        colorHex: _selectedColor,
        weeklyGoal: _weeklyGoal,
      );
      
      // If user wants to create a linked goal
      if (_createLinkedGoal) {
        // Create a milestone goal with same name
        final newGoal = await ref.read(personalGoalsProvider.notifier).addGoal(
          title: name,
          description: 'Focus time goal for $name',
          type: GoalType.milestone,
          icon: Icons.timer,
          color: _parseColor(_selectedColor),
          targetValue: 60 * 10, // Default 10 hours (600 minutes)
        );
        
        // Link the category to the newly created goal
        final updatedCategory = category.copyWith(linkedGoalId: newGoal.id);
        ref.read(activitiesProvider.notifier).updateCategory(updatedCategory);
      }
      
      Navigator.of(context).pop();
    }
  }

  Widget _buildLinkedGoalSection(ThemeData theme, bool isDark) {
    // Only show for new categories, not editing
    if (widget.editCategory != null) {
      // Show linked status if editing and has link
      if (widget.editCategory!.linkedGoalId != null) {
        return Row(
          children: [
            Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Linked to a Goal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            'Also create Goal',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(
          value: _createLinkedGoal,
          onChanged: (value) => setState(() => _createLinkedGoal = value),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  widget.editCategory != null ? 'Edit Category' : 'New Category',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saveCategory,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _parseColor(_selectedColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          getIconAsset(_selectedIcon),
                          width: 40,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            _parseColor(_selectedColor),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  Text(
                    'Name',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Workout, Study, Reading...',
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),

                  // Weekly goal
                  Text(
                    'Weekly Goal',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '$_weeklyGoal days per week',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: _weeklyGoal > 1
                            ? () => setState(() => _weeklyGoal--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _weeklyGoal < 7
                            ? () => setState(() => _weeklyGoal++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Linked Goal
                  _buildLinkedGoalSection(theme, isDark),
                  const SizedBox(height: 24),

                  // Color picker
                  Text(
                    'Color',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _colorOptions.map((colorHex) {
                      final isSelected = _selectedColor == colorHex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = colorHex),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _parseColor(colorHex),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Icon picker
                  Text(
                    'Icon',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ActivityIcon.values.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _parseColor(_selectedColor).withValues(alpha: 0.2)
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: _parseColor(_selectedColor),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              getIconAsset(icon),
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? _parseColor(_selectedColor)
                                    : isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
