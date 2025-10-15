import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/app_router.dart';
import '../core/utils/theme.dart';
import '../presentation/providers/app_providers.dart';

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: Builder(
        builder: (context) {
          final router = AppRouter.buildRouter(context);
          return MaterialApp.router(
            title: 'Homework Tracker',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
