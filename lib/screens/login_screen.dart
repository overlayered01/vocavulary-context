import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/migration.dart';
import '../data/supabase_repository.dart';
import '../providers.dart';
import '../theme.dart';

/// 로그인/회원가입. Supabase 설정 시에만 진입 가능.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) await _maybeOfferMigration();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 로그인 직후 로컬 단어장이 있으면 클라우드 이관을 제안한다.
  /// (구글 OAuth처럼 세션이 아직 없으면 건너뛴다 — 설정 화면에서 수동 가능)
  Future<void> _maybeOfferMigration() async {
    if (ref.read(authServiceProvider).currentUser == null) return;
    final local = ref.read(localRepositoryProvider);
    final books = await local.getWordbooks();
    if (books.isEmpty || !mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로컬 단어장 가져오기'),
        content: Text(
          '이 기기에서 만든 단어장 ${books.length}개를 클라우드로 복사할까요?\n'
          '이미 클라우드에 있는 단어장은 건너뜁니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('가져오기'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final migrated = await migrateLocalToCloud(local, SupabaseRepository());
    invalidateData(ref);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          migrated > 0 ? '단어장 $migrated개를 가져왔어요.' : '모든 단어장이 이미 클라우드에 있어요.',
        ),
      ),
    );
  }

  /// 인증 예외를 사용자용 안내 문구로 바꾼다. (raw 예외 문자열 노출 방지)
  String _friendlyError(Object e) {
    if (e is AuthException) {
      return switch (e.code) {
        'invalid_credentials' => '이메일 또는 비밀번호가 올바르지 않아요.',
        'user_already_exists' => '이미 가입된 이메일이에요. 로그인해 주세요.',
        'weak_password' => '비밀번호가 너무 짧아요. 6자 이상 입력해 주세요.',
        'email_not_confirmed' => '이메일 인증이 필요해요. 받은 편지함을 확인해 주세요.',
        'over_email_send_rate_limit' => '요청이 너무 잦아요. 잠시 후 다시 시도해 주세요.',
        _ => '로그인에 실패했어요. (${e.message})',
      };
    }
    return '요청을 처리하지 못했어요. 네트워크 상태를 확인하고 다시 시도해 주세요.';
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'WordCloud',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              '예문으로 쉽게, 알람으로 꾸준히',
              style: TextStyle(color: AppColors.sub),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: '이메일'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: '비밀번호'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.ink),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.ink, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _busy
                ? null
                : () => _run(
                    () => auth.signInWithEmail(
                      _email.text.trim(),
                      _password.text,
                    ),
                  ),
            child: _busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('로그인'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(
                    () => auth.signUpWithEmail(
                      _email.text.trim(),
                      _password.text,
                    ),
                  ),
            child: const Text('이메일로 회원가입'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
            child: const Text('구글로 계속하기'),
          ),
        ],
      ),
    );
  }
}
