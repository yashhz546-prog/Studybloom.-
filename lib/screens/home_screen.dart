import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/daily_entry_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/homework_section.dart';
import '../widgets/numeric_input_section.dart';
import '../widgets/physical_activity_section.dart';
import '../widgets/progress_ring.dart';
import 'history_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyEntryProvider>(
      builder: (context, provider, _) {
        final entry = provider.entry;
        final total = 4;
        int filled = 0;
        if (entry.completedHomeworkCount > 0 || entry.homework.values.contains(true)) filled++;
        if (entry.physicalActivity.name != 'none') filled++;
        if (entry.selfStudyMinutes != null) filled++;
        if (entry.phoneUsageMinutes != null) filled++;
        final canCalculate = provider.canCalculate;

        return Scaffold(
          appBar: AppBar(
            title: const Text('StudyBloom'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                tooltip: 'History',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                _Header(greeting: _greeting(), date: provider.selectedDate),
                const SizedBox(height: 20),
                Center(
                  child: ProgressRing(
                    progress: filled / total,
                    centerLabel: '$filled/$total',
                    centerSubLabel: 'sections done',
                  ),
                ),
                const SizedBox(height: 28),
                HomeworkSection(
                  homework: entry.homework,
                  onToggle: provider.toggleHomework,
                ),
                const SizedBox(height: 16),
                PhysicalActivitySection(
                  selected: entry.physicalActivity,
                  onChanged: provider.setPhysicalActivity,
                ),
                const SizedBox(height: 16),
                NumericInputSection(
                  emoji: '📖',
                  title: 'Self Study',
                  hint: 'Total self-study minutes',
                  initialValue: entry.selfStudyMinutes,
                  onChanged: provider.setSelfStudyMinutes,
                ),
                const SizedBox(height: 16),
                NumericInputSection(
                  emoji: '📱',
                  title: 'Phone Usage',
                  hint: 'Total screen time minutes',
                  initialValue: entry.phoneUsageMinutes,
                  onChanged: provider.setPhoneUsageMinutes,
                ),
                const SizedBox(height: 28),
                _CalculateButton(enabled: canCalculate),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting, required this.date});

  final String greeting;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d').format(date),
          style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
        ),
      ],
    );
  }
}

class _CalculateButton extends StatefulWidget {
  const _CalculateButton({required this.enabled});
  final bool enabled;

  @override
  State<_CalculateButton> createState() => _CalculateButtonState();
}

class _CalculateButtonState extends State<_CalculateButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _scale = 0.97) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _scale = 1) : null,
      onTapCancel: widget.enabled ? () => setState(() => _scale = 1) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.enabled
                ? () {
                    final provider = context.read<DailyEntryProvider>();
                    final score = provider.calculateAndSaveScore();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultScreen(score: score)),
                    );
                  }
                : null,
            child: const Text('✨  Calculate My Day'),
          ),
        ),
      ),
    );
  }
}
