import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exercise_db_model.dart';

class ExerciseDBService {
  static const String _baseUrl = 'https://oss.exercisedb.dev/api/v1/exercises';

  static const int defaultLimit = 100;

  Future<ExerciseDBPage> fetchExercisePage({
    int limit = defaultLimit,
    String? after,
  }) async {
    final Map<String, String> queryParameters = {'limit': limit.toString()};

    if (after != null && after.isNotEmpty) {
      queryParameters['after'] = after;
    }

    final Uri uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: queryParameters);

    print('');
    print('ExerciseDB request:');
    print(uri);

    final http.Response response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    print(
      'ExerciseDB status: '
      '${response.statusCode}',
    );

    if (response.statusCode == 429) {
      throw ExerciseDBRateLimitException('ExerciseDB rate limit reached.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'ExerciseDB request failed.\n'
        'Status: ${response.statusCode}\n'
        'Message: ${response.reasonPhrase}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid ExerciseDB response.');
    }

    if (decoded['success'] != true) {
      throw Exception('ExerciseDB returned success=false.');
    }

    final dynamic rawData = decoded['data'];

    if (rawData is! List) {
      throw Exception('ExerciseDB data is not a list.');
    }

    final dynamic rawMeta = decoded['meta'];

    final Map<String, dynamic> meta = rawMeta is Map
        ? Map<String, dynamic>.from(rawMeta)
        : {};

    final List<ExerciseDBModel> exercises = rawData
        .whereType<Map>()
        .map(
          (item) => ExerciseDBModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();

    return ExerciseDBPage(
      exercises: exercises,
      total: _parseInt(meta['total']),
      hasNextPage: meta['hasNextPage'] == true,
      nextCursor: meta['nextCursor']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ExerciseDBPage {
  final List<ExerciseDBModel> exercises;
  final int total;
  final bool hasNextPage;
  final String? nextCursor;

  const ExerciseDBPage({
    required this.exercises,
    required this.total,
    required this.hasNextPage,
    required this.nextCursor,
  });
}

class ExerciseDBRateLimitException implements Exception {
  final String message;

  ExerciseDBRateLimitException(this.message);

  @override
  String toString() => message;
}
