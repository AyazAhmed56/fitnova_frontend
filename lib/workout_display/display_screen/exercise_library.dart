import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exercise_catalog_model.dart';
import '../services/exercise_catalog_service.dart';
import 'exercise_details.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final ExerciseCatalogService _catalogService = ExerciseCatalogService();

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  final List<ExerciseCatalogModel> _exercises = [];

  int _currentPage = 0;
  int _totalExercises = 0;

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String _search = '';

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadInitialData();
  }

  // ===========================================================================
  // INITIAL LOAD
  // ===========================================================================

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMore = true;
      _exercises.clear();
    });

    try {
      final results = await Future.wait([
        _catalogService.getExercisesPage(page: 0, search: _search),
        _catalogService.getExerciseCount(),
      ]);

      final ExerciseCatalogPage page = results[0] as ExerciseCatalogPage;

      final int count = results[1] as int;

      if (!mounted) return;

      setState(() {
        _exercises.addAll(page.exercises);

        _currentPage = 0;
        _hasMore = page.hasMore;

        _totalExercises = count;

        _isInitialLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitialLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

  // ===========================================================================
  // LOAD MORE
  // ===========================================================================

  Future<void> _loadMoreExercises() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final int nextPage = _currentPage + 1;

      final ExerciseCatalogPage result = await _catalogService.getExercisesPage(
        page: nextPage,
        search: _search,
      );

      if (!mounted) return;

      setState(() {
        _exercises.addAll(result.exercises);

        _currentPage = nextPage;
        _hasMore = result.hasMore;

        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load more exercises.\n${_cleanErrorMessage(e)}',
          ),
          action: SnackBarAction(label: 'Retry', onPressed: _loadMoreExercises),
        ),
      );
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

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (!mounted) return;

    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _currentPage = 0;
      _hasMore = true;
      _exercises.clear();
    });

    try {
      final ExerciseCatalogPage result = await _catalogService.getExercisesPage(
        page: 0,
        search: _search,
      );

      if (!mounted) return;

      setState(() {
        _exercises.addAll(result.exercises);

        _currentPage = 0;
        _hasMore = result.hasMore;

        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isInitialLoading = false;
        _errorMessage = _cleanErrorMessage(e);
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();

    _searchDebounce?.cancel();

    setState(() {
      _search = '';
    });

    _performSearch();
  }

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _openExerciseDetails(ExerciseCatalogModel exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailsScreen(exercise: exercise),
      ),
    );
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/workout_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'Exercise Library',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ===============================================================
              // HEADER
              // ===============================================================
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

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Exercise Library',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _totalExercises > 0
                                  ? '$_totalExercises exercises available'
                                  : 'Browse all exercises',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_totalExercises > 0)
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
                            '${_exercises.length}/$_totalExercises',
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

              // ===============================================================
              // SEARCH BAR
              // ===============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),

                    suffixIcon: _searchController.text.isNotEmpty
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

              // ===============================================================
              // SEARCH RESULT INFO
              // ===============================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _search.trim().isEmpty
                            ? 'All Exercises'
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
                      '${_exercises.length} loaded',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ===============================================================
              // CONTENT
              // ===============================================================
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
    if (_isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_exercises.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _performSearch,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),

        itemCount: _exercises.length + (_hasMore ? 1 : 0),

        itemBuilder: (context, index) {
          // ================================================================
          // MORE EXERCISES BUTTON
          // ================================================================

          if (index == _exercises.length) {
            return _buildMoreButton();
          }

          final ExerciseCatalogModel exercise = _exercises[index];

          return _CatalogExerciseCard(
            exercise: exercise,
            index: index,
            onTap: () => _openExerciseDetails(exercise),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // MORE BUTTON
  // ===========================================================================

  Widget _buildMoreButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _isLoadingMore ? null : _loadMoreExercises,

          icon: _isLoadingMore
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.expand_more),

          label: Text(
            _isLoadingMore ? 'Loading exercises...' : 'More Exercises',
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff7C4DFF),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xff7C4DFF).withOpacity(.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY
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
              'No exercises found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _search.isEmpty
                  ? 'No exercises are available right now.'
                  : 'Try searching with another exercise name.',
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
  // ERROR
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
              'Unable to load exercises',
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
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
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
}

// =============================================================================
// CATALOG EXERCISE CARD
// =============================================================================

class _CatalogExerciseCard extends StatelessWidget {
  final ExerciseCatalogModel exercise;
  final int index;
  final VoidCallback onTap;

  const _CatalogExerciseCard({
    required this.exercise,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // GIF
              // ==============================================================
              _ExerciseGif(gifUrl: exercise.gifUrl),

              const SizedBox(width: 14),

              // ==============================================================
              // DETAILS
              // ==============================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (exercise.bodyParts.isNotEmpty)
                      _SmallInfoRow(
                        icon: Icons.accessibility_new,
                        text: exercise.bodyParts.join(', '),
                      ),

                    if (exercise.targetMuscles.isNotEmpty) ...[
                      const SizedBox(height: 6),

                      _SmallInfoRow(
                        icon: Icons.fitness_center,
                        text: exercise.targetMuscles.join(', '),
                      ),
                    ],

                    if (exercise.equipments.isNotEmpty) ...[
                      const SizedBox(height: 6),

                      _SmallInfoRow(
                        icon: Icons.sports_gymnastics,
                        text: exercise.equipments.join(', '),
                      ),
                    ],

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: Colors.white.withOpacity(.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ==============================================================
              // NUMBER
              // ==============================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff7C4DFF).withOpacity(.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GIF WIDGET
// =============================================================================

class _ExerciseGif extends StatelessWidget {
  final String? gifUrl;

  const _ExerciseGif({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    const double size = 115;

    if (gifUrl == null || gifUrl!.trim().isEmpty) {
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: Image.network(
          gifUrl!,
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
