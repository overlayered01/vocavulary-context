import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/migration.dart';
import '../data/supabase_repository.dart';
import '../l10n/l10n.dart';
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

    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.loginMigrateTitle),
        content: Text(l10n.loginMigrateConfirm(books.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.loginLater),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.loginImport),
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
          migrated > 0
              ? context.l10n.loginMigrated(migrated)
              : context.l10n.loginAlreadyInCloud,
        ),
      ),
    );
  }

  /// 인증 예외를 사용자용 안내 문구로 바꾼다. (raw 예외 문자열 노출 방지)
  String _friendlyError(Object e) {
    final l10n = context.l10n;
    if (e is AuthException) {
      return switch (e.code) {
        'invalid_credentials' => l10n.loginErrorInvalidCredentials,
        'user_already_exists' => l10n.loginErrorUserExists,
        'weak_password' => l10n.loginErrorWeakPassword,
        'email_not_confirmed' => l10n.loginErrorEmailNotConfirmed,
        'over_email_send_rate_limit' => l10n.loginErrorRateLimit,
        _ => l10n.loginErrorGeneric(e.message),
      };
    }
    return l10n.loginErrorNetwork;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              l10n.appTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              l10n.loginTagline,
              style: TextStyle(color: AppColors.sub),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.loginEmail),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.loginPassword),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.ink),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.ink, fontSize: 12),
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
                : Text(l10n.loginTitle),
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
            child: Text(l10n.loginSignUpWithEmail),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
            child: Text(l10n.loginContinueWithGoogle),
          ),
        ],
      ),
    );
  }
}
