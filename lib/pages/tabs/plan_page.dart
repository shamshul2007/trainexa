import 'package:flutter/material.dart';
import 'package:trainexa/models/workout_plan.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final storage = StorageService();
  WorkoutPlan? plan;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authManager = SupabaseAuthManager();
    final user = authManager.getCurrentUser();
    if (user == null) {
      setState(() => loading = false);
      return;
    }
    final p = await storage.loadWorkoutPlan(user.uid);
    setState(() {
      plan = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (plan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48),
              const SizedBox(height: 12),
              const Text('No plan yet. Complete onboarding to generate your plan.'),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Your Training Plan', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text('${plan!.trainingSplit.toUpperCase()} • ${plan!.durationWeeks} weeks'),
        Text('${plan!.startDate.toString().split(' ').first} to ${plan!.endDate.toString().split(' ').first}'),
        const SizedBox(height: 16),
        ...plan!.workouts.map((w) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text('${w.day}: ${w.name}'),
            subtitle: Text('${w.exercises.length} exercises'),
            children: w.exercises.map((ex) => ListTile(
              dense: true,
              title: Text(ex.name),
              subtitle: Text('${ex.sets} x ${ex.reps} • ${ex.restSeconds}s rest'),
            )).toList(),
          ),
        )),
      ],
    );
  }
}
