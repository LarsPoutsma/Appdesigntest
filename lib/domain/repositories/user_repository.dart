import '../entities/user.dart';

abstract class UserRepository {
  Future<UserProfile?> getCurrentUser();

  Future<void> saveUser(UserProfile profile);

  Future<void> signOut();
}
