class ExerciseDBModel {
  final String exerciseDbId;
  final String name;
  final String gifUrl;

  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  const ExerciseDBModel({
    required this.exerciseDbId,
    required this.name,
    required this.gifUrl,
    required this.bodyParts,
    required this.equipments,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory ExerciseDBModel.fromJson(Map<String, dynamic> json) {
    return ExerciseDBModel(
      exerciseDbId: json['exerciseId']?.toString() ?? '',

      name: json['name']?.toString() ?? '',

      gifUrl: json['gifUrl']?.toString() ?? '',

      bodyParts: _stringList(json['bodyParts']),

      equipments: _stringList(json['equipments']),

      targetMuscles: _stringList(json['targetMuscles']),

      secondaryMuscles: _stringList(json['secondaryMuscles']),

      instructions: _stringList(json['instructions']),
    );
  }

  Map<String, dynamic> toCatalogJson() {
    return {
      'exercise_db_id': exerciseDbId,
      'exercise_name': name,
      'normalized_name': normalizeName(name),
      'gif_url': gifUrl,
      'body_parts': bodyParts,
      'equipments': equipments,
      'target_muscles': targetMuscles,
      'secondary_muscles': secondaryMuscles,
      'instructions': instructions,
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String normalizeName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  String toString() {
    return 'ExerciseDBModel('
        'id: $exerciseDbId, '
        'name: $name'
        ')';
  }
}
