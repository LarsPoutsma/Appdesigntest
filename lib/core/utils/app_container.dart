import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/local/assignment_local_data_source.dart';
import '../../data/datasources/local/course_local_data_source.dart';
import '../../data/datasources/local/local_database.dart';
import '../../data/datasources/local/source_local_data_source.dart';
import '../../data/datasources/remote/assignment_remote_data_source.dart';
import '../../data/datasources/remote/course_remote_data_source.dart';
import '../../data/datasources/remote/source_remote_data_source.dart';
import '../../data/repositories/assignment_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/repositories/source_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/source_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../services/export_service.dart';
import '../../services/import_service.dart';
import '../../services/notification_service.dart';
import '../../services/sync_service.dart';

class AppContainer {
  AppContainer({
    required this.assignmentRepository,
    required this.courseRepository,
    required this.sourceRepository,
    required this.userRepository,
    required this.notificationService,
    required this.syncService,
    required this.importService,
    required this.exportService,
    required this.userId,
  });

  final AssignmentRepository assignmentRepository;
  final CourseRepository courseRepository;
  final SourceRepository sourceRepository;
  final UserRepository userRepository;
  final NotificationService? notificationService;
  final SyncService syncService;
  final ImportService importService;
  final ExportService exportService;
  final String userId;

  static Future<AppContainer> initialize({required String timezone}) async {
    final secureStorage = const FlutterSecureStorage();
    final existingPassphrase = await secureStorage.read(key: 'db_passphrase');
    final passphrase = existingPassphrase ?? 'homework-tracker';
    if (existingPassphrase == null) {
      await secureStorage.write(key: 'db_passphrase', value: passphrase);
    }
    final database = await LocalDatabase.instance(passphrase: passphrase);
    final supabase = Supabase.instance.client;

    final assignmentLocal = AssignmentLocalDataSource(database);
    final assignmentRemote = AssignmentRemoteDataSource(supabase);
    final courseLocal = CourseLocalDataSource(database);
    final courseRemote = CourseRemoteDataSource(supabase);
    final sourceLocal = SourceLocalDataSource(database);
    final sourceRemote = SourceRemoteDataSource(supabase);

    final userRepo = UserRepositoryImpl(client: supabase, secureStorage: secureStorage);
    final user = await userRepo.getCurrentUser();
    final userId = user?.id ?? 'local-user';

    final assignmentRepository = AssignmentRepositoryImpl(
      localDataSource: assignmentLocal,
      remoteDataSource: assignmentRemote,
      userId: userId,
    );
    final courseRepository = CourseRepositoryImpl(
      localDataSource: courseLocal,
      remoteDataSource: courseRemote,
      userId: userId,
    );
    final sourceRepository = SourceRepositoryImpl(
      localDataSource: sourceLocal,
      remoteDataSource: sourceRemote,
      userId: userId,
    );

    final syncService = SyncService(
      assignmentRepository: assignmentRepository,
      courseRepository: courseRepository,
      sourceRepository: sourceRepository,
    );
    final notificationService = NotificationService.instance;
    await notificationService?.initialize();

    final importService = ImportService(timezone: timezone);
    final exportService = ExportService();

    return AppContainer(
      assignmentRepository: assignmentRepository,
      courseRepository: courseRepository,
      sourceRepository: sourceRepository,
      userRepository: userRepo,
      notificationService: notificationService,
      syncService: syncService,
      importService: importService,
      exportService: exportService,
      userId: userId,
    );
  }
}
