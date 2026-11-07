// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Vocab with Examples';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonNext => 'Weiter';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonLoading => 'Wird geladen';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ko': 'Koreanisch',
      'ja': 'Japanisch',
      'zh': 'Chinesisch',
      'es': 'Spanisch',
      'fr': 'Französisch',
      'de': 'Deutsch',
      'pt': 'Portugiesisch',
      'vi': 'Vietnamesisch',
      'th': 'Thailändisch',
      'id': 'Indonesisch',
      'en': 'Englisch',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Mo',
      'd2': 'Di',
      'd3': 'Mi',
      'd4': 'Do',
      'd5': 'Fr',
      'd6': 'Sa',
      'd7': 'So',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get wordAddWord => 'Wort hinzufügen';

  @override
  String get wordEditWord => 'Wort bearbeiten';

  @override
  String get wordExamples => 'Beispiele';

  @override
  String wordExampleSource(String source) {
    return 'Quelle: $source';
  }

  @override
  String wordPartOfSpeech(String pos, String value) {
    String _temp0 = intl.Intl.selectLogic(pos, {
      'noun': 'Nomen',
      'verb': 'Verb',
      'adjective': 'Adjektiv',
      'adverb': 'Adverb',
      'pronoun': 'Pronomen',
      'preposition': 'Präposition',
      'conjunction': 'Konjunktion',
      'interjection': 'Interjektion',
      'article': 'Artikel',
      'determiner': 'Determinativ',
      'phrasalVerb': 'Phrasal Verb',
      'idiom': 'Redewendung',
      'phrase': 'Phrase',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get wordEditTermRequired => 'Gib zuerst ein englisches Wort ein.';

  @override
  String wordEditNoExamplesFound(String term) {
    return 'Keine Beispiele für „$term“ gefunden.';
  }

  @override
  String get wordEditExamplesAlreadyAdded =>
      'Alle gefundenen Beispiele sind bereits hinzugefügt.';

  @override
  String wordEditExamplesAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Beispiele hinzugefügt.',
      one: '1 Beispiel hinzugefügt.',
    );
    return '$_temp0';
  }

  @override
  String wordEditExamplesFetchFailed(String error) {
    return 'Beispiele konnten nicht geladen werden: $error';
  }

  @override
  String get wordEditTermAndMeaningRequired =>
      'Gib ein Wort und mindestens eine Bedeutung ein.';

  @override
  String get wordEditSaveFailed =>
      'Speichern fehlgeschlagen. Bitte versuch es erneut.';

  @override
  String get wordEditSectionTerm => 'Wort';

  @override
  String get wordEditSectionMeaning => 'Bedeutung & Aussprache';

  @override
  String get wordEditPhonetic => 'Lautschrift';

  @override
  String get wordEditSearching => 'Suche läuft';

  @override
  String get wordEditFetchExamples => 'Beispiele laden';

  @override
  String get wordEditAddManually => 'Manuell hinzufügen';

  @override
  String get wordEditOptional => 'Optional';

  @override
  String wordEditExampleNumber(int index) {
    return 'Beispiel $index';
  }

  @override
  String get wordEditDeleteExample => 'Beispiel löschen';

  @override
  String get wordEditSentence => 'Englischer Satz';

  @override
  String wordEditTranslationLabel(String language) {
    return 'Übersetzung ($language)';
  }

  @override
  String get wordEditTermLabel => 'Wort *';

  @override
  String get wordEditTermHint =>
      'Wähle ein gespeichertes Wort, um Bedeutungen und Beispiele automatisch auszufüllen.';

  @override
  String get wordEditPartOfSpeech => 'Wortart';

  @override
  String get wordEditPartOfSpeechNone => 'Keine';

  @override
  String get wordEditManualExampleTitle => 'Beispiel manuell hinzufügen';

  @override
  String get wordEditSentenceRequiredLabel => 'Englischer Satz *';

  @override
  String get wordEditSentenceRequired => 'Gib einen englischen Satz ein.';

  @override
  String wordEditPickerTitle(String term) {
    return 'Beispiele für „$term“';
  }

  @override
  String get wordEditPickerDescription =>
      'Wähle Beispiele zum Hinzufügen. Fehlende Übersetzungen kannst du selbst eingeben.';

  @override
  String wordEditNoTranslation(String language) {
    return 'Keine Übersetzung ($language)';
  }

  @override
  String get wordEditPickerAttribution =>
      'Beispiele von Tatoeba · CC BY 2.0 FR';

  @override
  String wordEditAddSelectedExamples(int count) {
    return 'Auswahl hinzufügen ($count)';
  }

  @override
  String get wordCreateLoadFailed =>
      'Laden fehlgeschlagen. Bitte versuch es erneut.';

  @override
  String get wordCreateSectionTitle => 'Wort eingeben';

  @override
  String get wordCreateWordbook => 'Wortliste';

  @override
  String get wordCreateNoWordbook => 'Keine Wortlisten';

  @override
  String get wordCreateReload => 'Neu laden';

  @override
  String get wordCreateTermLabel => 'Wort';

  @override
  String get wordCreateLookingUp => 'Wird gesucht';

  @override
  String get wordCreateAutoInputSettings => 'Auto-Ausfüllen';

  @override
  String get wordCreateMeaningsOn => 'Bedeutungen an';

  @override
  String get wordCreateMeaningsOff => 'Bedeutungen aus';

  @override
  String get wordCreateExamplesOn => 'Beispiele an';

  @override
  String get wordCreateExamplesOff => 'Beispiele aus';

  @override
  String get wordCreateCollapse => 'Einklappen';

  @override
  String get wordCreateExpand => 'Ausklappen';

  @override
  String get wordCreateAutoMeanings => 'Bedeutungen automatisch';

  @override
  String get wordCreateAutoExamples => 'Beispiele automatisch';

  @override
  String get wordDetailDictionaryMeaningsAdded =>
      'Ausgewählte Wörterbuch-Bedeutungen hinzugefügt.';

  @override
  String get wordDetailTitle => 'Wortdetails';

  @override
  String get wordDetailFavorite => 'Zu Favoriten';

  @override
  String get wordDetailUnfavorite => 'Aus Favoriten entfernen';

  @override
  String get wordDetailAccentUs => 'Amerikanisch';

  @override
  String get wordDetailAccentUk => 'Britisch';

  @override
  String get wordDetailMyMeanings => 'Meine Bedeutungen';

  @override
  String get wordDetailListenExample => 'Beispiel anhören';

  @override
  String get wordDetailGoogleTranslate => 'Google Übersetzer';

  @override
  String get meaningFieldsLabel => 'Bedeutung';

  @override
  String get meaningFieldsLabelRequired => 'Bedeutung *';

  @override
  String meaningFieldsLabelNumbered(int index) {
    return 'Bedeutung $index';
  }

  @override
  String meaningFieldsRemove(int index) {
    return 'Bedeutung $index entfernen';
  }

  @override
  String get meaningFieldsAdd => 'Bedeutung hinzufügen';

  @override
  String get meaningFieldsEmptyError => 'Gib mindestens eine Bedeutung ein.';

  @override
  String get meaningFieldsEditTitle => 'Bedeutungen bearbeiten';

  @override
  String get dictLookupAddFailed =>
      'Bedeutungen konnten nicht hinzugefügt werden. Bitte versuch es erneut.';

  @override
  String get dictLookupButton => 'Wörterbuch';

  @override
  String dictLookupTitle(String term) {
    return '$term · Wörterbuch';
  }

  @override
  String dictLookupFallbackNotice(String language) {
    return 'Einträge ohne Bedeutung auf $language zeigen die englische Definition.';
  }

  @override
  String get dictLookupLoadFailed =>
      'Wörterbuch-Bedeutungen konnten nicht geladen werden.';

  @override
  String get dictLookupNoResults =>
      'Keine Bedeutungen im Wörterbuch gefunden.\nPrüfe die Schreibweise oder versuch ein anderes Wörterbuch.';

  @override
  String get dictLookupAlreadyAdded => 'Hinzugefügt';

  @override
  String dictLookupAddSelected(int count) {
    return 'Auswahl hinzufügen ($count)';
  }

  @override
  String get dictLookupLinkFailed =>
      'Wörterbuch-Link konnte nicht geöffnet werden.';

  @override
  String get dictLinksNaver => 'Naver (En–Ko)';

  @override
  String get dictLinksOxford => 'Oxford (En–En)';

  @override
  String get dictLinksOpenFailed =>
      'Wörterbuch konnte nicht geöffnet werden. Bitte versuch es erneut.';

  @override
  String get dictLinksTitle => 'Mehr in Wörterbüchern';

  @override
  String wordbookError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get wordbookShareCode => 'Freigabecode';

  @override
  String wordbookDeleteTitle(String name) {
    return '„$name“ löschen';
  }

  @override
  String get wordbooksTitle => 'Meine Wortlisten';

  @override
  String get wordbooksNew => 'Neue Wortliste';

  @override
  String get wordbooksEmpty =>
      'Noch keine Wortlisten.\nTippe auf +, um eine anzulegen.';

  @override
  String get wordbooksCreate => 'Erstellen';

  @override
  String get wordbooksNameLabel => 'Name der Wortliste';

  @override
  String get wordbooksTagsLabel => 'Tags';

  @override
  String get wordbooksTagsHint => 'TOEFL, Alltag (durch Kommas getrennt)';

  @override
  String wordbooksWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter',
      one: '1 Wort',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksMenu => 'Wortlisten-Menü';

  @override
  String get wordbooksMenuRename => 'Name & Tags bearbeiten';

  @override
  String get wordbooksShareSettings => 'Teilen & Sichtbarkeit';

  @override
  String get wordbooksMenuDelete => 'Wortliste löschen';

  @override
  String get wordbooksEditTitle => 'Wortliste bearbeiten';

  @override
  String get wordbooksShareLoginRequired =>
      'Melde dich an, um Wortlisten zu teilen oder zu veröffentlichen.';

  @override
  String get wordbooksVisibilityPrivate => 'Privat';

  @override
  String get wordbooksVisibilityShared => 'Freigabecode';

  @override
  String get wordbooksVisibilityPublic => 'Öffentlich';

  @override
  String get wordbooksVisibilityPrivateDesc => 'Nur du kannst sie sehen.';

  @override
  String get wordbooksVisibilitySharedDesc =>
      'Jeder mit dem Freigabecode kann diese Wortliste kopieren.';

  @override
  String get wordbooksVisibilityPublicDesc =>
      'Erscheint im Tab „Entdecken“, wo jeder sie kopieren kann.';

  @override
  String get wordbooksCopyCode => 'Code kopieren';

  @override
  String get wordbooksCodeCopied => 'Freigabecode kopiert.';

  @override
  String wordbooksDeleteWithWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Die $count Wörter in dieser Wortliste werden ebenfalls gelöscht.\nGelöschte Wortlisten können nicht wiederhergestellt werden.',
      one:
          'Das 1 Wort in dieser Wortliste wird ebenfalls gelöscht.\nGelöschte Wortlisten können nicht wiederhergestellt werden.',
    );
    return '$_temp0';
  }

  @override
  String get wordbooksDeleteEmpty =>
      'Gelöschte Wortlisten können nicht wiederhergestellt werden.';

  @override
  String get wordbookDetailEmpty =>
      'Noch keine Wörter.\nTippe auf „Wort hinzufügen“.';

  @override
  String wordbookDetailWordDeleted(String term) {
    return '„$term“ gelöscht';
  }

  @override
  String get wordbookDetailUndo => 'Rückgängig';

  @override
  String get wordbookDetailEditWholeWord => 'Ganzes Wort bearbeiten';

  @override
  String get wordbookDetailEditWord => 'Wort bearbeiten';

  @override
  String get wordbookDetailFavorite => 'Favorit';

  @override
  String get wordbookDetailUnfavorite => 'Aus Favoriten entfernen';

  @override
  String get wordbookDetailEditMeaning => 'Bedeutung bearbeiten';

  @override
  String get wordbookDetailEditAll => 'Alles bearbeiten';

  @override
  String get wordbookDetailStatusFresh => 'Neu';

  @override
  String get wordbookDetailStatusLearning => 'Am Lernen';

  @override
  String get wordbookDetailStatusCompleted => 'Gelernt';

  @override
  String get wordbookDetailDeleteWordConfirm => 'Dieses Wort löschen?';

  @override
  String get wordbookDetailReleaseToDelete => 'Loslassen zum Löschen';

  @override
  String get exploreTitle => 'Entdecken';

  @override
  String get exploreCodeNotFound =>
      'Keine geteilte Wortliste mit diesem Code gefunden.';

  @override
  String get exploreImportFailed =>
      'Import fehlgeschlagen. Prüfe deine Internetverbindung.';

  @override
  String exploreCopyTitle(String title) {
    return '„$title“ kopieren';
  }

  @override
  String exploreCopyConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Wörter in deine Wortlisten kopieren?\nDer Lernfortschritt beginnt von vorn.',
      one:
          '1 Wort in deine Wortlisten kopieren?\nDer Lernfortschritt beginnt von vorn.',
    );
    return '$_temp0';
  }

  @override
  String get exploreCopy => 'Kopieren';

  @override
  String exploreImported(String title) {
    return '„$title“ importiert.';
  }

  @override
  String get exploreLoggedOutHeadline => 'Entdecke neue\nWortlisten';

  @override
  String get exploreLoginRequired =>
      'Melde dich an, um geteilte Wortlisten zu entdecken.';

  @override
  String get exploreGoToLogin => 'Anmelden';

  @override
  String get exploreSupabaseRequired =>
      'Verfügbar nach Verbindung mit Supabase.';

  @override
  String get exploreImportByCode => 'Mit Freigabecode importieren';

  @override
  String get exploreCodeHint => 'Erhaltenen Code einfügen';

  @override
  String get exploreImport => 'Importieren';

  @override
  String get exploreCodeHelp =>
      'Zum Teilen: Kopiere den Code unter „Teilen & Sichtbarkeit“ im Wortlisten-Menü.';

  @override
  String get explorePublicWordbooks => 'Öffentliche Wortlisten';

  @override
  String get explorePublicLoadFailed =>
      'Öffentliche Wortlisten konnten nicht geladen werden.\nZum Aktualisieren nach unten ziehen.';

  @override
  String get explorePublicEmpty => 'Noch keine öffentlichen Wortlisten.';

  @override
  String get loginMigrateTitle => 'Lokale Wortlisten importieren';

  @override
  String loginMigrateConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Wortlisten von diesem Gerät in die Cloud kopieren?\nWortlisten, die schon in der Cloud sind, werden übersprungen.',
      one:
          '1 Wortliste von diesem Gerät in die Cloud kopieren?\nWortlisten, die schon in der Cloud sind, werden übersprungen.',
    );
    return '$_temp0';
  }

  @override
  String get loginLater => 'Später';

  @override
  String get loginImport => 'Importieren';

  @override
  String loginMigrated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wortlisten importiert.',
      one: '1 Wortliste importiert.',
    );
    return '$_temp0';
  }

  @override
  String get loginAlreadyInCloud =>
      'Alle Wortlisten sind bereits in der Cloud.';

  @override
  String get loginErrorInvalidCredentials => 'E-Mail oder Passwort ist falsch.';

  @override
  String get loginErrorUserExists =>
      'Diese E-Mail ist bereits registriert. Bitte melde dich an.';

  @override
  String get loginErrorWeakPassword =>
      'Passwort zu kurz. Verwende mindestens 6 Zeichen.';

  @override
  String get loginErrorEmailNotConfirmed =>
      'Bitte bestätige deine E-Mail. Sieh in deinem Posteingang nach.';

  @override
  String get loginErrorRateLimit =>
      'Zu viele Anfragen. Bitte versuch es später erneut.';

  @override
  String loginErrorGeneric(String message) {
    return 'Anmeldung fehlgeschlagen. ($message)';
  }

  @override
  String get loginErrorNetwork =>
      'Anfrage konnte nicht verarbeitet werden. Prüfe deine Internetverbindung und versuch es erneut.';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginTagline =>
      'Leicht lernen mit Beispielen, dranbleiben mit Erinnerungen';

  @override
  String get loginEmail => 'E-Mail';

  @override
  String get loginPassword => 'Passwort';

  @override
  String get loginSignUpWithEmail => 'Mit E-Mail registrieren';

  @override
  String get loginContinueWithGoogle => 'Weiter mit Google';

  @override
  String get navHome => 'Start';

  @override
  String get navWordbooks => 'Wortlisten';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsTranslationSection => 'Bedeutung · Beispielübersetzung';

  @override
  String get settingsTranslationHelp =>
      '„Auto“ folgt der Sprache und Region deines Geräts. Die Übersetzung wird für Bedeutungen und Beispiele neu nachgeschlagener Wörter verwendet. Bedeutungen ohne Übersetzung zeigen die englische Definition, Beispielübersetzungen bleiben leer. Bereits gespeicherte Inhalte ändern sich nicht automatisch.';

  @override
  String get settingsAppLanguageNote =>
      'Die App wird ebenfalls in dieser Sprache angezeigt. Sprachen ohne App-Übersetzung werden auf Englisch angezeigt.';

  @override
  String get settingsReviewMixSection => 'Mischanteil bei Wiederholung';

  @override
  String get settingsReviewMixLabel => 'Gelernte Wörter einmischen';

  @override
  String settingsReviewMixHelp(int total, int mixed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Fragen',
      one: 'Frage',
    );
    return 'Mischt diesen Anteil „gelernter“ Wörter in die Wiederholung, um das Langzeitgedächtnis zu stärken. (z. B. $mixed von $total $_temp0)';
  }

  @override
  String get settingsReminderSection => 'Erinnerungen · Wiederholung';

  @override
  String get settingsReminderToggle => 'Wiederholungs-Erinnerungen';

  @override
  String get settingsReminderOff => 'Erinnerungen sind aus.';

  @override
  String get settingsReminderNoActive => 'Keine Erinnerungszeiten aktiv.';

  @override
  String settingsReminderSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erinnerungen',
      one: '1 Erinnerung',
    );
    return 'Wöchentlich · $_temp0 pro Woche. Wörter, die du lernst, kommen in der Reihenfolge ihrer Fälligkeit.';
  }

  @override
  String settingsReminderCapped(int limit) {
    return 'Einige späte Erinnerungen entfallen, da sie das Limit des Geräts von $limit geplanten Benachrichtigungen überschreiten.';
  }

  @override
  String get settingsTtsSection => 'Aussprache · TTS';

  @override
  String get settingsTtsDefault => 'Standard-Akzent';

  @override
  String get settingsTtsDefaultHelp =>
      'Wähle den Akzent zum Vorlesen von Wörtern und Beispielen.';

  @override
  String get settingsTtsUs => 'Amerikanisch';

  @override
  String get settingsTtsUk => 'Britisch';

  @override
  String get settingsTtsQuality => 'Sprachqualität';

  @override
  String get settingsTtsQualityValue => 'Geräte-TTS (kostenlos)';

  @override
  String get settingsTatoebaCredit =>
      'Externe Beispiele: Tatoeba · CC BY 2.0 FR';

  @override
  String get reminderEveryDay => 'Täglich';

  @override
  String get reminderNoWeekdays => 'Keine Tage';

  @override
  String get reminderWeekdays => 'Werktags';

  @override
  String get reminderWeekends => 'Wochenende';

  @override
  String reminderIntervalMinutes(int minutes) {
    return 'Alle $minutes Min.';
  }

  @override
  String reminderIntervalHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Alle $hours Std.',
      one: 'Jede Stunde',
    );
    return '$_temp0';
  }

  @override
  String reminderIntervalHoursMinutes(int hours, int minutes) {
    return 'Alle $hours Std. $minutes Min.';
  }

  @override
  String get reminderAddSchedule => 'Erinnerungszeit hinzufügen';

  @override
  String get reminderEditSchedule => 'Erinnerungszeit bearbeiten';

  @override
  String get reminderStart => 'Beginn';

  @override
  String get reminderEnd => 'Ende';

  @override
  String get reminderCrossesMidnight =>
      'Liegt das Ende vor dem Beginn, laufen die Erinnerungen über Mitternacht bis zur Endzeit am nächsten Tag.';

  @override
  String get reminderWeekdaysTitle => 'Erinnerungstage';

  @override
  String get reminderWeekdaysRequired => 'Wähle mindestens einen Tag.';

  @override
  String get reminderInterval => 'Intervall';

  @override
  String get reminderWordsPerAlert => 'Pro Erinnerung';

  @override
  String get reminderDecreaseWords => 'Weniger Wörter';

  @override
  String get reminderIncreaseWords => 'Mehr Wörter';

  @override
  String reminderWordCount(int count) {
    return '$count';
  }

  @override
  String reminderWordCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter',
      one: '1 Wort',
    );
    return '$_temp0';
  }

  @override
  String reminderTimesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal täglich',
      one: 'einmal täglich',
    );
    return '$_temp0';
  }

  @override
  String reminderPreview(String days, int count, String times) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal',
      one: 'einmal',
    );
    return '$days, $_temp0 · $times';
  }

  @override
  String get translationLanguageLabel => 'Übersetzungssprache';

  @override
  String translationLanguageAuto(String language) {
    return 'Auto · $language';
  }

  @override
  String get notificationChannelName => 'Wort-Benachrichtigungen';

  @override
  String get notificationChannelDescription =>
      'Zeigt Wörter und Bedeutungen als Benachrichtigung zu den gewählten Zeiten';

  @override
  String get notificationTitleDefault => 'Wort des Moments';

  @override
  String notificationTitleWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deine $count Wörter für heute',
      one: 'Dein Wort für heute',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyDefault =>
      'Füge Wörter hinzu, dann erscheinen sie hier mit Bedeutung.';

  @override
  String homeError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get homeGreeting => 'Bereit für ein paar Wörter?';

  @override
  String get homeTodayStudy => 'Heute gelernt';

  @override
  String homeTotalWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter insgesamt',
      one: '1 Wort insgesamt',
    );
    return '$_temp0';
  }

  @override
  String get homeAccuracy => 'Trefferquote';

  @override
  String homeCompletedWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gelernt',
      one: '1 gelernt',
    );
    return '$_temp0';
  }

  @override
  String get homeWordOfTheDay => 'Wort des Tages';

  @override
  String get homeQuickStart => 'Schnellstart';

  @override
  String get homeQuickGuessWord => 'Lückentext · tippen';

  @override
  String get homeQuickFillBlank => 'Lückentext · wählen';

  @override
  String get homeQuickBrowseWordbooks => 'Wortlisten ansehen';

  @override
  String get homeCreateWordbookFirst => 'Erstelle zuerst eine Wortliste.';

  @override
  String get homeEditWord => 'Wort bearbeiten';

  @override
  String get homeListenWord => 'Wort anhören';

  @override
  String get homeSeeDetails => 'Details ansehen';

  @override
  String get homeReviewAllDone => 'Alles wiederholt\nfür heute!';

  @override
  String homeReviewWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter\nwarten auf dich',
      one: '1 Wort\nwartet auf dich',
    );
    return '$_temp0';
  }

  @override
  String homeCompletedBadge(int count) {
    return '$count\ngelernt';
  }

  @override
  String homeReviewBreakdown(int due, int mixed) {
    return 'Neu/fällig $due · Gemischt $mixed';
  }

  @override
  String get homeStart => 'Los geht\'s';

  @override
  String get reviewNoExample =>
      '(Kein Beispiel – gib das Wort anhand der Bedeutung ein)';

  @override
  String get reviewTitle => 'Beispiel-Wiederholung';

  @override
  String get reviewEmpty => 'Heute keine Karten';

  @override
  String get reviewFillBlankTitle => 'Lücke füllen';

  @override
  String get reviewChoiceInstruction =>
      'Wähle das Wort, das zu Beispiel und Bedeutung passt';

  @override
  String get reviewInputInstruction =>
      'Gib das Wort ein, das zu Beispiel und Bedeutung passt';

  @override
  String reviewOtherExample(int current, int total) {
    return 'Anderes Beispiel  $current/$total';
  }

  @override
  String get reviewDontKnow => 'Weiß nicht';

  @override
  String get reviewInputHint => 'Wort eingeben';

  @override
  String reviewHint(String hint) {
    return 'Tipp: $hint';
  }

  @override
  String get reviewCheckAnswer => 'Prüfen';

  @override
  String get reviewCorrect => 'Richtig!';

  @override
  String get reviewWrongAnswerIs => 'Nicht ganz. Die Antwort ist';

  @override
  String reviewSource(String source) {
    return 'Quelle: $source';
  }

  @override
  String get reviewMixedNotice => 'Ein gelerntes Wort zur Wiederholung';

  @override
  String get reviewSummaryTitle => 'Wiederholung beendet';

  @override
  String get reviewSummaryDone => 'Du hast die Wiederholung geschafft';

  @override
  String reviewSummaryScore(int correct, int total) {
    return '$correct von $total richtig';
  }

  @override
  String get reviewGoHome => 'Zur Startseite';

  @override
  String get dictionaryRateLimited =>
      'Wörterbuchabfragen sind vorübergehend begrenzt. Bitte versuch es gleich noch einmal.';

  @override
  String get dictionaryConnectionFailed =>
      'Wörterbuch nicht erreichbar. Bitte versuch es gleich noch einmal.';

  @override
  String get dictionaryTimeout =>
      'Das Wörterbuch antwortet nicht. Bitte versuch es erneut.';

  @override
  String get dictionaryLoadFailed =>
      'Wörterbuch-Bedeutungen konnten nicht geladen werden. Prüfe deine Internetverbindung und versuch es erneut.';

  @override
  String get draftDictionaryUnavailable =>
      'Wörterbuch nicht erreichbar. Gib die Bedeutung selbst ein oder such erneut.';

  @override
  String get draftMeaningNotFound =>
      'Keine Bedeutung gefunden. Gib sie selbst ein oder such im Wörterbuch.';

  @override
  String draftNoTranslationUsedEnglish(String language) {
    return 'Das Wörterbuch hat keine Bedeutung auf $language, daher wurden englische Definitionen verwendet. Die Übersetzungssprache kannst du in den Einstellungen ändern.';
  }

  @override
  String draftSomeUsedEnglish(String language) {
    return 'Einträge ohne Bedeutung auf $language wurden mit englischen Definitionen ergänzt.';
  }

  @override
  String get draftExamplesRetry =>
      'Mit „Beispiele laden“ unten kannst du Beispiele erneut laden.';

  @override
  String get speakListen => 'Anhören';

  @override
  String get speakListenExample => 'Beispiel anhören';

  @override
  String get adPreview => 'Anzeigenvorschau';

  @override
  String get addWordButton => 'Wort hinzufügen';

  @override
  String get wordCreateExampleTranslations => 'Übersetzungen einfügen';

  @override
  String get wordCreateNoExampleTranslations => 'Ohne Übersetzung';

  @override
  String get homeRemainingCards => 'Verbleibende Karten';

  @override
  String homeTodayCards(int count) {
    return 'Heute $count wiederholen';
  }

  @override
  String get homeStartButton => 'Start';

  @override
  String get homeNoCardsToday => 'Heute keine Karten';

  @override
  String reviewRemaining(int count) {
    return 'Noch $count';
  }

  @override
  String get reviewKeep => 'Behalten';

  @override
  String get reviewDiscard => 'Ablegen';

  @override
  String reviewDoneTitle(int count) {
    return '$count Karten erledigt';
  }

  @override
  String wordbooksCardsLeft(int count) {
    return 'übrig · $count gesamt';
  }

  @override
  String get wordbookCardsLeftSuffix => 'übrig';

  @override
  String get wordbookDetailAllDiscarded => 'Keine Karten übrig';

  @override
  String wordbookDetailDiscarded(String term) {
    return '\'$term\' abgelegt';
  }

  @override
  String get wordbookDetailReleaseToDiscard => 'Loslassen zum Ablegen';

  @override
  String get wordbookAddWordShort => 'Wort';

  @override
  String get discardedTitle => 'Abgelegt';

  @override
  String get discardedEmpty => 'Nichts abgelegt';

  @override
  String get discardedRestore => 'Zurücklegen';

  @override
  String get wordAddMeaningSelect => 'Bedeutungen wählen';

  @override
  String get wordAddManualInput => 'Bedeutung eingeben';

  @override
  String get wordAddMeaningLabel => 'Bedeutung';

  @override
  String wordAddExamplesOf(String pos) {
    return '$pos-Beispiele';
  }

  @override
  String wordAddSelectedCount(int count) {
    return '$count gewählt';
  }

  @override
  String get wordAddWriteExample => 'Beispiel schreiben';

  @override
  String get wordAddSave => 'Hinzufügen';

  @override
  String get wordAddAlreadyInDeck => 'Schon im Stapel';

  @override
  String get wordAddNoResults => 'Nicht im Wörterbuch';

  @override
  String get wordAddLookupFailed => 'Wörterbuch nicht erreichbar';

  @override
  String get wordAddAutoInput => 'Automatisch ausfüllen';

  @override
  String get wordAddAutoOff => 'Automatik aus';

  @override
  String get wordAddExampleTranslation => 'Übersetzungen';

  @override
  String get wordAddNoExamples =>
      'Keine Beispiele gefunden. Du kannst das Wort auch ohne hinzufügen.';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSlate => 'Schiefer';

  @override
  String get themeNavy => 'Marine';

  @override
  String get themeBrown => 'Braun';

  @override
  String get themePlum => 'Pflaume';

  @override
  String get themeCharcoal => 'Anthrazit';

  @override
  String get themeCustom => 'Eigene';

  @override
  String get themeCustomTitle => 'Eigenes Design';

  @override
  String get themeBase => 'Basis';

  @override
  String get themePoint => 'Akzent';

  @override
  String get themeAutoText => 'Textfarben passen sich an';

  @override
  String get themeApply => 'Anwenden';

  @override
  String get themeReset => 'Zurücksetzen';

  @override
  String get settingsLanguageSection => 'Sprache';

  @override
  String get settingsLanguageRow => 'Bedeutungen · Beispiele · App';

  @override
  String get settingsFollowDevice => 'Wie Gerät';

  @override
  String get settingsReviewSection => 'Wiederholen';

  @override
  String get settingsSessionSize => 'Karten pro Wiederholung';

  @override
  String get settingsMixLabel => 'Abgelegte untermischen';

  @override
  String settingsMixExample(int total, int mixed) {
    return '$mixed von $total';
  }

  @override
  String get settingsWordAddSection => 'Wörter hinzufügen';

  @override
  String get settingsNotificationsSection => 'Erinnerungen';

  @override
  String get settingsReminderMaster => 'Wort-Benachrichtigungen';

  @override
  String get settingsAddSlot => 'Erinnerungszeitraum';

  @override
  String settingsWeeklyCount(int count) {
    return '$count× pro Woche';
  }

  @override
  String reminderCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Karten',
      one: '1 Karte',
    );
    return '$_temp0';
  }

  @override
  String get settingsPronunciationSection => 'Aussprache';

  @override
  String get settingsAccent => 'Akzent';

  @override
  String get settingsVoice => 'Stimme';

  @override
  String get settingsVoiceDefault => 'Standard';

  @override
  String get settingsSpeed => 'Tempo';

  @override
  String get settingsSpeedSlow => 'Langsam';

  @override
  String get settingsSpeedNormal => 'Normal';

  @override
  String get settingsSpeedFast => 'Schnell';

  @override
  String get settingsRecorded => 'Menschliche Aufnahmen für Wörter';

  @override
  String get settingsRecordedHelp => 'Sonst liest die Stimme';

  @override
  String get settingsAbout => 'Info · Quellen';

  @override
  String get settingsPrivacy => 'Datenschutzerklärung';

  @override
  String get aboutDataSources => 'Datenquellen';

  @override
  String get aboutUseMeanings => 'Bedeutungen · Wörterbuchbeispiele';

  @override
  String get aboutUseOnline => 'Online-Wörterbuch';

  @override
  String get aboutUseExamples => 'Übersetzte Beispiele';

  @override
  String get aboutUseRecordings => 'Wortaufnahmen';

  @override
  String get aboutApp => 'App';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String reminderPerDayTotal(int times, int cards) {
    return '$times× täglich · $cards Karten';
  }

  @override
  String settingsPackDownloading(String size) {
    return 'Beispielübersetzungen werden geladen · $size';
  }

  @override
  String settingsPackReady(String size) {
    return 'Beispielübersetzungen bereit · $size';
  }

  @override
  String get settingsPackFailed => 'Übersetzungen konnten nicht geladen werden';

  @override
  String get settingsPackRetry => 'Erneut';

  @override
  String get settingsExampleDataSection => 'Beispieldaten';

  @override
  String get settingsExampleData => 'Beispielübersetzungen laden';

  @override
  String get settingsPackNone => 'Nicht geladen';

  @override
  String get settingsPackNotNeeded => 'Für Englisch nicht nötig';

  @override
  String settingsPackVersion(int version, String size) {
    return 'Geladen · v$version · $size';
  }

  @override
  String get settingsPackUpdate => 'Nach Updates suchen';

  @override
  String settingsPackUpToDate(int version) {
    return 'Aktuell (v$version)';
  }

  @override
  String settingsPackUpdated(int version) {
    return 'Auf v$version aktualisiert';
  }

  @override
  String get examplePromptTitle => 'Beispielübersetzungen laden?';

  @override
  String examplePromptBody(String language, String size) {
    return 'Die $language-Übersetzungen der englischen Beispiele werden geladen$size. Jederzeit änderbar unter Einstellungen › Beispieldaten.';
  }

  @override
  String get examplePromptAccept => 'Laden';

  @override
  String get examplePromptDecline => 'Nicht jetzt';

  @override
  String get wordAddPosLabel => 'Wortart';

  @override
  String get wordAddPosUnknown => 'Unbekannt';

  @override
  String get homeQuickGuessFromMeaning => 'Wort aus der Bedeutung erraten';

  @override
  String get wordFoundExample => 'Gefundenes Beispiel';

  @override
  String get wordAddFoundExample => 'Beispiel hinzufügen';

  @override
  String wordbookFoundExamples(int count) {
    return '$count Beispiele gefunden';
  }

  @override
  String get wordAddScanExample => 'Beispiele aus einem Foto';

  @override
  String get wordScanCamera => 'Foto aufnehmen';

  @override
  String get wordScanGallery => 'Aus Fotos wählen';

  @override
  String get wordScanFailed => 'Text im Foto konnte nicht gelesen werden';

  @override
  String wordScanNoSentence(String term) {
    return 'Kein Satz mit „$term“ im Foto gefunden';
  }

  @override
  String get exampleSourcePhoto => 'Mein Foto';

  @override
  String wordScanAdded(int count) {
    return '$count Sätze aus dem Foto hinzugefügt';
  }

  @override
  String homeNewReviewBreakdown(int fresh, int review) {
    return 'Neu $fresh · Wiederholen $review';
  }

  @override
  String get settingsAnswerStyle => 'Antwortart';

  @override
  String get settingsAnswerInput => 'Wort eintippen';

  @override
  String get settingsAnswerChoice => 'Aus 4 auswählen';

  @override
  String get settingsAnswerHelp =>
      'Gilt, wenn du auf dem Startbildschirm mit Start wiederholst.';

  @override
  String get sampleWelcomeMeaning => 'willkommen';

  @override
  String get sampleWelcomeExample1 => 'Willkommen bei Vocab with Examples!';

  @override
  String get sampleWelcomeExample2 => 'Willkommen zurück, alle zusammen.';

  @override
  String get homeAddCardHint =>
      'Gib ein englisches Wort ein – Bedeutungen und Beispiele kommen auf die Karte';
}
