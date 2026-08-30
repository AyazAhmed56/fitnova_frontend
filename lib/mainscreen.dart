import 'package:fitnova/ai_coach/ai_coach_screen.dart';
import 'package:fitnova/dashboard.dart';
import 'package:fitnova/diet_display/display_screen/diethome.dart';
import 'package:fitnova/settings/settings.dart';
import 'package:fitnova/workout_display/display_screen/workout_home.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    Dashboard(),
    DietHome(),
    AiCoachScreen(),
    WorkoutHome(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final sw = constraints.maxWidth;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),

            child: BottomNavigationBar(
              currentIndex: selectedIndex,

              type: BottomNavigationBarType.fixed,

              selectedItemColor: const Color(0xFF3A6F4B),
              unselectedItemColor: Colors.grey,

              selectedFontSize: sw * 0.032,
              unselectedFontSize: sw * 0.03,

              elevation: 0,
              backgroundColor: Colors.white,

              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu),
                  label: 'Diet',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy),
                  activeIcon: Icon(Icons.chat),
                  label: 'Health Coach',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart_outlined),
                  activeIcon: Icon(Icons.shopping_cart),
                  label: 'Workout',
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
