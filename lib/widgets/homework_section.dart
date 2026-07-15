import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/daily_entry.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class HomeworkSection extends StatelessWidget {
  const HomeworkSection({
    super.key,
    required this.homework,
    required this.onToggle,
  });

  final Map<String, bool> homework;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final completed = homework.values.where((v) => v).length;
    final total = kSubjects.length;

    return SectionCard(
      emoji: '📚',
      title: 'School Homework',
      trailing: Text(
        '$completed/$total',
        style: const TextStyle(
          color: AppColors.rosePink,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Column(
        children: [
          ...kSubjects.map((subject) {
            final done = homework[subject] ?? false;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: done
                    ? AppColors.softBlush.withValues(alpha: 0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: CheckboxListTile(
                value: done,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  onToggle(subject);
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: done ? AppColors.mutedText : AppColors.inkText,
                    decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                  child: Text(subject),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.softBlush,
            color: AppColors.rosePink,
          ),
          const SizedBox(height: 8),
          Text(
            '$completed/$total Homework Completed',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
