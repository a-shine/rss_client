import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService(SupabaseClient client) : _client = client;
  final SupabaseClient _client;

  Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }
}
