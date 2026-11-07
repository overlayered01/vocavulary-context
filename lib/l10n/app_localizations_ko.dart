// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '예문 단어장';

  @override
  String get commonCancel => '취소';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonAdd => '추가';

  @override
  String get commonClose => '닫기';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonNext => '다음';

  @override
  String get commonEdit => '편집';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonLoading => '불러오는 중';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': '한국어',
      'ja': '일본어',
      'zh': '중국어',
      'es': '스페인어',
      'fr': '프랑스어',
      'de': '독일어',
      'pt': '포르투갈어',
      'vi': '베트남어',
      'th': '태국어',
      'id': '인도네시아어',
      'en': '영어',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': '월',
      'd2': '화',
      'd3': '수',
      'd4': '목',
      'd5': '금',
      'd6': '토',
      'd7': '일',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => '단어 추가';

  @override
  String get wordEditWord => '단어 편집';

  @override
  String get wordExamples => '예문';

  @override
  String wordExampleSource(String source) {
    return '출처: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': '명사',
      'verb': '동사',
      'adjective': '형용사',
      'adverb': '부사',
      'pronoun': '대명사',
      'preposition': '전치사',
      'conjunction': '접속사',
      'interjection': '감탄사',
      'article': '관사',
      'determiner': '한정사',
      'phrasalVerb': '구동사',
      'idiom': '관용구',
      'phrase': '구',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => '먼저 영어 단어를 입력해 주세요.';

  @override
  String wordEditNoExamplesFound(String term) {
    return '\'$term\'에 사용할 예문을 찾지 못했습니다.';
  }

  @override
  String get wordEditExamplesAlreadyAdded => '가져온 예문이 모두 이미 추가되어 있습니다.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '예문 $count개를 추가했습니다.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return '예문을 가져오지 못했습니다: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired => '단어와 뜻을 하나 이상 입력해 주세요.';

  @override
  String get wordEditSaveFailed => '저장하지 못했습니다. 다시 시도해 주세요.';

  @override
  String get wordEditSectionTerm => '단어 정보';

  @override
  String get wordEditSectionMeaning => '뜻과 발음';

  @override
  String get wordEditPhonetic => '발음기호';

  @override
  String get wordEditSearching => '검색 중';

  @override
  String get wordEditFetchExamples => '예문 가져오기';

  @override
  String get wordEditAddManually => '직접 추가';

  @override
  String get wordEditOptional => '선택';

  @override
  String wordEditExampleNumber(int index) {
    return '예문 $index';
  }

  @override
  String get wordEditDeleteExample => '예문 삭제';

  @override
  String get wordEditSentence => '영어 문장';

  @override
  String wordEditTranslationLabel(String language) {
    return '해석 ($language)';
  }

  @override
  String get wordEditTermLabel => '단어 *';

  @override
  String get wordEditTermHint => '저장된 단어를 선택하면 뜻과 예문을 자동으로 채웁니다.';

  @override
  String get wordEditPartOfSpeech => '품사';

  @override
  String get wordEditPartOfSpeechNone => '선택 안 함';

  @override
  String get wordEditManualExampleTitle => '예문 직접 추가';

  @override
  String get wordEditSentenceRequiredLabel => '영어 문장 *';

  @override
  String get wordEditSentenceRequired => '영어 문장을 입력해 주세요.';

  @override
  String wordEditPickerTitle(String term) {
    return '\'$term\' 예문';
  }

  @override
  String get wordEditPickerDescription =>
      '추가할 예문을 선택하세요. 번역이 없는 문장은 직접 입력할 수 있어요.';

  @override
  String wordEditNoTranslation(String language) {
    return '$language 번역 없음';
  }

  @override
  String get wordEditPickerAttribution => '예문 출처: Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return '선택한 예문 추가 ($count)';
  }

  @override
  String get wordCreateLoadFailed => '불러오지 못했습니다. 다시 시도해 주세요.';

  @override
  String get wordCreateSectionTitle => '단어 입력';

  @override
  String get wordCreateWordbook => '단어장';

  @override
  String get wordCreateNoWordbook => '단어장 없음';

  @override
  String get wordCreateReload => '다시 불러오기';

  @override
  String get wordCreateTermLabel => '단어';

  @override
  String get wordCreateLookingUp => '조회 중';

  @override
  String get wordCreateAutoInputSettings => '자동 입력 설정';

  @override
  String get wordCreateMeaningsOn => '뜻 켜짐';

  @override
  String get wordCreateMeaningsOff => '뜻 꺼짐';

  @override
  String get wordCreateExamplesOn => '예문 켜짐';

  @override
  String get wordCreateExamplesOff => '예문 꺼짐';

  @override
  String get wordCreateCollapse => '접기';

  @override
  String get wordCreateExpand => '펼치기';

  @override
  String get wordCreateAutoMeanings => '자동 뜻 입력';

  @override
  String get wordCreateAutoExamples => '자동 예문 입력';

  @override
  String get wordDetailDictionaryMeaningsAdded => '선택한 사전 뜻을 추가했어요.';

  @override
  String get wordDetailTitle => '단어 상세';

  @override
  String get wordDetailFavorite => '즐겨찾기';

  @override
  String get wordDetailUnfavorite => '즐겨찾기 해제';

  @override
  String get wordDetailAccentUs => '미국식';

  @override
  String get wordDetailAccentUk => '영국식';

  @override
  String get wordDetailMyMeanings => '내가 저장한 뜻';

  @override
  String get wordDetailListenExample => '예문 듣기';

  @override
  String get wordDetailGoogleTranslate => '구글 번역';

  @override
  String get meaningFieldsLabel => '뜻';

  @override
  String get meaningFieldsLabelRequired => '뜻 *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return '뜻 $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return '뜻 $index 삭제';
  }

  @override
  String get meaningFieldsAdd => '뜻 추가';

  @override
  String get meaningFieldsEmptyError => '뜻을 하나 이상 입력해 주세요.';

  @override
  String get meaningFieldsEditTitle => '뜻 수정';

  @override
  String get dictLookupAddFailed => '뜻을 추가하지 못했어요. 다시 시도해 주세요.';

  @override
  String get dictLookupButton => '사전 뜻 보기';

  @override
  String dictLookupTitle(String term) {
    return '$term · 사전 뜻';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return '$language 뜻이 없는 항목은 영어 풀이로 표시해요.';
  }

  @override
  String get dictLookupLoadFailed => '사전 뜻을 불러오지 못했어요.';

  @override
  String get dictLookupNoResults =>
      '사전에 등록된 뜻을 찾지 못했어요.\n철자를 확인하거나 다른 사전에서 찾아보세요.';

  @override
  String get dictLookupAlreadyAdded => '추가됨';

  @override
  String dictLookupAddSelected(int count) {
    return '선택한 뜻 추가 ($count)';
  }

  @override
  String get dictLookupLinkFailed => '사전 링크를 열지 못했어요.';

  @override
  String get dictLinksNaver => '네이버 영한';

  @override
  String get dictLinksOxford => 'Oxford 영영';

  @override
  String get dictLinksOpenFailed => '사전을 열지 못했습니다. 다시 시도해 주세요.';

  @override
  String get dictLinksTitle => '사전에서 더 보기';

  @override
  String wordbookError(String error) {
    return '오류: $error';
  }

  @override
  String get wordbookShareCode => '공유 코드';

  @override
  String wordbookDeleteTitle(String name) {
    return '\'$name\' 삭제';
  }

  @override
  String get wordbooksTitle => '내 단어장';

  @override
  String get wordbooksNew => '새 단어장';

  @override
  String get wordbooksEmpty => '단어장이 없습니다.\n+ 버튼으로 추가하세요.';

  @override
  String get wordbooksCreate => '만들기';

  @override
  String get wordbooksNameLabel => '단어장 이름';

  @override
  String get wordbooksTagsLabel => '태그';

  @override
  String get wordbooksTagsHint => '토익, 일상회화 (쉼표로 구분)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '단어 $count개',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => '단어장 메뉴';

  @override
  String get wordbooksMenuRename => '이름·태그 편집';

  @override
  String get wordbooksShareSettings => '공유·공개 설정';

  @override
  String get wordbooksMenuDelete => '단어장 삭제';

  @override
  String get wordbooksEditTitle => '단어장 편집';

  @override
  String get wordbooksShareLoginRequired => '공유·공개는 로그인 후 사용할 수 있어요.';

  @override
  String get wordbooksVisibilityPrivate => '비공개';

  @override
  String get wordbooksVisibilityShared => '코드 공유';

  @override
  String get wordbooksVisibilityPublic => '공개';

  @override
  String get wordbooksVisibilityPrivateDesc => '나만 볼 수 있어요.';

  @override
  String get wordbooksVisibilitySharedDesc => '공유 코드를 아는 사람이 이 단어장을 복제할 수 있어요.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      '탐색 탭의 공개 목록에 올라가고 누구나 복제할 수 있어요.';

  @override
  String get wordbooksCopyCode => '코드 복사';

  @override
  String get wordbooksCodeCopied => '공유 코드를 복사했어요.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '단어장에 든 단어 $count개도 함께 삭제됩니다.\n삭제한 단어장은 되돌릴 수 없어요.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty => '삭제한 단어장은 되돌릴 수 없어요.';

  @override
  String get wordbookDetailEmpty => '단어가 없습니다.\n단어 추가 버튼을 눌러보세요.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '\'$term\' 삭제됨';
  }

  @override
  String get wordbookDetailUndo => '실행취소';

  @override
  String get wordbookDetailEditWholeWord => '단어 전체 편집';

  @override
  String get wordbookDetailEditWord => '단어 편집';

  @override
  String get wordbookDetailFavorite => '즐겨찾기';

  @override
  String get wordbookDetailUnfavorite => '즐겨찾기 해제';

  @override
  String get wordbookDetailEditMeaning => '뜻 수정';

  @override
  String get wordbookDetailEditAll => '전체 편집';

  @override
  String get wordbookDetailStatusFresh => '미학습';

  @override
  String get wordbookDetailStatusLearning => '학습중';

  @override
  String get wordbookDetailStatusCompleted => '완료';

  @override
  String get wordbookDetailDeleteWordConfirm => '이 단어를 삭제할까요?';

  @override
  String get wordbookDetailReleaseToDelete => '놓으면 삭제';

  @override
  String get exploreTitle => '탐색';

  @override
  String get exploreCodeNotFound => '코드에 해당하는 공유 단어장을 찾을 수 없어요.';

  @override
  String get exploreImportFailed => '가져오지 못했어요. 네트워크 상태를 확인해 주세요.';

  @override
  String exploreCopyTitle(String title) {
    return '\'$title\' 복제';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '단어 $count개를 내 단어장으로 복제할까요?\n학습 상태는 처음부터 시작해요.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => '복제';

  @override
  String exploreImported(String title) {
    return '\'$title\' 단어장을 가져왔어요.';
  }

  @override
  String get exploreLoggedOutHeadline => '새로운 단어장을\n둘러보세요';

  @override
  String get exploreLoginRequired => '공유 단어장 탐색은 로그인 후 사용할 수 있어요.';

  @override
  String get exploreGoToLogin => '로그인하기';

  @override
  String get exploreSupabaseRequired => 'Supabase 연결 후 사용할 수 있습니다.';

  @override
  String get exploreImportByCode => '공유 코드로 가져오기';

  @override
  String get exploreCodeHint => '전달받은 코드를 붙여넣으세요';

  @override
  String get exploreImport => '가져오기';

  @override
  String get exploreCodeHelp => '단어장 메뉴의 공유·공개 설정에서 코드를 복사해 전달할 수 있어요.';

  @override
  String get explorePublicWordbooks => '공개 단어장';

  @override
  String get explorePublicLoadFailed => '공개 단어장을 불러오지 못했어요.\n아래로 당겨 새로고침해 보세요.';

  @override
  String get explorePublicEmpty => '아직 공개된 단어장이 없어요.';

  @override
  String get loginMigrateTitle => '로컬 단어장 가져오기';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 기기에서 만든 단어장 $count개를 클라우드로 복사할까요?\n이미 클라우드에 있는 단어장은 건너뜁니다.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => '나중에';

  @override
  String get loginImport => '가져오기';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '단어장 $count개를 가져왔어요.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => '모든 단어장이 이미 클라우드에 있어요.';

  @override
  String get loginErrorInvalidCredentials => '이메일 또는 비밀번호가 올바르지 않아요.';

  @override
  String get loginErrorUserExists => '이미 가입된 이메일이에요. 로그인해 주세요.';

  @override
  String get loginErrorWeakPassword => '비밀번호가 너무 짧아요. 6자 이상 입력해 주세요.';

  @override
  String get loginErrorEmailNotConfirmed => '이메일 인증이 필요해요. 받은 편지함을 확인해 주세요.';

  @override
  String get loginErrorRateLimit => '요청이 너무 잦아요. 잠시 후 다시 시도해 주세요.';

  @override
  String loginErrorGeneric(String message) {
    return '로그인에 실패했어요. ($message)';
  }

  @override
  String get loginErrorNetwork => '요청을 처리하지 못했어요. 네트워크 상태를 확인하고 다시 시도해 주세요.';

  @override
  String get loginTitle => '로그인';

  @override
  String get loginTagline => '예문으로 쉽게, 알람으로 꾸준히';

  @override
  String get loginEmail => '이메일';

  @override
  String get loginPassword => '비밀번호';

  @override
  String get loginSignUpWithEmail => '이메일로 회원가입';

  @override
  String get loginContinueWithGoogle => '구글로 계속하기';

  @override
  String get navHome => '홈';

  @override
  String get navWordbooks => '단어장';

  @override
  String get navSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsTranslationSection => '뜻 · 예문 번역';

  @override
  String get settingsTranslationHelp =>
      '자동은 기기 언어·국가에 맞춰 정해요. 새로 조회하는 단어 뜻과 예문에 제공되는 번역을 사용해요. 번역이 없는 뜻은 영어 풀이로 표시하고, 예문 해석은 비워둬요. 이미 저장한 내용은 자동으로 바뀌지 않아요.';

  @override
  String get settingsAppLanguageNote =>
      '앱 화면도 이 언어로 표시돼요. 화면 번역이 없는 언어는 영어로 보여요.';

  @override
  String get settingsReviewMixSection => '복습 섞기 비율';

  @override
  String get settingsReviewMixLabel => '이미 외운 단어 다시 섞기';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    return '복습 세트에 \'학습완료\' 단어를 이 비율만큼 섞어 출제해 장기 기억을 강화해요. (예: $total문제 중 $mixed문제)';
  }

  @override
  String get settingsReminderSection => '알람 · 복습';

  @override
  String get settingsReminderToggle => '복습 알림 받기';

  @override
  String get settingsReminderOff => '알림이 꺼져 있어요.';

  @override
  String get settingsReminderNoActive => '켜진 알람 구간이 없어요.';

  @override
  String settingsReminderSummary(int count) {
    return '매주 반복 · 일주일에 $count회 알림이에요. 학습 중인 단어를 복습할 차례 순으로 담아요.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return '기기의 예약 알림 제한($limit개)을 넘어 늦은 시각 일부는 빠져요.';
  }

  @override
  String get settingsTtsSection => '발음 · TTS';

  @override
  String get settingsTtsDefault => '기본 발음';

  @override
  String get settingsTtsDefaultHelp => '단어와 예문을 읽을 기본 억양을 선택하세요.';

  @override
  String get settingsTtsUs => '미국식';

  @override
  String get settingsTtsUk => '영국식';

  @override
  String get settingsTtsQuality => '음질';

  @override
  String get settingsTtsQualityValue => '기기 TTS(무료)';

  @override
  String get settingsTatoebaCredit => '외부 예문: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => '매일';

  @override
  String get reminderNoWeekdays => '요일 없음';

  @override
  String get reminderWeekdays => '평일';

  @override
  String get reminderWeekends => '주말';

  @override
  String reminderIntervalMinutes(int minutes) {
    return '$minutes분마다';
  }

  @override
  String reminderIntervalHours(int hours) {
    return '$hours시간마다';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분마다';
  }

  @override
  String get reminderAddSchedule => '알람 구간 추가';

  @override
  String get reminderEditSchedule => '알람 구간 편집';

  @override
  String get reminderStart => '시작';

  @override
  String get reminderEnd => '끝';

  @override
  String get reminderCrossesMidnight =>
      '끝 시각이 시작보다 이르면 자정을 넘겨 다음 날 끝 시각까지 보내요.';

  @override
  String get reminderWeekdaysTitle => '알림 받을 요일';

  @override
  String get reminderWeekdaysRequired => '요일을 하나 이상 선택해 주세요.';

  @override
  String get reminderInterval => '알림 간격';

  @override
  String get reminderWordsPerAlert => '한 번에';

  @override
  String get reminderDecreaseWords => '단어 수 줄이기';

  @override
  String get reminderIncreaseWords => '단어 수 늘리기';

  @override
  String reminderWordCount(int count) {
    return '$count개';
  }

  @override
  String reminderWordCountLabel(int count) {
    return '단어 $count개';
  }

  @override
  String reminderTimesPerDay(int count) {
    return '하루 $count회';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    return '$days $count회 · $times';
  }

  @override
  String get translationLanguageLabel => '번역 언어';

  @override
  String translationLanguageAuto(String language) {
    return '자동 · $language';
  }

  @override
  String get notificationChannelName => '단어 알림';

  @override
  String get notificationChannelDescription => '설정한 요일·시간대에 단어와 뜻을 알림으로 보여 줘요';

  @override
  String get notificationTitleDefault => '오늘의 단어';

  @override
  String notificationTitleWords(int count) {
    return '오늘의 단어 $count개';
  }

  @override
  String get notificationBodyDefault => '단어를 추가하면 여기에 단어와 뜻을 보여 드려요.';

  @override
  String homeError(String error) {
    return '오류: $error';
  }

  @override
  String get homeGreeting => '오늘도 외워볼까요?';

  @override
  String get homeTodayStudy => '오늘 학습';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '전체 $count개',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => '정답률';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '완료 $count개',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => '오늘의 단어';

  @override
  String get homeQuickStart => '빠른 시작';

  @override
  String get homeQuickGuessWord => '빈칸 채우기 · 직접 쓰기';

  @override
  String get homeQuickFillBlank => '빈칸 채우기 · 보기 고르기';

  @override
  String get homeQuickBrowseWordbooks => '단어장 둘러보기';

  @override
  String get homeCreateWordbookFirst => '먼저 단어장을 만들어 주세요.';

  @override
  String get homeEditWord => '단어 편집';

  @override
  String get homeListenWord => '단어 발음 듣기';

  @override
  String get homeSeeDetails => '자세히 보기';

  @override
  String get homeReviewAllDone => '오늘 복습을\n모두 마쳤어요!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 단어가\n기다리고 있어요',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\n완료';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return '신규/복습 $due · 섞기 $mixed';
  }

  @override
  String get homeStart => '시작하기';

  @override
  String get reviewNoExample => '(예문이 없습니다 — 뜻을 보고 단어를 입력하세요)';

  @override
  String get reviewTitle => '예문 복습';

  @override
  String get reviewEmpty => '오늘 꺼낼 카드 없음';

  @override
  String get reviewFillBlankTitle => '빈칸 채우기';

  @override
  String get reviewChoiceInstruction => '예문과 뜻을 보고 알맞은 단어를 고르세요';

  @override
  String get reviewInputInstruction => '예문과 뜻을 보고 단어를 입력하세요';

  @override
  String reviewOtherExample(int current, int total) {
    return '다른 예문  $current/$total';
  }

  @override
  String get reviewDontKnow => '모름';

  @override
  String get reviewInputHint => '단어 입력';

  @override
  String reviewHint(String hint) {
    return '힌트: $hint';
  }

  @override
  String get reviewCheckAnswer => '정답 확인';

  @override
  String get reviewCorrect => '정답입니다';

  @override
  String get reviewWrongAnswerIs => '아쉬워요. 정답은';

  @override
  String reviewSource(String source) {
    return '출처: $source';
  }

  @override
  String get reviewMixedNotice => '복습 섞기로 다시 나온 단어예요 (학습완료)';

  @override
  String get reviewSummaryTitle => '복습 완료';

  @override
  String get reviewSummaryDone => '복습을 완료했어요';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$total문제 중 $correct개 정답';
  }

  @override
  String get reviewGoHome => '홈으로';

  @override
  String get dictionaryRateLimited => '사전 조회가 잠시 제한됐어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get dictionaryConnectionFailed => '사전에 연결하지 못했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get dictionaryTimeout => '사전 응답이 늦어지고 있어요. 다시 시도해 주세요.';

  @override
  String get dictionaryLoadFailed =>
      '사전 뜻을 불러오지 못했어요. 인터넷 연결을 확인하고 다시 시도해 주세요.';

  @override
  String get draftDictionaryUnavailable =>
      '사전에 연결하지 못했어요. 뜻을 직접 입력하거나 다시 조회해 주세요.';

  @override
  String get draftMeaningNotFound => '뜻을 찾지 못했어요. 직접 입력하거나 사전에서 찾아보세요.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return '사전에 $language 뜻이 없어 영어 풀이로 채웠어요. 번역 언어는 설정에서 바꿀 수 있어요.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return '$language 뜻이 없는 항목은 영어 풀이로 채웠어요.';
  }

  @override
  String get draftExamplesRetry => '예문은 아래의 ‘예문 가져오기’로 다시 불러올 수 있어요.';

  @override
  String get speakListen => '발음 듣기';

  @override
  String get speakListenExample => '예문 듣기';

  @override
  String get adPreview => '광고 미리보기';

  @override
  String get addWordButton => '단어 추가';

  @override
  String get wordCreateExampleTranslations => '예문 해석 포함';

  @override
  String get wordCreateNoExampleTranslations => '해석 없음';

  @override
  String get homeRemainingCards => '남은 카드';

  @override
  String homeTodayCards(int count) {
    return '오늘 복습 $count장';
  }

  @override
  String get homeStartButton => '시작';

  @override
  String get homeNoCardsToday => '오늘 꺼낼 카드 없음';

  @override
  String reviewRemaining(int count) {
    return '남은 $count';
  }

  @override
  String get reviewKeep => '남기기';

  @override
  String get reviewDiscard => '버리기';

  @override
  String reviewDoneTitle(int count) {
    return '오늘 $count장 끝';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return '장 남음 · 전체 $count';
  }

  @override
  String get wordbookCardsLeftSuffix => '장 남음';

  @override
  String get wordbookDetailAllDiscarded => '남은 카드 없음';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' 버림';
  }

  @override
  String get wordbookDetailReleaseToDiscard => '놓으면 버림';

  @override
  String get wordbookAddWordShort => '단어';

  @override
  String get discardedTitle => '버린 카드';

  @override
  String get discardedEmpty => '버린 카드 없음';

  @override
  String get discardedRestore => '다시 넣기';

  @override
  String get wordAddMeaningSelect => '뜻 선택';

  @override
  String get wordAddManualInput => '뜻 직접 입력';

  @override
  String get wordAddMeaningLabel => '뜻';

  @override
  String wordAddExamplesOf(String pos) {
    return '$pos 예문';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count개 선택';
  }

  @override
  String get wordAddWriteExample => '예문 직접 쓰기';

  @override
  String get wordAddSave => '등록';

  @override
  String get wordAddAlreadyInDeck => '이미 덱에 있음';

  @override
  String get wordAddNoResults => '사전에 없음';

  @override
  String get wordAddLookupFailed => '사전 연결 실패';

  @override
  String get wordAddAutoInput => '자동 입력';

  @override
  String get wordAddAutoOff => '자동 입력 꺼짐';

  @override
  String get wordAddExampleTranslation => '예문 해석';

  @override
  String get wordAddNoExamples => '예문 후보가 없어요. 비워 두고 등록해도 돼요.';

  @override
  String get settingsTheme => '테마';

  @override
  String get themeSlate => '슬레이트';

  @override
  String get themeNavy => '네이비';

  @override
  String get themeBrown => '브라운';

  @override
  String get themePlum => '플럼';

  @override
  String get themeCharcoal => '차콜';

  @override
  String get themeCustom => '직접';

  @override
  String get themeCustomTitle => '테마 직접 지정';

  @override
  String get themeBase => '바탕';

  @override
  String get themePoint => '포인트';

  @override
  String get themeAutoText => '글자 색은 자동으로 맞춤';

  @override
  String get themeApply => '적용';

  @override
  String get themeReset => '초기화';

  @override
  String get settingsLanguageSection => '언어';

  @override
  String get settingsLanguageRow => '뜻 · 예문 · 앱 언어';

  @override
  String get settingsFollowDevice => '기기 설정 따름';

  @override
  String get settingsReviewSection => '복습';

  @override
  String get settingsSessionSize => '한 번에 복습할 카드 수';

  @override
  String get settingsMixLabel => '버린 카드 다시 섞기';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$total장 중 $mixed장';
  }

  @override
  String get settingsWordAddSection => '단어 추가';

  @override
  String get settingsNotificationsSection => '알림';

  @override
  String get settingsReminderMaster => '단어 알림';

  @override
  String get settingsAddSlot => '알림 구간';

  @override
  String settingsWeeklyCount(int count) {
    return '일주일 $count회';
  }

  @override
  String reminderCardCount(int count) {
    return '$count장';
  }

  @override
  String get settingsPronunciationSection => '발음';

  @override
  String get settingsAccent => '억양';

  @override
  String get settingsVoice => '목소리';

  @override
  String get settingsVoiceDefault => '기본';

  @override
  String get settingsSpeed => '속도';

  @override
  String get settingsSpeedSlow => '느리게';

  @override
  String get settingsSpeedNormal => '보통';

  @override
  String get settingsSpeedFast => '빠르게';

  @override
  String get settingsRecorded => '단어는 사람 녹음으로';

  @override
  String get settingsRecordedHelp => '녹음이 없으면 목소리로 읽음';

  @override
  String get settingsAbout => '정보 · 출처';

  @override
  String get settingsPrivacy => '개인정보처리방침';

  @override
  String get aboutDataSources => '데이터 출처';

  @override
  String get aboutUseMeanings => '뜻 · 사전 예문';

  @override
  String get aboutUseOnline => '온라인 사전';

  @override
  String get aboutUseExamples => '번역 예문';

  @override
  String get aboutUseRecordings => '단어 발음 녹음';

  @override
  String get aboutApp => '앱';

  @override
  String get aboutVersion => '버전';

  @override
  String get aboutLicenses => '오픈소스 라이선스';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '하루 $times회 · $cards장';
  }

  @override
  String settingsPackDownloading(String size) {
    return '예문 해석 받는 중 · $size';
  }

  @override
  String settingsPackReady(String size) {
    return '예문 해석 받음 · $size';
  }

  @override
  String get settingsPackFailed => '예문 해석을 받지 못했어요';

  @override
  String get settingsPackRetry => '다시 시도';

  @override
  String get settingsExampleDataSection => '예문 데이터';

  @override
  String get settingsExampleData => '예문 해석 받기';

  @override
  String get settingsPackNone => '받지 않음';

  @override
  String get settingsPackNotNeeded => '영어는 해석이 필요하지 않아요';

  @override
  String settingsPackVersion(int version, String size) {
    return '받음 · v$version · $size';
  }

  @override
  String get settingsPackUpdate => '업데이트 확인';

  @override
  String settingsPackUpToDate(int version) {
    return '최신 버전이에요 (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'v$version 버전으로 업데이트했어요';
  }

  @override
  String get examplePromptTitle => '예문 해석을 받을까요?';

  @override
  String examplePromptBody(String language, String size) {
    return '영어 예문의 $language 해석을 내려받아 기기에 둡니다$size. 설정의 예문 데이터에서 언제든 바꿀 수 있어요.';
  }

  @override
  String get examplePromptAccept => '받기';

  @override
  String get examplePromptDecline => '받지 않기';

  @override
  String get wordAddPosLabel => '품사';

  @override
  String get wordAddPosUnknown => '품사 모름';

  @override
  String get homeQuickGuessFromMeaning => '뜻 보고 단어 맞추기';

  @override
  String get wordFoundExample => '찾은 예문';

  @override
  String get wordAddFoundExample => '예문 넣기';

  @override
  String wordbookFoundExamples(int count) {
    return '예문 $count개 찾음';
  }

  @override
  String get wordAddScanExample => '사진에서 예문 가져오기';

  @override
  String get wordScanCamera => '카메라로 찍기';

  @override
  String get wordScanGallery => '앨범에서 고르기';

  @override
  String get wordScanFailed => '사진의 글자를 읽지 못했어요';

  @override
  String wordScanNoSentence(String term) {
    return '사진에서 \'$term\'이(가) 들어간 문장을 찾지 못했어요';
  }

  @override
  String get exampleSourcePhoto => '내 사진';

  @override
  String wordScanAdded(int count) {
    return '사진에서 문장 $count개를 가져왔어요';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return '신규 $fresh · 복습 $review';
  }

  @override
  String get settingsAnswerStyle => '문제 방식';

  @override
  String get settingsAnswerInput => '빈칸에 직접 쓰기';

  @override
  String get settingsAnswerChoice => '보기 4개 중 고르기';

  @override
  String get settingsAnswerHelp => '홈의 시작 버튼으로 복습할 때 이 방식으로 문제가 나와요.';

  @override
  String get sampleWelcomeMeaning => '환영합니다, 어서 오세요';

  @override
  String get sampleWelcomeExample1 => 'Vocab with Examples에 오신 것을 환영합니다!';

  @override
  String get sampleWelcomeExample2 => '모두 돌아온 것을 환영해요.';

  @override
  String get homeAddCardHint => '영어 단어를 쓰면 뜻과 예문을 찾아 카드로 만들어요';
}
