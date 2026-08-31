import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';

/// Supabase 인증 래퍼 (이메일·구글). Supabase 가 설정된 경우에만 사용된다.
class AuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// 로그인 상태 변화 스트림. 화면 갱신용으로 User? 만 흘려보낸다.
  Stream<User?> authStateChanges() =>
      _auth.onAuthStateChange.map((state) => state.session?.user);

  User? get currentUser => _auth.currentUser;

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) {
    return _auth.signUp(email: email, password: password);
  }

  /// 구글 로그인. 외부 브라우저로 OAuth 진행 후 딥링크로 복귀한다.
  /// Supabase 대시보드에서 Google provider 를 활성화해야 동작한다.
  Future<bool> signInWithGoogle() {
    return _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: SupabaseConfig.oauthRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
