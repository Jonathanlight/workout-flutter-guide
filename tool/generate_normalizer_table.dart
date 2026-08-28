// Generates `lib/src/catalog/diacritics.g.dart`.
//
// Usage:
//   dart run tool/generate_normalizer_table.dart [path/to/UnicodeData.txt]
//
// Upstream normalizes search text with `String.prototype.normalize('NFD')`
// followed by a strip of the combining marks in U+0300..U+036F. Dart has no
// Unicode normalization in its core library and this package takes no runtime
// dependency for it, so we precompute the only part of NFD that survives the
// subsequent `[^a-z0-9]+ -> ' '` collapse: code points whose canonical
// decomposition is an ASCII alphanumeric followed only by combining marks.
//
// Everything else decomposes to something outside `[a-z0-9]` and therefore
// collapses to a space in both implementations, so it needs no entry.
//
// Without an argument the script downloads UnicodeData.txt from unicode.org.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _unicodeDataUrl =
    'https://www.unicode.org/Public/UCD/latest/ucd/UnicodeData.txt';

const _combiningStart = 0x0300;
const _combiningEnd = 0x036F;

Future<void> main(List<String> args) async {
  final source = args.isEmpty
      ? await _download(_unicodeDataUrl)
      : File(args.single).readAsStringSync();

  final decompositions = _parseCanonicalDecompositions(source);
  final folding = <int, String>{};

  for (final codePoint in decompositions.keys) {
    final base = _foldToAscii(codePoint, decompositions);
    if (base != null) {
      folding[codePoint] = base;
    }
  }

  final sorted = folding.keys.toList()..sort();
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE -- DO NOT EDIT.')
    ..writeln('// Run `dart run tool/generate_normalizer_table.dart`.')
    ..writeln('//')
    ..writeln('// Source: $_unicodeDataUrl')
    ..writeln('// ${sorted.length} code points fold to an ASCII base.')
    ..writeln()
    ..writeln('/// Maps a code point to the ASCII character its canonical')
    ..writeln('/// decomposition starts with, lower-cased.')
    ..writeln('///')
    ..writeln('/// Used by `normalizeSearchText` to reproduce the upstream')
    ..writeln("/// `normalize('NFD')` + combining-mark strip without pulling")
    ..writeln('/// in a Unicode normalization dependency.')
    ..writeln('const Map<int, String> diacriticFolding = <int, String>{');
  for (final codePoint in sorted) {
    final hex = codePoint.toRadixString(16).toUpperCase().padLeft(4, '0');
    buffer.writeln("  0x$hex: '${folding[codePoint]}',");
  }
  buffer.writeln('};');

  final target = File(
    p.join(_packageRoot(), 'lib', 'src', 'catalog', 'diacritics.g.dart'),
  )..writeAsStringSync(buffer.toString());

  final format = Process.runSync('dart', ['format', target.path]);
  if (format.exitCode != 0) {
    stderr.writeln(format.stderr);
    exit(format.exitCode);
  }

  stdout.writeln('wrote ${sorted.length} entries to ${target.path}');
}

/// Parses `UnicodeData.txt` into `code point -> canonical decomposition`.
///
/// Compatibility decompositions (field 5 starts with a `<tag>`) are skipped:
/// NFD does not apply them.
Map<int, List<int>> _parseCanonicalDecompositions(String source) {
  final result = <int, List<int>>{};
  for (final line in const LineSplitter().convert(source)) {
    if (line.isEmpty) continue;
    final fields = line.split(';');
    if (fields.length < 6) continue;
    final decomposition = fields[5];
    if (decomposition.isEmpty || decomposition.startsWith('<')) continue;
    final codePoint = int.parse(fields[0], radix: 16);
    result[codePoint] = decomposition
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => int.parse(part, radix: 16))
        .toList();
  }
  return result;
}

/// Recursively decomposes [codePoint] and returns the lower-cased ASCII
/// alphanumeric it reduces to, or `null` when it reduces to anything else.
String? _foldToAscii(int codePoint, Map<int, List<int>> decompositions) {
  final expanded = _expand(codePoint, decompositions, 0);
  if (expanded == null || expanded.isEmpty) return null;
  final base = expanded.first;
  final marksOnly = expanded
      .skip(1)
      .every((cp) => cp >= _combiningStart && cp <= _combiningEnd);
  if (!marksOnly) return null;
  final character = String.fromCharCode(base).toLowerCase();
  return _isAsciiAlphanumeric(character) ? character : null;
}

List<int>? _expand(
  int codePoint,
  Map<int, List<int>> decompositions,
  int depth,
) {
  if (depth > 8) return null;
  final decomposition = decompositions[codePoint];
  if (decomposition == null) return <int>[codePoint];
  final result = <int>[];
  for (final part in decomposition) {
    final expanded = _expand(part, decompositions, depth + 1);
    if (expanded == null) return null;
    result.addAll(expanded);
  }
  return result;
}

bool _isAsciiAlphanumeric(String character) {
  if (character.length != 1) return false;
  final code = character.codeUnitAt(0);
  final isDigit = code >= 0x30 && code <= 0x39;
  final isLetter = code >= 0x61 && code <= 0x7A;
  return isDigit || isLetter;
}

Future<String> _download(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln('GET $url returned ${response.statusCode}');
      exit(1);
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
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
