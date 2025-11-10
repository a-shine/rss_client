import '../../../domain/models/user.dart';
import '../../../utils/result.dart';

abstract class UserRepository {
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  Future<Result<User>> signUp({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<User?> getCurrentUser();

  Stream<User?> get authStateChanges;
}
