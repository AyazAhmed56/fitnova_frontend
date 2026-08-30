import 'workout_day_model.dart';

class WorkoutPlanModel {
  final Map<String, WorkoutDayModel> days;
  final DateTime createdAt;

  final String note;
  final Map<String, dynamic> weeklySummary;

  WorkoutPlanModel({
    required this.days,
    required this.createdAt,
    this.note = '',
    this.weeklySummary = const {},
  });

  // ============================================================
  // FROM MAP
  // ============================================================

  factory WorkoutPlanModel.fromMap(Map<String, dynamic> map) {
    final Map<String, WorkoutDayModel> parsedDays = {};

    final rawDays = map['days'];

    if (rawDays is Map) {
      rawDays.forEach((key, value) {
        if (value is Map) {
          parsedDays[key.toString()] = WorkoutDayModel.fromMap(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    final rawSummary = map['weeklySummary'];

    return WorkoutPlanModel(
      days: parsedDays,
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      note: map['note']?.toString() ?? '',
      weeklySummary: rawSummary is Map
          ? Map<String, dynamic>.from(rawSummary)
          : const {},
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.toIso8601String(),

      'note': note,

      'weeklySummary': weeklySummary,

      'days': days.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  WorkoutPlanModel copyWith({
    Map<String, WorkoutDayModel>? days,
    DateTime? createdAt,
    String? note,
    Map<String, dynamic>? weeklySummary,
  }) {
    return WorkoutPlanModel(
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<String> get dayKeys => days.keys.toList();

  List<WorkoutDayModel> get allDays => days.values.toList();

  int get totalDays => days.length;

  WorkoutDayModel? getDay(String dayKey) {
    return days[dayKey];
  }

  WorkoutDayModel? getDayAt(int index) {
    if (index < 0 || index >= days.length) {
      return null;
    }

    return allDays[index];
  }

  bool containsDay(String dayKey) {
    return days.containsKey(dayKey);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() {
    return '''
WorkoutPlanModel(
  totalDays: $totalDays,
  days: $dayKeys,
  createdAt: $createdAt
)
''';
  }
}
