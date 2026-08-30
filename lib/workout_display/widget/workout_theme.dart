import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// Warm Mocha / Latte palette
/// Shared design tokens for the entire Workout module so every screen
/// stays visually consistent.
/// ---------------------------------------------------------------------
class WorkoutColors {
  WorkoutColors._();

  static const Color background = Color(0xFFF8F3EF); // Soft Ivory
  static const Color secondaryBackground = Color(0xFFEFE5DE); // Warm Beige
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure White

  static const Color primaryGradientStart = Color(0xFFC99A8D); // Dusty Mocha
  static const Color primaryGradientEnd = Color(0xFFA87567); // Cocoa Brown

  static const Color buttonGradientStart = Color(0xFFC28F81); // Light Coffee
  static const Color buttonGradientEnd = Color(0xFF9E6E61); // Deep Mocha

  static const Color border = Color(0xFFD8C4BA); // Soft Beige

  static const Color primaryText = Color(0xFF3A312D); // Charcoal Brown
  static const Color secondaryText = Color(0xFF7D6D66); // Warm Gray

  static const Color icon = Color(0xFFA87567); // Mocha Brown
  static const Color accent = Color(0xFFB98777); // Coffee Bronze

  static const Color shadow = Color(0x14000000); // 8% opacity black
}

class WorkoutGradients {
  WorkoutGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      WorkoutColors.primaryGradientStart,
      WorkoutColors.primaryGradientEnd,
    ],
  );

  static const LinearGradient button = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      WorkoutColors.buttonGradientStart,
      WorkoutColors.buttonGradientEnd,
    ],
  );

  /// Dark-to-transparent wash used on top of the gym background photo so
  /// white text always stays readable.
  static LinearGradient imageOverlay({double opacity = 0.86}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      WorkoutColors.primaryGradientStart.withOpacity(opacity * 0.9),
      WorkoutColors.primaryGradientEnd.withOpacity(opacity),
    ],
  );
}

/// Path to the warm-toned gym equipment background image.
/// Copy `assets/images/gym_background.png` into your Flutter project and
/// register it under `flutter: -> assets:` in pubspec.yaml, e.g.
///
/// flutter:
///   assets:
///     - assets/images/gym_background.png
const String kWorkoutBackgroundImage = 'assets/images/gym_background.png';

/// Consistent soft drop shadow used across cards/tiles.
List<BoxShadow> workoutCardShadow({double blur = 22, double dy = 10}) => [
  BoxShadow(
    color: WorkoutColors.shadow,
    blurRadius: blur,
    offset: Offset(0, dy),
  ),
];

/// A reusable hero banner: gym-equipment background image + mocha gradient
/// wash + arbitrary foreground content. Used at the top of every screen so
/// the whole module feels cohesive.
class WorkoutHeroBanner extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const WorkoutHeroBanner({
    super.key,
    required this.child,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              kWorkoutBackgroundImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: WorkoutColors.primaryGradientEnd),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: WorkoutGradients.imageOverlay(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Fades + slides [child] upward on entry. Stagger a list of these with
/// increasing [delay] values for a professional cascading reveal.
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeInSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
    this.offsetY = 26,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Gentle "press-down" scale feedback for tappable cards/buttons.
class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedPressable({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  double _scale = 1;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.96),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Responsive column count for grids: phones get 2, small tablets 3,
/// larger tablets / desktops 4.
int workoutGridColumns(double width) {
  if (width >= 900) return 4;
  if (width >= 600) return 3;
  return 2;
}

/// Clamps text scale so headline numbers/icons stay proportioned on very
/// narrow or very wide screens.
double workoutClampWidth(double value, {double min = 320, double max = 480}) {
  return value.clamp(min, max);
}
