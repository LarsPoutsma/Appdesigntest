import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/export_service.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final assignments = context.watch<AssignmentProvider>().assignments;
    final session = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Signed in user'),
            subtitle: Text(session.user?.email ?? 'Local-only mode'),
            trailing: Text(session.user?.timezone ?? settings.timezone),
          ),
          const Divider(),
          SwitchListTile.adaptive(
            title: const Text('Enable crash & usage telemetry'),
            value: settings.telemetryEnabled,
            onChanged: (value) => settings.setTelemetry(value),
            subtitle: const Text('Anonymous usage data helps improve reliability. You can opt out anytime.'),
          ),
          SwitchListTile.adaptive(
            title: const Text('Push notifications'),
            value: settings.pushNotificationsEnabled,
            onChanged: (value) => settings.setPushNotifications(value),
          ),
          ListTile(
            title: const Text('Timezone'),
            subtitle: Text(settings.timezone),
            trailing: DropdownButton<String>(
              value: settings.timezone,
              onChanged: (value) {
                if (value != null) {
                  settings.updateTimezone(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'America/Denver', child: Text('America/Denver')),
                DropdownMenuItem(value: 'America/New_York', child: Text('America/New_York')),
                DropdownMenuItem(value: 'America/Los_Angeles', child: Text('America/Los_Angeles')),
                DropdownMenuItem(value: 'Europe/London', child: Text('Europe/London')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Export assignments as ICS'),
            subtitle: const Text('Generate a read-only calendar feed you can subscribe to.'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                final exporter = session.container?.exportService ?? ExportService();
                final ics = exporter.generateIcsFeed(assignments);
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ICS Preview'),
                    content: SingleChildScrollView(child: SelectableText(ics)),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Sign out'),
            trailing: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => session.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}
