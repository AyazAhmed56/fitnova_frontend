import 'package:fitnova/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        isLoading = true;
      });

      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null || user.emailConfirmedAt == null) {
        await Supabase.instance.client.auth.signOut();
        throw Exception("Plese verify your email before logging in");
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration customDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    required double sw,
    required double sh,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF287831), size: sw * 0.055),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sh * 0.02,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.03),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.03),
        borderSide: const BorderSide(color: Color(0xFF287831), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF355C3B);
    const Color secondaryGreen = Color(0xFF4F7A57);
    const Color darkGreen = Color(0xFF1E4027);

    const Color headingColor = Color(0xFF1E2B22);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/main_background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.7),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double sw = constraints.maxWidth;
              final double sh = constraints.maxHeight;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.06,
                  vertical: sh * 0.1,
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
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
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: sw * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Login to continue your journey',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      TextFormField(
                        controller: emailController,
                        autofillHints: const [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your email';
                          }

                          if (!RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email';
                          }

                          return null;
                        },

                        decoration: customDecoration(
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          sw: sw,
                          sh: sh,
                        ),
                      ),

                      SizedBox(height: sh * 0.02),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.01),

                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          return null;
                        },

                        decoration: customDecoration(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          sw: sw,
                          sh: sh,

                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: sw * 0.055,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.03),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(thickness: 1, color: Colors.black),
                            ),

                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.45),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                "OR",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff355C3B),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Divider(thickness: 1, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 58,
                      //   child: ElevatedButton(
                      //     onPressed: isLoading
                      //         ? null
                      //         : () async {
                      //             try {
                      //               setState(() => isLoading = true);

                      //               await authService.signInWithGoogle();

                      //               if (!mounted) return;

                      //               Navigator.pushReplacement(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (_) => const AuthGate(),
                      //                 ),
                      //               );
                      //             } catch (e) {
                      //               if (!mounted) return;

                      //               ScaffoldMessenger.of(context).showSnackBar(
                      //                 SnackBar(content: Text(e.toString())),
                      //               );
                      //             } finally {
                      //               if (mounted) {
                      //                 setState(() => isLoading = false);
                      //               }
                      //             }
                      //           },
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.white.withOpacity(.15),
                      //       foregroundColor: Colors.black87,
                      //       elevation: 0,
                      //       shadowColor: Colors.transparent,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(18),
                      //         side: BorderSide(
                      //           color: Colors.white.withOpacity(.45),
                      //         ),
                      //       ),
                      //     ),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Image.asset("assets/google.png", height: 26),

                      //         const SizedBox(width: 14),

                      //         const Text(
                      //           "Continue with Google",
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 15,
                      //             color: Color(0xff1E2B22),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // SizedBox(height: sh * 0.02),

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

                          onPressed: isLoading ? null : login,

                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Ink(
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
                                      'Login',
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

                      SizedBox(height: 20),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: sw * .037,
                            ),
                            children: [
                              const TextSpan(
                                text: "Don't have an account?",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xff355C3B),
                                          Color(0xff4F7A57),
                                          Color(0xff1E4027),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
