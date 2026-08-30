import 'package:flutter/material.dart';

class MuscleChip extends StatelessWidget {
  final String muscle;

  const MuscleChip({super.key, required this.muscle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 255, 158).withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blue.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.accessibility_new,
            size: 18,
            color: Color.fromARGB(255, 1, 255, 158),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              muscle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color.fromARGB(255, 1, 255, 158),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
