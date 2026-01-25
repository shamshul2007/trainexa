import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/services/plan_service.dart';
import 'package:trainexa/services/ai_service.dart';
import 'package:trainexa/pages/onboarding/state.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  const WelcomeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fitness_center, size: 70, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The following quick survey will help us personalize your daily health plan.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ProfileBasicsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const ProfileBasicsScreen({super.key, required this.onNext});

  @override
  State<ProfileBasicsScreen> createState() => _ProfileBasicsScreenState();
}

class _ProfileBasicsScreenState extends State<ProfileBasicsScreen> {
  String? _sex;

  bool get _canContinue => _sex != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people, size: 70, color: Colors.pink.shade400),
          ),
          const SizedBox(height: 40),
          Text(
            'How do you identify?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildOptionButton(context, 'Male', _sex == 'male', () => setState(() => _sex = 'male')),
          const SizedBox(height: 12),
          _buildOptionButton(context, 'Female', _sex == 'female', () => setState(() => _sex = 'female')),
          const SizedBox(height: 12),
          _buildOptionButton(context, 'Non-binary', _sex == 'other', () => setState(() => _sex = 'other')),
          const SizedBox(height: 12),
          _buildOptionButton(context, 'Prefer not to disclose', _sex == 'prefer_not', () => setState(() => _sex = 'prefer_not')),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _canContinue ? () {
                OnboardingState.of(context).updateBasics(
                  name: 'User',
                  age: 25,
                  sex: _sex!,
                  weightLbs: 150,
                  heightCm: 170,
                );
                widget.onNext();
              } : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: _canContinue ? null : Colors.grey.shade400,
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? Colors.amber.shade400 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class ExperienceGoalsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const ExperienceGoalsScreen({super.key, required this.onNext});

  @override
  State<ExperienceGoalsScreen> createState() => _ExperienceGoalsScreenState();
}

class _ExperienceGoalsScreenState extends State<ExperienceGoalsScreen> {
  String? _goal;

  bool get _canContinue => _goal != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag, size: 70, color: Colors.green.shade600),
          ),
          const SizedBox(height: 40),
          Text(
            "What's your primary health goal?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildOptionPill('Lose weight', _goal == 'weight_loss', () => setState(() => _goal = 'weight_loss')),
                  const SizedBox(height: 12),
                  _buildOptionPill('Run farther or faster', _goal == 'endurance', () => setState(() => _goal = 'endurance')),
                  const SizedBox(height: 12),
                  _buildOptionPill('Build strength', _goal == 'strength', () => setState(() => _goal = 'strength')),
                  const SizedBox(height: 12),
                  _buildOptionPill('Reduce stress', _goal == 'stress', () => setState(() => _goal = 'stress')),
                  const SizedBox(height: 12),
                  _buildOptionPill('Stay fit', _goal == 'maintain', () => setState(() => _goal = 'maintain')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _canContinue ? () {
                OnboardingState.of(context).updateExperience('beginner', _goal!);
                widget.onNext();
              } : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: _canContinue ? null : Colors.grey.shade400,
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionPill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade400 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class EquipmentConstraintsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const EquipmentConstraintsScreen({super.key, required this.onNext});

  @override
  State<EquipmentConstraintsScreen> createState() => _EquipmentConstraintsScreenState();
}

class _EquipmentConstraintsScreenState extends State<EquipmentConstraintsScreen> {
  String? _equipment;

  bool get _canContinue => _equipment != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.home_filled, size: 70, color: Colors.orange.shade600),
          ),
          const SizedBox(height: 40),
          Text(
            'What equipment do you have?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildOptionPill('Full gym access', _equipment == 'gym', () => setState(() => _equipment = 'gym')),
          const SizedBox(height: 12),
          _buildOptionPill('Home equipment', _equipment == 'home', () => setState(() => _equipment = 'home')),
          const SizedBox(height: 12),
          _buildOptionPill('Minimal / bodyweight', _equipment == 'minimal', () => setState(() => _equipment = 'minimal')),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _canContinue ? () {
                OnboardingState.of(context).updateEquipment([_equipment!], '', 60);
                widget.onNext();
              } : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: _canContinue ? null : Colors.grey.shade400,
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionPill(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade400 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(28),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class ConfirmGenerateScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const ConfirmGenerateScreen({super.key, required this.onFinish});

  @override
  State<ConfirmGenerateScreen> createState() => _ConfirmGenerateScreenState();
}

class _ConfirmGenerateScreenState extends State<ConfirmGenerateScreen> {
  bool loading = false;
  String status = 'Analyzing your profile...';
  final storage = StorageService();

  Future<void> _generate() async {
    setState(() => loading = true);
    try {
      final authManager = SupabaseAuthManager();
      final currentUser = authManager.getCurrentUser();
      
      debugPrint('Current user check: ${currentUser?.uid ?? "null"}');
      
      if (currentUser == null) {
        throw Exception('Not authenticated. If you just signed up, please check your email to confirm your account, then sign in again.');
      }

      setState(() => status = 'Saving your profile...');
      final data = OnboardingState.of(context);
      final profile = UserProfile(
        id: currentUser.uid,
        name: data.name!,
        age: data.age!,
        sex: data.sex!,
        weightLbs: data.weight!,
        heightCm: data.height!,
        experienceLevel: data.experience!,
        primaryGoal: data.goal!,
        equipmentAvailable: data.equipment ?? const [],
        constraints: data.constraints ?? '',
        createdAt: DateTime.now(),
      );
      await storage.saveUserProfile(profile);
      
      setState(() => status = 'Generating your personalized plan...');
      final plan = await PlanService(AIService()).generatePlan(profile);
      
      setState(() => status = 'Saving plan...');
      await storage.saveWorkoutPlan(plan);
      
      widget.onFinish();
    } catch (e) {
      debugPrint('Plan generation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rocket_launch, size: 70, color: Colors.purple.shade600),
          ),
          const SizedBox(height: 40),
          Text(
            'All set!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Let's generate your personalized workout plan based on your goals.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (loading) ...[
            Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 40),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _generate,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Generate My Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ]
        ],
      ),
    );
  }
}

// Simple inherited holder for onboarding data across screens
// State is provided by OnboardingFlow via OnboardingState InheritedWidget
