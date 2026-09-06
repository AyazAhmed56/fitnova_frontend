import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/services/supabase_service.dart';

class GeneratePlanScreen extends StatefulWidget {
  const GeneratePlanScreen({super.key});

  @override
  State<GeneratePlanScreen> createState() => _GeneratePlanScreenState();
}

class _GeneratePlanScreenState extends State<GeneratePlanScreen> {
  final SupabaseService _service = SupabaseService();

  bool generatingMeal = false;
  bool generatingWorkout = false;
  bool generatingBoth = false;

  static const Color primary = Color(0xFF3A6F4B);
  static const Color background = Color(0xFFF5F8F5);

  bool get anyGenerating =>
      generatingMeal || generatingWorkout || generatingBoth;

  // ============================================================
  // GENERATE MEAL
  // ============================================================

  Future<void> _generateMealPlan(String userId) async {
    final confirm = await _confirm(
      'Generate Meal Plan',
      'Your current meal plan may be replaced with a new personalized meal plan. Continue?',
    );

    if (!confirm || !mounted) return;

    setState(() {
      generatingMeal = true;
    });

    try {
      await _service.generateAndSaveMealPlan(userId);

      if (!mounted) return;

      _message('Meal plan generated successfully.', Colors.green);
    } catch (e, stackTrace) {
      debugPrint('========== MEAL GENERATION ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('===========================================');

      if (!mounted) return;

      _message('Failed to generate meal plan.\n$e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generatingMeal = false;
        });
      }
    }
  }

  // ============================================================
  // GENERATE WORKOUT
  // ============================================================

  Future<void> _generateWorkoutPlan(String userId) async {
    final confirm = await _confirm(
      'Generate Workout Plan',
      'Your current workout plan may be replaced with a new personalized workout plan. Continue?',
    );

    if (!confirm || !mounted) return;

    setState(() {
      generatingWorkout = true;
    });

    try {
      await _service.generateAndSaveWorkoutPlan(userId);

      if (!mounted) return;

      _message('Workout plan generated successfully.', Colors.green);
    } catch (e, stackTrace) {
      debugPrint('========== WORKOUT GENERATION ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('==============================================');

      if (!mounted) return;

      _message('Failed to generate workout plan.\n$e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generatingWorkout = false;
        });
      }
    }
  }

  // ============================================================
  // GENERATE BOTH
  // ============================================================

  Future<void> _generateBoth(String userId) async {
    final confirm = await _confirm(
      'Generate New Plan',
      'This will generate a new meal plan and workout plan. Continue?',
    );

    if (!confirm || !mounted) return;

    setState(() {
      generatingBoth = true;
    });

    try {
      await _service.generateAndSavePlans(userId);

      if (!mounted) return;

      _message(
        'New meal and workout plans generated successfully.',
        Colors.green,
      );
    } catch (e, stackTrace) {
      debugPrint('========== BOTH PLAN GENERATION ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('=================================================');

      if (!mounted) return;

      _message('Failed to generate plans.\n$e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          generatingBoth = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM DIALOG
  // ============================================================

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              child: const Text(
                'Generate',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 6, overflow: TextOverflow.ellipsis),
        backgroundColor: color,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  // ============================================================
  // GENERATE CARD
  // ============================================================

  Widget _generateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: anyGenerating ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: primary, size: 28),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              if (loading)
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'Generate Plans',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: background,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF4ED), Color(0xFFDCEDE1)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Icon(Icons.auto_awesome, color: primary, size: 32),

                    const SizedBox(height: 12),

                    const Text(
                      'Create Your Plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'FitNova will use your current profile information to create a personalized plan.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Choose what you want to generate',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              _generateCard(
                icon: Icons.restaurant_menu,
                title: 'Generate Meal Plan',
                subtitle: 'Create a personalized diet and meal plan.',
                loading: generatingMeal,
                onTap: () => _generateMealPlan(user.id),
              ),

              _generateCard(
                icon: Icons.fitness_center,
                title: 'Generate Workout Plan',
                subtitle: 'Create a personalized training plan.',
                loading: generatingWorkout,
                onTap: () => _generateWorkoutPlan(user.id),
              ),

              _generateCard(
                icon: Icons.auto_awesome,
                title: 'Generate New Plan',
                subtitle: 'Generate both meal and workout plans.',
                loading: generatingBoth,
                onTap: () => _generateBoth(user.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
