import 'dart:convert';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutAIService {
  WorkoutAIService();

  String get workoutApiKey => dotenv.get('GEMINI_API_KEY_WORKOUT');

  static const String _model = 'gemini-2.5-flash';

  static const int _maxOutputTokens = 50000;

  static const Duration _requestTimeout = Duration(minutes: 3);

  final SupabaseClient _supabase = Supabase.instance.client;

  // GENERATE WORKOUT PLAN
  Future<Map<String, dynamic>> generateWorkoutPlan(
    UserProfileModel profile,
  ) async {
    final catalog = await _getExerciseCatalog();

    if (catalog.isEmpty) {
      throw Exception(
        'Exercise catalog is empty. '
        'Please check exercise_catalog in Supabase.',
      );
    }

    final catalogNames = catalog
        .map((e) => e['normalized_name'] ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final catalogMap = <String, Map<String, String>>{};

    for (final exercise in catalog) {
      final normalized =
          exercise['normalized_name']?.trim().toLowerCase() ?? '';

      if (normalized.isEmpty) {
        continue;
      }

      catalogMap[normalized] = exercise;
    }

    final prompt = _buildPrompt(profile, catalogNames);

    final response = await _callGemini(prompt);

    final workoutPlan = _parseGeminiResponse(response);

    // ----------------------------------------------------------
    // IMPORTANT
    // Repair obvious catalog-name formatting/alias problems
    // BEFORE validation.
    // ----------------------------------------------------------

    _resolveGeminiCatalogNames(workoutPlan, catalogMap);

    // ----------------------------------------------------------
    // Validate after names have been resolved.
    // ----------------------------------------------------------

    _validateWorkoutPlan(workoutPlan, catalogMap);

    // ----------------------------------------------------------
    // Generate substitutes automatically from Supabase.
    // ----------------------------------------------------------

    _generateSubstituteExercises(workoutPlan, catalogMap);

    // ----------------------------------------------------------
    // Add ExerciseDB/Supabase information.
    // ----------------------------------------------------------

    _enrichWorkoutPlan(workoutPlan, catalogMap);

    return workoutPlan;
  }

  // GEMINI REQUEST
  Future<http.Response> _callGemini(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:generateContent?key=$workoutApiKey',
    );

    http.Response? lastResponse;

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final stopwatch = Stopwatch()..start();

        final response = await http
            .post(
              url,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.2,
                  'responseMimeType': 'application/json',
                  'maxOutputTokens': _maxOutputTokens,
                },
              }),
            )
            .timeout(_requestTimeout);

        stopwatch.stop();

        print(
          'Workout Gemini attempt '
          '$attempt completed in '
          '${stopwatch.elapsed.inSeconds}s '
          'with status '
          '${response.statusCode}.',
        );

        lastResponse = response;

        if (response.statusCode == 200) {
          return response;
        }

        if (response.statusCode == 429 ||
            response.statusCode == 500 ||
            response.statusCode == 502 ||
            response.statusCode == 503 ||
            response.statusCode == 504) {
          if (attempt < 2) {
            await Future.delayed(const Duration(seconds: 3));

            continue;
          }
        }

        throw Exception(
          'Gemini Error '
          '(${response.statusCode}): '
          '${response.body}',
        );
      } on http.ClientException catch (e) {
        if (attempt == 2) {
          throw Exception('Unable to connect to Gemini.\n$e');
        }

        await Future.delayed(const Duration(seconds: 3));
      } on FormatException catch (e) {
        throw Exception('Invalid Gemini response.\n$e');
      } catch (e) {
        if (e.toString().contains('TimeoutException')) {
          if (attempt == 2) {
            throw Exception(
              'Workout generation timed out '
              'after ${_requestTimeout.inMinutes} '
              'minutes.',
            );
          }

          await Future.delayed(const Duration(seconds: 3));

          continue;
        }

        rethrow;
      }
    }

    throw Exception(
      'Gemini request failed with status '
      '${lastResponse?.statusCode ?? 'unknown'}.',
    );
  }

  // GET EXERCISE CATALOG
  Future<List<Map<String, String>>> _getExerciseCatalog() async {
    try {
      final response = await _supabase
          .from('exercise_catalog')
          .select(
            'exercise_name, '
            'normalized_name, '
            'exercise_db_id, '
            'gif_url, '
            'body_parts, '
            'equipments, '
            'target_muscles, '
            'secondary_muscles, '
            'instructions',
          )
          .order('normalized_name');

      final List<Map<String, String>> catalog = [];

      final Set<String> seen = {};

      for (final row in response) {
        final normalized =
            row['normalized_name']?.toString().trim().toLowerCase() ?? '';

        if (normalized.isEmpty) {
          continue;
        }

        if (seen.contains(normalized)) {
          continue;
        }

        seen.add(normalized);

        catalog.add({
          'normalized_name': normalized,

          'exercise_name': row['exercise_name']?.toString().trim() ?? '',

          'exercise_db_id': row['exercise_db_id']?.toString().trim() ?? '',

          'gif_url': row['gif_url']?.toString().trim() ?? '',

          'body_parts': _encodeCatalogList(row['body_parts']),

          'equipments': _encodeCatalogList(row['equipments']),

          'target_muscles': _encodeCatalogList(row['target_muscles']),

          'secondary_muscles': _encodeCatalogList(row['secondary_muscles']),

          'instructions': _encodeCatalogList(row['instructions']),
        });
      }

      print(
        'Exercise catalog loaded: '
        '${catalog.length}',
      );

      return catalog;
    } catch (e) {
      throw Exception(
        'Failed to load exercise catalog '
        'from Supabase.\n'
        'Error: $e',
      );
    }
  }

  // ENCODE SUPABASE LIST
  String _encodeCatalogList(dynamic value) {
    if (value is List) {
      return jsonEncode(
        value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
    }

    if (value == null) {
      return '[]';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '[]';
    }

    try {
      final decoded = jsonDecode(text);

      if (decoded is List) {
        return jsonEncode(
          decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        );
      }
    } catch (_) {}

    return jsonEncode(
      text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );
  }

  // NORMALIZE EXERCISE NAME
  String _normalizeExerciseName(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('°', ' degrees ')
        .replaceAll(RegExp(r'\([^)]*\)'), ' ')
        .replaceAll(RegExp(r'[\[\],:/\\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // RESOLVE GEMINI EXERCISE NAMES
  void _resolveGeminiCatalogNames(
    Map<String, dynamic> plan,
    Map<String, Map<String, String>> catalog,
  ) {
    final days = plan['days'];

    if (days is! Map) {
      return;
    }

    for (final dayEntry in days.entries) {
      final day = dayEntry.value;

      if (day is! Map) {
        continue;
      }

      final workout = day['workout'];

      if (workout is! List) {
        continue;
      }

      for (final rawExercise in workout) {
        if (rawExercise is! Map) {
          continue;
        }

        final generatedName =
            rawExercise['catalogName']?.toString().trim() ?? '';

        if (generatedName.isEmpty) {
          continue;
        }

        final resolved = _resolveSingleCatalogName(generatedName, catalog);

        if (resolved != null) {
          rawExercise['catalogName'] = resolved;
        }
      }
    }
  }

  // RESOLVE ONE NAME
  String? _resolveSingleCatalogName(
    String generatedName,
    Map<String, Map<String, String>> catalog,
  ) {
    final original = generatedName.trim().toLowerCase();

    if (original.isEmpty) {
      return null;
    }

    // ==========================================================
    // 1. EXACT MATCH
    // ==========================================================

    if (catalog.containsKey(original)) {
      return original;
    }

    // ==========================================================
    // 2. NORMALIZED MATCH
    // ==========================================================

    final normalized = _normalizeExerciseName(original);

    for (final entry in catalog.entries) {
      final candidate = _normalizeExerciseName(entry.key);

      if (candidate == normalized) {
        print(
          'Exercise normalized match: '
          '$generatedName -> ${entry.key}',
        );

        return entry.key;
      }
    }

    // ==========================================================
    // 3. EXPLICIT ALIAS MATCH
    // ==========================================================

    final aliasCandidates = _exerciseAliases(normalized);

    for (final alias in aliasCandidates) {
      final aliasNormalized = _normalizeExerciseName(alias);

      // First check exact catalog key.
      if (catalog.containsKey(aliasNormalized)) {
        print(
          'Exercise alias resolved: '
          '$generatedName -> $aliasNormalized',
        );

        return aliasNormalized;
      }

      // Then compare normalized catalog names.
      for (final entry in catalog.entries) {
        final candidate = _normalizeExerciseName(entry.key);

        if (candidate == aliasNormalized) {
          print(
            'Exercise alias resolved: '
            '$generatedName -> ${entry.key}',
          );

          return entry.key;
        }
      }
    }

    // ==========================================================
    // 4. PREFIX MATCH
    // ==========================================================

    final prefixMatches = <String>[];

    for (final entry in catalog.entries) {
      final candidate = _normalizeExerciseName(entry.key);

      if (candidate.startsWith(normalized)) {
        prefixMatches.add(entry.key);
      }
    }

    if (prefixMatches.length == 1) {
      print(
        'Exercise prefix resolved: '
        '$generatedName -> ${prefixMatches.first}',
      );

      return prefixMatches.first;
    }

    // ==========================================================
    // 5. CONTAINS MATCH
    // ==========================================================

    final containsMatches = <String>[];

    for (final entry in catalog.entries) {
      final candidate = _normalizeExerciseName(entry.key);

      if (candidate.contains(normalized)) {
        containsMatches.add(entry.key);
      }
    }

    if (containsMatches.length == 1) {
      print(
        'Exercise contains resolved: '
        '$generatedName -> ${containsMatches.first}',
      );

      return containsMatches.first;
    }

    // ==========================================================
    // 6. STRONG TOKEN MATCH
    // ==========================================================

    final generatedTokens = normalized
        .split(' ')
        .where((word) => word.length >= 3)
        .toSet();

    if (generatedTokens.isEmpty) {
      return null;
    }

    final scored = <String, double>{};

    for (final entry in catalog.entries) {
      final candidate = _normalizeExerciseName(entry.key);

      final candidateTokens = candidate
          .split(' ')
          .where((word) => word.length >= 3)
          .toSet();

      if (candidateTokens.isEmpty) {
        continue;
      }

      final overlap = generatedTokens.intersection(candidateTokens).length;

      if (overlap == 0) {
        continue;
      }

      double score = overlap.toDouble();

      // Strong bonus if the generated phrase appears
      // inside the catalog name.
      if (candidate.contains(normalized)) {
        score += 3;
      }

      // Strong bonus for exact token count.
      if (candidateTokens.length == generatedTokens.length) {
        score += 1;
      }

      scored[entry.key] = score;
    }

    if (scored.isEmpty) {
      return null;
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestScore = sorted.first.value;

    final best = sorted.where((entry) => entry.value == bestScore).toList();

    // Only accept a strong unique result.
    if (best.length == 1 && bestScore >= 3) {
      print(
        'Exercise fuzzy resolved: '
        '$generatedName -> ${best.first.key}',
      );

      return best.first.key;
    }

    print(
      'Could not safely resolve exercise: '
      '$generatedName',
    );

    return null;
  }

  List<String> _exerciseAliases(String normalized) {
    final aliases = <String>[];

    void add(String value) {
      final normalizedValue = _normalizeExerciseName(value);

      if (normalizedValue.isNotEmpty && !aliases.contains(normalizedValue)) {
        aliases.add(normalizedValue);
      }
    }

    // ==========================================================
    // SHOULDER PRESS
    // ==========================================================

    if (normalized == 'dumbbell shoulder press') {
      add('seated dumbbell shoulder press');
      add('dumbbell shoulder press seated');
      add('dumbbell shoulder press (seated)');
    }

    if (normalized == 'seated shoulder press') {
      add('seated dumbbell shoulder press');
      add('dumbbell shoulder press seated');
      add('dumbbell shoulder press (seated)');
    }

    if (normalized == 'shoulder press dumbbell') {
      add('seated dumbbell shoulder press');
      add('dumbbell shoulder press seated');
      add('dumbbell shoulder press (seated)');
    }

    if (normalized == 'dumbbell overhead press') {
      add('seated dumbbell shoulder press');
      add('dumbbell shoulder press seated');
      add('dumbbell shoulder press (seated)');
    }

    // ==========================================================
    // BENCH PRESS
    // ==========================================================

    if (normalized == 'barbell bench press') {
      add('flat bench press - barbell');
      add('flat bench press barbell');
    }

    if (normalized == 'dumbbell bench press') {
      add('flat bench press - dumbbell');
      add('flat bench press dumbbell');
    }

    if (normalized == 'incline barbell bench press') {
      add('incline bench press - barbell');
      add('incline bench press barbell');
    }

    if (normalized == 'incline dumbbell bench press') {
      add('incline bench press - dumbbell');
      add('incline bench press dumbbell');
    }

    // ==========================================================
    // SQUAT
    // ==========================================================

    if (normalized == 'barbell squat') {
      add('barbell full squat');
    }

    // ==========================================================
    // PULL UP
    // ==========================================================

    if (normalized == 'pull up') {
      add('pull-up');
    }

    if (normalized == 'pullup') {
      add('pull-up');
    }

    // ==========================================================
    // PUSH UP
    // ==========================================================

    if (normalized == 'push up') {
      add('push-up');
    }

    if (normalized == 'pushup') {
      add('push-up');
    }

    // ==========================================================
    // BICEPS
    // ==========================================================

    if (normalized == 'hammer curl') {
      add('dumbbell hammer curl');
    }

    if (normalized == 'barbell curl') {
      add('barbell biceps curl');
    }

    // ==========================================================
    // TRICEPS
    // ==========================================================

    if (normalized == 'tricep pushdown') {
      add('triceps pushdown');
      add('cable triceps pushdown');
      add('triceps pressdown');
    }

    if (normalized == 'triceps pushdown') {
      add('tricep pushdown');
      add('cable triceps pushdown');
      add('triceps pressdown');
    }

    // ==========================================================
    // LAT PULLDOWN
    // ==========================================================

    if (normalized == 'lat pulldown') {
      add('cable lat pulldown');
    }

    // ==========================================================
    // ROW
    // ==========================================================

    if (normalized == 'seated row') {
      add('seated cable row');
    }

    // ==========================================================
    // CALF
    // ==========================================================

    if (normalized == 'calf raise') {
      add('standing calf raise');
      add('seated calf raise');
    }

    // ==========================================================
    // HAMSTRING
    // ==========================================================

    if (normalized == 'hamstring curl') {
      add('lying leg curl');
      add('seated leg curl');
    }

    return aliases;
  }

  // KNOWN EXERCISE ALIASES
  String? _knownExerciseAlias(String normalized) {
    const aliases = <String, List<String>>{
      // ==========================================================
      // SHOULDER
      // ==========================================================
      'dumbbell shoulder press': [
        'seated dumbbell shoulder press',
        'dumbbell shoulder press seated',
        'dumbbell shoulder press (seated)',
      ],

      'seated shoulder press': [
        'seated dumbbell shoulder press',
        'dumbbell shoulder press seated',
        'dumbbell shoulder press (seated)',
      ],

      'seated dumbbell press': [
        'seated dumbbell shoulder press',
        'dumbbell shoulder press seated',
        'dumbbell shoulder press (seated)',
      ],

      'dumbbell overhead press': [
        'seated dumbbell shoulder press',
        'dumbbell shoulder press seated',
        'dumbbell shoulder press (seated)',
      ],

      'shoulder press dumbbell': [
        'seated dumbbell shoulder press',
        'dumbbell shoulder press seated',
        'dumbbell shoulder press (seated)',
      ],

      // ==========================================================
      // BENCH PRESS
      // ==========================================================
      'barbell bench press': [
        'flat bench press - barbell',
        'barbell bench press',
      ],

      'dumbbell bench press': [
        'flat bench press - dumbbell',
        'dumbbell bench press',
      ],

      'incline barbell bench press': ['incline bench press - barbell'],

      'incline dumbbell bench press': ['incline bench press - dumbbell'],

      // ==========================================================
      // SQUAT
      // ==========================================================
      'barbell squat': ['barbell full squat', 'barbell squat'],

      'squat': ['barbell full squat', 'barbell squat'],

      // ==========================================================
      // PULL UPS
      // ==========================================================
      'pull up': ['pull-up'],

      'pullup': ['pull-up'],

      // ==========================================================
      // PUSH UPS
      // ==========================================================
      'push up': ['push-up'],

      'pushup': ['push-up'],

      // ==========================================================
      // BICEPS
      // ==========================================================
      'hammer curl': ['dumbbell hammer curl', 'hammer curl'],

      'dumbbell hammer curl': ['dumbbell hammer curl', 'hammer curl'],

      'barbell curl': ['barbell biceps curl', 'barbell curl'],

      'barbell biceps curl': ['barbell biceps curl', 'barbell curl'],

      // ==========================================================
      // TRICEPS
      // ==========================================================
      'tricep pushdown': [
        'triceps pushdown',
        'cable triceps pushdown',
        'triceps pressdown',
      ],

      'triceps pushdown': [
        'triceps pushdown',
        'cable triceps pushdown',
        'triceps pressdown',
      ],

      'triceps pressdown': [
        'triceps pushdown',
        'cable triceps pushdown',
        'triceps pressdown',
      ],

      // ==========================================================
      // LAT PULLDOWN
      // ==========================================================
      'lat pulldown': ['lat pulldown', 'cable lat pulldown'],

      'cable lat pulldown': ['cable lat pulldown', 'lat pulldown'],

      // ==========================================================
      // ROW
      // ==========================================================
      'seated row': ['seated cable row', 'seated row'],

      'seated cable row': ['seated cable row', 'seated row'],

      // ==========================================================
      // CALVES
      // ==========================================================
      'calf raise': ['standing calf raise', 'seated calf raise', 'calf raise'],

      'standing calf raise': ['standing calf raise', 'calf raise'],

      // ==========================================================
      // LEG
      // ==========================================================
      'leg extension': ['leg extension'],

      'hamstring curl': ['lying leg curl', 'seated leg curl', 'leg curl'],
    };

    final candidates = aliases[normalized];

    if (candidates == null) {
      return null;
    }

    for (final candidate in candidates) {
      final candidateNormalized = _normalizeExerciseName(candidate);

      // The alias itself must actually exist in the
      // current Supabase catalog.
      returnCandidate:
      if (candidateNormalized.isNotEmpty) {
        return candidateNormalized;
      }
    }

    return null;
  }

  // PARSE GEMINI RESPONSE
  Map<String, dynamic> _parseGeminiResponse(http.Response response) {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(response.body));

      final candidates = data['candidates'];

      if (candidates is! List || candidates.isEmpty) {
        throw Exception('Gemini returned no candidates.');
      }

      final candidate = candidates.first;

      if (candidate is! Map) {
        throw Exception('Invalid Gemini candidate.');
      }

      final finishReason = candidate['finishReason']?.toString();

      print(
        'Workout Gemini finishReason: '
        '$finishReason',
      );

      if (finishReason == 'MAX_TOKENS') {
        throw Exception(
          'Gemini stopped because the '
          'response reached the output limit. '
          'The workout response was incomplete.',
        );
      }

      final content = candidate['content'];

      if (content is! Map) {
        throw Exception('Gemini response has no content.');
      }

      final parts = content['parts'];

      if (parts is! List || parts.isEmpty) {
        throw Exception('Gemini response has no parts.');
      }

      final buffer = StringBuffer();

      for (final part in parts) {
        if (part is Map && part['text'] != null) {
          buffer.write(part['text'].toString());
        }
      }

      final rawText = buffer.toString().trim();

      if (rawText.isEmpty) {
        throw Exception('Gemini returned an empty workout plan.');
      }

      final cleaned = _cleanJson(rawText);

      dynamic decoded;

      try {
        decoded = jsonDecode(cleaned);
      } catch (e) {
        print(
          'Gemini JSON length: '
          '${cleaned.length}',
        );

        final previewStart = cleaned.length > 300
            ? cleaned.substring(cleaned.length - 300)
            : cleaned;

        print(
          'End of Gemini response:\n'
          '$previewStart',
        );

        rethrow;
      }

      if (decoded is! Map) {
        throw Exception('Gemini returned invalid workout JSON.');
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      if (e is Exception && e.toString().startsWith('Exception:')) {
        rethrow;
      }

      throw Exception(
        'Could not parse Gemini workout JSON.\n'
        'Error: $e',
      );
    }
  }

  // CLEAN JSON
  String _cleanJson(String text) {
    var cleaned = text.trim();

    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    return cleaned.trim();
  }

  // GENERATE SUBSTITUTE EXERCISES
  void _generateSubstituteExercises(
    Map<String, dynamic> plan,
    Map<String, Map<String, String>> catalog,
  ) {
    final days = plan['days'];

    if (days is! Map) {
      return;
    }

    for (final dayEntry in days.entries) {
      final day = dayEntry.value;

      if (day is! Map) {
        continue;
      }

      final workout = day['workout'];

      if (workout is! List) {
        continue;
      }

      for (final rawExercise in workout) {
        if (rawExercise is! Map) {
          continue;
        }

        final mainName = rawExercise['catalogName']?.toString().trim() ?? '';

        if (mainName.isEmpty) {
          continue;
        }

        final mainData = catalog[mainName];

        if (mainData == null) {
          continue;
        }

        final mainTargetMuscles = _decodeList(mainData['target_muscles']);

        final mainBodyParts = _decodeList(mainData['body_parts']);

        final mainEquipment = _decodeList(mainData['equipments']);

        final candidates = <Map<String, String>>[];

        for (final entry in catalog.entries) {
          final candidateName = entry.key;

          final candidate = entry.value;

          // Never use the same exercise.
          if (candidateName == mainName) {
            continue;
          }

          final candidateTargetMuscles = _decodeList(
            candidate['target_muscles'],
          );

          final candidateBodyParts = _decodeList(candidate['body_parts']);

          final candidateEquipment = _decodeList(candidate['equipments']);

          int score = 0;

          // Same target muscle.
          if (_hasOverlap(mainTargetMuscles, candidateTargetMuscles)) {
            score += 5;
          }

          // Same body part.
          if (_hasOverlap(mainBodyParts, candidateBodyParts)) {
            score += 3;
          }

          // Similar equipment.
          if (_hasOverlap(mainEquipment, candidateEquipment)) {
            score += 1;
          }

          if (score > 0) {
            candidates.add({
              'catalogName': candidateName,
              '_score': score.toString(),
            });
          }
        }

        candidates.sort((a, b) {
          final scoreA = int.tryParse(a['_score'] ?? '0') ?? 0;

          final scoreB = int.tryParse(b['_score'] ?? '0') ?? 0;

          return scoreB.compareTo(scoreA);
        });

        final selected = <Map<String, String>>[];

        final used = <String>{};

        for (final candidate in candidates) {
          if (selected.length >= 2) {
            break;
          }

          final name = candidate['catalogName'];

          if (name == null) {
            continue;
          }

          if (used.contains(name)) {
            continue;
          }

          used.add(name);

          selected.add({'catalogName': name});
        }

        rawExercise['substituteExercises'] = selected;
      }
    }
  }

  // OVERLAP
  bool _hasOverlap(List<String> first, List<String> second) {
    if (first.isEmpty || second.isEmpty) {
      return false;
    }

    final firstSet = first.map((e) => e.trim().toLowerCase()).toSet();

    for (final value in second) {
      if (firstSet.contains(value.trim().toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  // VALIDATE WORKOUT PLAN
  void _validateWorkoutPlan(
    Map<String, dynamic> plan,
    Map<String, Map<String, String>> catalog,
  ) {
    final days = plan['days'];

    if (days is! Map) {
      throw Exception('Workout plan does not contain days.');
    }

    const requiredDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (final dayName in requiredDays) {
      if (!days.containsKey(dayName)) {
        throw Exception(
          'Workout plan is missing '
          '$dayName.',
        );
      }

      final day = days[dayName];

      if (day is! Map) {
        throw Exception(
          'Invalid data for '
          '$dayName.',
        );
      }

      final isRestDay = day['restDay'] == true;

      final workout = day['workout'];

      if (isRestDay) {
        if (workout is List && workout.isNotEmpty) {
          throw Exception(
            '$dayName is marked as '
            'rest day but contains '
            'exercises.',
          );
        }

        continue;
      }

      if (workout is! List) {
        throw Exception(
          '$dayName has no valid '
          'workout list.',
        );
      }

      for (final exercise in workout) {
        if (exercise is! Map) {
          throw Exception(
            'Invalid exercise on '
            '$dayName.',
          );
        }

        final catalogName = exercise['catalogName']?.toString().trim() ?? '';

        if (catalogName.isEmpty) {
          throw Exception(
            'Missing catalogName '
            'on $dayName.',
          );
        }

        // At this point the name should already
        // be resolved.
        if (!catalog.containsKey(catalogName)) {
          throw Exception(
            'Exercise could not be '
            'matched with Supabase:\n'
            '$catalogName\n'
            'Day: $dayName',
          );
        }
      }
    }
  }

  // ENRICH WORKOUT PLAN
  void _enrichWorkoutPlan(
    Map<String, dynamic> plan,
    Map<String, Map<String, String>> catalog,
  ) {
    final days = plan['days'];

    if (days is! Map) {
      return;
    }

    for (final entry in days.entries) {
      final day = entry.value;

      if (day is! Map) {
        continue;
      }

      final workout = day['workout'];

      if (workout is! List) {
        continue;
      }

      for (final rawExercise in workout) {
        if (rawExercise is! Map) {
          continue;
        }

        final catalogName = rawExercise['catalogName']?.toString().trim() ?? '';

        final catalogData = catalog[catalogName];

        if (catalogData == null) {
          continue;
        }

        final exerciseName = catalogData['exercise_name'] ?? '';

        rawExercise['exerciseName'] = exerciseName.isNotEmpty
            ? exerciseName
            : catalogName;

        rawExercise['exerciseId'] = catalogData['exercise_db_id'] ?? '';

        rawExercise['gifUrl'] = catalogData['gif_url'] ?? '';

        rawExercise['bodyParts'] = _decodeList(catalogData['body_parts']);

        rawExercise['targetMuscles'] = _decodeList(
          catalogData['target_muscles'],
        );

        rawExercise['secondaryMuscles'] = _decodeList(
          catalogData['secondary_muscles'],
        );

        rawExercise['equipment'] = _decodeList(catalogData['equipments']);

        rawExercise['catalogInstructions'] = _decodeList(
          catalogData['instructions'],
        );

        rawExercise['catalogSecondaryMuscles'] = _decodeList(
          catalogData['secondary_muscles'],
        );

        final alternatives = rawExercise['substituteExercises'];

        if (alternatives is List) {
          for (final rawAlternative in alternatives) {
            if (rawAlternative is! Map) {
              continue;
            }

            final alternativeName =
                rawAlternative['catalogName']?.toString().trim() ?? '';

            final alternativeData = catalog[alternativeName];

            if (alternativeData == null) {
              continue;
            }

            rawAlternative['exerciseName'] =
                alternativeData['exercise_name']?.isNotEmpty == true
                ? alternativeData['exercise_name']
                : alternativeName;
          }
        }
      }
    }
  }

  // DECODE LIST
  List<String> _decodeList(String? value) {
    if (value == null || value.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    return [];
  }

  // GEMINI PROMPT
  String _buildPrompt(UserProfileModel profile, List<String> catalogNames) {
    final catalog = jsonEncode(catalogNames);

    return '''
You are FitNova's evidence-based fitness coach.

Create a personalized 7-day workout plan using ONLY exercises from the supplied Supabase catalog.

USER:
name=${profile.fullName}
age=${profile.age}
gender=${profile.gender}
height=${profile.height}cm
weight=${profile.weight}kg
goal=${profile.goal}
targetWeight=${profile.targetWeight}
duration=${profile.durationMonths}
muscleGain=${profile.muscleGainTarget}
strengthGoal=${profile.strengthGoal}
primaryLift=${profile.primaryLift}
repRange=${profile.repRange}
enduranceGoal=${profile.enduranceGoal}
cardio=${profile.cardioPreference}
fitnessGoals=${profile.fitnessGoals.join(', ')}
workoutPlace=${profile.workoutPlace}
sport=${profile.sportName}
performanceGoals=${profile.performanceGoals.join(', ')}
competition=${profile.competitionLevel}
workoutDays=${profile.workoutDays}
activity=${profile.activityLevel}
comments=${profile.comments}
sleep=${profile.sleepHours}
preferredExercise=${profile.exercise}
location=${profile.workoutPrefer}
workoutTime=${profile.workoutTime}
equipment=${profile.equipmentPrefer}
split=${profile.split}
customsplit=${profile.customSplit} use this if the split is custom
bodyType=${profile.bodyType}
bodyGoal=${profile.bodyGoal}
experience=${profile.fitnessLevel}

Give special attention and more focus on the medical records and based on the medical records give the workout plan so that user should not get injured or their medical issues occur more.
medicalRecords=${profile.medical}

Use only fields relevant to the selected goal.

Respect:
- fitness level
- available equipment
- workout location
- selected workout days
- recovery
- user preferences
- workout split
- user's goal

Create exactly these seven days:

Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
Sunday

Only the user's selected workout days may contain workouts.

All other days must have:

restDay=true
workout=[]

Programming must be realistic and evidence-based.

Consider:
- goal
- volume
- intensity
- frequency
- recovery
- exercise order
- progressive overload
- movement balance

Avoid unsafe or unnecessarily advanced programming.

====================================================
STRICT CATALOG RULE
====================================================

Every main exercise MUST use a catalogName copied EXACTLY from the supplied catalog.

DO NOT:
- invent an exercise
- shorten an exercise name
- paraphrase an exercise name
- remove words
- change punctuation
- replace the catalog name with a generic name
- create your own exercise name

For example:

WRONG:
"sled 45"

WRONG:
"leg press"

WRONG:
"45 degree leg press"

ONLY use an exact catalog value such as:
"sled 45° leg press"

The catalogName must be copied character-for-character from the supplied catalog.

====================================================
CATALOG
====================================================

$catalog

====================================================
WORKOUT EXERCISE OUTPUT
====================================================

For every workout exercise return ONLY:

catalogName
sets
reps
duration
rest
tempo
difficulty
instructions
precautions
commonMistakes
substituteExercises
tips

Keep text short.

instructions:
2-3 short items

precautions:
0-2 short items

commonMistakes:
0-2 short items

tips:
0-2 short items

DO NOT generate substituteExercises.

Always return:

"substituteExercises": []

The application will automatically select exactly two substitute exercises from the Supabase catalog.

Do NOT generate:
- exercise IDs
- GIF URLs
- body parts
- target muscles
- secondary muscles
- equipment
- database instructions

Supabase supplies those.

Warm-up, stretching and cooldown should also be concise.

Every day needs one short scientificEvidence statement based on accepted training principles.

Do not invent:
- studies
- researchers
- statistics
- citations

For big muscles give 4 or more than 4 exercises and for small muscles give 2 or 3 exercises.

Big muscles include: 
- chest
- back
- shoulder 
- leg
Small muscles include:
- biceps
- triceps
- forearms
- abs

Give the main workout exercise in the proper sequence on complete muscle not the mixture of all muscles (e.g. 1. chest 2. shoulder 3. triceps 4. shoulder 5. chest etc) 

For upper split:
give at least 2-3 exercises for each relevant upper body part:
- chest
- back
- shoulder
- bicep
- tricep

For lower split:
give at least 2-3 exercises for relevant lower body parts:
- hamstrings
- quads
- glutes
- calves
- abs
- forearms

For cardio split:
include appropriate:
- bodyweight cardio
- machine cardio
- treadmill
- elliptical
- cycling
- cross-training/cardio

Rest days:

restDay=true
workout=[]

activity, recoveryTips, stretching and notes should be concise.

====================================================
JSON STRUCTURE
====================================================

Return ONLY valid JSON.

{
  "note": "",
  "days": {
    "Monday": {
      "dayName": "Monday",
      "focus": "",
      "estimatedDuration": "",
      "difficulty": "",
      "restDay": false,
      "activity": "",
      "recoveryTips": [],
      "warmUp": [],
      "workout": [],
      "stretching": [],
      "coolDown": [],
      "motivation": "",
      "scientificEvidence": ""
    },
    "Tuesday": {},
    "Wednesday": {},
    "Thursday": {},
    "Friday": {},
    "Saturday": {},
    "Sunday": {}
  }
}

Use the same complete structure for all seven days.

Before returning, verify:

- all 7 days exist
- days are Monday through Sunday
- workout days match the user's selected days
- rest days have workout=[]
- every catalogName exists EXACTLY in the supplied catalog
- substituteExercises=[]
- no database information is invented
- no GIF information is invented
- JSON is complete
- JSON is valid

Return no markdown.
Return no code fences.
''';
  }
}
