/// 302 exercises, 906 offline SVG frames, and a typed catalog to query them.
///
/// A Flutter port of [`@bryllim/workout-guide`](https://github.com/bryllim/workout-guide).
/// The catalog is compiled in as Dart constants, so it is available
/// synchronously with no asset loading and no network:
///
/// ```dart
/// import 'package:workout_flutter_guide/workout_flutter_guide.dart';
///
/// final pushUp = WorkoutGuide.getExercise('push-up')!;
/// final chest = WorkoutGuide.search('chest', equipment: Equipment.bodyweight);
///
/// ExerciseAnimation(exercise: pushUp, size: 200, color: Colors.black87);
/// ```
///
/// The illustrations are licensed under CC BY-SA 4.0 and **your app must
/// display their attribution**. Add a [WorkoutGuideAttribution] widget to an
/// About screen, or call `WorkoutGuide.registerLicenses()` and use Flutter's
/// `showLicensePage`. See `LICENSES.md` and `ATTRIBUTION.md`.
library;

export 'src/catalog/text_normalizer.dart';
export 'src/catalog/workout_guide.dart';
export 'src/models/attribution.dart';
export 'src/models/enums.dart';
export 'src/models/exercise.dart';
export 'src/models/exercise_frame.dart';
export 'src/widgets/attribution_widget.dart';
export 'src/widgets/exercise_animation.dart';
export 'src/widgets/exercise_frame_image.dart';
