import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/lifestyle.dart';
import 'package:flutter/material.dart';

class DietPreference extends StatefulWidget {
  const DietPreference({super.key});

  @override
  State<DietPreference> createState() => _DietPreferenceState();
}

class _DietPreferenceState extends State<DietPreference> {
  Set<String> selectedPreferences = {};
  final allergyController = TextEditingController();
  final commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> preferences = [
    {'title': 'Vegetarian', 'icon': Icons.eco},
    {'title': 'Vegan', 'icon': Icons.spa},
    {'title': 'Eggetarian', 'icon': Icons.egg},
    {'title': 'Non-Vegetarian', 'icon': Icons.restaurant},
    {'title': 'Jain', 'icon': Icons.self_improvement},
    {'title': 'Gluten Free', 'icon': Icons.grain},
    {'title': 'Dairy Free', 'icon': Icons.no_drinks},
    {'title': 'Low Carbs', 'icon': Icons.monitor_weight},
    {'title': 'Low Fat', 'icon': Icons.favorite_border},
    {'title': 'No Preference', 'icon': Icons.check_circle_outline},
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
            final sw = constraints.maxWidth;
            final sh = constraints.maxHeight;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(sw * 0.05),

                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Dietary Preferences',
                          style: TextStyle(
                            fontSize: sw * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      Center(
                        child: Text(
                          'Select all that apply',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: sw * 0.03,
                          mainAxisSpacing: sw * 0.03,
                          childAspectRatio: 2.3,
                        ),

                        itemCount: preferences.length,

                        itemBuilder: (context, index) {
                          final item = preferences[index];
                          final isSelected = selectedPreferences.contains(
                            item['title'],
                          );

                          return InkWell(
                            borderRadius: BorderRadius.circular(sw * 0.03),
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
                                horizontal: sw * 0.025,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(sw * 0.03),

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
                                    size: sw * 0.05,
                                    color: Colors.green.shade600,
                                  ),

                                  SizedBox(width: sw * 0.015),

                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontSize: sw * 0.03,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      size: sw * 0.045,
                                      color: const Color(0xFF3A6F4B),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: sh * 0.04),

                      Text(
                        'Any food allergies?',
                        style: TextStyle(
                          fontSize: sw * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: sh * 0.015),

                      TextFormField(
                        controller: allergyController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please mention NA if no allergy exists";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g. Nuts, Gluten, Dairy',

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),

                          contentPadding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04,
                            vertical: sh * 0.018,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.04),

                      Text(
                        'Any Comments?',
                        style: TextStyle(
                          fontSize: sw * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: sh * 0.015),

                      TextFormField(
                        controller: commentController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please mention NA if no comments needed";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Don\'t add costly foods',

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),

                          contentPadding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04,
                            vertical: sh * 0.018,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.04),

                      SizedBox(
                        width: double.infinity,
                        height: sh * 0.06,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A6F4B),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(sw * 0.03),
                            ),
                          ),

                          onPressed: () {
                            if (selectedPreferences.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please select any one diet preferences",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final data = OnboardingData.instance;
                            data.dietaryPreferences = selectedPreferences
                                .toList();
                            data.allergies = allergyController.text;
                            data.comments = commentController.text;
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LifeStyleAndHabits(),
                                ),
                              );
                            }
                          },

                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.04,
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
