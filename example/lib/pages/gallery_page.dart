import 'package:flutter/material.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

import '../widgets/exercise_card.dart';
import '../widgets/filter_bar.dart';
import 'about_page.dart';
import 'exercise_page.dart';

/// The searchable, filterable grid of every exercise in the catalog.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final TextEditingController _query = TextEditingController();

  Equipment? _equipment;
  Muscle? _muscle;
  bool _stretchesOnly = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Exercise> get _results => WorkoutGuide.search(
        _query.text,
        equipment: _equipment,
        primaryMuscle: _muscle,
        isStretch: _stretchesOnly ? true : null,
      );

  void _openExercise(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExercisePage(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            title: const Text('Workout Guide'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'About & credits',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: SearchBar(
                controller: _query,
                hintText: 'Search 302 exercises',
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.search),
                ),
                trailing: <Widget>[
                  if (_query.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Clear',
                      onPressed: () => setState(_query.clear),
                    ),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FilterBar(
              equipment: _equipment,
              muscle: _muscle,
              stretchesOnly: _stretchesOnly,
              onEquipmentChanged: (value) => setState(() => _equipment = value),
              onMuscleChanged: (value) => setState(() => _muscle = value),
              onStretchesChanged: (value) =>
                  setState(() => _stretchesOnly = value),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                results.length == 302
                    ? '302 exercises'
                    : '${results.length} of 302 exercises',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (results.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) => ExerciseCard(
                  exercise: results[index],
                  onTap: () => _openExercise(results[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Nothing matches those filters',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
