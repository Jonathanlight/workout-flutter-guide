import 'diacritics.g.dart';

const int _combiningMarkStart = 0x0300;
const int _combiningMarkEnd = 0x036F;
const int _ampersand = 0x26;
const int _digitZero = 0x30;
const int _digitNine = 0x39;
const int _lowerA = 0x61;
const int _lowerZ = 0x7A;

/// Normalizes [value] the way the upstream catalog does before matching.
///
/// The result is lower-case, free of diacritics, contains only `[a-z0-9]` and
/// single spaces, and is trimmed. `&` is spelled out as `and` so that
/// `"Arms & Shoulders"` and `"arms and shoulders"` are the same query.
///
/// This is a port of the upstream JavaScript:
///
/// ```js
/// value.toLowerCase()
///   .normalize('NFD')
///   .replace(/[̀-ͯ]/g, '')
///   .replace(/&/g, ' and ')
///   .replace(/[^a-z0-9]+/g, ' ')
///   .trim()
///   .replace(/\s+/g, ' ');
/// ```
///
/// ```dart
/// normalizeSearchText('Café  &  Crème!'); // 'cafe and creme'
/// normalizeSearchText('Pull-up Bar');     // 'pull up bar'
/// ```
String normalizeSearchText(String value) {
  final buffer = StringBuffer();
  var pendingSeparator = false;

  for (final rune in value.toLowerCase().runes) {
    // Combining marks are removed outright, exactly like the upstream strip
    // that follows `normalize('NFD')` -- they must not become a separator.
    if (rune >= _combiningMarkStart && rune <= _combiningMarkEnd) {
      continue;
    }

    if (rune == _ampersand) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write('and');
      pendingSeparator = true;
      continue;
    }

    final folded = diacriticFolding[rune];
    if (folded != null) {
      if (pendingSeparator && buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(folded);
      pendingSeparator = false;
      continue;
    }

    if (_isAsciiAlphanumeric(rune)) {
      if (pendingSeparator && buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.writeCharCode(rune);
      pendingSeparator = false;
      continue;
    }

    // Anything else collapses to a single separator, dropped if it would
    // leave a leading or trailing space.
    if (buffer.isNotEmpty) {
      pendingSeparator = true;
    }
  }

  return buffer.toString();
}

/// Splits [query] into the normalized tokens a search must all match.
///
/// Returns an empty list for a blank query, which means "no token filtering".
List<String> tokenizeSearchQuery(String query) {
  final normalized = normalizeSearchText(query);
  return normalized.isEmpty ? const <String>[] : normalized.split(' ');
}

bool _isAsciiAlphanumeric(int rune) {
  final isDigit = rune >= _digitZero && rune <= _digitNine;
  final isLetter = rune >= _lowerA && rune <= _lowerZ;
  return isDigit || isLetter;
}
