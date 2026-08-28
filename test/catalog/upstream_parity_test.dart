// A 1:1 port of the upstream test suite,
// `packages/workout-guide/test/catalog.test.ts` (bryllim/workout-guide
// v1.0.0). Same cases, same expectations: if this file passes, the Dart
// catalog answers like the JavaScript one.

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

void main() {
  group('exercise catalog', () {
    test('contains 302 unique exercises with three ordered frames', () {
      expect(WorkoutGuide.exercises, hasLength(302));
      expect(
        WorkoutGuide.exercises.map((exercise) => exercise.id).toSet(),
        hasLength(302),
      );
      expect(
        WorkoutGuide.exercises.map((exercise) => exercise.slug).toSet(),
        hasLength(302),
      );
      for (final exercise in WorkoutGuide.exercises) {
        expect(
          exercise.frames.map((frame) => frame.index),
          <int>[1, 2, 3],
          reason: exercise.slug,
        );
        expect(
          exercise.frames.every(
            (frame) => frame.attribution.creator == 'Bryl Lim',
          ),
          isTrue,
          reason: exercise.slug,
        );
      }
    });

    test('looks up exercises by id or slug and returns null for missing', () {
      expect(WorkoutGuide.getExercise('exercise-push-up')?.name, 'Push-up');
      expect(WorkoutGuide.getExercise('push-up')?.id, 'exercise-push-up');
      expect(WorkoutGuide.getExercise('missing'), isNull);
    });

    test('searches across names, equipment, and muscles', () {
      expect(
        WorkoutGuide.search('incline dumbbell')
            .any((exercise) => exercise.slug == 'incline-dumbbell-press'),
        isTrue,
      );
      expect(WorkoutGuide.search('resistance band glutes'), isNotEmpty);
      expect(WorkoutGuide.search('upper back'), isNotEmpty);
    });

    test('combines search and structured filters', () {
      final results = WorkoutGuide.search(
        'press',
        equipment: 'Dumbbell',
        primaryMuscle: 'Shoulders',
      );
      expect(results, isNotEmpty);
      expect(
        results.every((exercise) => exercise.equipment == Equipment.dumbbell),
        isTrue,
      );
      expect(
        WorkoutGuide.search('', isStretch: true)
            .every((exercise) => exercise.isStretch),
        isTrue,
      );
    });

    test('builds CDN asset URLs and handles missing exercises', () {
      expect(
        WorkoutGuide.assetCdnUrl('push-up', 2),
        'https://cdn.jsdelivr.net/npm/@bryllim/workout-guide@1.0.0'
        '/assets/push-up/frame-2.svg',
      );
      expect(WorkoutGuide.assetCdnUrl('missing', 1), isNull);
    });
  });
}
