import 'package:flutter/material.dart';

class NutritionSearchBar extends StatefulWidget {
  final void Function(String query) onSearch;

  const NutritionSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<NutritionSearchBar> createState() =>
      _NutritionSearchBarState();
}

class _NutritionSearchBarState
    extends State<NutritionSearchBar> {
  final TextEditingController _controller =
      TextEditingController();

  final FocusNode _focusNode =
      FocusNode();

  // These are local suggestions.
  //
  // IMPORTANT:
  // We intentionally do not call the backend while the user is typing.
  // This prevents asynchronous rebuilds/network activity from affecting
  // the TextField on DietHome.
  static const List<String> _nutrients = [
    'Protein',
    'Calcium',
    'Iron',
    'Fiber',
    'Potassium',
    'Magnesium',
    'Zinc',
    'Vitamin A',
    'Vitamin C',
    'Vitamin D',
    'Vitamin B12',
    'Folate',
    'Omega 3',
    'Healthy Fats',
    'Carbohydrates',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      return;
    }

    _focusNode.unfocus();

    widget.onSearch(query);
  }

  void _clear() {
    _controller.clear();

    // Keep the keyboard open after clearing.
    _focusNode.requestFocus();
  }

  List<String> _filteredSuggestions(
    String query,
  ) {
    final cleaned =
        query.trim().toLowerCase();

    if (cleaned.isEmpty) {
      return _nutrients
          .take(6)
          .toList();
    }

    return _nutrients
        .where(
          (item) => item
              .toLowerCase()
              .contains(cleaned),
        )
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // =============================================================
        // SEARCH FIELD
        // =============================================================

        TextField(
          controller: _controller,
          focusNode: _focusNode,

          textInputAction:
              TextInputAction.search,

          keyboardType:
              TextInputType.text,

          autocorrect: false,

          enableSuggestions: false,

          onSubmitted: _submit,

          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xff26352A),
          ),

          decoration:
              InputDecoration(
            hintText:
                'Search calcium, protein, iron...',

            hintStyle: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade600,
            ),

            prefixIcon:
                const Icon(
              Icons.search_rounded,
              size: 19,
              color: Color(0xff315C3C),
            ),

            suffixIcon:
                ValueListenableBuilder<
                    TextEditingValue>(
              valueListenable:
                  _controller,

              builder:
                  (context, value, child) {
                if (value.text.isEmpty) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  tooltip: 'Clear',
                  onPressed: _clear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                  ),
                  color:
                      const Color(0xff315C3C),
                );
              },
            ),

            filled: true,

            fillColor:
                Colors.white.withOpacity(.72),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 15,
            ),

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide:
                  BorderSide.none,
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide:
                  BorderSide.none,
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide:
                  const BorderSide(
                color: Color(0xff6A9270),
                width: 1,
              ),
            ),
          ),
        ),

        // =============================================================
        // LOCAL SUGGESTIONS
        // =============================================================

        ValueListenableBuilder<
            TextEditingValue>(
          valueListenable:
              _controller,

          builder:
              (context, value, child) {
            final query =
                value.text.trim();

            final suggestions =
                _filteredSuggestions(query);

            if (suggestions.isEmpty) {
              return const SizedBox.shrink();
            }

            // Do not show the dropdown immediately when the field is
            // completely empty. It will appear as soon as the user
            // types a character.
            if (query.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin:
                  const EdgeInsets.only(
                top: 6,
              ),

              constraints:
                  const BoxConstraints(
                maxHeight: 250,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(.96),

                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color: Colors.white,
                ),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 14,
                    offset: Offset(0, 5),
                    color:
                        Color(0x18000000),
                  ),
                ],
              ),

              child:
                  ListView.separated(
                shrinkWrap: true,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 5,
                ),

                itemCount:
                    suggestions.length,

                separatorBuilder:
                    (_, __) =>
                        Divider(
                  height: 1,
                  color:
                      Colors.grey.shade200,
                ),

                itemBuilder:
                    (context, index) {
                  final nutrient =
                      suggestions[index];

                  return ListTile(
                    dense: true,

                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 14,
                    ),

                    leading:
                        Container(
                      height: 30,
                      width: 30,

                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xffEDF5EE),
                        shape:
                            BoxShape.circle,
                      ),

                      child:
                          const Icon(
                        Icons
                            .restaurant_rounded,
                        size: 16,
                        color:
                            Color(0xff075D27),
                      ),
                    ),

                    title: Text(
                      nutrient,

                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(0xff24382A),
                      ),
                    ),

                    trailing:
                        const Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      size: 12,
                      color:
                          Color(0xff6B806F),
                    ),

                    onTap: () {
                      _controller.text =
                          nutrient;

                      _controller.selection =
                          TextSelection
                              .fromPosition(
                        TextPosition(
                          offset:
                              nutrient.length,
                        ),
                      );

                      _submit(
                        nutrient,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
