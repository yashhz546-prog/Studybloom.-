import 'package:hive/hive.dart';

/// The 11 subjects tracked in the homework checklist, in display order.
const List<String> kSubjects = [
  'English',
  'Hindi',
  'Sanskrit',
  'Computer',
  'Biology',
  'Physics',
  'Maths',
  'Chemistry',
  'History',
  'Civics',
  'Geography',
];

/// The four physical-activity options. Stored as a simple key so the
/// value is stable even if display copy changes later.
enum PhysicalActivityLevel { none, min30, hour1, hour2, hour3plus }

extension PhysicalActivityLevelX on PhysicalActivityLevel {
  String get label {
    switch (this) {
      case PhysicalActivityLevel.min30:
        return '30 Minutes';
      case PhysicalActivityLevel.hour1:
        return '1 Hour';
      case PhysicalActivityLevel.hour2:
        return '2 Hours';
      case PhysicalActivityLevel.hour3plus:
        return '3+ Hours';
      case PhysicalActivityLevel.none:
        return 'Not selected';
    }
  }
}

/// One day's worth of tracked data. `dateKey` is the primary/Hive key,
/// formatted as `yyyy-MM-dd` so entries sort and look up naturally.
class DailyEntry {
  DailyEntry({
    required this.dateKey,
    Map<String, bool>? homework,
    this.physicalActivity = PhysicalActivityLevel.none,
    this.selfStudyMinutes,
    this.phoneUsageMinutes,
    this.score,
  }) : homework = homework ?? {for (final s in kSubjects) s: false};

  final String dateKey;
  Map<String, bool> homework;
  PhysicalActivityLevel physicalActivity;
  int? selfStudyMinutes;
  int? phoneUsageMinutes;
  int? score;

  int get completedHomeworkCount => homework.values.where((v) => v).length;

  bool get isHomeworkSectionDone => homework.isNotEmpty;

  bool get isReadyToCalculate =>
      completedHomeworkCount >= 0 && // homework section always "complete" once touched; see provider
      physicalActivity != PhysicalActivityLevel.none &&
      selfStudyMinutes != null &&
      phoneUsageMinutes != null;

  DailyEntry copyWith({
    Map<String, bool>? homework,
    PhysicalActivityLevel? physicalActivity,
    int? selfStudyMinutes,
    int? phoneUsageMinutes,
    int? score,
  }) {
    return DailyEntry(
      dateKey: dateKey,
      homework: homework ?? Map<String, bool>.from(this.homework),
      physicalActivity: physicalActivity ?? this.physicalActivity,
      selfStudyMinutes: selfStudyMinutes ?? this.selfStudyMinutes,
      phoneUsageMinutes: phoneUsageMinutes ?? this.phoneUsageMinutes,
      score: score ?? this.score,
    );
  }
}

/// Hand-written Hive adapter (no build_runner / codegen required).
/// TypeId 0 is reserved for DailyEntry across the whole app.
class DailyEntryAdapter extends TypeAdapter<DailyEntry> {
  @override
  final int typeId = 0;

  @override
  DailyEntry read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++) reader.readByte(): reader.read(),
    };

    final rawHomework = (fields[1] as Map).cast<String, bool>();

    return DailyEntry(
      dateKey: fields[0] as String,
      homework: rawHomework,
      physicalActivity: PhysicalActivityLevel.values[fields[2] as int],
      selfStudyMinutes: fields[3] as int?,
      phoneUsageMinutes: fields[4] as int?,
      score: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.homework)
      ..writeByte(2)
      ..write(obj.physicalActivity.index)
      ..writeByte(3)
      ..write(obj.selfStudyMinutes)
      ..writeByte(4)
      ..write(obj.phoneUsageMinutes)
      ..writeByte(5)
      ..write(obj.score);
  }
}
