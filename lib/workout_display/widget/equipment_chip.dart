import 'package:flutter/material.dart';

class EquipmentChip extends StatelessWidget {
  final String equipment;

  const EquipmentChip({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 100, 248, 1).withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.deepPurple.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 18,
            color: Color.fromARGB(255, 100, 248, 1),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              equipment,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color.fromARGB(255, 100, 248, 1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
