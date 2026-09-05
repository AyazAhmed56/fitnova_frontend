import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EquipmentLibraryScreen extends StatefulWidget {
  const EquipmentLibraryScreen({super.key});

  @override
  State<EquipmentLibraryScreen> createState() => _EquipmentLibraryScreenState();
}

class _EquipmentLibraryScreenState extends State<EquipmentLibraryScreen> {
  // ===========================================================================
  // SUPABASE
  // ===========================================================================

  final SupabaseClient _supabase = Supabase.instance.client;

  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  // ===========================================================================
  // DATA
  // ===========================================================================

  final List<_EquipmentData> _equipment = [];

  String _search = '';

  bool _isLoading = true;

  String? _errorMessage;

  int _totalEquipment = 0;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _loadEquipment();
  }

  // ===========================================================================
  // LOAD EQUIPMENT
  // ===========================================================================

  Future<void> _loadEquipment() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _supabase
          .from('equipment_catalog')
          .select(
            'id, equipment_name, normalized_name, category, image_url, description',
          )
          .order('equipment_name');

      final List<_EquipmentData> loadedEquipment = [];

      for (final row in response) {
        final String name = row['equipment_name']?.toString().trim() ?? '';

        if (name.isEmpty) continue;

        loadedEquipment.add(
          _EquipmentData(
            id: row['id']?.toString() ?? '',
            name: name,
            normalizedName: row['normalized_name']?.toString().trim() ?? '',
            category: row['category']?.toString().trim() ?? '',
            imageUrl: row['image_url']?.toString().trim() ?? '',
            description: row['description']?.toString().trim() ?? '',
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _equipment
          ..clear()
          ..addAll(loadedEquipment);

        _totalEquipment = loadedEquipment.length;

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
    });

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {});
    });
  }

  // ===========================================================================
  // CLEAR SEARCH
  // ===========================================================================

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    setState(() {
      _search = '';
    });
  }

  // ===========================================================================
  // FILTER EQUIPMENT
  // ===========================================================================

  List<_EquipmentData> get _filteredEquipment {
    final String query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      return _equipment;
    }

    return _equipment.where((equipment) {
      return equipment.name.toLowerCase().contains(query) ||
          equipment.normalizedName.toLowerCase().contains(query) ||
          equipment.category.toLowerCase().contains(query) ||
          equipment.description.toLowerCase().contains(query);
    }).toList();
  }

  // ===========================================================================
  // ERROR CLEANUP
  // ===========================================================================

  String _cleanErrorMessage(Object error) {
    final String message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Container(
      // =======================================================================
      // SAME BACKGROUND AS EXERCISE LIBRARY
      // =======================================================================
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/workout_background.png'),
          fit: BoxFit.cover,
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // =====================================================================
        // APP BAR
        // =====================================================================
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,

          title: const Text(
            'Equipment Library',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          actions: [
            IconButton(
              onPressed: _loadEquipment,
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        // =====================================================================
        // BODY
        // =====================================================================
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // =================================================================
              // HEADER
              // =================================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.45),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(.15)),
                  ),

                  child: Row(
                    children: [
                      // =========================================================
                      // ICON
                      // =========================================================
                      Container(
                        width: 52,
                        height: 52,

                        decoration: BoxDecoration(
                          color: const Color(0xff7C4DFF).withOpacity(.18),
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // =========================================================
                      // TITLE
                      // =========================================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Equipment Library',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _totalEquipment > 0
                                  ? '$_totalEquipment equipment available'
                                  : 'Browse all equipment',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =========================================================
                      // COUNT
                      // =========================================================
                      if (_totalEquipment > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            '${_filteredEquipment.length}/$_totalEquipment',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // =================================================================
              // SEARCH BAR
              // =================================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: TextField(
                  controller: _searchController,

                  onChanged: _onSearchChanged,

                  textInputAction: TextInputAction.search,

                  style: const TextStyle(color: Colors.black87),

                  decoration: InputDecoration(
                    hintText: 'Search equipment...',

                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: Color(0xff7C4DFF),
                        width: 1.5,
                      ),
                    ),

                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =================================================================
              // RESULT INFORMATION
              // =================================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _search.trim().isEmpty
                            ? 'All Equipment'
                            : 'Results for "${_search.trim()}"',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * .040,
                          fontWeight: FontWeight.bold,
                        ),

                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Text(
                      '${_filteredEquipment.length} available',

                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // =================================================================
              // CONTENT
              // =================================================================
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildContent() {
    // -------------------------------------------------------------------------
    // LOADING
    // -------------------------------------------------------------------------

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // -------------------------------------------------------------------------
    // ERROR
    // -------------------------------------------------------------------------

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final List<_EquipmentData> filtered = _filteredEquipment;

    // -------------------------------------------------------------------------
    // EMPTY
    // -------------------------------------------------------------------------

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // -------------------------------------------------------------------------
    // EQUIPMENT LIST
    // -------------------------------------------------------------------------

    return RefreshIndicator(
      color: const Color(0xff7C4DFF),
      onRefresh: _loadEquipment,

      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),

        itemCount: filtered.length,

        itemBuilder: (context, index) {
          final _EquipmentData equipment = filtered[index];

          return _EquipmentCard(equipment: equipment, index: index);
        },
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.search_off_rounded,
              size: 70,
              color: Colors.white.withOpacity(.75),
            ),

            const SizedBox(height: 16),

            const Text(
              'No equipment found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _search.isEmpty
                  ? 'No equipment is available right now.'
                  : 'Try searching with another equipment name.',

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.white70),
            ),

            if (_search.isNotEmpty) ...[
              const SizedBox(height: 18),

              OutlinedButton(
                onPressed: _clearSearch,

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),

                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ERROR STATE
  // ===========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),

            const SizedBox(height: 16),

            const Text(
              'Unable to load equipment',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? 'Something went wrong.',

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadEquipment,

              icon: const Icon(Icons.refresh),

              label: const Text('Try Again'),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7C4DFF),
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EQUIPMENT DATA
// =============================================================================

class _EquipmentData {
  final String id;
  final String name;
  final String normalizedName;
  final String category;
  final String imageUrl;
  final String description;

  _EquipmentData({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.category,
    required this.imageUrl,
    required this.description,
  });
}

// =============================================================================
// EQUIPMENT CARD
// =============================================================================

class _EquipmentCard extends StatefulWidget {
  final _EquipmentData equipment;
  final int index;

  const _EquipmentCard({required this.equipment, required this.index});

  @override
  State<_EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<_EquipmentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final _EquipmentData equipment = widget.equipment;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),

      decoration: BoxDecoration(
        // SAME CARD STYLE AS EXERCISE LIBRARY
        color: Colors.black.withOpacity(.42),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(22),

        onTap: () {
          setState(() {
            _expanded = !_expanded;
          });
        },

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [
              // =================================================================
              // MAIN CARD ROW
              // =================================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =============================================================
                  // EQUIPMENT IMAGE
                  // =============================================================
                  _EquipmentImage(imageUrl: equipment.imageUrl),

                  const SizedBox(width: 14),

                  // =============================================================
                  // EQUIPMENT DETAILS
                  // =============================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          equipment.name,

                          maxLines: 2,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // =======================================================
                        // CATEGORY
                        // =======================================================
                        if (equipment.category.isNotEmpty)
                          _SmallInfoRow(
                            icon: Icons.category_outlined,
                            text: equipment.category,
                          ),

                        // =======================================================
                        // NORMALIZED NAME
                        // =======================================================
                        if (equipment.normalizedName.isNotEmpty) ...[
                          const SizedBox(height: 6),

                          _SmallInfoRow(
                            icon: Icons.label_outline,
                            text: equipment.normalizedName,
                          ),
                        ],

                        const SizedBox(height: 10),

                        // =======================================================
                        // VIEW DETAILS
                        // =======================================================
                        Row(
                          children: [
                            Text(
                              _expanded ? 'Hide Details' : 'View Details',

                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 4),

                            AnimatedRotation(
                              turns: _expanded ? .5 : 0,

                              duration: const Duration(milliseconds: 200),

                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: Colors.white.withOpacity(.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // =============================================================
                  // NUMBER
                  // =============================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xff7C4DFF).withOpacity(.25),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Text(
                      '${widget.index + 1}',

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // =================================================================
              // EXPANDED DETAILS
              // =================================================================
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),

                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,

                firstChild: const SizedBox.shrink(),

                secondChild: _ExpandedEquipmentDetails(equipment: equipment),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EXPANDED EQUIPMENT DETAILS
// =============================================================================

class _ExpandedEquipmentDetails extends StatelessWidget {
  final _EquipmentData equipment;

  const _ExpandedEquipmentDetails({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const SizedBox(height: 14),

        Divider(color: Colors.white.withOpacity(.12)),

        const SizedBox(height: 14),

        // =====================================================================
        // LARGE IMAGE
        // =====================================================================
        if (equipment.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),

            child: Container(
              width: double.infinity,
              height: 220,

              color: Colors.white,

              child: Image.network(
                equipment.imageUrl,

                fit: BoxFit.contain,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },

                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 42,
                    ),
                  );
                },
              ),
            ),
          ),

        // =====================================================================
        // NAME
        // =====================================================================
        const SizedBox(height: 16),

        Text(
          equipment.name,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // =====================================================================
        // CATEGORY
        // =====================================================================
        if (equipment.category.isNotEmpty) ...[
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

            decoration: BoxDecoration(
              color: const Color(0xff7C4DFF).withOpacity(.18),
              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: const Color(0xff7C4DFF).withOpacity(.25),
              ),
            ),

            child: Text(
              equipment.category,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // =====================================================================
        // DESCRIPTION
        // =====================================================================
        if (equipment.description.isNotEmpty) ...[
          const SizedBox(height: 16),

          const Text(
            'About this equipment',

            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            equipment.description,

            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],

        const SizedBox(height: 4),
      ],
    );
  }
}

// =============================================================================
// EQUIPMENT IMAGE
// =============================================================================

class _EquipmentImage extends StatelessWidget {
  final String imageUrl;

  const _EquipmentImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const double size = 115;

    // -------------------------------------------------------------------------
    // NO IMAGE
    // -------------------------------------------------------------------------

    if (imageUrl.trim().isEmpty) {
      return Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(18),
        ),

        child: const Icon(
          Icons.fitness_center,
          color: Colors.white54,
          size: 40,
        ),
      );
    }

    // -------------------------------------------------------------------------
    // IMAGE
    // -------------------------------------------------------------------------

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),

      child: Container(
        width: size,
        height: size,

        color: Colors.white,

        child: Image.network(
          imageUrl,

          width: size,
          height: size,

          fit: BoxFit.cover,

          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },

          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
                size: 36,
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// SMALL INFO ROW
// =============================================================================

class _SmallInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white70),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
