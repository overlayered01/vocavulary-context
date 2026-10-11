# Vocab with Examples — Google Play 해외 출시 준비

확인일: 2026-09-22

목표: 영어를 학습하는 여러 국가의 사용자에게 Android 앱을 배포한다.
현재 상태: 로컬 코드와 Google 공식 등록 요건을 검토했다. Play Console 앱 생성, 계정 상태, 스토어 등록, 출시용 번들 업로드는 확인되지 않았다. 아래 국가·언어 범위는 제안이며 최종 선택 전이다.

## 1. 앱 등록 시 입력할 기본 정보

| 항목 | 준비 내용 |
| --- | --- |
| 앱 이름 | Vocab with Examples (한국어: 예문 단어장) |
| 기본 스토어 언어 | 영어(미국), en-US 제안 |
| 앱/게임 | 앱 |
| 카테고리 | 교육 제안 |
| 무료/유료 | 무료 + 광고 수익 모델 제안, 최종 선택 필요 |
| 지원 이메일 | 실제 운영할 주소 필요 |
| 개발자 웹사이트 | 앱 소개·개인정보처리방침·app-ads.txt를 제공할 주소 필요 |
| 현재 Android 패키지명 | com.easywith.vocabulary |
| 현재 버전 | 1.0.0+1 |

스토어 기본 언어, 앱 화면 언어, 단어 뜻·예문 번역 언어, 배포 국가는 각각 설정해야 한다. 스토어 번역을 추가해도 Flutter 화면이나 학습 콘텐츠가 자동으로 바뀌지 않는다.

앱 패키지명은 표시 이름과 별개다. Google Play에 처음 업로드하기 전에 확정한다. 공식 안내상 패키지명은 고유하고 영구적이다.

