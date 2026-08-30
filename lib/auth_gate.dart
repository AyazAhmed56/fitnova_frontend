import 'package:fitnova/homescreen.dart';
import 'package:fitnova/mainscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitnova/planner_screens/info.dart';
import 'package:flutter/material.dart';
import 'package:fitnova/services/supabase_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkProfile(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          return const HomeScreen();
        }

        if (snapshot.data == true) {
          return const MainScreen();
        }

        return const Infoscreen();
      },
    );
  }

  Future<bool> _checkProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return false;
    }

    final profile = await SupabaseService().getUserProfile(user.id);
    return profile != null;
  }
}
