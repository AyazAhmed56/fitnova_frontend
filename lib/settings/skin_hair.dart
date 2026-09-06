import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';

class SkinHairScreen extends StatefulWidget {
  const SkinHairScreen({super.key});

  @override
  State<SkinHairScreen> createState() => _SkinHairScreenState();
}

class _SkinHairScreenState extends State<SkinHairScreen> {
  final SupabaseService _service = SupabaseService();

  UserProfileModel? profile;

  bool isLoading = true;
  bool isSaving = false;

  String skinTone = "";
  String hairType = "";
  String scalpType = "";

  List<String> skinConcerns = [];
  List<String> hairConcerns = [];

  final Color primary = const Color(0xFF3A6F4B);
  final Color lightGreen = const Color(0xFFEAF4ED);

  final List<String> skinTones = [
    "Very Fair",
    "Fair",
    "Light",
    "Medium",
    "Tan",
    "Deep",
    "Dark",
  ];

  final List<String> skinConcernOptions = [
    "Acne",
    "Pimples",
    "Dark Spots",
    "Pigmentation",
    "Dry Skin",
    "Oily Skin",
    "Sensitive Skin",
    "Uneven Skin Tone",
    "Dull Skin",
    "Fine Lines",
  ];

  final List<String> hairTypes = ["Straight", "Wavy", "Curly", "Coily"];

  final List<String> hairConcernOptions = [
    "Hair Fall",
    "Dandruff",
    "Dry Hair",
    "Oily Hair",
    "Frizzy Hair",
    "Split Ends",
    "Thin Hair",
    "Slow Growth",
    "Damaged Hair",
  ];

  final List<String> scalpTypes = [
    "Normal",
    "Dry",
    "Oily",
    "Sensitive",
    "Dandruff Prone",
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final result = await _service.getUserProfile(user.id);

      if (result != null) {
        profile = result;

        skinTone = result.skinTone;
        skinConcerns = List<String>.from(result.skinConcerns);

        hairType = result.hairType;
        hairConcerns = List<String>.from(result.hairConcerns);

        scalpType = result.scalpType;
      }
    } catch (e) {
      _showMessage("Failed to load skin & hair information: $e", Colors.red);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveSkinHair() async {
    if (profile == null) return;

    setState(() => isSaving = true);

    try {
      await _service.updateProfileFields(profile!.uid, {
        'skin_tone': skinTone,
        'skin_concerns': skinConcerns.join(', '),
        'hair_type': hairType,
        'hair_concerns': hairConcerns.join(', '),
        'scalp_type': scalpType,
      });

      if (!mounted) return;
      _showMessage(
        'Skin & hair information updated successfully.',
        Colors.green,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to update skin & hair information: $e', Colors.red);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _multiSelect(
    String title,
    List<String> options,
    List<String> selected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) {
            final isSelected = selected.contains(item);

            return FilterChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: const Color(0xFFCFE8D7),
              checkmarkColor: primary,

              onSelected: (value) {
                setState(() {
                  if (value) {
                    if (!selected.contains(item)) {
                      selected.add(item);
                    }
                  } else {
                    selected.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 22),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    if (profile == null) {
      return const Scaffold(body: Center(child: Text("Profile not found")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),

      appBar: AppBar(
        title: const Text(
          "Skin & Hair",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F8F5),
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: primary,
                      child: const Icon(
                        Icons.spa_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Skin & Hair Profile",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Help FitNova personalize your skin and hair recommendations.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // SKIN
              const Text(
                "Skin",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _dropdown(
                label: "Skin Tone",
                value: skinTone,
                items: skinTones,
                icon: Icons.palette_outlined,
                onChanged: (value) {
                  setState(() {
                    skinTone = value ?? "";
                  });
                },
              ),

              _multiSelect("Skin Concerns", skinConcernOptions, skinConcerns),

              const Divider(height: 30),

              // HAIR
              const Text(
                "Hair",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _dropdown(
                label: "Hair Type",
                value: hairType,
                items: hairTypes,
                icon: Icons.face_retouching_natural,
                onChanged: (value) {
                  setState(() {
                    hairType = value ?? "";
                  });
                },
              ),

              _dropdown(
                label: "Scalp Type",
                value: scalpType,
                items: scalpTypes,
                icon: Icons.water_drop_outlined,
                onChanged: (value) {
                  setState(() {
                    scalpType = value ?? "";
                  });
                },
              ),

              _multiSelect("Hair Concerns", hairConcernOptions, hairConcerns),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: primary),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "These details can be used by FitNova later for personalized skin, scalp and hair recommendations.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveSkinHair,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
