import 'dart:ui';
import 'package:fitnova/ai_coach/ai_coach_screen.dart';
import 'package:fitnova/diet_display/display_screen/dailymeal.dart';
import 'package:fitnova/diet_display/display_screen/haircare_screen.dart';
import 'package:fitnova/diet_display/display_screen/shoppinglist.dart';
import 'package:fitnova/diet_display/display_screen/skincare_screen.dart';
import 'package:fitnova/models/user_profile_model.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DietHome extends StatefulWidget {
  const DietHome({super.key});

  @override
  State<DietHome> createState() => _DietHomeState();
}

class _DietHomeState extends State<DietHome> {
  bool generateMealPlan = false;

  Future<UserProfileModel?> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return SupabaseService().getUserProfile(user.id);
  }

  Future<Map<String, dynamic>?> _loadMealPlan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return SupabaseService().getMealPlan(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/diet_background.png"),
          fit: BoxFit.cover,
        ),
      ),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),

        child: Scaffold(
          backgroundColor: Colors.transparent,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,

            title: const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xff14361E),
              ),
            ),
          ),

          body: LayoutBuilder(
            builder: (context, constraints) {
              final sw = constraints.maxWidth;
              final sh = constraints.maxHeight;

              return FutureBuilder<UserProfileModel?>(
                future: _loadProfile(),

                builder: (context, profileSnapshot) {
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!profileSnapshot.hasData) {
                    return const Center(child: Text("Profile not found"));
                  }

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _loadMealPlan(),

                    builder: (context, mealSnapshot) {
                      if (mealSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (generateMealPlan) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!mealSnapshot.hasData || mealSnapshot.data == null) {
                        return const Center(
                          child: Text("No Meal Plan Generated Yet"),
                        );
                      }

                      final mealPlan = mealSnapshot.data!;

                      final supabase = SupabaseService();

                      final bool planExpired = supabase.isPlanExpired(mealPlan);

                      final String remainingTime = supabase.formatRemainingTime(
                        supabase.getRemainingTime(mealPlan),
                      );

                      final double progress = supabase.getPlanProgress(
                        mealPlan,
                      );

                      // if (planExpired) {
                      //   return const Center(child: Text("Meal Plan Expired"));
                      // }

                      if (planExpired) {
                        return SafeArea(
                          child: Padding(
                            padding: EdgeInsets.all(sw * .06),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fitness_center_rounded,
                                    size: sw * .22,
                                    color: Colors.orange,
                                  ),

                                  SizedBox(height: sh * .03),

                                  Text(
                                    "Meal Plan Expired",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: sw * .065,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: sh * .018),

                                  Text(
                                    "Your meal plan has completed its 2-day diet cycle.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: sw * .042,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  SizedBox(height: sh * .012),

                                  Text(
                                    "Generate a fresh meal plan based on your latest fitness progress to continue improving safely and effectively.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: sw * .038,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  SizedBox(height: sh * .05),

                                  SizedBox(
                                    width: double.infinity,
                                    height: sh * .065,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh),
                                      label: const Text("Generate New Meal"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF3A6F4B,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: generateMealPlan
                                          ? null
                                          : () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          "Generate New Plan",
                                                        ),

                                                        content: const Text(
                                                          "This will replace your current meal plan. Continue?",
                                                        ),

                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              );
                                                            },

                                                            child: const Text(
                                                              "Cancel",
                                                            ),
                                                          ),

                                                          ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              );
                                                            },

                                                            child: const Text(
                                                              "Generate",
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                              if (confirm != true) return;

                                              final messenger =
                                                  ScaffoldMessenger.of(context);

                                              try {
                                                setState(() {
                                                  generateMealPlan = true;
                                                });

                                                final user = Supabase
                                                    .instance
                                                    .client
                                                    .auth
                                                    .currentUser;

                                                if (user == null) return null;

                                                await SupabaseService()
                                                    .generateAndSaveMealPlan(
                                                      user.id,
                                                    );

                                                if (mounted) {
                                                  setState(() {});
                                                }

                                                if (!mounted) return;

                                                messenger.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "New meal plan generated successfully",
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                if (!mounted) return;

                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(e.toString()),
                                                  ),
                                                );
                                              } finally {
                                                if (mounted) {
                                                  setState(() {
                                                    generateMealPlan = false;
                                                  });
                                                }
                                              }
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final days = Map<String, dynamic>.from(
                        mealPlan["days"] ?? {},
                      );

                      final day = Map<String, dynamic>.from(days["Day1"] ?? {});

                      final dailyTarget = Map<String, dynamic>.from(
                        day["dailyTarget"] ?? {},
                      );

                      return SafeArea(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),

                          padding: EdgeInsets.symmetric(
                            horizontal: sw * .05,
                            vertical: 10,
                          ),

                          child: Column(
                            children: [
                              SizedBox(height: sh * .025),

                              GlassCard(
                                padding: const EdgeInsets.all(22),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,

                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                              255,
                                              1,
                                              53,
                                              17,
                                            ),

                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(
                                                  .25,
                                                ),
                                                blurRadius: 18,
                                              ),
                                            ],
                                          ),

                                          child: const Icon(
                                            Icons.timer,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),

                                        const SizedBox(width: 18),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,

                                            children: [
                                              const Text(
                                                "Meal Plan",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff2D5B37),
                                                ),
                                              ),

                                              const SizedBox(height: 10),

                                              RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    fontSize: sw * .035,
                                                    color: Colors.black87,
                                                  ),

                                                  children: [
                                                    const TextSpan(
                                                      text: "Plan expires in ",
                                                    ),

                                                    TextSpan(
                                                      text: remainingTime,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xff4E7A42,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Text(
                                          "${(progress * 100).toInt()}%",
                                          style: TextStyle(
                                            fontSize: sw * .055,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: sh * .025),

                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),

                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 12,
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          1,
                                          250,
                                          18,
                                        ),
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.grey.shade200,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: sh * .02),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Your meal plan is ",
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: sw * .04,
                                            ),
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 8,
                                          ),

                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              255,
                                              1,
                                              53,
                                              17,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),

                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,

                                            children: [
                                              Icon(
                                                Icons.check,
                                                size: 18,
                                                color: Colors.white,
                                              ),

                                              SizedBox(width: 6),

                                              Text(
                                                "Active",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: sh * .03),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DailyMeal(),
                                    ),
                                  );
                                },
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Color.fromARGB(255, 1, 53, 17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(.25),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.restaurant_menu,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            "View 2-Day Meal Plan",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: sh * .03),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ShoppingList(),
                                    ),
                                  );
                                },
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Color.fromARGB(255, 1, 53, 17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(.25),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            "Shopping List",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: sh * .04),

                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.local_fire_department,
                                      iconColor: Colors.orange,
                                      value: "${dailyTarget["calories"]}",
                                      unit: "kcal",
                                      title: "Calories",
                                    ),
                                  ),

                                  SizedBox(width: sw * .025),

                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.eco,
                                      iconColor: Colors.green,
                                      value: "${dailyTarget["protein"]}",
                                      unit: "g",
                                      title: "Protein",
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: sh * .018),

                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.water_drop,
                                      iconColor: Colors.blue,
                                      value: "${dailyTarget["water"]}",
                                      unit: "Liters",
                                      title: "Water",
                                    ),
                                  ),

                                  SizedBox(width: sw * .025),

                                  Expanded(
                                    child: StatCard(
                                      icon: Icons.nightlight_round,
                                      iconColor: Colors.indigo,
                                      value: "${dailyTarget["sleep"]}",
                                      unit: "Hours",
                                      title: "Sleep",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: sh * .03),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SkinCareScreen(),
                                    ),
                                  );
                                },
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Color.fromARGB(255, 1, 53, 17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(.25),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.face,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            "Skin Care",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: sw * .03),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HairCareScreen(),
                                    ),
                                  );
                                },
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: Color.fromARGB(255, 1, 53, 17),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(.25),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.face_3,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            "Hair Care",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: sh * .03),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xffA8DB69),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(50),
            ),
            onPressed: () {
              // Add your action code here!
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiCoachScreen()),
              );
            },
            child: const Icon(Icons.smart_toy, color: Color(0xff1E4027)),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(28);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.28),
            borderRadius: radius,
            border: Border.all(
              color: Colors.white.withOpacity(.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String title;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),

      child: Column(
        children: [
          Container(
            height: 32,
            width: 32,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: iconColor.withOpacity(.18), blurRadius: 18),
              ],
            ),

            child: Icon(icon, color: iconColor, size: 25),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff1B3B24),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final IconData icon;

  const GradientButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,

      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xff406C43), Color(0xff24462C)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 10),

              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
