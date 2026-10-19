import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/workout/splitprefer.dart';
import 'package:flutter/material.dart';

class EquipmentPreferences extends StatefulWidget {
  const EquipmentPreferences({super.key});

  @override
  State<EquipmentPreferences> createState() => _EquipmentPreferencesState();
}

class _EquipmentPreferencesState extends State<EquipmentPreferences> {
  static const Color primaryColor = Color(0xFF3A6F4B);

  final Set<String> selectedPreferences = {};

  final List<Map<String, dynamic>> preferences = [
    {
      'title': 'Gym Equipment',
      'description': 'Full gym with machines and weights',
      'icon': Icons.fitness_center,
    },
    {
      'title': 'Basic Equipment',
      'description': 'Dumbbells, bands, or a bench',
      'icon': Icons.sports_gymnastics,
    },
    {
      'title': 'Home Workout',
      'description': 'Exercise at home with available space',
      'icon': Icons.home_outlined,
    },
    {
      'title': 'Bodyweight Only',
      'description': 'Use your body weight for resistance',
      'icon': Icons.accessibility_new,
    },
    {
      'title': 'No Equipment',
      'description': 'No equipment available',
      'icon': Icons.block,
    },
  ];

  void togglePreference(String title) {
    setState(() {
      if (title == 'No Equipment') {
        if (selectedPreferences.contains(title)) {
          selectedPreferences.remove(title);
        } else {
          selectedPreferences
            ..clear()
            ..add(title);
        }
        return;
      }

      selectedPreferences.remove('No Equipment');

      if (selectedPreferences.contains(title)) {
        selectedPreferences.remove(title);
      } else {
        selectedPreferences.add(title);
      }
    });
  }

  void continueToNext() {
    if (selectedPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your workout setup.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // The existing Supabase field is text, so store
    // the selected categories as a comma-separated string.
    OnboardingData.instance.equipmentPrefer = selectedPreferences.join(', ');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SplitPreference()),
    );
  }

  @override
  void initState() {
    super.initState();

    final saved = OnboardingData.instance.equipmentPrefer;
    if (saved.isNotEmpty) {
      selectedPreferences.addAll(
        saved
            .split(', ')
            .where(
              (value) => preferences.any((item) => item['title'] == value),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Preferences'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sw = constraints.maxWidth > 600
                ? 600.0
                : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sw),
                child: Padding(
                  padding: EdgeInsets.all(sw * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What equipment can you use?',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select one or more options. Choose '
                        'No Equipment if you have none available.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: preferences.length,
                          itemBuilder: (context, index) {
                            final item = preferences[index];
                            final title = item['title'] as String;
                            final isSelected = selectedPreferences.contains(
                              title,
                            );

                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => togglePreference(title),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE8F3E9)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey.shade300,
                                    width: 1.4,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item['icon'] as IconData,
                                      size: 32,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['description'] as String,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: continueToNext,
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
