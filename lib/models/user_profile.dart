import 'dart:convert';

/// Core user profile captured during onboarding
class UserProfile {
  final String id;
  final String name;
  final int age;
  final String sex; // male | female | other
  final double weightLbs;
  final double heightCm;
  final String experienceLevel; // beginner | intermediate | advanced
  final String primaryGoal; // muscle | strength | endurance | weight_loss | toned | hybrid
  final List<String> equipmentAvailable; // [home, gym, minimal]
  final String constraints; // free text
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.weightLbs,
    required this.heightCm,
    required this.experienceLevel,
    required this.primaryGoal,
    required this.equipmentAvailable,
    required this.constraints,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'sex': sex,
        'weight_lbs': weightLbs,
        'height_cm': heightCm,
        'experience_level': experienceLevel,
        'primary_goal': primaryGoal,
        'equipment_available': equipmentAvailable,
        'constraints': constraints,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        age: (json['age'] as num).toInt(),
        sex: json['sex'] as String,
        weightLbs: (json['weight_lbs'] as num).toDouble(),
        heightCm: (json['height_cm'] as num).toDouble(),
        experienceLevel: json['experience_level'] as String,
        primaryGoal: json['primary_goal'] as String,
        equipmentAvailable: List<String>.from(json['equipment_available'] ?? const []),
        constraints: json['constraints'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String encode() => jsonEncode(toJson());
  static UserProfile? tryDecode(String? source) {
    if (source == null || source.isEmpty) return null;
    try {
      final data = jsonDecode(source) as Map<String, dynamic>;
      if (!data.containsKey('id') || !data.containsKey('name')) return null;
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
