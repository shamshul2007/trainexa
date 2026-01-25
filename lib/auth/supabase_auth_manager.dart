import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trainexa/auth/auth_manager.dart';
import 'package:trainexa/supabase/supabase_config.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// User wrapper for Supabase auth
class User {
  final sb.User _supabaseUser;
  User(this._supabaseUser);

  String get uid => _supabaseUser.id;
  String? get email => _supabaseUser.email;
  bool get emailVerified => _supabaseUser.emailConfirmedAt != null;

  Future<void> sendEmailVerification() async {
    if (email == null) return;
    await SupabaseConfig.auth.resend(
      type: sb.OtpType.signup,
      email: email!,
    );
  }

  Future<User> refreshUser() async {
    final session = await SupabaseConfig.auth.refreshSession();
    if (session.user == null) throw Exception('Failed to refresh user');
    return User(session.user!);
  }
}

class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  @override
  Future<User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw Exception('Sign in failed');
      return User(response.user!);
    } on sb.AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
      );
      
      debugPrint('Signup response - user: ${response.user?.id}, session: ${response.session?.accessToken != null}');
      
      // Check if session was created (meaning email confirmation is disabled OR auto-confirmed)
      if (response.session == null) {
        throw Exception('Please check your email to confirm your account before signing in.');
      }
      
      if (response.user == null) throw Exception('Sign up failed');
      return User(response.user!);
    } on sb.AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await SupabaseConfig.auth.signOut();
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    try {
      final user = SupabaseConfig.auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Delete user record from user_profiles table (cascade will handle related data)
      await SupabaseService.delete('user_profiles', filters: {'id': user.id});
      
      // Sign out
      await signOut();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupabaseConfig.auth.updateUser(sb.UserAttributes(email: email));
    } on sb.AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw Exception(_formatAuthError(e.message));
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  User? getCurrentUser() {
    final user = SupabaseConfig.auth.currentUser;
    return user != null ? User(user) : null;
  }

  Stream<User?> authStateChanges() {
    return SupabaseConfig.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user != null ? User(user) : null;
    });
  }

  String _formatAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('Email not confirmed')) {
      return 'Please verify your email before signing in';
    }
    if (message.contains('User already registered')) {
      return 'This email is already registered';
    }
    return message;
  }
}
