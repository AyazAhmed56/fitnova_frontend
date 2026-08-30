import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutDayModel workoutDay;

  const WorkoutSessionScreen({super.key, required this.workoutDay});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final PageController _pageController;
  final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF9800),
    foregroundColor: Colors.black,
    elevation: 0,
    minimumSize: const Size.fromHeight(54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );
  Timer? _timer;

  int _currentExercise = 0;
  int _seconds = 0;

  bool _isRunning = false;
  bool _isPaused = false;

  List<ExerciseModel> get exercises => widget.workoutDay.workout;

  double get progress {
    if (exercises.isEmpty) return 0;
    return (_currentExercise + 1) / exercises.length;
  }

  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _seconds++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _seconds = 0;
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _nextExercise() {
    if (_currentExercise < exercises.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _timer?.cancel();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Workout Completed"),
          content: const Text(
            "Congratulations! You have completed today's workout session.",
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Finish"),
            ),
          ],
        ),
      );
    }
  }

  void _previousExercise() {
    if (_currentExercise > 0) {
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

    if (exercises.isEmpty) {
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
          appBar: AppBar(title: const Text("Workout Session")),
          body: const Center(
            child: Text(
              "No Exercises Available",
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
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Workout Session",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: Column(
          children: [
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text(
                        "Exercise ${_currentExercise + 1} of ${exercises.length}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .040,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: sw * .045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                itemCount: exercises.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentExercise = index;
                  });
                },
                itemBuilder: (context, index) {
                  final exercise = exercises[index];

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: sh * .03),
                    child: Column(
                      children: [
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
                            borderRadius: BorderRadiusGeometry.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 20,
                                  left: 10,
                                  right: 10,
                                ),
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
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.fitness_center,
                                          size: 32,
                                          color: const Color.fromARGB(
                                            255,
                                            121,
                                            192,
                                            250,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Text(
                                          'Workout Session',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: sw * .055,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _StatTile(
                                              icon: Icons.repeat,
                                              title: "Sets",
                                              value: exercise.sets,
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: _StatTile(
                                              icon: Icons.fitness_center,
                                              title: "Reps",
                                              value: exercise.reps,
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: _StatTile(
                                              icon: Icons.timer_outlined,
                                              title: "Rest",
                                              value: exercise.rest,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sw * .055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                exercise.exerciseType,
                                style: TextStyle(
                                  color: Colors.grey.shade200,
                                  fontSize: sw * .040,
                                ),
                              ),

                              const SizedBox(height: 18),

                              const Text(
                                "Instructions",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 12),

                              ...List.generate(
                                exercise.instructions.length,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        child: Text(
                                          "${i + 1}",
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: Text(
                                          exercise.instructions[i],
                                          style: const TextStyle(
                                            height: 1.6,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (exercise.tips.isNotEmpty) ...[
                                const SizedBox(height: 18),

                                const Text(
                                  "Tips",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                ...exercise.tips.map(
                                  (tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.orange,
                                          size: 20,
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            tip,
                                            style: const TextStyle(
                                              height: 1.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: sh * .03),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(.15),
                          Colors.white.withOpacity(.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(.20),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        /// Previous
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_currentExercise > 0) {
                                _previousExercise();
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 18,
                            ),
                            label: const Text(
                              '',
                              // "Previous",
                              // style: TextStyle(
                              //   color: Colors.black,
                              //   fontSize: 13,
                              //   fontWeight: FontWeight.w600,
                              // ),
                            ),
                            style: buttonStyle,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Start / Pause / Resume
                        Flexible(
                          child: !_isRunning
                              ? ElevatedButton.icon(
                                  onPressed: _startTimer,
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    '',
                                    // "Start",
                                    // style: TextStyle(
                                    //   color: Colors.black,
                                    //   fontSize: 13,
                                    //   fontWeight: FontWeight.w600,
                                    // ),
                                  ),
                                  style: buttonStyle,
                                )
                              : _isPaused
                              ? ElevatedButton.icon(
                                  onPressed: _resumeTimer,
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    '',
                                    // "Resume",
                                    // style: TextStyle(
                                    //   color: Colors.black,
                                    //   fontSize: 13,
                                    //   fontWeight: FontWeight.w600,
                                    // ),
                                  ),
                                  style: buttonStyle,
                                )
                              : ElevatedButton.icon(
                                  onPressed: _pauseTimer,
                                  icon: const Icon(
                                    Icons.pause,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    '',
                                    // "Pause",
                                    // style: TextStyle(
                                    //   color: Colors.black,
                                    //   fontSize: 13,
                                    //   fontWeight: FontWeight.w600,
                                    // ),
                                  ),
                                  style: buttonStyle,
                                ),
                        ),

                        const SizedBox(width: 12),

                        /// Next
                        Flexible(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _resetTimer();
                              _nextExercise();
                            },
                            icon: Icon(
                              _currentExercise == exercises.length - 1
                                  ? Icons.check_circle
                                  : Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 18,
                            ),
                            label: Text(
                              '',
                              // _currentExercise == exercises.length - 1
                              //     ? "Finish"
                              //     : "Next",
                              // style: const TextStyle(
                              //   color: Colors.black,
                              //   fontSize: 11,
                              //   fontWeight: FontWeight.w600,
                              // ),
                            ),
                            style: buttonStyle,
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
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color.fromARGB(255, 2, 243, 10)),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            value.isEmpty ? "-" : value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
