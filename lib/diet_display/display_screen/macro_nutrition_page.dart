import 'dart:ui';

import 'package:fitnova/diet_display/models/nutrition_food.dart';
import 'package:fitnova/diet_display/services/nutrition_service.dart';
import 'package:flutter/material.dart';

class MacroNutritionPage extends StatefulWidget {
  final String initialQuery;

  const MacroNutritionPage({super.key, required this.initialQuery});

  @override
  State<MacroNutritionPage> createState() => _MacroNutritionPageState();
}

class _MacroNutritionPageState extends State<MacroNutritionPage> {
  final NutritionService _service = NutritionService();

  final TextEditingController _searchController = TextEditingController();

  NutritionSearchResponse? _result;

  bool _loading = true;

  String? _error;

  static const Color darkGreen = Color(0xff063D1B);
  static const Color primaryGreen = Color(0xff075D27);

  @override
  void initState() {
    super.initState();

    _searchController.text = widget.initialQuery;

    _search(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // SEARCH
  // ================================================================

  Future<void> _search(String query) async {
    final cleaned = query.trim();

    if (cleaned.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.searchNutrition(cleaned);

      if (!mounted) return;

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;

        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

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

          // ========================================================
          // APP BAR
          // ========================================================
          appBar: AppBar(
            backgroundColor: Colors.white.withOpacity(.72),

            elevation: 0,

            scrolledUnderElevation: 0,

            centerTitle: true,

            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },

              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 19,
                color: Color(0xff1E3424),
              ),
            ),

            title: const Text(
              "Macro Nutrition",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xff17351F),
              ),
            ),
          ),

          // ========================================================
          // BODY
          // ========================================================
          body: Stack(
            children: [
              // ----------------------------------------------------
              // LIGHT OVERLAY
              // ----------------------------------------------------
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(.30)),
              ),

              // ----------------------------------------------------
              // CONTENT
              // ----------------------------------------------------
              SafeArea(
                top: false,

                child: RefreshIndicator(
                  color: primaryGreen,

                  backgroundColor: Colors.white,

                  onRefresh: () => _search(_searchController.text),

                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),

                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),

                    children: [
                      // ==================================================
                      // SEARCH BAR
                      // ==================================================
                      _buildSearchBar(),

                      const SizedBox(height: 20),

                      // ==================================================
                      // CONTENT
                      // ==================================================
                      if (_loading)
                        const _LoadingState()
                      else if (_error != null)
                        _ErrorState(
                          message: _error!,
                          onRetry: () => _search(_searchController.text),
                        )
                      else if (_result != null)
                        _ResultView(result: _result!)
                      else
                        const _EmptyState(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SEARCH BAR
  // ================================================================

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),

      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

        child: Container(
          height: 55,

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.68),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: Colors.white.withOpacity(.85), width: 1),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: TextField(
            controller: _searchController,

            textInputAction: TextInputAction.search,

            onSubmitted: _search,

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff26352A),
            ),

            decoration: InputDecoration(
              hintText: "Search calcium, protein, iron...",

              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),

              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: Color(0xff305C3B),
              ),

              suffixIcon: IconButton(
                onPressed: () {
                  _search(_searchController.text);
                },

                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: darkGreen,
                ),
              ),

              filled: false,

              border: InputBorder.none,

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// RESULT VIEW
// ====================================================================

class _ResultView extends StatelessWidget {
  final NutritionSearchResponse result;

  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final total = result.foods.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // ============================================================
        // HEADER
        // ============================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Expanded(
              child: Text(
                '${result.nutrientName} Rich Foods',

                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff17351F),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.65),

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: Colors.white.withOpacity(.8)),
              ),

              child: Text(
                '$total',

                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff063D1B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          '$total foods found for "${result.query}"',

          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),

        const SizedBox(height: 17),

        // ============================================================
        // FOODS TITLE
        // ============================================================
        const Row(
          children: [
            Icon(Icons.restaurant_rounded, size: 18, color: Color(0xff075D27)),

            SizedBox(width: 7),

            Text(
              "Foods",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xff214A2D),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ============================================================
        // FOOD LIST
        // ============================================================
        if (result.foods.isNotEmpty)
          ...result.foods.map(
            (food) => _FoodCard(
              food: food,
              nutrientName: result.nutrientName,
              nutrientUnit: result.nutrientUnit,
            ),
          ),

        if (result.foods.isEmpty) const _EmptyState(),
      ],
    );
  }
}

