import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

void main() {
  group('exercises', () {
    test('holds the whole catalog in manifest order', () {
      expect(WorkoutGuide.exercises, hasLength(302));
      expect(WorkoutGuide.exercises.first.slug, 'bench-press');
    });

    test('is unmodifiable', () {
      expect(
        () => WorkoutGuide.exercises.clear(),
        throwsUnsupportedError,
      );
    });

    test('every id follows the exercise-<slug> convention', () {
      for (final exercise in WorkoutGuide.exercises) {
        expect(exercise.id, 'exercise-${exercise.slug}');
      }
    });

    test('every exercise inherits the attribution of its first frame', () {
      for (final exercise in WorkoutGuide.exercises) {
        expect(
          exercise.attribution,
          exercise.frames.first.attribution,
          reason: exercise.slug,
        );
      }
    });

    test('keeps the upstream Everkinetic sources on 76 frames', () {
      final withSource = <ExerciseFrame>[
        for (final exercise in WorkoutGuide.exercises)
          for (final frame in exercise.frames)
            if (frame.attribution.source != null) frame,
      ];
      expect(withSource, hasLength(76));
      for (final frame in withSource) {
        final source = frame.attribution.source!;
        expect(frame.index, 1, reason: 'only first poses are adaptations');
        expect(source.name, 'Everkinetic');
        expect(source.url, startsWith('https://github.com/everkinetic/data'));
        expect(source.license, 'CC BY-SA 4.0');
        expect(source.changes, isNotEmpty);
      }
    });

    test('exposes exactly 14 stretches', () {
      expect(WorkoutGuide.stretches, hasLength(14));
      expect(
        WorkoutGuide.stretches.every((exercise) => exercise.isStretch),
        isTrue,
      );
    });
  });

  group('getExercise', () {
    test('finds by id and by slug', () {
      final byId = WorkoutGuide.getExercise('exercise-bench-press');
      final bySlug = WorkoutGuide.getExercise('bench-press');
      expect(byId, isNotNull);
      expect(byId, bySlug);
    });

    test('returns null for anything else', () {
      expect(WorkoutGuide.getExercise(''), isNull);
      expect(WorkoutGuide.getExercise('Bench-Press'), isNull);
      expect(WorkoutGuide.getExercise('bench press'), isNull);
      expect(WorkoutGuide.getExercise('nope'), isNull);
    });
  });

  group('search', () {
    test('an empty query returns everything', () {
      expect(WorkoutGuide.search(''), hasLength(302));
      expect(WorkoutGuide.search('   '), hasLength(302));
    });

    test('requires every token to match', () {
      final incline = WorkoutGuide.search('incline dumbbell');
      expect(incline, isNotEmpty);
      for (final exercise in incline) {
        expect(exercise.name.toLowerCase(), contains('incline'));
      }
      expect(WorkoutGuide.search('incline unicorn'), isEmpty);
    });

    test('matches substrings, not just whole words', () {
      expect(
        WorkoutGuide.search('ench').map((exercise) => exercise.slug),
        contains('bench-press'),
      );
    });

    test('searches secondary muscles too', () {
      final results = WorkoutGuide.search('triceps');
      expect(
        results.any((exercise) => exercise.primaryMuscle != Muscle.triceps),
        isTrue,
        reason: 'some hits should come from secondaryMuscles',
      );
    });

    test('is diacritic and punctuation insensitive', () {
      expect(
        WorkoutGuide.search('pull-up bar').map((exercise) => exercise.slug),
        WorkoutGuide.search('pull up bar').map((exercise) => exercise.slug),
      );
    });

    test('keeps catalog order', () {
      final results = WorkoutGuide.search('press');
      final indices = <int>[
        for (final exercise in results)
          WorkoutGuide.exercises.indexOf(exercise),
      ];
      expect(indices, orderedEquals(List<int>.of(indices)..sort()));
    });

    group('filters', () {
      test('accept a string label', () {
        final results = WorkoutGuide.search('', equipment: 'Pull-up Bar');
        expect(results, isNotEmpty);
        expect(
          results.every((e) => e.equipment == Equipment.pullUpBar),
          isTrue,
        );
      });

      test('accept a normalized string label', () {
        expect(
          WorkoutGuide.search('', equipment: 'pull up bar'),
          WorkoutGuide.search('', equipment: Equipment.pullUpBar),
        );
      });

      test('accept an enum value', () {
        final results = WorkoutGuide.search(
          '',
          exerciseType: ExerciseType.duration,
        );
        expect(results, isNotEmpty);
        expect(
          results.every((e) => e.exerciseType == ExerciseType.duration),
          isTrue,
        );
      });

      test('OR the values within one filter', () {
        final barbell = WorkoutGuide.search('', equipment: Equipment.barbell);
        final dumbbell = WorkoutGuide.search('', equipment: Equipment.dumbbell);
        final both = WorkoutGuide.search(
          '',
          equipment: <Equipment>[Equipment.barbell, Equipment.dumbbell],
        );
        expect(both, hasLength(barbell.length + dumbbell.length));
      });

      test('AND the different filters', () {
        final results = WorkoutGuide.search(
          '',
          equipment: Equipment.dumbbell,
          primaryMuscle: Muscle.shoulders,
        );
        expect(results, isNotEmpty);
        for (final exercise in results) {
          expect(exercise.equipment, Equipment.dumbbell);
          expect(exercise.primaryMuscle, Muscle.shoulders);
        }
      });

      test('an empty filter list matches nothing', () {
        expect(WorkoutGuide.search('', equipment: <String>[]), isEmpty);
      });

      test('isStretch filters both ways', () {
        expect(WorkoutGuide.search('', isStretch: true), hasLength(14));
        expect(WorkoutGuide.search('', isStretch: false), hasLength(288));
      });

      test('an unknown label matches nothing rather than throwing', () {
        expect(WorkoutGuide.search('', equipment: 'Jetpack'), isEmpty);
      });

      test('a wrong type throws ArgumentError', () {
        expect(
          () => WorkoutGuide.search('', equipment: 42),
          throwsArgumentError,
        );
        expect(
          () => WorkoutGuide.search('', primaryMuscle: <int>[1]),
          throwsArgumentError,
        );
      });
    });

    group('shorthands', () {
      test('match the equivalent search call', () {
        expect(
          WorkoutGuide.byEquipment(Equipment.kettlebell),
          WorkoutGuide.search('', equipment: Equipment.kettlebell),
        );
        expect(
          WorkoutGuide.byPrimaryMuscle(Muscle.lats),
          WorkoutGuide.search('', primaryMuscle: Muscle.lats),
        );
        expect(
          WorkoutGuide.byExerciseType(ExerciseType.weightReps),
          WorkoutGuide.search('', exerciseType: ExerciseType.weightReps),
        );
      });
    });
  });

  group('assetPath', () {
    test('points at the bundled package asset', () {
      expect(
        WorkoutGuide.assetPath('push-up', 1),
        'packages/workout_flutter_guide/assets/exercises/push-up/frame-1.svg',
      );
    });

    test('agrees with the exercise and frame accessors', () {
      final pushUp = WorkoutGuide.getExercise('push-up')!;
      expect(WorkoutGuide.assetPath('push-up', 2), pushUp.assetPath(2));
      expect(pushUp.assetPath(2), pushUp.frames[1].assetPath);
    });

    test('returns null out of range or for an unknown exercise', () {
      expect(WorkoutGuide.assetPath('push-up', 0), isNull);
      expect(WorkoutGuide.assetPath('push-up', 4), isNull);
      expect(WorkoutGuide.assetPath('nope', 1), isNull);
    });
  });

  group('assetCdnUrl', () {
    test('reproduces the upstream jsDelivr URL', () {
      expect(
        WorkoutGuide.assetCdnUrl('push-up', 2),
        'https://cdn.jsdelivr.net/npm/@bryllim/workout-guide@1.0.0'
        '/assets/push-up/frame-2.svg',
      );
    });

    test('honours a custom version', () {
      expect(
        WorkoutGuide.assetCdnUrl('push-up', 1, version: '2.0.0'),
        contains('workout-guide@2.0.0/'),
      );
    });

    test('adds the missing slash to a custom base', () {
      expect(
        WorkoutGuide.assetCdnUrl('push-up', 1, baseUrl: 'https://cdn.test/v1'),
        'https://cdn.test/v1/assets/push-up/frame-1.svg',
      );
      expect(
        WorkoutGuide.assetCdnUrl('push-up', 1, baseUrl: 'https://cdn.test/v1/'),
        'https://cdn.test/v1/assets/push-up/frame-1.svg',
      );
    });

    test('returns null for anything unknown', () {
      expect(WorkoutGuide.assetCdnUrl('nope', 1), isNull);
      expect(WorkoutGuide.assetCdnUrl('push-up', 9), isNull);
    });
  });
}
