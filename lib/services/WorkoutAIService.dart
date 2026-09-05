import 'dart:convert';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutAIService {
  WorkoutAIService();

  String get workoutApiKey => dotenv.get('GEMINI_API_KEY_WORKOUT');

  static const String _model = 'gemini-2.5-flash';

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // GENERATE WORKOUT PLAN
  // ============================================================

  Future<Map<String, dynamic>> generateWorkoutPlan(
    UserProfileModel profile,
  ) async {
    // ----------------------------------------------------------
    // FETCH COMPLETE EXERCISE CATALOG
    // ----------------------------------------------------------
    //
    // We only fetch:
    //
    // normalized_name
    // exercise_name
    //
    // We do NOT send GIF URLs, instructions, muscles, IDs etc.
    // to Gemini.
    //
    // Supabase remains the authoritative source for those fields.
    // ----------------------------------------------------------

    final catalog = await _getExerciseCatalog();

    if (catalog.isEmpty) {
      throw Exception(
        'Exercise catalog is empty. '
        'Please make sure exercise_catalog contains exercises '
        'and that Supabase SELECT access is enabled.',
      );
    }

    // Convert the catalog into a compact text block for Gemini.
    final catalogText = _formatCatalogForPrompt(catalog);

    final prompt = _buildPrompt(profile, catalogText, catalog.length);

    // ----------------------------------------------------------
    // GEMINI API
    // ----------------------------------------------------------

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:generateContent?key=$workoutApiKey',
    );

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
              'temperature': 0.30,
              'responseMimeType': 'application/json',
            },
          }),
        )
        .timeout(const Duration(seconds: 90));

    // ----------------------------------------------------------
    // ERROR HANDLING
    // ----------------------------------------------------------

    if (response.statusCode == 503) {
      throw Exception(
        'Gemini servers are busy. Please try again in a few moments.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini Error (${response.statusCode}): ${response.body}',
      );
    }

    // ----------------------------------------------------------
    // PARSE GEMINI RESPONSE
    // ----------------------------------------------------------

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    final candidates = data['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini returned no workout plan.');
    }

    final firstCandidate = candidates.first;

    if (firstCandidate is! Map) {
      throw Exception('Invalid Gemini candidate response.');
    }

    final content = firstCandidate['content'];

    if (content is! Map) {
      throw Exception('Gemini response does not contain content.');
    }

    final parts = content['parts'];

    if (parts is! List || parts.isEmpty) {
      throw Exception('Gemini response does not contain text.');
    }

    final firstPart = parts.first;

    if (firstPart is! Map) {
      throw Exception('Invalid Gemini response part.');
    }

    final rawText = firstPart['text']?.toString().trim() ?? '';

    if (rawText.isEmpty) {
      throw Exception('Gemini returned an empty workout plan.');
    }

    // ----------------------------------------------------------
    // CLEAN JSON
    // ----------------------------------------------------------

    final cleanedJson = _cleanJson(rawText);

    try {
      final decoded = jsonDecode(cleanedJson);

      if (decoded is! Map) {
        throw Exception('Gemini returned an invalid JSON structure.');
      }

      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      throw Exception(
        'Could not parse Gemini workout JSON.\n\n'
        'Response:\n$rawText\n\n'
        'Error: $e',
      );
    }
  }

  // ============================================================
  // FETCH EXERCISE CATALOG
  // ============================================================

  Future<List<Map<String, String>>> _getExerciseCatalog() async {
    try {
      final response = await _supabase
          .from('exercise_catalog')
          .select('exercise_name, normalized_name')
          .order('normalized_name');

      // if (response is! List) {
      //   throw Exception('Invalid exercise catalog response.');
      // }

      final List<Map<String, String>> catalog = [];

      final Set<String> seenNormalizedNames = {};

      for (final row in response) {
        // if (row is! Map) {
        //   continue;
        // }

        final normalizedName = row['normalized_name']?.toString().trim() ?? '';

        final exerciseName = row['exercise_name']?.toString().trim() ?? '';

        if (normalizedName.isEmpty) {
          continue;
        }

        // Avoid sending duplicate normalized names.
        if (seenNormalizedNames.contains(normalizedName)) {
          continue;
        }

        seenNormalizedNames.add(normalizedName);

        catalog.add({
          'normalized_name': normalizedName,
          'exercise_name': exerciseName.isEmpty ? normalizedName : exerciseName,
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

  // ============================================================
  // FORMAT CATALOG FOR GEMINI
  // ============================================================

  String _formatCatalogForPrompt(List<Map<String, String>> catalog) {
    final buffer = StringBuffer();

    for (final exercise in catalog) {
      final normalized = exercise['normalized_name'] ?? '';

      final display = exercise['exercise_name'] ?? '';

      buffer.writeln('$normalized | $display');
    }

    return buffer.toString().trim();
  }

  // ============================================================
  // JSON CLEANING
  // ============================================================

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

  // ============================================================
  // GEMINI PROMPT
  // ============================================================

  String _buildPrompt(
    UserProfileModel profile,
    String catalogText,
    int catalogCount,
  ) {
    return '''
You are an experienced evidence-based fitness coach, strength and conditioning specialist, and workout programmer.

Your task is to create a personalized ONE-WEEK workout PROGRAM for the user.

====================================================
IMPORTANT APPLICATION ARCHITECTURE
====================================================

This application contains a large ExerciseDB catalog in Supabase.

Supabase table:
exercise_catalog

Supabase is the AUTHORITATIVE SOURCE for ExerciseDB exercise information.

The application will automatically use the catalogName returned by you to locate the exact exercise record in Supabase.

Supabase will provide:

- ExerciseDB ID
- GIF URL
- body parts
- target muscles
- secondary muscles
- equipment
- ExerciseDB instructions
- other catalog information

Your responsibility is:

- workout programming
- exercise selection
- coaching
- sets
- reps
- duration
- rest
- tempo
- instructions
- precautions
- alternatives
- scientific evidence guidance

====================================================
DO NOT GENERATE EXERCISEDB DATA
====================================================

DO NOT generate:

- ExerciseDB IDs
- GIF URLs
- body parts from ExerciseDB
- target muscles from ExerciseDB
- secondary muscles from ExerciseDB
- ExerciseDB equipment
- ExerciseDB instructions

The application will retrieve those details from Supabase.

====================================================
USER PROFILE
====================================================

Name:
${profile.fullName}

Age:
${profile.age}

Gender:
${profile.gender}

Height:
${profile.height} cm

Weight:
${profile.weight} kg

Goal:
${profile.goal}

Target Weight:
${profile.targetWeight}

Duration:
${profile.durationMonths} months

Muscle Gain Target:
${profile.muscleGainTarget}

Strength Goal:
${profile.strengthGoal}

Primary Lift:
${profile.primaryLift}

Rep Range:
${profile.repRange}

Endurance Goal:
${profile.enduranceGoal}

Cardio Preference:
${profile.cardioPreference}

Fitness Goals:
${profile.fitnessGoals.join(", ")}

Workout Place:
${profile.workoutPlace}

Sport Name:
${profile.sportName}

Performance Goals:
${profile.performanceGoals.join(", ")}

Competition Level:
${profile.competitionLevel}

Selected Workout Days:
${profile.workoutDays}

Activity Level:
${profile.activityLevel}

Comments:
${profile.comments}

Sleep Hours:
${profile.sleepHours}

Daily Water Intake:
${profile.waterIntake}

Preferred Exercise:
${profile.exercise}

Workout Location:
${profile.workoutPrefer}

Wake Up Time:
${profile.wakeUp}

Job:
${profile.job}

Job Time:
${profile.officeTime}

Break Time:
${profile.breakTime}

Workout Time:
${profile.workoutTime}

Equipment Preference:
${profile.equipmentPrefer}

Workout Split Preference:
${profile.split}

====================================================
FITNESS PROFILE
====================================================

Body Type:
${profile.bodyType}

Body Goal:
${profile.bodyGoal}

Fitness Experience:
${profile.fitnessLevel}

====================================================
SUPABASE EXERCISE CATALOG
====================================================

The following catalog was retrieved directly from:

Supabase table:
exercise_catalog

Total catalog entries supplied:
$catalogCount

Each line has this format:

normalized_name | exercise_name

The first value is the AUTHORITATIVE MATCHING NAME.

The second value is the human-readable exercise name.

====================================================
CATALOG
====================================================

$catalogText

====================================================
ABSOLUTE EXERCISE CATALOG RULE
====================================================

THIS IS EXTREMELY IMPORTANT.

For EVERY MAIN WORKOUT exercise:

1. You MUST select the exercise from the supplied catalog.

2. You MUST NOT invent a main workout exercise that is
not present in the catalog.

3. You MUST return the exact normalized_name from the catalog
in the "catalogName" field.

4. You MUST return the corresponding human-readable
exercise_name in the "exerciseName" field whenever available.

5. Do NOT modify catalogName.

6. Do NOT capitalize, shorten, expand, rewrite, or paraphrase
catalogName.

7. Do NOT add sets, reps, equipment, muscle groups, or
descriptions to catalogName.

8. Do NOT create fictional exercise names.

9. Do NOT combine multiple exercises into one exercise.

10. Do NOT return an exerciseName that corresponds to a
different catalogName.

11. catalogName must correspond to the same exercise as
exerciseName.

12. If there are multiple suitable catalog entries, select
the one that best fits the user's:

- goal
- fitness level
- equipment
- workout location
- workout split
- selected workout days
- experience

====================================================
CATALOG MATCHING EXAMPLE
====================================================

Suppose the catalog contains:

barbell bench press | Barbell Bench Press

Then return:

"catalogName": "barbell bench press",
"exerciseName": "Barbell Bench Press"

NOT:

"catalogName": "Barbell Chest Press"

NOT:

"catalogName": "barbell bench press 4x10"

NOT:

"catalogName": "ultimate chest builder"

====================================================
IMPORTANT DISPLAY NAME RULE
====================================================

The catalogName is for database matching.

The exerciseName is for the application display.

Therefore:

catalogName:
must be copied exactly from the supplied catalog.

exerciseName:
should be the corresponding human-readable catalog exercise_name.

Do NOT invent a different exerciseName.

====================================================
PRIMARY EXERCISE LIBRARY
====================================================

The catalog supplied above is the PRIMARY and AUTHORITATIVE
exercise library.

You MUST strongly prefer exercises from this catalog.

Use catalog exercises for the main workout.

Do NOT randomly invent exercises.

Do NOT use obscure fictional exercise names.

====================================================
EXERCISE SELECTION RULE
====================================================

VERY IMPORTANT:

Use exercises from the supplied Supabase catalog for the
main workout.

Select exercises based on:

- user's goal
- user's fitness level
- user's equipment
- workout location
- workout split
- selected workout days
- muscle recovery
- movement patterns
- training experience

Do not select an exercise merely because its name sounds
appropriate.

It must exist in the supplied catalog.

====================================================
EXERCISE DATABASE MATCHING
====================================================

The application will match:

catalogName

against:

Supabase exercise_catalog.normalized_name

Therefore:

1. catalogName MUST exactly equal a supplied normalized_name.

2. Never modify catalogName.

3. Never add sets or reps to catalogName.

4. Never add equipment descriptions to catalogName.

5. Never add explanations to catalogName.

6. Never use a fictional catalogName.

7. Never provide ExerciseDB ID.

8. Keep exerciseId as an empty string.

====================================================
PROGRAM RULES
====================================================

1. Create ONLY a 7-day workout plan.

2. Keep these day keys EXACTLY:

Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
Sunday

3. Generate workouts ONLY on the user's selected workout days.

4. Remaining days must be Recovery or Rest Days.

5. Do not use the current date to rename days.

6. Respect:

- Goal
- Body Type
- Body Goal
- Fitness Experience
- Activity Level
- Workout Location
- Equipment Preference
- Workout Split
- Selected Workout Days

7. If the user trains at home:

- use only available equipment
- use bodyweight where appropriate
- never require unavailable gym machines

8. If the user trains at a gym:

- gym equipment may be used according to equipment preference

9. Do not train the same major muscle group excessively
on consecutive days.

10. Use realistic training volume.

11. Use progressive overload where appropriate.

12. Adjust intensity according to fitness experience.

13. Beginners must not receive unnecessarily advanced
or unsafe exercises.

14. Do not create excessively long workouts.

15. Use practical gym programming.

====================================================
GOAL-SPECIFIC PROGRAMMING
====================================================

Use these fields according to the user's goal.

For Build Muscle:

- Muscle Gain Target
- Body Goal
- Fitness Experience

For Strength / Power:

- Strength Goal
- Primary Lift
- Rep Range

For Endurance:

- Endurance Goal
- Cardio Preference

For General Fitness:

- Fitness Goals
- Workout Place

For Athletic Performance:

- Sport Name
- Performance Goals
- Competition Level

Ignore goal-specific fields that are unrelated to the
user's selected goal.

====================================================
MAIN WORKOUT EXERCISE FIELDS
====================================================

For every main workout exercise provide:

exerciseId
catalogName
exerciseName
exerciseType
exerciseOrder
isCompound
muscleGroup
secondaryMuscles
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

====================================================
ALTERNATIVE EXERCISES
====================================================

For EVERY main workout exercise, provide EXACTLY TWO
alternative exercises.

The alternatives must:

- train the same primary muscle group or movement pattern
- be realistic substitutes
- respect the user's equipment
- respect the user's workout location
- respect the user's fitness experience
- be standard exercises
- exist in the supplied Supabase catalog
- have an exact catalogName
- have a corresponding exerciseName
- be different from the main exercise

Each alternative must contain:

catalogName
exerciseName

Do NOT include:

- sets
- reps
- explanations
- GIF URLs
- ExerciseDB IDs
- fictional names

====================================================
ALTERNATIVE EXERCISE CATALOG RULE
====================================================

The exact same catalog rule applies to alternatives.

For every alternative:

catalogName MUST exactly match one of the supplied
normalized_name values.

exerciseName MUST correspond to that catalog entry.

Example:

"substituteExercises": [
  {
    "catalogName": "dumbbell bench press",
    "exerciseName": "Dumbbell Bench Press"
  },
  {
    "catalogName": "machine chest press",
    "exerciseName": "Machine Chest Press"
  }
]

Do NOT return:

"substituteExercises": [
  "Chest Power Builder",
  "Ultimate Chest Exercise"
]

Do NOT return fictional alternatives.

====================================================
EXACTLY TWO ALTERNATIVES
====================================================

For every main workout exercise:

Return EXACTLY TWO alternatives.

Never return:

- zero alternatives
- one alternative
- more than two alternatives

The alternatives are suggestions for the user.

They are NOT additional workout exercises.

====================================================
SETS / REPS / REST
====================================================

Use realistic values.

Examples:

Hypertrophy:

3-4 sets
8-15 reps
60-120 seconds rest

Strength:

3-5 sets
3-8 reps
2-4 minutes rest

Isolation:

2-4 sets
10-15 reps
45-90 seconds rest

Do not blindly use these ranges.

Adjust them according to:

- user's goal
- fitness experience
- exercise type
- training frequency
- recovery needs

====================================================
INSTRUCTIONS
====================================================

For every main exercise provide 3-5 concise form instructions.

Focus on:

- setup
- movement
- breathing
- control
- safe technique

Do not write extremely long explanations.

====================================================
PRECAUTIONS
====================================================

Provide practical precautions.

Include relevant:

- form warnings
- equipment safety
- beginner precautions
- range-of-motion precautions

Do not make unsupported medical claims.

====================================================
WARM-UP
====================================================

Warm-up is programming information.

Provide:

- bodyPart
- exerciseId
- exerciseName
- duration
- instructions

Warm-up movements should be standard and appropriate
for the day's workout.

Warm-up exercises should preferably be selected from the
supplied catalog when a suitable catalog exercise exists.

If a suitable warm-up movement is not available in the
catalog, use a standard warm-up movement name.

Do NOT invent ExerciseDB IDs or GIF URLs.

====================================================
COOL-DOWN
====================================================

Provide:

- exerciseId
- exerciseName
- duration
- instructions

Cool-down exercises should be practical and appropriate
for the workout.

Do NOT generate ExerciseDB IDs or GIF URLs.

====================================================
STRETCHING
====================================================

Provide:

- bodyPart
- exerciseId
- exerciseName
- duration
- instructions

Stretching should be appropriate for the muscles trained
that day.

Do NOT generate ExerciseDB IDs or GIF URLs.

====================================================
REST DAYS
====================================================

For rest/recovery days provide:

restDay: true

activity
recoveryTips
stretching
notes

Do not add a main workout to a rest day.

====================================================
NO DUPLICATE WORKOUTS
====================================================

Avoid repeating the exact same workout on consecutive
workout days.

Exercises may repeat during the week when appropriate,
but the overall workout structure should remain sensible.

====================================================
WEEKLY PLAN QUALITY
====================================================

The plan should feel like a real structured weekly
fitness program.

Consider:

- movement balance
- muscle recovery
- volume
- intensity
- exercise order
- compound exercises first
- isolation exercises later
- user's experience
- user's goal
- available equipment
- workout frequency
- recovery

====================================================
SCIENTIFIC EVIDENCE REQUIREMENT
====================================================

All programming decisions must be based on established
exercise science and evidence-based training principles.

Consider appropriate use of:

- progressive overload
- training volume
- training intensity
- training frequency
- recovery
- resistance training principles
- exercise selection
- movement balance
- appropriate rest periods
- individual training experience
- progressive adaptation
- technique and safety

For EVERY workout or recovery day, provide one concise
scientific evidence statement in:

scientificEvidence

The scientificEvidence field must:

- be ONE concise line
- explain why the day's structure is appropriate
- be relevant to that day's training
- use evidence-based training principles
- avoid exaggerated claims
- avoid medical diagnosis
- avoid unsupported claims

Example:

"Moderate resistance-training volume with progressive
overload and adequate recovery supports muscle development."

Another example:

"Longer rest intervals can help maintain training quality
during higher-intensity strength work."

Do NOT invent scientific studies.

Do NOT invent researchers.

Do NOT invent journal names.

Do NOT invent statistics.

Do NOT create fake citations.

Do NOT claim something is scientifically proven when evidence
is uncertain or mixed.

Do not provide a long academic explanation.

====================================================
SCIENTIFIC EVIDENCE AND USER SAFETY
====================================================

The scientificEvidence field is educational programming
context only.

Do not diagnose injuries or medical conditions.

Do not prescribe treatment.

If the user's comments indicate an injury, pain, medical
condition, or other health concern, use conservative
programming and appropriate precautions.

====================================================
IMPORTANT APPLICATION FLOW
====================================================

Gemini generates:

- workout program
- exercise selection
- programming
- coaching information
- alternatives
- scientific evidence

Supabase provides:

- ExerciseDB ID
- GIF URL
- body parts
- target muscles
- secondary muscles
- equipment
- ExerciseDB instructions
- other catalog data

Flutter displays the final enriched workout.

Do NOT attempt to generate:

- GIF URLs
- ExerciseDB IDs
- ExerciseDB instructions
- ExerciseDB target muscles
- ExerciseDB body parts

====================================================
JSON FORMAT
====================================================

Return exactly this structure:

{
  "note": "",
  "weeklySummary": {
    "goal": "",
    "fitnessLevel": "",
    "bodyType": "",
    "bodyGoal": "",
    "workoutDays": "",
    "restDays": "",
    "estimatedCaloriesBurnRange": "",
    "estimatedWorkoutDuration": ""
  },
  "days": {
    "Monday": {
      "dayName": "Monday",
      "focus": "",
      "estimatedDuration": "",
      "difficulty": "",
      "restDay": false,
      "activity": "",
      "recoveryTips": [],
      "scientificEvidence": "",

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
              "exerciseName": ""
            },
            {
              "catalogName": "",
              "exerciseName": ""
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

      "dailyTips": [],
      "precautions": [],
      "motivation": "",
      "notes": ""
    }
  }
}

====================================================
JSON FIELD REQUIREMENTS
====================================================

For every main workout exercise:

"exerciseId": ""

"catalogName":
EXACT normalized_name from the supplied catalog.

"exerciseName":
Corresponding human-readable exercise_name.

For every alternative:

"catalogName":
EXACT normalized_name from the supplied catalog.

"exerciseName":
Corresponding human-readable exercise_name.

====================================================
DAYS
====================================================

The "days" object MUST contain all seven days:

Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
Sunday

====================================================
REST DAY FORMAT
====================================================

For rest days:

"restDay": true

"activity":
"Complete Rest"

or another appropriate recovery activity.

Rest days MUST NOT contain a main workout.

====================================================
CATALOG VALIDATION BEFORE RESPONSE
====================================================

Before returning the final JSON, internally verify:

1. Every main workout catalogName exists in the supplied catalog.

2. Every main workout catalogName exactly matches a
normalized_name from the catalog.

3. Every main workout exerciseName corresponds to the
selected catalog entry.

4. Every main workout has exactly two alternatives.

5. Every alternative catalogName exists in the supplied catalog.

6. Every alternative catalogName exactly matches a
normalized_name from the catalog.

7. Every alternative exerciseName corresponds to the
selected catalog entry.

8. No catalogName contains sets or reps.

9. No catalogName contains explanations.

10. No ExerciseDB IDs were invented.

11. No GIF URLs were invented.

12. scientificEvidence exists for every day.

13. All seven days exist.

14. Rest days do not contain main workouts.

====================================================
FINAL OUTPUT RULE
====================================================

Return ONLY valid JSON.

Do NOT return:

- greetings
- explanations
- markdown
- code fences
- comments outside JSON

The response must start with:

{

and end with:

}

====================================================
''';
  }
}
