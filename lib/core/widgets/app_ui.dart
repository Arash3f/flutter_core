import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/dynamic_colors.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';

/// Muted text color for subtitles and hints.
Color appMutedOf(BuildContext context) =>
    DynamicColors.of(context, DynamicColorsName.textMuted);

/// Case-insensitive "does any of [fields] contain [query]" for client-side
/// search. An empty query matches everything.
bool appQueryMatches(String query, List<String?> fields) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  return fields.any((field) => (field ?? '').toLowerCase().contains(needle));
}

/// Large page title with an optional subtitle and trailing action. Screens
/// inside `AdaptiveShell` use this instead of their own `AppBar`, since the
/// shell already owns one.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: text.bodyMedium?.copyWith(
                      color: appMutedOf(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Search box that reports every keystroke and shows a clear button while
/// [query] is non-empty. Pass a [controller] only when the parent needs to
/// set the text itself.
class LiveSearchField extends StatefulWidget {
  const LiveSearchField({
    required this.onChanged,
    this.controller,
    this.hintText,
    this.query = '',
    super.key,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final String query;

  @override
  State<LiveSearchField> createState() => _LiveSearchFieldState();
}

class _LiveSearchFieldState extends State<LiveSearchField> {
  TextEditingController? _owned;

  TextEditingController get _controller => widget.controller ?? _owned!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _owned = TextEditingController(text: widget.query);
    }
  }

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = widget.query.trim().isNotEmpty;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText ?? LocaleKeys.searchHint.tr(),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasQuery
            ? IconButton(
                tooltip: LocaleKeys.actionClose.tr(),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
    );
  }
}

/// Tappable list row for an entity: optional leading avatar/badge, title,
/// subtitle and trailing widget, on an outlined card.
class AppEntityCard extends StatelessWidget {
  const AppEntityCard({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.fromLTRB(20, 0, 20, 10),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: margin,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: DynamicColors.of(context, DynamicColorsName.border),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 10, 14),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: text.bodySmall?.copyWith(
                            color: appMutedOf(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Arash Alfooneh ribbon mark (`assets/brand/mark-blue.png`).
///
/// Brand rule: use the ribbon form at 48 px and above. Below that the kit
/// ships a bold small-size mark; this widget is for chrome / splash / hero.
class AppMark extends StatelessWidget {
  const AppMark({this.size = 40, super.key});

  final double size;

  static const asset = 'assets/brand/mark-blue.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Image.asset(
        asset,
        width: size,
        height: size,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Arash Alfooneh',
      ),
    );
  }
}

/// Circle with the first letter of [label]. Handles emoji and non-Latin
/// scripts, since it takes the first rune rather than the first code unit.
class AppInitialsAvatar extends StatelessWidget {
  const AppInitialsAvatar({
    required this.label,
    this.radius = 24,
    this.color,
    super.key,
  });

  final String label;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final trimmed = label.trim();
    final initial = trimmed.isEmpty
        ? '?'
        : String.fromCharCodes(trimmed.runes.take(1));
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return CircleAvatar(
      radius: radius,
      backgroundColor: tint.withValues(alpha: 0.14),
      foregroundColor: tint,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.78),
      ),
    );
  }
}

/// Icon on a tinted rounded square, for list leading slots.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({required this.icon, this.color, super.key});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: tint),
    );
  }
}

/// Horizontally scrolling single-choice chips, for filters and sub-tabs.
class AppFilterPills<T> extends StatelessWidget {
  const AppFilterPills({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          for (final value in values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(labelOf(value)),
                selected: value == selected,
                onSelected: (_) => onSelected(value),
                showCheckmark: false,
              ),
            ),
        ],
      ),
    );
  }
}

/// Outlined surface that groups related content (a form, a settings block).
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DynamicColors.of(context, DynamicColorsName.border),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

/// Soft brand-tinted gradient behind full-screen pages such as login.
class AppAtmosphere extends StatelessWidget {
  const AppAtmosphere({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = DynamicColors.of(context, DynamicColorsName.background);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            background,
            Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.08),
              background,
            ),
            background,
          ],
        ),
      ),
      child: child,
    );
  }
}
