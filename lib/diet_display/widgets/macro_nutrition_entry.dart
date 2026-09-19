import 'package:fitnova/diet_display/display_screen/macro_nutrition_page.dart';
import 'package:flutter/material.dart';
import 'nutrition_search_bar.dart';

class MacroNutritionEntry extends StatelessWidget {
  const MacroNutritionEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return NutritionSearchBar(
      onSearch: (query) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MacroNutritionPage(initialQuery: query),
          ),
        );
      },
    );
  }
}
