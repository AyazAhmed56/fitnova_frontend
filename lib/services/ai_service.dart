import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitnova/models/user_profile_model.dart';
import 'package:http/http.dart' as http;

class AIService {
  final String dietApiKey = dotenv.get('GEMINI_API_KEY_DIET');

  Future<Map<String, dynamic>> generateMealPlan(
    UserProfileModel profile,
  ) async {
    final dietPrompt =
        """
You are an experienced Indian fitness coach, sports nutritionist, and dietician.
Don't add any expensive food items (like whey protein, avocado, kiwi, dragon, tofu) in large quantity (like paneer 2kg), give the food items that are easily available and all type of person even lower to lower middle class can afford
Create a highly practical personalized transformation diet plan.

USER DETAILS
Name: ${profile.fullName}
Age: ${profile.age}
Gender: ${profile.gender}
Height: ${profile.height} cm
Weight: ${profile.weight} kg
Goal: ${profile.goal}
Target Weight: ${profile.targetWeight}
Duration: ${profile.durationMonths} months
Muscle Gain Target:${profile.muscleGainTarget}
Strength Goal:${profile.strengthGoal}
Primary Lift:${profile.primaryLift}
Rep Range:${profile.repRange}
Endurance Goal:${profile.enduranceGoal}
Cardio Preference:${profile.cardioPreference}
Fitness Goals:${profile.fitnessGoals.join(", ")}
Workout Place:${profile.workoutPlace}
Sport Name:${profile.sportName}
Performance Goal:${profile.performanceGoals.join(", ")}
Competition Level:${profile.competitionLevel}
Workout Days:${profile.workoutDays}
Activity Level:${profile.activityLevel}
Diet Preferences:${profile.dietaryPreferences.join(", ")}
Allergies:${profile.allergies}
Comments:${profile.comments}
Meals Per Day:${profile.mealsPerDay}
Sleep Hours:${profile.sleepHours}
Daily Water Intake:${profile.waterIntake}
Workout Type:${profile.exercise}
Workout Location:${profile.workoutPrefer}
Wake Up Time:${profile.wakeUp}
Budget Range:${profile.budget}
Job:${profile.job}
Job Time:${profile.officeTime}
Break Time:${profile.breakTime}
Workout Time:${profile.workoutTime}
Workout Days:${profile.workoutDays}
================================================
APPEARANCE PROFILE
Skin Tone:${profile.skinTone}
Skin Concerns:${profile.skinConcerns.join(", ")}
Hair Type:${profile.hairType}
Scalp Type:${profile.scalpType}
Hair Concerns:${profile.hairConcerns.join(", ")}
================================================
FITNESS PROFILE
Body Type:${profile.bodyType}
Body Goal:${profile.bodyGoal}
Fitness Experience:${profile.fitnessLevel}
================================================
IMPORTANT RULES
# based on the given budget range give the diet plan in that range only. Recommend foods that fit comfortably within the user's daily and monthly budget.
Avoid premium imported foods unless the selected budget clearly allows them.
1. Create ONLY a 2-day plan.
2. The plan must feel like it was created by an experienced Indian sports nutritionist and dietician.
3. Include realistic Indian foods.
4. Use exact timings.
5. Calculate realistic calories according to:
   - weight
   - goal
   - activity level
6. Calculate realistic protein intake.
7. Use workout timing to generate:
   - pre workout meal
   - post workout meal
8. Include hydration drinks.
   
9. Include fruits where appropriate.
10. Include water reminders throughout the day.
11. Include sleep timing.
12. Keep dish names SHORT.

13. Provide exact quantities.

14. Generate a consolidated shopping list with quantities.

15. Return ONLY valid JSON.
16. For every edible meal
(Breakfast, Lunch, Snack, Dinner, Pre Workout, Post Workout)
17. Recommend foods that support the user's skin concerns.
18. Recommend foods that support healthy hair and scalp.
19. Include one homemade skin remedy each day using safe household ingredients.
20. Include one homemade hair/scalp remedy each day using safe household ingredients.
21. Adjust calories, carbohydrates, fats and protein according to:
   - Body Goal
   - Body Type
   - Fitness Experience
22. Recommend juices or drinks that support:
   - Skin glow
   - Hair health
   - Hydration
23. Use only realistic Indian foods.
24. Never recommend unsafe home remedies or medicines.
25. The food items or juices used in the skin care and hair care , use it in the diet plan so that the diet plan will be fixed no unnecessary food items will be taken.
26. USe this, based on the goal types otherwise ignore it.
Muscle Gain Target for build muscle
Strength Goal, Primary Lift, Rep Range for strength and power
Endurance Goal, Cardio Preference for improve endurance
Fitness Goals, Workout Place for generl fitness
Sport Name, Performance Goal, Competition Level for Athletic Performance

you MUST provide:
ingredients:
- ingredient list with quantities
instructions:
- step-by-step recipe in 3-5 short steps
================================================

JSON FORMAT
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
  }

  "days": {
    "Day1": {
      "dailyTarget": {
        "calories": "",
        "protein": "",
        "carbs": "",
        "fat": "",
        "water": "",
        "sleep": ""
      }
      "timeline": [ 
        "time":"",
        "type":"",
        "title":"",
        "quantity":"",
        "calories":"",
        "protein":"",
        "carbs":"",
        "fat":"",
        "ingredients":[],
        "instructions":[]
      ]
      "skinCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title":"",
          "ingredients":[],
          "instructions":[]
        }
      },

      "hairCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title":"",
          "ingredients":[],
          "instructions":[]
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
      }
      "timeline": [ 
        "time":"",
        "type":"",
        "title":"",
        "quantity":"",
        "calories":"",
        "protein":"",
        "carbs":"",
        "fat":"",
        "ingredients":[],
        "instructions":[]
      ]
      "skinCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title":"",
          "ingredients":[],
          "instructions":[]
        }
      },

      "hairCare": {
        "foods": [],
        "juice": "",
        "homeRemedy": {
          "title":"",
          "ingredients":[],
          "instructions":[]
        }
      }
    },
  }
}

================================================

Timeline types allowed:
any

IMPORTANT:

Return ONLY valid JSON.

Do NOT write:

- Hello
- Greetings
- Explanations
- Notes outside JSON
- Markdown
- ```json
- ```

Your response must start with {

and end with }

Output ONLY JSON.
""";

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$dietApiKey",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": dietPrompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 503) {
      throw Exception(
        "Gemini servers are busy. Please try again in a few moments.",
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        "Gemini Error (${response.statusCode}) : ${response.body}",
      );
    }

    final data = jsonDecode(response.body);

    final text = data["candidates"][0]["content"]["parts"][0]["text"] ?? "";

    // print("========== GEMINI RESPONSE ==========");
    // print(text);
    // print("====================================");

    final cleaned = text.replaceAll("```json", "").replaceAll("```", "").trim();

    return jsonDecode(cleaned);
  }
}
