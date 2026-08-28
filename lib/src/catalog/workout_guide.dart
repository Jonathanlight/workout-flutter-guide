import 'package:flutter/foundation.dart';

import '../generated/catalog.g.dart';
import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/exercise_frame.dart';
import 'text_normalizer.dart';

/// The exercise catalog: lookup, search and asset paths.
///
/// Everything is static, synchronous and offline. The catalog is compiled in
/// as Dart constants, so there is nothing to initialize and no `await`:
///
/// ```dart
/// final pushUp = WorkoutGuide.getExercise('push-up');
/// final chest = WorkoutGuide.search('chest', equipment: Equipment.bodyweight);
/// SvgPicture.asset(pushUp!.assetPath(1));
/// ```
///
/// This is a port of the upstream `@bryllim/workout-guide` JavaScript API and
/// deliberately keeps its semantics, down to the search normalization.
abstract final class WorkoutGuide {
  /// The version of the upstream catalog this package ships.
  ///
  /// Used as the default `version` of [assetCdnUrl].
  static const String catalogVersion = '1.0.0';

  /// The default jsDelivr base for [assetCdnUrl].
  static const String cdnBaseUrlTemplate =
      'https://cdn.jsdelivr.net/npm/@bryllim/workout-guide@';

  static final List<Exercise> _exercises =
      List<Exercise>.unmodifiable(kExerciseCatalog);

  static final Map<String, Exercise> _byId = <String, Exercise>{
    for (final exercise in kExerciseCatalog) exercise.id: exercise,
  };

  static final Map<String, Exercise> _bySlug = <String, Exercise>{
    for (final exercise in kExerciseCatalog) exercise.slug: exercise,
  };

  /// Every exercise, in catalog order. The list is unmodifiable.
  ///
  /// 302 entries, each with exactly three frames.
  static List<Exercise> get exercises => _exercises;

  /// Returns the exercise with this id or slug, or `null` when there is none.
  ///
  /// Ids win over slugs, matching upstream. Both are exact, case-sensitive
  /// matches: use [search] for anything fuzzier.
  ///
  /// ```dart
  /// WorkoutGuide.getExercise('exercise-push-up');  // by id
  /// WorkoutGuide.getExercise('push-up');           // by slug
  /// WorkoutGuide.getExercise('nope');              // null
  /// ```
  static Exercise? getExercise(String idOrSlug) =>
      _byId[idOrSlug] ?? _bySlug[idOrSlug];

  /// Returns the exercises matching [query] and the given filters.
  ///
  /// [query] is normalized with [normalizeSearchText] and split into tokens;
  /// an exercise matches when **every** token appears in its name, equipment,
  /// primary muscle or secondary muscles. An empty query matches everything,
  /// which makes `search('')` the way to filter without searching.
  ///
  /// Each filter accepts a [String] label, the matching enum value, or an
  /// [Iterable] of either. Several values within one filter are ORed together;
  /// different filters are ANDed. String labels are matched after
  /// normalization, so `'pull up bar'` and `'Pull-up Bar'` behave the same.
  ///
  /// Results keep catalog order.
  ///
  /// ```dart
  /// WorkoutGuide.search('press', equipment: 'Dumbbell');
  /// WorkoutGuide.search('', primaryMuscle: [Muscle.lats, Muscle.upperBack]);
  /// WorkoutGuide.search('', isStretch: true);
  /// ```
  ///
  /// Throws an [ArgumentError] when a filter gets a value that is neither a
  /// [String] nor the enum it expects.
  static List<Exercise> search(
    String query, {
    Object? equipment,
    Object? primaryMuscle,
    Object? exerciseType,
    bool? isStretch,
  }) {
    final equipmentFilter = _normalizeFilter(equipment, 'equipment');
    final muscleFilter = _normalizeFilter(primaryMuscle, 'primaryMuscle');
    final typeFilter = _normalizeFilter(exerciseType, 'exerciseType');
    final tokens = tokenizeSearchQuery(query);

    return <Exercise>[
      for (final exercise in kExerciseCatalog)
        if (_matches(
          exercise,
          equipmentFilter: equipmentFilter,
          muscleFilter: muscleFilter,
          typeFilter: typeFilter,
          isStretch: isStretch,
          tokens: tokens,
        ))
          exercise,
    ];
  }

  /// Returns every exercise using this equipment.
  ///
  /// Shorthand for `search('', equipment: equipment)`.
  static List<Exercise> byEquipment(Object equipment) =>
      search('', equipment: equipment);

  /// Returns every exercise whose primary muscle is [muscle].
  ///
  /// Shorthand for `search('', primaryMuscle: muscle)`.
  static List<Exercise> byPrimaryMuscle(Object muscle) =>
      search('', primaryMuscle: muscle);

  /// Returns every exercise of this type.
  ///
  /// Shorthand for `search('', exerciseType: type)`.
  static List<Exercise> byExerciseType(Object type) =>
      search('', exerciseType: type);

  /// Returns the 14 stretches of the catalog.
  static List<Exercise> get stretches => search('', isStretch: true);

  /// Returns the Flutter asset key of a frame, or `null` when there is none.
  ///
  /// [frameIndex] is 1-based. Returns `null` for an unknown exercise or an
  /// out-of-range frame rather than throwing, mirroring the upstream
  /// `getAssetUrl` contract.
  ///
  /// ```dart
  /// WorkoutGuide.assetPath('push-up', 1);
  /// // packages/workout_flutter_guide/assets/exercises/push-up/frame-1.svg
  /// ```
  ///
  /// When you already hold an [Exercise], prefer `exercise.assetPath(index)`
  /// or [ExerciseFrame.assetPath].
  static String? assetPath(String idOrSlug, int frameIndex) =>
      _frameOrNull(idOrSlug, frameIndex)?.assetPath;

