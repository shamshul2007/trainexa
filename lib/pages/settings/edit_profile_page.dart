import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';
import 'package:trainexa/models/user_profile.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/services/plan_service.dart';
import 'package:trainexa/services/ai_service.dart';
import 'package:trainexa/utils/profile_value_mappings.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authManager = SupabaseAuthManager();
  final _storage = StorageService();

  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _profile;

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String? _sex;
  String? _experience;
  String? _goal;
  List<String> _equipment = [];
  String? _constraints;

  final _sexOptions = ['Male', 'Female', 'Other'];
  final _experienceOptions = ['Beginner', 'Intermediate', 'Advanced'];
  final _goalOptions = ['Lose Weight', 'Build Muscle', 'Get Stronger', 'Improve Endurance', 'General Fitness'];
  final _equipmentOptions = ['Dumbbells', 'Barbell', 'Resistance Bands', 'Pull-up Bar', 'Bench', 'Kettlebell', 'None'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }


  Future<void> _loadProfile() async {
    try {
      final user = _authManager.getCurrentUser();
      if (user != null) {
        final profile = await _storage.loadUserProfile(user.uid);
        if (mounted) {
          if (profile != null) {
            setState(() {
              _profile = profile;
              _nameController.text = profile.name;
              _ageController.text = profile.age.toString();
              _weightController.text = profile.weightLbs.toString();
              _heightController.text = profile.heightCm.toString();
              // Convert database values to UI values
              _sex = ProfileValueMappings.sexToUi(profile.sex);
              _experience = ProfileValueMappings.experienceToUi(profile.experienceLevel);
              _goal = ProfileValueMappings.goalToUi(profile.primaryGoal);
              _equipment = List.from(profile.equipmentAvailable);
              _constraints = profile.constraints;
              _isLoading = false;
            });
          } else {
            // No profile found — still ensure loading false
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Failed to load profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile({bool regeneratePlan = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = _authManager.getCurrentUser();
      if (user == null) throw Exception('Not authenticated');

      // Convert UI values to database values
      final updatedProfile = UserProfile(
        id: user.uid,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        sex: ProfileValueMappings.sexToDb(_sex!),
        weightLbs: double.parse(_weightController.text),
        heightCm: double.parse(_heightController.text),
        experienceLevel: ProfileValueMappings.experienceToDb(_experience!),
        primaryGoal: ProfileValueMappings.goalToDb(_goal!),
        equipmentAvailable: _equipment,
        constraints: _constraints ?? '',
        createdAt: _profile?.createdAt ?? DateTime.now(),
      );

      await _storage.saveUserProfile(updatedProfile);

      if (regeneratePlan) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regenerating your workout plan...'),
            duration: Duration(seconds: 3),
          ),
        );

        final planService = PlanService(AIService());
        final plan = await planService.generatePlan(updatedProfile);
        await _storage.saveWorkoutPlan(plan);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(regeneratePlan ? 'Profile updated and plan regenerated!' : 'Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      debugPrint('Failed to save profile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmSave() async {
    // Compare UI values with database values (convert to DB format for comparison)
    final goalChanged = _goal != null && ProfileValueMappings.goalToDb(_goal!) != _profile?.primaryGoal;
    final experienceChanged = _experience != null && ProfileValueMappings.experienceToDb(_experience!) != _profile?.experienceLevel;
    final equipmentChanged = _equipment.toSet().difference(_profile?.equipmentAvailable.toSet() ?? {}).isNotEmpty ||
        (_profile?.equipmentAvailable.toSet().difference(_equipment.toSet()) ?? {}).isNotEmpty;

    if (goalChanged || experienceChanged || equipmentChanged) {
      final regenerate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Regenerate Plan?'),
          content: const Text(
            'You\'ve changed your fitness goal, experience level, or equipment. Would you like to regenerate your workout plan based on these new settings?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Save Only'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save & Regenerate'),
            ),
          ],
        ),
      );

      if (regenerate == null) return;
      await _saveProfile(regeneratePlan: regenerate);
    } else {
      await _saveProfile(regeneratePlan: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _confirmSave,
              child: const Text('Save'),
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Basic Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid age' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: const InputDecoration(
                labelText: 'Sex',
                prefixIcon: Icon(Icons.wc),
              ),
              items: _sexOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _sex = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (lbs)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid weight' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: Icon(Icons.height),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid height' : null,
            ),
            const SizedBox(height: 32),
            Text('Fitness Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _experience,
              decoration: const InputDecoration(
                labelText: 'Experience Level',
                prefixIcon: Icon(Icons.bar_chart),
              ),
              items: _experienceOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _experience = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: const InputDecoration(
                labelText: 'Primary Goal',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _goalOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _goal = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text('Equipment Available', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _equipmentOptions.map((eq) {
                final selected = _equipment.contains(eq);
                return FilterChip(
                  label: Text(eq),
                  selected: selected,
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        if (!_equipment.contains(eq)) _equipment.add(eq);
                      } else {
                        _equipment.remove(eq);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _constraints,
              decoration: const InputDecoration(
                labelText: 'Constraints (optional)',
                hintText: 'e.g., knee injury, no jumping',
                prefixIcon: Icon(Icons.warning_amber_outlined),
              ),
              maxLines: 2,
              onChanged: (v) => _constraints = v,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}