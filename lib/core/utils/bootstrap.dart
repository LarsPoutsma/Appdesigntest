import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/notification_service.dart';

class Bootstrap {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _configureLogging();

    const secureStorage = FlutterSecureStorage();
    NotificationService.registerPlugin(FlutterLocalNotificationsPlugin());
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
      authCallbackUrlHostname: 'login-callback',
      storageOptions: const StorageClientOptions(retryAttempts: 3),
    );

    await secureStorage.write(key: '__bootstrap__', value: DateTime.now().toIso8601String());
  }

  static void _configureLogging() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((event) {
      // ignore: avoid_print
      print('[${event.level.name}] ${event.loggerName}: ${event.time.toIso8601String()} ${event.message}');
    });
  }
}
