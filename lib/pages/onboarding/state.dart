import 'package:flutter/widgets.dart';

class OnboardingState extends InheritedWidget {
  final String? name;
  final int? age;
  final String? sex;
  final double? weight;
  final double? height;
  final String? experience;
  final String? goal;
  final List<String>? equipment;
  final String? constraints;
  final int? timePerWorkout;

  final void Function({required String name, required int age, required String sex, required double weightLbs, required double heightCm}) updateBasics;
  final void Function(String exp, String goal) updateExperience;
  final void Function(List<String> equipment, String constraints, int time) updateEquipment;

  const OnboardingState({
    super.key,
    required super.child,
    this.name,
    this.age,
    this.sex,
    this.weight,
    this.height,
    this.experience,
    this.goal,
    this.equipment,
    this.constraints,
    this.timePerWorkout,
    required this.updateBasics,
    required this.updateExperience,
    required this.updateEquipment,
  });

  static OnboardingState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<OnboardingState>()!;

  @override
  bool updateShouldNotify(covariant OnboardingState oldWidget) => true;
}
