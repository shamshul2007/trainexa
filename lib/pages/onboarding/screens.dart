import 'package:flutter/material.dart';
import 'package:trainexa/pages/onboarding/state.dart';

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
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _sex;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _canContinue => 
    _nameController.text.trim().isNotEmpty &&
    _ageController.text.trim().isNotEmpty &&
    _heightController.text.trim().isNotEmpty &&
    _weightController.text.trim().isNotEmpty &&
    _sex != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'Enter your age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            hintText: '170',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight (lbs)',
                            hintText: '150',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How do you identify?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionButton(context, 'Male', _sex == 'male', () => setState(() => _sex = 'male')),
                  const SizedBox(height: 12),
                  _buildOptionButton(context, 'Female', _sex == 'female', () => setState(() => _sex = 'female')),
                  const SizedBox(height: 12),
                  _buildOptionButton(context, 'Non-binary', _sex == 'other', () => setState(() => _sex = 'other')),
                  const SizedBox(height: 12),
                  _buildOptionButton(context, 'Prefer not to disclose', _sex == 'prefer_not', () => setState(() => _sex = 'prefer_not')),
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
                OnboardingState.of(context).updateBasics(
                  name: _nameController.text.trim(),
                  age: int.tryParse(_ageController.text.trim()) ?? 25,
                  sex: _sex!,
                  weightLbs: double.tryParse(_weightController.text.trim()) ?? 150,
                  heightCm: double.tryParse(_heightController.text.trim()) ?? 170,
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

  Future<void> _continue() async {
    // Simply complete onboarding - signup will handle plan generation
    widget.onFinish();
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: loading ? null : _continue,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue to Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Simple inherited holder for onboarding data across screens
// State is provided by OnboardingFlow via OnboardingState InheritedWidget
