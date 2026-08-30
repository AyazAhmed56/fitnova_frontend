import 'package:fitnova/models/onboarding_data.dart';
import 'package:fitnova/planner_screens/workout/equipment.dart';
import 'package:flutter/material.dart';
import 'package:fitnova/models/selection_item.dart';
import 'package:fitnova/diet_display/widgets/selection_card.dart';
// import 'package:dietplan/planner_screens/review.dart';

class BodyTypeScreen extends StatefulWidget {
  const BodyTypeScreen({super.key});

  @override
  State<BodyTypeScreen> createState() => _BodyTypeScreenState();
}

class _BodyTypeScreenState extends State<BodyTypeScreen> {
  final data = OnboardingData.instance;

  String selectedBodyType = "";
  String selectedBodyGoal = "";
  String selectedFitnessLevel = "";

  late final String genderFolder;

  @override
  void initState() {
    super.initState();

    selectedBodyType = data.bodyType;
    selectedBodyGoal = data.bodyGoal;
    selectedFitnessLevel = data.fitnessLevel;

    genderFolder = data.gender.toLowerCase() == "female" ? "female" : "male";
  }

  //=============================
  // BODY TYPE
  //=============================

  List<SelectionItem> get bodyTypes => [
    SelectionItem(
      title: "Ectomorph",
      image: "assets/bodytype/$genderFolder/ectomorph.png",
    ),
    SelectionItem(
      title: "Mesomorph",
      image: "assets/bodytype/$genderFolder/mesomorph.png",
    ),
    SelectionItem(
      title: "Endomorph",
      image: "assets/bodytype/$genderFolder/endomorph.png",
    ),
    SelectionItem(
      title: "Not Sure",
      image: "assets/bodytype/$genderFolder/not sure.png",
    ),
  ];

  //=============================
  // BODY GOALS
  //=============================

  List<SelectionItem> get bodyGoals {
    if (genderFolder == "male") {
      return [
        SelectionItem(
          title: "Lean Bulk",
          image: "assets/bodygoal/male/lean_bulk.png",
        ),
        SelectionItem(
          title: "Clean Bulk",
          image: "assets/bodygoal/male/clean_bulk.png",
        ),
        SelectionItem(
          title: "Muscle Gain",
          image: "assets/bodygoal/male/muscle_gain.png",
        ),
        SelectionItem(
          title: "Fat Loss",
          image: "assets/bodygoal/male/fat_loss.png",
        ),
        SelectionItem(
          title: "Body Recomp",
          image: "assets/bodygoal/male/body_recomp.png",
        ),
        SelectionItem(
          title: "Cutting",
          image: "assets/bodygoal/male/cutting.png",
        ),
        SelectionItem(
          title: "Maintain",
          image: "assets/bodygoal/male/maintain.png",
        ),
        SelectionItem(
          title: "Aesthetic Physique",
          image: "assets/bodygoal/male/aesthetic_physique.png",
        ),
      ];
    }

    return [
      SelectionItem(
        title: "Hour Glass",
        image: "assets/bodygoal/female/hour_glass.png",
      ),
      SelectionItem(
        title: "Lean & Toned",
        image: "assets/bodygoal/female/lean_&_toned.png",
      ),
      SelectionItem(
        title: "Muscle Tone",
        image: "assets/bodygoal/female/muscle_tone.png",
      ),
      SelectionItem(
        title: "Slim Fit",
        image: "assets/bodygoal/female/slim_fit.png",
      ),
      SelectionItem(
        title: "Weight Loss",
        image: "assets/bodygoal/female/weight_loss.png",
      ),
      SelectionItem(
        title: "Maintain",
        image: "assets/bodygoal/female/maintain.png",
      ),
      SelectionItem(
        title: "Toned curves",
        image: "assets/bodygoal/female/toned_curves.png",
      ),
      SelectionItem(
        title: "Overall Wellness",
        image: "assets/bodygoal/female/overall_wellness.png",
      ),
    ];
  }

  final List<String> fitnessLevels = ["Beginner", "Intermediate", "Advanced"];

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Body Profile",
                            style: TextStyle(
                              fontSize: sw * .065,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (_) => const EquipmentPreferences(),
                          //       ),
                          //     );
                          //   },
                          //   child: Text(
                          //     'Skip',
                          //     style: TextStyle(
                          //       fontSize: sw * 0.055,
                          //       fontWeight: FontWeight.w300,
                          //       color: Colors.grey.shade700,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      SizedBox(height: sh * .01),

                      Center(
                        child: Text(
                          "Tell us about your body and fitness goals",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sw * .04,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * .035),

                      Text(
                        "Current Body Type",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sw * .05,
                        ),
                      ),

                      SizedBox(height: sh * .02),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bodyTypes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: sw * .04,
                          mainAxisSpacing: sw * .04,
                          childAspectRatio: .82,
                        ),
                        itemBuilder: (context, index) {
                          final body = bodyTypes[index];

                          return SelectionCard(
                            title: body.title,
                            image: body.image,
                            selected: selectedBodyType == body.title,
                            onTap: () {
                              setState(() {
                                selectedBodyType = body.title;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: sh * .05),

                      Text(
                        "Desired Body Goal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sw * .05,
                        ),
                      ),

                      SizedBox(height: sh * .02),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bodyGoals.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: sw * .04,
                          mainAxisSpacing: sw * .04,
                          childAspectRatio: .82,
                        ),
                        itemBuilder: (context, index) {
                          final goal = bodyGoals[index];

                          return SelectionCard(
                            title: goal.title,
                            image: goal.image,
                            selected: selectedBodyGoal == goal.title,
                            onTap: () {
                              setState(() {
                                selectedBodyGoal = goal.title;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: sh * .05),

                      Text(
                        "Fitness Experience",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: sw * .05,
                        ),
                      ),

                      SizedBox(height: sh * .02),
                      Column(
                        children: fitnessLevels.map((level) {
                          final bool selected = selectedFitnessLevel == level;

                          return Padding(
                            padding: EdgeInsets.only(bottom: sh * .015),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                setState(() {
                                  selectedFitnessLevel = level;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: EdgeInsets.symmetric(
                                  horizontal: sw * .04,
                                  vertical: sh * .02,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.green.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xff3A6F4B)
                                        : Colors.grey.shade300,
                                    width: selected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: selected
                                          ? const Color(0xff3A6F4B)
                                          : Colors.grey,
                                    ),
                                    SizedBox(width: sw * .03),
                                    Expanded(
                                      child: Text(
                                        level,
                                        style: TextStyle(
                                          fontSize: sw * .043,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                            if (selectedBodyType.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select your body type.",
                                  ),
                                ),
                              );
                              return;
                            }

                            if (selectedBodyGoal.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select your body goal.",
                                  ),
                                ),
                              );
                              return;
                            }

                            if (selectedFitnessLevel.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please select your fitness experience.",
                                  ),
                                ),
                              );
                              return;
                            }

                            data.bodyType = selectedBodyType;
                            data.bodyGoal = selectedBodyGoal;
                            data.fitnessLevel = selectedFitnessLevel;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EquipmentPreferences(),
                              ),
                            );
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * .045,
                              fontWeight: FontWeight.bold,
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
