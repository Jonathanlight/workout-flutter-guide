import '../catalog/text_normalizer.dart';

/// How an exercise is measured when it is logged.
///
/// The [label] of each value is the exact string used by the upstream
/// catalog, so it round-trips through `manifest.json` unchanged.
enum ExerciseType {
  /// Logged as a weight and a repetition count, e.g. a bench press.
  weightReps('weight_reps'),

  /// Logged as a repetition count only, e.g. a push-up.
  bodyweightReps('bodyweight_reps'),

  /// Logged as a duration, e.g. a plank.
  duration('duration'),

  /// Logged as a distance and a duration, e.g. a treadmill run.
  distanceDuration('distance_duration'),

  /// Body-weight movement performed with assistance, e.g. an assisted pull-up.
  ///
  /// Logged as a repetition count and the amount of assistance used.
  assistedBodyweight('assisted_bodyweight');

  const ExerciseType(this.label);

  /// The upstream string value, e.g. `weight_reps`.
  final String label;

  static final Map<String, ExerciseType> _byNormalizedLabel = {
    for (final value in values) normalizeSearchText(value.label): value,
  };

  /// Returns the value whose [label] matches [label], or `null`.
  ///
  /// Matching is done on the normalized label, so `weight reps`,
  /// `Weight_Reps` and `weight_reps` all resolve to [weightReps].
  static ExerciseType? tryFromLabel(String label) =>
      _byNormalizedLabel[normalizeSearchText(label)];

  /// Returns the value whose [label] matches [label].
  ///
  /// Throws an [ArgumentError] when nothing matches. Use [tryFromLabel] for
  /// values that come from user input.
  static ExerciseType fromLabel(String label) =>
      tryFromLabel(label) ??
      (throw ArgumentError.value(label, 'label', 'unknown exercise type'));

  @override
  String toString() => label;
}

/// The equipment an exercise requires.
///
/// The [label] of each value is the exact string used by the upstream
/// catalog, including its capitalization and hyphenation.
enum Equipment {
  /// A loaded barbell.
  barbell('Barbell'),

  /// A flat, incline or decline bench.
  bench('Bench'),

  /// No equipment beyond the body itself.
  bodyweight('Bodyweight'),

  /// A plyometric box or a comparable raised platform.
  box('Box'),

  /// A cable machine.
  cable('Cable'),

  /// Cardio machines such as a treadmill, rower or bike.
  cardio('Cardio'),

  /// A chair or any stable seat.
  chair('Chair'),

  /// A doorway, used as an anchor for stretches and band work.
  doorway('Doorway'),

  /// One or two dumbbells.
  dumbbell('Dumbbell'),

  /// A kettlebell.
  kettlebell('Kettlebell'),

  /// A selectorized or plate-loaded machine.
  machine('Machine'),

  /// A single weight plate.
  plate('Plate'),

  /// A pull-up or chin-up bar.
  pullUpBar('Pull-up Bar'),

  /// An elastic resistance band.
  resistanceBand('Resistance Band'),

  /// A stability (Swiss) ball.
  stabilityBall('Stability Ball'),

  /// A towel, used for grip work and assisted stretches.
  towel('Towel'),

  /// A wall, used as a support surface.
  wall('Wall');

  const Equipment(this.label);

  /// The upstream string value, e.g. `Pull-up Bar`.
  final String label;

  static final Map<String, Equipment> _byNormalizedLabel = {
    for (final value in values) normalizeSearchText(value.label): value,
  };

  /// Returns the value whose [label] matches [label], or `null`.
  ///
  /// Matching is done on the normalized label, so `pull up bar` and
  /// `Pull-up Bar` both resolve to [pullUpBar].
  static Equipment? tryFromLabel(String label) =>
      _byNormalizedLabel[normalizeSearchText(label)];

