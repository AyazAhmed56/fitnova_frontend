import 'dart:ui';

import 'package:fitnova/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HairCareScreen extends StatefulWidget {
  const HairCareScreen({super.key});

  @override
  State<HairCareScreen> createState() => _HairCareScreenState();
}

class _HairCareScreenState extends State<HairCareScreen> {
  Future<Map<String, dynamic>?> _loadMealPlan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return await SupabaseService().getMealPlan(user.id);
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
    Future<void> generatePdf(
      List<String> foods,
      String juice,
      Map<String, dynamic> remedy,
      List<String> ingredients,
      List<String> instructions,
    ) async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Text(
              "Hair Care Routine",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Foods",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            ...foods.map((e) => pw.Text(e)),

            pw.SizedBox(height: 20),

            pw.Text(
              "Recommended Drink",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.Text(juice),

            pw.SizedBox(height: 20),

            pw.Text(
              remedy["title"] ?? "",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              "Ingredients",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            ...ingredients.map((e) => pw.Text(e)),

            pw.SizedBox(height: 20),

            pw.Text(
              "Steps",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),

            ...instructions.asMap().entries.map(
              (e) => pw.Text("${e.key + 1}. ${e.value}"),
            ),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "hair_care_routine.pdf",
      );
    }

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

        appBar: AppBar(centerTitle: true, title: const Text("Hair Care")),

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
                    return const Center(child: Text("No Meal Plan Found"));
                  }

                  final mealPlan = snapshot.data!;

                  final supabase = SupabaseService();

                  final expired = supabase.isPlanExpired(mealPlan);

                  if (expired) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(sw * .06),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.spa_outlined,
                              color: Colors.orange,
                              size: sw * .22,
                            ),

                            SizedBox(height: sh * .03),

                            Text(
                              "Hair Care Schedule Expired",
                              style: TextStyle(
                                fontSize: sw * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: sh * .015),

                            Text(
                              "Generate a new AI meal plan to receive a fresh hair care routine.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sw * .04,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final days = Map<String, dynamic>.from(
                    mealPlan["days"] ?? {},
                  );

                  final day = Map<String, dynamic>.from(days["Day1"] ?? {});

                  final hair = Map<String, dynamic>.from(day["hairCare"] ?? {});

                  final foods = List<String>.from(hair["foods"] ?? []);

                  final juice = hair["juice"]?.toString() ?? "";

                  final remedy = Map<String, dynamic>.from(
                    hair["homeRemedy"] ?? {},
                  );

                  final ingredients = List<String>.from(
                    remedy["ingredients"] ?? [],
                  );

                  final instructions = List<String>.from(
                    remedy["instructions"] ?? [],
                  );

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(sw * .05),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(sw * .06),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 1, 53, 17),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Today's Hair Care",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: sw * .055,
                                ),
                              ),

                              SizedBox(height: sh * .01),

                              Text(
                                "AI Generated Routine",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: sw * .038,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: sh * .03),

                        buildGlassDropdown(
                          title: "Foods For Healthy Hair",
                          icon: Icons.restaurant,
                          child: Column(
                            children: foods.map((food) {
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  food,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        SizedBox(height: sh * .03),

                        buildGlassDropdown(
                          title: "Recommended Drink",
                          icon: Icons.local_drink,
                          child: ListTile(
                            leading: const Icon(
                              Icons.local_drink,
                              color: Colors.white,
                            ),
                            title: Text(
                              juice,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: sh * .03),

                        buildGlassDropdown(
                          title: remedy["title"] ?? "Home Remedy",
                          icon: Icons.spa,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ingredients",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ...ingredients.map(
                                (ingredient) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          ingredient,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                "How To Apply",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              ...instructions.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          "${entry.key + 1}",
                                          style: const TextStyle(
                                            color: Color(0xff355C3B),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: sh * .03),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text("Download PDF"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 1, 53, 17),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: sh * .018,
                              ),
                            ),
                            onPressed: () {
                              generatePdf(
                                foods,
                                juice,
                                remedy,
                                ingredients,
                                instructions,
                              );
                            },
                          ),
                        ),

                        SizedBox(height: sh * .03),
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
