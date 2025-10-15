import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/session_provider.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/courses/course_manager_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/import/import_wizard_screen.dart';
import '../../presentation/screens/review/review_queue_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/sources/source_manager_screen.dart';
import '../../presentation/widgets/home_shell.dart';
import '../../presentation/widgets/setup_wizard.dart';

class AppRouter {
  static GoRouter buildRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/home/dashboard',
      refreshListenable: Provider.of<SessionProvider>(context, listen: false),
      redirect: (context, state) {
        final session = Provider.of<SessionProvider>(context, listen: false);
        if (session.isLoading) {
          return null;
        }
        if (!session.isOnboarded && !state.matchedLocation.startsWith('/setup')) {
          return '/setup';
        }
        if (session.isOnboarded && state.matchedLocation.startsWith('/setup')) {
          return '/home/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/setup',
          name: 'setup',
          builder: (context, state) => const SetupWizard(),
        ),
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/home/calendar',
              name: 'calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
            GoRoute(
              path: '/home/import',
              name: 'import',
              builder: (context, state) => const ImportWizardScreen(),
            ),
            GoRoute(
              path: '/home/review',
              name: 'review',
              builder: (context, state) => const ReviewQueueScreen(),
            ),
            GoRoute(
              path: '/home/courses',
              name: 'courses',
              builder: (context, state) => const CourseManagerScreen(),
            ),
            GoRoute(
              path: '/home/sources',
              name: 'sources',
              builder: (context, state) => const SourceManagerScreen(),
            ),
            GoRoute(
              path: '/home/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
