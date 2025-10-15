import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/user.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';

class SetupWizard extends StatefulWidget {
  const SetupWizard({super.key});

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends State<SetupWizard> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _timezone = 'America/Denver';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Homework Tracker Setup')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome! Connect your account to enable secure sync across devices.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    onSaved: (value) => _email = value ?? '',
                    validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _timezone,
                    decoration: const InputDecoration(labelText: 'Timezone'),
                    items: const [
                      DropdownMenuItem(value: 'America/Denver', child: Text('America/Denver (Default)')),
                      DropdownMenuItem(value: 'America/New_York', child: Text('America/New_York')),
                      DropdownMenuItem(value: 'America/Los_Angeles', child: Text('America/Los_Angeles')),
                      DropdownMenuItem(value: 'Europe/London', child: Text('Europe/London')),
                    ],
                    onChanged: (value) => setState(() => _timezone = value ?? 'America/Denver'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    title: const Text('Enable push notifications'),
                    value: settings.pushNotificationsEnabled,
                    onChanged: (value) => settings.setPushNotifications(value),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue'),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      _formKey.currentState!.save();
                      final profile = UserProfile(id: session.container?.userId ?? 'local-user', email: _email, timezone: _timezone);
                      await session.completeOnboarding(profile);
                      if (context.mounted) {
                        context.go('/home/dashboard');
                      }
                    },
                  ),
                  if (session.isLoading) const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
