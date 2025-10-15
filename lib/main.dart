import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'core/utils/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Bootstrap.ensureInitialized();
  await dotenv.load(fileName: '.env');
  tz.initializeTimeZones();

  runApp(const HomeworkTrackerApp());
}
