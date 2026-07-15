import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';

/// Schedules a single daily local notification at 8:30 PM reminding the
/// student to fill in their tracker — but only if today isn't done yet.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleEveningReminder(StorageService storage) async {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final today = storage.get(todayKey);
    if (today?.score != null) {
      // Already completed — no need to nag.
      await _plugin.cancel(0);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'studybloom_reminder',
      'Daily Reminder',
      channelDescription: 'Evening reminder to complete your StudyBloom tracker',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      '🌸 StudyBloom',
      "Don't forget to log today's progress!",
      details,
    );
  }
}
