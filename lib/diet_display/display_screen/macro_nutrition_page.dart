import 'package:fitnova/diet_display/models/nutrition_food.dart';
import 'package:fitnova/diet_display/services/nutrition_service.dart';
import 'package:flutter/material.dart';

class MacroNutritionPage extends StatefulWidget {
  final String initialQuery;

  const MacroNutritionPage({
    super.key,
    required this.initialQuery,
  });

  @override
  State<MacroNutritionPage> createState() =>
      _MacroNutritionPageState();
}

class _MacroNutritionPageState
    extends State<MacroNutritionPage> {
  final NutritionService _service = NutritionService();
  final TextEditingController _searchController =
      TextEditingController();

  NutritionSearchResponse? _result;
  bool _loading = true;
  String? _error;

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

  Future<void> _search(String query) async {
    final cleaned = query.trim();

    if (cleaned.isEmpty) return;

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
        _error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Nutrition'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _search(_searchController.text),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search calcium, protein, iron...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () =>
                      _search(_searchController.text),
                ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _ErrorState(
                message: _error!,
                onRetry: () =>
                    _search(_searchController.text),
              )
            else if (_result != null)
              _ResultView(result: _result!)
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final NutritionSearchResponse result;

  const _ResultView({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final total = result.foods.length + result.recipes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${result.nutrientName} Rich Foods',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$total results for "${result.query}"',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),

        if (result.foods.isNotEmpty) ...[
          const Text(
            'Foods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          ...result.foods.map(
            (food) => _FoodCard(
              food: food,
              nutrientName: result.nutrientName,
              nutrientUnit: result.nutrientUnit,
            ),
          ),
        ],

        if (result.recipes.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'FitNova Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          ...result.recipes.map(
            (recipe) => _RecipeCard(
              recipe: recipe,
              nutrientName: result.nutrientName,
              nutrientUnit: result.nutrientUnit,
            ),
          ),
        ],

        if (result.foods.isEmpty && result.recipes.isEmpty)
          const _EmptyState(),
      ],
    );
  }
}

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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Raw food • per 100 g',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _NutritionValue(
                    label: nutrientName,
                    value: _format(
                      food.nutrientValue,
                      nutrientUnit,
                    ),
                  ),
                ),
                Expanded(
                  child: _NutritionValue(
                    label: 'Calories',
                    value: _format(
                      food.calories,
                      'kcal',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  'Protein ${_format(food.proteinG, 'g')}',
                ),
                _Chip(
                  'Carbs ${_format(food.carbohydratesG, 'g')}',
                ),
                _Chip(
                  'Fat ${_format(food.fatG, 'g')}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final NutritionRecipe recipe;
  final String nutrientName;
  final String nutrientUnit;

  const _RecipeCard({
    required this.recipe,
    required this.nutrientName,
    required this.nutrientUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          recipe.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${nutrientName}: ${_format(recipe.nutrientValue, nutrientUnit)} '
          'per serving',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        children: [
          if (recipe.description != null &&
              recipe.description!.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(recipe.description!),
              ),
            ),

          Row(
            children: [
              Expanded(
                child: _NutritionValue(
                  label: 'Calories',
                  value: _format(
                    recipe.calories,
                    'kcal',
                  ),
                ),
              ),
              Expanded(
                child: _NutritionValue(
                  label: 'Protein',
                  value: _format(
                    recipe.proteinG,
                    'g',
                  ),
                ),
              ),
              Expanded(
                child: _NutritionValue(
                  label: 'Fat',
                  value: _format(
                    recipe.fatG,
                    'g',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (recipe.ingredients.isNotEmpty)
            _RecipeSection(
              title: 'Ingredients',
              child: Column(
                children: recipe.ingredients.map(
                  (ingredient) {
                    final quantity =
                        ingredient.quantity == null
                            ? ''
                            : _formatNumber(
                                ingredient.quantity!,
                              );

                    final unit =
                        ingredient.unit ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${ingredient.ingredientName}'
                              '${quantity.isEmpty ? '' : ' • $quantity $unit'}',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

          if (recipe.instructions != null &&
              recipe.instructions!.trim().isNotEmpty)
            _RecipeSection(
              title: 'Instructions',
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  recipe.instructions!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _RecipeSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _NutritionValue extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 50),
      child: Center(
        child: Text(
          'No foods found for this nutrient yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _format(double? value, String unit) {
  if (value == null) return '--';

  final number = value >= 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  return '$number $unit';
}

String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}
