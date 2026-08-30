import 'package:flutter/material.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = constraints.maxWidth;
        // final sh = constraints.maxHeight;

        return GestureDetector(
          onTap: onTap,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,

            decoration: BoxDecoration(
              color: selected ? Colors.green.shade50 : Colors.white,

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: selected
                    ? const Color(0xFF3A6F4B)
                    : Colors.grey.shade300,
                width: selected ? 2 : 1.2,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Stack(
              children: [
                /// Check Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: AnimatedScale(
                    scale: selected ? 1 : .8,
                    duration: const Duration(milliseconds: 250),

                    child: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? const Color(0xFF3A6F4B) : Colors.grey,
                      size: sw * .13,
                    ),
                  ),
                ),

                Column(
                  children: [
                    Expanded(
                      flex: 8,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Hero(
                          tag: image,
                          child: SizedBox(
                            width: double.infinity,
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: sw * 0.09,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
