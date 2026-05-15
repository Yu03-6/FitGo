import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;

  // Dropdown selections
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedDiet;
  bool _isSaving = false;
  late TextEditingController _dislikedIngredientsController;

  // Gender options
  final List<String> genderOptions = ['male', 'female'];

  // Goal options
  final List<String> goalOptions = ['build_muscle', 'lose_weight', 'keep_fit'];
  final Map<String, String> goalLabels = {
    'build_muscle': 'Build Muscle',
    'lose_weight': 'Lose Weight',
    'keep_fit': 'Keep Fit',
  };

  // Diet preference options
  final List<String> dietOptions = ['standard', 'keto', 'vegan'];
  final Map<String, String> dietLabels = {
    'standard': 'Standard',
    'keto': 'Keto',
    'vegan': 'Vegan',
  };

  // Activity level (0-7 scale)
  late int _activityLevel;
  bool _isInitialized = false;

  /// Convert activity level (0-7) to backend format (1.2-1.9)
  double _activityLevelToBackend(int level) {
    return 1.2 + (level / 7) * 0.7;
  }

  /// Convert backend format (1.2-1.9) to activity level (0-7)
  int _activityLevelFromBackend(double value) {
    return ((value - 1.2) / 0.7 * 7).round();
  }

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _ageController = TextEditingController();
    _dislikedIngredientsController = TextEditingController();
    _activityLevel = 4;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load existing profile data if available (only once)
    if (!_isInitialized) {
      _isInitialized = true;
      final userProfile = ref.read(userProfileProvider);

      if (userProfile != null) {
        _heightController.text = userProfile.height.toString();
        _weightController.text = userProfile.weight.toString();
        _ageController.text = userProfile.age.toString();
        _selectedGender = userProfile.gender;
        _selectedGoal = userProfile.goal;
        _selectedDiet = userProfile.dietPreference == 'vegetarian'
            ? 'vegan'
            : userProfile.dietPreference;
        _activityLevel = _activityLevelFromBackend(userProfile.activityLevel);
        if (userProfile.dislikedIngredients != null) {
          _dislikedIngredientsController.text =
              userProfile.dislikedIngredients!;
        }
      }
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _dislikedIngredientsController.dispose();
    super.dispose();
  }

  String _getGenderLabel(String gender) {
    return gender == 'male' ? 'Male' : 'Female';
  }

  /// Get description for activity level
  String _getActivityLevelDescription(int level) {
    if (level <= 1) {
      return '0-1: Sedentary - Little to no regular exercise';
    } else if (level <= 3) {
      return '2-3: Light - 2-4 days per week light exercise';
    } else if (level <= 5) {
      return '4-5: Moderate - 4-5 days per week regular exercise';
    } else {
      return '6-7: Very Active - Nearly daily or intense exercise';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null ||
        _selectedGoal == null ||
        _selectedDiet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });
      final nutrition =
          await ref.read(userProfileProvider.notifier).updateProfile(
                height: int.parse(_heightController.text),
                weight: double.parse(_weightController.text),
                age: int.parse(_ageController.text),
                gender: _selectedGender!,
                activityLevel: _activityLevelToBackend(_activityLevel),
                goal: _selectedGoal!,
                dietPreference: _selectedDiet!,
                dislikedIngredients: _dislikedIngredientsController.text.isEmpty
                    ? null
                    : _dislikedIngredientsController.text,
              );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile saved successfully!'
              '\nDaily Calorie Goal: ${nutrition.dailyCalories} kcal'
              '\nProtein: ${nutrition.proteinGrams}g | '
              'Carbs: ${nutrition.carbGrams}g | '
              'Fat: ${nutrition.fatGrams}g',
            ),
          ),
        );

        // Don't navigate - let AuthWrapper handle the state change
        // It will detect the profile exists and show welcome dialog or home page
        print(
            'OnboardingPage: Profile saved, waiting for AuthWrapper to update');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information Setup'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Let\'s Understand Your Body Data',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This will help us create a more accurate nutrition plan for you',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Height Input
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: const Icon(Icons.height),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height';
                  }
                  final height = int.tryParse(value);
                  if (height == null || height < 100 || height > 250) {
                    return 'Height should be between 100-250 cm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight Input
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: const Icon(Icons.scale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 200) {
                    return 'Weight should be between 30-200 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age Input
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age (years)',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 10 || age > 120) {
                    return 'Age should be between 1-120 years';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(_getGenderLabel(gender)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Activity Level Slider
              Text(
                'Activity Level: $_activityLevel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _activityLevel.toDouble(),
                min: 0,
                max: 7,
                divisions: 7,
                label: '$_activityLevel',
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value.toInt();
                  });
                },
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sedentary (0)', style: TextStyle(fontSize: 12)),
                  Text('Very Active (7)', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  _getActivityLevelDescription(_activityLevel),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fitness Goal Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGoal,
                decoration: InputDecoration(
                  labelText: 'Fitness Goal',
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: goalOptions.map((goal) {
                  return DropdownMenuItem(
                    value: goal,
                    child: Text(goalLabels[goal] ?? goal),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select fitness goal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Diet Preference Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDiet,
                decoration: InputDecoration(
                  labelText: 'Diet Preference',
                  prefixIcon: const Icon(Icons.restaurant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: dietOptions.map((diet) {
                  return DropdownMenuItem(
                    value: diet,
                    child: Text(dietLabels[diet] ?? diet),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiet = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select diet preference';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Disliked Ingredients Input
              TextFormField(
                controller: _dislikedIngredientsController,
                decoration: InputDecoration(
                  labelText:
                      'Disliked Ingredients (Optional, separate with commas)',
                  prefixIcon: const Icon(Icons.block),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save and Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