  /// Returns the value whose [label] matches [label].
  ///
  /// Throws an [ArgumentError] when nothing matches. Use [tryFromLabel] for
  /// values that come from user input.
  static Equipment fromLabel(String label) =>
      tryFromLabel(label) ??
      (throw ArgumentError.value(label, 'label', 'unknown equipment'));

  @override
  String toString() => label;
}

/// A muscle or muscle group targeted by an exercise.
///
/// Twenty of these appear as an `Exercise.primaryMuscle`; [cardio], [grip]
/// and [groin] only ever appear in `Exercise.secondaryMuscles`, and
/// [posteriorChain] only ever appears as a primary. Use [primaryValues] when
/// you are building a "filter by muscle" control.
enum Muscle {
  /// The adductors, on the inner thigh.
  adductors('Adductors'),

  /// The back as a whole, when the catalog is not more specific.
  back('Back'),

  /// The biceps.
  biceps('Biceps'),

  /// The calves.
  calves('Calves'),

  /// The chest (pectorals).
  chest('Chest'),

  /// The trunk: abdominals and deep stabilizers.
  core('Core'),

  /// The forearms.
  forearms('Forearms'),

  /// The glutes.
  glutes('Glutes'),

  /// The hamstrings.
  hamstrings('Hamstrings'),

  /// The hips, including the flexors.
  hips('Hips'),

  /// The latissimus dorsi.
  lats('Lats'),

  /// The legs as a whole, when the catalog is not more specific.
  legs('Legs'),

  /// The lower back (erector spinae).
  lowerBack('Lower Back'),

  /// Joint mobility rather than a specific muscle.
  mobility('Mobility'),

  /// The posterior chain: glutes, hamstrings and lower back together.
  ///
  /// Only ever a primary muscle in this catalog.
  posteriorChain('Posterior Chain'),

  /// The quadriceps.
  quads('Quads'),

  /// The posterior deltoids.
  rearDelts('Rear Delts'),

  /// The deltoids.
  shoulders('Shoulders'),

  /// The triceps.
  triceps('Triceps'),

  /// The upper back: trapezius and rhomboids.
  upperBack('Upper Back'),

  /// Cardiovascular demand rather than a muscle.
  ///
  /// Only ever a secondary entry in this catalog.
  cardio('Cardio'),

  /// Grip strength.
  ///
  /// Only ever a secondary entry in this catalog.
  grip('Grip'),

  /// The groin.
  ///
  /// Only ever a secondary entry in this catalog.
  groin('Groin');

  const Muscle(this.label);

  /// The upstream string value, e.g. `Lower Back`.
  final String label;

  static final Map<String, Muscle> _byNormalizedLabel = {
    for (final value in values) normalizeSearchText(value.label): value,
  };

  /// The twenty values that appear as an `Exercise.primaryMuscle`.
  ///
  /// Excludes [cardio], [grip] and [groin], which the catalog only uses as
  /// secondary entries.
  static const List<Muscle> primaryValues = <Muscle>[
    adductors,
    back,
    biceps,
    calves,
    chest,
    core,
    forearms,
    glutes,
    hamstrings,
    hips,
    lats,
    legs,
    lowerBack,
    mobility,
    posteriorChain,
    quads,
    rearDelts,
    shoulders,
    triceps,
    upperBack,
  ];

  /// Returns the value whose [label] matches [label], or `null`.
  ///
  /// Matching is done on the normalized label, so `lower back` and
  /// `Lower Back` both resolve to [lowerBack].
  static Muscle? tryFromLabel(String label) =>
      _byNormalizedLabel[normalizeSearchText(label)];

  /// Returns the value whose [label] matches [label].
  ///
  /// Throws an [ArgumentError] when nothing matches. Use [tryFromLabel] for
  /// values that come from user input.
  static Muscle fromLabel(String label) =>
      tryFromLabel(label) ??
      (throw ArgumentError.value(label, 'label', 'unknown muscle'));

  @override
  String toString() => label;
}
