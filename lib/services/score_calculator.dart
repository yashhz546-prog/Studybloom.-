import '../models/daily_entry.dart';

/// Turns one day's raw inputs into a score out of 100, following the
/// weighting: Homework 30, Self Study 40, Physical Activity 15, Phone 15.
class ScoreCalculator {
  ScoreCalculator._();

  static int calculate(DailyEntry entry) {
    final homework = _homeworkScore(entry.completedHomeworkCount);
    final selfStudy = _selfStudyScore(entry.selfStudyMinutes ?? 0);
    final activity = _activityScore(entry.physicalActivity);
    final phone = _phoneScore(entry.phoneUsageMinutes ?? 0);
    return (homework + selfStudy + activity + phone).clamp(0, 100);
  }

  /// 11 completed = 30 marks, scaled proportionally and floored
  /// (matches the spec's worked examples: 10→27, 9→24).
  static int _homeworkScore(int completed) {
    if (kSubjects.isEmpty) return 0;
    final raw = completed * 30 / kSubjects.length;
    return raw.floor().clamp(0, 30);
  }

  static int _activityScore(PhysicalActivityLevel level) {
    switch (level) {
      case PhysicalActivityLevel.min30:
        return 5;
      case PhysicalActivityLevel.hour1:
        return 10;
      case PhysicalActivityLevel.hour2:
        return 13;
      case PhysicalActivityLevel.hour3plus:
        return 15;
      case PhysicalActivityLevel.none:
        return 0;
    }
  }

  /// Piecewise-linear between the spec's anchor points, capped at 40.
  static int _selfStudyScore(int minutes) {
    const anchors = <int, int>{
      0: 0,
      30: 10,
      60: 20,
      90: 25,
      120: 30,
      150: 35,
      180: 40,
    };
    if (minutes >= 180) return 40;
    return _interpolate(minutes, anchors);
  }

  /// Piecewise-linear between the spec's anchor points; 0 beyond 180,
  /// flat 15 for anything at or below 30 minutes.
  static int _phoneScore(int minutes) {
    const anchors = <int, int>{
      0: 15,
      30: 15,
      60: 12,
      90: 9,
      120: 6,
      180: 0,
    };
    if (minutes >= 180) return 0;
    return _interpolate(minutes, anchors);
  }

  static int _interpolate(int x, Map<int, int> anchors) {
    final keys = anchors.keys.toList()..sort();
    for (int i = 0; i < keys.length - 1; i++) {
      final x0 = keys[i];
      final x1 = keys[i + 1];
      if (x >= x0 && x <= x1) {
        final y0 = anchors[x0]!;
        final y1 = anchors[x1]!;
        if (x1 == x0) return y0;
        final t = (x - x0) / (x1 - x0);
        return (y0 + (y1 - y0) * t).round();
      }
    }
    // x below the smallest anchor or above the largest.
    if (x < keys.first) return anchors[keys.first]!;
    return anchors[keys.last]!;
  }

  static ({String emoji, String title, String message}) feedbackFor(int score) {
    if (score >= 90) {
      return (emoji: '🌸', title: 'Outstanding!', message: 'Excellent discipline today.');
    } else if (score >= 80) {
      return (emoji: '✨', title: 'Excellent!', message: 'Keep maintaining this consistency.');
    } else if (score >= 70) {
      return (emoji: '😊', title: 'Good Job!', message: 'A little more focus tomorrow.');
    } else if (score >= 60) {
      return (emoji: '🙂', title: 'Fair.', message: 'Try reducing distractions.');
    }
    return (
      emoji: '💪',
      title: 'Tomorrow is another opportunity.',
      message: 'You can definitely improve.',
    );
  }
}
