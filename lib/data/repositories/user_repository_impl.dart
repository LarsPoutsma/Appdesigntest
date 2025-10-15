import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required SupabaseClient client,
    required FlutterSecureStorage secureStorage,
  })  : _client = client,
        _secureStorage = secureStorage;

  final SupabaseClient _client;
  final FlutterSecureStorage _secureStorage;
  final _logger = Logger('UserRepository');

  @override
  Future<UserProfile?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null || session.user == null) {
      return null;
    }
    return UserProfile(
      id: session.user!.id,
      email: session.user!.email ?? '',
      timezone: await _secureStorage.read(key: 'timezone') ?? 'America/Denver',
    );
  }

  @override
  Future<void> saveUser(UserProfile profile) async {
    await _secureStorage.write(key: 'timezone', value: profile.timezone);
    await _secureStorage.write(key: 'email', value: profile.email);
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error, stackTrace) {
      _logger.warning('Sign out failed', error, stackTrace);
    }
  }
}
