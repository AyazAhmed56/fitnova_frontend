class NutritionFood {
  final String id;
  final String name;
  final String normalizedName;
  final String foodType;
  final int? fdcId;
  final String? dataType;

  final double? servingSize;
  final String? servingUnit;

  final double? calories;
  final double? proteinG;
  final double? carbohydratesG;
  final double? fatG;
  final double? fiberG;

  final double? calciumMg;
  final double? ironMg;
  final double? magnesiumMg;
  final double? potassiumMg;
  final double? zincMg;

  final double? vitaminAUg;
  final double? vitaminCMg;
  final double? vitaminDUg;
  final double? vitaminB12Ug;
  final double? folateUg;
  final double? omega3G;

  final String? imageUrl;
  final String source;
  final String? sourceUrl;

  final double? nutrientValue;
  final String? nutrientUnit;

  const NutritionFood({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.foodType,
    this.fdcId,
    this.dataType,
    this.servingSize,
    this.servingUnit,
    this.calories,
    this.proteinG,
    this.carbohydratesG,
    this.fatG,
    this.fiberG,
    this.calciumMg,
    this.ironMg,
    this.magnesiumMg,
    this.potassiumMg,
    this.zincMg,
    this.vitaminAUg,
    this.vitaminCMg,
    this.vitaminDUg,
    this.vitaminB12Ug,
    this.folateUg,
    this.omega3G,
    this.imageUrl,
    this.source = 'USDA FoodData Central',
    this.sourceUrl,
    this.nutrientValue,
    this.nutrientUnit,
  });

  factory NutritionFood.fromJson(Map<String, dynamic> json) {
    double? number(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return NutritionFood(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      normalizedName: json['normalized_name']?.toString() ?? '',
      foodType: json['food_type']?.toString() ?? 'raw',
      fdcId: json['fdc_id'] == null
          ? null
          : int.tryParse(json['fdc_id'].toString()),
      dataType: json['data_type']?.toString(),
      servingSize: number(json['serving_size']),
      servingUnit: json['serving_unit']?.toString(),
      calories: number(json['calories']),
      proteinG: number(json['protein_g']),
      carbohydratesG: number(json['carbohydrates_g']),
      fatG: number(json['fat_g']),
      fiberG: number(json['fiber_g']),
      calciumMg: number(json['calcium_mg']),
      ironMg: number(json['iron_mg']),
      magnesiumMg: number(json['magnesium_mg']),
      potassiumMg: number(json['potassium_mg']),
      zincMg: number(json['zinc_mg']),
      vitaminAUg: number(json['vitamin_a_ug']),
      vitaminCMg: number(json['vitamin_c_mg']),
      vitaminDUg: number(json['vitamin_d_ug']),
      vitaminB12Ug: number(json['vitamin_b12_ug']),
      folateUg: number(json['folate_ug']),
      omega3G: number(json['omega_3_g']),
      imageUrl: json['image_url']?.toString(),
      source: json['source']?.toString() ?? 'USDA FoodData Central',
      sourceUrl: json['source_url']?.toString(),
      nutrientValue: number(json['nutrient_value']),
      nutrientUnit: json['nutrient_unit']?.toString(),
    );
  }

  bool get isRecipe => foodType.toLowerCase() == 'recipe';
}

class NutritionRecipeIngredient {
  final String id;
  final String ingredientName;
  final double? quantity;
  final String? unit;
  final int sortOrder;

  const NutritionRecipeIngredient({
    required this.id,
    required this.ingredientName,
    this.quantity,
    this.unit,
    this.sortOrder = 0,
  });

  factory NutritionRecipeIngredient.fromJson(
    Map<String, dynamic> json,
  ) {
    double? number(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return NutritionRecipeIngredient(
      id: json['id']?.toString() ?? '',
      ingredientName: json['ingredient_name']?.toString() ?? '',
      quantity: number(json['quantity']),
      unit: json['unit']?.toString(),
      sortOrder: int.tryParse(
            json['sort_order']?.toString() ?? '',
          ) ??
          0,
    );
  }
}

class NutritionRecipe {
  final String id;
  final String name;
  final String normalizedName;
  final String? description;
  final String? imageUrl;

  final double? calories;
  final double? proteinG;
  final double? carbohydratesG;
  final double? fatG;
  final double? fiberG;
  final double? calciumMg;
  final double? ironMg;

  final String? instructions;
  final List<NutritionRecipeIngredient> ingredients;

  final double? nutrientValue;
  final String? nutrientUnit;

  const NutritionRecipe({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.description,
    this.imageUrl,
    this.calories,
    this.proteinG,
    this.carbohydratesG,
    this.fatG,
    this.fiberG,
    this.calciumMg,
    this.ironMg,
    this.instructions,
    this.ingredients = const [],
    this.nutrientValue,
    this.nutrientUnit,
  });

  factory NutritionRecipe.fromJson(Map<String, dynamic> json) {
    double? number(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final rawIngredients = json['ingredients'];
    final ingredients = rawIngredients is List
        ? rawIngredients
            .whereType<Map>()
            .map(
              (item) => NutritionRecipeIngredient.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <NutritionRecipeIngredient>[];

    return NutritionRecipe(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      normalizedName:
          json['normalized_name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      calories: number(json['calories']),
      proteinG: number(json['protein_g']),
      carbohydratesG: number(json['carbohydrates_g']),
      fatG: number(json['fat_g']),
      fiberG: number(json['fiber_g']),
      calciumMg: number(json['calcium_mg']),
      ironMg: number(json['iron_mg']),
      instructions: json['instructions']?.toString(),
      ingredients: ingredients,
      nutrientValue: number(json['nutrient_value']),
      nutrientUnit: json['nutrient_unit']?.toString(),
    );
  }
}

class NutritionSearchResponse {
  final String query;
  final String nutrientKey;
  final String nutrientName;
  final String nutrientUnit;
  final List<NutritionFood> foods;
  final List<NutritionRecipe> recipes;

  const NutritionSearchResponse({
    required this.query,
    required this.nutrientKey,
    required this.nutrientName,
    required this.nutrientUnit,
    required this.foods,
    required this.recipes,
  });

  factory NutritionSearchResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final nutrient =
        Map<String, dynamic>.from(json['nutrient'] ?? {});

    final rawFoods = json['foods'];
    final rawRecipes = json['recipes'];

    return NutritionSearchResponse(
      query: json['query']?.toString() ?? '',
      nutrientKey: nutrient['key']?.toString() ?? '',
      nutrientName: nutrient['name']?.toString() ?? '',
      nutrientUnit: nutrient['unit']?.toString() ?? '',
      foods: rawFoods is List
          ? rawFoods
              .whereType<Map>()
              .map(
                (item) => NutritionFood.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      recipes: rawRecipes is List
          ? rawRecipes
              .whereType<Map>()
              .map(
                (item) => NutritionRecipe.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}
