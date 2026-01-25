import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trainexa/models/workout_plan.dart';
import 'package:trainexa/models/workout_session.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';

class WorkoutPlayerPage extends StatefulWidget {
  const WorkoutPlayerPage({super.key});

  @override
  State<WorkoutPlayerPage> createState() => _WorkoutPlayerPageState();
}

class _WorkoutPlayerPageState extends State<WorkoutPlayerPage> {
  final storage = StorageService();
  WorkoutPlan? plan;
  WorkoutDay? currentDay;
  int exerciseIndex = 0;
  int setIndex = 0;
  int restSeconds = 0;
  Timer? _timer;

  final repsCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  final List<SetLog> logs = [];
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authManager = SupabaseAuthManager();
    final user = authManager.getCurrentUser();
    if (user == null) return;
    final p = await storage.loadWorkoutPlan(user.uid);
    setState(() {
      plan = p;
      currentDay = p?.workouts.isNotEmpty == true ? p!.workouts.first : null;
      startTime = DateTime.now();
    });
    _loadTargets();
  }

  void _loadTargets() {
    final ex = _currentExercise;
    if (ex == null) return;
    repsCtrl.text = ex.reps.toString();
    weightCtrl.text = '0';
  }

  ExerciseItem? get _currentExercise => (currentDay == null || exerciseIndex >= (currentDay!.exercises.length)) ? null : currentDay!.exercises[exerciseIndex];

  void _logSet() {
    final ex = _currentExercise;
    if (ex == null) return;
    final reps = int.tryParse(repsCtrl.text) ?? ex.reps;
    final weight = double.tryParse(weightCtrl.text) ?? 0;
    logs.add(SetLog(
      exercise: ex.name,
      setNumber: setIndex + 1,
      repsTarget: ex.reps,
      repsAchieved: reps,
      weightLbs: weight,
      rpe: null,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      timestamp: DateTime.now(),
    ));

    final rest = ex.restSeconds;
    setState(() {
      setIndex++;
      restSeconds = rest;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (restSeconds <= 0) {
        t.cancel();
        setState(() {});
      } else {
        setState(() => restSeconds--);
      }
    });

    if (setIndex >= ex.sets) {
      // move to next exercise
      setState(() {
        exerciseIndex++;
        setIndex = 0;
      });
      _loadTargets();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _finishWorkout() async {
    final authManager = SupabaseAuthManager();
    final user = authManager.getCurrentUser();
    if (user == null || startTime == null) return;

    final duration = DateTime.now().difference(startTime!).inMinutes;
    final totalVolume = logs.fold<double>(0, (sum, log) => sum + (log.weightLbs * log.repsAchieved));

    final session = WorkoutSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.uid,
      workoutId: currentDay?.name ?? 'unknown',
      date: DateTime.now(),
      durationMinutes: duration,
      completed: true,
      setsLogged: logs,
      totalVolumeLbs: totalVolume,
    );

    try {
      await storage.saveSession(session);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout saved!')));
      setState(() {
        logs.clear();
        exerciseIndex = 0;
        setIndex = 0;
        startTime = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (plan == null || currentDay == null) {
      return const Center(child: Text('No workout loaded. Generate a plan first.'));
    }
    final ex = _currentExercise;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(currentDay!.name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${DateTime.now().toLocal().toString().split(' ').first}')
        ]),
        const SizedBox(height: 12),
        if (ex != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ex.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Target: ${ex.sets} x ${ex.reps} • Rest ${ex.restSeconds}s'),
                const SizedBox(height: 8),
                Text('Cues: ${ex.cues.join(', ')}'),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: repsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reps Achieved'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight Used (lbs)'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            FilledButton(onPressed: _logSet, child: const Text('Log Set')),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () => setState(() => notesCtrl.clear()), child: const Text('Skip Set')),
          ]),
          const SizedBox(height: 12),
          if (restSeconds > 0) Text('Rest: ${Duration(seconds: restSeconds).toString().substring(2, 7)}'),
          const Divider(),
          Text('Progress: Set ${setIndex + 1}/${ex.sets} • Exercise ${exerciseIndex + 1}/${currentDay!.exercises.length}'),
        ] else ...[
          const Text('Workout complete! 🎉'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _finishWorkout, child: const Text('Finish & Save Workout')),
          ),
        ]
      ]),
    );
  }
}
