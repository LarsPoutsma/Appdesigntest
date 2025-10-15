import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../providers/assignment_provider.dart';
import '../providers/course_provider.dart';
import '../providers/import_provider.dart';
import '../providers/review_provider.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/source_provider.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    ChangeNotifierProvider<SessionProvider>(
      create: (_) => SessionProvider()..initialize(),
    ),
    ChangeNotifierProxyProvider<SessionProvider, AssignmentProvider>(
      create: (context) => AssignmentProvider(context.read<SessionProvider>()),
      update: (context, session, previous) => previous ?? AssignmentProvider(session),
    ),
    ChangeNotifierProxyProvider<SessionProvider, CourseProvider>(
      create: (context) => CourseProvider(context.read<SessionProvider>()),
      update: (context, session, previous) => previous ?? CourseProvider(session),
    ),
    ChangeNotifierProxyProvider<SessionProvider, SourceProvider>(
      create: (context) => SourceProvider(context.read<SessionProvider>()),
      update: (context, session, previous) => previous ?? SourceProvider(session),
    ),
    ChangeNotifierProxyProvider3<SessionProvider, AssignmentProvider, CourseProvider, ImportProvider>(
      create: (context) => ImportProvider(
        context.read<SessionProvider>(),
        context.read<AssignmentProvider>(),
        context.read<CourseProvider>(),
      ),
      update: (context, session, assignment, course, previous) =>
          previous ?? ImportProvider(session, assignment, course),
    ),
    ChangeNotifierProxyProvider<AssignmentProvider, ReviewProvider>(
      create: (context) => ReviewProvider(context.read<AssignmentProvider>()),
      update: (context, assignment, previous) => previous ?? ReviewProvider(assignment),
    ),
    ChangeNotifierProxyProvider<SessionProvider, SettingsProvider>(
      create: (context) => SettingsProvider(context.read<SessionProvider>())..load(),
      update: (context, session, previous) {
        final provider = previous ?? SettingsProvider(session);
        provider.load();
        return provider;
      },
    ),
  ];
}