출처: [앱 만들기 및 설정](https://support.google.com/googleplay/android-developer/answer/9859152?hl=ko), [앱 번역 및 현지화](https://support.google.com/googleplay/android-developer/answer/9844778?hl=ko).

## 2. 국가와 언어 제안

학습 언어는 영어로 유지한다. 국가별로 달라지는 것은 화면 안내와 뜻·예문 번역에 사용하는 언어다. 아래 목록은 시장 규모 순위가 아닌 출시 범위 제안이다.

| 국가·지역 후보 | 스토어 현지화 언어 코드 |
| --- | --- |
| 한국 | ko-KR |
| 일본 | ja-JP |
| 대만·홍콩 | zh-TW, zh-HK |
| 베트남 | vi |
| 태국 | th |
| 인도네시아 | id |
| 인도 | hi-IN, en-IN — 인도의 다른 모국어는 후속 확장 검토 |
| 브라질 | pt-BR |
| 멕시코·콜롬비아·아르헨티나·칠레·페루 등 | es-419 |
| 스페인 | es-ES |
| 프랑스 | fr-FR |
| 독일 | de-DE |
| 이탈리아 | it-IT |
| 튀르키예 | tr-TR |
| 사우디아라비아·아랍에미리트·이집트 등 | ar |
| 말레이시아·필리핀 | ms-MY, fil, 영어 |
| 미국·캐나다·영국·호주·싱가포르 등의 영어 학습자 | 영어 기본 소개, 해당 사용자의 모국어 소개 |

위 코드는 Google Play 스토어 등록정보용이다. Flutter의 언어·문자 체계·국가 코드와는 별도로 매핑해야 한다. 예를 들어 번체 중국어는 앱에서 문자 체계도 고려하고, 아랍어는 오른쪽에서 왼쪽으로 쓰는 화면을 점검한다.

첫 출시 제안: 앱은 영어·한국어를 지원하고, 스토어 소개는 위 언어로 확대한다. 각 모국어의 뜻·예문 자동 번역을 약속하려면 해당 언어의 데이터 제공 범위와 앱 동작을 먼저 확인한다. 전체 화면까지 현지화하는 범위는 별도 선택이 필요하다.

배포 국가는 Play Console의 프로덕션 → 국가/지역에서 선택한다. 지원 가능한 국가를 넓게 열고 현지화 언어를 순차 추가하는 방법도 있다. 실제 선택 가능 여부는 계정의 Console 화면에서 확인한다.

영어 학습 수요의 참고 자료로 Duolingo 2025 보고서에서는 영어가 해당 서비스의 154개국에서 가장 많이 학습된 언어였다. 이는 Duolingo 이용자 데이터이며 전체 시장의 규모·수익 순위는 아니다.

출처: [Google Play 언어 목록](https://support.google.com/googleplay/android-developer/answer/9844778?hl=ko), [국가별 배포 설정](https://support.google.com/googleplay/android-developer/answer/7550024?hl=ko), [Duolingo 2025 언어 보고서](https://blog.duolingo.com/2025-duolingo-language-report/).

## 3. 현재 코드에서 확인한 출시 준비 사항

| 항목 | 확인 결과 | 필요한 작업 |
| --- | --- | --- |
| 앱 표시 이름 | Android·iOS·웹·화면에 예문 단어장(한국어)·Vocab with Examples(그 외) 적용 | 새 빌드에 반영 |
| 화면 다국어 지원 | 한국어 문자열이 화면에 직접 작성되어 있고 MaterialApp에 지원 언어 설정 없음 | 문자열 리소스 분리, 영어 기본값, 언어 선택 및 저장 |
| 단어 뜻 | 설정에서 10개 번역 언어 선택, 선택 언어의 사전 뜻 조회와 영어 풀이 대체 구현 | 배포 대상 언어별 번역 제공 범위·실기기 확인 |
| 예문 번역 | 선택 언어로 Tatoeba 조회, 언어별 캐시 분리, 번역 없는 해석은 빈 값 유지 | 배포 대상 언어별 예문 제공 범위·실기기 확인 |
| 알림 | 제목·본문·채널 안내가 한국어 | 선택 언어 반영 및 언어 변경 시 예약 갱신 |
| 출시 서명 | release가 debug 서명을 사용 | 업로드 키와 release 서명 설정 후 AAB 생성 |
| Android 대상 API | 현재 설치된 Flutter의 기본 targetSdkVersion은 36 | 최종 AAB에서도 API 36 이상인지 검증 |
| 광고 | 디버그 모바일 테스트 광고만 활성화 | 운영 AdMob ID, 동의 처리, 출시 설정 연결 |
| 개인정보 안내 | 앱 내 개인정보처리방침 링크를 찾지 못함 | 실제 데이터 처리에 맞는 공개 페이지와 앱 내 링크 준비 |
| 계정 삭제 | 회원가입 코드는 있고 계정 삭제 처리는 찾지 못함 | 계정 기능을 제공하는 출시에서는 앱 내부 및 외부 삭제 요청 경로 준비 |
| 데이터 보안 신고 | Console 상태 미확인 | 최종 빌드의 Supabase·사전·예문·광고 SDK 이용 내역에 맞춰 작성 |

2026-08-31부터 일반 Android 신규 앱과 업데이트는 API 36 이상을 대상으로 해야 한다. 계정 생성이 가능한 앱에는 앱 안과 외부 웹에서 계정 삭제를 요청할 수 있는 경로가 필요하다. 모든 앱에는 스토어 및 앱 내 개인정보처리방침이 필요하다.

출처: [대상 API 요건](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en), [사용자 데이터 정책](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en-GB), [데이터 보안 신고](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-AE), [AdMob UMP](https://developers.google.com/admob/flutter/privacy?hl=ko), [app-ads.txt 인증](https://support.google.com/admob/answer/14538460?hl=en).

## 4. 영어 스토어 소개 초안

영어 앱 화면을 제공하는 출시를 위한 초안이다. 번역이 실제 구현되기 전에는 영어 UI를 지원한다고 안내하지 않는다. 클라우드·공유·다국어 자동 번역은 출시 검증 전이므로 아래 홍보 문구에 포함하지 않았다.

앱 이름: Vocab with Examples

간단한 설명:

> Learn English vocabulary through example sentences and daily review.

자세한 설명:

> Build your English vocabulary with sentences that give words context.
>
> Vocab with Examples helps you collect words, add meanings and examples, and return to them for regular practice.
>
> • Organize vocabulary into your own wordbooks.
> • Look up English definitions, pronunciation information, and example sentences when available.
> • Practice recalling words from sentence clues.
> • Review with spaced repetition and mix familiar words back into your sessions.
> • Listen to words and sentences using your device's text-to-speech voices.
> • Set study reminders that fit your routine.
>
> Dictionary lookups and online examples require an internet connection. Voice availability depends on your device. You can edit word meanings and examples before saving them.

## 5. 진행 순서

1. Play 개발자 계정 생성 여부·유형을 확인하고 앱을 생성한다.
2. 최초 앱 화면 언어와 뜻·예문 언어 지원 범위를 정한다.
3. 현지화, 개인정보 안내, 필요한 계정 삭제 및 광고 동의 흐름을 구현한다.
4. 지원 이메일·웹사이트·스토어 소개·아이콘·스크린샷을 준비한다.
5. 업로드 키와 출시 서명을 구성하고 AAB를 빌드하여 내부 테스트한다.
6. 해당 계정에 요구되는 테스트를 진행하고 국가/지역 및 현지화 등록정보를 입력한다.
7. 실제 기기·배포 언어·광고·로그인 동작을 검증한 빌드를 검토용으로 제출한다.

2023-11-13 이후 생성된 개인 개발자 계정은 프로덕션 액세스를 신청하기 전에 최소 12명의 테스터가 연속 14일 동안 참여를 선택한 상태로 비공개 테스트를 진행해야 한다. 기간 충족 후에도 프로덕션 액세스 신청과 검토가 필요하다. 계정 유형과 생성 시점은 아직 확인되지 않았다.

출처: [개인 개발자 계정 테스트 요건](https://support.google.com/googleplay/android-developer/answer/14151465?hl=ko).
