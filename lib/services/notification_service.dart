import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/assignment.dart';

class NotificationService {
  NotificationService(this._plugin);

  static FlutterLocalNotificationsPlugin? _pluginInstance;

  final FlutterLocalNotificationsPlugin _plugin;

  static void registerPlugin(FlutterLocalNotificationsPlugin plugin) {
    _pluginInstance = plugin;
  }

  static NotificationService? get instance =>
      _pluginInstance != null ? NotificationService(_pluginInstance!) : null;

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(initializationSettings);
  }

  Future<void> scheduleReminder(Assignment assignment, Duration beforeDue) async {
    final scheduled = assignment.dueAt.subtract(beforeDue);
    if (scheduled.isBefore(DateTime.now().toUtc())) {
      return;
    }
    final zoned = tz.TZDateTime.from(scheduled, tz.local);
    await _plugin.zonedSchedule(
      assignment.hashCode,
      assignment.title,
      'Due ${assignment.dueAt.toLocal()} in ${beforeDue.inHours}h',
      zoned,
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders'),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      payload: assignment.id,
      matchDateTimeComponents: assignment.allDay ? DateTimeComponents.dateAndTime : null,
    );
  }

  Future<void> cancelReminder(String assignmentId) async {
    await _plugin.cancel(assignmentId.hashCode);
  }
}
