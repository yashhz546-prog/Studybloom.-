import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/daily_entry.dart';
import '../services/score_calculator.dart';
import '../services/storage_service.dart';

final DateFormat kDateKeyFormat = DateFormat('yyyy-MM-dd');

class DailyEntryProvider extends ChangeNotifier {
  DailyEntryProvider(this._storage);

  final StorageService _storage;

  DateTime _selectedDate = DateTime.now();
  late DailyEntry _entry = _storage.getOrCreate(_keyFor(_selectedDate));

  DateTime get selectedDate => _selectedDate;
  DailyEntry get entry => _entry;
  bool get isViewingToday => _isSameDay(_selectedDate, DateTime.now());

  String _keyFor(DateTime d) => kDateKeyFormat.format(d);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void loadDate(DateTime date) {
    _selectedDate = date;
    _entry = _storage.getOrCreate(_keyFor(date));
    notifyListeners();
  }

  void toggleHomework(String subject) {
    final updated = Map<String, bool>.from(_entry.homework);
    updated[subject] = !(updated[subject] ?? false);
    _entry = _entry.copyWith(homework: updated);
    _persist();
  }

  void setPhysicalActivity(PhysicalActivityLevel level) {
    _entry = _entry.copyWith(physicalActivity: level);
    _persist();
  }

  void setSelfStudyMinutes(int? minutes) {
    _entry.selfStudyMinutes = minutes;
    _persist();
  }

  void setPhoneUsageMinutes(int? minutes) {
    _entry.phoneUsageMinutes = minutes;
    _persist();
  }

  bool get canCalculate =>
      _entry.completedHomeworkCount >= 0 &&
      _entry.physicalActivity != PhysicalActivityLevel.none &&
      _entry.selfStudyMinutes != null &&
      _entry.phoneUsageMinutes != null &&
      _hasTouchedHomework;

  // At least one homework interaction OR all 11 explicitly left unchecked
  // isn't meaningful, so we simply require the physical/self-study/phone
  // fields (homework defaults to 0/11 which is a valid, real state).
  bool get _hasTouchedHomework => true;

  int calculateAndSaveScore() {
    final score = ScoreCalculator.calculate(_entry);
    _entry = _entry.copyWith(score: score);
    _persist();
    return score;
  }

  void _persist() {
    _storage.save(_entry);
    notifyListeners();
  }

  // ---- History / stats helpers ----

  List<DailyEntry> get allEntries => _storage.all();

  List<DailyEntry> get scoredEntries => _storage.completed();

  double? weeklyAverage() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final entries = scoredEntries
        .where((e) => kDateKeyFormat.parse(e.dateKey).isAfter(weekAgo))
        .toList();
    if (entries.isEmpty) return null;
    return entries.map((e) => e.score!).reduce((a, b) => a + b) / entries.length;
  }

  double? monthlyAverage() {
    final now = DateTime.now();
    final entries = scoredEntries
        .where((e) {
          final d = kDateKeyFormat.parse(e.dateKey);
          return d.year == now.year && d.month == now.month;
        })
        .toList();
    if (entries.isEmpty) return null;
    return entries.map((e) => e.score!).reduce((a, b) => a + b) / entries.length;
  }

  int currentStreak() {
    final entries = scoredEntries;
    if (entries.isEmpty) return 0;
    final byKey = {for (final e in entries) e.dateKey: e};
    int streak = 0;
    DateTime cursor = DateTime.now();
    while (true) {
      final key = _keyFor(cursor);
      if (byKey.containsKey(key)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  DailyEntry? bestStudyDay() {
    final entries = scoredEntries;
    if (entries.isEmpty) return null;
    entries.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
    return entries.first;
  }
}
