import 'package:flutter/material.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Storage'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Usage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _StorageBar(
                      label: 'Downloaded Workouts',
                      used: 245,
                      total: 1024,
                    ),
                    const SizedBox(height: 12),
                    _StorageBar(
                      label: 'App Data',
                      used: 18,
                      total: 1024,
                    ),
                    const SizedBox(height: 12),
                    _StorageBar(
                      label: 'Cache',
                      used: 52,
                      total: 1024,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'MANAGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            subtitle: const Text('52 MB'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Cache'),
                  content: const Text('This will clear 52 MB of cached data.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared')),
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Manage Downloads'),
            subtitle: const Text('245 MB'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download management coming soon')),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  final String label;
  final int used; // in MB
  final int total; // in MB

  const _StorageBar({
    required this.label,
    required this.used,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (used / total * 100).toInt();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$used MB', style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: used / total,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
