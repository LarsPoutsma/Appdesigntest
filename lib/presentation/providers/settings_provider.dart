import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import 'session_provider.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._session);

  final SessionProvider _session;
  bool telemetryEnabled = false;
  bool pushNotificationsEnabled = false;
  String timezone = 'America/Denver';
  Duration defaultDueTime = const Duration(hours: 23, minutes: 59);

  Future<void> load() async {
    timezone = _session.user?.timezone ?? timezone;
    notifyListeners();
  }

  Future<void> updateTimezone(String tz) async {
    timezone = tz;
    final user = _session.user;
    if (user != null) {
      await _session.completeOnboarding(user.copyWith(timezone: tz));
    }
    notifyListeners();
  }

  Future<void> setTelemetry(bool enabled) async {
    telemetryEnabled = enabled;
    notifyListeners();
  }

  Future<void> setPushNotifications(bool enabled) async {
    pushNotificationsEnabled = enabled;
    notifyListeners();
  }
}
