import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String tip;
  final int index;

  const TipCard({super.key, required this.tip, required this.index});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.transparent,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Number Badge
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.amber.withOpacity(.15),
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 16),

            /// Tip
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * .040,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
