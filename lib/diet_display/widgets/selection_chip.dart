import 'package:flutter/material.dart';

class SelectionChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const SelectionChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(title),
      selected: selected,
      selectedColor: Colors.green.shade100,
      checkmarkColor: const Color(0xFF3A6F4B),

      side: BorderSide(
        color: selected ? const Color(0xFF3A6F4B) : Colors.grey.shade300,
      ),

      onSelected: (_) => onTap(),
    );
  }
}
