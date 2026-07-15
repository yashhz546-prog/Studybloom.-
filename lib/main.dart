import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/daily_entry_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();
  // Ask "did you fill in today's tracker?" every evening at 8:30 PM.
  await notifications.scheduleEveningReminder(storage);

  runApp(StudyBloomApp(storage: storage));
}

class StudyBloomApp extends StatelessWidget {
  const StudyBloomApp({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DailyEntryProvider(storage),
      child: MaterialApp(
        title: 'StudyBloom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
