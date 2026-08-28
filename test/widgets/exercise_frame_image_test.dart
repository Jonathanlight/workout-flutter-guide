import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

import '../support/file_asset_bundle.dart';

void main() {
  final bundle = FileAssetBundle();
  final pushUp = WorkoutGuide.getExercise('push-up')!;

  // flutter_svg caches decoded pictures globally. Left alone, an asset
  // decoded by an earlier test resolves synchronously in a later one, which
  // would quietly defeat the placeholder test below.
  setUp(svg.cache.clear);

  Future<void> pumpImage(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the requested frame at the requested size',
      (tester) async {
    await pumpImage(
      tester,
      ExerciseFrameImage(
        exercise: pushUp,
        frame: 2,
        size: 120,
        bundle: bundle,
      ),
    );

    final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(picture.width, 120);
    expect(picture.height, 120);
    expect(
      (picture.bytesLoader as SvgAssetLoader).assetName,
      'packages/workout_flutter_guide/assets/exercises/push-up/frame-2.svg',
    );
  });

  testWidgets('tints the artwork only when a colour is given', (tester) async {
    await pumpImage(
      tester,
      ExerciseFrameImage(exercise: pushUp, size: 64, bundle: bundle),
    );
    expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter, isNull);

    await pumpImage(
      tester,
      ExerciseFrameImage(
        exercise: pushUp,
        size: 64,
        color: const Color(0xFF112233),
        bundle: bundle,
      ),
    );
    expect(
      tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
      const ColorFilter.mode(Color(0xFF112233), BlendMode.srcIn),
    );
  });

  testWidgets('labels itself with the exercise name by default',
      (tester) async {
    await pumpImage(
      tester,
      ExerciseFrameImage(exercise: pushUp, size: 64, bundle: bundle),
    );
    expect(find.bySemanticsLabel('Push-up'), findsOneWidget);
  });

  testWidgets('an empty label hides it from assistive technologies',
      (tester) async {
    await pumpImage(
      tester,
      ExerciseFrameImage(
        exercise: pushUp,
        size: 64,
        semanticLabel: '',
        bundle: bundle,
      ),
    );
    expect(find.bySemanticsLabel('Push-up'), findsNothing);
  });

  testWidgets('shows the placeholder before the asset resolves',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ExerciseFrameImage(
          exercise: pushUp,
          size: 64,
          placeholder: const SizedBox(key: ValueKey('placeholder')),
          bundle: bundle,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('placeholder')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('placeholder')), findsNothing);
  });

  test('rejects a frame index outside 1..3', () {
    expect(
      () => ExerciseFrameImage(exercise: pushUp, frame: 0),
      throwsAssertionError,
    );
    expect(
      () => ExerciseFrameImage(exercise: pushUp, frame: 4),
      throwsAssertionError,
    );
  });
}
