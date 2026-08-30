import 'package:fitnova/login.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF355C3B);
    const Color secondaryGreen = Color(0xFF4F7A57);
    const Color darkGreen = Color(0xFF1E4027);

    const Color headingColor = Color(0xFF1E2B22);
    const Color subtitleColor = Color(0xFF5F6C63);
    const Color accentText = Color(0xFF4F7A57);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/main_background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sw = constraints.maxWidth;
              final sh = constraints.maxHeight;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.08,
                    vertical: sh * .3,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Your Personal",
                          style: TextStyle(
                            fontSize: sw * .085,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                            letterSpacing: .3,
                          ),
                        ),

                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [primaryGreen, secondaryGreen, darkGreen],
                            ).createShader(bounds);
                          },
                          child: Text(
                            "Fitness Planner",
                            style: TextStyle(
                              fontSize: sw * .085,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: sh * 0.02),

                        Text(
                          "AI-powered diet, workout and wellness",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sw * .043,
                            color: subtitleColor,
                            height: 1.4,
                          ),
                        ),

                        SizedBox(height: sh * .006),

                        Text(
                          "plans personalized to your goals",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: sw * .043,
                            color: accentText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: sh * 0.08),

                        SizedBox(
                          width: double.infinity,
                          height: sh * .068,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryGreen,
                                    secondaryGreen,
                                    darkGreen,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: sw * .045,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: .3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
