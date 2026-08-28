// Turns `assets/manifest.json` into Dart constants.
//
// Usage:
//   dart run tool/generate_catalog.dart
//
// Writes two things:
//   * `lib/src/generated/catalog.g.dart` -- the whole catalog as a
//     `const List<Exercise>`, so `WorkoutGuide.exercises` is available
//     synchronously, with no `rootBundle` read and no JSON parsing at run
//     time.
//   * the assets block of `pubspec.yaml`, between the BEGIN/END markers.
//     Flutter does not glob asset directories recursively, so each of the 302
//     exercise directories has to be listed explicitly.
//
// Repeated attribution objects are hoisted into private constants so the
// generated file stays readable: `_bryl` covers the frames drawn from
// scratch, `_sourceNNN` the ones adapted from Everkinetic artwork.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _beginMarker = '    # BEGIN GENERATED ASSETS';
const _endMarker = '    # END GENERATED ASSETS';

void main() {
  final root = _packageRoot();
  final manifestFile = File(p.join(root, 'assets', 'manifest.json'));
  if (!manifestFile.existsSync()) {
    _fail('assets/manifest.json is missing -- run import_upstream.dart first');
  }

  final exercises = (jsonDecode(manifestFile.readAsStringSync()) as List)
      .cast<Map<String, Object?>>();

  final catalogFile = File(
    p.join(root, 'lib', 'src', 'generated', 'catalog.g.dart'),
  )
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(_renderCatalog(exercises));

  _rewritePubspecAssets(File(p.join(root, 'pubspec.yaml')), exercises);

  final format = Process.runSync('dart', ['format', catalogFile.path]);
  if (format.exitCode != 0) {
    stderr.writeln(format.stderr);
    exit(format.exitCode);
  }

  final lines = catalogFile.readAsLinesSync().length;
  stdout
    ..writeln('wrote ${exercises.length} exercises '
        '($lines lines) to ${p.relative(catalogFile.path, from: root)}')
    ..writeln('updated the assets block of pubspec.yaml');
}

