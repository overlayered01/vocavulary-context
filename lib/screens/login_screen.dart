import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
