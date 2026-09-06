import 'package:fitnova/diet_display/display_screen/dailymeal.dart';
import 'package:fitnova/workout_display/display_screen/weekly_workout_plan.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fitnova/services/supabase_service.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  final SupabaseService _service = SupabaseService();

  bool isLoading = true;
  bool hasMealPlan = false;
  bool hasWorkoutPlan = false;

  static const Color primary = Color(0xFF3A6F4B);
  static const Color background = Color(0xFFF5F8F5);

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final results = await Future.wait<bool>([
        _service.getMealPlan(user.id).then((plan) => plan != null),
        _service.getWorkoutPlan(user.id).then((plan) => plan != null),
      ]);

      if (!mounted) return;
      setState(() {
        hasMealPlan = results[0];
        hasWorkoutPlan = results[1];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Unable to load your plans: $e', Colors.red);
    }
  }

  Future<void> _openMealPlan() async {
    if (!hasMealPlan) {
      _showMessage('No active meal plan. Generate one first.', Colors.orange);
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyMeal()),
    );
    if (mounted) _loadPlans();
  }

  Future<void> _openWorkoutPlan() async {
    if (!hasWorkoutPlan) {
      _showMessage(
        'No active workout plan. Generate one first.',
        Colors.orange,
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WeeklyWorkoutPlan()),
    );
    if (mounted) _loadPlans();
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _planCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFFEAF4ED)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: available ? primary : Colors.grey,
                  size: 28,
                ),
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
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      available ? 'Available' : 'Not generated',
                      style: TextStyle(
                        color: available ? primary : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: available ? Colors.grey : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primary)),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'My Plan',
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF4ED), Color(0xFFDCEDE1)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, color: primary, size: 30),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Personalized Plans',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'View the active plans created according to your FitNova profile.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Diet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _planCard(
                icon: Icons.restaurant_menu,
                title: 'Meal Plan',
                subtitle: 'View your personalized diet and meals',
                available: hasMealPlan,
                onTap: _openMealPlan,
              ),
              const SizedBox(height: 10),
              const Text(
                'Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _planCard(
                icon: Icons.fitness_center,
                title: 'Workout Plan',
                subtitle: 'View your personalized training plan',
                available: hasWorkoutPlan,
                onTap: _openWorkoutPlan,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
