// Copies the upstream catalog and artwork into this package.
//
// Usage:
//   dart run tool/import_upstream.dart /path/to/bryllim/workout-guide
//
// Only `manifest.json` and the 906 `frame-*.svg` files are copied. PNG
// variants, the upstream site and the upstream scripts are deliberately left
// behind (see CLAUDE.md and docs/specs/004-tooling.md).
//
// The SVG files are copied byte-for-byte: they are CC BY-SA 4.0 material and
// this port does not modify them.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _expectedExercises = 302;
const _expectedFramesPerExercise = 3;

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln(
      'usage: dart run tool/import_upstream.dart <upstream-checkout>',
    );
    exit(64);
  }

  final upstreamRoot = p.normalize(p.absolute(args.single));
  final packageRoot = _findPackageRoot();
  final upstreamPackage = p.join(upstreamRoot, 'packages', 'workout-guide');
  final manifestFile = File(p.join(upstreamPackage, 'manifest.json'));

  if (!manifestFile.existsSync()) {
    _fail('no manifest at ${manifestFile.path}\n'
        'Is $upstreamRoot a checkout of bryllim/workout-guide?');
  }

  final manifestSource = manifestFile.readAsStringSync();
  final exercises = _decodeManifest(manifestSource);
  _validateManifest(exercises);

  final destAssets = Directory(p.join(packageRoot, 'assets', 'exercises'));
  if (destAssets.existsSync()) {
    destAssets.deleteSync(recursive: true);
  }
  destAssets.createSync(recursive: true);

  var copied = 0;
  var bytes = 0;
  final missing = <String>[];

  for (final exercise in exercises) {
    final slug = exercise['slug']! as String;
    final frames = (exercise['frames']! as List).cast<Map<String, Object?>>();
    for (final frame in frames) {
      final relative = frame['path']! as String;
      final source = File(p.join(upstreamPackage, relative));
      if (!source.existsSync()) {
        missing.add(relative);
        continue;
      }
      final index = frame['index']! as int;
      final target = File(
        p.join(destAssets.path, slug, 'frame-$index.svg'),
      );
      target.parent.createSync(recursive: true);
      source.copySync(target.path);
      copied++;
      bytes += target.lengthSync();
    }
  }

  if (missing.isNotEmpty) {
    _fail('${missing.length} frame(s) listed in the manifest are missing '
        'upstream, first: ${missing.first}');
  }

  File(p.join(packageRoot, 'assets', 'manifest.json'))
      .writeAsStringSync(manifestSource);

  final megabytes = (bytes / (1024 * 1024)).toStringAsFixed(1);
  stdout
    ..writeln('imported ${exercises.length} exercises')
    ..writeln('copied $copied SVG frames ($megabytes MB)')
    ..writeln('manifest.json copied verbatim')
    ..writeln('')
    ..writeln('next: dart run tool/generate_catalog.dart');
}

List<Map<String, Object?>> _decodeManifest(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    _fail('manifest.json is not a JSON array');
  }
  return decoded.cast<Map<String, Object?>>();
}

void _validateManifest(List<Map<String, Object?>> exercises) {
  if (exercises.length != _expectedExercises) {
    _fail('expected $_expectedExercises exercises, '
        'found ${exercises.length}');
  }
  final slugs = <String>{};
  for (final exercise in exercises) {
    final slug = exercise['slug'];
    if (slug is! String || !slugs.add(slug)) {
      _fail('missing or duplicated slug: $slug');
    }
    final frames = exercise['frames'];
    if (frames is! List || frames.length != _expectedFramesPerExercise) {
      _fail('$slug does not have $_expectedFramesPerExercise frames');
    }
  }
}

String _findPackageRoot() {
  var directory = Directory.current;
  while (true) {
    if (File(p.join(directory.path, 'pubspec.yaml')).existsSync()) {
      return directory.path;
    }
    final parent = directory.parent;
    if (parent.path == directory.path) {
      _fail('run this script from inside the package');
    }
    directory = parent;
  }
}

Never _fail(String message) {
  stderr.writeln('import_upstream: $message');
  exit(1);
}
