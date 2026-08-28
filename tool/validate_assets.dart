// Checks that the bundled artwork matches the catalog that describes it.
//
// Usage:
//   dart run tool/validate_assets.dart
//
// Exits non-zero, with a report, when any of the following is untrue:
//   * the manifest describes 302 exercises with three frames each, indexed
//     1..3;
//   * every declared file exists and is not empty;
//   * every file parses as XML, has an <svg> root, and is 512 x 512;
//   * pubspec.yaml declares every asset directory the catalog references;
//   * nothing but SVG files live under assets/exercises/.
//
// Rendering every frame through flutter_svg needs a Flutter binding, so that
// check lives in test/assets_test.dart and runs with `flutter test`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

const _expectedExercises = 302;
const _expectedFramesPerExercise = 3;
const _expectedSize = '512';

void main() {
  final root = _packageRoot();
  final problems = <String>[];

  final manifestFile = File(p.join(root, 'assets', 'manifest.json'));
  if (!manifestFile.existsSync()) {
    stderr.writeln('validate_assets: assets/manifest.json is missing');
    exit(1);
  }

  final exercises = (jsonDecode(manifestFile.readAsStringSync()) as List)
      .cast<Map<String, Object?>>();
  if (exercises.length != _expectedExercises) {
    problems.add(
      'manifest holds ${exercises.length} exercises, '
      'expected $_expectedExercises',
    );
  }

  final pubspec = File(p.join(root, 'pubspec.yaml')).readAsStringSync();
  final declaredFiles = <String>{};
  var checked = 0;

  for (final exercise in exercises) {
    final slug = exercise['slug']! as String;
    final frames = (exercise['frames']! as List).cast<Map<String, Object?>>();

    if (frames.length != _expectedFramesPerExercise) {
      problems.add('$slug has ${frames.length} frames');
      continue;
    }
    for (var i = 0; i < frames.length; i++) {
      if (frames[i]['index'] != i + 1) {
        problems.add('$slug frame $i is indexed ${frames[i]['index']}');
      }
    }
    if (!pubspec.contains('- assets/exercises/$slug/')) {
      problems.add('pubspec.yaml does not declare assets/exercises/$slug/');
    }

    for (final frame in frames) {
      final index = frame['index']! as int;
      final relative = p.join('assets', 'exercises', slug, 'frame-$index.svg');
      declaredFiles.add(p.join(root, relative));
      final file = File(p.join(root, relative));
      checked++;

      if (!file.existsSync()) {
        problems.add('missing: $relative');
        continue;
      }
      if (file.lengthSync() == 0) {
        problems.add('empty: $relative');
        continue;
      }
      problems.addAll(_validateSvg(file, relative));
    }
  }

  final onDisk = Directory(p.join(root, 'assets', 'exercises'))
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => file.path)
      .toSet();

  for (final path in onDisk.difference(declaredFiles)) {
    problems
        .add('not referenced by the manifest: ${p.relative(path, from: root)}');
  }

  if (problems.isEmpty) {
    stdout.writeln('validate_assets: $checked frames OK');
    return;
  }

  stderr.writeln('validate_assets: ${problems.length} problem(s)');
  for (final problem in problems.take(50)) {
    stderr.writeln('  - $problem');
  }
  if (problems.length > 50) {
    stderr.writeln('  ... and ${problems.length - 50} more');
  }
  exit(1);
}

List<String> _validateSvg(File file, String relative) {
  if (!relative.endsWith('.svg')) {
    return <String>['not an SVG: $relative'];
  }

  final XmlDocument document;
  try {
    document = XmlDocument.parse(file.readAsStringSync());
  } on XmlException catch (error) {
    return <String>['does not parse as XML: $relative ($error)'];
  }

  final root = document.rootElement;
  if (root.name.local != 'svg') {
    return <String>['root element is <${root.name.local}>: $relative'];
  }

  final problems = <String>[];
  final width = root.getAttribute('width');
  final height = root.getAttribute('height');
  final viewBox = root.getAttribute('viewBox');
  if (width != _expectedSize || height != _expectedSize) {
    problems.add('is ${width}x$height, expected '
        '${_expectedSize}x$_expectedSize: $relative');
  }
  if (viewBox != '0 0 $_expectedSize $_expectedSize') {
    problems.add('has viewBox "$viewBox": $relative');
  }
  return problems;
}

String _packageRoot() {
  var directory = Directory.current;
  while (!File(p.join(directory.path, 'pubspec.yaml')).existsSync()) {
    final parent = directory.parent;
    if (parent.path == directory.path) {
      stderr.writeln('run this script from inside the package');
      exit(1);
    }
    directory = parent;
  }
  return directory.path;
}
