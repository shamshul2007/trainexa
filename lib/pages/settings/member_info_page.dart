import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:trainexa/services/storage_service.dart';

class MemberInfoPage extends StatefulWidget {
  const MemberInfoPage({super.key});

  @override
  State<MemberInfoPage> createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  final _authManager = SupabaseAuthManager();
  final _storage = StorageService();
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _authManager.getCurrentUser();
      if (user != null) {
        final profile = await _storage.loadUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _profile = profile;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Failed to load profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authManager.getCurrentUser();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Member Information'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Profile Data',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your profile information is not available yet. Please complete the onboarding process or contact support if you believe this is an error.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (user?.email != null)
                  Text(
                    'Logged in as: ${user!.email}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Information'),
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
          const SizedBox(height: 24),
          _InfoSection(
            title: 'PERSONAL',
            children: [
              _InfoTile(
                label: 'Name',
                value: _profile!.name,
              ),
              _InfoTile(
                label: 'Email',
                value: user?.email ?? 'Not set',
              ),
              _InfoTile(
                label: 'Age',
                value: '${_profile!.age} years',
              ),
              _InfoTile(
                label: 'Sex',
                value: _profile!.sex.toUpperCase(),
              ),
            ],
          ),
          _InfoSection(
            title: 'PHYSICAL',
            children: [
              _InfoTile(
                label: 'Weight',
                value: '${_profile!.weightLbs.toStringAsFixed(1)} lbs',
              ),
              _InfoTile(
                label: 'Height',
                value: '${_profile!.heightCm.toStringAsFixed(0)} cm',
              ),
            ],
          ),
          _InfoSection(
            title: 'FITNESS',
            children: [
              _InfoTile(
                label: 'Experience Level',
                value: _profile!.experienceLevel.toUpperCase(),
              ),
              _InfoTile(
                label: 'Primary Goal',
                value: _profile!.primaryGoal.replaceAll('_', ' ').toUpperCase(),
              ),
              _InfoTile(
                label: 'Equipment',
                value: _profile!.equipmentAvailable.join(', ').toUpperCase(),
              ),
              if (_profile!.constraints.isNotEmpty)
                _InfoTile(
                  label: 'Constraints',
                  value: _profile!.constraints,
                ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile editing coming soon')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
