import 'package:flutter/material.dart';
import 'package:workout_flutter_guide/workout_flutter_guide.dart';

/// The equipment / muscle / stretch filters above the gallery grid.
class FilterBar extends StatelessWidget {
  const FilterBar({
    required this.equipment,
    required this.muscle,
    required this.stretchesOnly,
    required this.onEquipmentChanged,
    required this.onMuscleChanged,
    required this.onStretchesChanged,
    super.key,
  });

  final Equipment? equipment;
  final Muscle? muscle;
  final bool stretchesOnly;
  final ValueChanged<Equipment?> onEquipmentChanged;
  final ValueChanged<Muscle?> onMuscleChanged;
  final ValueChanged<bool> onStretchesChanged;

  bool get _hasAny => equipment != null || muscle != null || stretchesOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          _EnumFilterChip<Equipment>(
            label: 'Equipment',
            value: equipment,
            values: Equipment.values,
            labelOf: (value) => value.label,
            onChanged: onEquipmentChanged,
          ),
          const SizedBox(width: 8),
          _EnumFilterChip<Muscle>(
            label: 'Muscle',
            value: muscle,
            // Only the 20 muscles that actually appear as a primary muscle;
            // filtering on Grip or Groin would always come back empty.
            values: Muscle.primaryValues,
            labelOf: (value) => value.label,
            onChanged: onMuscleChanged,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Stretches'),
            selected: stretchesOnly,
            onSelected: onStretchesChanged,
          ),
          if (_hasAny) ...<Widget>[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
              onPressed: () {
                onEquipmentChanged(null);
                onMuscleChanged(null);
                onStretchesChanged(false);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Sentinel for the "no filter" entry of a menu.
///
/// `PopupMenuButton` swallows a null selection -- it treats it as a dismissal
/// -- so the "All" entry needs a value that is not null.
enum _MenuAction { clear }

class _EnumFilterChip<T extends Object> extends StatelessWidget {
  const _EnumFilterChip({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value != null;

    return PopupMenuButton<Object>(
      tooltip: 'Filter by ${label.toLowerCase()}',
      onSelected: (choice) => onChanged(choice is T ? choice : null),
      itemBuilder: (context) => <PopupMenuEntry<Object>>[
        const PopupMenuItem<Object>(
          value: _MenuAction.clear,
          child: Text('All'),
        ),
        const PopupMenuDivider(),
        for (final option in values)
          CheckedPopupMenuItem<Object>(
            value: option,
            checked: option == value,
            child: Text(labelOf(option)),
          ),
      ],
      child: Chip(
        label: Text(selected ? labelOf(value as T) : label),
        avatar: const Icon(Icons.expand_more, size: 18),
        backgroundColor: selected ? theme.colorScheme.secondaryContainer : null,
        side: selected
            ? BorderSide(color: theme.colorScheme.secondaryContainer)
            : null,
      ),
    );
  }
}
