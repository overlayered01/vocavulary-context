// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonNext => 'Next';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => 'Loading';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Korean',
      'ja': 'Japanese',
      'zh': 'Chinese',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'pt': 'Portuguese',
      'vi': 'Vietnamese',
      'th': 'Thai',
      'id': 'Indonesian',
      'en': 'English',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Mon',
      'd2': 'Tue',
      'd3': 'Wed',
      'd4': 'Thu',
      'd5': 'Fri',
      'd6': 'Sat',
      'd7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Add word';

  @override
  String get wordEditWord => 'Edit word';

  @override
  String get wordExamples => 'Examples';

  @override
  String wordExampleSource(String source) {
    return 'Source: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Noun',
      'verb': 'Verb',
      'adjective': 'Adjective',
      'adverb': 'Adverb',
      'pronoun': 'Pronoun',
      'preposition': 'Preposition',
      'conjunction': 'Conjunction',
      'interjection': 'Interjection',
      'article': 'Article',
      'determiner': 'Determiner',
      'phrasalVerb': 'Phrasal verb',
      'idiom': 'Idiom',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Enter an English word first.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'Couldn\'t find any examples for \'$term\'.';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'All fetched examples have already been added.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count examples.',
      one: 'Added 1 example.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'Couldn\'t fetch examples: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Enter a word and at least one meaning.';

  @override
  String get wordEditSaveFailed => 'Couldn\'t save. Please try again.';

  @override
  String get wordEditSectionTerm => 'Word';

  @override
  String get wordEditSectionMeaning => 'Meaning & pronunciation';

  @override
  String get wordEditPhonetic => 'Phonetic';

  @override
  String get wordEditSearching => 'Searching';

  @override
  String get wordEditFetchExamples => 'Fetch examples';

  @override
  String get wordEditAddManually => 'Add manually';

  @override
  String get wordEditOptional => 'Optional';

  @override
  String wordEditExampleNumber(int index) {
    return 'Example $index';
  }

  @override
  String get wordEditDeleteExample => 'Delete example';

  @override
  String get wordEditSentence => 'English sentence';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Translation ($language)';
  }

  @override
  String get wordEditTermLabel => 'Word *';

  @override
  String get wordEditTermHint =>
      'Pick a saved word to fill in its meanings and examples automatically.';

  @override
  String get wordEditPartOfSpeech => 'Part of speech';

  @override
  String get wordEditPartOfSpeechNone => 'None';

  @override
  String get wordEditManualExampleTitle => 'Add example manually';

  @override
  String get wordEditSentenceRequiredLabel => 'English sentence *';

  @override
  String get wordEditSentenceRequired => 'Enter an English sentence.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Examples for \'$term\'';
  }

  @override
  String get wordEditPickerDescription =>
      'Choose examples to add. You can type translations for sentences that don\'t have one.';

  @override
  String wordEditNoTranslation(String language) {
    return 'No $language translation';
  }

  @override
  String get wordEditPickerAttribution =>
      'Examples from Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Add selected ($count)';
  }

  @override
  String get wordCreateLoadFailed => 'Couldn\'t load. Please try again.';

  @override
  String get wordCreateSectionTitle => 'Enter a word';

  @override
  String get wordCreateWordbook => 'Wordbook';

  @override
  String get wordCreateNoWordbook => 'No wordbooks';

  @override
  String get wordCreateReload => 'Reload';

  @override
  String get wordCreateTermLabel => 'Word';

  @override
  String get wordCreateLookingUp => 'Looking up';

  @override
  String get wordCreateAutoInputSettings => 'Auto-fill settings';

  @override
  String get wordCreateMeaningsOn => 'Meanings on';

  @override
  String get wordCreateMeaningsOff => 'Meanings off';

  @override
  String get wordCreateExamplesOn => 'Examples on';

  @override
  String get wordCreateExamplesOff => 'Examples off';

  @override
  String get wordCreateCollapse => 'Collapse';

  @override
  String get wordCreateExpand => 'Expand';

  @override
  String get wordCreateAutoMeanings => 'Auto-fill meanings';

  @override
  String get wordCreateAutoExamples => 'Auto-fill examples';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Added the selected dictionary meanings.';

  @override
  String get wordDetailTitle => 'Word details';

  @override
  String get wordDetailFavorite => 'Add to favorites';

  @override
  String get wordDetailUnfavorite => 'Remove from favorites';

  @override
  String get wordDetailAccentUs => 'American';

  @override
  String get wordDetailAccentUk => 'British';

  @override
  String get wordDetailMyMeanings => 'My meanings';

  @override
  String get wordDetailListenExample => 'Listen to example';

  @override
  String get wordDetailGoogleTranslate => 'Google Translate';

  @override
  String get meaningFieldsLabel => 'Meaning';

  @override
  String get meaningFieldsLabelRequired => 'Meaning *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'Meaning $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'Remove meaning $index';
  }

  @override
  String get meaningFieldsAdd => 'Add meaning';

  @override
  String get meaningFieldsEmptyError => 'Enter at least one meaning.';

  @override
  String get meaningFieldsEditTitle => 'Edit meanings';

  @override
  String get dictLookupAddFailed =>
      'Couldn\'t add the meanings. Please try again.';

  @override
  String get dictLookupButton => 'Dictionary meanings';

  @override
  String dictLookupTitle(String term) {
    return '$term · Dictionary';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Entries without a $language meaning show the English definition.';
  }

  @override
  String get dictLookupLoadFailed => 'Couldn\'t load dictionary meanings.';

  @override
  String get dictLookupNoResults =>
      'No dictionary meanings found.\nCheck the spelling or try another dictionary.';

  @override
  String get dictLookupAlreadyAdded => 'Added';

  @override
  String dictLookupAddSelected(int count) {
    return 'Add selected ($count)';
  }

  @override
  String get dictLookupLinkFailed => 'Couldn\'t open the dictionary link.';

  @override
  String get dictLinksNaver => 'Naver (En–Ko)';

  @override
  String get dictLinksOxford => 'Oxford (En–En)';

  @override
  String get dictLinksOpenFailed =>
      'Couldn\'t open the dictionary. Please try again.';

  @override
  String get dictLinksTitle => 'More in dictionaries';

  @override
  String wordbookError(String error) {
    return 'Error: $error';
  }

  @override
  String get wordbookShareCode => 'Share code';

  @override
  String wordbookDeleteTitle(String name) {
    return 'Delete \'$name\'';
  }

  @override
  String get wordbooksTitle => 'My wordbooks';

  @override
  String get wordbooksNew => 'New wordbook';

  @override
  String get wordbooksEmpty => 'No wordbooks yet.\nTap + to add one.';

  @override
  String get wordbooksCreate => 'Create';

  @override
  String get wordbooksNameLabel => 'Wordbook name';

  @override
  String get wordbooksTagsLabel => 'Tags';

  @override
  String get wordbooksTagsHint => 'TOEIC, daily conversation (comma-separated)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Wordbook menu';

  @override
  String get wordbooksMenuRename => 'Edit name & tags';

  @override
  String get wordbooksShareSettings => 'Sharing & visibility';

  @override
  String get wordbooksMenuDelete => 'Delete wordbook';

  @override
  String get wordbooksEditTitle => 'Edit wordbook';

  @override
  String get wordbooksShareLoginRequired =>
      'Sign in to share or publish wordbooks.';

  @override
  String get wordbooksVisibilityPrivate => 'Private';

  @override
  String get wordbooksVisibilityShared => 'Share code';

  @override
  String get wordbooksVisibilityPublic => 'Public';

  @override
  String get wordbooksVisibilityPrivateDesc => 'Only you can see it.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Anyone with the share code can copy this wordbook.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Listed in the Explore tab, where anyone can copy it.';

  @override
  String get wordbooksCopyCode => 'Copy code';

  @override
  String get wordbooksCodeCopied => 'Share code copied.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The $count words in this wordbook will also be deleted.\nDeleted wordbooks can\'t be restored.',
      one:
          'The 1 word in this wordbook will also be deleted.\nDeleted wordbooks can\'t be restored.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty => 'Deleted wordbooks can\'t be restored.';

  @override
  String get wordbookDetailEmpty => 'No words yet.\nTap the Add word button.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '\'$term\' deleted';
  }

  @override
  String get wordbookDetailUndo => 'Undo';

  @override
  String get wordbookDetailEditWholeWord => 'Edit entire word';

  @override
  String get wordbookDetailEditWord => 'Edit word';

  @override
  String get wordbookDetailFavorite => 'Favorite';

  @override
  String get wordbookDetailUnfavorite => 'Remove from favorites';

  @override
  String get wordbookDetailEditMeaning => 'Edit meaning';

  @override
  String get wordbookDetailEditAll => 'Edit all';

  @override
  String get wordbookDetailStatusFresh => 'New';

  @override
  String get wordbookDetailStatusLearning => 'Learning';

  @override
  String get wordbookDetailStatusCompleted => 'Done';

  @override
  String get wordbookDetailDeleteWordConfirm => 'Delete this word?';

  @override
  String get wordbookDetailReleaseToDelete => 'Release to delete';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreCodeNotFound => 'No shared wordbook matches this code.';

  @override
  String get exploreImportFailed =>
      'Couldn\'t import. Please check your network connection.';

  @override
  String exploreCopyTitle(String title) {
    return 'Copy \'$title\'';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Copy $count words to your wordbooks?\nLearning progress will start fresh.',
      one:
          'Copy 1 word to your wordbooks?\nLearning progress will start fresh.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Copy';

  @override
  String exploreImported(String title) {
    return 'Imported \'$title\'.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Discover new\nwordbooks';

  @override
  String get exploreLoginRequired => 'Sign in to explore shared wordbooks.';

  @override
  String get exploreGoToLogin => 'Sign in';

  @override
  String get exploreSupabaseRequired => 'Available after connecting Supabase.';

  @override
  String get exploreImportByCode => 'Import with a share code';

  @override
  String get exploreCodeHint => 'Paste the code you received';

  @override
  String get exploreImport => 'Import';

  @override
  String get exploreCodeHelp =>
      'Copy a code from Sharing & visibility in the wordbook menu to share it.';

  @override
  String get explorePublicWordbooks => 'Public wordbooks';

  @override
  String get explorePublicLoadFailed =>
      'Couldn\'t load public wordbooks.\nPull down to refresh.';

  @override
  String get explorePublicEmpty => 'No public wordbooks yet.';

  @override
  String get loginMigrateTitle => 'Import local wordbooks';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Copy $count wordbooks created on this device to the cloud?\nWordbooks already in the cloud will be skipped.',
      one:
          'Copy 1 wordbook created on this device to the cloud?\nWordbooks already in the cloud will be skipped.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Later';

  @override
  String get loginImport => 'Import';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count wordbooks.',
      one: 'Imported 1 wordbook.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud => 'All wordbooks are already in the cloud.';

  @override
  String get loginErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get loginErrorUserExists =>
      'This email is already registered. Please sign in.';

  @override
  String get loginErrorWeakPassword =>
      'Password is too short. Use at least 6 characters.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Please verify your email. Check your inbox.';

  @override
  String get loginErrorRateLimit =>
      'Too many requests. Please try again later.';

  @override
  String loginErrorGeneric(String message) {
    return 'Sign-in failed. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'Couldn\'t process the request. Check your network connection and try again.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginTagline =>
      'Learn easily with examples, steadily with reminders';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignUpWithEmail => 'Sign up with email';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get navHome => 'Home';

  @override
  String get navWordbooks => 'Wordbooks';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTranslationSection => 'Meaning · Example translation';

  @override
  String get settingsTranslationHelp =>
      'Auto follows your device\'s language and region. Translations are used for meanings and examples of newly looked-up words. Meanings without a translation show the English definition, and example translations are left blank. Content you\'ve already saved won\'t change automatically.';

  @override
  String get settingsAppLanguageNote =>
      'The app is also displayed in this language. Languages without an app translation are shown in English.';

  @override
  String get settingsReviewMixSection => 'Review mix ratio';

  @override
  String get settingsReviewMixLabel => 'Mix in words you\'ve already learned';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'questions',
      one: 'question',
    );
    return 'Mixes this share of \'completed\' words into review sets to strengthen long-term memory. (e.g. $mixed of $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'Reminders · Review';

  @override
  String get settingsReminderToggle => 'Get review reminders';

  @override
  String get settingsReminderOff => 'Reminders are off.';

  @override
  String get settingsReminderNoActive => 'No reminder windows are turned on.';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reminders',
      one: '1 reminder',
    );
    return 'Repeats weekly · $_temp0 a week. Words you\'re learning are included in the order they\'re due for review.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Some late reminders are dropped because they exceed the device\'s limit of $limit scheduled notifications.';
  }

  @override
  String get settingsTtsSection => 'Pronunciation · TTS';

  @override
  String get settingsTtsDefault => 'Default accent';

  @override
  String get settingsTtsDefaultHelp =>
      'Choose the accent used to read words and examples.';

  @override
  String get settingsTtsUs => 'American';

  @override
  String get settingsTtsUk => 'British';

  @override
  String get settingsTtsQuality => 'Voice quality';

  @override
  String get settingsTtsQualityValue => 'Device TTS (free)';

  @override
  String get settingsTatoebaCredit =>
      'External examples: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Every day';

  @override
  String get reminderNoWeekdays => 'No days';

  @override
  String get reminderWeekdays => 'Weekdays';

  @override
  String get reminderWeekends => 'Weekends';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'Every $minutes min';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Every $hours hours',
      one: 'Every hour',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'Every $hours h $minutes min';
  }

  @override
  String get reminderAddSchedule => 'Add reminder window';

  @override
  String get reminderEditSchedule => 'Edit reminder window';

  @override
  String get reminderStart => 'Start';

  @override
  String get reminderEnd => 'End';

  @override
  String get reminderCrossesMidnight =>
      'If the end time is earlier than the start, reminders continue past midnight until the end time the next day.';

  @override
  String get reminderWeekdaysTitle => 'Reminder days';

  @override
  String get reminderWeekdaysRequired => 'Select at least one day.';

  @override
  String get reminderInterval => 'Reminder interval';

  @override
  String get reminderWordsPerAlert => 'Per alert';

  @override
  String get reminderDecreaseWords => 'Fewer words';

  @override
  String get reminderIncreaseWords => 'More words';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a day',
      one: 'once a day',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Translation language';

  @override
  String translationLanguageAuto(String language) {
    return 'Auto · $language';
  }

  @override
  String get notificationChannelName => 'Review reminders';

  @override
  String get notificationChannelDescription =>
      'Word review reminders sent on your chosen days and times';

  @override
  String get notificationTitleDefault => 'Time to review';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today\'s $count words',
      one: 'Today\'s word',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'Today\'s words are waiting for you. Tap to start learning!';

  @override
  String homeError(String error) {
    return 'Error: $error';
  }

  @override
  String get homeGreeting => 'Ready to learn some words?';

  @override
  String get homeTodayStudy => 'Studied today';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words total',
      one: '1 word total',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Accuracy';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mastered',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'Word of the day';

  @override
  String get homeQuickStart => 'Quick start';

  @override
  String get homeQuickGuessWord => 'Guess the word from examples';

  @override
  String get homeQuickFillBlank => 'Fill in the blanks';

  @override
  String get homeQuickBrowseWordbooks => 'Browse wordbooks';

  @override
  String get homeCreateWordbookFirst => 'Create a wordbook first.';

  @override
  String get homeEditWord => 'Edit word';

  @override
  String get homeListenWord => 'Hear the word';

  @override
  String get homeSeeDetails => 'See details';

  @override
  String get homeReviewAllDone => 'All reviews\ndone for today!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words are\nwaiting for you',
      one: '1 word is\nwaiting for you',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\ndone';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'New/review $due · Mixed $mixed';
  }

  @override
  String get homeStart => 'Start';

  @override
  String get reviewNoExample => '(No example — type the word from its meaning)';

  @override
  String get reviewTitle => 'Example review';

  @override
  String get reviewEmpty => 'No cards today';

  @override
  String get reviewFillBlankTitle => 'Fill in the blank';

  @override
  String get reviewChoiceInstruction =>
      'Pick the word that fits the example and meaning';

  @override
  String get reviewInputInstruction =>
      'Type the word that fits the example and meaning';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Another example  $current/$total';
  }

  @override
  String get reviewDontKnow => 'Don\'t know';

  @override
  String get reviewInputHint => 'Type the word';

  @override
  String reviewHint(String hint) {
    return 'Hint: $hint';
  }

  @override
  String get reviewCheckAnswer => 'Check answer';

  @override
  String get reviewCorrect => 'Correct!';

  @override
  String get reviewWrongAnswerIs => 'Not quite. The answer is';

  @override
  String reviewSource(String source) {
    return 'Source: $source';
  }

  @override
  String get reviewMixedNotice => 'A mastered word mixed back in for review';

  @override
  String get reviewSummaryTitle => 'Review complete';

  @override
  String get reviewSummaryDone => 'You finished the review';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get reviewGoHome => 'Back to home';

  @override
  String get dictionaryRateLimited =>
      'Dictionary lookups are temporarily limited. Please try again shortly.';

  @override
  String get dictionaryConnectionFailed =>
      'Couldn\'t reach the dictionary. Please try again shortly.';

  @override
  String get dictionaryTimeout =>
      'The dictionary is taking too long. Please try again.';

  @override
  String get dictionaryLoadFailed =>
      'Couldn\'t load dictionary meanings. Check your internet connection and try again.';

  @override
  String get draftDictionaryUnavailable =>
      'Couldn\'t reach the dictionary. Enter the meaning yourself or look it up again.';

  @override
  String get draftMeaningNotFound =>
      'No meaning found. Enter it yourself or search the dictionary.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'The dictionary has no $language meaning, so English definitions were used. You can change the translation language in Settings.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Entries without a $language meaning were filled with English definitions.';
  }

  @override
  String get draftExamplesRetry =>
      'You can load examples again with ‘Fetch examples’ below.';

  @override
  String get speakListen => 'Listen';

  @override
  String get speakListenExample => 'Listen to example';

  @override
  String get adPreview => 'Ad preview';

  @override
  String get addWordButton => 'Add word';

  @override
  String get wordCreateExampleTranslations => 'Include translations';

  @override
  String get wordCreateNoExampleTranslations => 'No translations';

  @override
  String get homeRemainingCards => 'Cards left';

  @override
  String homeTodayCards(int count) {
    return '$count today';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'New $fresh · Review $review';
  }

  @override
  String get homeStartButton => 'Start';

  @override
  String get homeNoCardsToday => 'No cards today';

  @override
  String reviewRemaining(int count) {
    return '$count left';
  }

  @override
  String get reviewKeep => 'Keep';

  @override
  String get reviewDiscard => 'Discard';

  @override
  String reviewDoneTitle(int count) {
    return '$count cards done';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'left · $count total';
  }

  @override
  String get wordbookCardsLeftSuffix => 'left';

  @override
  String get wordbookDetailAllDiscarded => 'No cards left';

  @override
  String wordbookDetailDiscarded(String term) {
    return 'Discarded \'$term\'';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Release to discard';

  @override
  String get wordbookAddWordShort => 'Word';

  @override
  String get discardedTitle => 'Discarded';

  @override
  String get discardedEmpty => 'Nothing discarded';

  @override
  String get discardedRestore => 'Put back';

  @override
  String get wordAddMeaningSelect => 'Pick meanings';

  @override
  String get wordAddManualInput => 'Type a meaning';

  @override
  String get wordAddMeaningLabel => 'Meaning';

  @override
  String wordAddExamplesOf(String pos) {
    return '$pos examples';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get wordAddWriteExample => 'Write an example';

  @override
  String get wordAddSave => 'Add word';

  @override
  String get wordAddAlreadyInDeck => 'Already in deck';

  @override
  String get wordAddNoResults => 'Not in dictionary';

  @override
  String get wordAddLookupFailed => 'Dictionary unavailable';

  @override
  String get wordAddAutoInput => 'Auto-fill';

  @override
  String get wordAddAutoOff => 'Auto-fill off';

  @override
  String get wordAddExampleTranslation => 'Translations';

  @override
  String get wordAddNoExamples =>
      'No example candidates. You can add the word without one.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSlate => 'Slate';

  @override
  String get themeNavy => 'Navy';

  @override
  String get themeBrown => 'Brown';

  @override
  String get themePlum => 'Plum';

  @override
  String get themeCharcoal => 'Charcoal';

  @override
  String get themeCustom => 'Custom';

  @override
  String get themeCustomTitle => 'Custom theme';

  @override
  String get themeBase => 'Base';

  @override
  String get themePoint => 'Accent';

  @override
  String get themeAutoText => 'Text colors adjust automatically';

  @override
  String get themeApply => 'Apply';

  @override
  String get themeReset => 'Reset';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageRow => 'Meanings · examples · app';

  @override
  String get settingsFollowDevice => 'Follows device';

  @override
  String get settingsReviewSection => 'Review';

  @override
  String get settingsSessionSize => 'Cards per session';

  @override
  String get settingsMixLabel => 'Mix discarded cards back';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed of $total';
  }

  @override
  String get settingsWordAddSection => 'Adding words';

  @override
  String get settingsNotificationsSection => 'Reminders';

  @override
  String get settingsReminderMaster => 'Review reminders';

  @override
  String get settingsAddSlot => 'Reminder slot';

  @override
  String settingsWeeklyCount(int count) {
    return '$count× a week';
  }

  @override
  String reminderCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get settingsPronunciationSection => 'Pronunciation';

  @override
  String get settingsAccent => 'Accent';

  @override
  String get settingsVoice => 'Voice';

  @override
  String get settingsVoiceDefault => 'Default';

  @override
  String get settingsSpeed => 'Speed';

  @override
  String get settingsSpeedSlow => 'Slow';

  @override
  String get settingsSpeedNormal => 'Normal';

  @override
  String get settingsSpeedFast => 'Fast';

  @override
  String get settingsRecorded => 'Human recordings for words';

  @override
  String get settingsRecordedHelp => 'Uses the voice when there\'s none';

  @override
  String get settingsAbout => 'About · sources';

  @override
  String get aboutDataSources => 'Data sources';

  @override
  String get aboutUseMeanings => 'Meanings · dictionary examples';

  @override
  String get aboutUseOnline => 'Online dictionary';

  @override
  String get aboutUseExamples => 'Translated examples';

  @override
  String get aboutUseRecordings => 'Word recordings';

  @override
  String get aboutApp => 'App';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Open-source licenses';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times× a day · $cards cards';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Downloading example translations · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Example translations ready · $size';
  }

  @override
  String get settingsPackFailed => 'Couldn\'t download example translations';

  @override
  String get settingsPackRetry => 'Retry';

  @override
  String get settingsExampleDataSection => 'Example data';

  @override
  String get settingsExampleData => 'Download example translations';

  @override
  String get settingsPackNone => 'Not downloaded';

  @override
  String get settingsPackNotNeeded => 'No translations needed for English';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Downloaded · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Check for updates';

  @override
  String settingsPackUpToDate(int version) {
    return 'Up to date (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Updated to v$version';
  }

  @override
  String get examplePromptTitle => 'Download example translations?';

  @override
  String examplePromptBody(String language, String size) {
    return 'Download $language translations of the English examples to this device$size. You can change this anytime under Example data in Settings.';
  }

  @override
  String get examplePromptAccept => 'Download';

  @override
  String get examplePromptDecline => 'Not now';

  @override
  String get wordAddPosLabel => 'Part of speech';

  @override
  String get wordAddPosUnknown => 'Unknown';

  @override
  String get homeQuickGuessFromMeaning => 'Guess the word from its meaning';

  @override
  String get wordFoundExample => 'Found example';

  @override
  String get wordAddFoundExample => 'Add example';

  @override
  String wordbookFoundExamples(int count) {
    return '$count examples found';
  }

  @override
  String get wordAddScanExample => 'Get examples from a photo';

  @override
  String get wordScanCamera => 'Take a photo';

  @override
  String get wordScanGallery => 'Choose from photos';

  @override
  String get wordScanPick => 'Choose sentences';

  @override
  String get wordScanFailed => 'Couldn\'t read text from the photo';

  @override
  String wordScanNoSentence(String term) {
    return 'No sentence with \'$term\' found in the photo';
  }

  @override
  String get exampleSourcePhoto => 'My photo';
}
