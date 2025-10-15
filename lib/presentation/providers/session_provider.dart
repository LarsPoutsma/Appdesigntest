import 'package:flutter/foundation.dart';

import '../../core/utils/app_container.dart';
import '../../domain/entities/user.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({this.defaultTimezone = 'America/Denver'});

  final String defaultTimezone;
  bool isLoading = true;
  bool isOnboarded = false;
  UserProfile? user;
  AppContainer? container;

  Future<void> initialize() async {
    container = await AppContainer.initialize(timezone: defaultTimezone);
    await container?.syncService.initializeBackgroundSync();
    user = await container?.userRepository.getCurrentUser();
    isOnboarded = user != null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    await container?.userRepository.saveUser(profile);
    container = await AppContainer.initialize(timezone: profile.timezone);
    await container?.syncService.initializeBackgroundSync();
    user = profile;
    isOnboarded = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await container?.userRepository.signOut();
    container = await AppContainer.initialize(timezone: defaultTimezone);
    await container?.syncService.initializeBackgroundSync();
    isOnboarded = false;
    user = null;
    notifyListeners();
  }
}
