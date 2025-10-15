import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.location;
    final destinations = [
      _ShellDestination(label: 'Dashboard', icon: Icons.checklist, route: '/home/dashboard'),
      _ShellDestination(label: 'Calendar', icon: Icons.calendar_month, route: '/home/calendar'),
      _ShellDestination(label: 'Import', icon: Icons.file_download, route: '/home/import'),
      _ShellDestination(label: 'Review', icon: Icons.rule, route: '/home/review'),
      _ShellDestination(label: 'Courses', icon: Icons.class_, route: '/home/courses'),
      _ShellDestination(label: 'Sources', icon: Icons.cloud_sync, route: '/home/sources'),
      _ShellDestination(label: 'Settings', icon: Icons.settings, route: '/home/settings'),
    ];

    final isWide = MediaQuery.of(context).size.width >= 900;
    final currentIndex = destinations.indexWhere((d) => location.startsWith(d.route));

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              NavigationRail(
                selectedIndex: currentIndex,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final destination in destinations)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                    ),
                ],
                onDestinationSelected: (index) {
                  router.go(destinations[index].route);
                },
              ),
            Expanded(
              child: Column(
                children: [
                  if (!isWide)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SegmentedButton<int>(
                        segments: [
                          for (var i = 0; i < destinations.length; i++)
                            ButtonSegment<int>(
                              value: i,
                              icon: Icon(destinations[i].icon),
                              label: Text(destinations[i].label),
                            ),
                        ],
                        selected: {currentIndex < 0 ? 0 : currentIndex},
                        onSelectionChanged: (selection) {
                          final index = selection.first;
                          router.go(destinations[index].route);
                        },
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({required this.label, required this.icon, required this.route});

  final String label;
  final IconData icon;
  final String route;
}
