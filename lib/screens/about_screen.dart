import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/panel.dart';

/// 앱 버전. pubspec.yaml의 version과 맞춘다.
const kAppVersion = '1.0.0';

/// 데이터 출처와 라이선스. 출처는 고정이며, 라이선스상 표시가 필요하다.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sources = [
      (
        l10n.aboutUseMeanings,
        'Wiktionary (Kaikki.org)',
        'https://kaikki.org',
        'CC BY-SA 4.0',
      ),
      (
        l10n.aboutUseOnline,
        'Free Dictionary API',
        'https://freedictionaryapi.com',
        'CC BY-SA 4.0',
      ),
      (
        l10n.aboutUseExamples,
        'Tatoeba',
        'https://tatoeba.org',
        'CC BY 2.0 FR',
      ),
      (
        l10n.aboutUseRecordings,
        'Wikimedia Commons',
        'https://commons.wikimedia.org',
        'CC BY-SA',
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.panel,
      body: PanelPage(
        header: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(color: AppColors.ink),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
                  child: Text(
                    l10n.settingsAbout,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bodyPadding: EdgeInsets.zero,
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              PanelLabel(l10n.aboutDataSources),
              WhiteBlock(
                child: Column(
                  children: [
                    for (final (i, (use, name, url, license))
                        in sources.indexed)
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: i == sources.length - 1
                                ? null
                                : Border(
                                    bottom: BorderSide(color: AppColors.chip),
                                  ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      use,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.sub,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.chip,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      license,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                Uri.parse(url).host,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.sub2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PanelLabel(l10n.aboutApp),
              WhiteBlock(
                child: Column(
                  children: [
                    BlockRow(
                      title: l10n.aboutVersion,
                      trailing: Text(
                        kAppVersion,
                        style: TextStyle(fontSize: 15, color: AppColors.ink),
                      ),
                    ),
                    BlockRow(
                      title: l10n.aboutLicenses,
                      divider: false,
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.sub,
                      ),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: l10n.appTitle,
                        applicationVersion: kAppVersion,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
