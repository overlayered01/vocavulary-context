import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'예문 단어장'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get commonRetry;

  /// No description provided for @commonNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get commonNext;

  /// No description provided for @commonEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get commonEdit;

  /// No description provided for @commonConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get commonConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In ko, this message translates to:
  /// **'불러오는 중'**
  String get commonLoading;

  /// Name of a language, by ISO 639-1 code, written in the UI language.
  ///
  /// In ko, this message translates to:
  /// **'{code, select, ko{한국어} ja{일본어} zh{중국어} es{스페인어} fr{프랑스어} de{독일어} pt{포르투갈어} vi{베트남어} th{태국어} id{인도네시아어} en{영어} other{{code}}}'**
  String languageName(String code);

  /// Short weekday name. day is 'd1' (Monday) to 'd7' (Sunday).
  ///
  /// In ko, this message translates to:
  /// **'{day, select, d1{월} d2{화} d3{수} d4{목} d5{금} d6{토} d7{일} other{}}'**
  String weekdayShort(String day);

  /// Title of the add-word screens.
  ///
  /// In ko, this message translates to:
  /// **'단어 추가'**
  String get wordAddWord;

  /// Title of the edit-word screen and tooltip of the edit-word action.
  ///
  /// In ko, this message translates to:
  /// **'단어 편집'**
  String get wordEditWord;

  /// Section label for example sentences.
  ///
  /// In ko, this message translates to:
  /// **'예문'**
  String get wordExamples;

  /// Attribution of an example sentence. source is e.g. 'Tatoeba · CC BY 2.0 FR'.
  ///
  /// In ko, this message translates to:
  /// **'출처: {source}'**
  String wordExampleSource(String source);

  /// Display name of a part of speech. pos is an ASCII key mapped from the stored Korean value; value is the stored value shown as-is for unknown parts.
  ///
  /// In ko, this message translates to:
  /// **'{pos, select, noun{명사} verb{동사} adjective{형용사} adverb{부사} pronoun{대명사} preposition{전치사} conjunction{접속사} interjection{감탄사} article{관사} determiner{한정사} phrasalVerb{구동사} idiom{숙어} other{{value}}}'**
  String wordPartOfSpeech(String pos, String value);

  /// No description provided for @wordEditTermRequired.
  ///
  /// In ko, this message translates to:
  /// **'먼저 영어 단어를 입력해 주세요.'**
  String get wordEditTermRequired;

  /// No description provided for @wordEditNoExamplesFound.
  ///
  /// In ko, this message translates to:
  /// **'\'{term}\'에 사용할 예문을 찾지 못했습니다.'**
  String wordEditNoExamplesFound(String term);

  /// No description provided for @wordEditExamplesAlreadyAdded.
  ///
  /// In ko, this message translates to:
  /// **'가져온 예문이 모두 이미 추가되어 있습니다.'**
  String get wordEditExamplesAlreadyAdded;

  /// No description provided for @wordEditExamplesAdded.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{예문 {count}개를 추가했습니다.}}'**
  String wordEditExamplesAdded(int count);

  /// No description provided for @wordEditExamplesFetchFailed.
  ///
  /// In ko, this message translates to:
  /// **'예문을 가져오지 못했습니다: {error}'**
  String wordEditExamplesFetchFailed(String error);

  /// No description provided for @wordEditTermAndMeaningRequired.
  ///
  /// In ko, this message translates to:
  /// **'단어와 뜻을 하나 이상 입력해 주세요.'**
  String get wordEditTermAndMeaningRequired;

  /// No description provided for @wordEditSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장하지 못했습니다. 다시 시도해 주세요.'**
  String get wordEditSaveFailed;

  /// No description provided for @wordEditSectionTerm.
  ///
  /// In ko, this message translates to:
  /// **'단어 정보'**
  String get wordEditSectionTerm;

  /// No description provided for @wordEditSectionMeaning.
  ///
  /// In ko, this message translates to:
  /// **'뜻과 발음'**
  String get wordEditSectionMeaning;

  /// No description provided for @wordEditPhonetic.
  ///
  /// In ko, this message translates to:
  /// **'발음기호'**
  String get wordEditPhonetic;

  /// No description provided for @wordEditSearching.
  ///
  /// In ko, this message translates to:
  /// **'검색 중'**
  String get wordEditSearching;

  /// No description provided for @wordEditFetchExamples.
  ///
  /// In ko, this message translates to:
  /// **'예문 가져오기'**
  String get wordEditFetchExamples;

  /// No description provided for @wordEditAddManually.
  ///
  /// In ko, this message translates to:
  /// **'직접 추가'**
  String get wordEditAddManually;

  /// Marks a form section as optional (not 'select').
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get wordEditOptional;

  /// No description provided for @wordEditExampleNumber.
  ///
  /// In ko, this message translates to:
  /// **'예문 {index}'**
  String wordEditExampleNumber(int index);

  /// No description provided for @wordEditDeleteExample.
  ///
  /// In ko, this message translates to:
  /// **'예문 삭제'**
  String get wordEditDeleteExample;

  /// No description provided for @wordEditSentence.
  ///
  /// In ko, this message translates to:
  /// **'영어 문장'**
  String get wordEditSentence;

  /// Label of the translation field. language is a localized language name.
  ///
  /// In ko, this message translates to:
  /// **'해석 ({language})'**
  String wordEditTranslationLabel(String language);

  /// No description provided for @wordEditTermLabel.
  ///
  /// In ko, this message translates to:
  /// **'단어 *'**
  String get wordEditTermLabel;

  /// No description provided for @wordEditTermHint.
  ///
  /// In ko, this message translates to:
  /// **'저장된 단어를 선택하면 뜻과 예문을 자동으로 채웁니다.'**
  String get wordEditTermHint;

  /// No description provided for @wordEditPartOfSpeech.
  ///
  /// In ko, this message translates to:
  /// **'품사'**
  String get wordEditPartOfSpeech;

  /// No description provided for @wordEditPartOfSpeechNone.
  ///
  /// In ko, this message translates to:
  /// **'선택 안 함'**
  String get wordEditPartOfSpeechNone;

  /// No description provided for @wordEditManualExampleTitle.
  ///
  /// In ko, this message translates to:
  /// **'예문 직접 추가'**
  String get wordEditManualExampleTitle;

  /// No description provided for @wordEditSentenceRequiredLabel.
  ///
  /// In ko, this message translates to:
  /// **'영어 문장 *'**
  String get wordEditSentenceRequiredLabel;

  /// No description provided for @wordEditSentenceRequired.
  ///
  /// In ko, this message translates to:
  /// **'영어 문장을 입력해 주세요.'**
  String get wordEditSentenceRequired;

  /// No description provided for @wordEditPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'\'{term}\' 예문'**
  String wordEditPickerTitle(String term);

  /// No description provided for @wordEditPickerDescription.
  ///
  /// In ko, this message translates to:
  /// **'추가할 예문을 선택하세요. 번역이 없는 문장은 직접 입력할 수 있어요.'**
  String get wordEditPickerDescription;

  /// No description provided for @wordEditNoTranslation.
  ///
  /// In ko, this message translates to:
  /// **'{language} 번역 없음'**
  String wordEditNoTranslation(String language);

  /// No description provided for @wordEditPickerAttribution.
  ///
  /// In ko, this message translates to:
  /// **'예문 출처: Tatoeba · CC BY 2.0 FR'**
  String get wordEditPickerAttribution;

  /// No description provided for @wordEditAddSelectedExamples.
  ///
  /// In ko, this message translates to:
  /// **'선택한 예문 추가 ({count})'**
  String wordEditAddSelectedExamples(int count);

  /// No description provided for @wordCreateLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'불러오지 못했습니다. 다시 시도해 주세요.'**
  String get wordCreateLoadFailed;

  /// No description provided for @wordCreateSectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'단어 입력'**
  String get wordCreateSectionTitle;

  /// No description provided for @wordCreateWordbook.
  ///
  /// In ko, this message translates to:
  /// **'단어장'**
  String get wordCreateWordbook;

  /// No description provided for @wordCreateNoWordbook.
  ///
  /// In ko, this message translates to:
  /// **'단어장 없음'**
  String get wordCreateNoWordbook;

  /// No description provided for @wordCreateReload.
  ///
  /// In ko, this message translates to:
  /// **'다시 불러오기'**
  String get wordCreateReload;

  /// No description provided for @wordCreateTermLabel.
  ///
  /// In ko, this message translates to:
  /// **'단어'**
  String get wordCreateTermLabel;

  /// No description provided for @wordCreateLookingUp.
  ///
  /// In ko, this message translates to:
  /// **'조회 중'**
  String get wordCreateLookingUp;

  /// No description provided for @wordCreateAutoInputSettings.
  ///
  /// In ko, this message translates to:
  /// **'자동 입력 설정'**
  String get wordCreateAutoInputSettings;

  /// No description provided for @wordCreateMeaningsOn.
  ///
  /// In ko, this message translates to:
  /// **'뜻 켜짐'**
  String get wordCreateMeaningsOn;

  /// No description provided for @wordCreateMeaningsOff.
  ///
  /// In ko, this message translates to:
  /// **'뜻 꺼짐'**
  String get wordCreateMeaningsOff;

  /// No description provided for @wordCreateExamplesOn.
  ///
  /// In ko, this message translates to:
  /// **'예문 켜짐'**
  String get wordCreateExamplesOn;

  /// No description provided for @wordCreateExamplesOff.
  ///
  /// In ko, this message translates to:
  /// **'예문 꺼짐'**
  String get wordCreateExamplesOff;

  /// No description provided for @wordCreateCollapse.
  ///
  /// In ko, this message translates to:
  /// **'접기'**
  String get wordCreateCollapse;

  /// No description provided for @wordCreateExpand.
  ///
  /// In ko, this message translates to:
  /// **'펼치기'**
  String get wordCreateExpand;

  /// No description provided for @wordCreateAutoMeanings.
  ///
  /// In ko, this message translates to:
  /// **'자동 뜻 입력'**
  String get wordCreateAutoMeanings;

  /// No description provided for @wordCreateAutoExamples.
  ///
  /// In ko, this message translates to:
  /// **'자동 예문 입력'**
  String get wordCreateAutoExamples;

  /// No description provided for @wordDetailDictionaryMeaningsAdded.
  ///
  /// In ko, this message translates to:
  /// **'선택한 사전 뜻을 추가했어요.'**
  String get wordDetailDictionaryMeaningsAdded;

  /// No description provided for @wordDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'단어 상세'**
  String get wordDetailTitle;

  /// No description provided for @wordDetailFavorite.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get wordDetailFavorite;

  /// No description provided for @wordDetailUnfavorite.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 해제'**
  String get wordDetailUnfavorite;

  /// No description provided for @wordDetailAccentUs.
  ///
  /// In ko, this message translates to:
  /// **'미국식'**
  String get wordDetailAccentUs;

  /// No description provided for @wordDetailAccentUk.
  ///
  /// In ko, this message translates to:
  /// **'영국식'**
  String get wordDetailAccentUk;

  /// No description provided for @wordDetailMyMeanings.
  ///
  /// In ko, this message translates to:
  /// **'내가 저장한 뜻'**
  String get wordDetailMyMeanings;

  /// No description provided for @wordDetailListenExample.
  ///
  /// In ko, this message translates to:
  /// **'예문 듣기'**
  String get wordDetailListenExample;

  /// No description provided for @wordDetailGoogleTranslate.
  ///
  /// In ko, this message translates to:
  /// **'구글 번역'**
  String get wordDetailGoogleTranslate;

  /// No description provided for @meaningFieldsLabel.
  ///
  /// In ko, this message translates to:
  /// **'뜻'**
  String get meaningFieldsLabel;

  /// No description provided for @meaningFieldsLabelRequired.
  ///
  /// In ko, this message translates to:
  /// **'뜻 *'**
  String get meaningFieldsLabelRequired;

  /// No description provided for @meaningFieldsLabelNumbered.
  ///
  /// In ko, this message translates to:
  /// **'뜻 {index}'**
  String meaningFieldsLabelNumbered(int index);

  /// No description provided for @meaningFieldsRemove.
  ///
  /// In ko, this message translates to:
  /// **'뜻 {index} 삭제'**
  String meaningFieldsRemove(int index);

  /// No description provided for @meaningFieldsAdd.
  ///
  /// In ko, this message translates to:
  /// **'뜻 추가'**
  String get meaningFieldsAdd;

  /// No description provided for @meaningFieldsEmptyError.
  ///
  /// In ko, this message translates to:
  /// **'뜻을 하나 이상 입력해 주세요.'**
  String get meaningFieldsEmptyError;

  /// No description provided for @meaningFieldsEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'뜻 수정'**
  String get meaningFieldsEditTitle;

  /// No description provided for @dictLookupAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'뜻을 추가하지 못했어요. 다시 시도해 주세요.'**
  String get dictLookupAddFailed;

  /// No description provided for @dictLookupButton.
  ///
  /// In ko, this message translates to:
  /// **'사전 뜻 보기'**
  String get dictLookupButton;

  /// No description provided for @dictLookupTitle.
  ///
  /// In ko, this message translates to:
  /// **'{term} · 사전 뜻'**
  String dictLookupTitle(String term);

  /// No description provided for @dictLookupFallbackNotice.
  ///
  /// In ko, this message translates to:
  /// **'{language} 뜻이 없는 항목은 영어 풀이로 표시해요.'**
  String dictLookupFallbackNotice(String language);

  /// No description provided for @dictLookupLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'사전 뜻을 불러오지 못했어요.'**
  String get dictLookupLoadFailed;

  /// No description provided for @dictLookupNoResults.
  ///
  /// In ko, this message translates to:
  /// **'사전에 등록된 뜻을 찾지 못했어요.\n철자를 확인하거나 다른 사전에서 찾아보세요.'**
  String get dictLookupNoResults;

  /// No description provided for @dictLookupAlreadyAdded.
  ///
  /// In ko, this message translates to:
  /// **'추가됨'**
  String get dictLookupAlreadyAdded;

  /// No description provided for @dictLookupAddSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택한 뜻 추가 ({count})'**
  String dictLookupAddSelected(int count);

  /// No description provided for @dictLookupLinkFailed.
  ///
  /// In ko, this message translates to:
  /// **'사전 링크를 열지 못했어요.'**
  String get dictLookupLinkFailed;

  /// No description provided for @dictLinksNaver.
  ///
  /// In ko, this message translates to:
  /// **'네이버 영한'**
  String get dictLinksNaver;

  /// No description provided for @dictLinksOxford.
  ///
  /// In ko, this message translates to:
  /// **'Oxford 영영'**
  String get dictLinksOxford;

  /// No description provided for @dictLinksOpenFailed.
  ///
  /// In ko, this message translates to:
  /// **'사전을 열지 못했습니다. 다시 시도해 주세요.'**
  String get dictLinksOpenFailed;

  /// No description provided for @dictLinksTitle.
  ///
  /// In ko, this message translates to:
  /// **'사전에서 더 보기'**
  String get dictLinksTitle;

  /// Generic error text shown when loading wordbooks or words fails
  ///
  /// In ko, this message translates to:
  /// **'오류: {error}'**
  String wordbookError(String error);

  /// Label for a wordbook share code
  ///
  /// In ko, this message translates to:
  /// **'공유 코드'**
  String get wordbookShareCode;

  /// Delete confirmation dialog title for a wordbook or word
  ///
  /// In ko, this message translates to:
  /// **'\'{name}\' 삭제'**
  String wordbookDeleteTitle(String name);

  /// No description provided for @wordbooksTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 단어장'**
  String get wordbooksTitle;

  /// No description provided for @wordbooksNew.
  ///
  /// In ko, this message translates to:
  /// **'새 단어장'**
  String get wordbooksNew;

  /// No description provided for @wordbooksEmpty.
  ///
  /// In ko, this message translates to:
  /// **'단어장이 없습니다.\n+ 버튼으로 추가하세요.'**
  String get wordbooksEmpty;

  /// No description provided for @wordbooksCreate.
  ///
  /// In ko, this message translates to:
  /// **'만들기'**
  String get wordbooksCreate;

  /// No description provided for @wordbooksNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'단어장 이름'**
  String get wordbooksNameLabel;

  /// No description provided for @wordbooksTagsLabel.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get wordbooksTagsLabel;

  /// No description provided for @wordbooksTagsHint.
  ///
  /// In ko, this message translates to:
  /// **'토익, 일상회화 (쉼표로 구분)'**
  String get wordbooksTagsHint;

  /// No description provided for @wordbooksWordCount.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{단어 {count}개}}'**
  String wordbooksWordCount(int count);

  /// No description provided for @wordbooksMenu.
  ///
  /// In ko, this message translates to:
  /// **'단어장 메뉴'**
  String get wordbooksMenu;

  /// No description provided for @wordbooksMenuRename.
  ///
  /// In ko, this message translates to:
  /// **'이름·태그 편집'**
  String get wordbooksMenuRename;

  /// No description provided for @wordbooksShareSettings.
  ///
  /// In ko, this message translates to:
  /// **'공유·공개 설정'**
  String get wordbooksShareSettings;

  /// No description provided for @wordbooksMenuDelete.
  ///
  /// In ko, this message translates to:
  /// **'단어장 삭제'**
  String get wordbooksMenuDelete;

  /// No description provided for @wordbooksEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'단어장 편집'**
  String get wordbooksEditTitle;

  /// No description provided for @wordbooksShareLoginRequired.
  ///
  /// In ko, this message translates to:
  /// **'공유·공개는 로그인 후 사용할 수 있어요.'**
  String get wordbooksShareLoginRequired;

  /// No description provided for @wordbooksVisibilityPrivate.
  ///
  /// In ko, this message translates to:
  /// **'비공개'**
  String get wordbooksVisibilityPrivate;

  /// No description provided for @wordbooksVisibilityShared.
  ///
  /// In ko, this message translates to:
  /// **'코드 공유'**
  String get wordbooksVisibilityShared;

  /// No description provided for @wordbooksVisibilityPublic.
  ///
  /// In ko, this message translates to:
  /// **'공개'**
  String get wordbooksVisibilityPublic;

  /// No description provided for @wordbooksVisibilityPrivateDesc.
  ///
  /// In ko, this message translates to:
  /// **'나만 볼 수 있어요.'**
  String get wordbooksVisibilityPrivateDesc;

  /// No description provided for @wordbooksVisibilitySharedDesc.
  ///
  /// In ko, this message translates to:
  /// **'공유 코드를 아는 사람이 이 단어장을 복제할 수 있어요.'**
  String get wordbooksVisibilitySharedDesc;

  /// No description provided for @wordbooksVisibilityPublicDesc.
  ///
  /// In ko, this message translates to:
  /// **'탐색 탭의 공개 목록에 올라가고 누구나 복제할 수 있어요.'**
  String get wordbooksVisibilityPublicDesc;

  /// No description provided for @wordbooksCopyCode.
  ///
  /// In ko, this message translates to:
  /// **'코드 복사'**
  String get wordbooksCopyCode;

  /// No description provided for @wordbooksCodeCopied.
  ///
  /// In ko, this message translates to:
  /// **'공유 코드를 복사했어요.'**
  String get wordbooksCodeCopied;

  /// No description provided for @wordbooksDeleteWithWords.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{단어장에 든 단어 {count}개도 함께 삭제됩니다.\n삭제한 단어장은 되돌릴 수 없어요.}}'**
  String wordbooksDeleteWithWords(int count);

  /// No description provided for @wordbooksDeleteEmpty.
  ///
  /// In ko, this message translates to:
  /// **'삭제한 단어장은 되돌릴 수 없어요.'**
  String get wordbooksDeleteEmpty;

  /// No description provided for @wordbookDetailEmpty.
  ///
  /// In ko, this message translates to:
  /// **'단어가 없습니다.\n단어 추가 버튼을 눌러보세요.'**
  String get wordbookDetailEmpty;

  /// No description provided for @wordbookDetailWordDeleted.
  ///
  /// In ko, this message translates to:
  /// **'\'{term}\' 삭제됨'**
  String wordbookDetailWordDeleted(String term);

  /// No description provided for @wordbookDetailUndo.
  ///
  /// In ko, this message translates to:
  /// **'실행취소'**
  String get wordbookDetailUndo;

  /// No description provided for @wordbookDetailEditWholeWord.
  ///
  /// In ko, this message translates to:
  /// **'단어 전체 편집'**
  String get wordbookDetailEditWholeWord;

  /// No description provided for @wordbookDetailEditWord.
  ///
  /// In ko, this message translates to:
  /// **'단어 편집'**
  String get wordbookDetailEditWord;

  /// No description provided for @wordbookDetailFavorite.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get wordbookDetailFavorite;

  /// No description provided for @wordbookDetailUnfavorite.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 해제'**
  String get wordbookDetailUnfavorite;

  /// No description provided for @wordbookDetailEditMeaning.
  ///
  /// In ko, this message translates to:
  /// **'뜻 수정'**
  String get wordbookDetailEditMeaning;

  /// No description provided for @wordbookDetailEditAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 편집'**
  String get wordbookDetailEditAll;

  /// No description provided for @wordbookDetailStatusFresh.
  ///
  /// In ko, this message translates to:
  /// **'미학습'**
  String get wordbookDetailStatusFresh;

  /// No description provided for @wordbookDetailStatusLearning.
  ///
  /// In ko, this message translates to:
  /// **'학습중'**
  String get wordbookDetailStatusLearning;

  /// No description provided for @wordbookDetailStatusCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get wordbookDetailStatusCompleted;

  /// No description provided for @wordbookDetailDeleteWordConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 단어를 삭제할까요?'**
  String get wordbookDetailDeleteWordConfirm;

  /// No description provided for @wordbookDetailReleaseToDelete.
  ///
  /// In ko, this message translates to:
  /// **'놓으면 삭제'**
  String get wordbookDetailReleaseToDelete;

  /// No description provided for @exploreTitle.
  ///
  /// In ko, this message translates to:
  /// **'탐색'**
  String get exploreTitle;

  /// No description provided for @exploreCodeNotFound.
  ///
  /// In ko, this message translates to:
  /// **'코드에 해당하는 공유 단어장을 찾을 수 없어요.'**
  String get exploreCodeNotFound;

  /// No description provided for @exploreImportFailed.
  ///
  /// In ko, this message translates to:
  /// **'가져오지 못했어요. 네트워크 상태를 확인해 주세요.'**
  String get exploreImportFailed;

  /// No description provided for @exploreCopyTitle.
  ///
  /// In ko, this message translates to:
  /// **'\'{title}\' 복제'**
  String exploreCopyTitle(String title);

  /// No description provided for @exploreCopyConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{단어 {count}개를 내 단어장으로 복제할까요?\n학습 상태는 처음부터 시작해요.}}'**
  String exploreCopyConfirm(int count);

  /// No description provided for @exploreCopy.
  ///
  /// In ko, this message translates to:
  /// **'복제'**
  String get exploreCopy;

  /// No description provided for @exploreImported.
  ///
  /// In ko, this message translates to:
  /// **'\'{title}\' 단어장을 가져왔어요.'**
  String exploreImported(String title);

  /// No description provided for @exploreLoggedOutHeadline.
  ///
  /// In ko, this message translates to:
  /// **'새로운 단어장을\n둘러보세요'**
  String get exploreLoggedOutHeadline;

  /// No description provided for @exploreLoginRequired.
  ///
  /// In ko, this message translates to:
  /// **'공유 단어장 탐색은 로그인 후 사용할 수 있어요.'**
  String get exploreLoginRequired;

  /// No description provided for @exploreGoToLogin.
  ///
  /// In ko, this message translates to:
  /// **'로그인하기'**
  String get exploreGoToLogin;

  /// No description provided for @exploreSupabaseRequired.
  ///
  /// In ko, this message translates to:
  /// **'Supabase 연결 후 사용할 수 있습니다.'**
  String get exploreSupabaseRequired;

  /// No description provided for @exploreImportByCode.
  ///
  /// In ko, this message translates to:
  /// **'공유 코드로 가져오기'**
  String get exploreImportByCode;

  /// No description provided for @exploreCodeHint.
  ///
  /// In ko, this message translates to:
  /// **'전달받은 코드를 붙여넣으세요'**
  String get exploreCodeHint;

  /// No description provided for @exploreImport.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get exploreImport;

  /// No description provided for @exploreCodeHelp.
  ///
  /// In ko, this message translates to:
  /// **'단어장 메뉴의 공유·공개 설정에서 코드를 복사해 전달할 수 있어요.'**
  String get exploreCodeHelp;

  /// No description provided for @explorePublicWordbooks.
  ///
  /// In ko, this message translates to:
  /// **'공개 단어장'**
  String get explorePublicWordbooks;

  /// No description provided for @explorePublicLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'공개 단어장을 불러오지 못했어요.\n아래로 당겨 새로고침해 보세요.'**
  String get explorePublicLoadFailed;

  /// No description provided for @explorePublicEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 공개된 단어장이 없어요.'**
  String get explorePublicEmpty;

  /// No description provided for @loginMigrateTitle.
  ///
  /// In ko, this message translates to:
  /// **'로컬 단어장 가져오기'**
  String get loginMigrateTitle;

  /// No description provided for @loginMigrateConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{이 기기에서 만든 단어장 {count}개를 클라우드로 복사할까요?\n이미 클라우드에 있는 단어장은 건너뜁니다.}}'**
  String loginMigrateConfirm(int count);

  /// No description provided for @loginLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get loginLater;

  /// No description provided for @loginImport.
  ///
  /// In ko, this message translates to:
  /// **'가져오기'**
  String get loginImport;

  /// No description provided for @loginMigrated.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{단어장 {count}개를 가져왔어요.}}'**
  String loginMigrated(int count);

  /// No description provided for @loginAlreadyInCloud.
  ///
  /// In ko, this message translates to:
  /// **'모든 단어장이 이미 클라우드에 있어요.'**
  String get loginAlreadyInCloud;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호가 올바르지 않아요.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorUserExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 가입된 이메일이에요. 로그인해 주세요.'**
  String get loginErrorUserExists;

  /// No description provided for @loginErrorWeakPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 너무 짧아요. 6자 이상 입력해 주세요.'**
  String get loginErrorWeakPassword;

  /// No description provided for @loginErrorEmailNotConfirmed.
  ///
  /// In ko, this message translates to:
  /// **'이메일 인증이 필요해요. 받은 편지함을 확인해 주세요.'**
  String get loginErrorEmailNotConfirmed;

  /// No description provided for @loginErrorRateLimit.
  ///
  /// In ko, this message translates to:
  /// **'요청이 너무 잦아요. 잠시 후 다시 시도해 주세요.'**
  String get loginErrorRateLimit;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했어요. ({message})'**
  String loginErrorGeneric(String message);

  /// No description provided for @loginErrorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'요청을 처리하지 못했어요. 네트워크 상태를 확인하고 다시 시도해 주세요.'**
  String get loginErrorNetwork;

  /// No description provided for @loginTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get loginTitle;

  /// No description provided for @loginTagline.
  ///
  /// In ko, this message translates to:
  /// **'예문으로 쉽게, 알람으로 꾸준히'**
  String get loginTagline;

  /// No description provided for @loginEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get loginPassword;

  /// No description provided for @loginSignUpWithEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일로 회원가입'**
  String get loginSignUpWithEmail;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'구글로 계속하기'**
  String get loginContinueWithGoogle;

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navWordbooks.
  ///
  /// In ko, this message translates to:
  /// **'단어장'**
  String get navWordbooks;

  /// No description provided for @navSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsTranslationSection.
  ///
  /// In ko, this message translates to:
  /// **'뜻 · 예문 번역'**
  String get settingsTranslationSection;

  /// No description provided for @settingsTranslationHelp.
  ///
  /// In ko, this message translates to:
  /// **'자동은 기기 언어·국가에 맞춰 정해요. 새로 조회하는 단어 뜻과 예문에 제공되는 번역을 사용해요. 번역이 없는 뜻은 영어 풀이로 표시하고, 예문 해석은 비워둬요. 이미 저장한 내용은 자동으로 바뀌지 않아요.'**
  String get settingsTranslationHelp;

  /// No description provided for @settingsAppLanguageNote.
  ///
  /// In ko, this message translates to:
  /// **'앱 화면도 이 언어로 표시돼요. 화면 번역이 없는 언어는 영어로 보여요.'**
  String get settingsAppLanguageNote;

  /// No description provided for @settingsReviewMixSection.
  ///
  /// In ko, this message translates to:
  /// **'복습 섞기 비율'**
  String get settingsReviewMixSection;

  /// No description provided for @settingsReviewMixLabel.
  ///
  /// In ko, this message translates to:
  /// **'이미 외운 단어 다시 섞기'**
  String get settingsReviewMixLabel;

  /// Explains the review mix ratio with an example: mixed completed words out of total questions.
  ///
  /// In ko, this message translates to:
  /// **'복습 세트에 \'학습완료\' 단어를 이 비율만큼 섞어 출제해 장기 기억을 강화해요. (예: {total}문제 중 {mixed}문제)'**
  String settingsReviewMixHelp(int total, int mixed);

  /// No description provided for @settingsReminderSection.
  ///
  /// In ko, this message translates to:
  /// **'알람 · 복습'**
  String get settingsReminderSection;

  /// No description provided for @settingsReminderToggle.
  ///
  /// In ko, this message translates to:
  /// **'복습 알림 받기'**
  String get settingsReminderToggle;

  /// No description provided for @settingsReminderOff.
  ///
  /// In ko, this message translates to:
  /// **'알림이 꺼져 있어요.'**
  String get settingsReminderOff;

  /// No description provided for @settingsReminderNoActive.
  ///
  /// In ko, this message translates to:
  /// **'켜진 알람 구간이 없어요.'**
  String get settingsReminderNoActive;

  /// Summary under the reminder list. count is the number of notifications per week.
  ///
  /// In ko, this message translates to:
  /// **'매주 반복 · 일주일에 {count}회 알림이에요. 학습 중인 단어를 복습할 차례 순으로 담아요.'**
  String settingsReminderSummary(int count);

  /// Appended to the reminder summary when the device's scheduled notification limit is exceeded.
  ///
  /// In ko, this message translates to:
  /// **'기기의 예약 알림 제한({limit}개)을 넘어 늦은 시각 일부는 빠져요.'**
  String settingsReminderCapped(int limit);

  /// No description provided for @settingsTtsSection.
  ///
  /// In ko, this message translates to:
  /// **'발음 · TTS'**
  String get settingsTtsSection;

  /// No description provided for @settingsTtsDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본 발음'**
  String get settingsTtsDefault;

  /// No description provided for @settingsTtsDefaultHelp.
  ///
  /// In ko, this message translates to:
  /// **'단어와 예문을 읽을 기본 억양을 선택하세요.'**
  String get settingsTtsDefaultHelp;

  /// No description provided for @settingsTtsUs.
  ///
  /// In ko, this message translates to:
  /// **'미국식'**
  String get settingsTtsUs;

  /// No description provided for @settingsTtsUk.
  ///
  /// In ko, this message translates to:
  /// **'영국식'**
  String get settingsTtsUk;

  /// No description provided for @settingsTtsQuality.
  ///
  /// In ko, this message translates to:
  /// **'음질'**
  String get settingsTtsQuality;

  /// No description provided for @settingsTtsQualityValue.
  ///
  /// In ko, this message translates to:
  /// **'기기 TTS(무료)'**
  String get settingsTtsQualityValue;

  /// No description provided for @settingsTatoebaCredit.
  ///
  /// In ko, this message translates to:
  /// **'외부 예문: Tatoeba · CC BY 2.0 FR'**
  String get settingsTatoebaCredit;

  /// No description provided for @reminderEveryDay.
  ///
  /// In ko, this message translates to:
  /// **'매일'**
  String get reminderEveryDay;

  /// No description provided for @reminderNoWeekdays.
  ///
  /// In ko, this message translates to:
  /// **'요일 없음'**
  String get reminderNoWeekdays;

  /// No description provided for @reminderWeekdays.
  ///
  /// In ko, this message translates to:
  /// **'평일'**
  String get reminderWeekdays;

  /// No description provided for @reminderWeekends.
  ///
  /// In ko, this message translates to:
  /// **'주말'**
  String get reminderWeekends;

  /// Reminder interval shorter than an hour.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분마다'**
  String reminderIntervalMinutes(int minutes);

  /// Reminder interval in whole hours.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간마다'**
  String reminderIntervalHours(int hours);

  /// Reminder interval in hours and minutes.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 {minutes}분마다'**
  String reminderIntervalHoursMinutes(int hours, int minutes);

  /// No description provided for @reminderAddSchedule.
  ///
  /// In ko, this message translates to:
  /// **'알람 구간 추가'**
  String get reminderAddSchedule;

  /// No description provided for @reminderEditSchedule.
  ///
  /// In ko, this message translates to:
  /// **'알람 구간 편집'**
  String get reminderEditSchedule;

  /// No description provided for @reminderStart.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get reminderStart;

  /// No description provided for @reminderEnd.
  ///
  /// In ko, this message translates to:
  /// **'끝'**
  String get reminderEnd;

  /// No description provided for @reminderCrossesMidnight.
  ///
  /// In ko, this message translates to:
  /// **'끝 시각이 시작보다 이르면 자정을 넘겨 다음 날 끝 시각까지 보내요.'**
  String get reminderCrossesMidnight;

  /// No description provided for @reminderWeekdaysTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 받을 요일'**
  String get reminderWeekdaysTitle;

  /// No description provided for @reminderWeekdaysRequired.
  ///
  /// In ko, this message translates to:
  /// **'요일을 하나 이상 선택해 주세요.'**
  String get reminderWeekdaysRequired;

  /// No description provided for @reminderInterval.
  ///
  /// In ko, this message translates to:
  /// **'알림 간격'**
  String get reminderInterval;

  /// No description provided for @reminderWordsPerAlert.
  ///
  /// In ko, this message translates to:
  /// **'한 번에'**
  String get reminderWordsPerAlert;

  /// No description provided for @reminderDecreaseWords.
  ///
  /// In ko, this message translates to:
  /// **'단어 수 줄이기'**
  String get reminderDecreaseWords;

  /// No description provided for @reminderIncreaseWords.
  ///
  /// In ko, this message translates to:
  /// **'단어 수 늘리기'**
  String get reminderIncreaseWords;

  /// Number of words sent per reminder, shown between the -/+ buttons.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String reminderWordCount(int count);

  /// Words per reminder, shown in the reminder schedule tile.
  ///
  /// In ko, this message translates to:
  /// **'단어 {count}개'**
  String reminderWordCountLabel(int count);

  /// Number of reminders per day, shown in the reminder schedule tile.
  ///
  /// In ko, this message translates to:
  /// **'하루 {count}회'**
  String reminderTimesPerDay(int count);

  /// Preview in the reminder editor, e.g. 'Weekdays 5 times · 09:00, 12:00, ...'.
  ///
  /// In ko, this message translates to:
  /// **'{days} {count}회 · {times}'**
  String reminderPreview(String days, int count, String times);

  /// No description provided for @translationLanguageLabel.
  ///
  /// In ko, this message translates to:
  /// **'번역 언어'**
  String get translationLanguageLabel;

  /// Dropdown item for automatic translation language; language is the detected language name.
  ///
  /// In ko, this message translates to:
  /// **'자동 · {language}'**
  String translationLanguageAuto(String language);

  /// No description provided for @notificationChannelName.
  ///
  /// In ko, this message translates to:
  /// **'복습 알림'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In ko, this message translates to:
  /// **'설정한 요일·시간대에 보내는 단어 복습 알림'**
  String get notificationChannelDescription;

  /// No description provided for @notificationTitleDefault.
  ///
  /// In ko, this message translates to:
  /// **'복습 시간이에요'**
  String get notificationTitleDefault;

  /// Reminder notification title listing today's words.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 단어 {count}개'**
  String notificationTitleWords(int count);

  /// No description provided for @notificationBodyDefault.
  ///
  /// In ko, this message translates to:
  /// **'오늘 외울 단어가 기다리고 있어요. 탭하면 바로 학습!'**
  String get notificationBodyDefault;

  /// No description provided for @homeError.
  ///
  /// In ko, this message translates to:
  /// **'오류: {error}'**
  String homeError(String error);

  /// No description provided for @homeGreeting.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 외워볼까요?'**
  String get homeGreeting;

  /// Home metric label: words studied today.
  ///
  /// In ko, this message translates to:
  /// **'오늘 학습'**
  String get homeTodayStudy;

  /// No description provided for @homeTotalWords.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{전체 {count}개}}'**
  String homeTotalWords(int count);

  /// No description provided for @homeAccuracy.
  ///
  /// In ko, this message translates to:
  /// **'정답률'**
  String get homeAccuracy;

  /// No description provided for @homeCompletedWords.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{완료 {count}개}}'**
  String homeCompletedWords(int count);

  /// No description provided for @homeWordOfTheDay.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 단어'**
  String get homeWordOfTheDay;

  /// No description provided for @homeQuickStart.
  ///
  /// In ko, this message translates to:
  /// **'빠른 시작'**
  String get homeQuickStart;

  /// No description provided for @homeQuickGuessWord.
  ///
  /// In ko, this message translates to:
  /// **'예문 보고 단어 맞추기'**
  String get homeQuickGuessWord;

  /// No description provided for @homeQuickFillBlank.
  ///
  /// In ko, this message translates to:
  /// **'예문 빈칸 채우기'**
  String get homeQuickFillBlank;

  /// No description provided for @homeQuickBrowseWordbooks.
  ///
  /// In ko, this message translates to:
  /// **'단어장 둘러보기'**
  String get homeQuickBrowseWordbooks;

  /// No description provided for @homeCreateWordbookFirst.
  ///
  /// In ko, this message translates to:
  /// **'먼저 단어장을 만들어 주세요.'**
  String get homeCreateWordbookFirst;

  /// No description provided for @homeEditWord.
  ///
  /// In ko, this message translates to:
  /// **'단어 편집'**
  String get homeEditWord;

  /// No description provided for @homeListenWord.
  ///
  /// In ko, this message translates to:
  /// **'단어 발음 듣기'**
  String get homeListenWord;

  /// No description provided for @homeSeeDetails.
  ///
  /// In ko, this message translates to:
  /// **'자세히 보기'**
  String get homeSeeDetails;

  /// No description provided for @homeReviewAllDone.
  ///
  /// In ko, this message translates to:
  /// **'오늘 복습을\n모두 마쳤어요!'**
  String get homeReviewAllDone;

  /// No description provided for @homeReviewWaiting.
  ///
  /// In ko, this message translates to:
  /// **'{count, plural, other{{count}개의 단어가\n기다리고 있어요}}'**
  String homeReviewWaiting(int count);

  /// Inside the progress ring: number of mastered words.
  ///
  /// In ko, this message translates to:
  /// **'{count}\n완료'**
  String homeCompletedBadge(int count);

  /// Due words vs. mastered words mixed back into the session.
  ///
  /// In ko, this message translates to:
  /// **'신규/복습 {due} · 섞기 {mixed}'**
  String homeReviewBreakdown(int due, int mixed);

  /// No description provided for @homeStart.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get homeStart;

  /// No description provided for @reviewNoExample.
  ///
  /// In ko, this message translates to:
  /// **'(예문이 없습니다 — 뜻을 보고 단어를 입력하세요)'**
  String get reviewNoExample;

  /// No description provided for @reviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'예문 복습'**
  String get reviewTitle;

  /// No description provided for @reviewEmpty.
  ///
  /// In ko, this message translates to:
  /// **'오늘 꺼낼 카드 없음'**
  String get reviewEmpty;

  /// No description provided for @reviewFillBlankTitle.
  ///
  /// In ko, this message translates to:
  /// **'빈칸 채우기'**
  String get reviewFillBlankTitle;

  /// No description provided for @reviewChoiceInstruction.
  ///
  /// In ko, this message translates to:
  /// **'예문과 뜻을 보고 알맞은 단어를 고르세요'**
  String get reviewChoiceInstruction;

  /// No description provided for @reviewInputInstruction.
  ///
  /// In ko, this message translates to:
  /// **'예문과 뜻을 보고 단어를 입력하세요'**
  String get reviewInputInstruction;

  /// No description provided for @reviewOtherExample.
  ///
  /// In ko, this message translates to:
  /// **'다른 예문  {current}/{total}'**
  String reviewOtherExample(int current, int total);

  /// No description provided for @reviewDontKnow.
  ///
  /// In ko, this message translates to:
  /// **'모름'**
  String get reviewDontKnow;

  /// No description provided for @reviewInputHint.
  ///
  /// In ko, this message translates to:
  /// **'단어 입력'**
  String get reviewInputHint;

  /// No description provided for @reviewHint.
  ///
  /// In ko, this message translates to:
  /// **'힌트: {hint}'**
  String reviewHint(String hint);

  /// No description provided for @reviewCheckAnswer.
  ///
  /// In ko, this message translates to:
  /// **'정답 확인'**
  String get reviewCheckAnswer;

  /// No description provided for @reviewCorrect.
  ///
  /// In ko, this message translates to:
  /// **'정답입니다'**
  String get reviewCorrect;

  /// Followed by the correct word on the next line.
  ///
  /// In ko, this message translates to:
  /// **'아쉬워요. 정답은'**
  String get reviewWrongAnswerIs;

  /// source may include the license, e.g. "Tatoeba · CC BY 2.0 FR".
  ///
  /// In ko, this message translates to:
  /// **'출처: {source}'**
  String reviewSource(String source);

  /// No description provided for @reviewMixedNotice.
  ///
  /// In ko, this message translates to:
  /// **'복습 섞기로 다시 나온 단어예요 (학습완료)'**
  String get reviewMixedNotice;

  /// No description provided for @reviewSummaryTitle.
  ///
  /// In ko, this message translates to:
  /// **'복습 완료'**
  String get reviewSummaryTitle;

  /// No description provided for @reviewSummaryDone.
  ///
  /// In ko, this message translates to:
  /// **'복습을 완료했어요'**
  String get reviewSummaryDone;

  /// No description provided for @reviewSummaryScore.
  ///
  /// In ko, this message translates to:
  /// **'{total}문제 중 {correct}개 정답'**
  String reviewSummaryScore(int correct, int total);

  /// No description provided for @reviewGoHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get reviewGoHome;

  /// No description provided for @dictionaryRateLimited.
  ///
  /// In ko, this message translates to:
  /// **'사전 조회가 잠시 제한됐어요. 잠시 후 다시 시도해 주세요.'**
  String get dictionaryRateLimited;

  /// No description provided for @dictionaryConnectionFailed.
  ///
  /// In ko, this message translates to:
  /// **'사전에 연결하지 못했어요. 잠시 후 다시 시도해 주세요.'**
  String get dictionaryConnectionFailed;

  /// No description provided for @dictionaryTimeout.
  ///
  /// In ko, this message translates to:
  /// **'사전 응답이 늦어지고 있어요. 다시 시도해 주세요.'**
  String get dictionaryTimeout;

  /// No description provided for @dictionaryLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'사전 뜻을 불러오지 못했어요. 인터넷 연결을 확인하고 다시 시도해 주세요.'**
  String get dictionaryLoadFailed;

  /// No description provided for @draftDictionaryUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'사전에 연결하지 못했어요. 뜻을 직접 입력하거나 다시 조회해 주세요.'**
  String get draftDictionaryUnavailable;

  /// No description provided for @draftMeaningNotFound.
  ///
  /// In ko, this message translates to:
  /// **'뜻을 찾지 못했어요. 직접 입력하거나 사전에서 찾아보세요.'**
  String get draftMeaningNotFound;

  /// language is a localized language name, e.g. 프랑스어 / French.
  ///
  /// In ko, this message translates to:
  /// **'사전에 {language} 뜻이 없어 영어 풀이로 채웠어요. 번역 언어는 설정에서 바꿀 수 있어요.'**
  String draftNoTranslationUsedEnglish(String language);

  /// language is a localized language name.
  ///
  /// In ko, this message translates to:
  /// **'{language} 뜻이 없는 항목은 영어 풀이로 채웠어요.'**
  String draftSomeUsedEnglish(String language);

  /// Refers to the fetch-examples button label on the word form.
  ///
  /// In ko, this message translates to:
  /// **'예문은 아래의 ‘예문 가져오기’로 다시 불러올 수 있어요.'**
  String get draftExamplesRetry;

  /// Default tooltip of the speaker button.
  ///
  /// In ko, this message translates to:
  /// **'발음 듣기'**
  String get speakListen;

  /// No description provided for @speakListenExample.
  ///
  /// In ko, this message translates to:
  /// **'예문 듣기'**
  String get speakListenExample;

  /// No description provided for @adPreview.
  ///
  /// In ko, this message translates to:
  /// **'광고 미리보기'**
  String get adPreview;

  /// No description provided for @addWordButton.
  ///
  /// In ko, this message translates to:
  /// **'단어 추가'**
  String get addWordButton;

  /// No description provided for @wordCreateExampleTranslations.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석 포함'**
  String get wordCreateExampleTranslations;

  /// Collapsed status chip: auto examples are added without translations.
  ///
  /// In ko, this message translates to:
  /// **'해석 없음'**
  String get wordCreateNoExampleTranslations;

  /// No description provided for @homeRemainingCards.
  ///
  /// In ko, this message translates to:
  /// **'남은 카드'**
  String get homeRemainingCards;

  /// No description provided for @homeTodayCards.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {count}장'**
  String homeTodayCards(int count);

  /// No description provided for @homeNewReviewBreakdown.
  ///
  /// In ko, this message translates to:
  /// **'신규 {fresh} · 복습 {review}'**
  String homeNewReviewBreakdown(int fresh, int review);

  /// No description provided for @homeStartButton.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get homeStartButton;

  /// No description provided for @homeNoCardsToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘 꺼낼 카드 없음'**
  String get homeNoCardsToday;

  /// No description provided for @reviewRemaining.
  ///
  /// In ko, this message translates to:
  /// **'남은 {count}'**
  String reviewRemaining(int count);

  /// No description provided for @reviewKeep.
  ///
  /// In ko, this message translates to:
  /// **'남기기'**
  String get reviewKeep;

  /// No description provided for @reviewDiscard.
  ///
  /// In ko, this message translates to:
  /// **'버리기'**
  String get reviewDiscard;

  /// No description provided for @reviewDoneTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {count}장 끝'**
  String reviewDoneTitle(int count);

  /// No description provided for @wordbooksCardsLeft.
  ///
  /// In ko, this message translates to:
  /// **'장 남음 · 전체 {count}'**
  String wordbooksCardsLeft(int count);

  /// No description provided for @wordbookCardsLeftSuffix.
  ///
  /// In ko, this message translates to:
  /// **'장 남음'**
  String get wordbookCardsLeftSuffix;

  /// No description provided for @wordbookDetailAllDiscarded.
  ///
  /// In ko, this message translates to:
  /// **'남은 카드 없음'**
  String get wordbookDetailAllDiscarded;

  /// No description provided for @wordbookDetailDiscarded.
  ///
  /// In ko, this message translates to:
  /// **'\'{term}\' 버림'**
  String wordbookDetailDiscarded(String term);

  /// No description provided for @wordbookDetailReleaseToDiscard.
  ///
  /// In ko, this message translates to:
  /// **'놓으면 버림'**
  String get wordbookDetailReleaseToDiscard;

  /// No description provided for @wordbookAddWordShort.
  ///
  /// In ko, this message translates to:
  /// **'단어'**
  String get wordbookAddWordShort;

  /// No description provided for @discardedTitle.
  ///
  /// In ko, this message translates to:
  /// **'버린 카드'**
  String get discardedTitle;

  /// No description provided for @discardedEmpty.
  ///
  /// In ko, this message translates to:
  /// **'버린 카드 없음'**
  String get discardedEmpty;

  /// No description provided for @discardedRestore.
  ///
  /// In ko, this message translates to:
  /// **'다시 넣기'**
  String get discardedRestore;

  /// No description provided for @wordAddMeaningSelect.
  ///
  /// In ko, this message translates to:
  /// **'뜻 선택'**
  String get wordAddMeaningSelect;

  /// No description provided for @wordAddManualInput.
  ///
  /// In ko, this message translates to:
  /// **'뜻 직접 입력'**
  String get wordAddManualInput;

  /// No description provided for @wordAddMeaningLabel.
  ///
  /// In ko, this message translates to:
  /// **'뜻'**
  String get wordAddMeaningLabel;

  /// No description provided for @wordAddExamplesOf.
  ///
  /// In ko, this message translates to:
  /// **'{pos} 예문'**
  String wordAddExamplesOf(String pos);

  /// No description provided for @wordAddSelectedCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택'**
  String wordAddSelectedCount(int count);

  /// No description provided for @wordAddWriteExample.
  ///
  /// In ko, this message translates to:
  /// **'예문 직접 쓰기'**
  String get wordAddWriteExample;

  /// No description provided for @wordAddSave.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get wordAddSave;

  /// No description provided for @wordAddAlreadyInDeck.
  ///
  /// In ko, this message translates to:
  /// **'이미 덱에 있음'**
  String get wordAddAlreadyInDeck;

  /// No description provided for @wordAddNoResults.
  ///
  /// In ko, this message translates to:
  /// **'사전에 없음'**
  String get wordAddNoResults;

  /// No description provided for @wordAddLookupFailed.
  ///
  /// In ko, this message translates to:
  /// **'사전 연결 실패'**
  String get wordAddLookupFailed;

  /// No description provided for @wordAddAutoInput.
  ///
  /// In ko, this message translates to:
  /// **'자동 입력'**
  String get wordAddAutoInput;

  /// No description provided for @wordAddAutoOff.
  ///
  /// In ko, this message translates to:
  /// **'자동 입력 꺼짐'**
  String get wordAddAutoOff;

  /// No description provided for @wordAddExampleTranslation.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석'**
  String get wordAddExampleTranslation;

  /// No description provided for @wordAddNoExamples.
  ///
  /// In ko, this message translates to:
  /// **'예문 후보가 없어요. 비워 두고 등록해도 돼요.'**
  String get wordAddNoExamples;

  /// No description provided for @settingsTheme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get settingsTheme;

  /// No description provided for @themeSlate.
  ///
  /// In ko, this message translates to:
  /// **'슬레이트'**
  String get themeSlate;

  /// No description provided for @themeNavy.
  ///
  /// In ko, this message translates to:
  /// **'네이비'**
  String get themeNavy;

  /// No description provided for @themeBrown.
  ///
  /// In ko, this message translates to:
  /// **'브라운'**
  String get themeBrown;

  /// No description provided for @themePlum.
  ///
  /// In ko, this message translates to:
  /// **'플럼'**
  String get themePlum;

  /// No description provided for @themeCharcoal.
  ///
  /// In ko, this message translates to:
  /// **'차콜'**
  String get themeCharcoal;

  /// No description provided for @themeCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접'**
  String get themeCustom;

  /// No description provided for @themeCustomTitle.
  ///
  /// In ko, this message translates to:
  /// **'테마 직접 지정'**
  String get themeCustomTitle;

  /// No description provided for @themeBase.
  ///
  /// In ko, this message translates to:
  /// **'바탕'**
  String get themeBase;

  /// No description provided for @themePoint.
  ///
  /// In ko, this message translates to:
  /// **'포인트'**
  String get themePoint;

  /// No description provided for @themeAutoText.
  ///
  /// In ko, this message translates to:
  /// **'글자 색은 자동으로 맞춤'**
  String get themeAutoText;

  /// No description provided for @themeApply.
  ///
  /// In ko, this message translates to:
  /// **'적용'**
  String get themeApply;

  /// No description provided for @themeReset.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get themeReset;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageRow.
  ///
  /// In ko, this message translates to:
  /// **'뜻 · 예문 · 앱 언어'**
  String get settingsLanguageRow;

  /// No description provided for @settingsFollowDevice.
  ///
  /// In ko, this message translates to:
  /// **'기기 설정 따름'**
  String get settingsFollowDevice;

  /// No description provided for @settingsReviewSection.
  ///
  /// In ko, this message translates to:
  /// **'복습'**
  String get settingsReviewSection;

  /// No description provided for @settingsSessionSize.
  ///
  /// In ko, this message translates to:
  /// **'한 번에 꺼낼 카드'**
  String get settingsSessionSize;

  /// No description provided for @settingsMixLabel.
  ///
  /// In ko, this message translates to:
  /// **'버린 카드 다시 섞기'**
  String get settingsMixLabel;

  /// No description provided for @settingsMixExample.
  ///
  /// In ko, this message translates to:
  /// **'{total}장 중 {mixed}장'**
  String settingsMixExample(int total, int mixed);

  /// No description provided for @settingsWordAddSection.
  ///
  /// In ko, this message translates to:
  /// **'단어 추가'**
  String get settingsWordAddSection;

  /// No description provided for @settingsNotificationsSection.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get settingsNotificationsSection;

  /// No description provided for @settingsReminderMaster.
  ///
  /// In ko, this message translates to:
  /// **'복습 알림'**
  String get settingsReminderMaster;

  /// No description provided for @settingsAddSlot.
  ///
  /// In ko, this message translates to:
  /// **'알림 구간'**
  String get settingsAddSlot;

  /// No description provided for @settingsWeeklyCount.
  ///
  /// In ko, this message translates to:
  /// **'일주일 {count}회'**
  String settingsWeeklyCount(int count);

  /// No description provided for @reminderCardCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}장'**
  String reminderCardCount(int count);

  /// No description provided for @settingsPronunciationSection.
  ///
  /// In ko, this message translates to:
  /// **'발음'**
  String get settingsPronunciationSection;

  /// No description provided for @settingsAccent.
  ///
  /// In ko, this message translates to:
  /// **'억양'**
  String get settingsAccent;

  /// No description provided for @settingsVoice.
  ///
  /// In ko, this message translates to:
  /// **'목소리'**
  String get settingsVoice;

  /// No description provided for @settingsVoiceDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get settingsVoiceDefault;

  /// No description provided for @settingsSpeed.
  ///
  /// In ko, this message translates to:
  /// **'속도'**
  String get settingsSpeed;

  /// No description provided for @settingsSpeedSlow.
  ///
  /// In ko, this message translates to:
  /// **'느리게'**
  String get settingsSpeedSlow;

  /// No description provided for @settingsSpeedNormal.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get settingsSpeedNormal;

  /// No description provided for @settingsSpeedFast.
  ///
  /// In ko, this message translates to:
  /// **'빠르게'**
  String get settingsSpeedFast;

  /// No description provided for @settingsRecorded.
  ///
  /// In ko, this message translates to:
  /// **'단어는 사람 녹음으로'**
  String get settingsRecorded;

  /// No description provided for @settingsRecordedHelp.
  ///
  /// In ko, this message translates to:
  /// **'녹음이 없으면 목소리로 읽음'**
  String get settingsRecordedHelp;

  /// No description provided for @settingsAbout.
  ///
  /// In ko, this message translates to:
  /// **'정보 · 출처'**
  String get settingsAbout;

  /// No description provided for @aboutDataSources.
  ///
  /// In ko, this message translates to:
  /// **'데이터 출처'**
  String get aboutDataSources;

  /// No description provided for @aboutUseMeanings.
  ///
  /// In ko, this message translates to:
  /// **'뜻 · 사전 예문'**
  String get aboutUseMeanings;

  /// No description provided for @aboutUseOnline.
  ///
  /// In ko, this message translates to:
  /// **'온라인 사전'**
  String get aboutUseOnline;

  /// No description provided for @aboutUseExamples.
  ///
  /// In ko, this message translates to:
  /// **'번역 예문'**
  String get aboutUseExamples;

  /// No description provided for @aboutUseRecordings.
  ///
  /// In ko, this message translates to:
  /// **'단어 발음 녹음'**
  String get aboutUseRecordings;

  /// No description provided for @aboutApp.
  ///
  /// In ko, this message translates to:
  /// **'앱'**
  String get aboutApp;

  /// No description provided for @aboutVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get aboutVersion;

  /// No description provided for @aboutLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get aboutLicenses;

  /// No description provided for @reminderPerDayTotal.
  ///
  /// In ko, this message translates to:
  /// **'하루 {times}회 · {cards}장'**
  String reminderPerDayTotal(int times, int cards);

  /// Status of the per-language example translation download. size is e.g. '1.7MB'.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석 받는 중 · {size}'**
  String settingsPackDownloading(String size);

  /// No description provided for @settingsPackReady.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석 받음 · {size}'**
  String settingsPackReady(String size);

  /// No description provided for @settingsPackFailed.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석을 받지 못했어요'**
  String get settingsPackFailed;

  /// No description provided for @settingsPackRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get settingsPackRetry;

  /// No description provided for @settingsExampleDataSection.
  ///
  /// In ko, this message translates to:
  /// **'예문 데이터'**
  String get settingsExampleDataSection;

  /// No description provided for @settingsExampleData.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석 받기'**
  String get settingsExampleData;

  /// No description provided for @settingsPackNone.
  ///
  /// In ko, this message translates to:
  /// **'받지 않음'**
  String get settingsPackNone;

  /// No description provided for @settingsPackNotNeeded.
  ///
  /// In ko, this message translates to:
  /// **'영어는 해석이 필요하지 않아요'**
  String get settingsPackNotNeeded;

  /// Installed example translation data. version is a number, size e.g. '1.7MB'.
  ///
  /// In ko, this message translates to:
  /// **'받음 · v{version} · {size}'**
  String settingsPackVersion(int version, String size);

  /// No description provided for @settingsPackUpdate.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 확인'**
  String get settingsPackUpdate;

  /// No description provided for @settingsPackUpToDate.
  ///
  /// In ko, this message translates to:
  /// **'최신 버전이에요 (v{version})'**
  String settingsPackUpToDate(int version);

  /// No description provided for @settingsPackUpdated.
  ///
  /// In ko, this message translates to:
  /// **'v{version} 버전으로 업데이트했어요'**
  String settingsPackUpdated(int version);

  /// No description provided for @examplePromptTitle.
  ///
  /// In ko, this message translates to:
  /// **'예문 해석을 받을까요?'**
  String get examplePromptTitle;

  /// First-run question. size is empty or e.g. ' (1.7MB)' including the leading space.
  ///
  /// In ko, this message translates to:
  /// **'영어 예문의 {language} 해석을 내려받아 기기에 둡니다{size}. 설정의 예문 데이터에서 언제든 바꿀 수 있어요.'**
  String examplePromptBody(String language, String size);

  /// No description provided for @examplePromptAccept.
  ///
  /// In ko, this message translates to:
  /// **'받기'**
  String get examplePromptAccept;

  /// No description provided for @examplePromptDecline.
  ///
  /// In ko, this message translates to:
  /// **'받지 않기'**
  String get examplePromptDecline;

  /// No description provided for @wordAddPosLabel.
  ///
  /// In ko, this message translates to:
  /// **'품사'**
  String get wordAddPosLabel;

  /// No description provided for @wordAddPosUnknown.
  ///
  /// In ko, this message translates to:
  /// **'품사 모름'**
  String get wordAddPosUnknown;

  /// No description provided for @homeQuickGuessFromMeaning.
  ///
  /// In ko, this message translates to:
  /// **'뜻 보고 단어 맞추기'**
  String get homeQuickGuessFromMeaning;

  /// No description provided for @wordFoundExample.
  ///
  /// In ko, this message translates to:
  /// **'찾은 예문'**
  String get wordFoundExample;

  /// No description provided for @wordAddFoundExample.
  ///
  /// In ko, this message translates to:
  /// **'예문 넣기'**
  String get wordAddFoundExample;

  /// No description provided for @wordbookFoundExamples.
  ///
  /// In ko, this message translates to:
  /// **'예문 {count}개 찾음'**
  String wordbookFoundExamples(int count);

  /// No description provided for @wordAddScanExample.
  ///
  /// In ko, this message translates to:
  /// **'사진에서 예문 가져오기'**
  String get wordAddScanExample;

  /// No description provided for @wordScanCamera.
  ///
  /// In ko, this message translates to:
  /// **'카메라로 찍기'**
  String get wordScanCamera;

  /// No description provided for @wordScanGallery.
  ///
  /// In ko, this message translates to:
  /// **'앨범에서 고르기'**
  String get wordScanGallery;

  /// No description provided for @wordScanPick.
  ///
  /// In ko, this message translates to:
  /// **'가져올 문장 고르기'**
  String get wordScanPick;

  /// No description provided for @wordScanFailed.
  ///
  /// In ko, this message translates to:
  /// **'사진의 글자를 읽지 못했어요'**
  String get wordScanFailed;

  /// No description provided for @wordScanNoSentence.
  ///
  /// In ko, this message translates to:
  /// **'사진에서 \'{term}\'이(가) 들어간 문장을 찾지 못했어요'**
  String wordScanNoSentence(String term);

  /// No description provided for @exampleSourcePhoto.
  ///
  /// In ko, this message translates to:
  /// **'내 사진'**
  String get exampleSourcePhoto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'ja',
    'ko',
    'pt',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
