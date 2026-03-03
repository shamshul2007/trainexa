import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/routes.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _authManager = SupabaseAuthManager();
  final _storage = StorageService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    
    // Listen to auth state changes and reload profile
    _authManager.authStateChanges().listen((user) {
      if (mounted) {
        if (user != null) {
          _loadProfile();
        } else {
          setState(() {
            _profile = null;
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = _authManager.getCurrentUser();
      debugPrint('Loading profile for user: ${user?.uid}');
      
      if (user != null) {
        final profile = await _storage.loadUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _profile = profile;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _profile = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authManager.signOut();
      if (mounted) {
        context.go(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _authManager.getCurrentUser();

    // If not authenticated, show message
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Not signed in',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in to view your account',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(Routes.login),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 60,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          if (_profile != null) ...[
            Text(
              _profile!.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
          ],
          if (user?.email != null)
            Text(
              user!.email!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile & Goals'),
            subtitle: _profile != null ? Text('${_profile!.experienceLevel} • ${_profile!.primaryGoal}') : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await context.push('/edit-profile');
              // Reload profile after editing
              _loadProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings & Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: _logout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
