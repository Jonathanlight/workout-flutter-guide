import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

import 'support/file_asset_bundle.dart';

/// Maps a package asset key back to its path in this repository.
String _repositoryPath(String assetKey) =>
    assetKey.substring(FileAssetBundle.packagePrefix.length);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every declared frame exists on disk and is not empty', () {
    final missing = <String>[];
    final empty = <String>[];
    for (final exercise in WorkoutGuide.exercises) {
      for (final frame in exercise.frames) {
        final file = File(_repositoryPath(frame.assetPath));
        if (!file.existsSync()) {
          missing.add(file.path);
        } else if (file.lengthSync() == 0) {
          empty.add(file.path);
        }
      }
    }
    expect(missing, isEmpty, reason: 'missing asset files');
    expect(empty, isEmpty, reason: 'empty asset files');
  });

  test('assets/ holds exactly the 906 SVG frames and nothing else', () {
    final files = Directory('assets/exercises')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path)
        .toList();
    expect(files, hasLength(906));
    expect(
      files.where((path) => !path.endsWith('.svg')),
      isEmpty,
      reason: 'only SVG files belong here -- no PNG variants',
    );
  });

  test('pubspec declares every asset directory the catalog needs', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final exercise in WorkoutGuide.exercises) {
      expect(
        pubspec,
        contains('- assets/exercises/${exercise.slug}/'),
        reason: '${exercise.slug} is missing from the pubspec assets block',
      );
    }
  });

  test('every frame is a 512 x 512 SVG', () {
    for (final exercise in WorkoutGuide.exercises) {
      for (final frame in exercise.frames) {
        final head = File(_repositoryPath(frame.assetPath))
            .readAsStringSync()
            .substring(0, 200);
        expect(head, startsWith('<svg '), reason: frame.assetPath);
        expect(head, contains('width="512"'), reason: frame.assetPath);
        expect(head, contains('height="512"'), reason: frame.assetPath);
        expect(
          head,
          contains('viewBox="0 0 512 512"'),
          reason: frame.assetPath,
        );
      }
    }
  });

  test(
    'flutter_svg parses all 906 frames',
    () async {
      final failures = <String>[];
      for (final exercise in WorkoutGuide.exercises) {
        for (final frame in exercise.frames) {
          final source =
              File(_repositoryPath(frame.assetPath)).readAsStringSync();
          try {
            await SvgStringLoader(source).loadBytes(null);
          } on Object catch (error) {
            failures.add('${frame.assetPath}: $error');
          }
        }
      }
      expect(failures, isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
