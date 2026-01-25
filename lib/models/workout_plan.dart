import 'dart:convert';

class ExerciseItem {
  final String name;
  final int sets;
  final int reps;
  final String tempo; // e.g., 2-1-2
  final int restSeconds;
  final String weightGuidance; // e.g., 85% 1RM
  final List<String> cues;

  const ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
    required this.tempo,
    required this.restSeconds,
    required this.weightGuidance,
    required this.cues,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'tempo': tempo,
        'rest_seconds': restSeconds,
        'weight_guidance': weightGuidance,
        'cues': cues,
      };

  factory ExerciseItem.fromJson(Map<String, dynamic> json) => ExerciseItem(
        name: json['name'] as String,
        sets: (json['sets'] as num).toInt(),
        reps: (json['reps'] as num).toInt(),
        tempo: json['tempo'] as String? ?? '2-1-2',
        restSeconds: (json['rest_seconds'] as num?)?.toInt() ?? 120,
        weightGuidance: json['weight_guidance'] as String? ?? '',
        cues: List<String>.from(json['cues'] ?? const []),
      );
}

class WorkoutDay {
  final String day; // Monday, etc
  final String name; // Push A
  final List<ExerciseItem> exercises;

  const WorkoutDay({required this.day, required this.name, required this.exercises});

  Map<String, dynamic> toJson() => {
        'day': day,
        'name': name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) => WorkoutDay(
        day: json['day'] as String,
        name: json['name'] as String,
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExerciseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutPlan {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final int durationWeeks;
  final String trainingSplit; // ppl, full_body, etc
  final List<WorkoutDay> workouts;
  final DateTime generatedAt;
  final String aiModel;

  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.durationWeeks,
    required this.trainingSplit,
    required this.workouts,
    required this.generatedAt,
    required this.aiModel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate.toIso8601String().substring(0, 10),
        'duration_weeks': durationWeeks,
        'training_split': trainingSplit,
        'workouts': workouts.map((e) => e.toJson()).toList(),
        'generated_at': generatedAt.toIso8601String(),
        'ai_model': aiModel,
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        durationWeeks: (json['duration_weeks'] as num).toInt(),
        trainingSplit: json['training_split'] as String,
        workouts: (json['workouts'] as List<dynamic>)
            .map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        generatedAt: DateTime.parse(json['generated_at'] as String),
        aiModel: json['ai_model'] as String? ?? 'proxy',
      );

  String encode() => jsonEncode(toJson());
  static WorkoutPlan? tryDecode(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      final data = jsonDecode(source) as Map<String, dynamic>;
      if (!data.containsKey('id') || !data.containsKey('workouts')) return null;
      return WorkoutPlan.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
