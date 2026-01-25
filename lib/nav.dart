import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trainexa/pages/onboarding/onboarding_flow.dart';
import 'package:trainexa/pages/splash_page.dart';
import 'package:trainexa/pages/auth/login_page.dart';
import 'package:trainexa/pages/auth/signup_page.dart';
import 'package:trainexa/pages/tabs/plan_page.dart';
import 'package:trainexa/pages/tabs/workout_player_page.dart';
import 'package:trainexa/pages/tabs/progress_page.dart';
import 'package:trainexa/pages/tabs/chat_page.dart';
import 'package:trainexa/pages/account_page.dart';
import 'package:trainexa/pages/settings/settings_page.dart';
import 'package:trainexa/pages/settings/member_info_page.dart';
import 'package:trainexa/pages/settings/download_quality_page.dart';
import 'package:trainexa/pages/settings/storage_page.dart';
import 'package:trainexa/pages/settings/about_page.dart';
import 'package:trainexa/pages/settings/terms_page.dart';
import 'package:trainexa/pages/settings/privacy_page.dart';
import 'package:trainexa/routes.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to Routes
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        pageBuilder: (context, state) => const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'signup',
        pageBuilder: (context, state) => const NoTransitionPage(child: SignupPage()),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => const NoTransitionPage(child: OnboardingFlow()),
      ),
      GoRoute(
        path: Routes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(child: HomeShell()),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        pageBuilder: (context, state) => const MaterialPage(child: AccountPage()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => const MaterialPage(child: SettingsPage()),
      ),
      GoRoute(
        path: '/settings/member-info',
        name: 'member-info',
        pageBuilder: (context, state) => const MaterialPage(child: MemberInfoPage()),
      ),
      GoRoute(
        path: '/settings/download-quality',
        name: 'download-quality',
        pageBuilder: (context, state) => const MaterialPage(child: DownloadQualityPage()),
      ),
      GoRoute(
        path: '/settings/storage',
        name: 'storage',
        pageBuilder: (context, state) => const MaterialPage(child: StoragePage()),
      ),
      GoRoute(
        path: '/settings/about',
        name: 'about',
        pageBuilder: (context, state) => const MaterialPage(child: AboutPage()),
      ),
      GoRoute(
        path: '/settings/terms',
        name: 'terms',
        pageBuilder: (context, state) => const MaterialPage(child: TermsPage()),
      ),
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        pageBuilder: (context, state) => const MaterialPage(child: PrivacyPage()),
      ),
    ],
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _pages = const [
    PlanPage(),
    WorkoutPlayerPage(),
    ProgressPage(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainexa'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/account'),
            tooltip: 'Account',
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Workout'),
          NavigationDestination(icon: Icon(Icons.show_chart), selectedIcon: Icon(Icons.show_chart), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Coach'),
        ],
      ),
    );
  }
}
