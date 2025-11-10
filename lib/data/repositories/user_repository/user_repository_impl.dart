import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../domain/models/user.dart';
import '../../../utils/result.dart';
import '../../services/supabase_auth_service/supabase_auth_service.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._authService);

  final SupabaseAuthService _authService;

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.error(Exception('Sign in failed: No user returned'));
      }

      return Result.ok(_mapSupabaseUserToDomainUser(response.user!));
    } on supabase.AuthException catch (e) {
      return Result.error(Exception('Sign in failed: ${e.message}'));
    } catch (e) {
      return Result.error(Exception('Sign in failed: $e'));
    }
  }

  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Result.error(Exception('Sign up failed: No user returned'));
      }

      return Result.ok(_mapSupabaseUserToDomainUser(response.user!));
    } on supabase.AuthException catch (e) {
      return Result.error(Exception('Sign up failed: ${e.message}'));
    } catch (e) {
      return Result.error(Exception('Sign up failed: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Sign out failed: $e'));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final supabaseUser = await _authService.getCurrentUser();
    if (supabaseUser == null) return null;
    return _mapSupabaseUserToDomainUser(supabaseUser);
  }

  @override
  Stream<User?> get authStateChanges {
    return _authService.authStateChanges.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return _mapSupabaseUserToDomainUser(user);
    });
  }

  User _mapSupabaseUserToDomainUser(supabase.User supabaseUser) {
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      createdAt: DateTime.parse(supabaseUser.createdAt),
    );
  }
}
