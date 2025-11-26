import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: User is null');
      }

      return User(
        id: response.user!.id,
        phoneNumber: response.user!.email ?? '',
        name: response.user!.userMetadata?['name'] ?? 'User',
        createdAt: DateTime.parse(response.user!.createdAt),
      );
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<User> signUpWithEmail(String email, String password, String name) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw Exception('Sign up failed: User is null');
      }

      return User(
        id: response.user!.id,
        phoneNumber: response.user!.email ?? '',
        name: name,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      return User(
        id: user.id,
        phoneNumber: user.email ?? '',
        name: user.userMetadata?['name'] ?? 'User',
        createdAt: DateTime.parse(user.createdAt),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
}
