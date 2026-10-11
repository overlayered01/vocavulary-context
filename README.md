# 예문 단어장 · Vocab with Examples (vocabulary)

예문으로 배우고, 알람으로 복습하고, 발음을 들으며, 클라우드로 공유하는 단어장 앱.

## 핵심 기능
- 🃏 **단어 = 카드** — 외운 카드는 버리고, 홈에는 남은 카드 수와 다음 카드의 예문만 크게 보여 줌
- 📝 **예문 복습** — 빈칸 예문을 보고 4지선다 또는 직접 입력. 정답을 확인하면 같은 카드에서 단어가 채워지고 [남기기 / 버리기] 선택
- 📚 **단어장** — 남은 카드 중심 목록, 오른쪽으로 밀어 버리기, 버린 카드는 따로 보고 다시 넣기
- 🏷️ **품사별 카드** — 단어 추가 시 품사 하나의 뜻과 그 품사 예문만 골라 저장
- 🔁 **버린 카드 다시 섞기** — 설정한 %만큼 버린 카드를 복습에 섞음
- 🔔 **알림 구간** — 요일·시간대·간격·한 번에 받을 장수 지정
- 🔊 **발음** — 억양·목소리·속도 선택, 단어는 Wikimedia Commons 사람 녹음 우선
- 🎨 **테마** — 프리셋 5종 + 바탕·포인트 색 직접 지정
- ☁️ **클라우드 동기화** — Supabase 로그인 시 기기 간 동기화 (미설정 시 로컬 모드)

## 기술 스택
- **Flutter** (Dart) / 상태관리 **Riverpod**
- **Supabase** (Auth, Postgres + RLS) — `SUPABASE_설정가이드.md` 참고
- flutter_local_notifications · flutter_tts · audioplayers · url_launcher

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

## 예문 단어장 테스트

현재 Windows PC의 Flutter 경로는 `$env:USERPROFILE\.local\share\flutter\bin\flutter.bat`입니다.
프로젝트 폴더에서 다음 명령으로 웹 테스트 화면을 실행할 수 있습니다.

```powershell
& "$env:USERPROFILE\.local\share\flutter\bin\flutter.bat" run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```

브라우저에서 `http://127.0.0.1:7357`을 엽니다. 서버 종료는 실행 터미널에서 `Ctrl+C`입니다.
Android 설치 파일은 `build/app/outputs/flutter-apk/app-debug.apk`입니다.
Android 패키지명은 `com.easywith.vocabulary`로 유지하므로, 같은 서명의 기존 앱에 업데이트하면 저장된 데이터를 유지합니다.
다른 PC에서 만든 APK와 서명이 다르면 업데이트 설치가 거절될 수 있습니다. 기존 앱을 삭제하기 전 설정에서 데이터를 내보내세요.

테스트할 항목:
- 홈·로그인·설정 및 설치된 앱의 이름이 **예문 단어장**(영어: **Vocab with Examples**)인지 확인
- 단어장 생성 → 단어 입력 → 사전 자동 작성 → 수정·저장 → 다시 실행 후 데이터 확인
- 직접 입력·객관식 복습과 단어·예문 발음 듣기
- Android 기기에서 알림 권한·예약 알림·홈 테스트 광고 확인

기본 빌드는 로컬 모드입니다. 로그인·동기화·공유 테스트에는 아래 Supabase 설정이 필요합니다.
웹에서는 실제 모바일 광고와 기기 알림을 검증할 수 없으므로 Android 기기에서 확인하세요.

## 클라우드 동기화 활성화
`SUPABASE_설정가이드.md`의 단계를 따라 Supabase 프로젝트를 만들고
`SUPABASE_URL`·`SUPABASE_ANON_KEY`를 `--dart-define`으로 주입하세요.
설정 후 앱 → 설정 → 계정에서 로그인하면 기기 간 동기화가 켜집니다.

## 단어 추가 (품사별 카드)
단어 하나는 카드 한 장이고, **카드 한 장은 품사 하나**입니다. 같은 단어라도
동사·명사로 모두 외우려면 카드를 따로 만듭니다(abandon `verb`, abandon `noun`).

1. **뜻 선택** — 단어를 입력하면 사전 결과가 품사별 카드로 나옵니다.
   한 품사를 고르고 저장할 뜻을 체크합니다. 이미 덱에 있는 품사는 고를 수 없고,
   사전에 없으면 품사를 고른 뒤 뜻을 직접 입력합니다.
2. **예문 고르기** — 고른 품사의 예문만 후보로 나옵니다. 체크한 예문만 저장되며
   직접 쓸 수도 있습니다. **덱에 넣기**를 누르면 저장됩니다.

