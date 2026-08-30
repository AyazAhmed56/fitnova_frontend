import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/warmup_model.dart';
import '../models/workout_day_model.dart';
import '../widget/warmup_card.dart';

class WarmupScreen extends StatefulWidget {
  final WorkoutDayModel workoutDay;

  const WarmupScreen({super.key, required this.workoutDay});

  @override
  State<WarmupScreen> createState() => _WarmupScreenState();
}

class _WarmupScreenState extends State<WarmupScreen> {
  late final PageController _pageController;
  final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 248, 134, 3),
    foregroundColor: Colors.grey.shade700,
    disabledBackgroundColor: Colors.grey.shade400,
    disabledForegroundColor: Colors.grey,
    elevation: 0,
    minimumSize: const Size.fromHeight(55),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<WarmupModel> get warmups => widget.workoutDay.warmUp;

  double get progress {
    if (warmups.isEmpty) return 0;
    return (_currentIndex + 1) / warmups.length;
  }

  void _nextExercise() {
    if (_currentIndex < warmups.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousExercise() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    if (warmups.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/workout_background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.modulate,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Warm Up")),
          body: const Center(
            child: Text(
              "No Warm Up Exercises",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/workout_background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Warm Up",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(30),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Text(
                          "Exercise ${_currentIndex + 1}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * .040,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          "${_currentIndex + 1} / ${warmups.length}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: warmups.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final warmup = warmups[index];

                    return SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: sh * .03),
                      child: Column(
                        children: [
                          WarmupCard(warmup: warmup, onTap: _nextExercise),
                          const SizedBox(height: 20),

                          if (widget.workoutDay.notes.trim().isNotEmpty)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Warm Up Notes",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          widget.workoutDay.notes,
                                          style: TextStyle(
                                            height: 1.5,
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          if (widget.workoutDay.dailyTips.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        color: Colors.green,
                                      ),

                                      SizedBox(width: 10),

                                      Text(
                                        "Warm Up Tips",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  ...List.generate(
                                    widget.workoutDay.dailyTips.length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 10,
                                            child: Text(
                                              "${i + 1}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              widget.workoutDay.dailyTips[i],
                                              style: TextStyle(
                                                height: 1.5,
                                                color: Colors.grey.shade200,
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

                          const SizedBox(height: 20),

                          if (widget.workoutDay.precautions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                      ),

                                      SizedBox(width: 10),

                                      Text(
                                        "Before You Begin",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  ...List.generate(
                                    widget.workoutDay.precautions.length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: Colors.red,
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Text(
                                              widget.workoutDay.precautions[i],
                                              style: TextStyle(
                                                color: Colors.grey.shade200,
                                                height: 1.5,
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

                          SizedBox(height: sh * .04),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_currentIndex > 0) {
                                  _previousExercise();
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black,
                                size: 18,
                              ),
                              label: const Text(
                                "Previous",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: buttonStyle,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: _nextExercise,
                              style: buttonStyle,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentIndex == warmups.length - 1
                                        ? "Finish"
                                        : "Next",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Icon(
                                    _currentIndex == warmups.length - 1
                                        ? Icons.check_circle
                                        : Icons.arrow_forward_ios,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
  }
}
