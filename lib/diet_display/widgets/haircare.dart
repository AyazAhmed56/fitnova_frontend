import 'package:flutter/material.dart';

class HairCareCard extends StatelessWidget {
  final Map<String, dynamic> hair;
  final double sw;
  final double sh;
  const HairCareCard({
    super.key,
    required this.hair,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    if (hair.isEmpty) return const SizedBox();

    final foods = List<String>.from(hair["foods"] ?? []);

    final juice = hair["juice"]?.toString() ?? "";

    final remedy = Map<String, dynamic>.from(hair["homeRemedy"] ?? {});

    final ingredients = List<String>.from(remedy["ingredients"] ?? []);

    final instructions = List<String>.from(remedy["instructions"] ?? []);

    return Container(
      padding: EdgeInsets.all(sw * .045),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa, color: Colors.green),

              SizedBox(width: sw * .02),

              Text(
                "Today's Hair Care",
                style: TextStyle(
                  fontSize: sw * .045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: sh * .02),

          const Text("Foods", style: TextStyle(fontWeight: FontWeight.bold)),

          ...foods.map(
            (e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("• $e"),
            ),
          ),

          SizedBox(height: sh * .02),

          const Text(
            "Recommended Drink",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          Text(juice),

          SizedBox(height: sh * .02),

          Text(
            remedy["title"] ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: sh * .01),

          const Text(
            "Ingredients",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          ...ingredients.map((e) => Text("• $e")),

          SizedBox(height: sh * .015),

          const Text("Steps", style: TextStyle(fontWeight: FontWeight.bold)),

          ...instructions.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("${entry.key + 1}. ${entry.value}"),
            ),
          ),
        ],
      ),
    );
  }
}
