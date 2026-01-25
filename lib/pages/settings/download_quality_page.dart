import 'package:flutter/material.dart';
import 'package:trainexa/services/storage_service.dart';

enum DownloadQuality { high, normal, low }

class DownloadQualityPage extends StatefulWidget {
  const DownloadQualityPage({super.key});

  @override
  State<DownloadQualityPage> createState() => _DownloadQualityPageState();
}

class _DownloadQualityPageState extends State<DownloadQualityPage> {
  final _storage = StorageService();
  DownloadQuality _selectedQuality = DownloadQuality.normal;

  @override
  void initState() {
    super.initState();
    _loadQualitySetting();
  }

  Future<void> _loadQualitySetting() async {
    final quality = await _storage.getSetting('download_quality');
    if (mounted) {
      setState(() {
        _selectedQuality = quality == 'high'
            ? DownloadQuality.high
            : quality == 'low'
                ? DownloadQuality.low
                : DownloadQuality.normal;
      });
    }
  }

  Future<void> _saveQualitySetting(DownloadQuality quality) async {
    await _storage.saveSetting('download_quality', quality.name);
    setState(() => _selectedQuality = quality);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Quality'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choose the quality for downloaded workout videos. Higher quality uses more storage space.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          _QualityOption(
            title: 'High',
            subtitle: 'Highest quality',
            value: DownloadQuality.high,
            selectedValue: _selectedQuality,
            onChanged: _saveQualitySetting,
          ),
          _QualityOption(
            title: 'Normal',
            subtitle: 'Faster download; uses less storage',
            value: DownloadQuality.normal,
            selectedValue: _selectedQuality,
            onChanged: _saveQualitySetting,
          ),
          _QualityOption(
            title: 'Low',
            subtitle: 'Fastest download; uses even less storage',
            value: DownloadQuality.low,
            selectedValue: _selectedQuality,
            onChanged: _saveQualitySetting,
          ),
        ],
      ),
    );
  }
}

class _QualityOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final DownloadQuality value;
  final DownloadQuality selectedValue;
  final ValueChanged<DownloadQuality> onChanged;

  const _QualityOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio<DownloadQuality>(
        value: value,
        groupValue: selectedValue,
        onChanged: (val) => onChanged(val!),
      ),
      onTap: () => onChanged(value),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
    );
  }
}
