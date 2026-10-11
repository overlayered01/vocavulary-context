import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Test ads only. Production monetization needs its own IDs and consent flow.
class MobileAdsService {
  Future<bool>? _initialization;

  bool get enabled =>
      kDebugMode &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String get bannerAdUnitId => defaultTargetPlatform == TargetPlatform.iOS
      ? 'ca-app-pub-3940256099942544/2435281174'
      : 'ca-app-pub-3940256099942544/9214589741';

  Future<bool> initialize() {
    if (!enabled) return Future.value(false);
    return _initialization ??= _initialize();
  }

  Future<bool> _initialize() async {
    try {
      await MobileAds.instance.initialize();
      return true;
    } catch (error) {
      _initialization = null;
      debugPrint('Test ads initialization failed: $error');
      return false;
    }
  }
}
