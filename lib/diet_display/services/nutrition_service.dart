import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/nutrition_food.dart';

class NutritionService {
  // Use the same Railway URL as your FitNova AI backend.
  // Change only this one line if your deployment URL changes.
  static const String baseUrl =
      'https://fitnovabackend-production.up.railway.app';

  Future<NutritionSearchResponse> searchNutrition(
    String query, {
    int limit = 20,
  }) async {
    final cleaned = query.trim();

    if (cleaned.isEmpty) {
      throw Exception('Please enter a nutrition to search.');
    }

    final uri = Uri.parse(
      '$baseUrl/nutrition/search',
    ).replace(
      queryParameters: {
        'query': cleaned,
        'limit': '$limit',
      },
    );

    final response = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 40));

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid nutrition response.');
      }

      return NutritionSearchResponse.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    }

    String message = 'Nutrition search failed.';

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) {
        message = decoded['detail'].toString();
      }
    } catch (_) {
      // Keep default error.
    }

    throw Exception(
      '$message (${response.statusCode})',
    );
  }

  Future<List<Map<String, dynamic>>> getSuggestions() async {
    final uri = Uri.parse('$baseUrl/nutrition/suggestions');

    final response = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }

    return const [];
  }
}
