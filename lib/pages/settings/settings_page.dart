import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';
import 'package:trainexa/routes.dart';
import 'package:trainexa/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authManager = SupabaseAuthManager();
  final _storage = StorageService();
  bool _notificationsEnabled = true;
  bool _healthTrackingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notifications = await _storage.getSetting('notifications_enabled');
    final healthTracking = await _storage.getSetting('health_tracking_enabled');
    if (mounted) {
      setState(() {
        _notificationsEnabled = notifications == 'true';
        _healthTrackingEnabled = healthTracking == 'true';
      });
    }
  }

  Future<void> _saveNotificationSetting(bool value) async {
    await _storage.saveSetting('notifications_enabled', value.toString());
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveHealthTrackingSetting(bool value) async {
    await _storage.saveSetting('health_tracking_enabled', value.toString());
    setState(() => _healthTrackingEnabled = value);
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
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
    final theme = Theme.of(context);
    final user = _authManager.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'ACCOUNT',
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: 'Member Information',
                onTap: () => context.push('/settings/member-info'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'PREFERENCES',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _saveNotificationSetting,
                ),
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: 'Download Quality',
                onTap: () => context.push('/settings/download-quality'),
              ),
              _SettingsTile(
                icon: Icons.favorite_outline,
                title: 'Health Tracking',
                trailing: Switch(
                  value: _healthTrackingEnabled,
                  onChanged: _saveHealthTrackingSetting,
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'STORAGE',
            children: [
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: 'Manage Storage',
                onTap: () => context.push('/settings/storage'),
              ),
            ],
          ),
          _SettingsSection(
            title: 'SUPPORT',
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Get Help',
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening help center...')),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.star_outline,
                title: 'Rate the App',
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening app store...')),
                  );
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'LEGAL',
            children: [
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => context.push('/settings/terms'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => context.push('/settings/privacy'),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () => context.push('/settings/about'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _handleSignOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 8),
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Signed in as ${user!.email}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
