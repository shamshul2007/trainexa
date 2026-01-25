import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:trainexa/models/workout_plan.dart';
import 'package:trainexa/models/workout_session.dart';
import 'package:trainexa/supabase/supabase_config.dart';

/// Supabase storage service for user data
class StorageService {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _onboardingDataKey = 'onboarding_data';

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      debugPrint('Failed to check onboarding status: $e');
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      debugPrint('Failed to mark onboarding completed: $e');
    }
  }

  /// Save onboarding data temporarily (to be used during signup)
  Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_onboardingDataKey, jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to save onboarding data: $e');
    }
  }

  /// Get saved onboarding data
  Future<Map<String, dynamic>?> getOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_onboardingDataKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(dataStr));
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get onboarding data: $e');
      return null;
    }
  }

  /// Clear onboarding data
  Future<void> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingDataKey);
    } catch (e) {
      debugPrint('Failed to clear onboarding data: $e');
    }
  }
  /// Load user profile by user ID
  Future<UserProfile?> loadUserProfile(String userId) async {
    try {
      final data = await SupabaseService.selectSingle(
        'user_profiles',
        filters: {'id': userId},
      );
      return data != null ? UserProfile.fromJson(data) : null;
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      return null;
    }
  }

  /// Save or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      // Check if user exists
      final existing = await loadUserProfile(profile.id);
      
      if (existing != null) {
        // Update existing
        await SupabaseService.update(
          'user_profiles',
          profile.toJson(),
          filters: {'id': profile.id},
        );
      } else {
        // Insert new (use auth user ID as profile ID)
        await SupabaseService.insert('user_profiles', profile.toJson());
      }
    } catch (e) {
      debugPrint('Failed to save user profile: $e');
      rethrow;
    }
  }

  /// Load current workout plan for a user
  Future<WorkoutPlan?> loadWorkoutPlan(String userId) async {
    try {
      final results = await SupabaseService.select(
        'workout_plans',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
        limit: 1,
      );
      return results.isNotEmpty ? WorkoutPlan.fromJson(results.first) : null;
    } catch (e) {
      debugPrint('Failed to load workout plan: $e');
      return null;
    }
  }

  /// Save a new workout plan
  Future<void> saveWorkoutPlan(WorkoutPlan plan) async {
    try {
      // Let Supabase auto-generate UUID for the plan
      final data = plan.toJson();
      data.remove('id'); // Remove client-generated ID
      await SupabaseService.insert('workout_plans', data);
    } catch (e) {
      debugPrint('Failed to save workout plan: $e');
      rethrow;
    }
  }

  /// Load workout sessions for a user
  Future<List<WorkoutSession>> loadSessions(String userId) async {
    try {
      final results = await SupabaseService.select(
        'workout_sessions',
        filters: {'user_id': userId},
        orderBy: 'date',
        ascending: false,
      );
      return results.map((e) => WorkoutSession.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Failed to load sessions: $e');
      return [];
    }
  }

  /// Save a new workout session
  Future<void> saveSession(WorkoutSession session) async {
    try {
      // Let Supabase auto-generate UUID
      final data = session.toJson();
      data.remove('id'); // Remove client-generated ID
      await SupabaseService.insert('workout_sessions', data);
    } catch (e) {
      debugPrint('Failed to save session: $e');
      rethrow;
    }
  }

  /// Update an existing workout session
  Future<void> updateSession(WorkoutSession session) async {
    try {
      await SupabaseService.update(
        'workout_sessions',
        session.toJson(),
        filters: {'id': session.id},
      );
    } catch (e) {
      debugPrint('Failed to update session: $e');
      rethrow;
    }
  }

  /// Delete a workout session
  Future<void> deleteSession(String sessionId) async {
    try {
      await SupabaseService.delete(
        'workout_sessions',
        filters: {'id': sessionId},
      );
    } catch (e) {
      debugPrint('Failed to delete session: $e');
      rethrow;
    }
  }

  /// Save a user setting
  Future<void> saveSetting(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('setting_$key', value);
    } catch (e) {
      debugPrint('Failed to save setting $key: $e');
    }
  }

  /// Get a user setting
  Future<String?> getSetting(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('setting_$key');
    } catch (e) {
      debugPrint('Failed to get setting $key: $e');
      return null;
    }
  }
}
