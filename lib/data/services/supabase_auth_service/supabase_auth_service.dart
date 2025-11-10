import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService(SupabaseClient client) : _client = client;
  final SupabaseClient _client;

  Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
