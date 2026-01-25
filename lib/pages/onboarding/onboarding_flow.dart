import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trainexa/routes.dart';
import 'package:trainexa/pages/onboarding/screens.dart';
import 'package:trainexa/pages/onboarding/state.dart';
import 'package:trainexa/services/storage_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  final _storage = StorageService();

  int _index = 0;

  // Shared state captured across steps
  String? _name;
  int? _age;
  String? _sex;
  double? _weight;
  double? _height;
  String? _experience;
  String? _goal;
  List<String>? _equipment;
  String? _constraints;
  int? _timePerWorkout;

  void _next() {
    if (_index < 4) {
      _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    // Save onboarding data for later use during signup
    await _storage.saveOnboardingData({
      'name': _name ?? '',
      'age': _age ?? 0,
      'sex': _sex ?? '',
      'weight': _weight ?? 0,
      'height': _height ?? 0,
      'experience': _experience ?? '',
      'goal': _goal ?? '',
      'equipment': _equipment ?? [],
      'constraints': _constraints ?? '',
      'timePerWorkout': _timePerWorkout ?? 0,
    });
    
    // Navigate to signup page
    if (!mounted) return;
    context.go(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingState(
      name: _name,
      age: _age,
      sex: _sex,
      weight: _weight,
      height: _height,
      experience: _experience,
      goal: _goal,
      equipment: _equipment,
      constraints: _constraints,
      timePerWorkout: _timePerWorkout,
      updateBasics: ({required String name, required int age, required String sex, required double weightLbs, required double heightCm}) {
        setState(() {
          _name = name;
          _age = age;
          _sex = sex;
          _weight = weightLbs;
          _height = heightCm;
        });
      },
      updateExperience: (String exp, String goal) => setState(() {
        _experience = exp;
        _goal = goal;
      }),
      updateEquipment: (List<String> equipment, String constraints, int time) => setState(() {
        _equipment = equipment;
        _constraints = constraints;
        _timePerWorkout = time;
      }),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    if (_index > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _controller.previousPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_index + 1) / 5,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    WelcomeScreen(onNext: _next),
                    ProfileBasicsScreen(onNext: _next),
                    ExperienceGoalsScreen(onNext: _next),
                    EquipmentConstraintsScreen(onNext: _next),
                    ConfirmGenerateScreen(onFinish: _completeOnboarding),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
