import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// The SDK's codec is needed to simulate native callbacks, not real ad requests.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabulary/app.dart';
import 'package:vocabulary/data/local_repository.dart';
import 'package:vocabulary/providers.dart';
import 'package:vocabulary/services/mobile_ads_service.dart';
import 'package:vocabulary/widgets/home_banner_ad.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  Completer<InitializationStatus>? pendingInitialization;
  var bannerHeight = 50.0;

  setUp(() {
    calls.clear();
    pendingInitialization = null;
    bannerHeight = 50;
    instanceManager = AdInstanceManager('plugins.flutter.io/google_mobile_ads');
    messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'MobileAds#initialize':
          return pendingInitialization?.future ?? InitializationStatus({});
        case 'AdSize#getLargeAnchoredAdaptiveBannerAdSize':
          return bannerHeight;
        default:
          return null;
      }
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, (
      call,
    ) async {
      if (call.method == 'create') return 0;
      if (call.method == 'resize') {
        return {
          'width': call.arguments['width'],
          'height': call.arguments['height'],
        };
      }
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(instanceManager.channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
  });

  Iterable<MethodCall> named(String method) =>
      calls.where((call) => call.method == method);

  Future<void> sendEvent(int adId, String event, {LoadAdError? error}) async {
    final data = instanceManager.channel.codec.encodeMethodCall(
      MethodCall('onAdEvent', {
        'adId': adId,
        'eventName': event,
        'loadAdError': ?error,
      }),
    );
    await messenger.handlePlatformMessage(
      instanceManager.channel.name,
      data,
      (_) {},
    );
  }

  Future<void> pumpBanner(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('학습 화면')),
            bottomNavigationBar: HomeBannerAd(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('데스크톱에서는 광고 SDK를 초기화하지 않는다', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(await MobileAdsService().initialize(), isFalse);
    expect(calls, isEmpty);
  });

  test('동시에 초기화해도 SDK 요청을 공유한다', () async {
    final service = MobileAdsService();
    expect(await Future.wait([service.initialize(), service.initialize()]), [
      true,
      true,
    ]);
    expect(named('MobileAds#initialize'), hasLength(1));
  });

  testWidgets('광고가 늦어도 화면을 사용하고 로드 후 배너 크기만 확보한다', (tester) async {
    await pumpBanner(tester);
    expect(find.text('학습 화면'), findsOneWidget);
    expect(tester.getSize(find.byType(HomeBannerAd)).height, 0);
    final arguments = named('loadBannerAd').single.arguments as Map;
    expect(arguments['adUnitId'], 'ca-app-pub-3940256099942544/9214589741');
    expect((arguments['request'] as AdRequest).nonPersonalizedAds, isTrue);
    await sendEvent(arguments['adId'] as int, 'onAdLoaded');
    await tester.pumpAndSettle();
    expect(find.byType(AdWidget), findsOneWidget);
    expect(tester.getSize(find.byType(AdWidget)), const Size(400, 50));
    expect(tester.getSize(find.byType(HomeBannerAd)).height, 74);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(named('disposeAd'), hasLength(1));
  });

  testWidgets('지나치게 큰 광고 대신 작은 표준 배너를 요청한다', (tester) async {
    bannerHeight = 150;
    await pumpBanner(tester);
    final size = named('loadBannerAd').single.arguments['size'] as AdSize;
    expect(size.width, 320);
    expect(size.height, 50);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('광고 로딩 실패 시 빈 공간을 남기지 않고 리소스를 정리한다', (tester) async {
    await pumpBanner(tester);
    final adId = named('loadBannerAd').single.arguments['adId'] as int;
    await sendEvent(
      adId,
      'onAdFailedToLoad',
      error: LoadAdError(2, 'test', 'Offline', null),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AdWidget), findsNothing);
    expect(tester.getSize(find.byType(HomeBannerAd)).height, 0);
    expect(find.text('학습 화면'), findsOneWidget);
    expect(named('disposeAd'), hasLength(1));
  });

  testWidgets('화면 너비가 바뀌면 이전 광고를 정리하고 새 크기로 조회한다', (tester) async {
    await pumpBanner(tester);
    final firstId = named('loadBannerAd').single.arguments['adId'] as int;
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(named('loadBannerAd'), hasLength(2));
    expect(named('disposeAd').single.arguments['adId'], firstId);
    final lastArguments = named('loadBannerAd').last.arguments as Map;
    expect((lastArguments['size'] as AdSize).width, 728);
    // An old callback must not display an ad sized for the previous screen.
    await sendEvent(firstId, 'onAdLoaded');
    await tester.pumpAndSettle();
    expect(find.byType(AdWidget), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('초기화 도중 화면을 닫으면 늦은 결과로 광고를 요청하지 않는다', (tester) async {
    pendingInitialization = Completer<InitializationStatus>();
    await pumpBanner(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    pendingInitialization!.complete(InitializationStatus({}));
    await tester.pumpAndSettle();
    expect(named('loadBannerAd'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈에서 다른 탭으로 이동하면 배너가 제거되고 광고를 정리한다', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = LocalRepository();
    await repo.init();
    final container = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        localRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeShell()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeBannerAd), findsOneWidget);
    expect(named('loadBannerAd'), hasLength(1));
    container.read(homeTabProvider.notifier).set(1);
    await tester.pumpAndSettle();
    expect(find.byType(HomeBannerAd), findsNothing);
    expect(named('disposeAd'), hasLength(1));
    container.read(homeTabProvider.notifier).set(2);
    await tester.pumpAndSettle();
    expect(find.byType(HomeBannerAd), findsNothing);
    expect(named('loadBannerAd'), hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
