import 'dart:ui';
import 'package:fitnova/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  bool showNote = true;

  Future<Map<String, dynamic>?> _loadMealPlan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return await SupabaseService().getMealPlan(user.id);
  }

  Future<void> generatePdf(Map<String, dynamic> shoppingMap) async {
    final pdf = pw.Document();

    final widgets = <pw.Widget>[];

    widgets.add(
      pw.Text(
        "Shopping List",
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    );

    widgets.add(pw.SizedBox(height: 20));

    for (final category in shoppingMap.entries) {
      widgets.add(
        pw.Text(
          category.key.toUpperCase(),
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );

      widgets.add(pw.SizedBox(height: 8));

      final items = List<String>.from(category.value);

      for (final item in items) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Text(item),
          ),
        );
      }

      widgets.add(pw.SizedBox(height: 15));
    }

    pdf.addPage(pw.MultiPage(build: (context) => widgets));

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "shopping_list.pdf",
    );
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

        appBar: AppBar(centerTitle: true, title: const Text("Shopping List")),

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
                    return const Center(child: Text("No Shopping List Found"));
                  }

                  final mealPlan = snapshot.data!;

                  final supabase = SupabaseService();

                  final expired = supabase.isPlanExpired(mealPlan);

                  final remainingTime = supabase.formatRemainingTime(
                    supabase.getRemainingTime(mealPlan),
                  );

                  if (expired) {
                    return Padding(
                      padding: EdgeInsets.all(sw * .06),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_checkout,
                              size: sw * .22,
                              color: Colors.orange,
                            ),

                            SizedBox(height: sh * .03),

                            Text(
                              "Shopping List Expired",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sw * .06,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: sh * .015),

                            Text(
                              "Your shopping list belongs to an expired meal plan.\nGenerate a new AI plan.",
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
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    123,
                                    250,
                                    4,
                                  ),
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

                  final Map<String, dynamic> shoppingMap =
                      Map<String, dynamic>.from(mealPlan["shoppingList"] ?? {});

                  final note = mealPlan["note"] ?? "";

                  if (shoppingMap.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(sw * .06),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: sw * .22,
                              color: Colors.grey,
                            ),

                            SizedBox(height: sh * .03),

                            Text(
                              "Shopping List Empty",
                              style: TextStyle(
                                fontSize: sw * .055,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: sh * .015),

                            Text(
                              "Generate a new meal plan to create your shopping list.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: sw * .04,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,

                        margin: EdgeInsets.all(sw * 0.05),

                        padding: EdgeInsets.all(sw * 0.05),

                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 1, 53, 17),

                          borderRadius: BorderRadius.circular(sw * 0.04),
                        ),

                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: sw * 0.1,
                            ),

                            SizedBox(height: sh * 0.01),

                            Text(
                              "${shoppingMap.length} Items",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sw * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: sh * 0.008),

                            Text(
                              "Everything needed for your 2-Day Fitness Plan",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: sw * 0.035,
                              ),
                            ),
                            SizedBox(height: sh * .015),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * .03,
                                vertical: sh * .008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                "Expires in $remainingTime",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: sw * .034,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),

                        child: SizedBox(
                          width: double.infinity,

                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                            ),
                            label: const Text("Download PDF"),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                1,
                                53,
                                17,
                              ),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: sh * 0.018,
                              ),
                            ),

                            onPressed: () {
                              generatePdf(shoppingMap);
                            },
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * .05,
                            vertical: sh * .015,
                          ),
                          itemCount: shoppingMap.length,
                          itemBuilder: (context, index) {
                            final category = shoppingMap.entries.elementAt(
                              index,
                            );
                            final items = List<String>.from(category.value);
                            return Padding(
                              padding: EdgeInsets.only(bottom: sh * .018),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 18,
                                    sigmaY: 18,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(.22),
                                          Colors.white.withOpacity(.08),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(.30),
                                      ),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        tilePadding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 4,
                                        ),
                                        childrenPadding: const EdgeInsets.only(
                                          left: 18,
                                          right: 18,
                                          bottom: 16,
                                        ),

                                        leading: Container(
                                          height: 46,
                                          width: 46,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xff355C3B),
                                                Color(0xff1E4027),
                                              ],
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_basket_rounded,
                                            color: Colors.white,
                                          ),
                                        ),

                                        title: Text(
                                          category.key.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: sw * .04,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xff1E4027),
                                          ),
                                        ),

                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xff355C3B,
                                            ).withOpacity(.12),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            "${items.length}",
                                            style: const TextStyle(
                                              color: Color(0xff355C3B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        children: items.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  size: 18,
                                                  color: Color(0xff355C3B),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: sw * .035,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (note.toString().isNotEmpty && showNote)
                        Container(
                          margin: EdgeInsets.all(sw * 0.04),

                          padding: EdgeInsets.all(sw * 0.04),

                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,

                            borderRadius: BorderRadius.circular(sw * 0.04),
                          ),

                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info, size: sw * 0.05),

                                      SizedBox(width: sw * 0.02),

                                      Text(
                                        "Coach Note",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: sw * 0.038,
                                        ),
                                      ),
                                    ],
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.close, size: sw * 0.05),
                                    onPressed: () {
                                      setState(() {
                                        showNote = false;
                                      });
                                    },
                                  ),
                                ],
                              ),

                              SizedBox(height: sh * 0.01),

                              Text(
                                note,
                                style: TextStyle(fontSize: sw * 0.035),
                              ),
                            ],
                          ),
                        ),
                    ],
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
