/// Supabase 연결 설정.
///
/// 값은 두 가지 방법으로 주입할 수 있다 (둘 다 비어 있으면 로컬 모드로 동작):
///   1) 실행 시 --dart-define 전달 (권장, 소스에 키를 남기지 않음)
///        flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///                    --dart-define=SUPABASE_ANON_KEY=eyJhb...
///   2) 아래 defaultValue 에 직접 입력 (간편하지만 키가 소스에 노출됨)
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// 구글 OAuth 로그인 후 앱으로 돌아오는 딥링크.
  /// AndroidManifest 의 intent-filter scheme/host 와 일치해야 한다.
  static const String oauthRedirect = 'io.supabase.wordcloud://login-callback/';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
