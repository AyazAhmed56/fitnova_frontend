class WarmupModel {
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final String duration;

  final List<String> instructions;

  const WarmupModel({
    this.exerciseId = '',
    required this.exerciseName,
    required this.bodyPart,
    required this.duration,
    this.instructions = const [],
  });

  factory WarmupModel.fromMap(Map<String, dynamic> map) {
    return WarmupModel(
      exerciseId: map['exerciseId']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      bodyPart: map['bodyPart']?.toString() ?? '',
      duration: map['duration']?.toString() ?? '',
      instructions: _stringList(map['instructions']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'bodyPart': bodyPart,
      'duration': duration,
      'instructions': instructions,
    };
  }

  WarmupModel copyWith({
    String? exerciseId,
    String? exerciseName,
    String? bodyPart,
    String? duration,
    List<String>? instructions,
  }) {
    return WarmupModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      bodyPart: bodyPart ?? this.bodyPart,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value.map((e) => e.toString()).toList();
  }
}
