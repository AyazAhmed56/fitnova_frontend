import 'package:fitnova/planner_screens/goal.dart';
import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';

class Infoscreen extends StatefulWidget {
  const Infoscreen({super.key});

  @override
  State<Infoscreen> createState() => _InfoscreenState();
}

class _InfoscreenState extends State<Infoscreen> {
  String? selectedGender;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(sw * 0.05),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      SizedBox(height: sh * 0.01),

                      Center(
                        child: Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: sw * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.04),

                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Full Name',

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),

                          contentPadding: EdgeInsets.symmetric(
                            horizontal: sw * 0.04,
                            vertical: sh * 0.018,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Age',
                                  style: TextStyle(
                                    fontSize: sw * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                SizedBox(height: sh * 0.01),

                                TextFormField(
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your age";
                                    }
                                    final age = int.tryParse(value);
                                    if (age == null) {
                                      return "Enter the valid age";
                                    }
                                    if (age < 5 || age > 100) {
                                      return "Age should be between 5 to 100";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Age',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.03,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: sw * 0.04),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontSize: sw * 0.04,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                SizedBox(height: sh * 0.01),

                                DropdownButtonFormField<String>(
                                  value: selectedGender,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.03,
                                      ),
                                    ),
                                  ),

                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Male',
                                      child: Text('Male'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Female',
                                      child: Text('Female'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Other',
                                      child: Text('Other'),
                                    ),
                                  ],

                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return "Please select your gender";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: sh * 0.03),

                      Text(
                        'Height (in cm)',
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      TextFormField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please mention your height";
                          }
                          final height = double.tryParse(value);
                          if (height == null || height < 0 || height > 300) {
                            return "Height is not valid";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Height',
                          suffixText: 'cm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      Text(
                        'Weight (in kg)',
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      TextFormField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Plese mention your weight";
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight < 0 || weight > 300) {
                            return "Weight is not valid";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Weight',
                          suffixText: 'kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      Text(
                        'Phone No.',
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Plese enter you phone no.";
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return "Phone no. should contin only digits";
                          }
                          if (value.length != 10) {
                            return "Phone no. must be of 10 digits";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Phone No',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.05),

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
                            final data = OnboardingData.instance;
                            data.fullName = nameController.text;
                            data.age = int.tryParse(ageController.text) ?? 0;
                            data.gender = selectedGender ?? '';
                            data.height =
                                double.tryParse(heightController.text) ?? 0;
                            data.weight =
                                double.tryParse(weightController.text) ?? 0;
                            data.phone =
                                int.tryParse(phoneController.text) ?? 0;

                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Goalscreen(),
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
