import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ReviewCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xff3A6F4B)),

                const SizedBox(width: 10),

                Text(
                  title,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,

                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            child,
          ],
        ),
      ),
    );
  }
}
