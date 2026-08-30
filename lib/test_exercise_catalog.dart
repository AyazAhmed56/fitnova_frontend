import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'workout_display/services/exercise_catalog_importer.dart';
import 'workout_display/services/exercise_catalog_service.dart';

Future<void> main() async {
  print('');
  print('========================================');
  print('       EXERCISE CATALOG IMPORT');
  print('========================================');

  // Load .env
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  final SupabaseClient supabase = Supabase.instance.client;

  print('');
  print('SUPABASE STATUS');
  print('----------------------------------------');

  print(
    'Authenticated: '
    '${supabase.auth.currentUser != null}',
  );

  print(
    'User ID: '
    '${supabase.auth.currentUser?.id}',
  );

  final ExerciseCatalogService catalog = ExerciseCatalogService();

  final ExerciseCatalogImporter importer = ExerciseCatalogImporter();

  // ----------------------------------------
  // BEFORE IMPORT
  // ----------------------------------------

  final int beforeCount = await importer.getDatabaseCount();

  print('');
  print('BEFORE IMPORT');
  print('----------------------------------------');
  print(
    'Exercises currently stored: '
    '$beforeCount',
  );

  // ----------------------------------------
  // IMPORT
  // ----------------------------------------

  print('');
  print('STARTING FULL EXERCISEDB IMPORT...');
  print('');

  await importer.importAllExercises();

  // ----------------------------------------
  // AFTER IMPORT
  // ----------------------------------------

  final int afterCount = await importer.getDatabaseCount();

  print('');
  print('AFTER IMPORT');
  print('----------------------------------------');

  print(
    'Exercises currently stored: '
    '$afterCount',
  );

  // ----------------------------------------
  // TEST LOOKUP
  // ----------------------------------------

  print('');
  print('TESTING CATALOG LOOKUP');
  print('----------------------------------------');

  final exercise = await catalog.findByName('upward facing dog');

  if (exercise == null) {
    print('Lookup failed: exercise not found.');
  } else {
    print('Lookup successful!');
    print('Name: ${exercise.exerciseName}');
    print('ID: ${exercise.exerciseDbId}');
    print('GIF: ${exercise.gifUrl}');
    print(
      'Body parts: '
      '${exercise.bodyParts.join(', ')}',
    );
    print(
      'Target muscles: '
      '${exercise.targetMuscles.join(', ')}',
    );
    print(
      'Equipment: '
      '${exercise.equipments.join(', ')}',
    );
    print(
      'Instructions: '
      '${exercise.instructions.length}',
    );
  }

  print('');
  print('========================================');
  print('       IMPORT TEST COMPLETE');
  print('========================================');
}
