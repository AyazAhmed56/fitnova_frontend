import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/diet/hair.dart';
import 'package:fitnova/diet_display/widgets/selection_card.dart';
import 'package:fitnova/diet_display/widgets/selection_chip.dart';
import 'package:flutter/material.dart';

class SkinScreen extends StatefulWidget {
  const SkinScreen({super.key});

  @override
  State<SkinScreen> createState() => _SkinScreenState();
}

class _SkinScreenState extends State<SkinScreen> {
  final OnboardingData data = OnboardingData.instance;

  String selectedSkinTone = "";

  final Set<String> selectedConcerns = {};

  late final String genderFolder;

  final List<String> concerns = [
    "Tanning",
    "Acne",
    "Pigmentation",
    "Dry Skin",
    "Oily Skin",
    "Dark Circles",
    "Dull Skin",
  ];

  @override
  void initState() {
    super.initState();

    selectedSkinTone = data.skinTone;
    selectedConcerns.addAll(data.skinConcerns);

    genderFolder = data.gender.toLowerCase() == "female" ? "female" : "male";
  }

  List<Map<String, String>> get skinTones => [
    {"title": "Fair", "image": "assets/skin/$genderFolder/fair.png"},
    {"title": "Wheatish", "image": "assets/skin/$genderFolder/wheatish.png"},
    {"title": "Medium", "image": "assets/skin/$genderFolder/medium.png"},
    {"title": "Dusky", "image": "assets/skin/$genderFolder/dusky.png"},
    {"title": "Dark", "image": "assets/skin/$genderFolder/dark.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Information Details"),
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

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: sw),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(sw * .05),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Skin Profile",
                            style: TextStyle(
                              fontSize: sw * .065,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HairScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: sw * 0.055,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: sh * .01),

                      Center(
                        child: Text(
                          "Select your skin tone and concerns",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: sw * .04,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * .035),

                      Text(
                        "Skin Tone",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sw * .05,
                        ),
                      ),

                      SizedBox(height: sh * .02),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: skinTones.length,

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,

                          crossAxisSpacing: sw * .04,

                          mainAxisSpacing: sw * .04,

                          childAspectRatio: .82,
                        ),

                        itemBuilder: (context, index) {
                          final tone = skinTones[index];

                          final bool selected =
                              selectedSkinTone == tone["title"];

                          return SelectionCard(
                            title: tone["title"]!,
                            image: tone["image"]!,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                selectedSkinTone = tone["title"]!;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: sh * .04),

                      Text(
                        "Skin Concerns",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sw * .05,
                        ),
                      ),

                      SizedBox(height: sh * .015),

                      Wrap(
                        spacing: sw * .025,
                        runSpacing: sh * .015,

                        children: concerns.map((concern) {
                          final bool selected = selectedConcerns.contains(
                            concern,
                          );

                          return SelectionChip(
                            title: concern,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  selectedConcerns.remove(concern);
                                } else {
                                  selectedConcerns.add(concern);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: sh * .05),

                      SizedBox(
                        width: double.infinity,
                        height: sh * .065,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff3A6F4B),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          onPressed: () {
                            if (selectedSkinTone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select your skin tone"),
                                ),
                              );

                              return;
                            }

                            data.skinTone = selectedSkinTone;

                            data.skinConcerns = selectedConcerns.toList();

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const HairScreen(),
                              ),
                            );
                          },

                          child: Text(
                            "Next",

                            style: TextStyle(
                              color: Colors.white,

                              fontSize: sw * .043,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: sh * .03),
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