// ====================================================================
// FOOD CARD
// ====================================================================

class _FoodCard extends StatelessWidget {
  final NutritionFood food;

  final String nutrientName;

  final String nutrientUnit;

  const _FoodCard({
    required this.food,
    required this.nutrientName,
    required this.nutrientUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.76),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white.withOpacity(.90), width: 1),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ========================================================
            // FOOD NAME
            // ========================================================
            Text(
              food.name,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 15,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: Color(0xff18291D),
              ),
            ),

            const SizedBox(height: 5),

            // ========================================================
            // SOURCE
            // ========================================================
            Row(
              children: [
                Container(
                  height: 6,
                  width: 6,

                  decoration: const BoxDecoration(
                    color: Color(0xff4F9A5E),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  'USDA food • per 100 g',

                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // ========================================================
            // MAIN NUTRITION VALUES
            // ========================================================
            Row(
              children: [
                Expanded(
                  child: _NutritionValue(
                    label: nutrientName,
                    value: _format(food.nutrientValue, nutrientUnit),
                    highlighted: true,
                  ),
                ),

                Container(width: 1, height: 34, color: Colors.grey.shade300),

                const SizedBox(width: 15),

                Expanded(
                  child: _NutritionValue(
                    label: 'Calories',
                    value: _format(food.calories, 'kcal'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // ========================================================
            // MACRO CHIPS
            // ========================================================
            Wrap(
              spacing: 6,
              runSpacing: 6,

              children: [
                _Chip(
                  icon: Icons.fitness_center_rounded,
                  text: 'Protein ${_format(food.proteinG, 'g')}',
                ),

                _Chip(
                  icon: Icons.grain_rounded,
                  text: 'Carbs ${_format(food.carbohydratesG, 'g')}',
                ),

                _Chip(
                  icon: Icons.opacity_rounded,
                  text: 'Fat ${_format(food.fatG, 'g')}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// NUTRITION VALUE
// ====================================================================

class _NutritionValue extends StatelessWidget {
  final String label;

  final String value;

  final bool highlighted;

  const _NutritionValue({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          value,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 18,

            fontWeight: FontWeight.w800,

            color: highlighted
                ? const Color(0xff075D27)
                : const Color(0xff1B251D),
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// CHIP
// ====================================================================

class _Chip extends StatelessWidget {
  final IconData icon;

  final String text;

  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

      decoration: BoxDecoration(
        color: const Color(0xffF2F5F1),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.white, width: 1),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 11, color: const Color(0xff42684A)),

          const SizedBox(width: 4),

          Text(
            text,

            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xff405146),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// LOADING STATE
// ====================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),

      child: Center(
        child: Column(
          children: [
            Container(
              height: 58,
              width: 58,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.75),

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.07),
                    blurRadius: 12,
                  ),
                ],
              ),

              child: const Padding(
                padding: EdgeInsets.all(17),

                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xff075D27),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              "Finding nutrition-rich foods...",

              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// ERROR STATE
// ====================================================================

class _ErrorState extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),

      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.65),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(color: Colors.white.withOpacity(.8)),
              ),

              child: Column(
                children: [
                  Container(
                    height: 52,
                    width: 52,

                    decoration: const BoxDecoration(
                      color: Color(0xffffeeee),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 27,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Something went wrong",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    message,
                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: onRetry,

                    icon: const Icon(Icons.refresh_rounded, size: 18),

                    label: const Text("Try Again"),

                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff075D27),

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// EMPTY STATE
// ====================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 55),

      child: Center(
        child: Column(
          children: [
            Container(
              height: 65,
              width: 65,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.70),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.search_off_rounded,
                size: 30,
                color: Color(0xff52715A),
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              "No foods found",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xff24392A),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "No foods were found for this nutrient yet.",

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// NUMBER FORMAT
// ====================================================================

String _format(double? value, String unit) {
  if (value == null) {
    return '--';
  }

  final number = value >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  return '$number $unit';
}
