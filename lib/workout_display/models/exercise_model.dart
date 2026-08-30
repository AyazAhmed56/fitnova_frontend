class ExerciseModel {
  // ============================================================
  // GEMINI / PROGRAMMING DATA
  // ============================================================

  final String exerciseId;
  final String exerciseName;
  final String exerciseOrder;
  final String exerciseType;

  final String muscleGroup;
  final List<String> secondaryMuscles;

  final bool isCompound;

  final String difficulty;
  final String equipmentRequired;

  final String sets;
  final String reps;
  final String duration;
  final String rest;
  final String tempo;

  final List<String> instructions;
  final List<String> tips;
  final List<String> precautions;
  final List<String> commonMistakes;
  final List<String> substituteExercises;

  // ============================================================
  // SUPABASE / EXERCISEDB DATA
  // ============================================================

  final String? exerciseDbId;
  final String? gifUrl;

  final List<String> bodyParts;
  final List<String> targetMuscles;

  final List<String> catalogSecondaryMuscles;
  final List<String> catalogInstructions;

  ExerciseModel({
    required this.exerciseId,
    required this.exerciseName,
    required this.exerciseOrder,
    required this.exerciseType,
    required this.muscleGroup,
    required this.secondaryMuscles,
    required this.isCompound,
    required this.difficulty,
    required this.equipmentRequired,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.rest,
    required this.tempo,
    required this.instructions,
    required this.tips,
    required this.precautions,
    required this.commonMistakes,
    required this.substituteExercises,
    required this.exerciseDbId,
    required this.gifUrl,
    required this.bodyParts,
    required this.targetMuscles,
    required this.catalogSecondaryMuscles,
    required this.catalogInstructions,
  });

  // ============================================================
  // FROM MAP
  // ============================================================

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      exerciseId: map['exerciseId']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      exerciseOrder: map['exerciseOrder']?.toString() ?? '',
      exerciseType: map['exerciseType']?.toString() ?? '',

      muscleGroup: map['muscleGroup']?.toString() ?? '',

      secondaryMuscles: _stringList(map['secondaryMuscles']),

      isCompound: map['isCompound'] == true,

      difficulty: map['difficulty']?.toString() ?? '',
      equipmentRequired: map['equipmentRequired']?.toString() ?? '',

      sets: map['sets']?.toString() ?? '',
      reps: map['reps']?.toString() ?? '',
      duration: map['duration']?.toString() ?? '',
      rest: map['rest']?.toString() ?? '',
      tempo: map['tempo']?.toString() ?? '',

      instructions: _stringList(map['instructions']),

      tips: _stringList(map['tips']),

      precautions: _stringList(map['precautions']),

      commonMistakes: _stringList(map['commonMistakes']),

      substituteExercises: _stringList(map['substituteExercises']),

      exerciseDbId: map['exerciseDbId']?.toString(),
      gifUrl: map['gifUrl']?.toString(),

      bodyParts: _stringList(map['bodyParts']),

      targetMuscles: _stringList(map['targetMuscles']),

      catalogSecondaryMuscles: _stringList(map['catalogSecondaryMuscles']),

      catalogInstructions: _stringList(map['catalogInstructions']),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      // Gemini programming
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'exerciseOrder': exerciseOrder,
      'exerciseType': exerciseType,
      'muscleGroup': muscleGroup,
      'secondaryMuscles': secondaryMuscles,
      'isCompound': isCompound,
      'difficulty': difficulty,
      'equipmentRequired': equipmentRequired,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'rest': rest,
      'tempo': tempo,
      'instructions': instructions,
      'tips': tips,
      'precautions': precautions,
      'commonMistakes': commonMistakes,
      'substituteExercises': substituteExercises,

      // Supabase ExerciseDB
      'exerciseDbId': exerciseDbId,
      'gifUrl': gifUrl,
      'bodyParts': bodyParts,
      'targetMuscles': targetMuscles,
      'catalogSecondaryMuscles': catalogSecondaryMuscles,
      'catalogInstructions': catalogInstructions,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  ExerciseModel copyWith({
    String? exerciseId,
    String? exerciseName,
    String? exerciseOrder,
    String? exerciseType,
    String? muscleGroup,
    List<String>? secondaryMuscles,
    bool? isCompound,
    String? difficulty,
    String? equipmentRequired,
    String? sets,
    String? reps,
    String? duration,
    String? rest,
    String? tempo,
    List<String>? instructions,
    List<String>? tips,
    List<String>? precautions,
    List<String>? commonMistakes,
    List<String>? substituteExercises,

    String? exerciseDbId,
    String? gifUrl,
    List<String>? bodyParts,
    List<String>? targetMuscles,
    List<String>? catalogSecondaryMuscles,
    List<String>? catalogInstructions,
  }) {
    return ExerciseModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseOrder: exerciseOrder ?? this.exerciseOrder,
      exerciseType: exerciseType ?? this.exerciseType,

      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,

      isCompound: isCompound ?? this.isCompound,

      difficulty: difficulty ?? this.difficulty,
      equipmentRequired: equipmentRequired ?? this.equipmentRequired,

      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      rest: rest ?? this.rest,
      tempo: tempo ?? this.tempo,

      instructions: instructions ?? this.instructions,

      tips: tips ?? this.tips,

      precautions: precautions ?? this.precautions,

      commonMistakes: commonMistakes ?? this.commonMistakes,

      substituteExercises: substituteExercises ?? this.substituteExercises,

      exerciseDbId: exerciseDbId ?? this.exerciseDbId,

      gifUrl: gifUrl ?? this.gifUrl,

      bodyParts: bodyParts ?? this.bodyParts,

      targetMuscles: targetMuscles ?? this.targetMuscles,

      catalogSecondaryMuscles:
          catalogSecondaryMuscles ?? this.catalogSecondaryMuscles,

      catalogInstructions: catalogInstructions ?? this.catalogInstructions,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  /// Prefer ExerciseDB instructions when available.
  List<String> get effectiveInstructions {
    if (catalogInstructions.isNotEmpty) {
      return catalogInstructions;
    }

    return instructions;
  }

  /// Prefer ExerciseDB secondary muscles when available.
  List<String> get effectiveSecondaryMuscles {
    if (catalogSecondaryMuscles.isNotEmpty) {
      return catalogSecondaryMuscles;
    }

    return secondaryMuscles;
  }

  /// True when this exercise was successfully matched
  /// against the Supabase ExerciseDB catalog.
  bool get hasCatalogData {
    return exerciseDbId != null && exerciseDbId!.isNotEmpty;
  }

  /// True when a GIF is available.
  bool get hasGif {
    return gifUrl != null && gifUrl!.isNotEmpty;
  }

  @override
  String toString() {
    return 'ExerciseModel('
        'exerciseName: $exerciseName, '
        'exerciseDbId: $exerciseDbId, '
        'sets: $sets, '
        'reps: $reps'
        ')';
  }
}
