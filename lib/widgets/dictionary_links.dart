import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

enum DictionarySource {
  naver('네이버 영한'),
  cambridge('Cambridge 영한'),
  oxford('Oxford 영영');

  final String label;
  const DictionarySource(this.label);

  Uri searchUri(String term) {
    final query = term.trim();
    return switch (this) {
      DictionarySource.naver => Uri.https(
        'en.dict.naver.com',
      ).replace(fragment: '/search?query=${Uri.encodeComponent(query)}'),
      DictionarySource.cambridge => Uri.https(
        'dictionary.cambridge.org',
        '/search/english-korean/direct/',
        {'q': query},
      ),
      DictionarySource.oxford => Uri.https(
        'www.oxfordlearnersdictionaries.com',
        '/search/english/',
        {'q': query},
      ),
    };
  }
}

class DictionaryLinks extends StatelessWidget {
  final String term;
  const DictionaryLinks({super.key, required this.term});

  Future<void> _open(BuildContext context, DictionarySource source) async {
    try {
      final opened = await launchUrl(
        source.searchUri(term),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (opened || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사전을 열지 못했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사전에서 더 보기',
          style: TextStyle(color: AppColors.sub, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final source in DictionarySource.values)
              TextButton.icon(
                onPressed: term.trim().isEmpty
                    ? null
                    : () => _open(context, source),
                icon: const Icon(Icons.open_in_new, size: 15),
                label: Text(source.label),
              ),
          ],
        ),
      ],
    );
  }
}
