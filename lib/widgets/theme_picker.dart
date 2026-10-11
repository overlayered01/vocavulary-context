import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../providers.dart';
import '../theme.dart';

/// 테마 프리셋 견본과 '직접' 견본. 프리셋은 바로 적용하고, 직접은 시트를 연다.
class ThemeSwatches extends ConsumerWidget {
  const ThemeSwatches({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final names = {
      'slate': l10n.themeSlate,
      'navy': l10n.themeNavy,
      'brown': l10n.themeBrown,
      'plum': l10n.themePlum,
      'charcoal': l10n.themeCharcoal,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final preset in AppThemes.presets)
          _Swatch(
            key: ValueKey('theme-${preset.id}'),
            label: names[preset.id] ?? preset.id,
            panel: preset.panel,
            point: preset.point,
            selected: settings.themeId == preset.id,
            onTap: () => notifier.setTheme(preset.id),
          ),
        _Swatch(
          key: const ValueKey('theme-custom'),
          label: l10n.themeCustom,
          panel: Color(settings.customThemeBase),
          point: Color(settings.customThemePoint),
          selected: settings.themeId == AppThemes.customId,
          custom: true,
          onTap: () => showCustomThemeSheet(context),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color panel;
  final Color point;
  final bool selected;
  final bool custom;
  final VoidCallback onTap;
  const _Swatch({
    super.key,
    required this.label,
    required this.panel,
    required this.point,
    required this.selected,
    required this.onTap,
    this.custom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: selected ? AppColors.ink : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  alignment: Alignment.bottomRight,
                  decoration: BoxDecoration(
                    color: custom && !selected ? null : panel,
                    gradient: custom && !selected
                        ? SweepGradient(
                            colors: [
                              AppThemes.slate.panel,
                              AppThemes.navy.panel,
                              AppThemes.plum.panel,
                              AppThemes.brown.panel,
                              AppThemes.slate.panel,
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: custom && !selected ? Colors.white : point,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.ink : AppColors.sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 바탕색·포인트색을 직접 고르는 시트.
Future<void> showCustomThemeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CustomThemeSheet(),
  );
}

class _CustomThemeSheet extends ConsumerStatefulWidget {
  const _CustomThemeSheet();

  @override
  ConsumerState<_CustomThemeSheet> createState() => _CustomThemeSheetState();
}

class _CustomThemeSheetState extends ConsumerState<_CustomThemeSheet> {
  late HSVColor _base;
  late HSVColor _point;
  bool _editingBase = true;
  final _hex = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _base = HSVColor.fromColor(Color(s.customThemeBase));
    _point = HSVColor.fromColor(Color(s.customThemePoint));
    _syncHex();
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  HSVColor get _current => _editingBase ? _base : _point;

  void _set(HSVColor color) {
    setState(() {
      if (_editingBase) {
        _base = color;
      } else {
        _point = color;
      }
      _syncHex();
    });
  }

  void _syncHex() => _hex.text = hexOf(_current.toColor());

  static String hexOf(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  void _onHex(String value) {
    final cleaned = value.replaceAll('#', '').trim();
    if (cleaned.length != 6) return;
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) return;
    setState(() {
      final color = HSVColor.fromColor(Color(0xFF000000 | parsed));
      if (_editingBase) {
        _base = color;
      } else {
        _point = color;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = _base.toColor();
    final point = _point.toColor();
    final preview = AppPalette.from(base, point);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22,
          0,
          22,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.themeCustomTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _base = HSVColor.fromColor(AppThemes.slate.panel);
                    _point = HSVColor.fromColor(AppThemes.slate.point);
                    _syncHex();
                  }),
                  child: Text(
                    l10n.themeReset,
                    style: TextStyle(color: AppColors.sub),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _MiniPreview(palette: preview),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TargetTile(
                    label: l10n.themeBase,
                    color: base,
                    selected: _editingBase,
                    onTap: () => setState(() {
                      _editingBase = true;
                      _syncHex();
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTile(
                    label: l10n.themePoint,
                    color: point,
                    selected: !_editingBase,
                    onTap: () => setState(() {
                      _editingBase = false;
                      _syncHex();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SaturationValueBox(color: _current, onChanged: _set),
            const SizedBox(height: 14),
            _HueBar(color: _current, onChanged: _set),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hex,
                    onChanged: _onHex,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                      LengthLimitingTextInputFormatter(7),
                    ],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                for (final preset in AppThemes.presets.take(3))
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () => _set(
                        HSVColor.fromColor(
                          _editingBase ? preset.panel : preset.point,
                        ),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _editingBase ? preset.panel : preset.point,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_rounded, size: 16, color: AppColors.sub2),
                const SizedBox(width: 6),
                Text(
                  l10n.themeAutoText,
                  style: TextStyle(fontSize: 12, color: AppColors.sub2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                key: const ValueKey('theme-apply'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: point,
                  foregroundColor: preview.onPoint,
                ),
                onPressed: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setCustomTheme(base.toARGB32(), point.toARGB32());
                  Navigator.pop(context);
                },
                child: Text(l10n.themeApply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _TargetTile({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? null : AppColors.chip,
        borderRadius: BorderRadius.circular(16),
        border: selected ? Border.all(color: AppColors.ink, width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
              Text(
                _CustomThemeSheetState.hexOf(color),
                style: TextStyle(fontSize: 12, color: AppColors.sub2),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// 채도(가로)·밝기(세로) 고르는 사각형.
class _SaturationValueBox extends StatelessWidget {
  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;
  const _SaturationValueBox({required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const height = 150.0;
        final width = constraints.maxWidth;
        void update(Offset p) => onChanged(
          color
              .withSaturation((p.dx / width).clamp(0.0, 1.0))
              .withValue(1 - (p.dy / height).clamp(0.0, 1.0)),
        );
        return GestureDetector(
          onPanDown: (d) => update(d.localPosition),
          onPanUpdate: (d) => update(d.localPosition),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          HSVColor.fromAHSV(1, color.hue, 1, 1).toColor(),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: color.saturation * width - 12,
                  top: (1 - color.value) * height - 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HueBar extends StatelessWidget {
  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;
  const _HueBar({required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        void update(Offset p) =>
            onChanged(color.withHue((p.dx / width).clamp(0.0, 1.0) * 360));
        return GestureDetector(
          onPanDown: (d) => update(d.localPosition),
          onPanUpdate: (d) => update(d.localPosition),
          child: SizedBox(
            height: 24,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        for (var h = 0; h <= 360; h += 60)
                          HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: color.hue / 360 * width - 11,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: HSVColor.fromAHSV(1, color.hue, 1, 1).toColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 고른 색으로 그린 작은 홈 화면.
class _MiniPreview extends StatelessWidget {
  final AppPalette palette;
  const _MiniPreview({required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Container(
        width: 220,
        height: 150,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.chip),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeRemainingCards,
                    style: TextStyle(fontSize: 8, color: palette.sub),
                  ),
                  Text(
                    '42',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w200,
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette.panel,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: 'They had to ',
                          children: [
                            TextSpan(
                              text: 'abandon',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                background: Paint()..color = palette.point,
                              ),
                            ),
                            const TextSpan(text: ' the car.'),
                          ],
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: palette.point,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.homeStartButton,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: palette.onPoint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
