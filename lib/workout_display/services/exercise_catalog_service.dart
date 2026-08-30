import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exercise_catalog_model.dart';

class ExerciseCatalogService {
  ExerciseCatalogService._();

  static final ExerciseCatalogService instance = ExerciseCatalogService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'exercise_catalog';

  // ============================================================
  // NORMALIZATION
  // ============================================================

  static String normalizeExerciseName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\(\)\[\],:/\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // EXACT NAME MATCH
  // ============================================================

  Future<ExerciseCatalogModel?> findByName(String exerciseName) async {
    final normalized = normalizeExerciseName(exerciseName);

    if (normalized.isEmpty) {
      return null;
    }

    final response = await _supabase
        .from(_table)
        .select()
        .eq('normalized_name', normalized)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ExerciseCatalogModel.fromJson(Map<String, dynamic>.from(response));
  }

  // ============================================================
  // BEST MATCH
  // ============================================================

  Future<ExerciseCatalogModel?> findBestMatch(String exerciseName) async {
    // First attempt: exact normalized match.
    final exact = await findByName(exerciseName);

    if (exact != null) {
      return exact;
    }

    // Second attempt: clean common equipment wording.
    final cleaned = _cleanExerciseName(exerciseName);

    if (cleaned != exerciseName) {
      final cleanedMatch = await findByName(cleaned);

      if (cleanedMatch != null) {
        return cleanedMatch;
      }
    }

    // Third attempt: ilike search.
    final normalized = normalizeExerciseName(cleaned);

    if (normalized.isEmpty) {
      return null;
    }

    final response = await _supabase
        .from(_table)
        .select()
        .ilike('normalized_name', '%$normalized%')
        .limit(10);

    if (response.isEmpty) {
      return null;
    }

    final candidates = response
        .whereType<Map>()
        .map(
          (item) =>
              ExerciseCatalogModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    return _chooseBestCandidate(normalized, candidates);
  }

  // ============================================================
  // MULTIPLE MATCHES
  // ============================================================

  Future<List<ExerciseCatalogModel>> findByNames(
    List<String> exerciseNames,
  ) async {
    if (exerciseNames.isEmpty) {
      return [];
    }

    final normalizedNames = exerciseNames
        .map(normalizeExerciseName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (normalizedNames.isEmpty) {
      return [];
    }

    final response = await _supabase
        .from(_table)
        .select()
        .inFilter('normalized_name', normalizedNames);

    // if (response is! List) {
    //   return [];
    // }

    return response
        .whereType<Map>()
        .map(
          (item) =>
              ExerciseCatalogModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ============================================================
  // ALL EXERCISES
  // ============================================================

  Future<List<ExerciseCatalogModel>> getAllExercises() async {
    final response = await _supabase
        .from(_table)
        .select()
        .order('exercise_name', ascending: true);

    // if (response is! List) {
    //   return [];
    // }

    return response
        .whereType<Map>()
        .map(
          (item) =>
              ExerciseCatalogModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ============================================================
  // COUNT
  // ============================================================

  Future<int> getExerciseCount() async {
    final response = await _supabase.from(_table).select('id');

    // if (response is! List) {
    //   return 0;
    // }

    return response.length;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _cleanExerciseName(String name) {
    var cleaned = name;

    final replacements = <String, String>{
      'barbell/dumbbell': '',
      'barbell or dumbbell': '',
      '(barbell)': '',
      '(dumbbell)': '',
      ' - barbell': '',
      ' - dumbbell': '',
      'barbell ': '',
      'dumbbell ': '',
    };

    for (final entry in replacements.entries) {
      cleaned = cleaned.replaceAll(entry.key, entry.value);
    }

    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  ExerciseCatalogModel _chooseBestCandidate(
    String normalizedQuery,
    List<ExerciseCatalogModel> candidates,
  ) {
    final queryWords = normalizedQuery.split(' ');

    int score(ExerciseCatalogModel candidate) {
      final candidateName = normalizeExerciseName(candidate.exerciseName);

      final candidateWords = candidateName.split(' ');

      int result = 0;

      for (final word in queryWords) {
        if (candidateWords.contains(word)) {
          result += 3;
        } else if (candidateName.contains(word)) {
          result += 1;
        }
      }

      if (candidateName == normalizedQuery) {
        result += 100;
      }

      return result;
    }

    candidates.sort((a, b) => score(b).compareTo(score(a)));

    return candidates.first;
  }
}
