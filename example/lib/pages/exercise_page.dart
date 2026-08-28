import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

/// The detail view: the movement animated, its metadata, and its provenance.
class ExercisePage extends StatefulWidget {
  const ExercisePage({required this.exercise, super.key});

  final Exercise exercise;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  bool _playing = true;
  double _speed = 400;

  Exercise get _exercise => widget.exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final source = _exercise.attribution.source;

    return Scaffold(
      appBar: AppBar(title: Text(_exercise.name)),
      // A detail page has no business being 1500 px wide on a desktop:
      // the artwork would dwarf everything else.
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 260,
                    child: Hero(
                      tag: _exercise.id,
                      child: ExerciseAnimation(
                        exercise: _exercise,
                        playing: _playing,
                        frameDuration: Duration(milliseconds: _speed.round()),
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _playing = !_playing),
                    icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                    tooltip: _playing ? 'Pause' : 'Play',
                  ),
                  Expanded(
                    child: Slider(
                      value: _speed,
                      min: 120,
                      max: 900,
                      label: '${_speed.round()} ms/frame',
                      onChanged: (value) => setState(() => _speed = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _Tag(_exercise.equipment.label, Icons.fitness_center),
                  _Tag(_exercise.primaryMuscle.label, Icons.accessibility_new),
                  _Tag(_exercise.exerciseType.label, Icons.straighten),
                  if (_exercise.isStretch)
                    const _Tag('Stretch', Icons.self_improvement),
                ],
              ),
              if (_exercise.secondaryMuscles.isNotEmpty) ...<Widget>[
                const SizedBox(height: 24),
                _SectionTitle('Also works'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final muscle in _exercise.secondaryMuscles)
                      Chip(label: Text(muscle.label)),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              _SectionTitle('Frames'),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  for (final frame in _exercise.frames)
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 1,
                            child: ExerciseFrameImage(
                              exercise: _exercise,
                              frame: frame.index,
                              color: theme.colorScheme.onSurfaceVariant,
                              semanticLabel:
                                  '${_exercise.name}, pose ${frame.index}',
                            ),
                          ),
                          Text(
                            <String>['Start', 'Mid', 'End'][frame.index - 1],
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle('Identifiers'),
              const SizedBox(height: 8),
              _KeyValue('id', _exercise.id),
              _KeyValue('slug', _exercise.slug),
              _KeyValue('asset', _exercise.assetPath(1)),
              const SizedBox(height: 24),
              _SectionTitle('Artwork'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      WorkoutGuideAttribution(
                        style: theme.textTheme.bodySmall,
                        linkStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        onLinkTap: (url) => _copy(context, url),
                      ),
                      if (source != null) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          'This first pose is adapted from ${source.name}: '
                          '${source.changes}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _copy(context, source.url),
                          child: Text(
                            source.url,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // The package takes no url_launcher dependency and neither does this
  // example, so a tapped link goes to the clipboard instead.
  void _copy(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $url')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.icon);

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
      );
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.name, this.value);

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 56,
            child: Text(
              name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
