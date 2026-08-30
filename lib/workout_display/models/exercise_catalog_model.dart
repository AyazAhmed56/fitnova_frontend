class ExerciseCatalogModel {
  final String id;
  final String exerciseDbId;
  final String exerciseName;
  final String normalizedName;
  final String? gifUrl;

  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExerciseCatalogModel({
    required this.id,
    required this.exerciseDbId,
    required this.exerciseName,
    required this.normalizedName,
    required this.gifUrl,
    required this.bodyParts,
    required this.equipments,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseCatalogModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCatalogModel(
      id: json['id']?.toString() ?? '',
      exerciseDbId: json['exercise_db_id']?.toString() ?? '',
      exerciseName: json['exercise_name']?.toString() ?? '',
      normalizedName: json['normalized_name']?.toString() ?? '',
      gifUrl: _nullableString(json['gif_url']),

      bodyParts: _stringList(json['body_parts']),
      equipments: _stringList(json['equipments']),
      targetMuscles: _stringList(json['target_muscles']),
      secondaryMuscles: _stringList(json['secondary_muscles']),
      instructions: _stringList(json['instructions']),

      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  String get primaryBodyPart {
    if (bodyParts.isEmpty) {
      return 'General';
    }

    return bodyParts.first;
  }

  String get primaryTargetMuscle {
    if (targetMuscles.isEmpty) {
      return 'General';
    }

    return targetMuscles.first;
  }

  String get primaryEquipment {
    if (equipments.isEmpty) {
      return 'Body weight';
    }

    return equipments.first;
  }

  @override
  String toString() {
    return 'ExerciseCatalogModel('
        'exerciseDbId: $exerciseDbId, '
        'exerciseName: $exerciseName'
        ')';
  }
}
