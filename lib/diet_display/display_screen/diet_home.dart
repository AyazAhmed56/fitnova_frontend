import 'dart:ui';

import 'package:fitnova/ai_coach/ai_coach_screen.dart';
import 'package:fitnova/diet_display/display_screen/dailymeal.dart';
import 'package:fitnova/diet_display/display_screen/haircare_screen.dart';
import 'package:fitnova/diet_display/display_screen/macro_nutrition_page.dart';
import 'package:fitnova/diet_display/display_screen/shoppinglist.dart';
import 'package:fitnova/diet_display/display_screen/skincare_screen.dart';
import 'package:fitnova/diet_display/widgets/nutrition_search_bar.dart';
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
  static const Color darkGreen = Color(0xff063D1B);
  static const Color primaryGreen = Color(0xff075A25);
  static const Color textGreen = Color(0xff214A2D);

  final SupabaseService _supabase = SupabaseService();

  UserProfileModel? _profile;
  Map<String, dynamic>? _mealPlan;

  bool _pageLoading = true;
  bool generateMealPlan = false;
  String? _pageError;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  Future<void> _loadPageData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (!mounted) return;
        setState(() {
          _pageLoading = false;
          _pageError = 'User is not logged in.';
        });
        return;
      }

      final results = await Future.wait([
        _supabase.getUserProfile(user.id),
        _supabase.getMealPlan(user.id),
      ]);

      if (!mounted) return;

      setState(() {
        _profile = results[0] as UserProfileModel?;
        _mealPlan = results[1] as Map<String, dynamic>?;
        _pageLoading = false;
        _pageError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pageLoading = false;
        _pageError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _generateNewMealPlan() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      generateMealPlan = true;
    });

    try {
      await _supabase.generateAndSaveMealPlan(user.id);

      final newMealPlan = await _supabase.getMealPlan(user.id);

      if (!mounted) return;

      setState(() {
        _mealPlan = newMealPlan;
      });

      messenger.showSnackBar(
        const SnackBar(
          content: Text('New meal plan generated successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        generateMealPlan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent the entire DietHome layout from being resized when the
    // browser/mobile keyboard opens. This keeps the TextField mounted
    // and prevents focus/cursor from being lost.
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
          resizeToAvoidBottomInset: false,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 52,
            title: const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xff14361E),
              ),
            ),
          ),

          body: _buildBody(context),

          floatingActionButton: FloatingActionButton(
            heroTag: "diet_ai_coach_fab",
            backgroundColor: const Color(0xffA8DB69),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiCoachScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xff1E4027),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final sw = size.width;
    final sh = size.height;

    if (_pageLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pageError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _pageError!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Text("Profile not found"),
      );
    }

    if (generateMealPlan) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_mealPlan == null) {
      return const Center(
        child: Text("No Meal Plan Generated Yet"),
      );
    }

    final mealPlan = _mealPlan!;

    final bool planExpired =
        _supabase.isPlanExpired(mealPlan);

    final String remainingTime =
        _supabase.formatRemainingTime(
      _supabase.getRemainingTime(mealPlan),
    );

    final double progress =
        _supabase.getPlanProgress(mealPlan);

    if (planExpired) {
      return _buildExpiredPlan(
        context,
        sw,
        sh,
      );
    }

    final days = Map<String, dynamic>.from(
      mealPlan["days"] ?? {},
    );

    final day = Map<String, dynamic>.from(
      days["Day1"] ?? {},
    );

    final dailyTarget = Map<String, dynamic>.from(
      day["dailyTarget"] ?? {},
    );

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.manual,
        padding: EdgeInsets.only(
          left: sw * .045,
          right: sw * .045,
          top: 4,
          bottom: 28,
        ),
        child: Column(
          children: [
            _buildMealPlanStatus(
              remainingTime: remainingTime,
              progress: progress,
            ),

            SizedBox(height: sh * .018),

            // ==========================================================
            // NUTRITION SEARCH
            // ==========================================================

            GlassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(22),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 21,
                        color: primaryGreen,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Nutrition Search",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Find foods rich in protein, calcium, iron and more",
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 11),

                  // IMPORTANT:
                  // This widget owns its controller and focus node.
                  // Typing here does NOT rebuild DietHome.
                  NutritionSearchBar(
                    onSearch: (query) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MacroNutritionPage(
                            initialQuery: query,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: sh * .018),

            ActionButton(
              icon: Icons.restaurant_menu_rounded,
              title: "View 2-Day Meal Plan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyMeal(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            ActionButton(
              icon: Icons.shopping_cart_outlined,
              title: "Shopping List",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShoppingList(),
                  ),
                );
              },
            ),

            SizedBox(height: sh * .018),

            ActionButton(
              icon: Icons.face_retouching_natural_rounded,
              title: "Skin Care",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SkinCareScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            ActionButton(
              icon: Icons.face_3_rounded,
              title: "Hair Care",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HairCareScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: sh * .022),

            _buildStatsGrid(
              dailyTarget: dailyTarget,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanStatus({
    required String remainingTime,
    required double progress,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      borderRadius: BorderRadius.circular(22),

      child: Column(
        children: [
          Row(
            children: [
              // ICON
              Container(
                height: 37,
                width: 37,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: darkGreen,

                  boxShadow: [
                    BoxShadow(
                      color: darkGreen.withOpacity(.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.timer_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Meal Plan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textGreen,
                      ),
                    ),

                    const SizedBox(height: 3),

                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade700,
                        ),

                        children: [
                          const TextSpan(text: "Plan expires in "),

                          TextSpan(
                            text: remainingTime,

                            style: const TextStyle(
                              color: Color(0xff4E7A42),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // PERCENTAGE
              Text(
                "${(progress * 100).toInt()}%",

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,

              backgroundColor: Colors.white.withOpacity(.65),

              valueColor: const AlwaysStoppedAnimation(Color(0xff39D353)),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Text(
                  "Your meal plan is",

                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(30),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(Icons.check_rounded, size: 12, color: Colors.white),

                    SizedBox(width: 4),

                    Text(
                      "Active",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NEW 2 × 2 STATISTICS GRID
  // ================================================================

  Widget _buildStatsGrid({required Map<String, dynamic> dailyTarget}) {
    return Column(
      children: [
        // ------------------------------------------------------------
        // ROW 1
        // ------------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: LargeStatCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
                backgroundColor: const Color(0xfffff5e8),
                value: "${dailyTarget["calories"]}",
                unit: "kcal",
                title: "Calories",
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: LargeStatCard(
                icon: Icons.eco_rounded,
                iconColor: const Color(0xff4E9F62),
                backgroundColor: const Color(0xffeef8ee),
                value: "${dailyTarget["protein"]}",
                unit: "g",
                title: "Protein",
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------------------
        // ROW 2
        // ------------------------------------------------------------
        Row(
          children: [
            Expanded(
              child: LargeStatCard(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xff318BEA),
                backgroundColor: const Color(0xffedf6ff),
                value: "${dailyTarget["water"]}",
                unit: "L",
                title: "Water",
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: LargeStatCard(
                icon: Icons.nightlight_round,
                iconColor: const Color(0xff5A5FCB),
                backgroundColor: const Color(0xfff0f1ff),
                value: "${dailyTarget["sleep"]}",
                unit: "hrs",
                title: "Sleep",
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // EXPIRED PLAN
  // ================================================================

  Widget _buildExpiredPlan(BuildContext context, double sw, double sh) {
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
                    backgroundColor: const Color(0xFF3A6F4B),
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: generateMealPlan
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,

                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Generate New Plan"),

                                content: const Text(
                                  "This will replace your current meal plan. Continue?",
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },

                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },

                                    child: const Text("Generate"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm != true) {
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            setState(() {
                              generateMealPlan = true;
                            });

                            final user =
                                Supabase.instance.client.auth.currentUser;

                            if (user == null) return;

                            await SupabaseService().generateAndSaveMealPlan(
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
                              SnackBar(content: Text(e.toString())),
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
}

// ====================================================================
// ACTION BUTTON
// ====================================================================

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(17),

        child: Ink(
          height: 50,

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,

              colors: [Color(0xff06431D), Color(0xff075D27)],
            ),

            borderRadius: BorderRadius.circular(17),

            boxShadow: [
              BoxShadow(
                color: const Color(0xff063D1B).withOpacity(.20),

                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: Row(
              children: [
                Container(
                  height: 31,
                  width: 31,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.14),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(icon, color: Colors.white, size: 17),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    title,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                Container(
                  height: 25,
                  width: 25,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// NEW LARGE STAT CARD
// ====================================================================

class LargeStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String value;
  final String unit;
  final String title;

  const LargeStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.value,
    required this.unit,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.50),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.white.withOpacity(.75), width: 1.2),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ----------------------------------------------------------
          // TOP ICON + TITLE
          // ----------------------------------------------------------
          Row(
            children: [
              Container(
                height: 35,
                width: 35,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: iconColor, size: 19),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff27472F),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // ----------------------------------------------------------
          // VALUE
          // ----------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,

            textBaseline: TextBaseline.alphabetic,

            children: [
              Flexible(
                child: Text(
                  value,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff172A1C),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              Text(
                unit,

                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Text(
            "Daily target",

            style: TextStyle(
              fontSize: 10.5,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// GLASS CARD
// ====================================================================

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
    final radius = borderRadius ?? BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: radius,

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),

        child: Container(
          padding: padding,

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.30),

            borderRadius: radius,

            border: Border.all(color: Colors.white.withOpacity(.55), width: 1),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }
}

// ====================================================================
// OPTIONAL GRADIENT BUTTON
// ====================================================================

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
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: onTap,

        child: Ink(
          height: 50,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            gradient: const LinearGradient(
              colors: [Color(0xff406C43), Color(0xff24462C)],
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(icon, color: Colors.white, size: 18),

              const SizedBox(width: 8),

              Text(
                text,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
