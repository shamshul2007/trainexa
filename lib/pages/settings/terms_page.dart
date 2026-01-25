import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  String get _lastUpdated {
    final now = DateTime.now();
    return '${_monthName(now.month)} ${now.day}, ${now.year}';
  }

  String _monthName(int month) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: $_lastUpdated',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const _Section(
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using Trainexa, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            const _Section(
              title: '2. Use License',
              content:
                  'Permission is granted to temporarily use Trainexa for personal, non-commercial use only. This is the grant of a license, not a transfer of title.',
            ),
            const _Section(
              title: '3. User Responsibilities',
              content:
                  'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
            ),
            const _Section(
              title: '4. Health Disclaimer',
              content:
                  'Trainexa provides fitness information and workout plans. Consult with a qualified healthcare professional before starting any exercise program. We are not responsible for any injuries or health issues that may occur.',
            ),
            const _Section(
              title: '5. Content Accuracy',
              content:
                  'While we strive to provide accurate information, we make no warranties about the completeness, reliability, or accuracy of the workout plans and fitness information.',
            ),
            const _Section(
              title: '6. Modifications',
              content:
                  'We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the modified terms.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}
