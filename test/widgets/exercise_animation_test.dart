import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

import '../support/file_asset_bundle.dart';

void main() {
  final bundle = FileAssetBundle();
  final pushUp = WorkoutGuide.getExercise('push-up')!;
  final benchPress = WorkoutGuide.getExercise('bench-press')!;

  int visibleFrame(WidgetTester tester) =>
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index! + 1;

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: child),
          ),
        ),
      );

  testWidgets('cycles 1 -> 2 -> 3 -> 1', (tester) async {
    await pump(
      tester,
      ExerciseAnimation(
        exercise: pushUp,
        frameDuration: const Duration(milliseconds: 100),
        size: 80,
        bundle: bundle,
      ),
    );

    expect(visibleFrame(tester), 1);
    await tester.pump(const Duration(milliseconds: 100));
    expect(visibleFrame(tester), 2);
    await tester.pump(const Duration(milliseconds: 100));
    expect(visibleFrame(tester), 3);
    await tester.pump(const Duration(milliseconds: 100));
    expect(visibleFrame(tester), 1);
  });

  testWidgets('builds all three frames so none of them pops in later',
      (tester) async {
    await pump(
      tester,
      ExerciseAnimation(exercise: pushUp, size: 80, bundle: bundle),
    );
    // Only the selected child is painted, hence skipOffstage: false. What
    // matters is that all three are mounted, so all three SVGs decode up
    // front.
    expect(
      find.byType(ExerciseFrameImage, skipOffstage: false),
      findsNWidgets(3),
    );
  });

  testWidgets('holds the start frame when it is not playing', (tester) async {
    await pump(
      tester,
      ExerciseAnimation(
        exercise: pushUp,
        frameDuration: const Duration(milliseconds: 100),
        playing: false,
        size: 80,
        bundle: bundle,
      ),
    );

    expect(visibleFrame(tester), 1);
    await tester.pump(const Duration(milliseconds: 500));
    expect(visibleFrame(tester), 1);
  });

  testWidgets('rewinds to the start frame when playing turns off',
      (tester) async {
    Widget build({required bool playing}) => ExerciseAnimation(
          exercise: pushUp,
          frameDuration: const Duration(milliseconds: 100),
          playing: playing,
          size: 80,
          bundle: bundle,
        );

    await pump(tester, build(playing: true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(visibleFrame(tester), 2);

    await pump(tester, build(playing: false));
    expect(visibleFrame(tester), 1);
    await tester.pump(const Duration(milliseconds: 500));
    expect(visibleFrame(tester), 1);
  });

  testWidgets('restarts when the exercise changes', (tester) async {
    await pump(
      tester,
      ExerciseAnimation(
        exercise: pushUp,
        frameDuration: const Duration(milliseconds: 100),
        size: 80,
        bundle: bundle,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(visibleFrame(tester), 2);

    await pump(
      tester,
      ExerciseAnimation(
        exercise: benchPress,
        frameDuration: const Duration(milliseconds: 100),
        size: 80,
        bundle: bundle,
      ),
    );
    expect(visibleFrame(tester), 1);
  });

  testWidgets('holds still when the platform asks for reduced motion',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: ExerciseAnimation(
              exercise: pushUp,
              frameDuration: const Duration(milliseconds: 100),
              size: 80,
              bundle: bundle,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(visibleFrame(tester), 1);
  });

  testWidgets('honours respectReducedMotion: false', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: ExerciseAnimation(
              exercise: pushUp,
              frameDuration: const Duration(milliseconds: 100),
              respectReducedMotion: false,
              size: 80,
              bundle: bundle,
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(visibleFrame(tester), 2);
  });

  testWidgets('names itself once instead of once per frame', (tester) async {
    await pump(
      tester,
      ExerciseAnimation(exercise: pushUp, size: 80, bundle: bundle),
    );
    expect(find.bySemanticsLabel('Push-up'), findsOneWidget);
  });

  testWidgets('cancels its timer when it leaves the tree', (tester) async {
    await pump(
      tester,
      ExerciseAnimation(
        exercise: pushUp,
        frameDuration: const Duration(milliseconds: 100),
        size: 80,
        bundle: bundle,
      ),
    );
    await pump(tester, const SizedBox());
    // A leaked periodic timer makes the test framework fail here.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ExerciseAnimation), findsNothing);
  });

  test('rejects a non-positive frame duration', () {
    expect(
      () => ExerciseAnimation(exercise: pushUp, frameDuration: Duration.zero),
      throwsAssertionError,
    );
  });
}
