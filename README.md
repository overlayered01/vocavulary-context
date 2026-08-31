# WordCloud 단어장 (vocabulary)

예문으로 배우고, 알람으로 복습하고, 발음을 들으며, 클라우드로 공유하는 단어장 앱.

## 핵심 기능 (MVP)
- 📚 **단어장·단어·예문 관리** — 단어별 여러 예문 등록
- 📝 **예문 보고 단어 직접 입력 복습** — 빈칸 예문 + 뜻을 보고 단어를 입력 (첫 글자·글자 수 힌트)
- 🔁 **복습 섞기 비율** — 이미 외운 단어를 설정한 %만큼 다시 섞어 출제 (장기 기억 강화)
- 🔔 **주기 알람** — 매일 지정 시각 복습 알림 (flutter_local_notifications)
- 🔊 **발음 듣기** — 기기 TTS(미국식/영국식) + 네이버·구글 사전 딥링크
- ☁️ **클라우드 동기화** — Supabase 로그인 시 기기 간 동기화 (미설정 시 로컬 모드)

## 기술 스택
- **Flutter** (Dart) / 상태관리 **Riverpod**
- **Supabase** (Auth, Postgres + RLS) — `SUPABASE_설정가이드.md` 참고
- flutter_local_notifications · flutter_tts · url_launcher

## 프로젝트 구조
```
lib/
  main.dart              앱 부팅 (Supabase 시도 → 미설정 시 로컬 모드)
  app.dart               MaterialApp + 하단 탭 네비게이션
  theme.dart             색상·테마
  models/                Word, Wordbook, Example, AppSettings
  data/
    repository.dart      저장소 추상화 (로컬 ↔ Supabase 교체)
    local_repository.dart   SharedPreferences 기반 (기본)
    supabase_repository.dart Supabase(Postgres) 기반 (로그인 시)
    srs.dart             간격 반복 + 복습 세션(섞기 비율) 로직
    sample_data.dart     첫 실행 시드 단어장
  services/              tts / notification / auth
  providers.dart         Riverpod 프로바이더
  screens/               home, wordbooks, wordbook_detail,
                         word_detail, word_edit, review, settings, login
```

## 실행
```powershell
flutter pub get
flutter run            # 로컬 모드로 즉시 실행 (Supabase 불필요)
```

## 빌드 / 테스트
```powershell
flutter analyze        # 정적 분석
flutter test           # SRS·복습 로직 단위 테스트
flutter build apk --debug
```

## 클라우드 동기화 활성화
`SUPABASE_설정가이드.md`의 단계를 따라 Supabase 프로젝트를 만들고
`SUPABASE_URL`·`SUPABASE_ANON_KEY`를 `--dart-define`으로 주입하세요.
설정 후 앱 → 설정 → 계정에서 로그인하면 기기 간 동기화가 켜집니다.

## 기획·설계 문서
- `docs/기획문서.md`
- `docs/와이어프레임.html`
- `docs/기술스택비교.md`
