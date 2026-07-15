import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/daily_entry.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class PhysicalActivitySection extends StatelessWidget {
  const PhysicalActivitySection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PhysicalActivityLevel selected;
  final ValueChanged<PhysicalActivityLevel> onChanged;

  static const _options = [
    PhysicalActivityLevel.min30,
    PhysicalActivityLevel.hour1,
    PhysicalActivityLevel.hour2,
    PhysicalActivityLevel.hour3plus,
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      emoji: '🏃',
      title: 'Physical Activity',
      child: Column(
        children: _options.map((option) {
          final isSelected = selected == option;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(option);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.softBlush.withValues(alpha: 0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Radio<PhysicalActivityLevel>(
                    value: option,
                    groupValue: selected,
                    onChanged: (v) {
                      if (v != null) {
                        HapticFeedback.selectionClick();
                        onChanged(v);
                      }
                    },
                  ),
                  Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.inkText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
