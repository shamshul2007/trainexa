import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _authManager = SupabaseAuthManager();
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Check if user is authenticated
    final currentUser = _authManager.getCurrentUser();
    
    if (currentUser == null) {
      // Not authenticated - check if onboarding completed
      final onboardingCompleted = await _storage.isOnboardingCompleted();
      if (!mounted) return;
      
      if (onboardingCompleted) {
        // Onboarding done, go to login
        context.go(Routes.login);
      } else {
        // New user - start with onboarding
        context.go(Routes.onboarding);
      }
    } else {
      // Authenticated - go directly to home (Plan screen is first)
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text('Trainexa', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
