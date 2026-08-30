import 'package:flutter/material.dart';

import '../models/exercise_catalog_model.dart';
import '../widget/equipment_chip.dart';
import '../widget/muscle_chip.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseCatalogModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/workout_background.png'),
          fit: BoxFit.cover,
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
            'Exercise Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 16, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // GIF
                // ============================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GifViewer(gifUrl: exercise.gifUrl),
                ),

                const SizedBox(height: 20),

                // ============================================================
                // BASIC INFORMATION
                // ============================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * .065,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'ExerciseDB ID: ${exercise.exerciseDbId}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (exercise.bodyParts.isNotEmpty) ...[
                          const Text(
                            'Body Parts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.bodyParts
                                .map(
                                  (bodyPart) => _CatalogChip(
                                    icon: Icons.accessibility_new,
                                    text: bodyPart,
                                  ),
                                )
                                .toList(),
                          ),
                        ],

                        if (exercise.targetMuscles.isNotEmpty) ...[
                          const SizedBox(height: 20),

                          const Text(
                            'Target Muscles',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.targetMuscles
                                .map((muscle) => MuscleChip(muscle: muscle))
                                .toList(),
                          ),
                        ],

                        if (exercise.equipments.isNotEmpty) ...[
                          const SizedBox(height: 20),

                          const Text(
                            'Equipment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.equipments
                                .map(
                                  (equipment) =>
                                      EquipmentChip(equipment: equipment),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ============================================================
                // SECONDARY MUSCLES
                // ============================================================
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 24),

                  _SectionTitle(title: 'Secondary Muscles'),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: exercise.secondaryMuscles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.42),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(.10),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                color: Colors.white70,
                                size: 18,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                exercise.secondaryMuscles[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // ============================================================
                // INSTRUCTIONS
                // ============================================================
                if (exercise.instructions.isNotEmpty) ...[
                  const SizedBox(height: 28),

                  const _SectionTitle(title: 'Instructions'),

                  const SizedBox(height: 12),

                  ...List.generate(exercise.instructions.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.42),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(.10),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xff7C4DFF).withOpacity(.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Text(
                              exercise.instructions[index],
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.55,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // ============================================================
                // CATALOG ID INFORMATION
                // ============================================================
                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catalog Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _InfoRow(
                          title: 'ExerciseDB ID',
                          value: exercise.exerciseDbId,
                        ),

                        _InfoRow(title: 'Catalog ID', value: exercise.id),

                        _InfoRow(
                          title: 'Normalized Name',
                          value: exercise.normalizedName,
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
    );
  }
}

// =============================================================================
// GIF VIEWER
// =============================================================================

class _GifViewer extends StatelessWidget {
  final String? gifUrl;

  const _GifViewer({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        height: 300,
        color: Colors.white,
        child: gifUrl == null || gifUrl!.trim().isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'GIF not available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Image.network(
                gifUrl!,
                fit: BoxFit.contain,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },

                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 55,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'GIF could not be loaded',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// =============================================================================
// SECTION TITLE
// =============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// =============================================================================
// CATALOG CHIP
// =============================================================================

class _CatalogChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CatalogChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 17),

          const SizedBox(width: 7),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INFO ROW
// =============================================================================

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
