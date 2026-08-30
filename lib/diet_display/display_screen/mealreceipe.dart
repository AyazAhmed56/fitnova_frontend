import 'dart:ui';

import 'package:flutter/material.dart';

class MealRecipeScreen extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MealRecipeScreen({super.key, required this.meal});

  @override
  State<MealRecipeScreen> createState() => _MealRecipeScreenState();
}

class _MealRecipeScreenState extends State<MealRecipeScreen> {
  IconData getIcon(String type) {
    switch (type) {
      case "Wake Up":
        return Icons.wb_sunny;

      case "Hydration":
        return Icons.water_drop;

      case "Pre Workout":
        return Icons.fitness_center;

      case "Workout":
        return Icons.sports_gymnastics;

      case "Post Workout":
        return Icons.local_drink;

      case "Breakfast":
      case "Lunch":
      case "Snack":
      case "Dinner":
        return Icons.restaurant;

      case "Sleep":
        return Icons.bed;

      default:
        return Icons.schedule;
    }
  }

  Widget buildGlassDropdown({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 1, 54, 9).withOpacity(.30),
                const Color.fromARGB(255, 3, 153, 43).withOpacity(.18),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 4,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              leading: Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xff355C3B), Color(0xff1E4027)],
                  ),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [child],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.meal["type"] ?? "";
    final title = widget.meal["title"] ?? "";
    final time = widget.meal["time"] ?? "";
    final quantity = widget.meal["quantity"] ?? "";
    final calories = widget.meal["calories"]?.toString() ?? "";
    final protein = widget.meal["protein"]?.toString() ?? "";
    final carbs = widget.meal["carbs"]?.toString() ?? "";
    final fat = widget.meal["fat"]?.toString() ?? "";
    final drink = widget.meal["drink"]?.toString() ?? "";
    final coachTip =
        widget.meal["coachTip"]?.toString() ??
        "Follow the meal timing consistently.";
    final ingredientsRaw = widget.meal["ingredients"];
    final instructionsRaw = widget.meal["instructions"];

    final List<dynamic> ingredients = ingredientsRaw is List
        ? ingredientsRaw
        : ingredientsRaw != null
        ? [ingredientsRaw]
        : [];

    final List<dynamic> instructions = instructionsRaw is List
        ? instructionsRaw
        : instructionsRaw != null
        ? [instructionsRaw]
        : [];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/diet_background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,

        appBar: AppBar(centerTitle: true, title: Text(type)),

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sw = constraints.maxWidth;
              final sh = constraints.maxHeight;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,

                      padding: EdgeInsets.all(sw * 0.07),

                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 1, 53, 17),
                      ),

                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: sw * 0.09,
                            backgroundColor: Colors.white,

                            child: Icon(
                              getIcon(type),
                              size: sw * 0.09,
                              color: const Color(0xFF3A6F4B),
                            ),
                          ),

                          SizedBox(height: sh * 0.02),

                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: sh * 0.01),

                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: sw * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(sw * 0.05),

                      child: Column(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: sw * .03,
                            crossAxisSpacing: sw * .03,
                            childAspectRatio: 1.4,
                            children: [
                              _nutritionCard(
                                Icons.local_fire_department,
                                "Calories",
                                calories,
                                Colors.orange,
                                sw,
                              ),

                              _nutritionCard(
                                Icons.fitness_center,
                                "Protein",
                                protein,
                                Colors.blue,
                                sw,
                              ),

                              _nutritionCard(
                                Icons.rice_bowl,
                                "Carbs",
                                carbs,
                                Colors.green,
                                sw,
                              ),

                              _nutritionCard(
                                Icons.water_drop,
                                "Fat",
                                fat,
                                Colors.purple,
                                sw,
                              ),
                            ],
                          ),

                          SizedBox(height: sh * 0.025),

                          buildGlassDropdown(
                            title: "Meal Details",
                            icon: Icons.restaurant,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    time,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                                ListTile(
                                  leading: const Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),

                                if (quantity.isNotEmpty)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.scale,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                      quantity,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (ingredients.isNotEmpty) ...[
                            SizedBox(height: sh * 0.025),

                            buildGlassDropdown(
                              title: "Ingredients",
                              icon: Icons.inventory_2,
                              child: Column(
                                children: ingredients.map((item) {
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                      item.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          if (instructions.isNotEmpty) ...[
                            SizedBox(height: sh * 0.025),

                            buildGlassDropdown(
                              title: "Instructions",
                              icon: Icons.menu_book,
                              child: Column(
                                children: List.generate(
                                  instructions.length,
                                  (index) => ListTile(
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          color: Color(0xff355C3B),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      instructions[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            if (drink.isNotEmpty) ...[
                              SizedBox(height: sh * .025),

                              buildGlassDropdown(
                                title: "Recommended Drink",
                                icon: Icons.local_drink,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.local_drink,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    drink,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ],

                          SizedBox(height: sh * 0.025),

                          buildGlassDropdown(
                            title: "Coach Tip",
                            icon: Icons.lightbulb,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                coachTip,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _nutritionCard(
    IconData icon,
    String title,
    String value,
    Color color,
    double sw,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xff355C3B).withOpacity(.22),
                const Color(0xff1E4027).withOpacity(.10),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(.22),
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sw * .04,
              horizontal: sw * .02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: sw * .085,
                  width: sw * .085,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xff355C3B), Color(0xff1E4027)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff355C3B).withOpacity(.35),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: sw * .045),
                ),

                SizedBox(height: sw * .025),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: sw * .035,
                      color: const Color(0xff1E4027),
                    ),
                  ),
                ),

                SizedBox(height: sw * .01),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: sw * .035,
                    fontWeight: FontWeight.bold,
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
