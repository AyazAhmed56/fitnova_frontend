import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitnova/models/user_profile_model.dart';
import 'package:http/http.dart' as http;

class AIService {
  String get dietApiKey => dotenv.get('GEMINI_API_KEY_DIET');

  static const String _model = 'gemini-2.5-flash';

  Future<Map<String, dynamic>> generateMealPlan(
    UserProfileModel profile,
  ) async {
    final dietPrompt = _buildDietPrompt(profile);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:generateContent?key=$dietApiKey',
    );

    final response = await http
        .post(
          url,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': dietPrompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.3,
              'responseMimeType': 'application/json',
              'maxOutputTokens': 16000,
            },
          }),
        )
        .timeout(const Duration(minutes: 2));

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

    final data = jsonDecode(response.body);
    final candidates = data['candidates'];

    if (candidates is! List || candidates.isEmpty) {
      throw Exception('Gemini returned no meal-plan response.');
    }

    final candidate = candidates.first;
    final finishReason = candidate is Map
        ? candidate['finishReason']?.toString()
        : null;

    if (finishReason == 'MAX_TOKENS') {
      throw Exception(
        'Gemini returned an incomplete meal plan because the output limit '
        'was reached. Try again or reduce recipe detail.',
      );
    }

    final content = candidate is Map ? candidate['content'] : null;
    final parts = content is Map ? content['parts'] : null;

    if (parts is! List || parts.isEmpty) {
      throw Exception('Gemini returned an empty meal plan.');
    }

    final textBuffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] != null) {
        textBuffer.write(part['text'].toString());
      }
    }

    final rawText = textBuffer.toString().trim();
    if (rawText.isEmpty) {
      throw Exception('Gemini returned an empty meal plan.');
    }

    final cleaned = rawText
        .replaceAll(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*```$'), '')
        .trim();

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) {
        throw const FormatException(
          'The meal plan root must be a JSON object.',
        );
      }
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      throw Exception('Could not parse Gemini meal-plan JSON: $e');
    }
  }

  String _buildDietPrompt(UserProfileModel profile) {
    return '''
You are FitNova's careful, evidence-informed Indian meal-planning assistant. Create practical, affordable food guidance using familiar ingredients and realistic home cooking. Do not claim to diagnose, cure, or treat medical conditions.

USER PROFILE
Name: ${profile.fullName}
Age: ${profile.age}; gender: ${profile.gender}
Height: ${profile.height} cm; weight: ${profile.weight} kg
Goal: ${profile.goal}; target weight: ${profile.targetWeight}; duration: ${profile.durationMonths} months
Medical records/restrictions: ${profile.medical}
Current state: ${profile.state}; native/birth state: ${profile.nativeState}
Muscle gain target: ${profile.muscleGainTarget}
Strength goal: ${profile.strengthGoal}; primary lift: ${profile.primaryLift}; rep range: ${profile.repRange}
Endurance goal: ${profile.enduranceGoal}; cardio preference: ${profile.cardioPreference}
Fitness goals: ${profile.fitnessGoals.join(', ')}
Workout place: ${profile.workoutPlace}; sport: ${profile.sportName}
Performance goals: ${profile.performanceGoals.join(', ')}; competition level: ${profile.competitionLevel}
Workout days: ${profile.workoutDays}; activity level: ${profile.activityLevel}
Dietary preferences: ${profile.dietaryPreferences.join(', ')}
Allergies: ${profile.allergies}; comments/food dislikes: ${profile.comments}
Meals per day: ${profile.mealsPerDay}; sleep hours: ${profile.sleepHours}
Daily water intake: ${profile.waterIntake}
Workout type: ${profile.exercise}; workout location: ${profile.workoutPrefer}
Wake-up time: ${profile.wakeUp}; budget range: ${profile.budget}
Job: ${profile.job}; office/job time: ${profile.officeTime}; break time: ${profile.breakTime}
Workout time: ${profile.workoutTime}

APPEARANCE AND WELLNESS PROFILE
Skin tone (do not infer health from tone): ${profile.skinTone}
Skin concerns: ${profile.skinConcerns.join(', ')}
Hair type: ${profile.hairType}; scalp type: ${profile.scalpType}
Hair concerns: ${profile.hairConcerns.join(', ')}

FITNESS PROFILE
Body type (not a definitive scientific predictor): ${profile.bodyType}
Body goal: ${profile.bodyGoal}; fitness experience: ${profile.fitnessLevel}

CORE PERSONALIZATION
1. Create exactly a 2-day plan: Day1 and Day2 only.
2. Respect allergies, dietary preferences, medical restrictions, dislikes, budget, age, regional food preferences, schedule, cooking time, and meal frequency.
3. Never include a known allergen or food the user must avoid. If allergy information is unclear, err on the side of avoiding the named allergen.
4. Medical records are a safety constraint, not a reason to diagnose or prescribe a therapeutic diet. Avoid obvious conflicts with stated restrictions; recommend a qualified clinician/dietitian for individualized medical nutrition advice where needed.
5. Never recommend crash diets, extreme calorie restriction, unsafe bulking, fat burners, medicines, or unrequested supplements.
6. Calories and macros are estimates, not laboratory measurements. Make them realistic and internally consistent; do not promise a specific weight change.
7. For users under 18, do not prescribe aggressive calorie deficits or weight-loss targets; prioritize regular balanced meals, growth, and appropriate adult/clinical guidance.
8. For older adults, favor familiar, digestible meals, adequate protein, fiber, hydration, and suitable textures where needed.
9. Prefer affordable, widely available Indian ingredients: dal, chana, rajma, eggs, milk/curd, seasonal vegetables and fruit, rice, roti, poha, upma, peanuts, and locally common grains.
10. Avoid premium imported foods and supplements such as whey protein, avocado, kiwi, dragon fruit, and specialty products unless the user's budget clearly allows them and preferences support them. Never use implausible quantities such as kilograms of paneer per day.
11. Fit the plan comfortably within the user's daily/monthly budget. Reuse ingredients across both days to reduce cost and waste. Do not claim exact local prices.
12. Use current and native state to select familiar regional dishes where possible without stereotyping.
13. Age can guide food style but does not determine taste. Healthier homemade versions of familiar foods (such as wraps, burgers, pizza, chilli paneer, soya/chicken dishes, fries, or momos) may be used for teens/young adults only when appropriate, affordable, and compatible. Familiar dal, sabzi, roti, rice, khichdi, curd, and softer foods may suit some older adults.
14. Use body goal and experience cautiously; do not base calories or macros on body-type labels alone.
15. Use goal-specific fields only when relevant:
    - Muscle gain: sufficient energy and protein from meals.
    - Strength/power: enough energy and carbohydrate to support training and recovery.
    - Endurance: practical carbohydrate sources, hydration, and recovery.
    - General fitness: balanced meals and sustainable portions.
    - Athletic performance: adequate energy and practical meal timing around training/competition.
16. Do not add goal-specific foods or rules that are irrelevant to the user's selected goal.

CALORIES, MACROS, WATER, AND SLEEP
- Estimate a reasonable daily calorie target using available age, body size, goal, activity, and training details. If information is insufficient, avoid false precision and use a conservative estimate.
- Adjust energy to goal and activity, not target weight alone.
- Provide daily calories, protein, carbs, fat, water, and sleep targets with units.
- Meal calories/macros should broadly sum to daily targets; small rounding differences are acceptable.
- Distribute affordable protein sources across meals. Do not force extreme protein intake or supplements.
- Do not eliminate entire macronutrients.
- Water is a general estimate; never encourage excessive intake. Medical fluid restrictions take priority.
- Use the known wake-up/sleep routine when possible. Food does not replace adequate sleep.

TIMELINE AND RECIPE RULES
- Each day must have a chronological timeline array.
- Match the user's meal count where practical. Water reminders are not meals.
- Include breakfast, lunch, snack, and dinner as appropriate. Include pre-workout/post-workout food only when it fits the workout schedule and appetite; these may be integrated into regular meals if the requested meal count is lower.
- If workout time is known, a light, digestible pre-workout option may be placed about 30-120 minutes before training when useful, and a balanced post-workout meal at a practical time after training. Avoid heavy greasy meals immediately before exercise.
- If workout time is missing, do not invent one; use ordinary meal timing.
- Include realistic water reminders spaced throughout waking hours.
- Include an affordable seasonal fruit where suitable.
- Green or black tea is optional. Include it on one or both days only if it suits preferences and health context. Avoid caffeine near bedtime; do not force morning and evening tea.
- Include a sleep entry with a plausible time consistent with wake-up time and sleep target.
- Keep dish titles short and meals varied but not unnecessarily complicated.
- Give exact practical quantities (g, ml, pieces, katori, roti) for each ingredient.
- Every edible meal must have an ingredients list with quantities and 3-5 short preparation steps. For simple drinks or ready-to-eat foods, give brief preparation/assembly steps.
- Every timeline item must have calories, protein, carbs, and fat as strings with units or estimates. Water and unsweetened non-caloric drinks may use zero or near-zero values.

SKIN AND HAIR CARE
- Each day must contain both "skinCare" and "hairCare".
- The "foods" arrays must reference foods already present in that day's timeline; do not add new eating occasions.
- Skin-supportive diet suggestions may mention varied balanced meals and commonly available sources of vitamin C, vitamin A precursors, protein, and healthy fats. Do not promise glow or treatment of acne/pigmentation.
- Hair-supportive diet suggestions may mention adequate protein, iron-containing foods, zinc-containing foods, and dietary variety. Do not claim food cures hair loss or scalp conditions.
- The "juice" value must name a drink already included in that day's timeline, or an affordable drink already accounted for in the timeline. Do not introduce uncounted calories or ingredients. Prefer whole fruit or simple homemade drinks where practical.
- Include one safe external homemade skin remedy and one safe external homemade hair/scalp remedy per day. These are not medical treatments.
- Never recommend lemon juice, baking soda, undiluted essential oils, harsh scrubs, bleach, or irritating substances on skin/scalp.
- For skin, use a gentle option such as plain oatmeal paste or plain aloe gel only if tolerated. Include patch-test advice, avoid eyes/broken skin, and stop if irritation occurs.
- For hair/scalp, a small amount of plain coconut oil may be suggested only if tolerated; do not suggest oiling when it worsens the user's scalp condition. Include patch-test/stop-if-irritated advice.
- External remedy ingredients must not be counted as food or included in the shopping list unless also used in meals.
- If a skin/scalp concern sounds severe, painful, infected, persistent, or worsening, recommend professional advice instead of presenting a home remedy as treatment.

SHOPPING LIST
- Provide one consolidated shopping list for both days with exactly these keys: vegetables, fruits, protein, grains, dairy, nutsSeeds, spices, others.
- Include only ingredients used in timeline meals/drinks; combine duplicates and total quantities for two days.
- Include pantry items only if actually used.
- Do not include external-only remedy ingredients unless also used in the meal plan.
- Make quantities practical for one person for two days.

JSON REQUIREMENTS
- Return one valid JSON object only; no Markdown, code fences, comments, or text outside JSON.
- Use double quotes for all JSON keys and strings. No trailing commas.
- Use arrays for lists and objects for structured entries.
- Keep nutrition values and quantities as strings including units.
- Every timeline entry must include all required keys. Use empty strings/arrays only where appropriate.
- Keep recipe steps concise so the JSON remains complete and valid.

REQUIRED JSON STRUCTURE
{
  "note": "Generate a new plan after Day 2 for variety and adherence.",
  "shoppingList": {
    "vegetables": [],
    "fruits": [],
    "protein": [],
    "grains": [],
    "dairy": [],
    "nutsSeeds": [],
    "spices": [],
    "others": []
  },
  "days": {
    "Day1": {
      "dailyTarget": {
        "calories": "",
        "protein": "",
        "carbs": "",
        "fat": "",
        "water": "",
        "sleep": ""
      },
      "timeline": [
        {
          "time": "",
          "type": "",
          "title": "",
          "quantity": "",
          "calories": "",
          "protein": "",
          "carbs": "",
          "fat": "",
          "ingredients": [],
          "instructions": []
        }
      ],
      "skinCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title": "",
          "ingredients": [],
          "instructions": []
        }
      },
      "hairCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title": "",
          "ingredients": [],
          "instructions": []
        }
      }
    },
    "Day2": {
      "dailyTarget": {
        "calories": "",
        "protein": "",
        "carbs": "",
        "fat": "",
        "water": "",
        "sleep": ""
      },
      "timeline": [
        {
          "time": "",
          "type": "",
          "title": "",
          "quantity": "",
          "calories": "",
          "protein": "",
          "carbs": "",
          "fat": "",
          "ingredients": [],
          "instructions": []
        }
      ],
      "skinCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title": "",
          "ingredients": [],
          "instructions": []
        }
      },
      "hairCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title": "",
          "ingredients": [],
          "instructions": []
        }
      }
    }
  }
}

Allowed timeline types include Breakfast, Lunch, Snack, Dinner, Pre Workout, Post Workout, Hydration, Tea, and Sleep. Other concise relevant types are allowed.

FINAL SELF-CHECK
1. Exactly Day1 and Day2 exist.
2. All eight shopping categories exist.
3. Every timeline entry has time, type, title, quantity, calories, protein, carbs, fat, ingredients, instructions.
4. Recipes have 3-5 short steps when preparation is applicable.
5. Allergies, restrictions, budget, regional preferences, age, and schedule are respected.
6. Workout timing is used only when supported by the profile.
7. Skin/hair foods and drinks already exist in the timeline.
8. Each day has one safe external skin remedy and one safe external hair/scalp remedy.
9. Shopping quantities consolidate both days and match the plan.
10. Daily targets and meal estimates are broadly consistent.
11. JSON is valid and complete, starts with { and ends with }.
Return ONLY JSON.
''';
  }
}
