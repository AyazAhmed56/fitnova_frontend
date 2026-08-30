import 'stretching_model.dart';

class RestDayModel {
  final bool restDay;
  final String activity;
  final String notes;
  final List<String> recoveryTips;
  final List<StretchingModel> stretching;

  const RestDayModel({
    required this.restDay,
    required this.activity,
    required this.notes,
    required this.recoveryTips,
    required this.stretching,
  });

  factory RestDayModel.fromMap(Map<String, dynamic> map) {
    return RestDayModel(
      restDay: map['restDay'] ?? false,
      activity: map['activity'] ?? '',
      notes: map['notes'] ?? '',
      recoveryTips: List<String>.from(map['recoveryTips'] ?? const []),
      stretching: (map['stretching'] as List<dynamic>? ?? [])
          .map((e) => StretchingModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restDay': restDay,
      'activity': activity,
      'notes': notes,
      'recoveryTips': recoveryTips,
      'stretching': stretching.map((e) => e.toMap()).toList(),
    };
  }

  RestDayModel copyWith({
    bool? restDay,
    String? activity,
    String? notes,
    List<String>? recoveryTips,
    List<StretchingModel>? stretching,
  }) {
    return RestDayModel(
      restDay: restDay ?? this.restDay,
      activity: activity ?? this.activity,
      notes: notes ?? this.notes,
      recoveryTips: recoveryTips ?? this.recoveryTips,
      stretching: stretching ?? this.stretching,
    );
  }
}
