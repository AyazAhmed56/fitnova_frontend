class CooldownModel {
  final String exerciseId;
  final String exerciseName;
  final String duration;

  final List<String> instructions;

  const CooldownModel({
    this.exerciseId = '',
    required this.exerciseName,
    required this.duration,
    this.instructions = const [],
  });

  factory CooldownModel.fromMap(Map<String, dynamic> map) {
    return CooldownModel(
      exerciseId: map['exerciseId']?.toString() ?? '',
      exerciseName: map['exerciseName']?.toString() ?? '',
      duration: map['duration']?.toString() ?? '',
      instructions: _stringList(map['instructions']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'duration': duration,
      'instructions': instructions,
    };
  }

  CooldownModel copyWith({
    String? exerciseId,
    String? exerciseName,
    String? duration,
    List<String>? instructions,
  }) {
    return CooldownModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
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