예문 후보 순서는 ① 앱에 내장한 언어판 사전의 품사별 예문(번역 포함 가능)
② 온라인 영어 사전 예문(번역 없음) ③ 앱에 내장한 Tatoeba 예문(번역 있음)
④ 온라인 Tatoeba입니다. 내장 Tatoeba 예문은 `tool/build_examples.py`가 spaCy로
품사를 미리 붙여 두어 인터넷 없이도 카드 품사에 맞는 문장만 나옵니다
(영어 문장과 "단어|품사" 색인은 `assets/examples/en.json`에 내장). 예문 해석은 용량이
커서 앱에 넣지 않고, 기기가 번역 언어의 파일 하나만 공개 데이터 저장소
[overlayered01/vocabulary-data](https://github.com/overlayered01/vocabulary-data)에서
jsDelivr CDN으로 받아 저장합니다(설정 → 언어에 받기 상태 표시). 올리기는
`tool/publish_packs.py`가 하며, 목록(`manifest.json`)의 버전이 바뀔 때만 다시 받습니다.
내장 예문이 3개보다 적거나 해석 있는 문장이 없으면 온라인 Tatoeba도 부르며,
여기에는 품사 정보가 없어 앞뒤 단어로 거릅니다. 자동 뜻·예문 입력과 예문 해석 여부는 설정 또는
단어 추가 화면 아래의 자동 입력 줄에서 바꿉니다.

단어 추가·편집 및 상세 화면의 **사전 뜻 보기**에서 사전 풀이를 조회하고,
선택한 뜻을 기존 뜻에 추가할 수 있습니다. API 키 없이 동작합니다.
설정 → **언어**에서 한국어·일본어·중국어·스페인어·프랑스어·독일어·포르투갈어·베트남어·태국어·인도네시아어를 선택할 수 있습니다.
선택 언어의 번역이 제공되는 항목은 번역과 영어 풀이를 함께 보여주며,
번역이 없는 항목은 영어 풀이를 사용합니다. 사전 순서대로 표시하며 빈도순 추천은 아닙니다.
예문도 선택 언어의 번역을 우선 조회하고, 번역이 없는 문장의 해석은 비워둡니다.
설정은 기기에 저장되며, 언어별로 조회 캐시를 분리합니다. 이미 저장한 단어는 자동으로 번역하지 않습니다.
다른 번역 언어로 같은 단어를 새로 추가하면 이전 언어의 뜻·예문을 복사하지 않고 다시 조회합니다.
이는 사전·Tatoeba에 제공된 번역 조회이며, 번역이 없는 내용을 새로 생성하는 기계번역 기능은 아닙니다.

사전 데이터는 [Wiktionary](https://en.wiktionary.org/) 기여자들의 자료이며
[FreeDictionaryAPI.com](https://freedictionaryapi.com/)을 통해 제공합니다.
한국어·일본어·중국어 뜻은 앱에 내장한 각 언어판 Wiktionary 사전을 먼저 사용합니다.
[Kaikki.org](https://kaikki.org/) 추출 데이터를 `tool/build_dictionary.py ko|ja|zh`로 가공해
`assets/dictionaries/<언어>.json`에 넣으며(품사별 뜻 최대 8개와 예문 최대 2개), 없는 단어는 기본형(went → go)으로 다시 찾고 그래도 없으면 온라인 사전을 씁니다.
중국어판은 번체가 많아 간체로 변환합니다(`pip install opencc-python-reimplemented` 필요).
가져온 사전 내용(편집한 내용 포함)에는 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)이 적용됩니다.
앱에서 각 단어의 원문과 라이선스를 열 수 있으며, 저장·내보내기·가져오기 시 원문 조회 단어를 보존합니다.

## 테스트 광고

Android·iOS **디버그 빌드**의 홈 화면 하단에 Google AdMob 테스트 배너를 표시합니다.
단어장·설정 탭과 단어 입력·복습 화면에는 표시하지 않습니다.
광고가 로드되기 전이나 실패한 경우에는 배너 공간을 숨기며, 광고 로딩은 앱 시작을 막지 않습니다.
웹·데스크톱 및 릴리스·프로파일 빌드에서는 광고를 요청하지 않습니다.
웹 디버그 실행에서는 위치를 확인할 수 있도록 홈 하단에 320×50 크기의 **광고 미리보기**를 표시합니다.
미리보기는 실제 광고가 아니며, 앱의 적응형 배너 크기는 기기에 따라 달라질 수 있습니다.

```powershell
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```

브라우저에서 `http://127.0.0.1:7357`을 열면 확인할 수 있습니다.

```powershell
flutter build apk --debug
```

설치 파일: `build/app/outputs/flutter-apk/app-debug.apk`.
Google의 샘플 앱 ID와 적응형 배너 ID를 사용하므로 수익은 발생하지 않습니다.
실제 광고를 운영하려면 본인 AdMob 앱·광고 단위 ID, 필요한 동의 처리와 배포 설정을 별도로 적용해야 합니다.
현재 릴리스 서명 설정은 변경하지 않았습니다.
[Google 테스트 광고 안내](https://developers.google.com/admob/flutter/test-ads?hl=ko),
[적응형 배너 안내](https://developers.google.com/admob/flutter/banner?hl=ko).

## 기획·설계 문서

- `docs/기획문서.md`
- `docs/와이어프레임.html`
- `docs/기술스택비교.md`
- [사전 API 서비스 비교](docs/사전_API_서비스_비교.md) — 무료 범위, 한국어 지원, 저장 조건, 속도 확인 기록과 권장 구성
