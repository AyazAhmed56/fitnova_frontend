import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/skin.dart';
import 'package:fitnova/planner_screens/workout/splitprefer.dart';
import 'package:flutter/material.dart';
// import 'package:hugeicons/hugeicons.dart';

class EquipmentPreferences extends StatefulWidget {
  const EquipmentPreferences({super.key});

  @override
  State<EquipmentPreferences> createState() => _EquipmentPreferencesState();
}

class _EquipmentPreferencesState extends State<EquipmentPreferences> {
  Set<String> selectedPreferences = {};

  final List<Map<String, dynamic>> preferences = [
    {'title': 'Dumbbells', 'icon': Icons.fitness_center},
    {'title': 'Barbell', 'icon': Icons.sports_gymnastics},
    {'title': 'Resistance band', 'icon': Icons.sports},
    {'title': 'Kettlebell', 'icon': Icons.fitness_center},
    {'title': 'Pull-up bar', 'icon': Icons.horizontal_rule},
    {'title': 'Bench', 'icon': Icons.event_seat},
    {'title': 'Yoga Mat', 'icon': Icons.self_improvement},
    {'title': 'None', 'icon': Icons.block},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information Details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final sh = constraints.maxHeight;
            // Cap content width on tablet/web so it doesn't stretch full width,
            // and use that capped width as the basis for proportional sizing.
            final sw = screenW > 600 ? 600.0 : screenW;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sw),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(sw * 0.0533),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Equipment Used',
                          style: TextStyle(
                            fontSize: sw * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.0123),
                      Text(
                        'Where do you prefer to workout?',
                        style: TextStyle(
                          fontSize: sw * 0.053,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: sh * 0.0123),
                      Text(
                        'You can select more than one',
                        style: TextStyle(
                          fontSize: sw * 0.037,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: sh * 0.0123),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: sw * 0.0267,
                          mainAxisSpacing: sh * 0.0123,
                          childAspectRatio: 2.3,
                        ),

                        itemCount: preferences.length,

                        itemBuilder: (context, index) {
                          final item = preferences[index];
                          final isSelected = selectedPreferences.contains(
                            item['title'],
                          );

                          return InkWell(
                            borderRadius: BorderRadius.circular(sw * 0.0347),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedPreferences.remove(item['title']);
                                } else {
                                  selectedPreferences.add(item['title']);
                                }
                              });
                            },

                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.032,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(
                                  sw * 0.0347,
                                ),

                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF3A6F4B)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),

                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    size: sw * 0.1067,
                                    color: Colors.green,
                                  ),

                                  SizedBox(width: sw * 0.0267),

                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontSize: sw * 0.0427,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      size: sw * 0.1067,
                                      color: const Color(0xFF3A6F4B),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: sh * 0.0369),
                      SizedBox(
                        width: double.infinity,
                        height: sh * 0.0493,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A6F4B),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.0347),
                            ),
                          ),

                          onPressed: () {
                            if (selectedPreferences.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pleae select your preference'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final data = OnboardingData.instance;
                            data.equipmentPrefer = selectedPreferences
                                .toString();
                            if (data.fitnessLevel == 'Beginner') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SkinScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SplitPreference(),
                                ),
                              );
                            }
                          },

                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.0533,
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
