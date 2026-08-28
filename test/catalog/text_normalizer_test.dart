import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

void main() {
  group('normalizeSearchText', () {
    test('lower-cases and collapses separators', () {
      expect(normalizeSearchText('Bench Press'), 'bench press');
      expect(normalizeSearchText('Pull-up Bar'), 'pull up bar');
      expect(normalizeSearchText('  spaced   out  '), 'spaced out');
      expect(normalizeSearchText('weight_reps'), 'weight reps');
    });

    test('strips diacritics', () {
      expect(normalizeSearchText('Café'), 'cafe');
      expect(normalizeSearchText('crème brûlée'), 'creme brulee');
      expect(normalizeSearchText('Ångström'), 'angstrom');
    });

    test('drops combining marks without leaving a separator', () {
      // 'e' followed by a combining acute accent (U+0301). The mark
      // disappears; it does not become a word boundary.
      expect(normalizeSearchText('the\u0301re'), 'there');
      // The precomposed form gives the same answer.
      expect(normalizeSearchText('th\u00e9re'), 'there');
      // A stray mark with no base letter simply vanishes.
      expect(normalizeSearchText('a\u0301'), 'a');
    });

    test('leaves undecomposable letters as separators, like upstream', () {
      // NFD does not decompose these, so the JavaScript turns them into
      // spaces too.
      expect(normalizeSearchText('straße'), 'stra e');
      expect(normalizeSearchText('æther'), 'ther');
      expect(normalizeSearchText('łódź'), 'odz');
    });

    test('spells out ampersands', () {
      expect(normalizeSearchText('R&B'), 'r and b');
      expect(normalizeSearchText('Arms & Shoulders'), 'arms and shoulders');
      expect(normalizeSearchText('&leading'), 'and leading');
      expect(normalizeSearchText('trailing&'), 'trailing and');
      expect(normalizeSearchText('&'), 'and');
    });

    test('returns an empty string when nothing survives', () {
      expect(normalizeSearchText(''), '');
      expect(normalizeSearchText('   '), '');
      expect(normalizeSearchText('!!! ??? ---'), '');
      expect(normalizeSearchText('中文'), '');
    });

    test('keeps digits', () {
      expect(normalizeSearchText('90/90 Hip Switch'), '90 90 hip switch');
    });
  });

  group('tokenizeSearchQuery', () {
    test('splits on the normalized spaces', () {
      expect(
        tokenizeSearchQuery('  Incline   Dumbbell-Press '),
        <String>['incline', 'dumbbell', 'press'],
      );
    });

    test('is empty for a blank query', () {
      expect(tokenizeSearchQuery(''), isEmpty);
      expect(tokenizeSearchQuery('  ...  '), isEmpty);
    });
  });

  group('parity with the upstream JavaScript', () {
    test('matches every golden case', () {
      final golden = jsonDecode(
        File('test/golden/normalizer_parity.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final cases = (golden['cases']! as List).cast<Map<String, Object?>>();

      expect(cases, hasLength(greaterThan(500)));
      for (final testCase in cases) {
        final input = testCase['input']! as String;
        expect(
          normalizeSearchText(input),
          testCase['expected'],
          reason: 'input: ${jsonEncode(input)}',
        );
      }
    });
  });
}
