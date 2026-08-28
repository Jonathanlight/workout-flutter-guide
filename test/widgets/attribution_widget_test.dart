import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: child)),
      );

  testWidgets('credits both authors and the licence', (tester) async {
    await pump(tester, const WorkoutGuideAttribution());

    final text = tester.widget<Text>(find.byType(Text));
    final rendered = text.textSpan!.toPlainText();
    expect(rendered, contains('Bryl Lim'));
    expect(rendered, contains('Everkinetic'));
    expect(rendered, contains('CC BY-SA 4.0'));
  });

  testWidgets('reports the tapped link', (tester) async {
    final tapped = <String>[];
    await pump(
      tester,
      WorkoutGuideAttribution(onLinkTap: tapped.add),
    );

    final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
    final links = <TextSpan>[
      for (final child in span.children!.cast<TextSpan>())
        if (child.recognizer != null) child,
    ];
    expect(links, hasLength(3));

    for (final link in links) {
      (link.recognizer! as TapGestureRecognizer).onTap!();
    }

    expect(tapped, <String>[
      WorkoutGuideAttribution.creatorUrl,
      WorkoutGuideAttribution.sourceUrl,
      WorkoutGuideAttribution.licenseUrl,
    ]);
  });

  testWidgets('renders plain text when no tap handler is given',
      (tester) async {
    await pump(tester, const WorkoutGuideAttribution());

    final span = tester.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
    for (final child in span.children!.cast<TextSpan>()) {
      expect(child.recognizer, isNull);
    }
  });

  testWidgets('survives a rebuild without disposing a live recognizer',
      (tester) async {
    await pump(tester, WorkoutGuideAttribution(onLinkTap: (_) {}));
    await pump(tester, WorkoutGuideAttribution(onLinkTap: (_) {}));
    await pump(tester, const SizedBox());
    expect(tester.takeException(), isNull);
  });

  test('exposes the same credit as plain text', () {
    expect(
      WorkoutGuideAttribution.plainText,
      allOf(
        contains('Bryl Lim'),
        contains(WorkoutGuideAttribution.creatorUrl),
        contains('Everkinetic'),
        contains(WorkoutGuideAttribution.sourceUrl),
        contains('CC BY-SA 4.0'),
        contains(WorkoutGuideAttribution.licenseUrl),
      ),
    );
  });
}