String _renderCatalog(List<Map<String, Object?>> exercises) {
  // Attribution objects repeat: one shared "no upstream source" record, and
  // one record per distinct upstream source URL.
  final sourceConstants = <String, String>{};
  for (final exercise in exercises) {
    for (final frame in _frames(exercise)) {
      final attribution = frame['attribution']! as Map<String, Object?>;
      final source = attribution['source'];
      if (source == null) continue;
      final url = (source as Map<String, Object?>)['url']! as String;
      sourceConstants.putIfAbsent(
        url,
        () => '_source${sourceConstants.length.toString().padLeft(3, '0')}',
      );
    }
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE -- DO NOT EDIT.')
    ..writeln('// Run `dart run tool/generate_catalog.dart` instead.')
    ..writeln('//')
    ..writeln('// Source: assets/manifest.json, copied verbatim from')
    ..writeln('// bryllim/workout-guide v1.0.0. The attribution data below is')
    ..writeln('// part of the CC BY-SA 4.0 terms of the artwork: do not strip')
    ..writeln('// it. See ATTRIBUTION.md.')
    ..writeln()
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("import '../models/attribution.dart';")
    ..writeln("import '../models/enums.dart';")
    ..writeln("import '../models/exercise.dart';")
    ..writeln("import '../models/exercise_frame.dart';")
    ..writeln()
    ..writeln('const ExerciseAttribution _bryl = ExerciseAttribution(')
    ..writeln("  creator: 'Bryl Lim',")
    ..writeln("  creatorUrl: 'https://bryllim.com',")
    ..writeln("  license: 'CC BY-SA 4.0',")
    ..writeln(
      "  licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',",
    )
    ..writeln(');');

  // Emit one constant per distinct upstream source, in first-seen order.
  final emitted = <String>{};
  for (final exercise in exercises) {
    for (final frame in _frames(exercise)) {
      final attribution = frame['attribution']! as Map<String, Object?>;
      final source = attribution['source'] as Map<String, Object?>?;
      if (source == null) continue;
      final url = source['url']! as String;
      final name = sourceConstants[url]!;
      if (!emitted.add(name)) continue;
      buffer
        ..writeln()
        ..writeln('const ExerciseAttribution $name = ExerciseAttribution(')
        ..writeln('  creator: ${_string(attribution['creator']! as String)},')
        ..writeln(
          '  creatorUrl: ${_string(attribution['creatorUrl']! as String)},',
        )
        ..writeln('  license: ${_string(attribution['license']! as String)},')
        ..writeln(
          '  licenseUrl: ${_string(attribution['licenseUrl']! as String)},',
        )
        ..writeln('  source: AttributionSource(')
        ..writeln('    name: ${_string(source['name']! as String)},')
        ..writeln('    url: ${_string(url)},')
        ..writeln('    license: ${_string(source['license']! as String)},')
        ..writeln(
          '    licenseUrl: ${_string(source['licenseUrl']! as String)},',
        )
        ..writeln('    changes: ${_string(source['changes']! as String)},')
        ..writeln('  ),')
        ..writeln(');');
    }
  }

  buffer
    ..writeln()
    ..writeln('/// Every exercise of the catalog, in manifest order.')
    ..writeln('///')
    ..writeln('/// Generated from `assets/manifest.json`. Use')
    ..writeln('/// `WorkoutGuide.exercises` rather than this list directly:')
    ..writeln('/// it is the documented, unmodifiable entry point.')
    ..writeln('const List<Exercise> kExerciseCatalog = <Exercise>[');

  for (final exercise in exercises) {
    final attribution = exercise['attribution']! as Map<String, Object?>;
    final type = _enumValue(
      'ExerciseType',
      exercise['exerciseType']! as String,
    );
    final equipment = _enumValue('Equipment', exercise['equipment']! as String);
    final primaryMuscle = _enumValue(
      'Muscle',
      exercise['primaryMuscle']! as String,
    );
    final secondaryMuscles =
        (exercise['secondaryMuscles']! as List).cast<String>();
    buffer
      ..writeln('  Exercise(')
      ..writeln('    id: ${_string(exercise['id']! as String)},')
      ..writeln('    slug: ${_string(exercise['slug']! as String)},')
      ..writeln('    name: ${_string(exercise['name']! as String)},')
      ..writeln('    exerciseType: $type,')
      ..writeln('    equipment: $equipment,')
      ..writeln('    primaryMuscle: $primaryMuscle,')
      ..writeln('    secondaryMuscles: <Muscle>[');
    for (final muscle in secondaryMuscles) {
      buffer.writeln('      ${_enumValue('Muscle', muscle)},');
    }
    buffer
      ..writeln('    ],')
      ..writeln('    isStretch: ${exercise['isStretch']! as bool},')
      ..writeln('    frames: <ExerciseFrame>[');
    for (final frame in _frames(exercise)) {
      final frameAttribution = frame['attribution']! as Map<String, Object?>;
      final source = frameAttribution['source'] as Map<String, Object?>?;
      final reference =
          source == null ? '_bryl' : sourceConstants[source['url']! as String]!;
      buffer
        ..writeln('      ExerciseFrame(')
        ..writeln('        index: ${frame['index']! as int},')
        ..writeln('        path: ${_string(frame['path']! as String)},')
        ..writeln('        width: ${frame['width']! as int},')
        ..writeln('        height: ${frame['height']! as int},')
        ..writeln('        format: ${_string(frame['format']! as String)},')
        ..writeln('        attribution: $reference,')
        ..writeln('      ),');
    }
    final source = attribution['source'] as Map<String, Object?>?;
    final reference =
        source == null ? '_bryl' : sourceConstants[source['url']! as String]!;
    buffer
      ..writeln('    ],')
      ..writeln('    attribution: $reference,')
      ..writeln('  ),');
  }

  buffer.writeln('];');
  return buffer.toString();
}

void _rewritePubspecAssets(
  File pubspec,
  List<Map<String, Object?>> exercises,
) {
  final lines = pubspec.readAsLinesSync();
  final begin = lines.indexOf(_beginMarker);
  final end = lines.indexOf(_endMarker);
  if (begin < 0 || end < begin) {
    _fail('pubspec.yaml is missing the generated assets markers');
  }

  final slugs = <String>[
    for (final exercise in exercises) exercise['slug']! as String,
  ]..sort();

  final replacement = <String>[
    _beginMarker,
    '    - assets/manifest.json',
    for (final slug in slugs) '    - assets/exercises/$slug/',
    _endMarker,
  ];

  final updated = <String>[
    ...lines.sublist(0, begin),
    ...replacement,
    ...lines.sublist(end + 1),
  ];
  pubspec.writeAsStringSync('${updated.join('\n')}\n');
}

List<Map<String, Object?>> _frames(Map<String, Object?> exercise) =>
    (exercise['frames']! as List).cast<Map<String, Object?>>();

/// Renders [value] as a single-quoted Dart string literal.
String _string(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll(r'$', r'\$')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
  return "'$escaped'";
}

/// Renders an upstream label as the matching Dart enum value.
String _enumValue(String enumName, String label) {
  final words = label
      .replaceAll(RegExp('[^A-Za-z0-9]+'), ' ')
      .trim()
      .toLowerCase()
      .split(' ');
  final buffer = StringBuffer(words.first);
  for (final word in words.skip(1)) {
    buffer
      ..write(word[0].toUpperCase())
      ..write(word.substring(1));
  }
  return '$enumName.$buffer';
}

String _packageRoot() {
  var directory = Directory.current;
  while (!File(p.join(directory.path, 'pubspec.yaml')).existsSync()) {
    final parent = directory.parent;
    if (parent.path == directory.path) {
      _fail('run this script from inside the package');
    }
    directory = parent;
  }
  return directory.path;
}

Never _fail(String message) {
  stderr.writeln('generate_catalog: $message');
  exit(1);
}
