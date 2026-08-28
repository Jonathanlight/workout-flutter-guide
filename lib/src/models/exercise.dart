import 'attribution.dart';
import 'enums.dart';
import 'exercise_frame.dart';

/// One exercise of the catalog, with its metadata and its three frames.
///
/// Instances are immutable and come from `WorkoutGuide.exercises`; you never
/// need to build one yourself, though the constructor is `const` if you want
/// a fixture in a test.
///
/// ```dart
/// final pushUp = WorkoutGuide.getExercise('push-up')!;
/// pushUp.name;             // 'Push-up'
/// pushUp.primaryMuscle;    // Muscle.chest
/// pushUp.frames.length;    // 3
/// ```
class Exercise {
  /// Creates an exercise.
  ///
  /// [frames] must hold exactly three frames, ordered 1, 2, 3.
  const Exercise({
    required this.id,
    required this.slug,
    required this.name,
    required this.exerciseType,
    required this.equipment,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.isStretch,
    required this.frames,
    required this.attribution,
  });

  /// Reads an entry out of the catalog manifest.
  ///
  /// Throws an [ArgumentError] when an equipment, muscle or type label is not
  /// one the catalog knows about — a manifest that drifts from the enums is a
  /// bug to fix, not a value to silently drop.
  factory Exercise.fromJson(Map<String, Object?> json) => Exercise(
        id: json['id']! as String,
        slug: json['slug']! as String,
        name: json['name']! as String,
        exerciseType: ExerciseType.fromLabel(json['exerciseType']! as String),
        equipment: Equipment.fromLabel(json['equipment']! as String),
        primaryMuscle: Muscle.fromLabel(json['primaryMuscle']! as String),
        secondaryMuscles: List<Muscle>.unmodifiable(
          (json['secondaryMuscles']! as List)
              .cast<String>()
              .map(Muscle.fromLabel),
        ),
        isStretch: json['isStretch']! as bool,
        frames: List<ExerciseFrame>.unmodifiable(
          (json['frames']! as List)
              .cast<Map<String, Object?>>()
              .map(ExerciseFrame.fromJson),
        ),
        attribution: ExerciseAttribution.fromJson(
          json['attribution']! as Map<String, Object?>,
        ),
      );

  /// The stable identifier, always `exercise-<slug>`.
  final String id;

  /// The kebab-case name, also the asset directory, e.g. `bench-press`.
  final String slug;

  /// The display name, e.g. `Bench Press`.
  final String name;

  /// How this exercise is measured when it is logged.
  final ExerciseType exerciseType;

  /// The equipment it requires.
  final Equipment equipment;

  /// The muscle it targets first.
  final Muscle primaryMuscle;

  /// The muscles it also works, in the order the catalog lists them.
  ///
  /// May be empty. The list is unmodifiable.
  final List<Muscle> secondaryMuscles;

  /// Whether this is a stretch rather than a strength movement.
  ///
  /// True for 14 of the 302 exercises.
  final bool isStretch;

  /// The three poses, ordered start, mid, end. The list is unmodifiable.
  final List<ExerciseFrame> frames;

  /// Who made the artwork and under which license.
  ///
  /// Always equal to `frames.first.attribution`: the exercise inherits the
  /// attribution of its first pose, which is the frame that may be derived
  /// from an upstream Everkinetic drawing.
  final ExerciseAttribution attribution;

  /// The start pose.
  ExerciseFrame get startFrame => frames[0];

  /// The mid pose.
  ExerciseFrame get midFrame => frames[1];

  /// The end pose.
  ExerciseFrame get endFrame => frames[2];

  /// Returns the frame with the given 1-based [index].
  ///
  /// Throws a [RangeError] outside 1..3.
  ExerciseFrame frame(int index) {
    if (index < 1 || index > frames.length) {
      throw RangeError.range(index, 1, frames.length, 'index');
    }
    return frames[index - 1];
  }

  /// The Flutter asset key of the frame with the given 1-based [index].
  ///
  /// Throws a [RangeError] outside 1..3. See [ExerciseFrame.assetPath].
  String assetPath(int index) => frame(index).assetPath;

  /// Whether this exercise needs no equipment at all.
  bool get isBodyweight => equipment == Equipment.bodyweight;

  /// Every muscle this exercise works, primary first, without duplicates.
  List<Muscle> get allMuscles => <Muscle>[
        primaryMuscle,
        ...secondaryMuscles.where((muscle) => muscle != primaryMuscle),
      ];

  /// Returns this exercise in the shape used by the catalog manifest.
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'slug': slug,
        'name': name,
        'exerciseType': exerciseType.label,
        'equipment': equipment.label,
        'primaryMuscle': primaryMuscle.label,
        'secondaryMuscles': <String>[
          for (final muscle in secondaryMuscles) muscle.label,
        ],
        'isStretch': isStretch,
        'frames': <Map<String, Object?>>[
          for (final frame in frames) frame.toJson(),
        ],
        'attribution': attribution.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          other.id == id &&
          other.slug == slug &&
          other.name == name &&
          other.exerciseType == exerciseType &&
          other.equipment == equipment &&
          other.primaryMuscle == primaryMuscle &&
          _listEquals(other.secondaryMuscles, secondaryMuscles) &&
          other.isStretch == isStretch &&
          _listEquals(other.frames, frames) &&
          other.attribution == attribution;

  @override
  int get hashCode => Object.hash(
        id,
        slug,
        name,
        exerciseType,
        equipment,
        primaryMuscle,
        Object.hashAll(secondaryMuscles),
        isStretch,
        Object.hashAll(frames),
        attribution,
      );

  @override
  String toString() => 'Exercise($id)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
