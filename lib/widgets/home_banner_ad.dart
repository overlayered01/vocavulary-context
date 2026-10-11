import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../l10n/l10n.dart';
import '../providers.dart';
import '../theme.dart';

/// An anchored banner above the home navigation; no space until an ad loads.
class HomeBannerAd extends ConsumerWidget {
  const HomeBannerAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb && kDebugMode) return const _WebBannerPreview();
    if (!ref.watch(mobileAdsServiceProvider).enabled) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0, 728).floor();
          if (width < 320) return const SizedBox.shrink();
          final orientation = MediaQuery.orientationOf(context);
          // Recreate and dispose the native ad when its available size changes.
          return _AdaptiveBanner(
            key: ValueKey('$width/$orientation'),
            width: width,
          );
        },
      ),
    );
  }
}

/// A local layout preview; never initializes or requests a mobile ad.
class _WebBannerPreview extends StatelessWidget {
  const _WebBannerPreview();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          heightFactor: 1,
          child: Container(
            width: 320,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              context.l10n.adPreview,
              style: TextStyle(color: AppColors.sub, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaptiveBanner extends ConsumerStatefulWidget {
  final int width;
  const _AdaptiveBanner({super.key, required this.width});

  @override
  ConsumerState<_AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends ConsumerState<_AdaptiveBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final service = ref.read(mobileAdsServiceProvider);
      final ready = await service.initialize();
      if (!mounted || !ready) return;
      final adaptiveSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
        widget.width,
      );
      if (!mounted || adaptiveSize == null) return;
      // Keep large video banners from taking over the minimal home screen.
      final size = adaptiveSize.height > 90 ? AdSize.banner : adaptiveSize;
      final ad = BannerAd(
        adUnitId: service.bannerAdUnitId,
        size: size,
        request: const AdRequest(nonPersonalizedAds: true),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted || !identical(_ad, ad)) {
              unawaited(_release(ad));
              return;
            }
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Test banner failed to load: $error');
            if (identical(_ad, ad)) {
              _ad = null;
              if (mounted) setState(() => _loaded = false);
            }
            unawaited(_release(ad));
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (error) {
      debugPrint('Test banner unavailable: $error');
      final ad = _ad;
      _ad = null;
      if (ad != null) await _release(ad);
      if (mounted) setState(() => _loaded = false);
    }
  }

  Future<void> _release(Ad ad) async {
    try {
      await ad.dispose();
    } catch (error) {
      debugPrint('Test banner cleanup failed: $error');
    }
  }

  @override
  void dispose() {
    final ad = _ad;
    _ad = null;
    if (ad != null) unawaited(_release(ad));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        heightFactor: 1,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
