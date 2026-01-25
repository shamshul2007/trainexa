import 'dart:convert';

class SetLog {
  final String exercise;
  final int setNumber;
  final int repsTarget;
  final int repsAchieved;
  final double weightLbs;
  final int? rpe; // 1-10 optional
  final String? notes;
  final DateTime timestamp;

  const SetLog({
    required this.exercise,
    required this.setNumber,
    required this.repsTarget,
    required this.repsAchieved,
    required this.weightLbs,
    this.rpe,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'exercise': exercise,
        'set_number': setNumber,
        'reps_target': repsTarget,
        'reps_achieved': repsAchieved,
        'weight_lbs': weightLbs,
        'rpe': rpe,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SetLog.fromJson(Map<String, dynamic> json) => SetLog(
        exercise: json['exercise'] as String,
        setNumber: (json['set_number'] as num).toInt(),
        repsTarget: (json['reps_target'] as num).toInt(),
        repsAchieved: (json['reps_achieved'] as num).toInt(),
        weightLbs: (json['weight_lbs'] as num).toDouble(),
        rpe: (json['rpe'] as num?)?.toInt(),
        notes: json['notes'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class WorkoutSession {
  final String id;
  final String userId;
  final String workoutId; // reference inside plan
  final DateTime date;
  final int durationMinutes;
  final bool completed;
  final List<SetLog> setsLogged;
  final double totalVolumeLbs;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.date,
    required this.durationMinutes,
    required this.completed,
    required this.setsLogged,
    required this.totalVolumeLbs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'workout_id': workoutId,
        'date': date.toIso8601String().substring(0, 10),
        'duration_minutes': durationMinutes,
        'completed': completed,
        'sets_logged': setsLogged.map((e) => e.toJson()).toList(),
        'total_volume_lbs': totalVolumeLbs,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        workoutId: json['workout_id'] as String,
        date: DateTime.parse(json['date'] as String),
        durationMinutes: (json['duration_minutes'] as num).toInt(),
        completed: json['completed'] as bool? ?? false,
        setsLogged: (json['sets_logged'] as List<dynamic>)
            .map((e) => SetLog.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalVolumeLbs: (json['total_volume_lbs'] as num).toDouble(),
      );

  String encode() => jsonEncode(toJson());
  static WorkoutSession? tryDecode(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      final data = jsonDecode(source) as Map<String, dynamic>;
      if (!data.containsKey('id')) return null;
      return WorkoutSession.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
