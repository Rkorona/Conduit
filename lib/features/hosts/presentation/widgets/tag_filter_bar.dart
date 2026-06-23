import 'package:flutter/material.dart';

class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    required this.tags,
    required this.selectedTag,
    required this.onSelected,
    super.key,
  });

  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tag in tags) ...[
            _TagPill(
              label: tag,
              selected: selectedTag == tag,
              onTap: () => onSelected(tag),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final background = selected
        ? Color.alphaBlend(accent.withValues(alpha: 0.18), colorScheme.surface)
        : colorScheme.surface;
    final foreground = selected ? accent : colorScheme.onSurfaceVariant;
    final border = selected
        ? accent.withValues(alpha: 0.55)
        : colorScheme.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: selected ? 1.3 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag_rounded, size: 13, color: foreground),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
