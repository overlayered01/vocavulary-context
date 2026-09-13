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

## 사전 뜻 조회
**단어 추가** 화면에서 단어장을 선택하고 단어를 입력한 뒤 **완료**를 누르면
뜻·품사·발음기호·예문을 채웁니다. 저장된 같은 단어의 내용을 우선 참고하고 부족한 정보는 사전과
Tatoeba에서 가져옵니다. 사전에서 뜻을 채울 때는 한 품사의 뜻을 최대 3개 사용하며,
찾지 못한 항목은 비워둡니다. 확인·수정 후 저장해야 단어장에 추가됩니다.
사전 응답이 오면 먼저 편집 화면을 열고 예문은 백그라운드에서 채웁니다.
예문 도착 전에 직접 수정하거나 단어를 변경한 경우, 또는 저장한 경우에는 나중 결과를 덮어쓰지 않습니다.
같은 예문 조회는 진행 중 요청을 공유하며 성공한 결과를 10분간 메모리에 보관합니다.

단어 추가·편집 및 상세 화면의 **사전 뜻 보기**에서 사전 풀이를 조회하고,
선택한 뜻을 기존 뜻에 추가할 수 있습니다. API 키 없이 동작합니다.
한국어 번역이 제공되는 항목은 번역과 영어 풀이를 함께 보여주며,
번역이 없는 항목은 영어 풀이를 사용합니다. 사전 순서대로 표시하며 빈도순 추천은 아닙니다.

사전 데이터는 [Wiktionary](https://en.wiktionary.org/) 기여자들의 자료이며
[FreeDictionaryAPI.com](https://freedictionaryapi.com/)을 통해 제공합니다.
가져온 사전 내용(편집한 내용 포함)에는 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)이 적용됩니다.
앱에서 각 단어의 원문과 라이선스를 열 수 있으며, 저장·내보내기·가져오기 시 원문 조회 단어를 보존합니다.

## 기획·설계 문서

- `docs/기획문서.md`
- `docs/와이어프레임.html`
- `docs/기술스택비교.md`
- [사전 API 서비스 비교](docs/사전_API_서비스_비교.md) — 무료 범위, 한국어 지원, 저장 조건, 속도 확인 기록과 권장 구성
