import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wordbooks_screen.dart';
import 'theme.dart';

/// 알림 탭 등 위젯 트리 밖에서 화면을 열 때 쓰는 루트 내비게이터 키.
final rootNavigatorKey = GlobalKey<NavigatorState>();

class VocabularyApp extends StatelessWidget {
  const VocabularyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordCloud 단어장',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: buildAppTheme(),
      home: const HomeShell(),
    );
  }
}

/// 하단 탭 네비게이션 쉘.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _pages = [
    HomeScreen(),
    WordbooksScreen(),
    ExploreScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabProvider);
    return Scaffold(
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(homeTabProvider.notifier).set(i),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accentSoft,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '단어장',
          ),
          NavigationDestination(
            icon: Icon(Icons.travel_explore_outlined),
            selectedIcon: Icon(Icons.travel_explore),
            label: '탐색',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
