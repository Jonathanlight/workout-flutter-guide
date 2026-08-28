import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

List<Map<String, Object?>> _readManifest() =>
    (jsonDecode(File('assets/manifest.json').readAsStringSync()) as List)
        .cast<Map<String, Object?>>();

void main() {
  group('generated catalog', () {
    test('is identical to the manifest it was generated from', () {
      final manifest = _readManifest();
      expect(manifest, hasLength(WorkoutGuide.exercises.length));

      for (var i = 0; i < manifest.length; i++) {
        final fromJson = Exercise.fromJson(manifest[i]);
        expect(
          fromJson,
          WorkoutGuide.exercises[i],
          reason: 'entry $i (${manifest[i]['slug']}) drifted from the manifest',
        );
      }
    });

    test('round-trips back to the manifest JSON', () {
      final manifest = _readManifest();
      for (var i = 0; i < manifest.length; i++) {
        expect(
          WorkoutGuide.exercises[i].toJson(),
          manifest[i],
          reason: 'entry $i (${manifest[i]['slug']}) does not round-trip',
        );
      }
    });
  });

  group('Exercise', () {
    late Exercise pushUp;

    setUp(() => pushUp = WorkoutGuide.getExercise('push-up')!);

    test('exposes its frames by name and by index', () {
      expect(pushUp.startFrame, pushUp.frames[0]);
      expect(pushUp.midFrame, pushUp.frames[1]);
      expect(pushUp.endFrame, pushUp.frames[2]);
      expect(pushUp.frame(1), pushUp.startFrame);
      expect(pushUp.frame(3), pushUp.endFrame);
    });

    test('rejects an out-of-range frame', () {
      expect(() => pushUp.frame(0), throwsRangeError);
      expect(() => pushUp.frame(4), throwsRangeError);
      expect(() => pushUp.assetPath(0), throwsRangeError);
    });

    test('lists every muscle without repeating the primary one', () {
      final muscles = pushUp.allMuscles;
      expect(muscles.first, pushUp.primaryMuscle);
      expect(muscles.toSet(), hasLength(muscles.length));
    });

    test('knows whether it needs equipment', () {
      expect(pushUp.isBodyweight, isTrue);
      expect(WorkoutGuide.getExercise('bench-press')!.isBodyweight, isFalse);
    });

    test('has unmodifiable lists', () {
      expect(() => pushUp.frames.clear(), throwsUnsupportedError);
      expect(() => pushUp.secondaryMuscles.clear(), throwsUnsupportedError);
    });

    test('compares structurally', () {
      final manifest = _readManifest();
      final copy = Exercise.fromJson(
        manifest.firstWhere((entry) => entry['slug'] == 'push-up'),
      );
      expect(copy, pushUp);
      expect(copy.hashCode, pushUp.hashCode);
      expect(pushUp == WorkoutGuide.getExercise('bench-press'), isFalse);
    });
  });

  group('ExerciseFrame', () {
    test('derives the package asset key from the upstream path', () {
      final frame = WorkoutGuide.getExercise('push-up')!.frames.first;
      expect(frame.path, 'assets/push-up/frame-1.svg');
      expect(
        frame.assetPath,
        'packages/workout_flutter_guide/assets/exercises/push-up/frame-1.svg',
      );
    });

    test('is always a 512 square SVG', () {
      for (final exercise in WorkoutGuide.exercises) {
        for (final frame in exercise.frames) {
          expect(frame.width, 512);
          expect(frame.height, 512);
          expect(frame.format, 'svg');
        }
      }
    });
  });

  group('enums', () {
    test('keep the upstream labels', () {
      expect(ExerciseType.weightReps.label, 'weight_reps');
      expect(Equipment.pullUpBar.label, 'Pull-up Bar');
      expect(Muscle.lowerBack.label, 'Lower Back');
    });

    test('resolve a label, normalized or not', () {
      expect(Equipment.tryFromLabel('Pull-up Bar'), Equipment.pullUpBar);
      expect(Equipment.tryFromLabel('pull up bar'), Equipment.pullUpBar);
      expect(Muscle.tryFromLabel('REAR DELTS'), Muscle.rearDelts);
      expect(
        ExerciseType.tryFromLabel('distance_duration'),
        ExerciseType.distanceDuration,
      );
    });

    test('return null or throw on an unknown label', () {
      expect(Equipment.tryFromLabel('Jetpack'), isNull);
      expect(() => Equipment.fromLabel('Jetpack'), throwsArgumentError);
      expect(Muscle.tryFromLabel(''), isNull);
      expect(() => ExerciseType.fromLabel('reps'), throwsArgumentError);
    });

    test('cover every value the catalog actually uses', () {
      final equipment = <Equipment>{};
      final primary = <Muscle>{};
      final secondary = <Muscle>{};
      final types = <ExerciseType>{};
      for (final exercise in WorkoutGuide.exercises) {
        equipment.add(exercise.equipment);
        primary.add(exercise.primaryMuscle);
        secondary.addAll(exercise.secondaryMuscles);
        types.add(exercise.exerciseType);
      }
      expect(equipment, hasLength(Equipment.values.length));
      expect(types, hasLength(ExerciseType.values.length));
      expect(primary, unorderedEquals(Muscle.primaryValues));
      expect(
        secondary.difference(primary),
        <Muscle>{Muscle.cardio, Muscle.grip, Muscle.groin},
        reason: 'these three only ever appear as secondary muscles',
      );
    });
  });

  group('attribution', () {
    test('is never stripped', () {
      for (final exercise in WorkoutGuide.exercises) {
        for (final frame in exercise.frames) {
          expect(frame.attribution.creator, 'Bryl Lim');
          expect(frame.attribution.license, 'CC BY-SA 4.0');
          expect(
            frame.attribution.licenseUrl,
            'https://creativecommons.org/licenses/by-sa/4.0/',
          );
        }
      }
    });

    test('round-trips through JSON', () {
      final withSource = WorkoutGuide.exercises
          .firstWhere((exercise) => exercise.attribution.source != null)
          .attribution;
      expect(
        ExerciseAttribution.fromJson(withSource.toJson()),
        withSource,
      );
      final withoutSource = WorkoutGuide.exercises
          .firstWhere((exercise) => exercise.attribution.source == null)
          .attribution;
      expect(withoutSource.toJson().containsKey('source'), isFalse);
      expect(
        ExerciseAttribution.fromJson(withoutSource.toJson()),
        withoutSource,
      );
    });
  });
}
