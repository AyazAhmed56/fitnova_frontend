import 'dart:convert';

import 'package:fitnova/models/user_profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WorkoutAIService {
  WorkoutAIService();

  String get workoutApiKey => dotenv.get('GEMINI_API_KEY_WORKOUT');

  static const String _model = 'gemini-2.5-flash';

  Future<Map<String, dynamic>> generateWorkoutPlan(
    UserProfileModel profile,
  ) async {
    final prompt = _buildPrompt(profile);

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

  String _buildPrompt(UserProfileModel profile) {
    return '''
You are an experienced evidence-based fitness coach, strength and conditioning specialist, and workout programmer.

Your task is to create a personalized ONE-WEEK workout PROGRAM for the user.

====================================================
IMPORTANT APPLICATION ARCHITECTURE
====================================================

This application already contains a large ExerciseDB catalog in Supabase.

Supabase table:
exercise_catalog

Supabase is the AUTHORITATIVE SOURCE for ExerciseDB exercise information.

The application will automatically search Supabase after you generate the plan.

Therefore:

DO NOT generate ExerciseDB information.

DO NOT invent:
- exercise database IDs
- GIF URLs
- body parts from ExerciseDB
- target muscles from ExerciseDB
- secondary muscles from ExerciseDB
- ExerciseDB equipment
- ExerciseDB instructions

The application will retrieve those details from Supabase.

Your responsibility is ONLY workout programming and coaching.

====================================================
USER PROFILE
====================================================

Name: ${profile.fullName}
Age: ${profile.age}
Gender: ${profile.gender}

Height: ${profile.height} cm
Weight: ${profile.weight} kg

Goal: ${profile.goal}
Target Weight: ${profile.targetWeight}
Duration: ${profile.durationMonths} months

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
PRIMARY EXERCISE LIBRARY
====================================================

You MUST strongly prefer exercises from this list.

Use these exercises for the majority of the main workout.

You may select another standard exercise ONLY when:
- the user's equipment requires it,
- the exercise is unsuitable for the user's experience,
- the user's goal requires another movement,
- an appropriate listed exercise cannot reasonably cover the movement pattern.

Even when using another exercise, use a standard internationally recognized exercise name.

====================================================
CHEST
====================================================

- Flat Bench Press - Barbell
- Flat Bench Press - Dumbbell
- Incline Bench Press - Barbell
- Incline Bench Press - Dumbbell
- Cable Fly
- Pec Deck Fly
- Scoop Up Cable Fly
- Decline Bench Press - Barbell
- Decline Bench Press - Dumbbell
- Machine Chest Press

====================================================
BACK
====================================================

- Bent Over Row
- T-Bar Row
- Lat Pulldown
- Chin Up
- Seated Row
- Straight Arm Pulldown
- Hyperextension

====================================================
SHOULDERS
====================================================

- Shrugs
- Reverse Pec Deck Fly
- Face Pull
- Shoulder Bench Press
- Lateral Raise
- Front Raise
- Upright Row

====================================================
BICEPS
====================================================

- Preacher Curl
- Dumbbell Curl
- Reverse Grip Curl
- Barbell Curl
- Bayesian Curl
- Incline Bench Curl
- Hammer Curl

====================================================
TRICEPS
====================================================

- Triceps Pushdown
- Triceps Overhead Extension
- Single Arm Triceps Extension

====================================================
LEGS
====================================================

Prefer standard exercises such as:

- Leg Press
- Squat
- Lunges
- Leg Extension
- Leg Curl
- Romanian Deadlift
- Hamstring Curl
- Calf Raise

Use other standard leg exercises when necessary.

====================================================
EXERCISE SELECTION RULE
====================================================

VERY IMPORTANT:

Use the above exercise library for MOST main-workout exercises.

Aim for approximately 80-90% of the main workout exercises to come from this preferred library whenever the user's equipment and experience allow it.

Do not randomly select obscure exercises.

Do not create fictional exercise names.

Do not combine multiple exercises into one exercise name.

Use concise standard names.

The name must be suitable for matching against the Supabase ExerciseDB catalog.

Examples:

GOOD:
"Lat Pulldown"

GOOD:
"Barbell Curl"

GOOD:
"Face Pull"

BAD:
"Ultimate Wide Grip Lat Blast"

BAD:
"Chest Power Builder"

BAD:
"Special AI Push Movement"

====================================================
EXERCISE DATABASE MATCHING
====================================================

The application will match your exerciseName against Supabase.

Therefore:

1. Use standard exercise names.
2. Do not put sets/reps inside exerciseName.
3. Do not put equipment descriptions inside exerciseName unless they are part of the standard exercise name.
4. Keep exerciseName concise.
5. Do not provide exerciseId unless it is already known.
6. Leave exerciseId as an empty string.

Example:

Correct:

"exerciseName": "Lat Pulldown"

Incorrect:

"exerciseName": "Lat Pulldown 4 sets x 12 reps"

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
- gym equipment may be used according to their equipment preference

9. Do not train the same major muscle group excessively on consecutive days.

10. Use realistic training volume.

11. Use progressive overload where appropriate.

12. Adjust intensity according to fitness experience.

13. Beginners must not receive unnecessarily advanced or unsafe exercises.

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

Ignore goal-specific fields that are unrelated to the user's selected goal.

====================================================
MAIN WORKOUT EXERCISE FIELDS
====================================================

For every main workout exercise provide ONLY programming/coaching information.

Required fields:

exerciseId
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

IMPORTANT:

muscleGroup and secondaryMuscles here are programming guidance.

Supabase ExerciseDB data will later replace/enrich these fields when a catalog match is found.

DO NOT provide:
gifUrl
bodyParts
targetMuscles
catalogInstructions
catalogSecondaryMuscles
exerciseDbId

Those are retrieved from Supabase.

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
Adjust them according to the user's goal and experience.

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

====================================================
WARM-UP
====================================================

Warm-up is programming information.

Provide:
- exercise name
- body part
- duration
- short instructions

Use standard warm-up movements.

====================================================
COOL-DOWN
====================================================

Provide:
- exercise name
- duration
- short instructions

====================================================
STRETCHING
====================================================

Provide:
- body part
- exercise name
- duration
- short instructions

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

Avoid repeating the exact same workout on consecutive workout days.

Exercises may repeat during the week when appropriate, but the overall workout structure should remain sensible.

====================================================
WEEKLY PLAN QUALITY
====================================================

The plan should feel like a real structured weekly gym program.

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

====================================================
IMPORTANT
====================================================

Gemini generates the PROGRAM.

Supabase provides the ExerciseDB DATA.

Flutter displays the final enriched workout.

Do not attempt to generate GIF URLs.

Do not attempt to generate ExerciseDB IDs.

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
          "substituteExercises": [],
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

The "days" object MUST contain all seven days.

For rest days, use:

"restDay": true

and:

"activity": "Complete Rest"

or an appropriate recovery activity.

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
