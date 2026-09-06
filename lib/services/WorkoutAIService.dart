import 'dart:convert';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutAIService {
  WorkoutAIService();

  String get workoutApiKey => dotenv.get('GEMINI_API_KEY_WORKOUT');

  static const String _model = 'gemini-2.5-flash';

  // The new response is intentionally compact, so 15k tokens is
  // normally more than enough.
  static const int _maxOutputTokens = 50000;

  static const Duration _requestTimeout = Duration(minutes: 3);

  final SupabaseClient _supabase = Supabase.instance.client;

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
      final normalized = exercise['normalized_name']?.trim() ?? '';

      if (normalized.isEmpty) continue;

      catalogMap[normalized] = exercise;
    }

    final prompt = _buildPrompt(profile, catalogNames);

    final response = await _callGemini(prompt);

    final workoutPlan = _parseGeminiResponse(response);

    _validateWorkoutPlan(workoutPlan, catalogMap);

    _enrichWorkoutPlan(workoutPlan, catalogMap);

    return workoutPlan;
  }

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
          'Workout Gemini attempt $attempt '
          'completed in ${stopwatch.elapsed.inSeconds}s '
          'with status ${response.statusCode}.',
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
          'Gemini Error (${response.statusCode}): '
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
              'Workout generation timed out after '
              '${_requestTimeout.inMinutes} minutes.',
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

  Future<List<Map<String, String>>> _getExerciseCatalog() async {
    try {
      final response = await _supabase
          .from('exercise_catalog')
          .select(
            'exercise_name, normalized_name, exercise_db_id, '
            'gif_url, body_parts, equipments, target_muscles, '
            'secondary_muscles, instructions',
          )
          .order('normalized_name');

      final List<Map<String, String>> catalog = [];

      final Set<String> seen = {};

      for (final row in response) {
        final normalized = row['normalized_name']?.toString().trim() ?? '';

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

      return catalog;
    } catch (e) {
      throw Exception(
        'Failed to load exercise catalog from Supabase.\n'
        'Error: $e',
      );
    }
  }

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
          'Gemini stopped because the response reached '
          'the output limit. The workout response was incomplete.',
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
        print('Gemini JSON length: ${cleaned.length}');

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
        throw Exception('Workout plan is missing $dayName.');
      }

      final day = days[dayName];

      if (day is! Map) {
        throw Exception('Invalid data for $dayName.');
      }

      final isRestDay = day['restDay'] == true;

      final workout = day['workout'];

      if (isRestDay) {
        if (workout is List && workout.isNotEmpty) {
          throw Exception(
            '$dayName is marked as rest day '
            'but contains exercises.',
          );
        }

        continue;
      }

      if (workout is! List) {
        throw Exception('$dayName has no valid workout list.');
      }

      for (final exercise in workout) {
        if (exercise is! Map) {
          throw Exception('Invalid exercise on $dayName.');
        }

        final catalogName = exercise['catalogName']?.toString().trim() ?? '';

        if (catalogName.isEmpty) {
          throw Exception('Missing catalogName on $dayName.');
        }

        if (!catalog.containsKey(catalogName)) {
          throw Exception(
            'Gemini returned an exercise that does '
            'not exist in Supabase:\n'
            '$catalogName\n'
            'Day: $dayName',
          );
        }

        final alternatives = exercise['substituteExercises'];

        if (alternatives is! List || alternatives.length != 2) {
          throw Exception(
            '$catalogName on $dayName must have '
            'exactly two alternatives.',
          );
        }

        final alternativeNames = <String>{};

        for (final alternative in alternatives) {
          if (alternative is! Map) {
            throw Exception('Invalid alternative on $dayName.');
          }

          final alternativeName =
              alternative['catalogName']?.toString().trim() ?? '';

          if (alternativeName.isEmpty) {
            throw Exception(
              'Alternative is missing catalogName '
              'on $dayName.',
            );
          }

          if (!catalog.containsKey(alternativeName)) {
            throw Exception(
              'Invalid alternative exercise:\n'
              '$alternativeName\n'
              'Day: $dayName',
            );
          }

          if (alternativeName == catalogName) {
            throw Exception(
              'Alternative cannot be the same '
              'as the main exercise:\n'
              '$catalogName',
            );
          }

          if (!alternativeNames.add(alternativeName)) {
            throw Exception(
              'The two alternatives must be different:\n'
              '$catalogName',
            );
          }
        }
      }
    }
  }

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
bodyType=${profile.bodyType}
bodyGoal=${profile.bodyGoal}
experience=${profile.fitnessLevel}

Use only fields relevant to the selected goal. Respect experience, available equipment, workout location, selected days, recovery and user preferences.

Create exactly these seven days:
Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.
in the same sequence of days

Only the user's selected workout days may contain workouts. Other days must have restDay=true and workout=[].

Programming must be realistic and evidence-based. Consider goal, volume, intensity, frequency, recovery, exercise order, progressive overload and movement balance. Avoid unsafe or unnecessarily advanced programming.

CATALOG RULE:
Every main exercise and every alternative MUST use an exact catalogName from this list. Never invent, rewrite, shorten or modify catalogName.

CATALOG:
$catalog

For every workout exercise return ONLY:
catalogName, sets, reps, duration, rest, tempo, difficulty, instructions, precautions, commonMistakes, substituteExercises, tips.

Keep text short:
instructions: 2-3 short items
precautions: 0-2 short items
commonMistakes: 0-2 short items
tips: 0-2 short items

Every exercise MUST have exactly TWO different substituteExercises. Each substitute contains only catalogName.

Do NOT generate exercise IDs, GIF URLs, body parts, target muscles, secondary muscles, equipment or database instructions. Supabase supplies those.

Warm-up, stretching and cooldown should also be concise.

Every day needs one short scientificEvidence statement based on accepted training principles. Do not invent studies, researchers, statistics or citations.

Rest days:
restDay=true
workout=[]
activity, recoveryTips, stretching, notes should be concise.

Return ONLY valid JSON.

Use this compact structure:

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
      "warmUp": [
    {
      "bodyPart": "",
      "exerciseId": "",
      "exerciseName": "",
      "duration": "",
      "instructions": []
    }
  ],

  "workout": [
    {
      "exerciseId": "",
      "catalogName": "",
      "exerciseName": "",
      "exerciseType": "",
      "exerciseOrder": "1",
      "isCompound": true,
      "muscleGroup": "",
      "secondaryMuscles": [],
      "sets": "",
      "reps": "",
      "duration": "",
      "rest": "",
      "tempo": "",
      "difficulty": "",
      "instructions": [],
      "precautions": [],
      "commonMistakes": [],

      "substituteExercises": [
        {
          "catalogName": "",
        },
        {
          "catalogName": "",
        }
      ],

      "tips": []
    }
  ],

  "stretching": [
    {
      "bodyPart": "",
      "exerciseId": "",
      "exerciseName": "",
      "duration": "",
      "instructions": []
    }
  ],

  "coolDown": [
    {
      "exerciseId": "",
      "exerciseName": "",
      "duration": "",
      "instructions": []
    }
  ],
      "motivation": "",
    }
  }
}

Use the same structure for all seven days.

Before returning, verify:
- all 7 days exist
- workout days match the user's selected days
- rest days have workout=[]
- every catalogName exists exactly in the catalog
- every exercise has exactly 2 different alternatives
- every alternative exists exactly in the catalog
- no database/GIF information is invented
- JSON is complete and valid

Return no markdown and no code fences.
''';
  }
}
