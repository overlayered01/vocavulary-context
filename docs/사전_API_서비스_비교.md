# 사전 API 서비스 비교

작성·공식 자료 확인일: 2026-09-14

대상: Vocab with Examples의 뜻·품사·발음기호·예문 자동 입력

현재 앱은 **FreeDictionaryAPI.com으로 사전 뜻을, Tatoeba로 예문을 무료 조회**한다. 무료로 속도를 더 개선하려면 자주 쓰는 단어 데이터를 앱에 미리 넣고, 없는 단어만 외부에서 조회하는 구성이 적합하다. 기본 사전 내장은 아직 제안 단계다.

## 서비스 비교

요금과 한도는 확인일의 공개 안내 기준이다. 한국어 지원은 **영어 단어에 대한 한국어 뜻**을 기준으로 적었다. 예문 번역과 단어 뜻은 별개다.

| 서비스 | 무료 범위·키 | 한국어 지원 | 앱에서의 용도·검토 결과 |
| --- | --- | --- | --- |
| [FreeDictionaryAPI.com](https://freedictionaryapi.com/) | 무료, 키 불필요. IP당 시간당 1,000회 | 번역 데이터가 있는 뜻에 한해 제공 | 현재 사용. 뜻·품사·발음기호·일부 예문 조회 |
| [dictionaryapi.dev](https://dictionaryapi.dev/) | 무료, 공개 URL로 조회 | 공식 안내는 영어 풀이 중심. 영한 지원 미확인 | 영영 사전 대안. 현재 환경의 간이 측정에서는 응답 지연 |
| [WordsAPI](https://www.wordsapi.com/) | 홈페이지상 Basic 일 2,500회 무료. RapidAPI 가입·키 필요 | 영어 중심. 한국어 뜻 제공 미확인 | 정의·연관어 조회 후보. 장기 저장 조건 검토 필요 |
| [Collins API](https://www.collinsdictionary.com/collins-api) | 월 5,000회까지 무료 안내. 키 신청 필요 | 영한 웹 사전은 있으나 영한 **API 제공 범위는 미확인** | 이중언어 사전 후보. 저장 및 상업 이용 조건 확인 필요 |
| [Cambridge Dictionary API](https://dictionary-api.cambridge.org/api/) | 평가용 30일·3,000회. 정식 이용은 별도 계약 | English–Korean 사전 명시 | 영한 데이터 후보. 지속적인 무료 운영 대안으로 보기는 어려움 |
| [Tatoeba](https://api.tatoeba.org/) | 공개 API·다운로드 데이터 | 한국어 번역이 연결된 영어 예문 | 현재 사용. 단어 정의를 제공하는 사전은 아님 |
| [Kaikki / Wiktionary](https://kaikki.org/) | 무료 공개 데이터 다운로드. 조회 API와 다른 방식 | 한국어판 추출물에 영어 표제어 약 1.5만 개의 한국어 풀이 | 기본 사전 내장 1순위 후보. 아래 [언어판 Wiktionary 측정](#언어판-wiktionary-측정-2026-10-06) 참고 |

FreeDictionaryAPI.com과 dictionaryapi.dev는 이름이 비슷하지만 **서로 다른 서비스**다.

## 현재 앱에 적용된 내용

| 항목 | 현재 동작 | 구현 |
| --- | --- | --- |
| 사전 조회 | 한국어·일본어·중국어는 내장한 언어판 Wiktionary 사전(기본형 대체 조회)을 먼저 쓰고, 온라인 사전 결과를 뒤에 합친다. 온라인은 `en` 항목을 `translations=true`로 조회하며 번역이 없으면 영어 풀이 사용 | [local_dictionary.dart](../lib/services/local_dictionary.dart), [dictionary_service.dart](../lib/services/dictionary_service.dart), 생성 스크립트 [build_dictionary.py](../tool/build_dictionary.py) |
| 자동 입력 | 저장된 같은 단어를 우선 참고. 부족한 정보를 조회하고 한 품사의 뜻을 최대 3개 선택 | [word_draft_service.dart](../lib/services/word_draft_service.dart) |
| 예문 조회 | 한국어 번역이 연결된 문장을 우선 찾고, 부족하면 영어 문장으로 보충 | [example_source_service.dart](../lib/services/example_source_service.dart) |
| 편집 화면 진입 | 사전 조회가 끝나면 먼저 화면을 열고, 늦게 도착한 예문은 수정되지 않은 초안에만 반영 | [word_edit_screen.dart](../lib/screens/word_edit_screen.dart) |
| 메모리 캐시 | 사전 최대 50항목. 예문 최대 50항목·10분, 동일한 진행 중 예문 요청 공유 | 위 사전·예문 서비스 |
| 자세한 사전 보기 | 네이버 영한·Cambridge 영한·Oxford 영영의 외부 검색 페이지 열기 | [dictionary_links.dart](../lib/widgets/dictionary_links.dart) |

현재는 조회 결과를 재실행 후에도 유지하는 별도 사전 캐시가 없다. 사용자가 단어장에 저장한 내용은 저장소에 남아 다음 자동 입력에 활용된다. 기본 사전 데이터 내장도 아직 구현되지 않았다.

자동 입력은 사전 순서와 태그를 참고한 선택이며, 사용 빈도 통계에 따른 대표 뜻 순위는 아니다. 외부 사전 링크는 해당 사이트를 여는 기능으로, 그 사이트의 API를 사용하는 것은 아니다.

## 서비스별 적용 조건

### FreeDictionaryAPI.com — 현재 무료 사전

Wiktionary 기반으로 정의·품사·발음·예문과 선택적인 번역을 제공하며 CORS를 지원한다. 한국어 번역이 없는 항목도 있어 모든 단어를 영한사전처럼 채울 수는 없다. 데이터는 CC BY-SA 4.0이며, 원문 Wiktionary 링크와 FreeDictionaryAPI.com 출처 표시가 요구된다. 다운로드형 앱의 배포 페이지에도 출처 표시 안내가 있다. [공식 기능·한도·출처 안내](https://freedictionaryapi.com/)

현재 앱의 요청 예시는 다음과 같다.

```http
GET https://freedictionaryapi.com/api/v1/entries/en/happy?translations=true
```

### dictionaryapi.dev — 무료 영영 사전 대안

공개 문서는 영어 정의·품사·발음·예문을 반환하는 URL을 제공하고 무료 운영을 명시한다. 한국어 뜻을 보완하는 용도로 적합한지는 확인되지 않았다. 장기 저장을 도입한다면 응답 데이터의 출처·라이선스도 별도로 확인해야 한다. [공식 안내](https://dictionaryapi.dev/)

```http
GET https://api.dictionaryapi.dev/api/v2/entries/en/happy
```

### WordsAPI — 무료 호출량과 저장 조건을 함께 검토

영어 정의와 동의어·반의어 등 연관어 정보를 제공한다. 홈페이지에는 무료 Basic 요금제가 일 2,500회로 표시되어 있다. 결제·접근 관리는 RapidAPI에서 하므로 실제 가입 시 적용되는 한도와 초과 과금 조건은 해당 화면에서 확인해야 한다. [공식 기능·요금 안내](https://www.wordsapi.com/), [공식 연결 요금 페이지](https://rapidapi.com/dpventures/api/wordsapi/pricing)

홈페이지 약관은 API 데이터 캐시를 최대 24시간으로 제한한다. **조회한 뜻을 단어장에 장기간 저장하는 기능에는 별도 허용 범위를 확인해야 한다.** 데이터 세트 구매는 API 무료 요금제와 별도다. [공식 약관의 Caching 항목](https://www.wordsapi.com/)

### Collins — 무료 한도는 있으나 적용 범위 확인 필요

공식 가격표는 영영 및 이중언어 API 모두 월 5,000회까지 무료라고 안내한다. 사용할 사전을 지정해 키를 신청하는 방식이다. 웹사이트에 영한사전이 있다는 사실만으로 영한 API 이용 가능성을 확정할 수는 없다. [공식 API 안내](https://www.collinsdictionary.com/collins-api)

약관은 API 요청을 대체하는 오프라인·온라인 저장 및 캐시를 제한하고, 상업 제품에는 상업 라이선스를 요구한다. 따라서 무료 한도만 보고 현재 단어장 저장 흐름에 바로 적용하기는 어렵다. [공식 이용 조건](https://blog.collinsdictionary.com/terms-conditions-collins-api/)

### Cambridge — 영한 지원, 정식 이용은 계약형

API 대상 목록에 Cambridge English–Korean Dictionary가 명시되어 있다. [지원 사전 목록](https://dictionary-api.cambridge.org/api/)

평가용 키는 30일 동안 3,000회로 제한된다. 정식 개발·서비스 이용에는 별도 계약이 필요하며, 데이터와 사용 방식에 따라 비용을 협의한다. 평가 약관은 데이터 수정·저장도 제한하므로, 자동 입력 후 수정·저장하는 기능을 계약 범위에 포함할 수 있는지 확인해야 한다. [평가 이용 조건](https://dictionary-api.cambridge.org/api/terms-and-conditions), [라이선스 신청 안내](https://dictionary-api.cambridge.org/apply)

### Tatoeba — 무료 예문 데이터

현재 앱은 공개 API에서 영어 문장과 연결된 한국어 번역을 조회한다. 단어 정의·품사 자동 입력용 사전과는 역할이 다르다. [공식 API](https://api.tatoeba.org/), [현재 요청 구현](../lib/services/example_source_service.dart)

다운로드 페이지는 두 언어의 문장·번역 쌍을 내보내는 기능을 제공한다. 이를 미리 가공하면 내장된 예문은 외부 요청 없이 표시할 수 있다. 공개 문장 파일의 기본 라이선스는 CC BY 2.0 FR이며 일부 문장은 CC0다. 문장과 번역의 출처·라이선스를 보존해야 한다. [공식 다운로드 안내](https://tatoeba.org/ar/downloads)

### Kaikki — 기본 사전 내장용 데이터

Wiktionary 추출 데이터를 JSONL로 내려받을 수 있다. 실시간 사전 API를 교체하는 것과 달리, 필요한 단어를 추리고 앱이 검색할 수 있는 형식으로 가공하는 작업이 필요하다. 제공 사이트는 기존 후처리 데이터의 종료 예정 안내와 함께 원시 데이터 사용을 권장한다. [영어 데이터 안내](https://kaikki.org/dictionary/English/index.html), [원시 데이터 다운로드](https://kaikki.org/dictionary/rawdata.html)

영어판 Wiktionary 추출물은 영어 풀이 중심이다. 그 안의 `Korean` 목록은 한국어 표제어를 뜻하므로 영한사전과 혼동하지 않아야 한다. 한국어판 Wiktionary 추출물도 별도로 있으나, 영어 표제어의 수록 범위와 뜻의 품질은 아직 확인하지 않았다. 원문 출처와 적용 라이선스를 보존하는 방식으로 가공해야 한다. [판본·풀이 언어 안내](https://kaikki.org/)

## 언어판 Wiktionary 측정 (2026-10-06)

### 배경
현재 자동 뜻 입력은 **영어판** Wiktionary의 번역 표에 의존한다. 번역 표가 비어 있는 뜻이 많아, 예를 들어 `take`는 풀이 103개 중 한국어 번역이 10개뿐이고 기본 뜻("잡다, 쥐다")에는 번역이 없다. 반면 **한국어판** Wiktionary는 영어 표제어를 처음부터 한국어로 풀이한다(`take`: 잡다, 쥐다 / 점령하다 / 맡다 / 취하다 / 가져가다 …).

### 데이터
- [Kaikki 한국어판 영어 항목](https://kaikki.org/kowiktionary/%EC%98%81%EC%96%B4/index.html): JSONL 약 10.6MB, 17,829항목.
- 한글 풀이가 있는 항목만 남기고 번호·영문 괄호 설명을 정리하면 **15,202단어, 1.1MB(gzip 약 0.4MB)**. 앱 내장이 가능한 크기다.
- 라이선스는 현재 사용 중인 데이터와 같은 CC BY-SA. 원문 출처 표시를 유지해야 한다.
- 다른 언어판도 Kaikki에 있다(영어 표제어의 풀이 수, 사이트 표기 기준): 일본어·중국어 약 10만, 프랑스어 약 22만, 베트남어 약 19만, 태국어 약 50만, 독일어 약 8만, 스페인어 약 3.5만, 포르투갈어 약 2.5만, 인도네시아어 약 900.

### 한국어 뜻 수록률
대상: [wordfreq](https://github.com/rspeer/wordfreq) 영어 빈도 상위 5,000단어(알파벳 단어만). 현재 방식은 FreeDictionaryAPI.com 호출 한도 때문에 10개 중 1개(500단어) 표본으로 측정했다. "수록"은 한국어 뜻을 하나 이상 얻을 수 있다는 뜻이다.

| 방식 | 상위 1,000 | 1,001~3,000 | 3,001~5,000 | 전체(5,000) | 표본 500 |
| --- | --- | --- | --- | --- | --- |
| 현재 방식(영어판 번역 표) | — | — | — | — | 42% |
| 한국어판 Wiktionary | 84% | 65% | 53% | 64% | 63% |
| 한국어판 + 기본형 대체 조회(추정) | 97% | 92% | 83% | 89% | — |
| 한국어판 + 기본형 + 현재 방식 | — | — | — | — | 93% |

- 빈도 목록에는 `been`, `went`, `services` 같은 활용형이 많다. 학습자는 대개 기본형을 입력하지만, 활용형이 들어오면 기본형(`go`, `service`)으로 다시 찾는 규칙을 둘 때의 값을 "기본형 대체 조회"로 적었다. 간단한 접미사·불규칙 규칙으로 계산한 추정치다.
- 남은 미수록어는 주로 고유명사(york, boston), 약어(ms, info, ads), 신조어(app, stats)다.

### 품질 메모
- 기본 뜻이 앞에 오는 경우가 많다(take: 잡다, get: 얻다, run: 달리다). 다만 사용 빈도 순서가 보장되지는 않는다.
- 일부 풀이에 "(타동사)", "㉶" 같은 편집 표기가 섞여 있어 정리 규칙이 더 필요하다.
- 희귀어(ubiquitous, procrastinate 등)는 빠져 있어 현재 방식의 대체 조회가 계속 필요하다.

### 일본어·중국어 확장 (같은 날)
같은 방식으로 일본어판(英語 항목)과 중국어판(英語·英语 항목)을 가공했다. 중국어판은 번체가 많아 OpenCC로 간체 변환했다. 활용형 항목(took → take, went → go)은 뜻 대신 기본형 연결로 저장하고, 속어·고어 표시 뜻과 고유명사·약어는 뺐다.

| 언어 | 내장 단어 수 | 파일(압축) | 상위 5,000 내장 사전(+기본형) | 표본 200: 온라인만 | 표본 200: 내장+온라인 |
| --- | --- | --- | --- | --- | --- |
| 한국어 | 15,000 | 1.05MB (약 0.35MB) | 88% | 36% | 90% |
| 일본어 | 54,490 | 4.30MB (약 1.1MB) | 89% | 44% | 90% |
| 중국어 | 66,468 | 3.90MB (약 1.3MB) | 46% | 46% | 66% |

- 중국어판은 to, and, for, my 같은 기본 기능어 항목이 없어 수록률이 낮다. 온라인 사전(영어판 번역 표)과 합쳐 66%까지 오른다.
- 표본은 상위 5,000단어 중 25개마다 1개다. 온라인 수치는 번역이 하나라도 있는 비율이다.

### 권장 적용 순서
1. 언어별 사전 파일(단어 → 품사 → 뜻)을 앱에 넣거나 첫 사용 시 내려받는다.
2. 조회 순서: 해당 언어판 사전 → 기본형으로 다시 조회 → 현재 API(영어판 번역 표) → 영어 풀이.
3. 한국어로 효과를 확인한 뒤 일본어·중국어·프랑스어·베트남어·태국어 순으로 확장한다. 인도네시아어는 Wiktionary 수록이 적어 Open Multilingual Wordnet(Wordnet Bahasa) 등 별도 데이터가 필요하다.

## 속도 확인 기록

2026-09-13 개발 세션에서 현재 PC의 Chrome으로 확인한 간이 측정이다. 아래 수치는 이번 문서 작성 중 재측정한 결과가 아니다.

| 측정 | FreeDictionaryAPI.com | 비교 대상 |
| --- | --- | --- |
| `happy` 사전·예문 조회 | 847ms, HTTP 200 | Tatoeba는 약 16초까지 응답을 받지 못해 요청 중단 |
| `happy` 사전 비교 | 1,091ms, HTTP 200 | dictionaryapi.dev는 10초 제한까지 응답을 받지 못해 중단 |
| `benefit` 사전 비교 | 1,004ms, HTTP 200 | dictionaryapi.dev는 10초 제한까지 응답을 받지 못해 중단 |
| `run` 사전 비교 | 1,090ms, HTTP 200 | dictionaryapi.dev는 10초 제한까지 응답을 받지 못해 중단 |

사전 비교는 브라우저의 `cache: no-store` 옵션으로 각 단어를 1회 요청한 결과다. Tatoeba 비교는 별도 측정이며, 테스트 중단 시간은 앱에 설정된 타임아웃과 다르다. WordsAPI·Collins·Cambridge의 실제 API 속도는 측정하지 않았다.

이 결과에서는 Tatoeba 대기가 화면 진입을 지연시키는 원인으로 확인되었다. 현재 코드는 예문을 기다리지 않고 편집 화면을 열도록 개선되어 있다. 다만 사전 조회 자체는 최대 15초까지 기다릴 수 있다. [사전 타임아웃](../lib/services/dictionary_service.dart), [초안·예문 처리](../lib/services/word_draft_service.dart)

단일 환경의 적은 표본이므로 서비스 전체의 평균 속도나 안정성 순위로 해석할 수 없다. 유료 서비스가 더 빠르다는 결론도 아직 근거가 없다.

## 무료 운영을 위한 권장 구성

다음은 현재 구현과 위 자료를 바탕으로 한 제안이다.

1. 현재 무료 사전과 예문을 나중에 채우는 흐름을 유지한다.
2. Kaikki 등 공개 데이터에서 자주 쓰는 영어 단어를 추려 기본 사전을 만든다. 한국어 뜻의 수록률과 정확도를 먼저 확인한다.
3. 기본 사전에 없는 단어만 외부 API로 조회하고, 라이선스에 맞게 결과를 재사용한다.
4. 필요한 영어·한국어 예문 쌍도 선별해 내장한다. 예문이 없어도 뜻 확인과 저장은 계속 가능하게 한다.
5. 자세한 풀이를 확인하는 외부 사전 링크는 유지한다.

미리 넣은 항목은 조회 시 네트워크 대기가 사라지는 장점이 있다. 대신 데이터 선별·가공·업데이트와 앱 용량 관리가 필요하다. 무료 데이터 사용은 별도 서버를 운영할 때의 저장·전송 비용까지 없다는 뜻은 아니다.

한국어 뜻의 충분한 수록률이 가장 중요한 선택 기준이다. 현재 검토만으로 **무료·빠른 응답·충실한 영한 풀이를 모두 보장하는 서비스**를 확정하지는 않았다.
