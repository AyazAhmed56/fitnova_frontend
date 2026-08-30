import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exercise_db_model.dart';
import 'exercise_db_service.dart';

class ExerciseCatalogImporter {
  final ExerciseDBService _exerciseDB = ExerciseDBService();
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _table = 'exercise_catalog';

  // ExerciseDB supports cursor pagination.
  static const int _pageLimit = 100;

  // Supabase batch size.
  static const int _batchSize = 50;

  // Small delay between API pages.
  static const Duration _delayBetweenPages = Duration(milliseconds: 700);

  Future<void> importAllExercises() async {
    print('');
    print('========================================');
    print('       EXERCISE CATALOG IMPORT');
    print('========================================');

    String? cursor;

    int pageNumber = 0;
    int totalFetched = 0;
    int totalUploaded = 0;

    // Prevent duplicate processing during this import.
    final Set<String> processedIds = <String>{};

    try {
      while (true) {
        pageNumber++;

        print('');
        print('----------------------------------------');
        print('ExerciseDB PAGE $pageNumber');
        print('----------------------------------------');

        final ExerciseDBPage page = await _fetchWithRetry(cursor: cursor);

        final int received = page.exercises.length;

        print('Exercises received: $received');
        print('API total: ${page.total}');
        print('Has next page: ${page.hasNextPage}');
        print('Next cursor: ${page.nextCursor}');

        totalFetched += received;

        // Remove invalid/duplicate IDs.
        final List<ExerciseDBModel> uniqueExercises = page.exercises.where((
          exercise,
        ) {
          if (exercise.exerciseDbId.isEmpty) {
            return false;
          }

          return processedIds.add(exercise.exerciseDbId);
        }).toList();

        print(
          'Unique exercises in page: '
          '${uniqueExercises.length}',
        );

        if (uniqueExercises.isNotEmpty) {
          await _saveBatch(uniqueExercises);

          totalUploaded += uniqueExercises.length;

          print(
            'Total uploaded this run: '
            '$totalUploaded',
          );
        }

        // Stop when ExerciseDB says there are no more records.
        if (!page.hasNextPage ||
            page.nextCursor == null ||
            page.nextCursor!.isEmpty) {
          break;
        }

        cursor = page.nextCursor;

        await Future.delayed(_delayBetweenPages);
      }

      print('');
      print('========================================');
      print('       IMPORT COMPLETED');
      print('========================================');

      print('Pages processed: $pageNumber');
      print('Exercises fetched: $totalFetched');
      print('Unique exercises processed: $totalUploaded');

      final int databaseCount = await getDatabaseCount();

      print(
        'Exercises currently in Supabase: '
        '$databaseCount',
      );

      print('========================================');
    } catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       IMPORT FAILED');
      print('========================================');

      print('Error: $e');

      print('');
      print('Stack trace:');
      print(stackTrace);

      rethrow;
    }
  }

  Future<ExerciseDBPage> _fetchWithRetry({String? cursor}) async {
    const int maxAttempts = 5;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await _exerciseDB.fetchExercisePage(
          limit: _pageLimit,
          after: cursor,
        );
      } on ExerciseDBRateLimitException {
        if (attempt == maxAttempts) {
          rethrow;
        }

        final int waitSeconds = attempt * 5;

        print(
          'Rate limit reached.'
          ' Waiting $waitSeconds seconds...',
        );

        await Future.delayed(Duration(seconds: waitSeconds));
      } catch (e) {
        if (attempt == maxAttempts) {
          rethrow;
        }

        final int waitSeconds = attempt * 3;

        print(
          'Request failed.'
          ' Retrying in $waitSeconds seconds...',
        );

        await Future.delayed(Duration(seconds: waitSeconds));
      }
    }

    throw Exception('Unable to fetch ExerciseDB page.');
  }

  Future<void> _saveBatch(List<ExerciseDBModel> exercises) async {
    for (int start = 0; start < exercises.length; start += _batchSize) {
      final int end = (start + _batchSize < exercises.length)
          ? start + _batchSize
          : exercises.length;

      final List<Map<String, dynamic>> batch = exercises
          .sublist(start, end)
          .map((exercise) => exercise.toCatalogJson())
          .toList();

      print('Uploading batch: ${batch.length}');

      await _supabase.from(_table).upsert(batch, onConflict: 'exercise_db_id');

      print('Batch uploaded successfully.');
    }
  }

  Future<int> getDatabaseCount() async {
    final response = await _supabase.from(_table).select('id');

    return response.length;
  }
}
