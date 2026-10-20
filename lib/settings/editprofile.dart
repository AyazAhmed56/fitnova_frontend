import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final phoneController = TextEditingController();
  final medicalController = TextEditingController();

  static const List<String> indianStatesAndUTs = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi (National Capital Territory)',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  String? gender;
  String? currentState;
  String? nativeState;

  bool isLoading = true;
  bool isSaving = false;
  UserProfileModel? profile;

  final Color primary = const Color(0xFF3A6F4B);
  final Color background = const Color(0xFFF5F8F6);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final data = await SupabaseService().getUserProfile(user.id);
      if (data != null) {
        profile = data;
        fullNameController.text = data.fullName;
        ageController.text = data.age.toString();
        heightController.text = data.height.toString();
        weightController.text = data.weight.toString();
        phoneController.text = data.phone == 0 ? '' : data.phone.toString();
        medicalController.text = data.medical;
        gender = data.gender.isNotEmpty ? data.gender : null;
        currentState = indianStatesAndUTs.contains(data.state)
            ? data.state
            : null;
        nativeState = indianStatesAndUTs.contains(data.nativeState)
            ? data.nativeState
            : null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to load profile: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final currentProfile = profile;
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile not found. Please try again.')),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      await SupabaseService().updateProfileFields(currentProfile.uid, {
        'full_name': fullNameController.text.trim(),
        'age': int.parse(ageController.text.trim()),
        'gender': gender,
        'height': double.parse(heightController.text.trim()),
        'weight': double.parse(weightController.text.trim()),
        'phone': int.parse(phoneController.text.trim()),
        'state': currentState,
        'native_state': nativeState,
        'medical': medicalController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Please enter $label';
    return null;
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? suffixText,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffixText,
          alignLabelWithHint: maxLines > 1,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _infoRow(String title, dynamic value) {
    final text = value == null || value.toString().trim().isEmpty
        ? 'Not set'
        : value.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: background,
          elevation: 0,
        ),
        body: const Center(child: Text('Profile not found')),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: background,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 600
                ? 600.0
                : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: width,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                    child: Column(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              fullNameController.text.trim().isNotEmpty
                                  ? fullNameController.text
                                        .trim()[0]
                                        .toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your basic profile information',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _sectionTitle('BASIC INFORMATION'),
                        _textField(
                          controller: fullNameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (v) => _required(v, 'your full name'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _textField(
                                controller: ageController,
                                label: 'Age',
                                icon: Icons.cake_outlined,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final age = int.tryParse(value?.trim() ?? '');
                                  if (age == null || age < 5 || age > 100) {
                                    return 'Enter age (5–100)';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _dropdown<String>(
                                label: 'Gender',
                                icon: Icons.wc_outlined,
                                value: gender,
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
                                onChanged: (value) =>
                                    setState(() => gender = value),
                                validator: (value) =>
                                    value == null ? 'Select gender' : null,
                              ),
                            ),
                          ],
                        ),
                        _textField(
                          controller: heightController,
                          label: 'Height',
                          icon: Icons.height,
                          suffixText: 'cm',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final height = double.tryParse(value?.trim() ?? '');
                            if (height == null || height <= 0 || height > 300) {
                              return 'Enter valid height';
                            }
                            return null;
                          },
                        ),
                        _textField(
                          controller: weightController,
                          label: 'Weight',
                          icon: Icons.monitor_weight_outlined,
                          suffixText: 'kg',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final weight = double.tryParse(value?.trim() ?? '');
                            if (weight == null || weight <= 0 || weight > 300) {
                              return 'Enter valid weight';
                            }
                            return null;
                          },
                        ),
                        _textField(
                          controller: phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            final phone = value?.trim() ?? '';
                            if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),

                        _sectionTitle('LOCATION INFORMATION'),
                        _dropdown<String>(
                          label: 'Current State / UT',
                          icon: Icons.location_on_outlined,
                          value: currentState,
                          items: indianStatesAndUTs
                              .map(
                                (state) => DropdownMenuItem(
                                  value: state,
                                  child: Text(
                                    state,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => currentState = value),
                          validator: (value) => value == null
                              ? 'Select your current state'
                              : null,
                        ),
                        _dropdown<String>(
                          label: 'Native State / UT',
                          icon: Icons.home_outlined,
                          value: nativeState,
                          items: indianStatesAndUTs
                              .map(
                                (state) => DropdownMenuItem(
                                  value: state,
                                  child: Text(
                                    state,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => nativeState = value),
                          validator: (value) =>
                              value == null ? 'Select your native state' : null,
                        ),

                        _sectionTitle('MEDICAL INFORMATION'),
                        _textField(
                          controller: medicalController,
                          label: 'Medical Records / History',
                          icon: Icons.medical_information_outlined,
                          maxLines: 3,
                          validator: (value) => _required(
                            value,
                            'your medical history (enter NA if none)',
                          ),
                        ),

                        _sectionTitle('CURRENT FITNESS INFORMATION'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF4ED),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              _infoRow('Current Goal', profile!.goal),
                              _infoRow('Target Weight', profile!.targetWeight),
                              _infoRow(
                                'Activity Level',
                                profile!.activityLevel,
                              ),
                              _infoRow('Workout Days', profile!.workoutDays),
                              _infoRow('Wake Up', profile!.wakeUp),
                              _infoRow('Workout Time', profile!.workoutTime),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_outlined),
                                      SizedBox(width: 8),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    phoneController.dispose();
    medicalController.dispose();
    super.dispose();
  }
}
