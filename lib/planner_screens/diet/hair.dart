import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/models/selection_item.dart';
import 'package:fitnova/diet_display/widgets/selection_card.dart';
import 'package:fitnova/diet_display/widgets/selection_chip.dart';
import 'package:fitnova/planner_screens/review.dart';
import 'package:flutter/material.dart';

class HairScreen extends StatefulWidget {
  const HairScreen({super.key});

  @override
  State<HairScreen> createState() => _HairScreenState();
}

class _HairScreenState extends State<HairScreen> {
  final data = OnboardingData.instance;

  String selectedHairType = "";

  String selectedScalpType = "";

  Set<String> selectedConcerns = {};

  late final String genderFolder;

  @override
  void initState() {
    super.initState();

    selectedHairType = data.hairType;

    selectedScalpType = data.scalpType;

    selectedConcerns = data.hairConcerns.toSet();

    genderFolder = data.gender.toLowerCase() == "female" ? "female" : "male";
  }

  List<SelectionItem> get hairTypes => [
    SelectionItem(
      title: "Straight",
      image: "assets/hair/$genderFolder/straight.png",
    ),
    SelectionItem(title: "Wavy", image: "assets/hair/$genderFolder/wavy.png"),
    SelectionItem(title: "Curly", image: "assets/hair/$genderFolder/curly.png"),
    SelectionItem(title: "Coily", image: "assets/hair/$genderFolder/coily.png"),
  ];

  final List<SelectionItem> scalpTypes = [
    SelectionItem(title: "Normal", image: "assets/hair/scalp/normal.png"),
    SelectionItem(title: "Dry", image: "assets/hair/scalp/dry.png"),
    SelectionItem(title: "Oily", image: "assets/hair/scalp/oily.png"),
    SelectionItem(title: "Sensitive", image: "assets/hair/scalp/sensitive.png"),
  ];

  final List<String> concerns = [
    "Hair Fall",
    "Slow Growth",
    "Dandruff",
    "Split Ends",
    "Breakage",
    "Itchy Scalp",
    "Thin Hair",
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
                            "Hair & Scalp Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: sw * .065,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReviewInfo(),
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
                          "Tell us about your hair",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: sw * .04,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * .035),

                      Text(
                        "Hair Type",
                        style: TextStyle(
                          fontSize: sw * .05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: sh * .02),

                      GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: hairTypes.length,

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: sw * .04,
                          mainAxisSpacing: sw * .04,
                          childAspectRatio: .82,
                        ),

                        itemBuilder: (context, index) {
                          final hair = hairTypes[index];

                          return SelectionCard(
                            title: hair.title,
                            image: hair.image,

                            selected: selectedHairType == hair.title,

                            onTap: () {
                              setState(() {
                                selectedHairType = hair.title;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: sh * .04),

                      Text(
                        "Scalp Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sw * .05,
                        ),
                      ),

                      SizedBox(height: sh * .02),

                      GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: scalpTypes.length,

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: sw * .04,
                          mainAxisSpacing: sw * .04,
                          childAspectRatio: .82,
                        ),

                        itemBuilder: (context, index) {
                          final scalp = scalpTypes[index];

                          return SelectionCard(
                            title: scalp.title,

                            image: scalp.image,

                            selected: selectedScalpType == scalp.title,

                            onTap: () {
                              setState(() {
                                selectedScalpType = scalp.title;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: sh * .04),

                      Text(
                        "Hair Concerns",
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
                            backgroundColor: const Color(0xFF3A6F4B),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          onPressed: () {
                            if (selectedHairType.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select your hair type.",
                                  ),
                                ),
                              );

                              return;
                            }

                            if (selectedScalpType.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select your scalp type.",
                                  ),
                                ),
                              );

                              return;
                            }

                            data.hairType = selectedHairType;

                            data.scalpType = selectedScalpType;

                            data.hairConcerns = selectedConcerns.toList();

                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => const ReviewInfo(),
                              ),
                            );
                          },

                          child: Text(
                            "Next",

                            style: TextStyle(
                              color: Colors.white,

                              fontWeight: FontWeight.w600,

                              fontSize: sw * .043,
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
