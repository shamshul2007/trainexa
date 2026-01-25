import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:trainexa/models/workout_plan.dart';
import 'package:trainexa/services/ai_service.dart';

/// Generates workout plans using the AI proxy endpoint.
class PlanService {
  final AIService _ai;
  PlanService(this._ai);

  Future<WorkoutPlan> generatePlan(UserProfile profile, {String? lastWeekSummary}) async {
    final systemPrompt =
        'You are an expert AI personal trainer. Your job is to create personalized workout programs that are: \n'
        '1. Safe and appropriate for the user\'s experience level\n'
        '2. Aligned with their specific goal\n'
        '3. Feasible given their equipment and time constraints\n'
        '4. Progressive (harder each week within a 4–8 week cycle)\n'
        'Output plans in JSON format with exact exercise names, sets, reps, tempo, rest periods, and form cues. Always include warmup, main work, supplemental work, cooldown. Be specific with numbers.';

    final userPrompt = '''Create a 4-week program for:
Name: ${profile.name}
Age: ${profile.age}, Sex: ${profile.sex}
Experience: ${profile.experienceLevel}
Goal: ${profile.primaryGoal}
Equipment: ${profile.equipmentAvailable.join(', ')}
Constraints: ${profile.constraints}
Time per session: ~${_timePerSessionGuess(profile)} minutes
${lastWeekSummary != null ? 'Last Week Performance: $lastWeekSummary' : ''}
Use a split appropriate to the info above (e.g., full body, PPL, upper/lower) 3–4 days/week.
Format JSON exactly as:
{
  "plan_name": "...",
  "duration_weeks": 4,
  "workouts": [
    {"day": "Monday", "name": "...", "exercises": [{
      "name": "...", "sets": 4, "reps": 8, "tempo": "2-1-2",
      "rest_seconds": 120, "weight_guidance": "RPE 7", "cues": ["..."]
    }]}]
}
''';

    final res = await _ai.createChatCompletion(
      model: 'gpt-4o',
      responseFormat: {'type': 'json_object'},
      messages: [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userPrompt},
          ]
        },
      ],
    );

    // Extract JSON
    final content = ((res['choices'] as List).first['message']['content']) as String;
    final parsed = _safeJsonDecode(content);
    final workouts = (parsed['workouts'] as List<dynamic>)
        .map((w) => WorkoutDay.fromJson(w as Map<String, dynamic>))
        .toList();

    final start = DateTime.now();
    final end = start.add(const Duration(days: 28));
    final plan = WorkoutPlan(
      id: 'plan_${start.millisecondsSinceEpoch}',
      userId: profile.id,
      startDate: DateTime(start.year, start.month, start.day),
      endDate: DateTime(end.year, end.month, end.day),
      durationWeeks: 4,
      trainingSplit: _inferSplit(workouts),
      workouts: workouts,
      generatedAt: DateTime.now(),
      aiModel: 'proxy',
    );
    return plan;
  }

  Map<String, dynamic> _safeJsonDecode(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Malformed AI JSON, attempting salvage: $e');
      // Try to locate JSON object delimiters
      final start = source.indexOf('{');
      final end = source.lastIndexOf('}');
      if (start >= 0 && end > start) {
        final slice = source.substring(start, end + 1);
        return jsonDecode(slice) as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  String _inferSplit(List<WorkoutDay> days) {
    final names = days.map((e) => e.name.toLowerCase()).join(' ');
    if (names.contains('push') && names.contains('pull') && names.contains('leg')) return 'ppl';
    if (names.contains('upper') && names.contains('lower')) return 'upper_lower';
    return 'full_body';
  }

  int _timePerSessionGuess(UserProfile p) => 60; // refined later
}
