import 'dart:ui';
import 'package:fitnova/diet_display/display_screen/mealreceipe.dart';
import 'package:fitnova/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyMeal extends StatefulWidget {
  const DailyMeal({super.key});

  @override
  State<DailyMeal> createState() => _DailyMealState();
}

class _DailyMealState extends State<DailyMeal> {
  String selectedDay = "Day1";

  Future<Map<String, dynamic>?> _loadMealPlan() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return null;
    }

    return await SupabaseService().getMealPlan(user.id);
  }

  pw.TableRow buildTableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),

        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
      ],
    );
  }

  Future<void> generateDayPdf(
    String dayName,
    Map<String, dynamic> day,
    List<Map<String, dynamic>> timeline,
  ) async {
    final pdf = pw.Document();

    final target = Map<String, dynamic>.from(day["dailyTarget"] ?? {});

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),

        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Fitness Schedule - $dayName",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Daily Targets",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              buildTableRow("Calories", target["calories"] ?? ""),
              buildTableRow("Protein", target["protein"] ?? ""),
              buildTableRow("Water", target["water"] ?? ""),
              buildTableRow("Sleep", target["sleep"] ?? ""),
            ],
          ),

          pw.SizedBox(height: 25),

          pw.Text(
            "Timeline",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 10),

          ...timeline.map((item) {
            final ingredientsRaw = item["ingredients"];
            final instructionsRaw = item["instructions"];

            final ingredients = ingredientsRaw is List
                ? ingredientsRaw
                : ingredientsRaw != null
                ? [ingredientsRaw]
                : [];

            final instructions = instructionsRaw is List
                ? instructionsRaw
                : instructionsRaw != null
                ? [instructionsRaw]
                : [];

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 15),

              padding: const pw.EdgeInsets.all(12),

              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),

              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,

                children: [
                  pw.Text(
                    "${item["time"] ?? ""} | ${item["type"] ?? ""}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  pw.SizedBox(height: 5),

                  pw.Text(
                    item["title"] ?? "",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),

                  if ((item["quantity"] ?? "").toString().isNotEmpty)
                    pw.Text("Quantity: ${item["quantity"]}"),

                  if ((item["calories"] ?? "").toString().isNotEmpty)
                    pw.Text("Calories: ${item["calories"]}"),

                  if ((item["protein"] ?? "").toString().isNotEmpty)
                    pw.Text("Protein: ${item["protein"]}"),

                  if (ingredients.isNotEmpty) ...[
                    pw.SizedBox(height: 8),

                    pw.Text(
                      "Ingredients",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),

                    ...ingredients.map((e) => pw.Text(e)),
                  ],

                  if (instructions.isNotEmpty) ...[
                    pw.SizedBox(height: 8),

                    pw.Text(
                      "Instructions",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),

                    ...List.generate(
                      instructions.length,
                      (i) => pw.Text("${i + 1}. ${instructions[i]}"),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "$dayName-fitness-plan.pdf",
    );
  }

  // bool isMealType(String type) {
  //   return [
  //     "Breakfast",
  //     "Lunch",
  //     "Snack",
  //     "Dinner",
  //     "Pre-Workout",
  //     "Post-Workout",
  //     "Post-Workout/Dinner",
  //     "Wake Up",
  //     "Hydration",
  //     "Fruit",
  //     "Workout",
  //     "Sleep",
  //   ].contains(type);
  // }

  // Widget buildTargetCard(String title, String value, IconData icon) {
  //   return Container(
  //     width: 150,
  //     padding: const EdgeInsets.all(12),

  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //     ),

  //     child: Column(
  //       children: [
  //         Icon(icon, color: const Color(0xFF3A6F4B)),

  //         const SizedBox(height: 8),

  //         Text(
  //           value,
  //           textAlign: TextAlign.center,

  //           style: const TextStyle(fontWeight: FontWeight.bold),
  //         ),

  //         const SizedBox(height: 4),

  //         Text(title),
  //       ],
  //     ),
  //   );
  // }

  IconData getTimelineIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
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

        appBar: AppBar(
          centerTitle: true,
          title: const Text("Fitness Schedule"),
        ),

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sw = constraints.maxWidth;
              final sh = constraints.maxHeight;

              return FutureBuilder<Map<String, dynamic>?>(
                future: _loadMealPlan(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text("No Plan Found"));
                  }

                  final plan = snapshot.data!;

                  final supabase = SupabaseService();

                  final expired = supabase.isPlanExpired(plan);

                  final remainingTime = supabase.formatRemainingTime(
                    supabase.getRemainingTime(plan),
                  );

                  if (expired) {
                    return Padding(
                      padding: EdgeInsets.all(sw * .06),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_off_rounded,
                              color: Colors.orange,
                              size: sw * .22,
                            ),

                            SizedBox(height: sh * .03),

                            Text(
                              "Your 2-Day Plan Has Expired",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sw * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: sh * .015),

                            Text(
                              "Generate a new AI plan to continue your fitness journey.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: sw * .04,
                              ),
                            ),

                            SizedBox(height: sh * .04),

                            SizedBox(
                              width: double.infinity,
                              height: sh * .065,

                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),

                                label: const Text("Generate New Plan"),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A6F4B),
                                  foregroundColor: Colors.white,
                                ),

                                onPressed: () async {
                                  final user =
                                      Supabase.instance.client.auth.currentUser;

                                  if (user == null) return;

                                  await SupabaseService().generateAndSavePlans(
                                    user.id,
                                  );

                                  if (!mounted) return;

                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final days = Map<String, dynamic>.from(plan["days"] ?? {});

                  final day = Map<String, dynamic>.from(
                    days[selectedDay] ?? {},
                  );

                  // final dailyTarget = Map<String, dynamic>.from(
                  //   day["dailyTarget"] ?? {},
                  // );

                  final timeline = List<Map<String, dynamic>>.from(
                    day["timeline"] ?? [],
                  );

                  print("Timeline Length: ${timeline.length}");

                  for (final item in timeline) {
                    print(item);
                  }

                  // final skin = Map<String, dynamic>.from(day["skinCare"] ?? {});

                  // final hair = Map<String, dynamic>.from(day["hairCare"] ?? {});

                  return Padding(
                    padding: EdgeInsets.all(sw * 0.02),

                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: sh * .02),

                          padding: EdgeInsets.symmetric(
                            horizontal: sw * .04,
                            vertical: sh * .012,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.green.shade50,

                            borderRadius: BorderRadius.circular(30),

                            border: Border.all(color: Colors.green),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(Icons.timer, color: Colors.green),

                              SizedBox(width: sw * .02),

                              Text(
                                "Expires in $remainingTime",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedDay == "Day1"
                                      ? Colors.white
                                      : const Color.fromARGB(255, 1, 53, 17),
                                  padding: EdgeInsets.symmetric(
                                    vertical: sh * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      sw * 0.02,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  setState(() {
                                    selectedDay = "Day1";
                                  });
                                },

                                child: Text(
                                  "Day 1",
                                  style: TextStyle(
                                    fontSize: sw * 0.035,
                                    color: selectedDay == "Day1"
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: sw * 0.01),

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedDay == "Day2"
                                      ? Colors.white
                                      : const Color.fromARGB(255, 1, 53, 17),
                                  padding: EdgeInsets.symmetric(
                                    vertical: sh * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      sw * 0.02,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  setState(() {
                                    selectedDay = "Day2";
                                  });
                                },

                                child: Text(
                                  "Day 2",
                                  style: TextStyle(
                                    fontSize: sw * 0.035,
                                    color: selectedDay == "Day2"
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: sw * 0.01),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    1,
                                    53,
                                    17,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: sh * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      sw * 0.02,
                                    ),
                                  ),
                                ),

                                onPressed: () async {
                                  await generateDayPdf(
                                    selectedDay,
                                    day,
                                    timeline,
                                  );
                                },

                                // icon: const Icon(Icons.picture_as_pdf),
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.white,
                                ),

                                label: Text(
                                  "PDF",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sw * .034,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: sh * 0.02),

                        // SizedBox(height: sh * 0.02),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: sh * .03),
                            itemCount: timeline.length,
                            itemBuilder: (context, index) {
                              final item = timeline[index];

                              return Padding(
                                padding: EdgeInsets.only(bottom: sh * .02),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            MealRecipeScreen(meal: item),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 18,
                                        sigmaY: 18,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(sw * .045),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(.30),
                                              Colors.white.withOpacity(.12),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              .35,
                                            ),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                .08,
                                              ),
                                              blurRadius: 25,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: sw * .14,
                                              width: sw * .14,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff355C3B),
                                                    Color(0xff1E4027),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xff355C3B,
                                                    ).withOpacity(.35),
                                                    blurRadius: 15,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                getTimelineIcon(
                                                  item["type"] ?? "",
                                                ),
                                                color: Colors.white,
                                                size: sw * .06,
                                              ),
                                            ),

                                            SizedBox(width: sw * .04),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item["type"] ?? "",
                                                          style: TextStyle(
                                                            fontSize: sw * .043,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color(
                                                              0xff1E4027,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  sw * .025,
                                                              vertical:
                                                                  sh * .004,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xff355C3B,
                                                          ).withOpacity(.12),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          item["time"] ?? "",
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xff355C3B,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: sw * .03,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: sh * .015),

                                                  Text(
                                                    item["title"] ?? "",
                                                    style: TextStyle(
                                                      fontSize: sw * .038,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                      height: 1.4,
                                                    ),
                                                  ),

                                                  if ((item["calories"] ?? "")
                                                      .toString()
                                                      .isNotEmpty) ...[
                                                    SizedBox(height: sh * .018),

                                                    Wrap(
                                                      spacing: 10,
                                                      runSpacing: 8,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  .18,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  30,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    .35,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "🔥 ${item["calories"]}",
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                    0xff355C3B,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),

                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  .18,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  30,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    .35,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "💪 ${item["protein"]}",
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Color(
                                                                    0xff355C3B,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
