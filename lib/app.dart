import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/l10n.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wordbooks_screen.dart';
import 'theme.dart';
import 'widgets/panel.dart' show ContentWidth;

/// 알림 탭 등 위젯 트리 밖에서 화면을 열 때 쓰는 루트 내비게이터 키.
final rootNavigatorKey = GlobalKey<NavigatorState>();

class VocabularyApp extends ConsumerStatefulWidget {
  const VocabularyApp({super.key});

  @override
  ConsumerState<VocabularyApp> createState() => _VocabularyAppState();
}

class _VocabularyAppState extends ConsumerState<VocabularyApp> {
  String? _paletteKey;

  @override
  void initState() {
    super.initState();
    // 예문 데이터를 받기로 했으면 번역 언어의 해석 파일을 미리 받아 둔다
    // (언어를 바꿀 때도). 새 버전이 있으면 이때 받는다.
    ref.listenManual(
      settingsProvider.select((s) => (s.translationLanguage, s.exampleData)),
      (_, value) {
        if (value.$2 == true) {
          ref.read(translationPacksProvider).prefetch(value.$1);
        }
      },
      fireImmediately: true,
    );
  }

  /// 테마 색은 [AppColors]의 정적 값이라, 바뀌면 모든 위젯을 다시 그린다.
  void _applyPalette(String key, AppPalette palette) {
    if (_paletteKey == key) return;
    final changed = _paletteKey != null;
    _paletteKey = key;
    AppPalette.current = palette;
    if (!changed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      void rebuild(Element element) {
        element.markNeedsBuild();
        element.visitChildren(rebuild);
      }

      (context as Element).visitChildren(rebuild);
    });
  }

  @override
  Widget build(BuildContext context) {
    final translationLanguage = ref.watch(
      settingsProvider.select((s) => s.translationLanguageOverride),
    );
    final (themeId, base, point) = ref.watch(
      settingsProvider.select(
        (s) => (s.themeId, s.customThemeBase, s.customThemePoint),
      ),
    );
    _applyPalette(
      '$themeId/$base/$point',
      AppThemes.paletteFor(themeId, Color(base), Color(point)),
    );
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      // 번역 언어를 고르면 화면 언어도 같이 바뀐다. 지원하지 않는 언어는 영어로 보인다.
      locale: appLocaleFor(translationLanguage),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorKey: rootNavigatorKey,
      theme: buildAppTheme(),
      home: const HomeShell(),
    );
  }
}

/// 하단 탭 네비게이션 쉘.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  static const _pages = [HomeScreen(), WordbooksScreen(), SettingsScreen()];

  @override
  void initState() {
    super.initState();
    // 실행할 때마다 최신 단어로 알림 내용을 새로 채운다.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => rescheduleReminders(ref),
    );
    // 해석이 필요한 언어인데 아직 묻지 않았으면 예문 데이터를 받을지 묻는다.
    ref.listenManual(
      settingsProvider.select(
        (s) => s.exampleData == null && s.translationLanguage.hasTranslations,
      ),
      (_, ask) {
        if (ask) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _askExampleData(),
          );
        }
      },
      fireImmediately: true,
    );
  }

  bool _asking = false;

  Future<void> _askExampleData() async {
    if (_asking || !mounted) return;
    _asking = true;
    final language = ref.read(settingsProvider).translationLanguage;
    final packs = ref.read(translationPacksProvider);
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        key: const ValueKey('example-data-prompt'),
        title: Text(ctx.l10n.examplePromptTitle),
        content: FutureBuilder(
          future: packs.info(language),
          builder: (ctx, snapshot) {
            final bytes = snapshot.data?.bytes ?? 0;
            return Text(
              ctx.l10n.examplePromptBody(
                ctx.l10n.language(language),
                bytes > 0 ? ' (${(bytes / 1e6).toStringAsFixed(1)}MB)' : '',
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.examplePromptDecline),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.examplePromptAccept),
          ),
        ],
      ),
    );
    _asking = false;
    if (accepted == null || !mounted) return;
    await ref.read(settingsProvider.notifier).setExampleData(accepted);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeTabProvider);
    final labels = [
      context.l10n.navHome,
      context.l10n.navWordbooks,
      context.l10n.navSettings,
    ];
    return Scaffold(
      backgroundColor: AppColors.panel,
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: ColoredBox(
        color: AppColors.panel,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 본문과 같은 폭·여백 안에 탭을 둔다 (넓은 화면에서 양 끝으로 벌어지지 않게).
              ContentWidth(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        for (var i = 0; i < labels.length; i++)
                          Expanded(
                            child: Semantics(
                              selected: i == index,
                              button: true,
                              child: InkWell(
                                onTap: () =>
                                    ref.read(homeTabProvider.notifier).set(i),
                                child: Center(
                                  child: Text(
                                    labels[i],
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: i == index
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: i == index
                                          ? AppColors.onPanel
                                          : AppColors.onPanelSub,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
