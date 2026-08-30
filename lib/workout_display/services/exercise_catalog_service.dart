import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exercise_catalog_model.dart';

class ExerciseCatalogService {
  ExerciseCatalogService._();

  static final ExerciseCatalogService instance =
      ExerciseCatalogService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'exercise_catalog';

  // ============================================================
  // PAGINATION
  // ============================================================

  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // ============================================================
  // CACHE
  // ============================================================

  final Map<String, ExerciseCatalogModel?> _nameCache = {};
  final Map<String, ExerciseCatalogModel?> _idCache = {};

  // ============================================================
  // NORMALIZATION
  // ============================================================

  static String normalizeExerciseName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\(\)\[\],:/\\\-]'), ' ')
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

    if (_nameCache.containsKey(normalized)) {
      return _nameCache[normalized];
    }

    final response = await _supabase
        .from(_table)
        .select()
        .eq('normalized_name', normalized)
        .maybeSingle();

    final result = response == null
        ? null
        : ExerciseCatalogModel.fromJson(
            Map<String, dynamic>.from(response),
          );

    _nameCache[normalized] = result;

    if (result != null && result.exerciseDbId.isNotEmpty) {
      _idCache[result.exerciseDbId] = result;
    }

    return result;
  }

  // ============================================================
  // EXERCISEDB ID MATCH
  // ============================================================

  Future<ExerciseCatalogModel?> findByExerciseDbId(
    String exerciseDbId,
  ) async {
    final id = exerciseDbId.trim();

    if (id.isEmpty) {
      return null;
    }

    if (_idCache.containsKey(id)) {
      return _idCache[id];
    }

    final response = await _supabase
        .from(_table)
        .select()
        .eq('exercise_db_id', id)
        .maybeSingle();

    final result = response == null
        ? null
        : ExerciseCatalogModel.fromJson(
            Map<String, dynamic>.from(response),
          );

    _idCache[id] = result;

    if (result != null) {
      _nameCache[normalizeExerciseName(result.exerciseName)] = result;
    }

    return result;
  }

  // ============================================================
  // BEST MATCH
  // ============================================================

  Future<ExerciseCatalogModel?> findBestMatch(
    String exerciseName,
  ) async {
    final original = exerciseName.trim();

    if (original.isEmpty) {
      return null;
    }

    // 1. Exact normalized match.
    final exact = await findByName(original);

    if (exact != null) {
      return exact;
    }

    // 2. Remove common Gemini equipment wording.
    final cleaned = _cleanExerciseName(original);

    if (cleaned != original) {
      final cleanedMatch = await findByName(cleaned);

      if (cleanedMatch != null) {
        return cleanedMatch;
      }
    }

    // 3. Search candidates by the complete cleaned phrase.
    final normalized = normalizeExerciseName(cleaned);

    if (normalized.isEmpty) {
      return null;
    }

    final response = await _supabase
        .from(_table)
        .select()
        .ilike('normalized_name', '%$normalized%')
        .limit(20);

    final candidates = response
        .whereType<Map>()
        .map(
          (item) => ExerciseCatalogModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    if (candidates.isNotEmpty) {
      return _chooseBestCandidate(normalized, candidates);
    }

    // 4. Last fallback: search by important words.
    final words = normalized
        .split(' ')
        .where((word) => word.length >= 2)
        .toList();

    words.sort((a, b) => b.length.compareTo(a.length));

    for (final word in words.take(3)) {
      final fallbackResponse = await _supabase
          .from(_table)
          .select()
          .ilike('normalized_name', '%$word%')
          .limit(20);

      final fallbackCandidates = fallbackResponse
          .whereType<Map>()
          .map(
            (item) => ExerciseCatalogModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (fallbackCandidates.isNotEmpty) {
        return _chooseBestCandidate(
          normalized,
          fallbackCandidates,
        );
      }
    }

    return null;
  }

  // ============================================================
  // PAGINATED EXERCISE LIBRARY
  // ============================================================

  Future<ExerciseCatalogPage> getExercisesPage({
    required int page,
    String search = '',
    int pageSize = defaultPageSize,
  }) async {
    final safePage = page < 0 ? 0 : page;
    final safePageSize =
        pageSize.clamp(1, maxPageSize).toInt();

    final from = safePage * safePageSize;
    final to = from + safePageSize - 1;

    final trimmedSearch = search.trim();

    var query = _supabase
        .from(_table)
        .select();

    if (trimmedSearch.isNotEmpty) {
      final normalizedSearch =
          normalizeExerciseName(trimmedSearch);

      query = query.or(
        'exercise_name.ilike.%$trimmedSearch%,'
        'normalized_name.ilike.%$normalizedSearch%,'
        'exercise_db_id.ilike.%$trimmedSearch%',
      );
    }

    final response = await query
        .order('exercise_name', ascending: true)
        .range(from, to);

    final exercises = response
        .whereType<Map>()
        .map(
          (item) => ExerciseCatalogModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    _cacheExercises(exercises);

    return ExerciseCatalogPage(
      exercises: exercises,
      page: safePage,
      pageSize: safePageSize,
      hasMore: exercises.length == safePageSize,
    );
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

    final results = response
        .whereType<Map>()
        .map(
          (item) => ExerciseCatalogModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    _cacheExercises(results);

    return results;
  }

  // ============================================================
  // ALL EXERCISES
  // ============================================================

  Future<List<ExerciseCatalogModel>> getAllExercises() async {
    final List<ExerciseCatalogModel> allExercises = [];

    var from = 0;

    while (true) {
      final to = from + 499;

      final response = await _supabase
          .from(_table)
          .select()
          .order('exercise_name', ascending: true)
          .range(from, to);

      final page = response
          .whereType<Map>()
          .map(
            (item) => ExerciseCatalogModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      allExercises.addAll(page);

      if (page.length < 500) {
        break;
      }

      from += 500;
    }

    _cacheExercises(allExercises);

    return allExercises;
  }

  // ============================================================
  // TOTAL COUNT
  // ============================================================

  Future<int> getExerciseCount() async {
    final response = await _supabase
        .from(_table)
        .select('id')
        .count(CountOption.exact);

    return response.count;
  }

  // ============================================================
  // CACHE HELPERS
  // ============================================================

  void _cacheExercises(
    List<ExerciseCatalogModel> exercises,
  ) {
    for (final exercise in exercises) {
      _nameCache[
        normalizeExerciseName(exercise.exerciseName)
      ] = exercise;

      if (exercise.exerciseDbId.isNotEmpty) {
        _idCache[exercise.exerciseDbId] = exercise;
      }
    }
  }

  void clearCache() {
    _nameCache.clear();
    _idCache.clear();
  }

  // ============================================================
  // NAME CLEANING
  // ============================================================

  String _cleanExerciseName(String name) {
    var cleaned = name.toLowerCase().trim();

    final replacements = <String, String>{
      'barbell/dumbbell': '',
      'barbell or dumbbell': '',
      'barbell / dumbbell': '',
      '(barbell)': '',
      '(dumbbell)': '',
      '[barbell]': '',
      '[dumbbell]': '',
      ' - barbell': '',
      ' - dumbbell': '',
      ' barbell': '',
      ' dumbbell': '',
    };

    for (final entry in replacements.entries) {
      cleaned = cleaned.replaceAll(entry.key, ' ');
    }

    return cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ============================================================
  // BEST CANDIDATE
  // ============================================================

  ExerciseCatalogModel _chooseBestCandidate(
    String normalizedQuery,
    List<ExerciseCatalogModel> candidates,
  ) {
    final queryWords = normalizeExerciseName(
      normalizedQuery,
    )
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toSet();

    int score(ExerciseCatalogModel candidate) {
      final candidateName = normalizeExerciseName(
        candidate.exerciseName,
      );

      final candidateWords =
          candidateName.split(' ').toSet();

      var result = 0;

      for (final word in queryWords) {
        if (candidateWords.contains(word)) {
          result += 10;
        } else if (candidateName.contains(word)) {
          result += 3;
        }
      }

      if (candidateName == normalizedQuery) {
        result += 1000;
      }

      // Prefer a record with a usable GIF.
      if (candidate.gifUrl != null &&
          candidate.gifUrl!.trim().isNotEmpty) {
        result += 5;
      }

      return result;
    }

    candidates.sort(
      (a, b) => score(b).compareTo(score(a)),
    );

    return candidates.first;
  }
}

// ================================================================
// PAGINATION RESULT
// ================================================================

class ExerciseCatalogPage {
  final List<ExerciseCatalogModel> exercises;
  final int page;
  final int pageSize;
  final bool hasMore;

  const ExerciseCatalogPage({
    required this.exercises,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}
