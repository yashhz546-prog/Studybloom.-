import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_entry.dart';
import '../providers/daily_entry_provider.dart';
import '../services/pdf_export_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyEntryProvider>();
    final entriesByKey = {for (final e in provider.allEntries) e.dateKey: e};
    final streak = provider.currentStreak();
    final weekly = provider.weeklyAverage();
    final monthly = provider.monthlyAverage();
    final best = provider.bestStudyDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Export month as PDF',
            onPressed: () {
              PdfExportService().exportMonth(_visibleMonth, provider.allEntries);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _StatsRow(streak: streak, weekly: weekly, monthly: monthly),
          if (best != null) ...[
            const SizedBox(height: 16),
            _BestDayCard(entry: best),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => _shiftMonth(-1),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_visibleMonth),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => _shiftMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MonthGrid(
            month: _visibleMonth,
            entriesByKey: entriesByKey,
            onDayTap: (date, entry) {
              provider.loadDate(date);
              if (entry?.score != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ResultScreen(score: entry!.score!)),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.streak, required this.weekly, required this.monthly});
  final int streak;
  final double? weekly;
  final double? monthly;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatChip(label: 'Streak', value: '$streak 🔥')),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'Weekly Avg',
            value: weekly == null ? '—' : weekly!.toStringAsFixed(0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'Monthly Avg',
            value: monthly == null ? '—' : monthly!.toStringAsFixed(0),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.softBlush.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 11)),
        ],
      ),
    );
  }
}

class _BestDayCard extends StatelessWidget {
  const _BestDayCard({required this.entry});
  final DailyEntry entry;

  @override
  Widget build(BuildContext context) {
    final date = kDateKeyFormat.parse(entry.dateKey);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rosePink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Best Study Day', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  DateFormat('MMMM d, yyyy').format(date),
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.rosePink),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.entriesByKey,
    required this.onDayTap,
  });

  final DateTime month;
  final Map<String, DailyEntry> entriesByKey;
  final void Function(DateTime date, DailyEntry? entry) onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday-start grid

    final cells = <Widget>[];
    for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S']) {
      cells.add(Center(
        child: Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
      ));
    }
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final key = kDateKeyFormat.format(date);
      final entry = entriesByKey[key];
      final isToday = _isSameDay(date, DateTime.now());
      final isFuture = date.isAfter(DateTime.now());

      Color bg = Colors.transparent;
      Color fg = AppColors.inkText;
      if (entry?.score != null) {
        final score = entry!.score!;
        bg = score >= 80
            ? AppColors.rosePink
            : score >= 60
                ? AppColors.primaryPink
                : AppColors.softBlush;
        fg = score >= 80 ? Colors.white : AppColors.inkText;
      }

      cells.add(
        GestureDetector(
          onTap: isFuture ? null : () => onDayTap(date, entry),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: isToday ? Border.all(color: AppColors.rosePink, width: 1.6) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: isFuture ? AppColors.mutedText.withValues(alpha: 0.4) : fg,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
