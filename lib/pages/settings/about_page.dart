import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Trainexa',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_version.isNotEmpty)
            Text(
              'Version $_version ($_buildNumber)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your personalized AI-powered fitness coach. Get custom workout plans tailored to your goals and track your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 48),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acknowledgements'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Trainexa',
                applicationVersion: _version,
                applicationIcon: Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© ${DateTime.now().year} Trainexa. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
