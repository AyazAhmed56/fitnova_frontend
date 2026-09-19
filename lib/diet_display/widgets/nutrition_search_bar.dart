import 'dart:async';

import 'package:flutter/material.dart';

import '../services/nutrition_service.dart';

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

  final FocusNode _focusNode = FocusNode();
  final NutritionService _service = NutritionService();

  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _loadingSuggestions = true;
    });

    try {
      final result = await _service.getSuggestions();

      if (!mounted) return;

      setState(() {
        _suggestions = result;
        _loadingSuggestions = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingSuggestions = false;
      });
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  void _submit(String value) {
    final query = value.trim();

    if (query.isEmpty) return;

    _focusNode.unfocus();
    widget.onSearch(query);
  }

  List<Map<String, dynamic>> get _filteredSuggestions {
    final query = _controller.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _suggestions.take(6).toList();
    }

    return _suggestions
        .where(
          (item) => item['display_name']
              .toString()
              .toLowerCase()
              .contains(query),
        )
        .take(6)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _filteredSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _submit,
          decoration: InputDecoration(
            hintText: 'Search calcium, protein, iron...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        if (_focusNode.hasFocus || _controller.text.isNotEmpty)
          if (!_loadingSuggestions && suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    color: Color(0x18000000),
                  ),
                ],
              ),
              child: Column(
                children: suggestions.map((item) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.restaurant_menu_outlined,
                    ),
                    title: Text(
                      item['display_name'].toString(),
                    ),
                    subtitle: Text(
                      'Find foods rich in ${item['display_name']}',
                    ),
                    onTap: () {
                      final name =
                          item['display_name'].toString();
                      _controller.text = name;
                      _submit(name);
                    },
                  );
                }).toList(),
              ),
            ),
      ],
    );
  }
}