  /// Builds the jsDelivr URL of a frame, or `null` when there is none.
  ///
  /// This package never makes a network request; this is a pure string
  /// builder, kept byte-compatible with the upstream `getAssetUrl` so that
  /// code shared with a JavaScript app produces the same URLs.
  ///
  /// ```dart
  /// WorkoutGuide.assetCdnUrl('push-up', 2);
  /// // https://cdn.jsdelivr.net/npm/@bryllim/workout-guide@1.0.0/assets/push-up/frame-2.svg
  /// ```
  ///
  /// Use it to serve the artwork from a CDN instead of the bundle; the bundled
  /// assets remain the offline default.
  static String? assetCdnUrl(
    String idOrSlug,
    int frameIndex, {
    String? baseUrl,
    String version = catalogVersion,
  }) {
    final frame = _frameOrNull(idOrSlug, frameIndex);
    if (frame == null) return null;
    final base = baseUrl ?? '$cdnBaseUrlTemplate$version/';
    final normalizedBase = base.endsWith('/') ? base : '$base/';
    return Uri.parse(normalizedBase).resolve(frame.path).toString();
  }

  /// Registers this package's licenses with Flutter's [LicenseRegistry].
  ///
  /// Call it once at start-up if your app uses `showLicensePage` or
  /// `showAboutDialog`; the artwork is CC BY-SA 4.0 and its attribution has to
  /// reach your users somehow. The other supported way is to render a
  /// `WorkoutGuideAttribution` widget on an About screen.
  ///
  /// Calling it more than once adds the entry more than once, so call it from
  /// `main` rather than from a `build` method.
  static void registerLicenses() {
    LicenseRegistry.addLicense(() async* {
      yield const LicenseEntryWithLineBreaks(
        <String>['workout_flutter_guide'],
        'Exercise illustrations by Bryl Lim (https://bryllim.com), based on '
        'artwork by Everkinetic (https://github.com/everkinetic/data), '
        'licensed under CC BY-SA 4.0 '
        '(https://creativecommons.org/licenses/by-sa/4.0/).\n'
        '\n'
        'The artwork is redistributed unmodified from '
        '@bryllim/workout-guide v$catalogVersion. Per-frame source URLs and '
        'recorded changes are available at run time through '
        'Exercise.attribution.source.\n'
        '\n'
        'You may share and adapt these assets for any purpose, including '
        'commercially, provided that you give appropriate credit, link to the '
        'license, indicate changes, and distribute adaptations under the same '
        'license.\n'
        '\n'
        'The Dart source of workout_flutter_guide is MIT licensed.',
      );
    });
  }

  static ExerciseFrame? _frameOrNull(String idOrSlug, int frameIndex) {
    final exercise = getExercise(idOrSlug);
    if (exercise == null) return null;
    if (frameIndex < 1 || frameIndex > exercise.frames.length) return null;
    return exercise.frames[frameIndex - 1];
  }

  static bool _matches(
    Exercise exercise, {
    required List<String>? equipmentFilter,
    required List<String>? muscleFilter,
    required List<String>? typeFilter,
    required bool? isStretch,
    required List<String> tokens,
  }) {
    if (!_matchesFilter(exercise.equipment.label, equipmentFilter)) {
      return false;
    }
    if (!_matchesFilter(exercise.primaryMuscle.label, muscleFilter)) {
      return false;
    }
    if (!_matchesFilter(exercise.exerciseType.label, typeFilter)) {
      return false;
    }
    if (isStretch != null && exercise.isStretch != isStretch) return false;
    if (tokens.isEmpty) return true;

    final searchable = _searchableText(exercise);
    return tokens.every(searchable.contains);
  }

  static bool _matchesFilter(String value, List<String>? normalizedFilter) =>
      normalizedFilter == null ||
      normalizedFilter.contains(normalizeSearchText(value));

  static final Map<String, String> _searchableCache = <String, String>{};

  static String _searchableText(Exercise exercise) =>
      _searchableCache[exercise.id] ??= normalizeSearchText(
        <String>[
          exercise.name,
          exercise.equipment.label,
          exercise.primaryMuscle.label,
          for (final muscle in exercise.secondaryMuscles) muscle.label,
        ].join(' '),
      );

  /// Turns a filter argument into the list of normalized labels to match.
  ///
  /// Accepts a [String], an enum value with a `label`, or an [Iterable] of
  /// either. Returns `null` when the filter is absent, meaning "match all".
  static List<String>? _normalizeFilter(Object? filter, String name) {
    if (filter == null) return null;
    if (filter is Iterable) {
      return <String>[
        for (final value in filter) _normalizeFilterValue(value, name),
      ];
    }
    return <String>[_normalizeFilterValue(filter, name)];
  }

  static String _normalizeFilterValue(Object? value, String name) {
    final label = switch (value) {
      String() => value,
      Equipment() => value.label,
      Muscle() => value.label,
      ExerciseType() => value.label,
      _ => throw ArgumentError.value(
          value,
          name,
          'expected a String, an Equipment, a Muscle, an ExerciseType, '
          'or an Iterable of those',
        ),
    };
    return normalizeSearchText(label);
  }
}
