import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/colors.dart';
import '../../domain/models/activity_category.dart';
import '../providers/activities_providers.dart';

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

  final List<String> _colorOptions = [
    '0xFFFF6B6B', // Red
    '0xFFFF8E53', // Orange
    '0xFFFFD93D', // Yellow
    '0xFF4ECDC4', // Teal
    '0xFF45B7D1', // Blue
    '0xFF6C5CE7', // Purple
    '0xFFA29BFE', // Lavender
    '0xFFE84393', // Pink
    '0xFF00B894', // Green
    '0xFF636E72', // Gray
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.editCategory;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _selectedIcon = edit?.icon ?? ActivityIcon.hobby;
    _selectedColor = edit?.colorHex ?? _colorOptions[0];
    _weeklyGoal = edit?.weeklyGoal ?? 3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (widget.editCategory != null) {
      final category = ActivityCategory(
        id: widget.editCategory!.id,
        name: name,
        icon: _selectedIcon,
        colorHex: _selectedColor,
        weeklyGoal: _weeklyGoal,
        sortOrder: widget.editCategory!.sortOrder,
      );
      ref.read(activitiesProvider.notifier).updateCategory(category);
      Navigator.of(context).pop(category);
    } else {
      ref.read(activitiesProvider.notifier).addCategory(
        name: name,
        icon: _selectedIcon,
        colorHex: _selectedColor,
        weeklyGoal: _weeklyGoal,
      );
      Navigator.of(context).pop();
    }
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
                        color: Color(int.parse(_selectedColor)).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          getIconAsset(_selectedIcon),
                          width: 40,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            Color(int.parse(_selectedColor)),
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

                  // Color picker
                  Text(
                    'Color',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorOptions.map((colorHex) {
                      final isSelected = _selectedColor == colorHex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = colorHex),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(int.parse(colorHex)),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Color(int.parse(colorHex)).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Icon picker
                  Text(
                    'Icon',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: ActivityIcon.values.length,
                      itemBuilder: (context, index) {
                        final icon = ActivityIcon.values[index];
                        final isSelected = _selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(int.parse(_selectedColor)).withValues(alpha: 0.2)
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: Color(int.parse(_selectedColor)),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                getIconAsset(icon),
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? Color(int.parse(_selectedColor))
                                      : isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
