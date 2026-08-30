import 'package:flutter/material.dart';

class PrecautionCard extends StatelessWidget {
  final String precaution;
  final int index;

  const PrecautionCard({
    super.key,
    required this.precaution,
    required this.index,
  });

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
            /// Warning Badge
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.orange.withOpacity(.15),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            ),

            const SizedBox(width: 16),

            /// Precaution Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Precaution ${index + 1}",
                    style: TextStyle(color: Colors.grey.shade200, fontSize: 13),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    precaution,
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
