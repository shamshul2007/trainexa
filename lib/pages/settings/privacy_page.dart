import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: $_lastUpdated',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const _Section(
              title: 'Information We Collect',
              content:
                  'We collect information you provide directly to us, including your name, email address, age, fitness goals, and workout preferences. We also collect usage data to improve our services.',
            ),
            const _Section(
              title: 'How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services, including generating personalized workout plans, tracking your progress, and communicating with you about your account.',
            ),
            const _Section(
              title: 'Data Storage',
              content:
                  'Your data is securely stored using industry-standard encryption. We use Supabase as our database provider, which complies with GDPR and other privacy regulations.',
            ),
            const _Section(
              title: 'Information Sharing',
              content:
                  'We do not sell your personal information. We may share your information with third-party service providers who help us operate our app, but only to the extent necessary.',
            ),
            const _Section(
              title: 'Your Rights',
              content:
                  'You have the right to access, update, or delete your personal information at any time. You can do this through your account settings or by contacting us directly.',
            ),
            const _Section(
              title: 'Data Retention',
              content:
                  'We retain your information for as long as your account is active or as needed to provide you services. You may delete your account at any time.',
            ),
            const _Section(
              title: 'Security',
              content:
                  'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),
            const _Section(
              title: 'Changes to This Policy',
              content:
                  'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            const _Section(
              title: 'Contact Us',
              content:
                  'If you have any questions about this privacy policy, please contact us through the app\'s support section.',
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
