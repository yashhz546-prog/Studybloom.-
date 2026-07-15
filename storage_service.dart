import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_entry.dart';

/// Thin wrapper around a single Hive box keyed by `yyyy-MM-dd`.
/// Kept separate from the provider so storage logic never leaks into UI.
class StorageService {
  static const String boxName = 'daily_entries';
  late Box<DailyEntry> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DailyEntryAdapter());
    }
    _box = await Hive.openBox<DailyEntry>(boxName);
  }

  DailyEntry getOrCreate(String dateKey) {
    final existing = _box.get(dateKey);
    if (existing != null) return existing;
    final fresh = DailyEntry(dateKey: dateKey);
    _box.put(dateKey, fresh);
    return fresh;
  }

  DailyEntry? get(String dateKey) => _box.get(dateKey);

  Future<void> save(DailyEntry entry) => _box.put(entry.dateKey, entry);

  List<DailyEntry> all() => _box.values.toList()
    ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

  List<DailyEntry> completed() =>
      all().where((e) => e.score != null).toList();
}
